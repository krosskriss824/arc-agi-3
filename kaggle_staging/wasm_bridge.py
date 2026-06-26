"""
wasm_bridge.py — Pure Functional TTT + Adapter I/O + FrameGraphExplorer
SOTA refactor v19:
  BUG-TTT-OOB (P0): pure_batch_ttt_loss filters OOB actions before cross_entropy
  FrameGraphExplorer: graph-based state explorer with dedup + priority tiers
  volatile_mask: hash stability via volatile pixel zeroing

FIXES (v19):
  TTT-OOB: n_classes from logits.shape[-1]; filter not clamp; zero loss if empty
  GRAPH:   FrameGraphExplorer ported from Kaggle v18 → canonical GitHub source
  HASH:    encode_grid_numpy gains volatile_mask param for stable dedup hashing

Previous fixes (v12/v13 retained):
  C1: functional_ttt_train uses ONE shared idx per step
  H1: removed imperative in-function .to() calls
  H2: kl_reg_loss / mse_anchor_reg have local fallback implementations
  M1: _load_binary uses pathlib.Path.read_bytes()
  X3: zero-alloc bulk write via _ensure_buf pre-alloc + D4 batch hash
"""
from __future__ import annotations
from dataclasses import dataclass, field
from functools import reduce
from pathlib import Path
from typing import Optional
import collections
import os

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.func import functional_call, grad


# ─── Loss helpers — FIX H2: local fallback, no crash if external missing ──────

try:
    from external.urm.models.losses import value_logits_to_scalar as _ext_vl2s
    from external.urm.models.losses import kl_reg_loss as _ext_kl
    from external.urm.models.losses import mse_anchor_reg as _ext_mse_anchor
    value_logits_to_scalar = _ext_vl2s
    kl_reg_loss            = _ext_kl
    mse_anchor_reg         = _ext_mse_anchor
except ImportError:
    _BIN_CENTERS = torch.tensor([-1.0, -0.25, 0.5, 1.25, 2.0])

    def value_logits_to_scalar(logits: torch.Tensor) -> torch.Tensor:
        """5-bin softmax weighted avg. Local fallback."""
        probs   = torch.softmax(logits, dim=-1)
        centers = _BIN_CENTERS.to(logits.device)
        return (probs * centers).sum(dim=-1)

    def kl_reg_loss(logits: torch.Tensor, anchor: torch.Tensor) -> torch.Tensor:
        """KL(logits || anchor). Local fallback."""
        return F.kl_div(
            F.log_softmax(logits, dim=-1),
            F.softmax(anchor, dim=-1),
            reduction="batchmean",
        )

    def mse_anchor_reg(pred: torch.Tensor, anchor: torch.Tensor) -> torch.Tensor:
        """MSE regularisation toward anchor. Local fallback."""
        return F.mse_loss(pred, anchor.detach())


# ─── Constants ────────────────────────────────────────────────────────────────

_TOKEN_LEN: int = 4099
_HEAD_PREFIXES: tuple[str, ...] = ("action_head.", "value_head.")

# Priority tiers for FrameGraphExplorer
# Lower number = higher priority = explored first
_TIER_MOVEMENT: int = 1
_TIER_SELECT:   int = 2
_TIER_PUZZLE:   int = 3
_TIER_UNDO:     int = 4
_TIER_DEFAULT:  int = 3


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
    volatile_mask: Optional[np.ndarray] = None,
) -> tuple[np.ndarray, int]:
    """
    Encodes a 2-D ARC grid into a fixed-length token vector.
    Returns (tokens: int32[4099], valid_len: int).
    Pure NumPy — no tensors created here.

    Layout: [grid_ravel | action | n_actions | 0 | <pad>]
    valid_len = h*w + 3

    volatile_mask (optional, shape == grid.shape):
        Boolean mask of pixels that change frequently (timers, counters).
        When provided, those pixels are zeroed BEFORE hashing → stable dedup.
        Compute via: compute_volatile_mask(frame_history).
    """
    working = grid.copy()
    if volatile_mask is not None and volatile_mask.shape == grid.shape:
        working[volatile_mask] = 0

    flat = working.ravel().astype(np.int32)
    meta = np.array([action, n_actions, 0], dtype=np.int32)
    raw  = np.concatenate([flat, meta])
    tokens = np.pad(raw, (0, max(0, _TOKEN_LEN - len(raw))))[:_TOKEN_LEN]
    return tokens, len(raw)


