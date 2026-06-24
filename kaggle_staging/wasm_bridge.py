"""
wasm_bridge.py — Pure Functional TTT + Adapter I/O
SOTA refactor v11:
  - functional_ttt_train: pure param-space gradient descent, no optimizer state
  - pure_batch_ttt_loss:  fully vectorised, device-derived zero tensors
  - save_adapter / load_adapter: head-only, action_emb NEVER persisted
  - encode_grid_numpy: pure NumPy, no tensors
  - All device references derived from input tensors — zero bare constructors
"""
from __future__ import annotations
from dataclasses import dataclass
from functools import reduce
from typing import Optional
import os

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.func import functional_call, grad

from external.urm.models.losses import value_logits_to_scalar, kl_reg_loss, mse_anchor_reg


# ─── Constants ────────────────────────────────────────────────────────────────

_TOKEN_LEN: int = 4099
_HEAD_PREFIXES: tuple[str, ...] = ("action_head.", "value_head.")


# ─── Algebraic config ─────────────────────────────────────────────────────────

@dataclass(frozen=True)
class TTTConfig:
    steps:       int   = 100
    lr:          float = 1e-4
    lambda_reg:  float = 0.1
    batch_size:  int   = 4
    reg_mode:    str   = "mse"   # "mse" | "kl"


@dataclass(frozen=True)
class AdapterCfg:
    head_prefixes: tuple[str, ...] = _HEAD_PREFIXES


# ─── Grid encoding — pure NumPy ───────────────────────────────────────────────

def encode_grid_numpy(
    grid: np.ndarray,
    action: int = 0,
    n_actions: int = 7,
) -> tuple[np.ndarray, int]:
    """
    Encodes a 2-D ARC grid into a fixed-length token vector.
    Returns (tokens: int32[4099], valid_len: int).
    Pure NumPy — no tensors created here.

    Layout: [grid_ravel | action | n_actions | 0 | <pad>]
    valid_len = h*w + 3
    """
    flat = grid.ravel().astype(np.int32)
    meta = np.array([action, n_actions, 0], dtype=np.int32)
    raw  = np.concatenate([flat, meta])
    vlen = len(raw)                                        # h*w + 3
    tokens = np.pad(raw, (0, max(0, _TOKEN_LEN - len(raw))))[:_TOKEN_LEN]
    return tokens, vlen


# ─── pure_batch_ttt_loss — fully vectorised ───────────────────────────────────

def pure_batch_ttt_loss(
    params:       dict,
    buffers:      dict,
    model:        nn.Module,
    batch_states:  torch.Tensor,   # (B, T)
    batch_actions: torch.Tensor,   # (B,)
    batch_next:    torch.Tensor,   # (B, T) — unused in base loss, kept for API compat
    batch_rewards: torch.Tensor,   # (B,)
    pre_logits:    Optional[torch.Tensor],  # (B_pre, A) anchor
    pre_values:    Optional[torch.Tensor],  # (B_pre, 5) anchor
    lambda_reg:    float = 0.1,
    reg_mode:      str   = "mse",
) -> torch.Tensor:
    """
    Pure functional loss: no optimizer state, no in-place ops.
    Device derived from batch_states.device — zero bare constructors.
    """
    device = batch_states.device

    out      = functional_call(model, (params, buffers), (batch_states,))
    act_loss = F.cross_entropy(out["action_logits"], batch_actions)
    val_loss = F.mse_loss(value_logits_to_scalar(out["value"]), batch_rewards.float())
    task_loss = act_loss + val_loss

    # Regularisation via anchor — pattern-matched on presence, no if-branches in hot path
    has_anchor = (pre_logits is not None) and (pre_values is not None)
    reg_loss   = (
        {
            "mse": lambda: (
                mse_anchor_reg(out["action_logits"][:len(batch_states)], pre_logits)
                + mse_anchor_reg(out["value"][:len(batch_states)], pre_values)
            ),
            "kl": lambda: (
                kl_reg_loss(out["action_logits"][:len(batch_states)], pre_logits)
                + mse_anchor_reg(out["value"][:len(batch_states)], pre_values)
            ),
        }.get(reg_mode, lambda: torch.zeros(1, device=device))()
        if has_anchor
        else torch.zeros(1, device=device)
    )

    return task_loss + lambda_reg * reg_loss


