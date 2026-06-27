"""agent/my_agent.py — ARC-AGI-3 official entry point.

Delegates to VERICODINGAgent (submission_agent.py).
arc_agi.run() calls MyAgent.step(obs) per step.
"""
from __future__ import annotations
import os, sys, numpy as np

_HERE = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.dirname(_HERE)
for _p in [_ROOT, os.path.join(_ROOT, "external", "urm")]:
    if _p not in sys.path:
        sys.path.insert(0, _p)

import torch
from submission_agent import VERICODINGAgent
from wasm_bridge import get_rhae, _HAS_RHAE_WASM

MODEL_DIR = next(
    (p for p in [
        _os.path.join(_os.path.dirname(_HERE), "urm_checkpoint.pt"),
        "/kaggle/input/datasets/krisskey/vericoding-urm/urm_checkpoint.pt",
        "/kaggle/input/vericoding-urm/urm_checkpoint.pt",
    ] if _os.path.exists(p)),
    None
)

class MyAgent:
    """Official ARC-AGI-3 agent. Wraps VERICODINGAgent + URMWMA + RhaeEngine."""

    def __init__(self):
        self._n_actions = 7
        self._agent = VERICODINGAgent("__init__")
        self._step_count = 0
        self._rhae = get_rhae()
        self._wm = getattr(self._agent, "world_model", None)
        if self._wm is not None and MODEL_DIR is not None:
            load_fn = getattr(self._wm, "load_backbone", None) or getattr(self._wm, "loadbackbone", None)
            if load_fn:
                load_fn(str(MODEL_DIR), device="cuda" if torch.cuda.is_available() else "cpu")
                print(f"[MyAgent] backbone loaded from {MODEL_DIR}")
        print(f"[MyAgent] init OK | RHAE_WASM={_HAS_RHAE_WASM} | WM={self._wm is not None}")

    def step(self, observation: dict) -> int:
        """One agent step. Returns action int."""
        self._step_count += 1

        grid = observation.get("grid") or observation.get("frame")
        if grid is None:
            return 0

        grid_np = np.array(grid, dtype=np.int32) if not isinstance(grid, np.ndarray) else grid.astype(np.int32)
        last_action = observation.get("last_action", 0)

        # Delegate to VERICODINGAgent's action selection
        frames = [grid_np]
        act = self._agent.choose_action(frames, None)
        act = max(1, min(int(act), self._n_actions))
        return int(act)

    def reset(self) -> None:
        """Called between games by arc_agi.run()."""
        self._step_count = 0
        self._agent.on_game_start()
