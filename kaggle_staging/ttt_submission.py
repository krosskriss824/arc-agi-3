"""
ttt_submission.py v3 — TTT with real observations + variable-length grid fix

Changes vs v2:
  - encode_grid_numpy may return different seq_len per grid (depends on grid size)
  - v3: pad all tokens to same seq_len before torch.stack (fixes RuntimeError)
  - Fallback: if any grid fails to encode, skip it rather than crashing
  - Multi-GPU: auto-detects DataParallel / device count (unchanged)
  - Backbone frozen; only action_head + value_head updated (unchanged)
"""
from __future__ import annotations
from typing import Optional
import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np


def _get_device(agent) -> torch.device:
    wm = agent.wm
    if isinstance(wm, nn.DataParallel):
        wm = wm.module
    return wm._device


def _get_wm(agent):
    wm = agent.wm
    if isinstance(wm, nn.DataParallel):
        return wm.module
    return wm


def _encode_obs_batch(obs_list, device) -> Optional[torch.Tensor]:
    """
    Encode a list of raw observations to a padded token tensor (n, max_seq_len).
    Skips observations that fail to encode.
    Returns None if no observations could be encoded.
    """
    from wasm_bridge import encode_grid_numpy
    token_arrays = []
    valid_indices = []
    for idx, obs in enumerate(obs_list):
        try:
            grid = np.asarray(obs, dtype=np.int32)
            if grid.ndim == 3:
                grid = grid[0]
            if grid.ndim != 2:
                continue
            tok, _ = encode_grid_numpy(grid)  # (seq_len,) int32
            token_arrays.append(tok)
            valid_indices.append(idx)
        except Exception:
            continue

    if not token_arrays:
        return None, []

    # Pad to same length
    max_len = max(t.shape[0] for t in token_arrays)
    padded  = np.zeros((len(token_arrays), max_len), dtype=np.int32)
    for i, t in enumerate(token_arrays):
        padded[i, :t.shape[0]] = t

    return torch.from_numpy(padded).long().to(device), valid_indices


def ttt_on_trajectory(
    agent,
    action_history:  list,
    reward_history:  list,
    obs_history:     Optional[list] = None,
    steps:           int   = 50,
    lr:              float = 5e-4,
) -> None:
    """
    Update action_head + value_head on observed (obs, action, reward) tuples.
    Modifies agent.wm in-place. Backbone stays frozen.

    Args:
        agent:          object with .wm attribute (VERICODINGAgent or wrapper)
        action_history: list[int]
        reward_history: list[float]
        obs_history:    list of raw grids (np.ndarray 2D/3D) or None
        steps:          gradient steps
        lr:             learning rate
    """
    n = min(len(action_history), len(reward_history))
    if n == 0:
        return

    wm     = _get_wm(agent)
    device = _get_device(agent)

    # ── Build state tokens ──────────────────────────────────────────────────
    valid_indices = list(range(n))   # default: all
    if obs_history and len(obs_history) >= n:
        state_tokens, valid_indices = _encode_obs_batch(obs_history[:n], device)
        if state_tokens is None:
            # Full encode failure → dummy zeros
            state_tokens  = torch.zeros(n, 1, dtype=torch.long, device=device)
            valid_indices = list(range(n))
    else:
        state_tokens  = torch.zeros(n, 1, dtype=torch.long, device=device)
        valid_indices = list(range(n))

    # Filter actions/rewards to valid indices
    actions = torch.tensor(
        [action_history[i] for i in valid_indices], dtype=torch.long, device=device
    )
    rewards = torch.tensor(
        [reward_history[i] for i in valid_indices], dtype=torch.float32, device=device
    )
    n_valid = len(valid_indices)
    if n_valid == 0:
        return

    # ── Freeze backbone, unfreeze heads ────────────────────────────────────
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

    n_gpus = torch.cuda.device_count()
    if n_gpus > 1:
        print(f"[TTT] {n_gpus} GPUs — TTT on cuda:0 (heads only)")

    # ── Training loop ───────────────────────────────────────────────────────
    wm.train()
    last_act_loss = last_val_loss = 0.0
    for step in range(steps):
        opt.zero_grad()
        out       = wm(state_tokens, action=None)
        logits    = out["action_logits"]        # (n_valid, n_actions)
        val_out   = out["value"].float()         # (n_valid, 5)
        act_loss  = F.cross_entropy(logits, actions)
        val_pred  = val_out.mean(dim=-1)         # (n_valid,)
        val_loss  = F.mse_loss(val_pred, rewards)
        loss      = act_loss + 0.5 * val_loss
        loss.backward()
        torch.nn.utils.clip_grad_norm_(head_params, 1.0)
        opt.step()
        last_act_loss = act_loss.item()
        last_val_loss = val_loss.item()

    wm.eval()
    for param in wm.parameters():
        param.requires_grad = False

    print(f"[TTT] steps={steps} n={n_valid}/{n} act={last_act_loss:.4f} "
          f"val={last_val_loss:.4f} device={device}")
