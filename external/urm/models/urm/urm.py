"""
urm.py — Universal Reasoning Model (URM) Core
SOTA refactor v11: algebraic carry type, pure functional forward,
device discipline enforced via assertions, no bare tensor constructors,
no loops in hot path, pattern-matched halt logic.
"""
from __future__ import annotations
from dataclasses import dataclass, replace
from typing import Optional, NamedTuple
import math

import torch
import torch.nn as nn
import torch.nn.functional as F

from ..layers import CastedEmbedding, CastedLinear, RMSNorm, RotaryEmbedding, EmbeddingCfg, LinearCfg
from ..losses import ACTLossHead, ACTLossCfg, value_logits_to_scalar


# ─── Algebraic config ─────────────────────────────────────────────────────────

@dataclass(frozen=True)
class URMConfig:
    vocab_size: int        = 12        # 0-9 colours + pad + mask
    hidden_size: int       = 512
    num_heads: int         = 8
    num_layers: int        = 6
    ffn_mult: int          = 4
    max_seq_len: int       = 4099      # h*w + 3 meta tokens
    loops: int             = 3         # ACT max loops
    dropout: float         = 0.0
    cast_to: torch.dtype   = torch.float32


# ─── URMCarry — pure algebraic state ─────────────────────────────────────────

class URMCarry(NamedTuple):
    """
    Immutable carry threaded through URM recurrent steps.
    All tensors must be on the same device.
    Never mutated in-place — always replaced via URMCarry(...)._replace or NamedTuple.
    """
    current_hidden: torch.Tensor   # (B, T, H)
    steps:          torch.Tensor   # (B,) int32
    halted:         torch.Tensor   # (B,) bool
    current_data:   dict           # mirrors batch keys, tensors on same device


# ─── Transformer block (single layer) ────────────────────────────────────────

class URMBlock(nn.Module):
    """
    Pre-norm transformer block with RoPE.
    Pure: no in-place modifications to input tensors.
    """

    def __init__(self, cfg: URMConfig) -> None:
        super().__init__()
        self.cfg = cfg
        H, nh = cfg.hidden_size, cfg.num_heads
        head_dim = H // nh

        self.norm1 = RMSNorm(H)
        self.norm2 = RMSNorm(H)
        self.rope  = RotaryEmbedding(head_dim, max_seq_len=cfg.max_seq_len)

        self.q_proj = CastedLinear.from_params(H, H, bias=False, cast_to=cfg.cast_to)
        self.k_proj = CastedLinear.from_params(H, H, bias=False, cast_to=cfg.cast_to)
        self.v_proj = CastedLinear.from_params(H, H, bias=False, cast_to=cfg.cast_to)
        self.o_proj = CastedLinear.from_params(H, H, bias=False, cast_to=cfg.cast_to)

        ffn_dim = H * cfg.ffn_mult
        self.gate = CastedLinear.from_params(H, ffn_dim, bias=False, cast_to=cfg.cast_to)
        self.up   = CastedLinear.from_params(H, ffn_dim, bias=False, cast_to=cfg.cast_to)
        self.down = CastedLinear.from_params(ffn_dim, H, bias=False, cast_to=cfg.cast_to)

    def _attn(self, x: torch.Tensor) -> torch.Tensor:
        B, T, H = x.shape
        nh, hd = self.cfg.num_heads, H // self.cfg.num_heads
        # project and reshape to (B, nh, T, hd)
        reshape = lambda t: t.view(B, T, nh, hd).transpose(1, 2)
        q, k, v = reshape(self.q_proj(x)), reshape(self.k_proj(x)), reshape(self.v_proj(x))
        q, k    = self.rope(q, k)
        out     = F.scaled_dot_product_attention(q, k, v, dropout_p=0.0, is_causal=False)
        return self.o_proj(out.transpose(1, 2).contiguous().view(B, T, H))

    def _ffn(self, x: torch.Tensor) -> torch.Tensor:
        return self.down(F.silu(self.gate(x)) * self.up(x))

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return x + self._ffn(self.norm2(x + self._attn(self.norm1(x))))


# ─── URM_Inner — recurrent transformer core ──────────────────────────────────

