"""
submission_agent.py — SOTA ARC-AGI-3 Submission Agent
Refactor v19: FrameGraphExplorer + TTT-OOB fix + volatile_mask hash

FIXES (v19):
  TTT-OOB (P0): pure_batch_ttt_loss filters OOB action targets (wasm_bridge)
  GRAPH:  choose_action → FrameGraphExplorer FIRST, URM fallback when frontier empty
  HASH:   on_step records frame history; volatile_mask passed to encode_grid_numpy
  TAGS:   set_game_tags() configures priority tiers before first step

FIXES (v13, retained):
  X1: sys.path.insert(0, dirname(__file__)) — wasm_bridge resolves correctly
  X2: _set_eager() device check deferred — correct device after load_backbone
  X5: parallel_urm_inference (vmap) removed — mutable _carry incompatible

Architecture:
  URMWMA           := world model adapter wrapping URM backbone
  VERICODINGAgent  := stateful agent (episode buffer + graph explorer + action selection)
  ActionResult     := algebraic return type from choose_action

Flow (per step):
  env.step(action)
  agent.on_step(obs, action, reward)
      → records to EpisodeBuffer
      → updates frame_history for volatile_mask
      → registers transition in FrameGraphExplorer
  action = agent.choose_action(frames, prev_action)
      → compute state_hash via WASM canonical_hash
      → FrameGraphExplorer.choose_action(state_hash) → action or None
      → if None: URM forward pass (fallback)
"""
from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional, NamedTuple
import collections
import math

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

import sys, os
# FIX X1: kaggle_staging/ first in path → wasm_bridge resolves to correct module
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(1, os.path.join(os.path.dirname(__file__), "..", "external"))

from urm.models.urm.urm import URM, URMConfig, URMCarry
from urm.models.losses import value_logits_to_scalar
from wasm_bridge import (
    encode_grid_numpy,
    compute_volatile_mask,
    load_adapter,
    FrameGraphExplorer,
)


# ─── Algebraic result types ───────────────────────────────────────────────────

class ActionResult(NamedTuple):
    action:       int
    value:        float
    confidence:   float        # max softmax prob of action head
    hidden_norm:  float        # ||hidden||_2 / sqrt(T*H) — diagnostic
    source:       str = "urm"  # "graph" | "urm" — which path produced this action


@dataclass(frozen=True)
class AgentConfig:
    n_actions:   int   = 7
    hidden_size: int   = 512
    max_ep_len:  int   = 200
    device:      str   = "cpu"
    fp16:        bool  = False
    # Volatile mask: number of frames to track for hash stability
    volatile_history_len: int = 10


# ─── DummyBackbone — minimal stub until urm_checkpoint.pt is loaded ──────────

class _DummyBackbone(nn.Module):
    """
    Zero-parameter stub. Raises informative error if forward is called
    before load_backbone. Avoids allocating full URM weight tensors.
    """
    def __init__(self, hidden_size: int) -> None:
        super().__init__()
        self.hidden_size = hidden_size

    def initial_carry(self, batch: dict):
        raise RuntimeError(
            "[_DummyBackbone] forward called before load_backbone. "
            "Call build_agent with a valid checkpoint_path."
        )

    def forward(self, carry, batch: dict):
        raise RuntimeError(
            "[_DummyBackbone] forward called before load_backbone. "
            "Call build_agent with a valid checkpoint_path."
        )


# ─── URMWMA — world model adapter ────────────────────────────────────────────

