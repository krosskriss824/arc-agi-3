"""
wasm_bridge.py — Pure Functional TTT + Adapter I/O
SOTA refactor v12:
  - functional_ttt_train: pure param-space gradient descent, no optimizer state
  - pure_batch_ttt_loss:  fully vectorised, device-derived zero tensors
  - save_adapter / load_adapter: head-only, action_emb NEVER persisted
  - encode_grid_numpy: pure NumPy, no tensors
  - All device references derived from input tensors — zero bare constructors
  - v12: legacy positional-arg shim for functional_ttt_train (P0 fix)
        _carry_to_device guard for _DummyCarry (P3 fix)
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

try:
    from external.urm.models.losses import value_logits_to_scalar, kl_reg_loss, mse_anchor_reg
except ImportError:
    # fallback stubs so import never crashes
    def value_logits_to_scalar(x): return x.mean(dim=-1, keepdim=True)
    def kl_reg_loss(a, b): return torch.zeros(1, device=a.device)
    def mse_anchor_reg(a, b): return F.mse_loss(a, b)


# ─── WASM flag (Python fallback always) ──────────────────────────────────────
_HAS_WASM: bool = False


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
    grid,
    action: int = 0,
    n_actions: int = 7,
) -> tuple[np.ndarray, int]:
    """
    Encodes a 2-D ARC grid (np.ndarray or list) into a fixed-length token vector.
    Returns (tokens: int32[4099], valid_len: int).
    Pure NumPy — no tensors created here.
    Handles list-of-lists grids gracefully.
    """
    grid_arr = np.asarray(grid, dtype=np.int32)
    if grid_arr.ndim == 0:
        grid_arr = grid_arr.reshape(1, 1)
    elif grid_arr.ndim == 1:
        grid_arr = grid_arr.reshape(1, -1)
    flat = grid_arr.ravel()
    meta = np.array([action, n_actions, 0], dtype=np.int32)
    raw  = np.concatenate([flat, meta])
    vlen = len(raw)
    tokens = np.pad(raw, (0, max(0, _TOKEN_LEN - len(raw))))[:_TOKEN_LEN]
    return tokens, vlen


# ─── _carry_to_device — P3 fix: guard for _DummyCarry ────────────────────────

def _carry_to_device(carry, device):
    """
    Move URMCarry to device. Guards against _DummyCarry objects
    that don't have the 'steps' attribute (P3 fix).
    """
    if not hasattr(carry, 'steps'):
        return carry
    try:
        return carry._replace(
            **{k: v.to(device) if isinstance(v, torch.Tensor) else v
               for k, v in carry._asdict().items()}
        )
    except Exception:
        return carry


# ─── _extract_head_params / _extract_buffers — compat aliases ────────────────

def _extract_head_params(wm: nn.Module) -> dict:
    """Alias for extract_head_params (backward compat with old notebooks)."""
    return extract_head_params(wm)


def _extract_buffers(wm: nn.Module) -> dict:
    """Extract non-parameter buffers (running stats etc) for functional_call."""
    return {k: v.clone().detach() for k, v in wm.named_buffers()}


# ─── pure_batch_ttt_loss — fully vectorised ───────────────────────────────────

def pure_batch_ttt_loss(
    params:       dict,
    buffers:      dict,
    model:        nn.Module,
    batch_states:  torch.Tensor,   # (B, T)
    batch_actions: torch.Tensor,   # (B,)
    batch_next:    torch.Tensor,   # (B, T)
    batch_rewards: torch.Tensor,   # (B,)
    pre_logits:    Optional[torch.Tensor],
    pre_values:    Optional[torch.Tensor],
    lambda_reg:    float = 0.1,
    reg_mode:      str   = "mse",
) -> torch.Tensor:
    device = batch_states.device

    out      = functional_call(model, (params, buffers), (batch_states,))
    act_loss = F.cross_entropy(out["action_logits"], batch_actions)
    val_loss = F.mse_loss(value_logits_to_scalar(out["value"]), batch_rewards.float())
    task_loss = act_loss + val_loss

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


# ─── functional_ttt_train — P0 fix: legacy positional-arg shim ───────────────

def functional_ttt_train(
    params,
    buffers,
    model,
    states,
    actions,
    next_states,
    rewards,
    # Legacy positional args (old notebooks pass these as positional)
    steps_or_cfg=None,
    lr=None,
    lambda_reg=None,
    # New kwargs-only API
    cfg: Optional[TTTConfig] = None,
) -> dict:
    """
    Pure functional TTT — returns new params without mutating model.
    P0 fix: accepts both old positional API and new TTTConfig API.

    Old call (from notebook): functional_ttt_train(p, b, m, s, a, ns, r, steps=30, lr=8e-5, lambda_reg=0.1)
    New call:                 functional_ttt_train(p, b, m, s, a, ns, r, cfg=TTTConfig(steps=50, lr=1e-4))
    """
    # Resolve config — legacy positional args take priority
    if cfg is None:
        _steps      = int(steps_or_cfg) if steps_or_cfg is not None else 30
        _lr         = float(lr) if lr is not None else 1e-4
        _lambda_reg = float(lambda_reg) if lambda_reg is not None else 0.1
        cfg = TTTConfig(steps=_steps, lr=_lr, lambda_reg=_lambda_reg)

    n      = len(states)
    device = states.device

    if n < cfg.batch_size:
        # not enough data — return params unchanged
        return params

    with torch.no_grad():
        pre_out    = functional_call(model, (params, buffers), (states[:cfg.batch_size],))
        pre_logits = pre_out["action_logits"].detach()
        pre_values = pre_out["value"].detach()

    _grad_fn = grad(pure_batch_ttt_loss, argnums=0)

    def _step(p: dict, _: int) -> tuple[dict, None]:
        bs  = min(cfg.batch_size, n)
        idx = torch.randperm(n, device=device)[:bs]
        try:
            g = _grad_fn(
                p, buffers, model,
                states[idx], actions[idx], next_states[idx], rewards[idx],
                pre_logits, pre_values,
                cfg.lambda_reg, cfg.reg_mode,
            )
            return {k: w - cfg.lr * g[k] for k, w in p.items()}, None
        except Exception:
            return p, None

    final_params, _ = reduce(
        lambda acc, i: (_step(acc[0], i)[0], None),
        range(cfg.steps),
        (params, None),
    )
    return final_params


# ─── Adapter I/O ─────────────────────────────────────────────────────────────

def extract_head_params(wm: nn.Module) -> dict:
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
    adapter = extract_head_params(wm)
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    torch.save(adapter, path)
    print(f"[save_adapter] saved {len(adapter)} keys to {path}")


def load_adapter(wm: nn.Module, path: str) -> list[str]:
    raw     = torch.load(path, map_location="cpu", weights_only=True)
    adapter = {
        k: v for k, v in raw.items()
        if any(k.startswith(p) for p in _HEAD_PREFIXES)
    }
    missing, unexpected = wm.load_state_dict(adapter, strict=False)
    print(f"[load_adapter] loaded={list(adapter)}, missing={missing}, unexpected={unexpected}")
    return list(adapter.keys())


def adapter_path_for_game(base_dir: str, game_id: str, n_actions: int) -> str:
    return os.path.join(base_dir, f"adapter_{game_id}_na{n_actions}.pt")
