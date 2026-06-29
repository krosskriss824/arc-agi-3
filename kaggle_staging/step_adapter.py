"""step_adapter.py — Single source of truth for ARC-AGI-3 env.step().

ARC-AGI-3 contract:
  - Simple actions: env.step(action) — no data dict needed
  - Complex actions (ACTION6): env.step(action, data={"x": int, "y": int}) — ALWAYS required
  - Missing x/y for complex → fail fast (return None), NEVER bare step

FIX v2:
  - safe_step now always returns a normalised StepResult NamedTuple
    (obs, reward, done, truncated, info, state_str)
    so callers can use both .reward/.state AND tuple unpacking.
  - _is_win helper exported here for use in game_profiler.
"""
from typing import NamedTuple, Any, Optional
import numpy as np


class StepResult(NamedTuple):
    obs:       Any
    reward:    float
    done:      bool
    truncated: bool
    info:      Any
    state:     str   # "WIN" | "LOSE" | "" — unified field


def _normalise(raw) -> Optional[StepResult]:
    """Convert any env.step() return into StepResult. Returns None on error."""
    if raw is None:
        return None
    # Already a StepResult
    if isinstance(raw, StepResult):
        return raw
    # Tuple / list (standard Gym API)
    if isinstance(raw, (tuple, list)):
        if len(raw) >= 4:
            obs, reward, done, trunc = raw[0], raw[1], raw[2], raw[3]
            info = raw[4] if len(raw) > 4 else {}
            # Detect WIN from info dict or done flag
            state_str = ""
            if isinstance(info, dict):
                state_str = str(info.get("state", info.get("game_state", "")))
            if done and not state_str:
                state_str = "WIN" if float(reward) > 0 else "LOSE"
            return StepResult(obs, float(reward), bool(done), bool(trunc), info, state_str)
        return None
    # Object with attributes (old ARC-AGI-3 wrapper)
    try:
        obs      = getattr(raw, "observation", getattr(raw, "obs", raw))
        reward   = float(getattr(raw, "reward", 0.0))
        done     = bool(getattr(raw, "done", False))
        trunc    = bool(getattr(raw, "truncated", False))
        info     = getattr(raw, "info", {})
        state_str = str(getattr(raw, "state", ""))
        return StepResult(obs, reward, done, trunc, info, state_str)
    except Exception:
        return None


def is_win(result: Optional[StepResult]) -> bool:
    """True if StepResult represents a WIN."""
    if result is None:
        return False
    return "WIN" in result.state or (result.done and result.reward > 0)


def safe_step(env, action, x=None, y=None) -> Optional[StepResult]:
    """Execute env.step() respecting ARC-AGI-3 action contract.
    Always returns StepResult or None.
    """
    try:
        if action.is_complex():
            if x is None or y is None:
                return None
            raw = env.step(action, data={"x": int(x), "y": int(y)})
        else:
            raw = env.step(action)
        return _normalise(raw)
    except (KeyError, TypeError, AttributeError, Exception):
        return None