class URMWMA(nn.Module):
    """
    URM World Model Adapter.
    Wraps URM backbone with action embedding, action head, value head.

    Invariants:
      - compile_forward sets eager-only (no torch.compile)
      - action_emb size = n_actions + 1 (padding_idx=0)
      - forward derives device from state_tokens.device — zero external .to() needed
      - load_backbone moves ALL parameters atomically; caller must not .to() externally
    """

    def __init__(self, cfg: AgentConfig = AgentConfig()) -> None:
        super().__init__()
        self.cfg        = cfg
        self._backbone  = _DummyBackbone(cfg.hidden_size)
        self.action_emb = nn.Embedding(cfg.n_actions + 1, cfg.hidden_size, padding_idx=0)
        self.action_head = nn.Linear(cfg.hidden_size, cfg.n_actions)
        self.value_head  = nn.Linear(cfg.hidden_size, 5)
        self._init_heads()
        self._set_eager()
        self._carry = None

    def _init_heads(self) -> None:
        nn.init.orthogonal_(self.action_head.weight, gain=0.01)
        nn.init.zeros_(self.action_head.bias)
        nn.init.orthogonal_(self.value_head.weight, gain=0.01)
        nn.init.zeros_(self.value_head.bias)

    def _set_eager(self) -> None:
        self._forward_pure_compiled = self._forward_pure
        n_params = sum(p.numel() for p in self.parameters())
        print(f"[URMWMA] Eager mode | params={n_params:,}")

    @property
    def _device(self) -> torch.device:
        return next(self.parameters()).device

    def load_backbone(self, checkpoint_path: str, device: str = "cpu") -> None:
        from urm.models.urm.urm import URM, URMConfig
        state = torch.load(checkpoint_path, map_location="cpu", weights_only=False)
        cleaned = {
            k.replace("_orig_mod.", "").replace("model.", "", 1): v
            for k, v in state.items()
        }
        cfg = URMConfig(hidden_size=self.cfg.hidden_size)
        backbone = URM(cfg)
        missing, unexpected = backbone.load_state_dict(cleaned, strict=False)
        print(f"[load_backbone] missing={len(missing)}, unexpected={len(unexpected)}")
        self._backbone = backbone
        self.to(device)
        dev_name = "CUDA" if next(self.parameters()).is_cuda else "CPU"
        print(f"[load_backbone] model on {self._device} ({dev_name})")

    def reset_carry(self) -> None:
        self._carry = None

    def _forward_pure(
        self,
        state_tokens: torch.Tensor,
        act_emb: torch.Tensor,
        device: torch.device,
    ) -> tuple[torch.Tensor, torch.Tensor, torch.Tensor, torch.Tensor]:
        clamped = state_tokens.clamp(0, 11)
        B       = clamped.size(0)
        batch   = {
            "inputs":             clamped,
            "puzzle_identifiers": torch.zeros(B, dtype=torch.long, device=device),
            "labels":             clamped,
        }
        carry   = self._carry if self._carry is not None \
                  else self._backbone.initial_carry(batch)
        new_carry, outputs = self._backbone(carry, batch)
        self._carry = new_carry

        logits = outputs["logits"]
        hidden = new_carry.current_hidden.to(act_emb.dtype)
        pooled = hidden.mean(dim=1) + act_emb
        action_logits = self.action_head(pooled)
        value         = self.value_head(pooled)
        return action_logits, value, logits, hidden

    def forward(
        self,
        state_tokens: torch.Tensor,
        action: Optional[int] = None,
        return_all: bool = False,
    ) -> dict:
        device = state_tokens.device
        B      = state_tokens.size(0)
        act_t   = (
            torch.tensor([action], dtype=torch.long, device=device)
            if action is not None
            else torch.zeros(B, dtype=torch.long, device=device)
        )
        act_emb = self.action_emb(act_t)
        action_logits, value, logits, hidden = self._forward_pure_compiled(
            state_tokens, act_emb, device
        )
        return {
            "action_logits": action_logits,
            "value":         value,
            "logits":        logits,
            "hidden":        hidden if return_all else None,
        }


# ─── Episode buffer ───────────────────────────────────────────────────────────