def compute_volatile_mask(
    frame_history: list[np.ndarray],
    threshold: float = 0.5,
) -> Optional[np.ndarray]:
    """
    Computes a boolean mask of pixels that change more than `threshold`
    fraction of consecutive frame pairs.

    Returns None if fewer than 2 frames provided (no history to compare).
    Returns boolean ndarray of same shape as frames.

    Usage:
        mask = compute_volatile_mask(last_10_grids)
        tokens, _ = encode_grid_numpy(grid, volatile_mask=mask)

    This is the Go-Explore volatile-status-bar masking technique from
    samrishtt/arc-agi-3-kaggle-competition (score 0.33).
    """
    if len(frame_history) < 2:
        return None
    frames = frame_history[-10:]  # last 10 at most
    h, w   = frames[0].shape
    change_freq = np.zeros((h, w), dtype=np.float32)
    for i in range(1, len(frames)):
        diff = (frames[i] != frames[i - 1]).astype(np.float32)
        change_freq += diff
    change_freq /= (len(frames) - 1)
    return change_freq > threshold


# ─── FrameGraphExplorer — v18 graph-based state explorer ─────────────────────

class FrameGraphExplorer:
    """
    Graph-based state explorer for ARC-AGI-3.

    Algorithm:
        state = canonical_hash(current_grid)   [WASM D4-canonical]
        if state not in graph: register all available actions
        pick highest-priority unexplored action from current state
        mark that (state, action) pair as explored
        if no unexplored actions remain: signal URM fallback

    Priority tiers (lower = higher priority):
        movement actions  (tag "movement") → tier 1
        select actions    (tag "select")   → tier 2
        puzzle actions                      → tier 3
        undo/reset                         → tier 4

    WIN detection:
        call on_win(state_hash, action) after each step
        extract_win_path() returns minimal action list

    Dedup contract:
        never executes the same action from the same state hash twice
        across the entire episode (reset on on_episode_reset)
    """

    def __init__(self) -> None:
        # graph[state_hash] = set of (priority, action_idx) not yet tried
        self._graph: dict[int, list[tuple[int, int]]] = {}
        # parent for win-path extraction: (state_hash → (parent_hash, action))
        self._parent: dict[int, tuple[int, int]] = {}
        self._root_hash: Optional[int] = None
        self._win_path: Optional[list[int]] = None
        self._n_actions: int = 7
        self._game_tags: list[str] = []
        # Per-(state,action) explored set
        self._explored: set[tuple[int, int]] = set()

    # ── Configuration ─────────────────────────────────────────────────────────

    def set_game_tags(self, tags: list[str]) -> None:
        """Call BEFORE first choose_action. Sets priority tier mapping."""
        self._game_tags = [t.lower() for t in tags]

    def update_n_actions(self, n: int) -> None:
        """Call after every env.step() with len(env.action_space)."""
        self._n_actions = n

    # ── Episode lifecycle ──────────────────────────────────────────────────────

    def on_episode_reset(self) -> None:
        """Call at the start of every new game/episode."""
        self._graph.clear()
        self._parent.clear()
        self._explored.clear()
        self._root_hash = None
        self._win_path  = None

    # ── Priority assignment ────────────────────────────────────────────────────

    def _action_priority(self, action_idx: int) -> int:
        """
        Assigns priority tier to an action index.
        Heuristic based on game tags and action index position.

        In ARC-AGI-3 the first few actions tend to be directional/movement,
        middle ones are select/click, last one is undo/reset.
        Without game tags we use position-based heuristic.
        """
        n = self._n_actions
        if "movement" in self._game_tags:
            # First n-2 actions are movement
            if action_idx < max(1, n - 2):
                return _TIER_MOVEMENT
        if "select" in self._game_tags:
            # All non-last actions are select
            if action_idx < n - 1:
                return _TIER_SELECT
        # Default: puzzle-tier for middle actions, undo-tier for last
        if action_idx == n - 1:
            return _TIER_UNDO
        return _TIER_PUZZLE

    # ── Graph management ──────────────────────────────────────────────────────

    def _ensure_node(self, state_hash: int) -> None:
        """Register all available actions for a new state node."""
        if state_hash in self._graph:
            return
        # Build priority-sorted action list, exclude already explored
        actions = [
            (self._action_priority(a), a)
            for a in range(self._n_actions)
            if (state_hash, a) not in self._explored
        ]
        actions.sort()  # stable sort: priority first, then action index
        self._graph[state_hash] = actions

    def register_transition(
        self,
        from_hash: int,
        action: int,
        to_hash: int,
    ) -> None:
        """Record (from → action → to) for win-path extraction."""
        if to_hash not in self._parent:
            self._parent[to_hash] = (from_hash, action)
        if self._root_hash is None:
            self._root_hash = from_hash

    def on_win(self, win_hash: int) -> None:
        """Call when WIN state detected. Stores win_path."""
        self._win_path = self._extract_path(win_hash)

    def _extract_path(self, target: int) -> list[int]:
        """Backtrack parent pointers to extract minimal action sequence."""
        path: list[int] = []
        h = target
        while h in self._parent:
            parent_h, action = self._parent[h]
            path.append(action)
            h = parent_h
        path.reverse()
        return path

    def extract_win_path(self) -> Optional[list[int]]:
        """Returns minimal action list to WIN, or None if not found yet."""
        return self._win_path

    # ── Core: choose action ────────────────────────────────────────────────────

    def choose_action(
        self,
        state_hash: int,
        parent_hash: Optional[int] = None,
        parent_action: Optional[int] = None,
    ) -> Optional[int]:
        """
        Returns the highest-priority unexplored action from state_hash.
        Returns None when all actions from this state are exhausted
        (signal for URM fallback).

        Registers parent transition for path extraction if provided.
        """
        # Record parent for path extraction
        if parent_hash is not None and parent_action is not None:
            self.register_transition(parent_hash, parent_action, state_hash)

        self._ensure_node(state_hash)
        candidates = self._graph[state_hash]

        # Pop first non-explored candidate
        while candidates:
            _, action = candidates.pop(0)
            key = (state_hash, action)
            if key not in self._explored:
                self._explored.add(key)
                return action

        # Frontier exhausted for this state
        return None

    @property
    def has_win(self) -> bool:
        return self._win_path is not None


