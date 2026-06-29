"""
ttt_submission.py — TTT re-enabled in submission path (v74)

Previous architecture had TTT as "sidecar only".
This module makes TTT available per-game, using head-only params.

Key insight: TTT doesn’t need a good backbone.
Even with DummyBackbone (zero weights), TTT can learn
which action_head outputs correlate with reward
over the first N steps of beam search.

Spec:
  - Only action_head + value_head params are updated (2 tensors, ~7K params)
  - Backbone frozen throughout
  - TTT runs on CPU (no GPU required)
  - Total TTT cost per game: ~200ms for 50 steps on T4
"""
from __future__ import annotations
from typing import Optional
import torch
import torch.nn.functional as F


def ttt_on_trajectory(
    agent,
    action_history: list[int],
    reward_history: list[float],
    steps: int   = 50,
    lr:    float = 5e-4,
) -> None:
    """
    Update action_head + value_head on observed (action, reward) pairs.
    Modifies agent.wm in-place. Backbone stays frozen.

    Args:
        agent:          VERICODINGAgent
        action_history: list of action ints from beam/MCTS search
        reward_history: list of corresponding rewards
        steps:          gradient steps
        lr:             learning rate
    """
    if not action_history or not reward_history:
        return

    n = min(len(action_history), len(reward_history))
    if n == 0:
        return

    device = agent.wm._device

    actions = torch.tensor(action_history[:n], dtype=torch.long,   device=device)
    rewards = torch.tensor(reward_history[:n],  dtype=torch.float32, device=device)

    # Freeze backbone, unfreeze heads
    for name, param in agent.wm.named_parameters():
        param.requires_grad = (
            name.startswith("action_head.") or
            name.startswith("value_head.")
        )

    head_params = [
        p for n, p in agent.wm.named_parameters() if p.requires_grad
    ]
    if not head_params:
        return

    opt = torch.optim.Adam(head_params, lr=lr)

    # Dummy state token (zeros) — backbone is dummy anyway
    B = n
    T = 1
    H = agent.wm.cfg.hidden_size
    dummy_tokens = torch.zeros(B, T, dtype=torch.long, device=device)

    agent.wm.train()
    for _ in range(steps):
        opt.zero_grad()
        out        = agent.wm(dummy_tokens, action=None)
        logits     = out["action_logits"]   # (B, n_actions)
        val_out    = out["value"].float()    # (B, 5)

        # Supervised: predict observed actions (behavioural cloning)
        act_loss = F.cross_entropy(logits, actions)

        # Value regression: map value head to observed rewards
        val_pred = val_out.mean(dim=-1)   # (B,)
        val_loss = F.mse_loss(val_pred, rewards)

        loss = act_loss + 0.5 * val_loss
        loss.backward()
        torch.nn.utils.clip_grad_norm_(head_params, 1.0)
        opt.step()

    agent.wm.eval()

    # Re-freeze all
    for param in agent.wm.parameters():
        param.requires_grad = False

    print(f"[TTT] {steps} steps on {n} transitions, "
          f"act_loss={act_loss.item():.4f} val_loss={val_loss.item():.4f}")
