"""
submission_agent.py — SOTA ARC-AGI-3 Submission Agent
Refactor v12: algebraic types, pure functional forward, device discipline,
eager-only (no torch.compile), no TTT in submission path.

FIXES (v12):
  C3: EpisodeBuffer.__post_init__ uses self.max_len for deque maxlen
  H3: choose_action extracts ndarray from obs dict when needed
  H4: kaggle_main passes encode_grid_numpy(obs)[0] — buffer stores tokens not raw grids
  M2: _DummyBackbone is a minimal stub with no URM allocation
  M3: conf logging now uses last result.confidence (handled in kaggle_main)

Architecture:
  URMWMA           := world model adapter wrapping URM backbone
  VERICODINGAgent  := stateful agent (episode buffer + action selection)
  ActionResult     := algebraic return type from choose_action
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
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "external"))

from urm.models.urm.urm import URM, URMConfig, URMCarry
from urm.models.losses import value_logits_to_scalar
from wasm_bridge import encode_grid_numpy, load_adapter


# ─── Algebraic result types ───────────────────────────────────────────────────

class ActionResult(NamedTuple):
    action:       int
    value:        float
    confidence:   float        # max softmax prob of action head
    hidden_norm:  float        # ||hidden||_2 / sqrt(T*H) — diagnostic


@dataclass(frozen=True)
class AgentConfig:
    n_actions:   int   = 7
    hidden_size: int   = 512
    max_ep_len:  int   = 200
    device:      str   = "cpu"
    fp16:        bool  = False


# ─── DummyBackbone — minimal stub until urm_checkpoint.pt is loaded ──────────
# FIX M2: no full URM allocation here — stub raises on forward to catch misuse early

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
        dev_name = "CUDA" if any(p.is_cuda for p in self.parameters()) else "CPU"
        print(f"[URMWMA] Eager {dev_name}")

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
        self._set_eager()
        print(f"[load_backbone] model on {self._device}")

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


# ─── VERICODINGAgent — main submission agent ─────────────────────────────────

class VERICODINGAgent:
    """
    Stateful ARC-AGI-3 agent.

    Interface contract:
      on_game_start() → resets carry + buffer
      choose_action(frames, prev_action) → ActionResult
      on_step(obs, action, reward) → None  (encodes and records to buffer)

    Submission invariant:
      NO TTT calls here — sidecar training only.
      NO .to(device) after construction — load_backbone handles device placement.
    """

    def __init__(self, cfg: Optional[AgentConfig] = None) -> None:
        self.cfg = cfg or AgentConfig()
        self.wm  = URMWMA(self.cfg)
        self.buf = EpisodeBuffer(max_len=self.cfg.max_ep_len)
        self.wm.eval()

    def on_game_start(self) -> None:
        self.wm.reset_carry()
        self.buf.clear()

    def on_step(self, obs, action: int, reward: float) -> None:
        """
        FIX H4: obs is raw grid from env.step() — encode here before storing.
        Buffer always stores encoded token vectors, not raw grids.
        """
        grid = _extract_grid(obs)
        tokens, _ = encode_grid_numpy(grid)
        self.buf.push(tokens, action, reward)

    @torch.no_grad()
    def choose_action(
        self,
        frames: list,
        prev_action: Optional[int],
    ) -> ActionResult:
        """
        FIX H3: frames extracted safely via _extract_grid.
        """
        device = self.wm._device
        tokens_list  = [encode_grid_numpy(_extract_grid(f))[0] for f in frames]
        state_tokens = torch.from_numpy(np.stack(tokens_list)).long().to(device)

        out = self.wm(state_tokens, action=prev_action)
        action_logits = out["action_logits"]
        probs         = F.softmax(action_logits, dim=-1)
        action_idx    = action_logits[0].argmax().item()
        confidence    = probs[0, action_idx].item()
        value_scalar  = value_logits_to_scalar(out["value"])[0].item()

        return ActionResult(
            action=int(action_idx),
            value=float(value_scalar),
            confidence=float(confidence),
            hidden_norm=0.0,
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