@dataclass
class EpisodeBuffer:
    """
    Rolling buffer of (state_tokens, action, reward) for one episode.
    Bounded by max_len.
    FIX C3: __post_init__ creates deques using self.max_len, not hardcoded 200.
    """
    max_len: int = 200
    _states:  collections.deque = field(init=False)
    _actions: collections.deque = field(init=False)
    _rewards: collections.deque = field(init=False)

    def __post_init__(self) -> None:
        self._states  = collections.deque(maxlen=self.max_len)
        self._actions = collections.deque(maxlen=self.max_len)
        self._rewards = collections.deque(maxlen=self.max_len)

    def push(self, state: np.ndarray, action: int, reward: float) -> None:
        self._states.append(state)
        self._actions.append(action)
        self._rewards.append(reward)

    def __len__(self) -> int:
        return len(self._states)

    def as_tensors(self, device: torch.device) -> tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
        states  = torch.from_numpy(np.stack(self._states)).long().to(device)
        actions = torch.tensor(list(self._actions), dtype=torch.long, device=device)
        rewards = torch.tensor(list(self._rewards), dtype=torch.float32, device=device)
        return states, actions, rewards

    def clear(self) -> None:
        self._states.clear()
        self._actions.clear()
        self._rewards.clear()


# ─── Grid extraction helper — FIX H3 ─────────────────────────────────────────

def _extract_grid(obs) -> np.ndarray:
    """
    Safely extract np.ndarray from obs, which may be:
      - np.ndarray directly
      - dict with key 'grid', 'observation', or 'input'
    Raises TypeError with informative message if unknown format.
    """
    if isinstance(obs, np.ndarray):
        return obs
    if isinstance(obs, dict):
        for key in ("grid", "observation", "input"):
            if key in obs:
                return np.asarray(obs[key])
        raise TypeError(f"[_extract_grid] obs dict has no known grid key. Keys: {list(obs.keys())}")
    raise TypeError(f"[_extract_grid] unsupported obs type: {type(obs)}")


# ─── Simple state hash (Python fallback when WASM unavailable) ────────────────

def _python_state_hash(grid: np.ndarray) -> int:
    """
    Fallback hash when WASM canonical_hash is unavailable.
    Uses raw grid bytes — NOT D4-canonical.
    Only used if RhaeEngine fails to init.
    """
    return int(hash(grid.tobytes()) & 0xFFFFFFFFFFFFFFFF)


# ─── VERICODINGAgent — main submission agent ─────────────────────────────────