# ─── functional_ttt_train — pure param-space gradient descent ────────────────

def functional_ttt_train(
    params:       dict,
    buffers:      dict,
    model:        nn.Module,
    states:       torch.Tensor,   # (N, T)
    actions:      torch.Tensor,   # (N,)
    next_states:  torch.Tensor,   # (N, T)
    rewards:      torch.Tensor,   # (N,)
    cfg:          TTTConfig = TTTConfig(),
) -> dict:
    """
    Pure functional TTT — returns new params without mutating model.
    Uses torch.func.grad for parameter-space gradients.
    All randomness (randperm) on states.device — no CPU index leakage.

    Mathematical identity:
        p_{t+1} = p_t - lr * ∇_{p_t} L(p_t)
        final = reduce(step, range(steps), params)
    """
    n      = len(states)
    device = states.device   # SINGLE source of truth for all new tensors

    # compute anchor predictions once (detached)
    with torch.no_grad():
        pre_out    = functional_call(model, (params, buffers), (states[:cfg.batch_size],))
        pre_logits = pre_out["action_logits"].detach()
        pre_values = pre_out["value"].detach()

    _grad_fn = grad(pure_batch_ttt_loss, argnums=0)

    def _step(p: dict, _: int) -> tuple[dict, None]:
        # sample indices on device — no CPU randperm
        bs  = min(cfg.batch_size, n)
        idx = torch.randperm(n, device=device)[:bs]
        g   = _grad_fn(
            p, buffers, model,
            states[idx], actions[idx], next_states[idx], rewards[idx],
            pre_logits, pre_values,
            cfg.lambda_reg, cfg.reg_mode,
        )
        return {k: w - cfg.lr * g[k] for k, w in p.items()}, None

    # pure fold — functional reduce over steps
    final_params, _ = reduce(
        lambda acc, i: (_step(acc[0], i)[0], None),
        range(cfg.steps),
        (params, None),
    )
    return final_params


# ─── Adapter I/O ─────────────────────────────────────────────────────────────

def extract_head_params(wm: nn.Module) -> dict:
    """
    Returns ONLY action_head.* and value_head.* from wm state_dict (CPU, detached).
    action_emb is NEVER included — invariant enforced by assertion.
    """
    sd = wm.state_dict()
    adapter = {
        k: v.clone().detach().cpu()
        for k, v in sd.items()
        if any(k.startswith(p) for p in _HEAD_PREFIXES)
    }
    bad = [k for k in adapter if not any(k.startswith(p) for p in _HEAD_PREFIXES)]
    assert not bad, f"[extract_head_params] Invariant violated — unexpected keys: {bad}"
    return adapter


def save_adapter(wm: nn.Module, path: str) -> None:
    """
    Save head-only adapter. Creates parent dirs. Verifies invariant before write.
    """
    adapter = extract_head_params(wm)
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    torch.save(adapter, path)
    print(f"[save_adapter] saved {len(adapter)} keys to {path}")


def load_adapter(wm: nn.Module, path: str) -> list[str]:
    """
    Load head adapter into wm. Never touches action_emb.
    Returns list of loaded keys for logging.
    strict=False: missing/unexpected keys are logged, not raised.
    """
    raw     = torch.load(path, map_location="cpu", weights_only=True)
    adapter = {
        k: v for k, v in raw.items()
        if any(k.startswith(p) for p in _HEAD_PREFIXES)
    }
    missing, unexpected = wm.load_state_dict(adapter, strict=False)
    print(f"[load_adapter] loaded={list(adapter)}, missing={missing}, unexpected={unexpected}")
    return list(adapter.keys())


def adapter_path_for_game(base_dir: str, game_id: str, n_actions: int) -> str:
    """Deterministic per-game adapter path (heads are action-space-agnostic)."""
    return os.path.join(base_dir, f"adapter_{game_id}_na{n_actions}.pt")
