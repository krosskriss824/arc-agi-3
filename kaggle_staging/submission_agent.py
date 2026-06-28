"""
submission_agent.py — SOTA ARC-AGI-3 Submission Agent
Refactor v12:
  - P2: GPU guard in build_agent + load_backbone (fp16 support)
  - P0: _DummyCarry-safe encode_grid_numpy via wasm_bridge
  - Algebraic types, pure functional forward, device discipline,
    eager-only (no torch.compile), no TTT in submission path.

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
import os
import sys

import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "external"))

try:
    from urm.models.urm.urm import URM, URMConfig, URMCarry
    from urm.models.losses import value_logits_to_scalar
    _HAS_URM = True
except ImportError as _e:
    print(f"[URMWMA] Cannot import URM: {_e}")
    _HAS_URM = False
    URMCarry = None

from wasm_bridge import encode_grid_numpy, load_adapter


# ─── Algebraic result types ───────────────────────────────────────────────────

class ActionResult(NamedTuple):
    action:       int
    value:        float
    confidence:   float
    hidden_norm:  float


@dataclass(frozen=True)
class AgentConfig:
    n_actions:   int   = 7
    hidden_size: int   = 512
    max_ep_len:  int   = 200
    device:      str   = "cpu"
    fp16:        bool  = False


# ─── DummyBackbone ────────────────────────────────────────────────────────────

class _DummyBackbone(nn.Module):
    """
    Zero-weight stand-in backbone.
    Used when URM import fails or before checkpoint is loaded.
    """
    def __init__(self, hidden_size: int) -> None:
        super().__init__()
        self.hidden_size = hidden_size
        if _HAS_URM:
            cfg = URMConfig(hidden_size=hidden_size)
            self._urm = URM(cfg)
        else:
            # Minimal stub: linear map as placeholder
            self._urm = nn.Linear(hidden_size, hidden_size)

    def initial_carry(self, batch: dict):
        if _HAS_URM:
            return self._urm.initial_carry(batch)
        return None

    def forward(self, carry, batch: dict) -> tuple:
        if _HAS_URM:
            return self._urm(carry, batch)
        # stub: return zeros
        B = batch["inputs"].size(0)
        T = batch["inputs"].size(1)
        h = self.hidden_size
        dev = batch["inputs"].device
        hidden = torch.zeros(B, T, h, device=dev)
        logits = torch.zeros(B, T, 12, device=dev)
        return None, {"logits": logits, "hidden": hidden,
                      "current_hidden": hidden}


# ─── URMWMA — world model adapter ────────────────────────────────────────────

class URMWMA(nn.Module):
    """
    URM World Model Adapter.
    v12: fp16 support, GPU guard, graceful URM-missing fallback.
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
        try:
            dev_name = next(self.parameters()).device
        except StopIteration:
            dev_name = "cpu"
        print(f"[URMWMA] Eager {dev_name}")

    @property
    def _device(self) -> torch.device:
        try:
            return next(self.parameters()).device
        except StopIteration:
            return torch.device("cpu")

    def load_backbone(self, checkpoint_path: str, device: str = "cpu") -> None:
        """
        Load urm_checkpoint.pt into backbone.
        P2: auto-upgrade device to CUDA if available and device=="cpu" requested.
        Moves ALL parameters atomically after load.
        """
        # P2: GPU guard
        if device == "cpu" and torch.cuda.is_available():
            device = "cuda"
            print(f"[load_backbone] P2: upgrading to CUDA")

        state = torch.load(checkpoint_path, map_location="cpu", weights_only=False)
        cleaned = {
            k.replace("_orig_mod.", "").replace("model.", "", 1): v
            for k, v in state.items()
        }
        if _HAS_URM:
            missing, unexpected = self._backbone._urm.load_state_dict(cleaned, strict=False)
            print(f"[load_backbone] missing={len(missing)}, unexpected={len(unexpected)}")
        self.to(device)
        # P2: FP16 on GPU
        if self.cfg.fp16 and device != "cpu":
            self.half()
            print(f"[load_backbone] FP16 enabled")
        self._set_eager()
        print(f"[load_backbone] model on {self._device}")

    def encode_state(self, grid: np.ndarray, action: int = 0) -> torch.Tensor:
        """Encode grid to token tensor on model device."""
        tokens, _ = encode_grid_numpy(grid, action)
        return torch.from_numpy(tokens).long().unsqueeze(0).to(self._device)

    def reset_carry(self) -> None:
        self._carry = None

    def _forward_pure(
        self,
        state_tokens: torch.Tensor,
        act_emb: torch.Tensor,
        device: torch.device,
    ) -> tuple:
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
        # handle both URMCarry (has current_hidden) and stub (has hidden)
        _h_key = "current_hidden" if "current_hidden" in outputs else "hidden"
        hidden = outputs.get(_h_key, outputs["logits"].mean(-1, keepdim=True))
        if hasattr(new_carry, "current_hidden"):
            hidden = new_carry.current_hidden

        hidden = hidden.to(act_emb.dtype)
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

        # cast to model dtype (fp16 compat)
        if self.cfg.fp16 and state_tokens.is_cuda:
            state_tokens = state_tokens.to(dtype=torch.float16)

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
    max_len: int = 200
    _states:  collections.deque = field(default_factory=lambda: collections.deque(maxlen=200))
    _actions: collections.deque = field(default_factory=lambda: collections.deque(maxlen=200))
    _rewards: collections.deque = field(default_factory=lambda: collections.deque(maxlen=200))

    def push(self, state: np.ndarray, action: int, reward: float) -> None:
        self._states.append(state)
        self._actions.append(action)
        self._rewards.append(reward)

    def __len__(self) -> int:
        return len(self._states)

    def as_tensors(self, device: torch.device) -> tuple:
        states  = torch.from_numpy(np.stack(self._states)).long().to(device)
        actions = torch.tensor(list(self._actions), dtype=torch.long, device=device)
        rewards = torch.tensor(list(self._rewards), dtype=torch.float32, device=device)
        return states, actions, rewards

    def clear(self) -> None:
        self._states.clear()
        self._actions.clear()
        self._rewards.clear()


