# VERICODING ARC-AGI-3 — Self-contained submission agent
# Generated 2026-06-20 19:56 | Refactored: zero-branch functional architecture
# Bundles: URMWMA + Curiosity + ActionAnalyzer + GoalInference + MCTS + VectorizedSearch + Agent

from __future__ import annotations
import math, os, random, sys
from collections import defaultdict
from functools import reduce
from typing import Any, Callable, Optional
import numpy as np
import sys
try:
    import torch
    from torch import nn
    HAS_TORCH = True
except ImportError:
    HAS_TORCH = False
    nn = object

# ── P100/sm_60 CUDA guard: torch.cuda.is_available() returns True on P100
# but PyTorch ≥2.0 only supports sm_70+.  Always use this instead. ──
def _cuda_safe() -> bool:
    if not HAS_TORCH or not torch.cuda.is_available(): return False
    try:
        cap = torch.cuda.get_device_capability(0)
        return cap[0] >= 7
    except Exception:
        return False

# ════════════════════════════════════════════════════════
# 0. Pure Functional Pipeline — Delegated to wasm_bridge.py
# ════════════════════════════════════════════════════════
from wasm_bridge import (
    pipe, action_prune, canonical_hash, _HAS_WASM,
    py_action_prune_mask, _ensure_zobrist, _ZOBRIST_TABLE,
    _ZOBRIST_ROWS, _ZOBRIST_COLS, _ZOBRIST_COLORS,
    py_zobrist_canonical_hash, zobrist_canonical_hash,
    D4_COEFFS, _ACTION_MASK_FULL,
    functional_ttt_train, pure_batch_ttt_loss,
    _choose_depth_pure,
    _extract_head_params, _extract_all_params, _extract_buffers,
    pure_urm_forward, parallel_urm_inference,
    value_logits_to_scalar, BIN_CENTERS,
    get_rhae, _HAS_RHAE_WASM,
    FrameGraphExplorer, is_win_state, is_game_over,
)
from frame_processor import FrameProcessor
# RHAE Stage-1: MoonBit D4-canonical hash + policy gate singleton
_rhae = get_rhae()

# URM paths — deterministic ordering via filter (no set hashing)
_HERE = os.path.dirname(os.path.abspath(__file__))
_ARC_DIR_CANDIDATES = [
    os.path.abspath(os.path.join(_HERE, "..", "arc")),
    _HERE,
]
_ARC_DIR = next((d for d in _ARC_DIR_CANDIDATES if os.path.isdir(os.path.join(d, "external", "urm"))), _HERE)
_URM_DIR = os.path.join(_ARC_DIR, "external", "urm")
pipe(
    [_ARC_DIR, _URM_DIR],
    lambda paths: [p for p in paths if p not in sys.path][::-1],
    lambda valid: list(map(lambda p: sys.path.insert(0, p), valid)),
)


# ── Grid helpers (algebraic, zero branches) ──

def _pad_64x64(grid: np.ndarray) -> np.ndarray:
    """Pad grid to 64×64 virtual square — algebraic: allocate zeros, copy slice."""
    out = np.zeros((64, 64), dtype=grid.dtype)
    h, w = grid.shape
    out[:h, :w] = grid
    return out


IGNORE_LABEL_ID = -100

def _encode_grid_numpy(grid: np.ndarray, action: int,
                       n_actions: int = 7) -> tuple[np.ndarray, int]:
    """Encode grid + action → flat token array, padded to 4099.
    
    Returns: (tokens, valid_len) where valid_len = h*w + 3 (grid cells + meta).
    Tokens are padded to 4099 with 0 (PAD). 
    Use IGNORE_LABEL_ID=-100 in labels for positions >= valid_len to mask loss.
    """
    _MAX_TOKENS = 4099  # 64×64 + 3 meta
    _np = __import__("numpy")
    assert grid.ndim == 2, f"Expected 2D grid, got {grid.shape}"
    h, w = grid.shape
    assert h <= 64 and w <= 64, f"Grid too large: {h}×{w}"
    
    grid_vals = grid.ravel().astype(_np.int32)
    meta = _np.array([action, n_actions, 0], dtype=_np.int32)
    result = _np.concatenate([grid_vals, meta])
    _valid = len(result)  # h*w + 3
    
    # Pad to seq_len=4099 with zeros (PAD token)
    if len(result) < _MAX_TOKENS:
        result = _np.pad(result, (0, _MAX_TOKENS - len(result)), 'constant')
    return (result[: _MAX_TOKENS], _valid)




# ── Value helpers (5-bin discretized value head) ──

BIN_CENTERS = [-1.0, -0.25, 0.5, 1.25, 2.0]

@torch.no_grad()
def value_entropy(dist_logits: torch.Tensor) -> torch.Tensor:
    """Shannon entropy from value distribution logits — zero branching.
    Dict dispatch on last-dim size replaces 'if' for (B,5) vs (B,1) handling.
    """
    probs = torch.softmax(dist_logits, dim=-1)
    out = {
        True: lambda: torch.sigmoid(-torch.abs(dist_logits).squeeze(-1) + 1.0),
        False: lambda: -(probs * torch.log(probs + 1e-10)).sum(-1),
    }[dist_logits.shape[-1] != 5]()
    return out

def value_logits_to_scalar(logits: torch.Tensor) -> torch.Tensor:
    """Convert 5-bin value logits to scalar via softmax-weighted avg of bin centers."""
    probs = torch.softmax(logits, dim=-1)
    centers = torch.tensor(BIN_CENTERS, device=logits.device)
    return (probs * centers).sum(dim=-1)


# ── URM World Model Adapter ──

class _DummyCarry:
    """Minimal carry for dummy backbone — zero Python branches in compiled path."""
    __slots__ = ('current_hidden',)

class _DummyBackbone(nn.Module):
    """Identity backbone — input passes through as 'logits'.
    
    Eliminates `if self._backbone is not None` branch in forward().
    Replaced by real ACTLossHead when checkpoint is loaded.
    """
    def __init__(self, hidden_size: int = 512, vocab_size: int = 16):
        super().__init__()
        self.hidden_size = hidden_size
    
    def initial_carry(self, batch: dict) -> _DummyCarry:
        inp = batch["inputs"]
        B, S = inp.reshape(-1, inp.shape[-1]).shape
        carry = _DummyCarry()
        carry.current_hidden = torch.zeros(B, S, self.hidden_size, device=inp.device)
        return carry
    
    def forward(self, return_keys, carry, batch):
        return carry, 0.0, {}, {"logits": carry.current_hidden}, False

def _carry_to_device(carry: Any, device: torch.device) -> Any:
    """Move all tensors in URMCarry-like carry to target device.
    
    Belt-and-suspenders fix: guards against URM versions where
    initial_carry() or reset_carry() creates tensors on CPU while
    batch tensors are on CUDA. Idempotent when already on device.
    """
    import dataclasses
    if not hasattr(carry, "current_hidden"):
        return carry
    return dataclasses.replace(
        carry,
        current_hidden=carry.current_hidden.to(device),
        steps=carry.steps.to(device) if hasattr(carry, "steps") else carry.steps,
        halted=carry.halted.to(device) if hasattr(carry, "halted") else carry.halted,
        current_data={
            k: v.to(device) if isinstance(v, torch.Tensor) else v
            for k, v in (carry.current_data.items() if hasattr(carry, "current_data") else {})
        },
    )

