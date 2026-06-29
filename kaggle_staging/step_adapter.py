"""step_adapter.py v2 — Single source of truth for ARC-AGI-3 env.step().

ARC-AGI-3 returns EITHER:
  - object with .reward / .state   (old API / some envs)
  - 5-tuple (obs, reward, done, truncated, info)  (gym API)

This module normalises BOTH into a StepResult namedtuple.
Import this everywhere — never unpack raw env.step() directly.
"""
from typing import NamedTuple, Any, Optional
import numpy as np


class StepResult(NamedTuple):
    obs:       Any
    reward:    float
    done:      bool
    truncated: bool
    info:      dict
    win:       bool = False


def _normalise(raw) -> Optional[StepResult]:
    """Convert raw env.step() output to StepResult. Returns None on error."""
    if raw is None:
        return None
    # Tuple / list  (gym 5-tuple or shorter)
    if isinstance(raw, (tuple, list)):
        n = len(raw)
        if n >= 5:
            obs, reward, done, trunc, info = raw[0], raw[1], raw[2], raw[3], raw[4]
        elif n == 4:
            obs, reward, done, trunc, info = raw[0], raw[1], raw[2], raw[3], {}
        elif n == 3:
            obs, reward, done, trunc, info = raw[0], raw[1], raw[2], False, {}
        else:
            return None
        reward = float(reward)
        done   = bool(done)
        trunc  = bool(trunc)
        win    = done and reward > 0
        if not win and isinstance(info, dict):
            win = "WIN" in str(info.get("state", "")) or bool(info.get("win", False))
        return StepResult(obs, reward, done, trunc, info, win)
    # Object API (legacy)
    try:
        reward = float(getattr(raw, "reward", 0.0))
        state  = str(getattr(raw, "state", ""))
        done   = bool(getattr(raw, "done", False)) or "WIN" in state or "LOSE" in state
        win    = "WIN" in state or (done and reward > 0)
        obs    = getattr(raw, "frame", raw)
        return StepResult(obs, reward, done, False, {}, win)
    except Exception:
        return None


def safe_step(env, action, x=None, y=None) -> Optional[StepResult]:
    """Execute env.step() respecting ARC-AGI-3 action contract.
    Returns normalised StepResult or None on any failure.
    """
    try:
        if hasattr(action, 'is_complex') and action.is_complex():
            if x is None or y is None:
                return None
            raw = env.step(action, data={"x": int(x), "y": int(y)})
        else:
            raw = env.step(action)
        return _normalise(raw)
    except Exception:
        return None


def is_win(result) -> bool:
    """Safe win check on StepResult or raw env output."""
    if result is None:
        return False
    if isinstance(result, StepResult):
        return result.win
    r = _normalise(result)
    return r.win if r else False


def get_reward(result) -> float:
    if result is None:
        return 0.0
    if isinstance(result, StepResult):
        return result.reward
    r = _normalise(result)
    return r.reward if r else 0.0


def get_obs(result):
    """Extract 2D int32 numpy grid from StepResult or raw output."""
    if result is None:
        return None
    obs = result.obs if isinstance(result, StepResult) else getattr(result, 'frame', result)
    if obs is None:
        return None
    frame = getattr(obs, 'frame', obs)
    if isinstance(frame, (list, np.ndarray)):
        arr = np.asarray(frame, dtype=np.int32)
        if arr.ndim == 3:
            return arr[0]
        if arr.ndim == 2:
            return arr
    return None
