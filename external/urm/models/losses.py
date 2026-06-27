"""
losses.py — ARC-AGI-3 URM Loss Functions
SOTA refactor v11: pure functional, no loops, algebraic dispatch.
All device references derived from input tensors — zero bare constructors.
"""
from __future__ import annotations
from dataclasses import dataclass
from typing import Optional
import torch
import torch.nn as nn
import torch.nn.functional as F


# ─── Algebraic loss config ────────────────────────────────────────────────────

@dataclass(frozen=True)
class ACTLossCfg:
    halt_weight: float = 1.0
    ponder_weight: float = 0.01
    value_weight: float = 1.0
    action_weight: float = 1.0


# ─── stablemax (numerically stable softmax variant) ──────────────────────────

def stablemax(x: torch.Tensor, dim: int = -1) -> torch.Tensor:
    """
    Numerically stable softmax via log-sum-exp shift.
    Pure functional — no in-place ops.
    """
    shifted = x - x.amax(dim=dim, keepdim=True).detach()
    exp_x = shifted.exp()
    return exp_x / exp_x.sum(dim=dim, keepdim=True)


def stablemax_cross_entropy(
    logits: torch.Tensor,
    targets: torch.Tensor,
    label_smoothing: float = 0.0,
    ignore_index: int = -100,
) -> torch.Tensor:
    """
    Cross-entropy via stablemax probabilities.
    Vectorised — no loops.
    label_smoothing applied uniformly when > 0.
    """
    probs = stablemax(logits, dim=-1)                     # (B, V)
    log_probs = probs.clamp(min=1e-9).log()

    # mask ignore_index positions
    valid_mask = targets != ignore_index                  # (B,)
    safe_targets = targets.masked_fill(~valid_mask, 0)   # avoid OOB index

    # gather log-probs at target positions
    nll = -log_probs.gather(-1, safe_targets.unsqueeze(-1)).squeeze(-1)  # (B,)

    # uniform label smoothing
    smooth_loss = -log_probs.mean(dim=-1)                 # (B,)
    loss = (1.0 - label_smoothing) * nll + label_smoothing * smooth_loss

    return loss.masked_fill(~valid_mask, 0.0).sum() / valid_mask.float().sum().clamp(min=1.0)


# ─── value_logits_to_scalar ───────────────────────────────────────────────────

def value_logits_to_scalar(value_logits: torch.Tensor) -> torch.Tensor:
    """
    Maps 5-bin value head logits -> scalar via expectation over support [-2,-1,0,1,2].
    Pure: no in-place, device derived from input.
    """
    support = torch.tensor([-2.0, -1.0, 0.0, 1.0, 2.0],
                           dtype=value_logits.dtype,
                           device=value_logits.device)   # device from input
    probs = F.softmax(value_logits, dim=-1)               # (B, 5)
    return (probs * support).sum(dim=-1)                  # (B,)


# ─── ACTLossHead ─────────────────────────────────────────────────────────────

class ACTLossHead(nn.Module):
    """
    Adaptive Computation Time loss head.
    Combines: halt loss, ponder cost, value loss, action loss.
    All tensors created on device derived from inputs.
    No loops, no bare constructors.
    """

    def __init__(self, cfg: ACTLossCfg = ACTLossCfg()) -> None:
        super().__init__()
        self.cfg = cfg

    def forward(
        self,
        action_logits: torch.Tensor,        # (B, A)
        value_logits: torch.Tensor,          # (B, 5)
        q_halt: torch.Tensor,                # (B,)
        q_continue: torch.Tensor,            # (B,)
        target_actions: torch.Tensor,        # (B,)
        target_values: torch.Tensor,         # (B,)
        ponder_steps: torch.Tensor,          # (B,) int
        halted: torch.Tensor,                # (B,) bool
    ) -> dict[str, torch.Tensor]:

        device = action_logits.device

        # Action cross-entropy (only on halted steps)
        act_loss = F.cross_entropy(action_logits, target_actions, reduction="none")
        act_loss = (act_loss * halted.float()).mean()

        # Value regression via scalar expectation
        val_pred = value_logits_to_scalar(value_logits)
        val_loss = F.mse_loss(val_pred, target_values.float())

        # ACT halt/continue Q-loss
        halt_target = halted.float()
        halt_loss = F.binary_cross_entropy_with_logits(q_halt, halt_target)

        # Ponder regularisation (encourage fewer steps)
        ponder_cost = ponder_steps.float().mean() * self.cfg.ponder_weight

        total = (
            self.cfg.action_weight * act_loss
            + self.cfg.value_weight * val_loss
            + self.cfg.halt_weight * halt_loss
            + ponder_cost
        )

        return {
            "loss":        total,
            "act_loss":    act_loss,
            "val_loss":    val_loss,
            "halt_loss":   halt_loss,
            "ponder_cost": ponder_cost,
        }


# ─── Regularisation helpers ───────────────────────────────────────────────────

def kl_reg_loss(
    current_logits: torch.Tensor,
    anchor_logits: torch.Tensor,
) -> torch.Tensor:
    """
    KL(current || anchor) — used as TTT regulariser to prevent catastrophic forgetting.
    Both tensors on same device (caller's responsibility).
    """
    p = F.softmax(anchor_logits.detach(), dim=-1)
    q_log = F.log_softmax(current_logits, dim=-1)
    return F.kl_div(q_log, p, reduction="batchmean")


def mse_anchor_reg(
    current: torch.Tensor,
    anchor: torch.Tensor,
    weight: float = 0.1,
) -> torch.Tensor:
    """
    MSE regularisation toward anchor predictions (TTT stability).
    Anchor detached — no gradient through anchor.
    """
    return weight * F.mse_loss(current, anchor.detach())