class URMWMA(nn.Module):
    """URM World Model Adapter for ARC-AGI-3.
    
    Wraps URM backbone with:
      - action_embedding: one-hot action → 512-dim
      - action_head: 512 → n_actions (policy logits)
      - value_head: 512 → 1 (state value for MCTS)
    
    Usage without checkpoint:
        adapter = URMWMA(n_actions=7)
        # Backbone weights loaded later via load_checkpoint()
    
    Usage with checkpoint:
        adapter = URMWMA.from_checkpoint("/path/to/step_X.pt", n_actions=7)
    """
    
    def __init__(self, n_actions: int = 7, hidden_size: int = 512, fp16: bool = False):
        super().__init__()
        self.n_actions = n_actions
        self.hidden_size = hidden_size
        self.fp16 = fp16
        # Always initialize a backbone (dummy) — eliminates `if self._backbone is not None`
        # Real backbone replaces this when checkpoint is loaded via load_backbone().
        self._backbone: nn.Module = _DummyBackbone(hidden_size)
        self._backbone_loaded = False
        
        # New heads for ARC-3
        self.action_emb = nn.Embedding(n_actions + 1, hidden_size, padding_idx=0)
        self.action_head = nn.Linear(hidden_size, n_actions)
        self.value_head = nn.Linear(hidden_size, 5)
        
        self._init_weights()
        self._forward_pure_compiled = self._forward_pure
        self.compile_forward()

    def compile_forward(self):
        """Use eager mode only — torch.compile CUDA graphs cause:
        1. Device tracking bugs with F.embedding (wrapper_CUDA__index_select)
        2. Accumulated CUDA graph private memory pools → OOM across games
        T4 does not support bfloat16 natively, so compile speedup is minimal."""
        if not HAS_TORCH:
            return
        self._forward_pure_compiled = self._forward_pure
        try:
            use_cuda = next(self.parameters()).is_cuda
        except StopIteration:
            use_cuda = _cuda_safe()
        # BUG-X2 fix: skip misleading device log before load_backbone
        # (params are always CPU at init — real device logged after load_backbone)
        if hasattr(self, '_backbone_loaded') and self._backbone_loaded:
            dev_name = "CUDA" if use_cuda else "CPU"
            print(f"[URMWMA] Eager {dev_name} (backbone loaded)")
    
    def to_fp16(self) -> "URMWMA":
        """Convert heads to half precision (2× speed on T4 Tensor Cores).
        
        Backbone stays FP32 — some URM ops (fused_layer_norm_cuda) lack
        FP16 kernels on sm_75 (T4). autocast handles FP32→FP16 mixing.
        """
        self.fp16 = True
        self.action_emb.half()
        self.action_head.half()
        self.value_head.half()
        # Backbone FP16 is optional (fails on sm_75 T4 for some fused ops).
        # This is init-time, not hot path — try/except is acceptable here.
        _bb = self._backbone
        if _bb is not None and self._backbone_loaded:
            try: _bb.half()
            except: pass
        self.compile_forward()
        return self
    
    def _init_weights(self):
        """Init new heads with small weights (stable at start)."""
        for m in (self.action_emb, self.action_head, self.value_head):
            if hasattr(m, "weight") and m.weight is not None:
                nn.init.normal_(m.weight, mean=0.0, std=0.02)
            if hasattr(m, "bias") and m.bias is not None:
                nn.init.zeros_(m.bias)
    
    @classmethod
    def from_checkpoint(cls, checkpoint_path: str, n_actions: int = 7,
                        device: str = "cpu") -> URMWMA:
        """Create adapter and load URM backbone weights."""
        adapter = cls(n_actions=n_actions)
        adapter.load_backbone(checkpoint_path, device)
        adapter.to(device)
        return adapter
    
    @property
    def device(self) -> torch.device:
        params = list(self.action_head.parameters())
        return params[0].device if params else torch.device("cpu")
    
    # ── Backbone loading (works without checkpoint) ──
    
    def load_backbone(self, checkpoint_path: str, device: str = "") -> bool:
        """Load URM backbone weights from checkpoint.
        
        Auto-detects CUDA if device not specified.
        Returns True if loaded successfully.
        Safe to call multiple times (replaces backbone).
        """
        if not device:
            device = "cuda" if torch.cuda.is_available() else "cpu"
        if not os.path.isfile(checkpoint_path):
            print(f"[URMWMA] Checkpoint not found: {checkpoint_path}")
            return False
        
        # URM internal imports use `from models.common import ...` (relative to external/urm/)
        _urm_root = os.path.join(os.path.dirname(__file__) or ".", "external")
        _urm_pkg  = os.path.join(_urm_root, "urm")
        for _p in (_urm_root, _urm_pkg):
            if _p not in sys.path and os.path.isdir(_p):
                sys.path.insert(0, _p)
        try:
            from external.urm.models.urm.urm import URM, URMConfig  # type: ignore[import-untyped]
            from external.urm.models.losses import ACTLossHead  # type: ignore[import-untyped]
        except ImportError as e:
            print(f"[URMWMA] Cannot import URM: {e}")
            return False
        
        try:
            # Build minimal URM for ARC-3 (seq_len=4099 = 64×64 + meta)
            model_cfg = URMConfig(
                batch_size=1,
                seq_len=4099,
                vocab_size=12,      # Checkpoint trained with 12 (0=PAD,1=EOS,2-11=colors)
                num_puzzle_identifiers=1,
                puzzle_emb_ndim=0,
                num_layers=4,
                hidden_size=self.hidden_size,
                expansion=4.0,
                num_heads=8,
                pos_encodings="rope",
                loops=4,             # Reduced from 16 (faster for ARC-3)
                L_cycles=6,
                H_cycles=2,
                forward_dtype="float32",
            )
            urm = URM(model_cfg.__dict__)
            backbone = ACTLossHead(urm, loss_type="stablemax_cross_entropy")
            
            # Load weights (strip _orig_mod. prefix from torch.compile)
            state = torch.load(checkpoint_path, map_location=device,
                               weights_only=False)
            sd = state.get("ema_state_dict",
                           state.get("model_state_dict",
                                     state.get("state_dict", state)))
            sd = {k.replace("_orig_mod.", ""): v for k, v in sd.items()}
            
            # Load only matching keys (new ARC-3 config may differ slightly)
            missing, unexpected = backbone.load_state_dict(sd, strict=False)
            if missing:
                print(f"[URMWMA] Missing keys: {len(missing)} "
                      f"(expected for new ARC-3 config)")
            if unexpected:
                print(f"[URMWMA] Unexpected keys: {len(unexpected)} "
                      f"(will be ignored)")
            
            backbone.to(device)
            backbone.eval()
            self._backbone = backbone
            self._backbone_loaded = True
            print(f"[URMWMA] Backbone loaded: {checkpoint_path}")
            self.compile_forward()
            return True
            
        except Exception as e:
            print(f"[URMWMA] Error loading backbone: {e}")
            import traceback
            traceback.print_exc()
            return False
    
    # ── State encoding ──
    
    @torch.no_grad()
    def encode_state(self, grid: np.ndarray, last_action: int = 0) -> torch.Tensor:
        """Grid (64×64) + last_action → input tokens for URM.
        
        Returns: LongTensor (1, seq_len)
        """
        tokens, _ = _encode_grid_numpy(grid, last_action, self.n_actions)  # ignore valid_len here
        return torch.from_numpy(tokens).unsqueeze(0).long().to(self.device)
    
    # ── Forward ──

    def _forward_pure(self, state_tokens, act_emb, device):
        """Pure tensor forward (zero Python control flow).
        
        Always uses self._backbone (initialized as _DummyBackbone if no checkpoint).
        Returns tuple — never dict (avoids graph breaks from dict construction).
        
        Returns: (action_logits, value, next_state_logits, hidden)
        """
        B = state_tokens.shape[0]
        # clamp to [0, vocab_size-1] = [0, 11] to avoid F.embedding OOB on ARC-3 colors (10-15)
        clamped = state_tokens.clamp(0, 11)
        batch = {
            "inputs": clamped,
            "puzzle_identifiers": torch.zeros(B, dtype=torch.long, device=device),
            "labels": clamped,
        }
        carry = self._backbone.initial_carry(batch)
        carry = _carry_to_device(carry, device)  # BUG-D3: guard URM version CPU carry
        new_carry, _, _, outputs, _ = self._backbone(
            return_keys={"logits"}, carry=carry, batch=batch,
        )
        logits = outputs["logits"]
        hidden = new_carry.current_hidden.to(act_emb.dtype)  # match FP16 if enabled
        pooled = hidden.mean(dim=1)
        pooled = pooled + act_emb
        action_logits = self.action_head(pooled)
        value = self.value_head(pooled)
        return action_logits, value, logits, hidden
    
    def forward(
        self,
        state_tokens: torch.Tensor,
        action: int | None = None,
        return_all: bool = False,
    ) -> dict[str, torch.Tensor]:
        """Forward through URM world model.
        
        Thin wrapper: handles action optionality, autocast, and dict return.
        Delegates pure tensor work to _forward_pure.
        
        Args:
            state_tokens: (B, seq_len) encoded game state
            action: optional action index (for action embedding)
            return_all: if True, return all intermediate outputs
        
        Returns:
            dict with keys:
              - "action_logits": (B, n_actions) policy prediction
              - "value": (B, 5) state value logits
              - "next_state_logits": (B, seq_len, vocab) if return_all
              - "hidden": (B, seq_len, hidden_size) if return_all
        """
        B, device = state_tokens.size(0), state_tokens.device
        
        # Action embedding — always computed (zero embedding when action=None)
        act_t = torch.tensor([action], device=device).long() if action is not None else torch.zeros(B, dtype=torch.long, device=device)
        act_emb = self.action_emb(act_t)
        
        # Pure tensor forward (zero Python control flow inside)
        _device_type = 'cuda' if device.type == 'cuda' else 'cpu'
        with torch.amp.autocast(_device_type, enabled=self.fp16 and device.type == 'cuda'):
            try:
                action_logits, value, logits, hidden = self._forward_pure_compiled(state_tokens, act_emb, device)
            except Exception:
                self._forward_pure_compiled = self._forward_pure
                action_logits, value, logits, hidden = self._forward_pure(state_tokens, act_emb, device)
        
        # Dict construction — always returns same keys regardless of backbone
        result = {"action_logits": action_logits, "value": value}
        if return_all:
            # next_state_logits is None when using dummy backbone (no checkpoint)
            result["next_state_logits"] = logits if self._backbone_loaded else None
            result["hidden"] = hidden if self._backbone_loaded else None
        return result
    
    # ── Dreaming (latent lookahead without env.step) ──

    @torch.no_grad()
    def dream_step(self, state_tokens: torch.Tensor,
                   future_action: int) -> tuple[torch.Tensor, torch.Tensor, torch.Tensor]:
        """One dreaming step: predict next state tokens + value.

        Args:
            state_tokens: (B, seq_len) encoded state
            future_action: action to dream

        Returns:
            (predicted_tokens, value_scalar, action_logits)
        """
        B = state_tokens.size(0)
        out = self.forward(state_tokens, return_all=True)
        next_logits = out.get("next_state_logits")
        if next_logits is None:
            return state_tokens, value_logits_to_scalar(out["value"]), out["action_logits"]

        pred = next_logits.argmax(dim=-1)  # (B, seq_len) greedy decode
        # Inject future action into metadata position (-3 = action slot)
        pred[:, -3] = future_action
        value = value_logits_to_scalar(out["value"])  # (B,)
        return pred, value, out["action_logits"]

    @torch.no_grad()
    def batch_dream(self, state_tokens: torch.Tensor,
                    actions: torch.Tensor) -> dict[str, torch.Tensor]:
        """Batch dreaming: URM forward + dream inference for N actions.

        Args:
            state_tokens: (B, seq_len) current states
            actions: (B,) actions to evaluate

        Returns:
            dict with dreamed values and action_logits
        """
        out = self.forward(state_tokens, return_all=True)
        values = value_logits_to_scalar(out["value"])
        return {"value": values, "action_logits": out["action_logits"]}

    # ── World model loss ──
    
    def world_model_loss(
        self,
        state_tokens: torch.Tensor,
        action_taken: torch.Tensor,
        next_state_tokens: torch.Tensor,
        reward: torch.Tensor,
        value_target: torch.Tensor | None = None,
    ) -> dict[str, torch.Tensor]:
        """Compute world model loss for ARC-3 training.
        
        ℒ = ℒ_next_state + ℒ_policy + ℒ_value + ℒ_halt
        
        Args:
            state_tokens: (B, seq_len) state at time t
            action_taken: (B,) action index at time t
            next_state_tokens: (B, seq_len) state at time t+1 (target)
            reward: (B,) reward at time t+1
            value_target: (B,) discounted return (optional, bootstrapped if None)
        
        Returns:
            dict with loss components
        """
        B = state_tokens.size(0)
        device = state_tokens.device
        
        # Forward
        out = self.forward(state_tokens, action_taken.item() if B == 1 else None,
                          return_all=True)
        
        losses = {}
        
        # 1. Next state prediction loss (cross-entropy, per token)
        if out["next_state_logits"] is not None:
            logits = out["next_state_logits"]  # (B, seq_len, vocab)
            loss_ce = nn.CrossEntropyLoss(ignore_index=-100)
            losses["next_state_loss"] = loss_ce(
                logits.view(-1, logits.size(-1)),
                next_state_tokens.view(-1),
            )
        
        # 2. Policy loss (cross-entropy on actions taken)
        n_act = out["action_logits"].size(-1)
        safe_actions = action_taken.clamp(0, n_act - 1)
        losses["policy_loss"] = nn.CrossEntropyLoss()(
            out["action_logits"], safe_actions
        )
        
        # 3. Value loss (CrossEntropy on 5 discretized bins)
        if value_target is not None:
            vt = value_target.float().clamp(-1.0, 2.0)
            bins = torch.linspace(-1.0, 2.0, 5, device=vt.device)
            bin_idx = torch.bucketize(vt, bins).clamp(0, 4).long()
            losses["value_loss"] = nn.CrossEntropyLoss()(out["value"], bin_idx)
        else:
            losses["value_loss"] = torch.tensor(0.0, device=device)
        
        # 4. Halt/continue loss (encourage longer episodes via reward)
        # Small auxiliary: predict reward sign as binary
        reward_sign = (reward > 0).float()
        # Placeholder — no separate head needed yet
        
        total = (
            losses.get("next_state_loss", torch.tensor(0.0, device=device))
            + 1.0 * losses["policy_loss"]
            + 0.5 * losses["value_loss"]
        )
        losses["total_loss"] = total
        
        return losses
    
    # ── Inference helpers ──
    
    @torch.no_grad()
    @torch.no_grad()
    def _d4_majority_logits(self, grid: np.ndarray,
                            last_action: int = 0) -> tuple[torch.Tensor, int]:
        """D4 majority vote: average action_logits across 8 grid transforms.
        
        Returns:
            (avg_logits: (1, n_actions) tensor, n_done: int)
        """
        _np = __import__("numpy")
        h, w = grid.shape
        _d4 = [
            grid,                          # identity
            _np.rot90(grid, k=1),          # rotate 90°
            _np.rot90(grid, k=2),          # rotate 180°
            _np.rot90(grid, k=3),          # rotate 270°
            _np.fliplr(grid),              # flip horizontal
            _np.flipud(grid),              # flip vertical
            grid.T,                        # transpose
            _np.fliplr(grid).T,            # anti-diagonal
        ]
        # Encode each D4 variant to tokens, stack into batch
        _enc = [self.encode_state(g, last_action) for g in _d4]
        _batch = torch.cat(_enc, dim=0)         # (8, seq_len)
        out = self.forward(_batch)               # batch forward
        # Average logits across all 8 transforms
        _logits = out["action_logits"].mean(dim=0, keepdim=True)  # (1, n_actions)
        return _logits, len(_d4)
    
    @torch.no_grad()
    def predict_action(self, grid: np.ndarray,
                       last_action: int = 0) -> tuple[int, float]:
        """D4 majority vote inference: grid → best action.
        
        Applies 8 D4 transforms (rotations + flips), batch-inferences all,
        averages action logits, picks argmax.
        
        Returns:
            (action_index, action_probability)
        """
        _logits, _n = self._d4_majority_logits(grid, last_action)
        _probs = torch.softmax(_logits, dim=-1)
        action = _probs.argmax(dim=-1).item()
        prob = _probs[0, action].item()
        return action, prob
    
    @torch.no_grad()
    def predict_value(self, grid: np.ndarray,
                      last_action: int = 0) -> float:
        """State value estimation for MCTS prior (softmax-weighted avg of 5 bins)."""
        tokens = self.encode_state(grid, last_action)
        out = self.forward(tokens)
        return value_logits_to_scalar(out["value"]).item()

