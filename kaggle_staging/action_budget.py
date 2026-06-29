"""
action_budget.py — ActionBudgetOptimizer (v73)

Key insight: RHAE scores level as (human_baseline / ai_actions)^2
Goal: minimize ai_actions to maximize quadratic score.

Predicates (Dafny-like):
  ActionIsUseful(a, obs_before, obs_after) := obs_after != obs_before
  PruneReplay(traj) removes no-ops → |trimmed| <= |traj|
  QuadraticGain: reducing 20→15 actions (human=10) yields 0.25→0.44 (+0.39)
"""
from __future__ import annotations
from typing import Callable
import numpy as np

# Human baseline speed cutoff: if AI < human * CUTOFF → score ≈ 1.0
# No point optimising further once ai_steps < human_steps * 1.15
SPEEDRUN_CUTOFF = 1.0 / 1.15  # ~0.87


def prune_trajectory(
    traj: list[int],
    step_fn: Callable[[int], tuple],   # (obs, reward, done, truncated, info)
    reset_fn: Callable[[], object],
    eq_fn: Callable[[object, object], bool] | None = None,
) -> list[int]:
    """
    Remove no-op actions from traj by replaying through step_fn.
    Uses env.reset() + step_fn to detect state-invariant actions.

    Invariant: all returned actions satisfy ActionIsUseful.
    Fallback: if replay raises, return original traj unchanged.
    """
    if eq_fn is None:
        def eq_fn(a, b):  # noqa: E306
            if isinstance(a, np.ndarray):
                return np.array_equal(a, b)
            return a == b

    try:
        obs = reset_fn()
        trimmed: list[int] = []
        for action in traj:
            obs_before = obs
            obs_after, _, done, truncated, _ = step_fn(action)
            if not eq_fn(obs_before, obs_after):
                trimmed.append(action)
            obs = obs_after
            if done or truncated:
                break
        return trimmed if trimmed else traj  # safety: never return empty
    except Exception as e:
        print(f"[ActionBudget] prune_trajectory fallback: {e}")
        return traj


def level_score(human_steps: int, ai_steps: int) -> float:
    """RHAE score formula: (human / ai)^2, capped at 1.0."""
    if ai_steps <= 0:
        return 0.0
    return min(1.0, (human_steps / ai_steps) ** 2)


def should_stop_early(step: int, human_estimate: int) -> bool:
    """True when further steps cannot improve score meaningfully."""
    threshold = int(human_estimate / SPEEDRUN_CUTOFF)
    return step >= threshold