class VERICODINGAgent:
    """
    Stateful ARC-AGI-3 agent.

    Interface contract:
      on_game_start(n_actions, tags) → resets carry + buffer + graph explorer
      choose_action(frames, prev_action) → ActionResult
      on_step(obs, action, reward, to_hash) → records to buffer + graph

    v19 additions:
      - FrameGraphExplorer: graph-based dedup exploration, priority tiers
      - volatile_mask: stable hashing across timer/counter pixels
      - source field in ActionResult: "graph" | "urm"

    Submission invariant:
      NO TTT calls here — sidecar training only.
      NO .to(device) after construction — load_backbone handles device placement.
    """

    def __init__(self, cfg: Optional[AgentConfig] = None) -> None:
        self.cfg      = cfg or AgentConfig()
        self.wm       = URMWMA(self.cfg)
        self.buf      = EpisodeBuffer(max_len=self.cfg.max_ep_len)
        self.explorer = FrameGraphExplorer()
        self.wm.eval()

        # volatile_mask tracking
        self._frame_history: collections.deque[np.ndarray] = collections.deque(
            maxlen=self.cfg.volatile_history_len
        )
        self._volatile_mask: Optional[np.ndarray] = None

        # Graph transition tracking
        self._prev_hash:   Optional[int] = None
        self._prev_action: Optional[int] = None
        self._n_actions:   int = self.cfg.n_actions

    def set_game_tags(self, tags: list[str]) -> None:
        """Call BEFORE first choose_action. Priority tiers depend on game type."""
        self.explorer.set_game_tags(tags)

    def on_game_start(
        self,
        n_actions: Optional[int] = None,
        tags: Optional[list[str]] = None,
    ) -> None:
        """Reset all per-episode state."""
        self.wm.reset_carry()
        self.buf.clear()
        self.explorer.on_episode_reset()
        self._frame_history.clear()
        self._volatile_mask = None
        self._prev_hash   = None
        self._prev_action = None
        if n_actions is not None:
            self._n_actions = n_actions
            self.explorer.update_n_actions(n_actions)
        if tags is not None:
            self.explorer.set_game_tags(tags)

    def on_step(
        self,
        obs,
        action: int,
        reward: float,
        to_hash: Optional[int] = None,
    ) -> None:
        """
        FIX H4: obs is raw grid from env.step() — encode here before storing.
        Buffer always stores encoded token vectors, not raw grids.

        v19: also updates frame_history for volatile_mask computation
             and registers graph transition.
        """
        grid = _extract_grid(obs)

        # Update frame history + recompute volatile_mask
        self._frame_history.append(grid)
        if len(self._frame_history) >= 3:
            self._volatile_mask = compute_volatile_mask(
                list(self._frame_history), threshold=0.5
            )

        tokens, _ = encode_grid_numpy(
            grid,
            action=action,
            volatile_mask=self._volatile_mask,
        )
        self.buf.push(tokens, action, reward)

        # Register graph transition if we have previous state
        if to_hash is not None and self._prev_hash is not None:
            self.explorer.register_transition(
                self._prev_hash, action, to_hash
            )
        self._prev_action = action

    def update_action_space(self, n_actions: int) -> None:
        """Call after every env.step() with len(env.action_space)."""
        self._n_actions = n_actions
        self.explorer.update_n_actions(n_actions)

    @torch.no_grad()
    def choose_action(
        self,
        frames: list,
        prev_action: Optional[int],
        current_hash: Optional[int] = None,
    ) -> ActionResult:
        """
        v19: FrameGraphExplorer FIRST, URM fallback when frontier exhausted.

        Graph path:
            state_hash = current_hash (WASM D4-canonical) or python fallback
            action = explorer.choose_action(state_hash)
            → returns ActionResult(source="graph")

        URM path (fallback when explorer returns None):
            standard forward pass through URMWMA
            → returns ActionResult(source="urm")
        """
        device = self.wm._device

        # ── Compute state hash ──────────────────────────────────────────────
        if current_hash is None and frames:
            try:
                grid = _extract_grid(frames[-1])
                current_hash = _python_state_hash(grid)
            except Exception:
                current_hash = 0

        # ── Graph explorer (PRIMARY) ────────────────────────────────────────
        if current_hash is not None:
            graph_action = self.explorer.choose_action(
                current_hash,
                parent_hash=self._prev_hash,
                parent_action=self._prev_action,
            )
            if graph_action is not None:
                self._prev_hash = current_hash
                self._prev_action = graph_action
                return ActionResult(
                    action=int(graph_action),
                    value=0.0,
                    confidence=1.0,
                    hidden_norm=0.0,
                    source="graph",
                )

        # ── URM fallback (when frontier empty) ─────────────────────────────
        tokens_list  = [encode_grid_numpy(_extract_grid(f))[0] for f in frames]
        state_tokens = torch.from_numpy(np.stack(tokens_list)).long().to(device)

        out = self.wm(state_tokens, action=prev_action)
        action_logits = out["action_logits"]

        # Clamp to valid action space
        valid_logits = action_logits[:, :self._n_actions]
        probs         = F.softmax(valid_logits, dim=-1)
        action_idx    = valid_logits[0].argmax().item()
        confidence    = probs[0, action_idx].item()
        value_scalar  = value_logits_to_scalar(out["value"])[0].item()

        self._prev_hash   = current_hash
        self._prev_action = int(action_idx)

        return ActionResult(
            action=int(action_idx),
            value=float(value_scalar),
            confidence=float(confidence),
            hidden_norm=0.0,
            source="urm",
        )


# ─── Checkpoint utilities ────────────────────────────────────────────────────

def build_agent(
    checkpoint_path: Optional[str] = None,
    adapter_path:    Optional[str] = None,
    n_actions:       int   = 7,
    hidden_size:     int   = 512,
    device:          str   = "cpu",
) -> VERICODINGAgent:
    """
    Factory: constructs and optionally loads backbone + adapter.
    """
    cfg   = AgentConfig(n_actions=n_actions, hidden_size=hidden_size, device=device)
    agent = VERICODINGAgent(cfg)

    if checkpoint_path is not None:
        agent.wm.load_backbone(checkpoint_path, device=device)

    if adapter_path is not None and os.path.exists(adapter_path):
        load_adapter(agent.wm, adapter_path)

    agent.wm.eval()
    return agent