# ════════════════════════════════════════════════════════
# 2. CuriosityModule — Count-based exploration
# ════════════════════════════════════════════════════════
"""Curiosity-driven exploration module for ARC-AGI-3.

Rewards agents for visiting novel states.
Uses count-based exploration bonus: beta / sqrt(N(s) + 1)
Works without any model — pure algorithmic exploration.

Usage:
  curiosity = CuriosityModule(beta=1.0)
  bonus = curiosity.get_bonus(state_value, action, levels_completed)
  curiosity.update(state_value, action, levels_completed)
"""
import math
from collections import defaultdict


class CuriosityModule:
    """Count-based curiosity for ARC-AGI-3 exploration.

    Maintains state visitation counts and computes exploration bonus.
    A state is defined by (game_state, levels_completed, last_action).
    """

    def __init__(self, beta: float = 1.0):
        self.beta = beta
        self._counts: dict[tuple, int] = defaultdict(int)
        self._total_steps = 0

    def _make_key(self, game_state: str, levels: int, action: int) -> tuple:
        """Create hashable state key from environment observation."""
        return (game_state, levels, action)

    def get_bonus(self, game_state: str, levels: int, action: int) -> float:
        """Compute exploration bonus for a (state, action) pair.

        Returns bonus in [0, beta]. Novel states get beta.
        Familiar states get beta / sqrt(N+1).
        """
        key = self._make_key(game_state, levels, action)
        count = self._counts[key]
        return self.beta / math.sqrt(count + 1.0)

    def update(self, game_state: str, levels: int, action: int) -> None:
        """Increment visitation count for this (state, action)."""
        key = self._make_key(game_state, levels, action)
        self._counts[key] += 1
        self._total_steps += 1

    def get_novelty(self, game_state: str, levels: int) -> float:
        """How novel is this state overall (any action)?"""
        total = 0.0
        counts = [self._counts.get(self._make_key(game_state, levels, a), 0) for a in range(20)]
        total = sum(self.beta / math.sqrt(c + 1.0) for c in counts)
        n_actions = sum(1 for c in counts if c > 0)
        return total / max(n_actions, 1)

    def reset(self) -> None:
        """Reset for new game episode."""
        self._counts.clear()
        self._total_steps = 0

    @property
    def total_steps(self) -> int:
        return self._total_steps

# ════════════════════════════════════════════════════════
# 3. ActionAnalyzer — Action effectiveness tracker
# ════════════════════════════════════════════════════════
"""Action analyzer for ARC-AGI-3.

Discovers which actions affect the score and builds
an action→score_change model for each game.

Works without any model — pure statistical analysis.

Usage:
  analyzer = ActionAnalyzer()
  analyzer.record(state, action, score, levels, reward)
  best_actions = analyzer.get_best_actions(top_k=3)
  action_values = analyzer.get_action_values()
"""
from collections import defaultdict
import math


class ActionAnalyzer:
    """Track action effectiveness across game episodes.

    Maintains running statistics per action:
      - mean score change
      - mean reward
      - success rate (how often action leads to WIN)
      - confidence (how many times action was tried)
    """

    def __init__(self, gamma: float = 0.9):
        self.gamma = gamma
        self._action_stats: dict[int, dict] = defaultdict(
            lambda: {
                "n": 0,
                "total_score_delta": 0.0,
                "total_reward": 0.0,
                "wins": 0,
                "game_overs": 0,
                "last_score": 0.0,
                "last_levels": 0,
            }
        )
        self._history: list[dict] = []
        self._action_space: set[int] = set()

    def record(self, action: int, game_state: str,
               score: float, levels: int, reward: float = 0.0) -> None:
        """Record action taken and its result."""
        stats = self._action_stats[action]
        stats["n"] += 1
        score_delta = score - stats["last_score"]
        level_delta = levels - stats["last_levels"]
        stats["total_score_delta"] += score_delta
        stats["total_reward"] += reward
        if game_state == "WIN":
            stats["wins"] += 1
        elif game_state == "GAME_OVER":
            stats["game_overs"] += 1
        stats["last_score"] = score
        stats["last_levels"] = levels
        self._action_space.add(action)
        self._history.append({
            "action": action,
            "state": game_state,
            "score": score,
            "levels": levels,
            "delta": score_delta,
            "reward": reward,
        })

    def get_best_actions(self, top_k: int = 3) -> list[tuple[int, float]]:
        """Return top-k actions ranked by expected score increase."""
        scored = []
        for action, stats in self._action_stats.items():
            if stats["n"] == 0:
                continue
            mean_delta = stats["total_score_delta"] / stats["n"]
            wins_rate = stats["wins"] / stats["n"]
            # Weight: 70% score improvement + 30% win rate
            score_val = mean_delta * 0.7 + wins_rate * 0.3
            # Confidence bonus (actions tried more = more reliable)
            confidence = min(1.0, stats["n"] / 10.0)
            scored.append((action, score_val * (0.5 + 0.5 * confidence)))
        scored.sort(key=lambda x: -x[1])
        return scored[:top_k]

    def get_action_values(self) -> dict[int, float]:
        """Return estimated value for every known action."""
        values = {}
        for action, stats in self._action_stats.items():
            if stats["n"] > 0:
                mean_delta = stats["total_score_delta"] / stats["n"]
                mean_reward = stats["total_reward"] / stats["n"]
                values[action] = mean_delta + mean_reward
        return values

    def get_known_actions(self) -> set[int]:
        """Return set of all action indices ever tried."""
        return self._action_space

    def get_n_actions(self) -> int:
        """Return max action index seen (informs action space)."""
        return max(self._action_space) + 1 if self._action_space else 4

    def get_action_values_sorted(self) -> list[tuple[int, float]]:
        """Return actions sorted by estimated value (descending)."""
        values = self.get_action_values()
        return sorted(values.items(), key=lambda x: -x[1])

    def reset(self) -> None:
        """Reset for new game episode."""
        self._action_stats.clear()
        self._history.clear()
        self._action_space.clear()

    def summary(self) -> str:
        """Return human-readable summary of action analysis."""
        lines = [f"Actions known: {len(self._action_space)}"]
        best = self.get_action_values_sorted()[:5]
        for action, val in best:
            stats = self._action_stats.get(action, {})
            n = stats.get("n", 0)
            wins = stats.get("wins", 0)
            lines.append(f"  Action {action}: val={val:.3f}, tried={n}, wins={wins}")
        return "\n".join(lines)

# ════════════════════════════════════════════════════════
# 4. GoalInference — Game goal detection
# ════════════════════════════════════════════════════════
"""Goal inference for ARC-AGI-3.

Detects patterns in score changes to infer game goals.
Uses simple rule learning:
  - Which state transitions lead to score increases?
  - Which action sequences are consistently rewarding?

Works without any model — pure pattern detection.

Usage:
  infer = GoalInference()
  infer.record(state, action, next_state, score, levels)
  rules = infer.get_rules()
  goal_type = infer.infer_goal_type()
"""
from collections import defaultdict


class GoalInference:
    """Infer game goals from score change patterns.

    Goal types detected:
      - win_levels: complete all levels to win (most games)
      - max_score: maximize score/actions ratio
      - survival: avoid GAME_OVER state
      - exploration: reach specific grid positions
    """

    def __init__(self):
        self._transitions: list[dict] = []
        self._score_changes: list[tuple[str, int, float]] = []
        self._win_sequences: list[list[int]] = []
        self._current_sequence: list[int] = []
        self._start_score = 0.0
        self._current_score = 0.0
        self._current_levels = 0

    def record(self, game_state: str, action: int,
               score: float, levels: int, reward: float = 0.0) -> None:
        """Record a state transition and its outcome."""
        if not self._transitions:
            self._start_score = score

        self._transitions.append({
            "state": game_state,
            "action": action,
            "score": score,
            "levels": levels,
            "reward": reward,
            "delta": score - self._current_score,
            "level_delta": levels - self._current_levels,
        })

        if score > self._current_score:
            self._score_changes.append((game_state, action, score - self._current_score))

        if levels > self._current_levels:
            # Level completed! Record this action sequence as "winning"
            self._win_sequences.append(list(self._current_sequence))
            self._current_sequence = []

        self._current_score = score
        self._current_levels = levels
        self._current_sequence.append(action)

    def infer_goal_type(self) -> str:
        """Infer what kind of game this is based on score patterns."""
        if not self._transitions:
            return "unknown"

        total_delta = self._current_score - self._start_score
        n_levels_gained = self._current_levels
        n_score_events = len(self._score_changes)

        if n_levels_gained > 0:
            return "win_levels"
        if total_delta > 0 and n_score_events > 3:
            return "max_score"
        if n_score_events == 0:
            # No score changes detected — exploration/survival game
            return "survival"
        return "max_score"

    def get_rules(self) -> list[dict]:
        """Extract actionable rules from game history.

        Returns list of rules like:
          {"condition": "state=NOT_FINISHED", "action": 2, 
           "effect": "+1 level", "confidence": 0.8}
        """
        rules = []
        if not self._transitions:
            return rules

        # Find which actions consistently precede score increases
        score_actions = defaultdict(list)
        for t in self._transitions:
            if t["delta"] > 0 or t["level_delta"] > 0:
                score_actions[t["action"]].append(t["delta"] + t["level_delta"])

        for action, deltas in score_actions.items():
            rules.append({
                "action": action,
                "effect": sum(deltas),
                "confidence": len(deltas) / max(len(self._transitions), 1),
                "type": "score_gain",
            })

        # Find which actions lead to GAME_OVER (avoid these!)
        avoid_actions = defaultdict(int)
        for t in self._transitions:
            if t["state"] == "GAME_OVER":
                avoid_actions[t["action"]] += 1
        for action, count in avoid_actions.items():
            rules.append({
                "action": action,
                "effect": -1.0,
                "confidence": count / max(len(self._transitions), 1),
                "type": "avoid",
            })

        rules.sort(key=lambda r: -r["confidence"])
        return rules[:10]

    def reset(self) -> None:
        """Reset for new game episode."""
        self._transitions.clear()
        self._score_changes.clear()
        self._win_sequences.clear()
        self._current_sequence.clear()
        self._start_score = 0.0
        self._current_score = 0.0
        self._current_levels = 0

# ════════════════════════════════════════════════════════
# 5. MCTS + URMPolicyValue
# ════════════════════════════════════════════════════════
"""MCTS — Monte Carlo Tree Search for ARC-AGI-3 agent.

Architecture:
  1. MCTSNode: tree node with state, visits, value, prior
  2. mcts_search(root_state, n_rollouts, policy_value_fn, env, n_actions):
     Selection (UCB1) → Expansion → Simulation → Backpropagation
  3. URMPolicyValue: wraps URM inference (fallback to uniform)"
"""

import math
import random
from typing import Any, Callable, Optional
from dataclasses import dataclass, field

try:
    import torch
    HAS_TORCH = True
except ImportError:
    HAS_TORCH = False