class URMInner(nn.Module):
    """
    Shared-weight recurrent transformer.
    Each ACT loop runs the same block stack.
    Outputs: (new_carry, logits, (q_halt, q_continue))
    Device invariant: all carry fields on next(self.parameters()).device
    """

    def __init__(self, cfg: URMConfig) -> None:
        super().__init__()
        self.cfg = cfg
        self.embed  = CastedEmbedding.from_params(cfg.vocab_size, cfg.hidden_size,
                                                   cast_to=cfg.cast_to)
        self.blocks = nn.ModuleList([URMBlock(cfg) for _ in range(cfg.num_layers)])
        self.norm   = RMSNorm(cfg.hidden_size)
        self.lm_head = CastedLinear.from_params(cfg.hidden_size, cfg.vocab_size,
                                                  bias=False, cast_to=cfg.cast_to)
        # ACT halt/continue heads
        self.halt_head     = CastedLinear.from_params(cfg.hidden_size, 1, bias=True)
        self.continue_head = CastedLinear.from_params(cfg.hidden_size, 1, bias=True)

    @property
    def _device(self) -> torch.device:
        return next(self.parameters()).device

    def empty_carry(self, batch_size: int, device: torch.device) -> URMCarry:
        """Returns zero-initialized carry on specified device."""
        return URMCarry(
            current_hidden=torch.zeros(
                batch_size, self.cfg.max_seq_len, self.cfg.hidden_size,
                device=device, dtype=torch.float32,
            ),
            steps=torch.zeros(batch_size, dtype=torch.int32, device=device),
            halted=torch.ones(batch_size, dtype=torch.bool, device=device),
            current_data={},
        )

    def _assert_carry_device(self, carry: URMCarry) -> None:
        dev = self._device
        assert carry.current_hidden.device == dev, \
            f"carry.current_hidden on {carry.current_hidden.device}, expected {dev}"
        assert carry.steps.device == dev, \
            f"carry.steps on {carry.steps.device}, expected {dev}"
        assert carry.halted.device == dev, \
            f"carry.halted on {carry.halted.device}, expected {dev}"

    def forward(
        self,
        carry: URMCarry,
        data: dict,
    ) -> tuple[URMCarry, torch.Tensor, tuple[torch.Tensor, torch.Tensor]]:
        self._assert_carry_device(carry)
        dev = self._device

        x = self.embed(data["inputs"].clamp(0, self.cfg.vocab_size - 1))  # (B, T, H)

        # inject recurrent hidden state (residual)
        h = x + carry.current_hidden[:, :x.size(1), :]

        # run shared blocks
        for block in self.blocks:
            h = block(h)

        h = self.norm(h)
        logits = self.lm_head(h)             # (B, T, V)

        # pool for halt decision
        pooled   = h.mean(dim=1)             # (B, H)
        q_halt   = self.halt_head(pooled).squeeze(-1)      # (B,)
        q_cont   = self.continue_head(pooled).squeeze(-1)  # (B,)

        # pad hidden to max_seq_len if needed (pure, no in-place)
        T = h.size(1)
        new_hidden = torch.cat(
            [h, torch.zeros(h.size(0), self.cfg.max_seq_len - T, self.cfg.hidden_size,
                            device=dev, dtype=h.dtype)],
            dim=1,
        ) if T < self.cfg.max_seq_len else h[:, :self.cfg.max_seq_len, :]

        new_carry = URMCarry(
            current_hidden=new_hidden,
            steps=carry.steps + 1,
            halted=carry.halted,
            current_data=data,
        )
        return new_carry, logits, (q_halt, q_cont)


# ─── URM — outer ACT loop ─────────────────────────────────────────────────────

class URM(nn.Module):
    """
    Universal Reasoning Model with Adaptive Computation Time.
    Outer recurrent loop over URMInner.
    Pure functional carry threading — no global state mutation.

    Device invariant: all batch tensors must be on next(self.parameters()).device
    before calling forward. load_backbone moves all parameters; caller must not
    move tensors externally.
    """

    def __init__(self, cfg: URMConfig = URMConfig()) -> None:
        super().__init__()
        self.config = cfg
        self.inner  = URMInner(cfg)
        self.act_loss = ACTLossHead(ACTLossCfg())

    @property
    def _device(self) -> torch.device:
        return next(self.parameters()).device

    def initial_carry(self, batch: dict) -> URMCarry:
        """
        Construct initial carry. Device derived from batch["inputs"] — single source of truth.
        """
        device     = batch["inputs"].device
        batch_size = batch["inputs"].size(0)
        base       = self.inner.empty_carry(batch_size, device=device)
        return URMCarry(
            current_hidden=base.current_hidden,
            steps=torch.zeros(batch_size, dtype=torch.int32, device=device),
            halted=torch.ones(batch_size,  dtype=torch.bool,  device=device),
            current_data={k: torch.empty_like(v) for k, v in batch.items()},
        )

    def _reset_carry(self, halted: torch.Tensor, carry: URMCarry, batch: dict) -> URMCarry:
        """
        Reset carry fields for newly-halted samples.
        Pattern-matched via torch.where — no Python loops.
        """
        view = lambda t: halted.view((-1,) + (1,) * (t.dim() - 1))
        return URMCarry(
            current_hidden=torch.where(view(carry.current_hidden),
                                       torch.zeros_like(carry.current_hidden),
                                       carry.current_hidden),
            steps=torch.where(halted, torch.zeros_like(carry.steps), carry.steps),
            halted=halted,
            current_data={
                k: torch.where(view(v), batch[k], v)
                for k, v in carry.current_data.items()
            },
        )

    def forward(
        self,
        carry: URMCarry,
        batch: dict,
        compute_target_q: bool = False,
    ) -> tuple[URMCarry, dict]:
        dev = self._device
        self.inner._assert_carry_device(carry)

        reset_carry = self._reset_carry(carry.halted, carry, batch)
        reset_data  = {k: torch.where(
            carry.halted.view((-1,) + (1,) * (v.dim() - 1)), batch[k], v)
            for k, v in reset_carry.current_data.items()}

        new_carry, logits, (q_halt, q_cont) = self.inner(reset_carry, reset_data)

        # ACT halt decision — pattern-matched, no if-statements
        halt_signal = q_halt > 0.0
        new_steps   = torch.where(carry.halted,
                                   torch.zeros_like(new_carry.steps),
                                   new_carry.steps)

        # training: stochastic min-halt (vectorised)
        stochastic_halt = (
            halt_signal
            | (self.training & (self.config.loops > 1) & (
                (torch.rand_like(q_halt) < 0.1).bool()
                & (new_steps >= torch.randint_like(new_steps, low=2,
                                                    high=self.config.loops + 1))
            ))
        )

        final_carry = URMCarry(
            current_hidden=new_carry.current_hidden,
            steps=new_steps,
            halted=stochastic_halt,
            current_data=reset_data,
        )

        outputs = {
            "logits":    logits,
            "q_halt":    q_halt,
            "q_continue": q_cont,
            "steps":     new_steps,
            "halted":    stochastic_halt,
        }
        return final_carry, outputs
