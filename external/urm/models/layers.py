"""
layers.py — ARC-AGI-3 URM Backbone Layers
SOTA refactor v11: pure algebraic types, device-discipline, no bare constructors.
All tensors created inside a module use device derived from parameters.
"""
from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
import math

import torch
import torch.nn as nn
import torch.nn.functional as F


# ─── Algebraic config types ───────────────────────────────────────────────────

@dataclass(frozen=True)
class EmbeddingCfg:
    num_embeddings: int
    embedding_dim: int
    cast_to: torch.dtype = torch.float32
    padding_idx: Optional[int] = None


@dataclass(frozen=True)
class LinearCfg:
    in_features: int
    out_features: int
    bias: bool = True
    cast_to: torch.dtype = torch.float32


# ─── CastedEmbedding ──────────────────────────────────────────────────────────

class CastedEmbedding(nn.Module):
    """
    Embedding with explicit dtype cast on forward.
    Device discipline: weight lives on module device; input must match.
    No bare tensor constructors.
    """

    def __init__(self, cfg: EmbeddingCfg) -> None:
        super().__init__()
        self.cfg = cfg
        self.embedding_weight = nn.Parameter(
            torch.empty(cfg.num_embeddings, cfg.embedding_dim)
        )
        nn.init.normal_(self.embedding_weight, std=1.0 / math.sqrt(cfg.embedding_dim))

    @property
    def _device(self) -> torch.device:
        return self.embedding_weight.device

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        # x must be on same device as weight — verified by F.embedding internally
        return F.embedding(
            x,
            self.embedding_weight.to(self.cfg.cast_to),
            padding_idx=self.cfg.padding_idx,
        )

    @classmethod
    def from_params(
        cls,
        num_embeddings: int,
        embedding_dim: int,
        cast_to: torch.dtype = torch.float32,
        padding_idx: Optional[int] = None,
    ) -> "CastedEmbedding":
        return cls(EmbeddingCfg(num_embeddings, embedding_dim, cast_to, padding_idx))


# ─── CastedLinear ─────────────────────────────────────────────────────────────

class CastedLinear(nn.Module):
    """
    Linear layer with explicit dtype cast on forward.
    Pattern: cast weight to target dtype at forward time only (keeps master fp32).
    """

    def __init__(self, cfg: LinearCfg) -> None:
        super().__init__()
        self.cfg = cfg
        self.weight = nn.Parameter(torch.empty(cfg.out_features, cfg.in_features))
        self.bias: Optional[nn.Parameter] = (
            nn.Parameter(torch.zeros(cfg.out_features)) if cfg.bias else None
        )
        nn.init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in = cfg.in_features
            bound = 1.0 / math.sqrt(fan_in) if fan_in > 0 else 0
            nn.init.uniform_(self.bias, -bound, bound)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        w = self.weight.to(self.cfg.cast_to)
        b = self.bias.to(self.cfg.cast_to) if self.bias is not None else None
        return F.linear(x, w, b)

    @classmethod
    def from_params(
        cls,
        in_features: int,
        out_features: int,
        bias: bool = True,
        cast_to: torch.dtype = torch.float32,
    ) -> "CastedLinear":
        return cls(LinearCfg(in_features, out_features, bias, cast_to))


# ─── CastedSparseEmbedding ────────────────────────────────────────────────────

@dataclass(frozen=True)
class SparseEmbeddingCfg:
    num_embeddings: int
    embedding_dim: int
    cast_to: torch.dtype = torch.float32
    sparse: bool = True


class CastedSparseEmbedding(nn.Module):
    """
    Sparse embedding variant — same device discipline as CastedEmbedding.
    sparse=True uses sparse gradient updates (faster for large vocab).
    """

    def __init__(self, cfg: SparseEmbeddingCfg) -> None:
        super().__init__()
        self.cfg = cfg
        self.embedding_weight = nn.Parameter(
            torch.empty(cfg.num_embeddings, cfg.embedding_dim),
            requires_grad=True,
        )
        nn.init.normal_(self.embedding_weight, std=1.0 / math.sqrt(cfg.embedding_dim))

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return F.embedding(
            x,
            self.embedding_weight.to(self.cfg.cast_to),
            sparse=self.cfg.sparse,
        )

    @classmethod
    def from_params(
        cls,
        num_embeddings: int,
        embedding_dim: int,
        cast_to: torch.dtype = torch.float32,
    ) -> "CastedSparseEmbedding":
        return cls(SparseEmbeddingCfg(num_embeddings, embedding_dim, cast_to))


# ─── RMSNorm ──────────────────────────────────────────────────────────────────

class RMSNorm(nn.Module):
    """
    RMS normalisation — used in URM inner layers.
    eps on same device as weight.
    """

    def __init__(self, dim: int, eps: float = 1e-6) -> None:
        super().__init__()
        self.eps = eps
        self.weight = nn.Parameter(torch.ones(dim))

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        norm = x.float().pow(2).mean(-1, keepdim=True).add(self.eps).rsqrt()
        return (x.float() * norm).to(x.dtype) * self.weight


# ─── RotaryEmbedding ──────────────────────────────────────────────────────────

class RotaryEmbedding(nn.Module):
    """
    RoPE positional encoding.
    Buffers registered — device propagates automatically with .to().
    No bare tensor constructors in forward.
    """

    def __init__(self, dim: int, max_seq_len: int = 4096, base: int = 10000) -> None:
        super().__init__()
        inv_freq = 1.0 / (base ** (torch.arange(0, dim, 2).float() / dim))
        self.register_buffer("inv_freq", inv_freq, persistent=False)
        self._build_cache(max_seq_len)

    def _build_cache(self, seq_len: int) -> None:
        t = torch.arange(seq_len, device=self.inv_freq.device).float()
        freqs = torch.outer(t, self.inv_freq)
        emb = torch.cat([freqs, freqs], dim=-1)
        self.register_buffer("cos_cached", emb.cos()[None, None, :, :], persistent=False)
        self.register_buffer("sin_cached", emb.sin()[None, None, :, :], persistent=False)

    @staticmethod
    def _rotate_half(x: torch.Tensor) -> torch.Tensor:
        half = x.shape[-1] // 2
        return torch.cat([-x[..., half:], x[..., :half]], dim=-1)

    def forward(self, q: torch.Tensor, k: torch.Tensor) -> tuple[torch.Tensor, torch.Tensor]:
        seq = q.shape[-2]
        cos = self.cos_cached[:, :, :seq, :]
        sin = self.sin_cached[:, :, :seq, :]
        q_rot = q * cos + self._rotate_half(q) * sin
        k_rot = k * cos + self._rotate_half(k) * sin
        return q_rot, k_rot