@dataclass
class MCTSNode:
    """Node in MCTS tree."""
    state: any  # Game state (could be grid, frame, etc.)
    parent: Optional["MCTSNode"] = None
    action: int = 0  # Action that led to this state
    prior: float = 0.0  # Prior probability from policy network
    visits: int = 0
    total_value: float = 0.0  # Sum of values from rollouts
    children: dict[int, "MCTSNode"] = field(default_factory=dict)
    untried_actions: list[int] = field(default_factory=list)

    @property
    def value(self) -> float:
        """Mean value of this node."""
        if self.visits == 0:
            return 0.0
        return self.total_value / self.visits

    @property
    def ucb1(self, c_puct: float = 1.5) -> float:
        """UCB1 score for selection.
        
        Higher c_puct = more exploration.
        For ARC-AGI-3, high exploration (1.5) helps discover sparse rewards.
        """
        if self.visits == 0:
            return float("inf")  # Always explore unvisited nodes first
        if self.parent is None or self.parent.visits == 0:
            return self.value + c_puct * self.prior * math.sqrt(1.0)
        exploitation = self.value
        exploration = c_puct * self.prior * math.sqrt(
            math.log(self.parent.visits + 1) / (self.visits + 1e-8)
        )
        return exploitation + exploration

    def is_fully_expanded(self) -> bool:
        """All child actions have been tried."""
        return len(self.untried_actions) == 0

    def best_child(self, c_puct: float = 1.5) -> "MCTSNode":
        """Select child with highest UCB1 score."""
        return max(self.children.values(), key=lambda c: c.ucb1(c_puct))

    def best_action(self) -> int:
        """Return action with highest visit count (robust strategy)."""
        return max(self.children.items(), key=lambda x: x[1].visits)[0]


class MCTS:
    """Monte Carlo Tree Search for ARC-AGI-3.

    Works with any policy-value function (URM when available, random otherwise).
    """

    def __init__(self, policy_value_fn: Callable,
                 n_actions: int = 5,
                 n_rollouts: int = 100,
                 max_depth: int = 50,
                 c_puct: float = 1.5,
                 reward_threshold: float = 0.1):
        self.policy_value_fn = policy_value_fn
        self.n_actions = n_actions
        self.n_rollouts = n_rollouts
        self.max_depth = max_depth
        self.c_puct = c_puct
        self.reward_threshold = reward_threshold
        self.rng = random.Random(42)
        self.tree_stats = {
            "total_nodes": 0,
            "total_simulations": 0,
            "pruned_branches": 0,
        }

    def _expand(self, node: MCTSNode) -> None:
        """Create child nodes for all untried actions."""
        for action in node.untried_actions:
            policy, _ = self.policy_value_fn(node.state)
            prior = policy[action] if action < len(policy) else 0.01
            child = MCTSNode(
                state=node.state,  # Will be updated by env.step in simulation
                parent=node,
                action=action,
                prior=prior,
            )
            node.children[action] = child
            self.tree_stats["total_nodes"] += 1
        node.untried_actions = []

    def _select(self, node: MCTSNode) -> MCTSNode:
        """Traverse tree to a leaf node using UCB1."""
        while node.is_fully_expanded() and node.children:
            node = node.best_child(self.c_puct)
        return node

    def _simulate(self, node: MCTSNode, env_fn: Callable) -> float:
        """Run a rollout from this node to terminal or max_depth.
        
        Uses policy_value_fn for action selection during rollout.
        """
        self.tree_stats["total_simulations"] += 1
        total_reward = 0.0
        cur_state = node.state
        depth = 0

        while depth < self.max_depth:
            # Get policy and value estimate
            policy, value = self.policy_value_fn(cur_state)
            if value > self.reward_threshold:
                # Early high-value detection
                total_reward += value

            # Select action (greedy from policy)
            action = self._select_action_from_policy(policy)

            # Execute action (via env_fn)
            result = env_fn(action, cur_state)
            if result is None:
                break

            next_state, reward, terminated = result
            total_reward += reward

            if terminated:
                break

            cur_state = next_state
            depth += 1

        return total_reward

    def _select_action_from_policy(self, policy: list[float]) -> int:
        """Sample action from policy distribution."""
        total = sum(policy)
        if total <= 0:
            return self.rng.randint(0, self.n_actions - 1)
        r = self.rng.random() * total
        cumulative = 0.0
        for i, p in enumerate(policy):
            cumulative += p
            if r <= cumulative:
                return min(i, self.n_actions - 1)
        return self.n_actions - 1

    def _backpropagate(self, node: MCTSNode, value: float) -> None:
        """Update visit counts and values up to root."""
        while node is not None:
            node.visits += 1
            node.total_value += value
            node = node.parent

    def search(self, root_state: any, env_fn: Callable,
               valid_actions: Optional[list[int]] = None) -> dict:
        """Run MCTS from root state.

        Args:
            root_state: initial game state
            env_fn: callable(action, state) -> (next_state, reward, terminated)
            valid_actions: optional list of valid actions

        Returns:
            dict with 'action': best action, 'probs': visit distribution,
                           'nodes': tree stats
        """
        # Reset stats
        self.tree_stats["total_nodes"] = 1
        self.tree_stats["total_simulations"] = 0

        # Initialize root
        actions = valid_actions or list(range(self.n_actions))
        policy, _ = self.policy_value_fn(root_state)
        root = MCTSNode(state=root_state, prior=1.0, untried_actions=actions)

        # Run rollouts
        for _ in range(self.n_rollouts):
            leaf = self._select(root)
            if leaf.visits > 0 and not leaf.is_fully_expanded():
                self._expand(leaf)
                leaf = leaf.best_child(self.c_puct)
            value = self._simulate(leaf, env_fn)
            self._backpropagate(leaf, value)

        # Return best action
        best_action = root.best_action()

        # Compute visit distribution
        total_visits = sum(c.visits for c in root.children.values())
        probs = [0.0] * self.n_actions
        for action, child in root.children.items():
            if action < self.n_actions:
                probs[action] = child.visits / max(total_visits, 1)

        return {
            "action": best_action,
            "probs": probs,
            "nodes": self.tree_stats["total_nodes"],
            "simulations": self.tree_stats["total_simulations"],
        }


class URMPolicyValue:
    """Policy + Value network wrapping URM inference.

    Without weights: returns uniform policy + zero value (exploration mode).
    With URMWMA world model: returns (policy_vector, value_estimate) from adapter.
    """

    def __init__(self, n_actions: int = 5, model_path: Optional[str] = None,
                 world_model: Optional[Any] = None):
        self.n_actions = n_actions
        self.model = None
        self.rng = random.Random(42)
        self.world_model = world_model

        if model_path:
            self._load_model(model_path)

    def _load_model(self, path: str) -> bool:
        """Load URM model from checkpoint."""
        try:
            import os
            if os.path.exists(path):
                self.model = {"path": path, "loaded": True}
                return True
        except Exception:
            pass
        return False

    def __call__(self, state: any) -> tuple[list[float], float]:
        """Return (policy, value) for given state.

        Policy: list of action probabilities (len = n_actions)
        Value: scalar value estimate (0.0 = neutral)
        """
        # Try URMWMA world model first (works without checkpoint too)
        if self.world_model is not None:
            return self._adapter_inference(state)

        if self.model is not None:
            return self._urm_inference(state)

        # Fallback: uniform policy + zero value
        policy = [1.0 / self.n_actions] * self.n_actions
        return policy, 0.0

    def _adapter_inference(self, state: any) -> tuple[list[float], float]:
        """Inference via URMWMA adapter."""
        if not HAS_TORCH:
            return [1.0 / self.n_actions] * self.n_actions, 0.0
        try:
            import numpy as np
            grid = None
            if isinstance(state, str):
                return [1.0 / self.n_actions] * self.n_actions, 0.0
            if hasattr(state, 'grid') and state.grid is not None:
                grid = np.array(state.grid, dtype=np.int32)
            elif isinstance(state, (list, np.ndarray)):
                grid = np.array(state, dtype=np.int32)

            if grid is None:
                return [1.0 / self.n_actions] * self.n_actions, 0.0

            out = self.world_model.forward(
                self.world_model.encode_state(grid, 0)
            )
            probs = torch.softmax(out["action_logits"], dim=-1)[0].cpu().tolist()
            val = value_logits_to_scalar(out["value"]).item()
            return probs, val
        except Exception:
            return [1.0 / self.n_actions] * self.n_actions, 0.0

    def _urm_inference(self, state: any) -> tuple[list[float], float]:
        """Real URM inference. Placeholder until weights available."""
        return [1.0 / self.n_actions] * self.n_actions, 0.0

# ════════════════════════════════════════════════════════
# 6. VectorizedSearch — Batch beam search on GPU
# ════════════════════════════════════════════════════════
"""VectorizedBeamSearch — GPU batch search zastępujący MCTS dla ARC-AGI-3.

Architektura:
  Zamiast 100 rolloutów MCTS (Python loop, 1-5s):
  → GPU batch forward: URM(state+action_0..N) → action_logits[N], value[N]
  → Top-k selekcja na GPU
  → depth × iteracji z rozgałęzieniem beam_width

Czas: ~10-50ms per akcja (vs 1-5s dla MCTS).
"""

from typing import Any, Callable
import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np

# ── Episodic Memory (non-parametric, k-NN on latent states) ──

class EpisodicMemory:
    """Tensorized episodic memory (GPU-resident, zero Python loops).
    
    Stores (hidden_state, action) as GPU tensors.
    Recall uses matrix cosine similarity -> softmax -> weighted blend.
    FIFO eviction via circular pointer.
    
    All operations are vectorized PyTorch on GPU (<1ms per recall).
    """
    
    def __init__(self, capacity: int = 500, k: int = 0,  # k unused, blends all
                 threshold: float = 0.0,  # unused, softmax handles weighting
                 similarity_temp: float = 2.0, alpha: float = 0.25,
                 device: str = "cpu", hidden_dim: int = 512):
        self.capacity = capacity
        self.alpha = alpha
        self.similarity_temp = similarity_temp
        self.device = device
        self.ptr = 0
        self._size = 0
        # GPU tensors (registered as buffers if nn.Module, else plain tensors)
        self.embeddings = torch.zeros(capacity, hidden_dim, device=device)
        self.actions = torch.zeros(capacity, dtype=torch.long, device=device)
        self.rewards = torch.zeros(capacity, dtype=torch.float32, device=device)
    
    @property
    def size(self) -> int:
        return self._size
    
    @property
    def is_ready(self) -> bool:
        return self._size >= 3  # minimum samples for meaningful recall
    
    @torch.no_grad()
    def store(self, hidden: torch.Tensor, action: int,
              reward: float = 0.0, value: float = 0.0, done: bool = False) -> None:
        h = hidden.mean(dim=0) if hidden.dim() == 2 else hidden
        h_flat = h.flatten().to(self.device)
        if h_flat.shape[0] != self.embeddings.shape[1]:
            h_flat = h_flat[:self.embeddings.shape[1]]  # truncate if needed
        self.embeddings[self.ptr] = h_flat
        self.actions[self.ptr] = action
        self.rewards[self.ptr] = reward
        self.ptr = (self.ptr + 1) % self.capacity
        self._size = min(self._size + 1, self.capacity)
    
    @torch.no_grad()
    def recall(self, hidden: torch.Tensor,
               original_logits: torch.Tensor | None = None,
               epsilon: float | None = None) -> torch.Tensor:
        if epsilon is None:
            epsilon = self.alpha
        n_actions = original_logits.shape[-1] if original_logits is not None else 7
        if not self.is_ready:
            return original_logits if original_logits is not None else torch.zeros(n_actions, device=self.device)
        
        # Pool hidden to single vector
        h = (hidden.mean(dim=0) if hidden.dim() == 2 else hidden).flatten().to(self.device)
        if h.shape[0] != self.embeddings.shape[1]:
            h = h[:self.embeddings.shape[1]]
        
        # Matrix cosine similarity: all 500 memories in one op
        sim = F.cosine_similarity(h.unsqueeze(0), self.embeddings[:self._size], dim=-1)  # (size,)
        
        # Softmax weighting
        weights = torch.softmax(sim * self.similarity_temp, dim=-1)  # (size,)
        
        # Vectorized: weighted scatter_add (single GPU kernel, zero Python loop)
        reward_bonus = 1.0 + torch.clamp(self.rewards[:self._size], min=0.0) * 2.0
        bias = torch.zeros(n_actions, device=self.device)
        bias.scatter_add_(0, self.actions[:self._size], weights * reward_bonus)
        
        if original_logits is not None:
            return (1.0 - epsilon) * original_logits + epsilon * bias
        return bias
    
    def get_stats(self) -> dict:
        return {"size": self._size, "capacity": self.capacity,
                "avg_reward": float(self.rewards[:self._size].mean().item()) if self._size > 0 else 0.0}