# ─── VERICODINGAgent ──────────────────────────────────────────────────────────

class VERICODINGAgent:
    """
    Stateful ARC-AGI-3 agent. v12: accepts both (cfg) and ("__init__") call.
    Submission invariant: NO TTT here — sidecar only.
    """

    def __init__(self, cfg=None) -> None:
        # Compat: old notebooks pass "__init__" string as first arg
        if isinstance(cfg, str) or cfg is None:
            cfg = AgentConfig()
        self.cfg = cfg
        self.wm  = URMWMA(self.cfg)
        self.buf = EpisodeBuffer(max_len=self.cfg.max_ep_len)
        # compat shims for old-style attribute access
        self.world_model = self.wm
        self._last_action_data = None
        self._game_tags = []
        self._step_modulus = 1
        self.wm.eval()

    def set_game_tags(self, tags) -> None:
        self._game_tags = list(tags) if tags else []

    def set_step_modulus(self, m: int) -> None:
        self._step_modulus = max(1, int(m))

    def on_game_start(self) -> None:
        self.wm.reset_carry()
        self.buf.clear()
        self._last_action_data = None

    def on_step(self, state_tokens, action: int, reward: float) -> None:
        if isinstance(state_tokens, np.ndarray):
            self.buf.push(state_tokens, action, reward)

    @torch.no_grad()
    def choose_action(
        self,
        frames: list,
        prev_action,
    ):
        """
        Select action from current observation frames.
        Handles both raw grids and frame objects (with .frame attribute).
        """
        device = self.wm._device

        tokens_list = []
        for f in frames:
            # handle frame objects
            grid = getattr(f, "frame", f)
            if isinstance(grid, (list, np.ndarray)):
                grid = np.asarray(grid, dtype=np.int32)
                if grid.ndim == 3:
                    grid = grid[0]
            else:
                grid = np.zeros((1, 1), dtype=np.int32)
            tok, _ = encode_grid_numpy(grid)
            tokens_list.append(tok)

        state_tokens = torch.from_numpy(
            np.stack(tokens_list)
        ).long().to(device)

        # resolve action int from enum or int
        act_int = None
        if prev_action is not None:
            act_int = (
                prev_action.value[0]
                if isinstance(getattr(prev_action, "value", None), tuple)
                else getattr(prev_action, "value", int(prev_action))
            )

        out = self.wm(state_tokens, action=act_int)

        action_logits = out["action_logits"]
        probs         = F.softmax(action_logits.float(), dim=-1)
        action_idx    = action_logits[0].argmax().item()
        confidence    = probs[0, action_idx].item()

        val_out = out["value"].float()
        if _HAS_URM:
            try:
                value_scalar = value_logits_to_scalar(val_out)[0].item()
            except Exception:
                value_scalar = val_out.mean().item()
        else:
            value_scalar = val_out.mean().item()

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
    fp16:            bool  = False,
) -> VERICODINGAgent:
    """
    Factory: constructs and optionally loads backbone + adapter.
    P2: auto-upgrade to CUDA if available.
    """
    # P2: GPU guard
    if device == "cpu" and torch.cuda.is_available():
        device = "cuda"
        fp16   = True
        print(f"[build_agent] P2: auto-upgraded to CUDA+FP16")

    cfg   = AgentConfig(n_actions=n_actions, hidden_size=hidden_size,
                        device=device, fp16=fp16)
    agent = VERICODINGAgent(cfg)

    if checkpoint_path is not None and os.path.exists(checkpoint_path):
        agent.wm.load_backbone(checkpoint_path, device=device)
    else:
        print(f"[build_agent] no checkpoint — using DummyBackbone")

    if adapter_path is not None and os.path.exists(adapter_path):
        load_adapter(agent.wm, adapter_path)

    agent.wm.eval()
    return agent