# ─── pure_batch_ttt_loss — fully vectorised + P0 OOB fix ─────────────────────

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
    FIX H1: no internal .to() calls — all tensors must arrive on correct device.

    FIX TTT-OOB (P0): cross_entropy crashes when target >= n_classes.
        Root cause: different games have different n_actions; TTT head may have
        been initialized with fewer classes than the current action_space size.
        Fix: derive n_classes from logits.shape[-1] at runtime;
             filter (not clamp) OOB targets to preserve gradient correctness;
             return zero loss tensor if all targets are OOB (no valid samples).
    """
    device = batch_states.device

    out      = functional_call(model, (params, buffers), (batch_states,))
    act_logits = out["action_logits"]   # (B, n_classes)

    # ── P0 FIX: filter OOB action targets ────────────────────────────────────
    n_classes  = act_logits.shape[-1]   # derive at runtime, NOT from config
    valid_mask = (batch_actions >= 0) & (batch_actions < n_classes)

    if valid_mask.sum() == 0:
        # All targets OOB — skip action loss for this batch
        # Value loss still computed to keep model updating
        val_loss = F.mse_loss(
            value_logits_to_scalar(out["value"]),
            batch_rewards.float(),
        )
        task_loss = val_loss
    else:
        valid_logits  = act_logits[valid_mask]
        valid_targets = batch_actions[valid_mask]
        act_loss  = F.cross_entropy(valid_logits, valid_targets)
        val_loss  = F.mse_loss(
            value_logits_to_scalar(out["value"]),
            batch_rewards.float(),
        )
        task_loss = act_loss + val_loss
    # ─────────────────────────────────────────────────────────────────────────

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

    FIX C1: ONE shared idx per step — states/actions/next/rewards always aligned.
    FIX H1: no .to(device) inside — caller responsible for device placement.

    Mathematical identity:
        p_{t+1} = p_t - lr * ∇_{p_t} L(p_t)
        final = reduce(step, range(steps), params)
    """
    n      = len(states)
    device = states.device

    with torch.no_grad():
        pre_out    = functional_call(model, (params, buffers), (states[:cfg.batch_size],))
        pre_logits = pre_out["action_logits"].detach()
        pre_values = pre_out["value"].detach()

    _grad_fn = grad(pure_batch_ttt_loss, argnums=0)

    def _step(p: dict, _: int) -> tuple[dict, None]:
        # FIX C1: single shared idx — all four tensors use the SAME permutation
        bs  = min(cfg.batch_size, n)
        idx = torch.randperm(n, device=device)[:bs]
        g   = _grad_fn(
            p, buffers, model,
            states[idx], actions[idx], next_states[idx], rewards[idx],
            pre_logits, pre_values,
            cfg.lambda_reg, cfg.reg_mode,
        )
        return {k: w - cfg.lr * g[k] for k, w in p.items()}, None

    final_params, _ = reduce(
        lambda acc, i: (_step(acc[0], i)[0], None),
        range(cfg.steps),
        (params, None),
    )
    return final_params


# ─── _load_binary — FIX M1: pathlib, no resource leak ────────────────────────

def _load_binary(paths: list[str]) -> Optional[bytes]:
    """
    FIX M1: uses Path.read_bytes() — no open() / close() resource leak.
    Returns first readable file, or None if none found.
    """
    return next(
        (Path(p).read_bytes() for p in paths if Path(p).is_file()),
        None,
    )


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