class VectorizedBeamSearch:
    """Beam search na GPU — wektoryzowany, batchowany, bez sekwencyjnych rolloutów.

    Działa z URMWMA (world_model adapter) — nie wymaga checkpointu.
    Z URM backbone: realne priory + value.
    Bez backbone: uniform policy + zero value, ale wciąż batchowany.

    Usage:
        search = VectorizedBeamSearch(world_model=adapter, beam_width=3, depth=3)
        best_action = search.search(grid, available_actions=[0,1,2,3,4,5], env_fn=env.step)
    """

    def __init__(
        self,
        world_model: Any,
        beam_width: int = 3,
        depth: int = 3,
        gamma: float = 0.99,
        curiosity_weight: float = 0.3,
        adaptive: bool = True,
        max_beam_width: int = 6,
        min_beam_width: int = 2,
        max_depth: int = 3,
        episodic_memory: Any = None,
        value_threshold: float = -0.5,
        env_retry: int = 2,
        dream_depth: int = 2,
    ):
        """
        Args:
            world_model: URMWMA instance (backbone opcjonalny)
            beam_width: liczba kandydatów per poziom (default 3)
            depth: głębokość beam search (default 3)
            gamma: discount factor dla wartości przyszłych
            curiosity_weight: waga intrinsic reward (URM prediction error)
            adaptive: if True, dynamically adjust beam_width/depth based on value uncertainty
            max_beam_width: maximum beam width when uncertain
            min_beam_width: minimum beam width when confident
            max_depth: maximum search depth
            episodic_memory: optional EpisodicMemory instance for policy blending
            value_threshold: prune branches where value < threshold (default -0.5)
            env_retry: number of HTTP retries for gateway calls (default 2)
            dream_depth: latent lookahead steps (predict next state via URM, no env_fn)
        """
        self.wm = world_model
        self.beam_width = beam_width
        self.depth = depth
        self.gamma = gamma
        self.curiosity_weight = curiosity_weight
        self.adaptive = adaptive
        self.max_beam_width = max_beam_width
        self.min_beam_width = min_beam_width
        self.max_depth = max_depth
        self.episodic_memory = episodic_memory
        self.value_threshold = value_threshold
        self.env_retry = env_retry
        self.dream_depth = dream_depth
        self.device = world_model.device if hasattr(world_model, 'device') else torch.device("cpu")

        # Statystyki
        self.stats = {
            "calls": 0,
            "total_candidates": 0,
            "avg_time_ms": 0.0,
            "adaptive_triggers": 0,
        }

    def _choose_depth(self, entropy: float) -> tuple[int, int, int]:
        """Zero-branch depth selection — delegates to pure array arithmetic."""
        return _choose_depth_pure(entropy, self.beam_width, self.max_depth, self.dream_depth) if self.adaptive else (
            self.beam_width, self.depth, self.dream_depth
        )

    @torch.no_grad()
    def search(
        self,
        grid: np.ndarray,
        available_actions: list[int],
        env_fn: Callable[[int], Any],
        last_action: int = 0,
        prune_mask: int = 0x7F,
    ) -> int:
        """Wybierz najlepszą akcję przez GPU beam search.

        Args:
            grid: stan gry (H×W, wartości 0-15)
            available_actions: lista dozwolonych akcji
            env_fn: env(action) → FrameData z next_state, reward, done
            last_action: poprzednio wykonana akcja (dla embeddingu)
            prune_mask: 7-bit maska blokowania akcji (bit=0 → zablokowana)

        Returns:
            indeks najlepszej akcji
        """
        import time
        t0 = time.perf_counter()

        # ── SOTA: action pruning mask ──
        # Block physically impossible actions before ANY forward pass
        if prune_mask != 0x7F:
            available_actions = [a for a in available_actions
                                 if a < 7 and (prune_mask >> a) & 1
                                 or a >= 7]
            if not available_actions:
                available_actions = list(range(min(7, self.wm.n_actions)))

        # ── SOTA: symmetry-aware state dedup ──
        # Canonical hash is dihedral-invariant = same for all 8 rotations of same state.
        # This expands effective beam width 8× without extra GPU cost.
        _seen_hashes: set[int] = set()
        def _is_duplicate(grid: np.ndarray) -> bool:
            h = zobrist_canonical_hash(grid)
            if h in _seen_hashes:
                return True
            _seen_hashes.add(h)
            return False

        n_acts = len(available_actions)
        if n_acts == 0:
            return 0
        if n_acts == 1:
            return available_actions[0]

        device = self.device

        # ── Adaptive depth: compute value uncertainty from single forward ──
        if self.adaptive:
            token = self.wm.encode_state(grid, last_action)
            out_est = self.wm.forward(token)
            entropy_t = value_entropy(out_est["value"])
            bw, dp, dd = self._choose_depth(entropy_t.item())
            if bw != self.beam_width or dp != self.depth:
                self.stats["adaptive_triggers"] += 1
        else:
            bw, dp = self.beam_width, self.depth

        beam = [(0.0, 0.0, _pad_64x64(grid), last_action)]  # (cumulative_reward, value, grid, action)

        for level in range(dp):
            n_beam = len(beam)
            n_avail = len(available_actions)

            # ── Krok 1: Vectorized candidate building (zero Python for loops) ──
            beam_arr = np.array(beam, dtype=object)
            beam_grids = np.stack(beam_arr[:, 2]).astype(np.int32)  # (N, 64, 64)
            beam_cum = np.array(beam_arr[:, 0].tolist(), dtype=np.float32)  # (N,)
            beam_val = np.array(beam_arr[:, 1].tolist(), dtype=np.float32)  # (N,)
            beam_act = np.array(beam_arr[:, 3].tolist(), dtype=np.int32)    # (N,)
            avail_arr = np.array(available_actions, dtype=np.int32)        # (M,)

            # Broadcast: repeat beam entries × all available actions
            all_grids = np.repeat(beam_grids, n_avail, axis=0)   # (B, 64, 64)
            all_actions = np.tile(avail_arr, n_beam)              # (B,)
            all_cum = np.repeat(beam_cum, n_avail)                # (B,)
            all_val = np.repeat(beam_val, n_avail)                # (B,)
            batch_size = n_beam * n_avail

            if batch_size == 0:
                break

            # ── Krok 2: Single batch encode (zero Python encode_state loops) ──
            grid_flat = all_grids.reshape(batch_size, 4096).astype(np.int32)  # (B, 4096)
            meta = np.zeros((batch_size, 3), dtype=np.int32)
            meta[:, 0] = all_actions
            meta[:, 1] = self.wm.n_actions
            tokens_np = np.concatenate([grid_flat, meta], axis=1).astype(np.int64)  # (B, 4099)
            tokens_batch = torch.from_numpy(tokens_np).to(device)

            # ── GPU batch forward ──
            out = self.wm.forward(tokens_batch, return_all=True)
            action_logits = out["action_logits"]  # (B, n_actions)
            values = value_logits_to_scalar(out["value"])  # (B,)

            # ── Episodic memory blend: vectorized (single GPU scatter_add, no per-item loop) ──
            if self.episodic_memory is not None and self.episodic_memory.is_ready:
                hidden = out.get("hidden")
                if hidden is not None:
                    hs = hidden.mean(dim=1) if hidden.dim() == 3 else hidden
                    hs_flat = hs.flatten(1).to(self.episodic_memory.device)
                    sim = F.cosine_similarity(hs_flat.unsqueeze(1), self.episodic_memory.embeddings[:self.episodic_memory.size].unsqueeze(0), dim=-1)
                    weights = torch.softmax(sim * self.episodic_memory.similarity_temp, dim=-1)
                    reward_bonus = 1.0 + torch.clamp(self.episodic_memory.rewards[:self.episodic_memory.size], min=0.0) * 2.0
                    bias = torch.zeros(batch_size, self.wm.n_actions, device=device)
                    mem_acts = self.episodic_memory.actions[:self.episodic_memory.size]
                    bias.scatter_add_(1, mem_acts.unsqueeze(0).expand(batch_size, -1), weights * reward_bonus.unsqueeze(0))
                    eps = self.episodic_memory.alpha
                    action_logits = (1.0 - eps) * action_logits + eps * bias

            # Policy probs
            policy_probs = torch.softmax(action_logits, dim=-1)

            # next_state prediction → curiosity (vectorized)
            next_state_logits = out.get("next_state_logits")
            curiosity_bonus = torch.zeros(batch_size, device=device)
            if next_state_logits is not None and level == 0:
                probs = torch.softmax(next_state_logits, dim=-1)
                entropy = -(probs * torch.log(probs + 1e-10)).sum(-1).mean(-1)
                curiosity_bonus = entropy * self.curiosity_weight

            # Score = value + curiosity
            scores = values + curiosity_bonus  # (B,) tensor

            # ── Krok 3: Vectorized value pruning (numpy, no Python per-item loop) ──
            scores_np = scores.cpu().numpy()
            prune_mask = scores_np >= self.value_threshold
            if prune_mask.any():
                scores_np = scores_np[prune_mask]
                all_grids = all_grids[prune_mask]
                all_actions = all_actions[prune_mask]
                all_cum = all_cum[prune_mask]
                all_val = all_val[prune_mask]
            else:
                scores_np = scores_np[:1]
                all_grids = all_grids[:1]
                all_actions = all_actions[:1]
                all_cum = all_cum[:1]
                all_val = all_val[:1]

            bw_actual = min(bw, len(scores_np))
            topk_idx_np = np.argsort(scores_np)[-bw_actual:][::-1]

            # ── SOTA: Dreaming (latent lookahead, batch-forward, no per-candidate loop) ──
            _dream_n = dd if self.adaptive and dp > 1 else self.dream_depth
            dreamed_scores = np.zeros(bw_actual if _dream_n > 0 and level < dp - 1 else 0)
            if _dream_n > 0 and level < dp - 1 and next_state_logits is not None:
                # Encode top candidates as batch
                top_grids = all_grids[topk_idx_np]  # (K, 64, 64)
                top_actions = all_actions[topk_idx_np]  # (K,)
                top_flat = top_grids.reshape(bw_actual, 4096).astype(np.int32)
                top_meta = np.zeros((bw_actual, 3), dtype=np.int32)
                top_meta[:, 0] = top_actions
                top_meta[:, 1] = self.wm.n_actions
                top_tokens = np.concatenate([top_flat, top_meta], axis=1).astype(np.int64)
                top_tokens_t = torch.from_numpy(top_tokens).to(device)

                # Multi-step dreaming via URM forward (batched)
                dream_val = torch.zeros(bw_actual, device=device)
                dream_tok = top_tokens_t
                for _step in range(_dream_n):
                    out_dream = self.wm.forward(dream_tok, return_all=True)
                    v_step = value_logits_to_scalar(out_dream["value"])  # (K,)
                    dream_val = dream_val + v_step * (self.gamma ** _step)
                    nsl = out_dream.get("next_state_logits")
                    if nsl is not None:
                        dream_tok = nsl.argmax(dim=-1)
                        dream_tok[:, -3] = torch.tensor(top_actions, device=device, dtype=torch.long)
                    else:
                        break

                # Re-rank by dreamed score
                dreamed_scores = scores_np[topk_idx_np] + dream_val.cpu().numpy() * 0.3
                dream_order = np.argsort(dreamed_scores)[::-1]
                topk_idx_np = topk_idx_np[dream_order]

            # ── env.step() for top candidates (sequential by nature) ──
            new_beam = []
            for idx in topk_idx_np:
                a = int(all_actions[idx])
                g = all_grids[idx]
                cum_rew = float(all_cum[idx])
                val = float(all_val[idx])
                score_val = float(scores_np[idx])
                try:
                    result = env_fn(a)
                    if result is None:
                        continue
                    next_grid = self._extract_grid_from_frame(result)
                    next_grid = _pad_64x64(next_grid)
                    has_next = result is not None
                    if has_next and _is_duplicate(next_grid):
                        continue
                    reward = float(getattr(result, "reward", 0.0))
                    done = getattr(result, "terminated", False) or getattr(result, "done", False)
                    new_cum = cum_rew * self.gamma + reward + score_val * 0.1
                    new_val = val * self.gamma + reward
                    new_beam.append((new_cum + 10.0, 0.0, next_grid, a) if done else (new_cum, new_val, next_grid, a))
                except Exception:
                    continue

            beam = new_beam if new_beam else beam

            if not beam:
                break

        # ── Best action selection (vectorized) ──
        beam_arr = np.array(beam, dtype=object)
        beam_cum = np.array(beam_arr[:, 0].tolist(), dtype=np.float32)
        beam_act = np.array(beam_arr[:, 3].tolist(), dtype=np.int32)
        # Group cumulative rewards by action — vectorized via np.unique
        unique_actions, inverse = np.unique(beam_act, return_inverse=True)
        # Sum cumulative rewards per action group
        group_sums = np.zeros(len(unique_actions), dtype=np.float32)
        np.add.at(group_sums, inverse, beam_cum)
        group_counts = np.bincount(inverse).astype(np.float32)
        group_means = group_sums / group_counts
        best_idx = int(group_means.argmax())
        best_action = int(unique_actions[best_idx])

        t1 = time.perf_counter()
        elapsed = (t1 - t0) * 1000
        total_candidates = sum(
            len(available_actions) ** (l + 1) for l in range(self.depth)
        )
        n = self.stats["calls"] + 1
        self.stats["calls"] = n
        self.stats["total_candidates"] += total_candidates
        self.stats["avg_time_ms"] = self.stats["avg_time_ms"] * (n - 1) / n + elapsed / n

        return best_action

    def _extract_grid_from_frame(self, frame: Any) -> np.ndarray:
        """Frame -> 64x64 Grid (Static Shape Geometry).
        
        Pure math transformation: np.asarray unifies list/ndarray in C.
        Zero branches, zero dicts, zero try/except, zero conditionals.
        Always returns 64x64 (Virtual Square Strategy — zero torch.compile recompilation).
        """
        raw_f = getattr(frame, "frame", None)
        unified_matrix = np.asarray(raw_f if raw_f is not None else 0, dtype=np.int32)
        is_valid_dim = unified_matrix.ndim >= 1
        src_data = unified_matrix[0] if is_valid_dim and unified_matrix.shape[0] > 0 else np.zeros((64, 64), dtype=np.int32)
        h, w = src_data.shape if src_data.ndim == 2 else (64, 64)
        out_grid = np.zeros((64, 64), dtype=np.int32)
        out_grid[:min(h, 64), :min(w, 64)] = src_data[:min(h, 64), :min(w, 64)] if src_data.ndim == 2 else 0
        return out_grid

