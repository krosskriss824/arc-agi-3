"""
ttt_submission.py v2 — TTT with real observations + multi-GPU guard

Changes vs v1:
  - ttt_on_trajectory now accepts obs_history (real grids)
  - Uses real encoded tokens instead of dummy zeros
  - Multi-GPU: auto-detects DataParallel / device count
  - Backbone stays frozen; only action_head + value_head updated
  - ~200ms / 50 steps on T4 (unchanged)
"""
from __future__ import annotations
from typing import Optional
import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np


def _get_device(agent) -> torch.device:
    """Unwrap DataParallel if needed."""
    wm = agent.wm
    if isinstance(wm, nn.DataParallel):
        wm = wm.module
    return wm._device


def _get_wm(agent):
    """Unwrap DataParallel."""
    wm = agent.wm
    if isinstance(wm, nn.DataParallel):
        return wm.module
    return wm


def ttt_on_trajectory(
    agent,
    action_history:  list[int],
    reward_history:  list[float],
    obs_history:     Optional[list] = None,
    steps:           int   = 50,
    lr:              float = 5e-4,
) -> None:
    """
    Update action_head + value_head on observed (obs, action, reward) tuples.
    Modifies agent.wm in-place. Backbone stays frozen.

    Args:
        agent:          VERICODINGAgent
        action_history: list[int] from beam/explorer
        reward_history: list[float] corresponding rewards
        obs_history:    list of raw grids (np.ndarray 2D) or None
                        If None, falls back to dummy zeros (old behaviour)
        steps:          gradient steps
        lr:             learning rate
    """
    n = min(len(action_history), len(reward_history))
    if n == 0:
        return

    wm     = _get_wm(agent)
    device = _get_device(agent)

    actions = torch.tensor(action_history[:n], dtype=torch.long,   device=device)
    rewards = torch.tensor(reward_history[:n],  dtype=torch.float32, device=device)

    # ── Build state tokens from real observations ──────────────────────────
    if obs_history and len(obs_history) >= n:
        try:
            from wasm_bridge import encode_grid_numpy
            token_list = []
            for obs in obs_history[:n]:
                grid = np.asarray(obs, dtype=np.int32)
                if grid.ndim == 3:
                    grid = grid[0]
                tok, _ = encode_grid_numpy(grid)
                token_list.append(tok)
            state_tokens = torch.from_numpy(
                np.stack(token_list)
            ).long().to(device)                    # (n, seq_len)
        except Exception as e:
            print(f"[TTT] obs encode failed ({e}), falling back to zeros")
            state_tokens = torch.zeros(n, 1, dtype=torch.long, device=device)
    else:
        # Fallback: dummy zeros (gradient on bias only — still useful for reward signal)
        H = wm.cfg.hidden_size
        state_tokens = torch.zeros(n, 1, dtype=torch.long, device=device)

    # ── Freeze backbone, unfreeze heads ───────────────────────────────────
    for name, param in wm.named_parameters():
        param.requires_grad = (
            name.startswith("action_head.") or
            name.startswith("value_head.")
        )

    head_params = [p for p in wm.parameters() if p.requires_grad]
    if not head_params:
        print("[TTT] no trainable head params — skip")
        return

    opt = torch.optim.Adam(head_params, lr=lr)

    # ── Multi-GPU info ─────────────────────────────────────────────────────
    n_gpus = torch.cuda.device_count()
    if n_gpus > 1:
        print(f"[TTT] {n_gpus} GPUs detected — TTT runs on cuda:0 (heads only, DataParallel not needed)")

    # ── Training loop ──────────────────────────────────────────────────────
    wm.train()
    last_act_loss = last_val_loss = 0.0
    for step in range(steps):
        opt.zero_grad()

        out        = wm(state_tokens, action=None)
        logits     = out["action_logits"]         # (n, n_actions)
        val_out    = out["value"].float()          # (n, 5)

        act_loss   = F.cross_entropy(logits, actions)
        val_pred   = val_out.mean(dim=-1)          # (n,)
        val_loss   = F.mse_loss(val_pred, rewards)

        loss = act_loss + 0.5 * val_loss
        loss.backward()
        torch.nn.utils.clip_grad_norm_(head_params, 1.0)
        opt.step()
        last_act_loss = act_loss.item()
        last_val_loss = val_loss.item()

    wm.eval()
    for param in wm.parameters():
        param.requires_grad = False

    print(f"[TTT] {steps} steps | n={n} | act={last_act_loss:.4f} val={last_val_loss:.4f} | device={device}")