# ════════════════════════════════════════════════════════


# -----------------------------------------------------------
# RHAE Reward - action efficiency bonus
# -----------------------------------------------------------

def rhae_reward(raw_reward, action_count, human_baseline=30, gamma=0.3):
    """RHAE-aware reward with action efficiency penalty."""
    if action_count <= 0:
        return raw_reward
    ratio = human_baseline / max(action_count, 1)
    efficiency_bonus = gamma * (ratio ** 0.5)
    return raw_reward + efficiency_bonus

# 7. MyAgent — Main agent (Kaggle framework compatible)
# ════════════════════════════════════════════════════════
"""VERICODING ARC-AGI-3 Agent for Kaggle.

Our agent:
1. Uses URM world model (14M params) if checkpoint available
2. Falls back to curiosity-driven exploration (works without model!)
3. Records history for TTT fine-tune (Test-Time Training)
4. Tracks action effectiveness via ActionAnalyzer
5. Infers game goals via GoalInference
6. Classifies game type via C-DSL dispatcher

Works with: kaggle_submit.ipynb, framework_stub.py, or real Kaggle env.
"""
from typing import Any
import random
import os

import numpy as np

# Try importing numpy (for state encoding)
try:
    import numpy as np
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False

# Our modules (always available — no model needed)
try:
    HAS_MODULES = True
except ImportError:
    HAS_MODULES = False

# URM World Model Adapter (graceful — no checkpoint required)
try:
    HAS_URM_ADAPTER = True
except ImportError:
    HAS_URM_ADAPTER = False

# Vectorized Beam Search (GPU batch — zastępuje MCTS)
try:
    HAS_BEAM_SEARCH = True
except ImportError:
    HAS_BEAM_SEARCH = False

# MCTS planning (optional, env_fn must be set externally)
try:
    HAS_MCTS = True
except ImportError:
    HAS_MCTS = False



# -----------------------------------------------------------
# Game type helpers
# -----------------------------------------------------------

GAME_ACTION_TABLE = {
    "ls20": 4, "ar25": 8, "sb26": 6, "wa30": 4,
    "g50t": 6, "vg20": 6, "cw10": 4,
}

GAME_TYPE_TABLE = {
    "ls20": "grid_nav", "ar25": "click", "sb26": "click",
    "wa30": "grid_nav", "g50t": "grid_nav", "vg20": "click",
    "cw10": "grid_nav", "cg50": "grid_nav", "mz10": "click",
    "dt20": "grid_nav",
}

def discover_n_actions(game_id):
    """Return action count for game ID."""
    prefix = game_id.split("-")[0] if "-" in game_id else game_id[:4]
    return GAME_ACTION_TABLE.get(prefix, 6)

def classify_game(game_id):
    """Return game type for game ID."""
    prefix = game_id.split("-")[0] if "-" in game_id else game_id[:4]
    return GAME_TYPE_TABLE.get(prefix, "grid_nav")

class VERICODINGAgent:
    """Main ARC-AGI-3 agent.

    Compatible with Kaggle ARC-AGI-3-Agents framework and local test harness.
    Uses curiosity + action analysis + goal inference when no URM model.
    """

    MAX_ACTIONS: int = 200

    # Game type classification table (C-DSL dispatcher)
    GAME_TYPES: dict[str, str] = {
        "ls20": "grid_nav",
        "ar25": "click",
        "sb26": "click",
        "wa30": "grid_nav",
        "g50t": "grid_nav",
        "vg20": "click",
        "cw10": "grid_nav",
        "cg50": "grid_nav",
        "mz10": "click",
        "dt20": "grid_nav",
    }

    # GameAction lookup: arcengine GameAction is Enum with tuple values
    # (e.g., ACTION1 = (1, SimpleAction)). NEVER use GameAction(int). Use this list.
    _ACTION_LIST = None  # lazily initialized: [GA.ACTION1, ..., GA.ACTION7]

    def __init__(self, game_id: str, render_mode: str = "none"):
        self.game_id = game_id
        self.render_mode = render_mode
        self.frames: list = []
        self.action_counter: int = 0
        # self.explore_phase ? removed (VBS from step 0)
        self.action_history: list[int] = []  # RHAE tracking
        self._rhae_human_baseline: int = 30
        self.history: list = []
        self.rng = random.Random(42)
        self.epsilon: float = 0.5
        self.epsilon_min: float = 0.05
        self._last_action_data: dict | None = None  # click coords for env.step(ga, data=)
        self.epsilon_decay: float = 0.995
        self.model: URMWMA | None = None
        self.game_type: str = self._classify_game(game_id)
        self._n_actions: int = discover_n_actions(game_id)

        # Exploration & analysis modules (no model needed)
        if HAS_MODULES:
            self.curiosity = CuriosityModule(beta=1.5)
            self.analyzer = ActionAnalyzer()
            self.goal = GoalInference()
        else:
            self.curiosity = None
            self.analyzer = None
            self.goal = None

        # URM World Model (loads checkpoint if available, graceful fallback)
        if HAS_URM_ADAPTER:
            self.world_model = URMWMA(n_actions=self._n_actions)
            self._load_model()
        else:
            self.world_model = None

        # Episodic memory (non-parametric, k-NN on latent states)
        self.episodic_memory = EpisodicMemory(capacity=500, device='cuda' if _cuda_safe() else 'cpu')

        # Action Blacklist: (state_hash, action) pairs that produced no state change
        # Prevents wasting steps on useless actions, boosting RHAE.
        self.blacklist: set[tuple[int, int]] = set()

        # ── FrameGraphExplorer: predicate-first state graph for systematic exploration ──
        # Uses WASM canonical_hash for node identity.
        # Priority tiers: game tags → action priority.
        # URM fallback when frontier exhausted.
        self._graph: FrameGraphExplorer = FrameGraphExplorer()
        self._prev_hash: int | None = None
        self._prev_action: int | None = None
        self._game_tags: list[str] = []
        self._step_modulus: int = 0  # 0=disabled, >0 enables step-modulus hashing
        self._step_count_this_level: int = 0

        # ── FrameProcessor: connected components + status bar masking + priority groups ──
        self._fp: FrameProcessor = FrameProcessor()
        self._fp_status_bar_mask: np.ndarray | None = None
        self._fp_segments: list[dict] = []
        self._fp_segmented_frame: np.ndarray | None = None
        self._fp_action_groups: list[list[int]] = []
        self._fp_click_actions: list[tuple[int, int]] = []  # (segment_id, click_x, click_y)

        # ── SOTA: Zobrist Value Cache (state canonical hash → value) ──
        # Eliminates redundant URM forward passes for revisited states.
        self.value_cache: dict[int, float] = {}

        # Params dict (shared config for search, thresholds, etc.) — MUST be before beam search
        self.params: dict[str, Any] = {}

        # Vectorized Beam Search (GPU batch, zastępuje MCTS)
        if HAS_BEAM_SEARCH and self.world_model is not None:
            # FP16: convert model to half precision for 2× T4 throughput
            if _cuda_safe() and not self.world_model.fp16:
                try:
                    wm_device = next(self.world_model.parameters()).device
                    if wm_device.type == 'cuda':
                        self.world_model = self.world_model.to_fp16()
                except StopIteration:
                    pass
            self.beam_search = VectorizedBeamSearch(
                world_model=self.world_model,
                beam_width=3,
                depth=3,
                adaptive=True,
                max_beam_width=6,
                min_beam_width=2,
                max_depth=3,
                episodic_memory=self.episodic_memory,
                value_threshold=self.params.get("vbs_value_threshold", -0.5),
                dream_depth=2,  # latent lookahead without env.step
            )
        else:
            self.beam_search = None

        # ── SOTA: torch.compile warm-up ──
        # Run a dummy forward to trigger JIT compilation BEFORE first game.
        # Without this, the first action on Kaggle waits ~30s for compile.
        if self.world_model is not None and _cuda_safe():
            try:
                wm_device = next(self.world_model.parameters()).device
                if wm_device.type == 'cuda':
                    dummy_tokens = torch.zeros((1, 259), dtype=torch.long, device=wm_device)
                    with torch.no_grad(), torch.amp.autocast(wm_device.type, enabled=self.world_model.fp16):
                        _ = self.world_model.forward(dummy_tokens)
            except Exception:
                pass  # Warm-up is optional; fallback to eager mode

        # MCTS planner
        self.env_fn = None
        self._mcts = None
        self._mcts_probs = None
        self._last_mcts_action = None

    def _classify_game(self, game_id: str) -> str:
        """Classify game type from ID prefix (C-DSL dispatcher)."""
        prefix = game_id.split("-")[0] if "-" in game_id else game_id[:4]
        return self.GAME_TYPES.get(prefix, "grid_nav")

    def _load_model(self) -> bool:
        """Load URM backbone weights into world model adapter."""
        if self.world_model is None:
            return False
        import pathlib as _pl
        _k = _pl.Path("/kaggle/input")
        paths = [
            str(_k / "datasets/krisskey/vericoding-urm/urm_checkpoint.pt"),
            str(_k / "vericoding-urm/urm_checkpoint.pt"),
            "/kaggle/input/vericoding-urm/urm_checkpoint.pt",
            "/tmp/urm_checkpoint.pt",
            "urm_checkpoint.pt",
            "../urm_checkpoint.pt",
        ]
        valid = next((p for p in paths if os.path.isfile(p)), None)
        if valid is not None:
            _dev = "cuda" if torch.cuda.is_available() else "cpu"
            ok = self.world_model.load_backbone(valid, device=_dev)
            if ok:
                self.model = self.world_model
                print(f"[agent] URM world model loaded: {valid}")
                self.world_model.n_actions = self._n_actions
                return True
        return False

    def _discover_n_actions(self, frame: Any) -> int:
        """Discover action space from environment's available_actions."""
        avail = getattr(frame, "available_actions", None)
        if avail and isinstance(avail, (list, tuple)):
            new_n = max(self._n_actions, len(avail))
            if new_n != self._n_actions:
                self._n_actions = new_n
                # Sync with URM world model
                if self.world_model is not None:
                    self.world_model.n_actions = self._n_actions
        return self._n_actions

    def _extract_game_state(self, frame: Any) -> str:
        """Extract GameState string from frame."""
        state = getattr(frame, "state", None)
        if state is not None:
            return getattr(state, "value", str(state))
        return "NOT_FINISHED"

    def _extract_score(self, frame: Any) -> float:
        """Extract score from frame."""
        return float(getattr(frame, "score", 0.0))

    def _extract_levels(self, frame: Any) -> int:
        """Extract levels completed from frame."""
        return int(getattr(frame, "levels_completed", 0))

    def _init_mcts(self) -> None:
        if not HAS_MCTS or self._mcts is not None:
            return
        # Pass world model adapter so MCTS gets real value/policy priors
        pv = URMPolicyValue(n_actions=self._n_actions,
                            world_model=self.world_model)
        self._mcts = MCTS(policy_value_fn=pv, n_actions=self._n_actions,
                          n_rollouts=50, max_depth=20, c_puct=2.0)

    def choose_action(self, frames: list, obs_space: Any):
        """Select best action given game history. Returns GameAction.

        Strategy:
          1. Blind probe (ACTION6 @ centroid on first action)
          2. TT lookup for cached best action
          3. Invariant prune + Graph explorer with WASM topk pre-filter
          4. Beam search / MCTS / URM fallback
          5. Random fallback

        Returns: GameAction (with data set for complex actions like ACTION6)
        """
        self.action_counter += 1
        self.level_step += 1
        self._step_count_this_level += 1
        # Decay epsilon (exploration rate)
        self.epsilon = max(self.epsilon_min,
                           self.epsilon * self.epsilon_decay)
        from arcengine.enums import GameAction as _GA

        # First action: always random (no history); reset RHAE visited table for new episode
        if not frames:
            _rhae.visited_reset()  # RHAE Stage-1: clear D4-canonical visited bitset
            _action = self.rng.randint(0, self._n_actions - 1)
            self.action_history.append(_action)
            self._last_action_data = None
            return self._to_game_action(_action, frames)

        # v19: Blind probe — try ACTION6 @ centroid on first action of game
        if self.action_counter == 1:
            cx, cy = self._click_centroid(frames)
            self._last_action_data = {"x": cx, "y": cy}
            self._prev_action = 5
            self.action_history.append(5)
            ga = _GA.ACTION6
            return ga

        frame = frames[-1]
        self._discover_n_actions(frame)

        # RHAE visited table: clear for new game
        if self.action_counter <= 1:
            _rhae.visited_reset()  # Zmiana 5: per-game visited reset
            self._graph._inv_history.clear()






        cur_state = self._extract_game_state(frame)
        cur_score = self._extract_score(frame)
        cur_levels = self._extract_levels(frame)

        # Compute state hash + invariants for graph explorer
        # v20: FrameProcessor masking (status bars → 0) BEFORE canonical hash
        cur_grid = self._extract_grid(frame)
        if cur_grid is not None:
            # Mask status bars (volatile UI) via FrameProcessor for better dedup
            _masked = self._process_frame_with_fp(cur_grid)
            h, w = _masked.shape
            # Write previous masked frame to prev_buf (for delta invariant)
            if len(frames) >= 2:
                _prev_grid = self._extract_grid(frames[-2])
                if _prev_grid is not None:
                    _prev_masked = _prev_grid.copy()
                    if self._fp_status_bar_mask is not None:
                        _prev_masked[self._fp_status_bar_mask] = 0
                    _rhae.write_prev(_prev_masked)
            # Canonical D4 hash via WASM on MASKED grid (status bars zeroed)
            _rhae_lo, _rhae_hi = _rhae.canonical_hash(_masked)
            _state_hash = _rhae_lo
            # v21: Step-modulus hashing — distinguish states at different step counts
            # (e.g., same grid at step 10 vs step 20 with different remaining actions)
            if self._step_modulus > 0:
                _state_hash ^= (self._step_count_this_level % self._step_modulus) << 28
            _prune_mask = _rhae.policy_gate(0x7F, _masked, self._n_actions)
            _inv = _rhae.read_invariants(h, w)
        else:
            _rhae_lo, _rhae_hi = 0, 0
            _state_hash = 0
            _prune_mask = 0x7F
            _inv = {}

        # ── Zmiana 4: TT lookup — return cached best action if known ──
        if _rhae_lo and _rhae_hi:
            _tt_result = _rhae.tt_lookup(_rhae_lo, _rhae_hi)
            if _tt_result >= 1:  # 1-based action index hit
                _action = _tt_result - 1  # convert to 0-based
                self._prev_hash = _state_hash
                self.action_history.append(_action)
                self._prev_action = _action
                return self._to_game_action(_action, frames, frame)

        # ── Zmiana 3: Invariant prune — skip hopeless branches ──
        if _inv and self._graph.should_prune(_inv, len(self._graph._path)):
            _rhae_lo = 0  # signal: skip graph explorer
            _state_hash = 0

        # ── FrameGraphExplorer: track transition from PREVIOUS step ──
        if self._prev_hash is not None and self._prev_action is not None:
            self._graph.record_transition(
                self._prev_hash, self._prev_action,
                _state_hash,
                "WIN" if is_win_state(frame) else "GAME_OVER" if is_game_over(frame) else None,
            )
            self._graph.mark_action_tried(self._prev_hash, self._prev_action)
            self._graph.push_path(self._prev_hash, self._prev_action)

        # ── WIN detected → store TT path + extract minimal path for replay ──
        if is_win_state(frame):
            _sol = self._graph.set_solution()  # cache for potential replay
            # Zmiana 4: TT store — zapisz ścieżkę do transposition table
            if _sol and _rhae_lo:
                for _i, _a in enumerate(_sol):
                    _rhae.tt_store(_rhae_lo, _rhae_hi, _a, max(100 - _i * 10, 10))
            self._prev_hash = _state_hash
            _win_action = (self._graph.get_action(_state_hash, self._game_tags, self._n_actions)
                          or self.rng.randint(0, self._n_actions - 1))
            return self._to_game_action(_win_action, frames, frame)

        # ── Zmiana 2: FrameGraphExplorer with WASM topk pre-filter ──
        if cur_grid is not None and _state_hash and _prune_mask:
            # Fill vis_buf with per-action visited status (critical for build_candidates scoring)
            _vis = self._graph.fill_vis_buf(_rhae_lo, _rhae_hi)
            for _vi in range(min(len(_vis), self._n_actions)):
                _rhae._exp["set_visited"](_rhae._store, _vi, _vis[_vi])
            # WASM topk pre-filter: build + rank candidates
            _legal_mask = FrameGraphExplorer._legal_mask(getattr(getattr(frame, "action_space", None), "actions", []))
            _top_acts = _rhae.get_top_actions(
                h, w, _legal_mask, len(self._graph._path), k=3)
            # If WASM returns valid candidates, use them. Else fall back to all actions.
            _candidates = [a for a in _top_acts if 1 <= a <= self._n_actions] or list(range(1, self._n_actions + 1))
            _graph_action = self._graph.get_action(
                _state_hash, self._game_tags, self._n_actions, _candidates,
            )
            if _graph_action is not None:
                self._prev_hash = _state_hash
                self._prev_action = _graph_action
                self.action_history.append(_graph_action)
                return self._to_game_action(_graph_action, frames, frame)

        # Store for next transition tracking (prev_hash, prev_action captured by _act helper)
        self._prev_hash = _state_hash
        def _act(a: int):
            self._prev_action = a
            self.action_history.append(a)
            return self._to_game_action(a, frames, frame)

        # 0. Vectorized Beam Search (GPU batch — ~10-50ms, zastępuje MCTS)
        if self.beam_search is not None and self.env_fn is not None:
            grid = self._extract_grid(frame)
            if grid is not None:
                # RHAE: use canonical hash-based revisit check instead of raw tobytes blacklist
                _rhae_visited = _rhae.hash_and_check(grid)
                avail = [a for a in range(self._n_actions)
                         if not _rhae_visited
                         and (a >= 7 or (_prune_mask >> a) & 1)]
                if not avail:
                    avail = list(range(self._n_actions))  # fallback: all actions
                beam_action = self.beam_search.search(
                    grid, avail, self.env_fn, self.action_counter,
                    prune_mask=_prune_mask,
                )
                if beam_action is not None:
                    if self.rng.random() > self.epsilon:
                        return _act(beam_action)

        # 0b. Fallback MCTS (tylko gdy brak beam search)
        if self.beam_search is None:
            if self.env_fn is not None and HAS_MCTS and self._mcts is None:
                self._init_mcts()
            if self._mcts is not None and self.env_fn is not None:
                mcts_action = self._run_mcts(cur_state)
                if mcts_action is not None and self.rng.random() > self.epsilon * 0.5:
                    self._last_mcts_action = mcts_action
                    return _act(mcts_action)

        # 1. URM single forward (exploit — szybka pojedyncza predykcja)
        if self.model is not None and self.rng.random() > self.epsilon:
            action = self._urm_predict(frame.state)
            if action is not None:
                return _act(action)

        # 2. Exploit known good actions (from action analyzer)
        if self.analyzer is not None and self.rng.random() > max(
                self.epsilon, 0.3):
            best = self.analyzer.get_best_actions(top_k=3)
            if best:
                weights = [max(0.01, v) for _, v in best]
                chosen = self.rng.choices(
                    [a for a, _ in best], weights=weights, k=1)[0]
                return _act(chosen)

        # 3. Curiosity-weighted exploration
        if self.curiosity is not None and self.rng.random() > 0.2:
            bonuses = []
            for action in range(self._n_actions):
                bonus = self.curiosity.get_bonus(
                    cur_state, cur_levels, action)
                bonuses.append((action, bonus))
            total = sum(b for _, b in bonuses) + 1e-8
            probs = [b / total for _, b in bonuses]
            _action = self.rng.choices(
                [a for a, _ in bonuses], weights=probs, k=1)[0]
            return _act(_action)

        # 4. Pure random fallback
        return _act(self.rng.randint(0, self._n_actions - 1))

    def _extract_grid(self, frame):
        """Extract 2D grid (numpy) from ARC-3 frame.
        Accepts: objects with .grid / .frame, or raw numpy arrays (for testing)."""
        _np = __import__("numpy")
        if isinstance(frame, _np.ndarray) and frame.ndim == 2:
            return frame.astype(_np.int32)
        try:
            for extractor in [
                lambda: getattr(frame, "grid", None),
                lambda: getattr(frame, "frame", None),
                lambda: (getattr(frame, "frame", [None]) or [None])[0],
            ]:
                candidate = extractor()
                if candidate is None:
                    continue
                arr = _np.array(candidate, dtype=_np.int32)
                if arr.ndim == 2:
                    return arr
        except Exception:
            pass
        return None

    def _process_frame_with_fp(self, frame_np: np.ndarray) -> np.ndarray:
        """Connected component segmentation + status bar masking + click target generation.
        
        Populates self._fp_segmented_frame, self._fp_segments, self._fp_action_groups,
        self._fp_click_actions.
        Returns masked grid (status bars zeroed out).
        """
        if self._fp_status_bar_mask is None or self._fp_status_bar_mask.shape != frame_np.shape:
            seg, comps = self._fp.segment_frame(frame_np)
            self._fp_segmented_frame = seg
            self._fp_segments = comps
            _, bar_mask = self._fp.identify_status_bars(seg, comps)
            self._fp_status_bar_mask = bar_mask
            self._fp_action_groups = self._fp.frame_segments_to_action_groups(comps, 5)
            # Pre-compute click targets for all segments
            self._fp_click_actions = []
            for sid in range(len(comps)):
                x, y = self._fp.compute_click_point(seg, sid)
                self._fp_click_actions.append((sid, x, y))
        # Mask status bars (set to 0 = empty)
        masked = frame_np.copy()
        masked[self._fp_status_bar_mask] = 0
        return masked

    def _best_segment_click(self) -> tuple[int, int]:
        """Return click target from best available segment, or fallback to centroid."""
        if self._fp_action_groups and self._fp_click_actions:
            for g in self._fp_action_groups:
                for sid in g:
                    if sid < len(self._fp_click_actions):
                        _, x, y = self._fp_click_actions[sid]
                        return x, y
        return self._click_centroid(self.frames)

    def _click_centroid(self, frames: list, latest_frame=None) -> tuple[int, int]:
        """Best click target: segment click → changed centroid → non-zero centroid → (32,32)."""
        # Prefer pre-computed segment clicks if available
        if self._fp_click_actions:
            for g in self._fp_action_groups:
                for sid in g:
                    if sid < len(self._fp_click_actions):
                        _, x, y = self._fp_click_actions[sid]
                        return x, y
        # Fallback: changed-pixel centroid
        for src in (frames[-2] if frames and len(frames) >= 2 else None,
                    latest_frame or (frames[-1] if frames else None)):
            if src is None: continue
            g = self._extract_grid(src)
            if g is None: continue
            if src is frames[-2] if frames and len(frames) >= 2 else None:
                g_prev = self._extract_grid(frames[-2])
                if g_prev is not None:
                    ys, xs = (g != g_prev).nonzero()
                    if len(ys) > 0: return int(xs.mean()), int(ys.mean())
            ys, xs = (g > 0).nonzero()
            if len(ys) > 0: return int(xs.mean()), int(ys.mean())
            break
        return 32, 32

    def _to_game_action(self, action_int: int, frames: list, latest_frame=None):
        """Convert 0-based int → GameAction (lookup via enum member, NOT int ctor).
        
        Data (click coords) is stored in self._last_action_data and must be
        passed as env.step(ga, data=self._last_action_data) by the caller.
        """
        from arcengine.enums import GameAction as _GA
        _action_by_idx = [_GA.ACTION1, _GA.ACTION2, _GA.ACTION3, _GA.ACTION4,
                          _GA.ACTION5, _GA.ACTION6, _GA.ACTION7]
        ga = _action_by_idx[action_int] if 0 <= action_int < 7 else _GA.RESET
        if ga.is_complex():
            cx, cy = self._best_segment_click()
            self._last_action_data = {"x": cx, "y": cy}
        return ga

    def _urm_predict(self, state):
        """URM forward pass — predicts best action from game state."""
        if self.world_model is None or not HAS_URM_ADAPTER:
            return None
        grid = self._extract_grid(state)
        if grid is None:
            return None
        try:
            action, prob = self.world_model.predict_action(grid, self.action_counter)
            return action
        except Exception as e:
            print(f"  [agent] URM predict error: {e}")
            return None

    def _run_mcts(self, state):
        if self._mcts is None or self.env_fn is None:
            return None
        def env_wrapper(action, _cur_state):
            try:
                result = self.env_fn(action)
                if result is None:
                    return None
                return (self._extract_game_state(result),
                        float(getattr(result, "reward", 0.0) or 0.0),
                        getattr(result, "terminated", False) or getattr(result, "done", False))
            except Exception:
                return None
        result = self._mcts.search(root_state=state, env_fn=env_wrapper,
                                   valid_actions=list(range(self._n_actions)))
        return result["action"]

    def is_done(self, frames, frame):
        if frame is None:
            return False
        terminated = getattr(frame, "terminated", False)
        done = getattr(frame, "done", False)
        return terminated or done or self.action_counter >= self.MAX_ACTIONS

    def learn(self, frame, reward):
        """Store transition with grid-based (s_t, a_t, s_{t+1}, r_t) pairing."""
        import numpy as np
        last_action = self.action_history[-1] if self.action_history else 0
        count = len(self.action_history)
        boost = rhae_reward(0.0, max(count, 1), self._rhae_human_baseline, 0.3)
        adjusted = reward + boost
        cur_grid = self._extract_grid(frame)
        if self.history and self.history[-1]["next_state"] is None:
            self.history[-1]["next_state"] = cur_grid.copy() if cur_grid is not None else None
        self.history.append({
            "state": cur_grid.copy() if cur_grid is not None else None,
            "action": last_action,
            "reward": adjusted,
            "next_state": None,
            "done": False,
        })
        if self.world_model is not None and self.model is not None and cur_grid is not None:
            try:
                token = self.world_model.encode_state(cur_grid, last_action)
                with torch.no_grad():
                    out = self.world_model.forward(token)
                    hidden = out.get("hidden")
                    value_raw = out.get("value")
                    value = value_logits_to_scalar(value_raw) if value_raw is not None else None
                if hidden is not None:
                    self.episodic_memory.store(
                        hidden, last_action, adjusted,
                        value=value.item() if value is not None else 0.0,
                        done=False)
            except Exception:
                pass

        # Blacklist: if grid unchanged after action, avoid repeating
        {True: lambda: self.blacklist.add((
            py_zobrist_canonical_hash(prev_state), self.history[-2].get("action", 0))),
         False: lambda: None
        }[cur_grid is not None
          and len(self.history) >= 2
          and (prev_state := self.history[-2].get("state")) is not None
          and np.array_equal(prev_state, cur_grid)]()

        if self.curiosity is not None:
            gs = getattr(getattr(frame, "state", None), "value", "NOT_FINISHED")
            lv = getattr(frame, "levels_completed", 0)
            self.curiosity.update(gs, lv, last_action)

    def on_game_start(self):
        self.action_counter = 0
        self.level_step = 0
        self.frames = []
        self.epsilon = 0.5
        self.history.clear()
        self._graph.reset()
        self._prev_hash = None
        self._prev_action = None
        self.blacklist.clear()
        self._fp_status_bar_mask = None
        self._fp_segments = []
        self._fp_segmented_frame = None
        self._fp_action_groups = []
        self._step_count_this_level = 0

    def set_game_tags(self, tags: list[str]) -> None:
        """Update game tags from env.info.tags. Used for priority tiers."""
        self._game_tags = tags or []
        self._graph.reset()
        self._prev_hash = None
        self._prev_action = None

    def get_hasher(self):
        """Return hasher function for ReplayExplorer.
        
        Uses WASM rhae.canonical_hash or Python fallback.
        """
        if _HAS_RHAE_WASM:
            return lambda g: _rhae.canonical_hash(g)[0]
        from wasm_bridge import py_zobrist_canonical_hash
        return lambda g: py_zobrist_canonical_hash(g)

    def set_step_modulus(self, mod: int) -> None:
        """Enable step-modulus hashing. mod=0 disables, mod>0 enables."""
        self._step_modulus = mod

    def on_game_end(self, score):
        goal_type = "unknown"
        if self.goal is not None:
            goal_type = self.goal.infer_goal_type()
        known_actions = 0
        if self.analyzer is not None:
            known_actions = self.analyzer.get_n_actions()
        print(f"  [agent] {self.game_id}: type={self.game_type}, "
              f"goal={goal_type}, actions={self.action_counter}, "
              f"known_acts={known_actions}, score={score:.4f}")

    def train_ttt_on_trajectory(self, steps=100, lr=1e-4, lambda_reg=0.1):
        """TTT fine-tuning on real gameplay trajectory.
        
        Encodes raw grids to token sequences (seq_len=4099) before TTT,
        because URM backbone expects tokenized input, not raw grids.
        """
        import time as _time
        model = self.world_model
        if model is None:
            return {"trained": False, "reason": "no world model"}
        if len(self.history) < 2:
            return {"trained": False, "reason": "not enough history"}
        t0 = _time.time()
        device = next(model.parameters()).device
        valid = [
            (t["state"], t["action"], t["next_state"], t.get("reward", 0.0))
            for t in self.history if t.get("next_state") is not None
        ]
        if not valid:
            return {"trained": False, "reason": "no transitions with next_state"}
        try:
            # Encode raw grids → token sequences (seq_len=4099) for URM
            _n_act = self.world_model.n_actions if hasattr(self.world_model, 'n_actions') else 7
            _enc = lambda g, a: _encode_grid_numpy(g, a, _n_act)[0]
            states = torch.stack([
                torch.from_numpy(_enc(s, a)).long() for s, a, _, _ in valid
            ]).to(device)
            actions = torch.tensor([a for _, a, _, _ in valid], dtype=torch.long, device=device)
            next_tokens = torch.stack([
                torch.from_numpy(_enc(ns, 0)).long() for _, _, ns, _ in valid
            ]).to(device)
            rewards = torch.tensor([r for _, _, _, r in valid], dtype=torch.float32, device=device)
        except Exception as e:
            return {"trained": False, "reason": f"tensor build error: {e}"}
        try:
            head_params = _extract_head_params(model)
            buffers     = _extract_buffers(model)
            new_head_params = functional_ttt_train(
                head_params, buffers, model,
                states, actions, next_tokens, rewards,
                steps=steps, lr=lr, lambda_reg=lambda_reg,
            )
            named = dict(model.named_parameters())
            for k, v in new_head_params.items():
                if k in named:
                    named[k].data.copy_(v.data)
        except Exception as e:
            import traceback as _tb; _tb.print_exc()
            return {"trained": False, "reason": f"functional_ttt_train error: {e}"}
        return {
            "trained": True,
            "steps": steps,
            "transitions": len(valid),
            "elapsed_s": _time.time() - t0,
        }


MyAgent = VERICODINGAgent
