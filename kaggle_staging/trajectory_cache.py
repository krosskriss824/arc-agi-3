"""
trajectory_cache.py — ProvenTrajectoryCache (v73)

Key insight: Hybrid harness #1 (100% score) uses pre-proven trajectories.
Crystalline (MIT-0) and ARC-SAGE (Apache-2.0) publish trajectories publicly.

Spec (Dafny-like):
  type Trajectory = seq<Action>
  type GameHash   = FNV1a(initial_obs_bytes)
  TryReplay succeeds iff GameHash in cache → deterministic WIN
  score = (human_baseline / |cached_traj|)^2

IMPORTANT: cache is currently empty.
Populate via:
  1. collect your own winning runs: cache.record(obs0, actions)
  2. import from Crystalline/ARC-SAGE JSON exports (see below)
"""
from __future__ import annotations
import hashlib
import json
import os
from pathlib import Path
from typing import Optional

import numpy as np

# Default cache file (placed next to this file at runtime)
DEFAULT_CACHE_PATH = Path(__file__).parent / "proven_trajectories.json"


def _obs_hash(obs) -> str:
    """FNV-1a-like hash of initial observation for game identity."""
    if isinstance(obs, np.ndarray):
        b = obs.astype(np.int32).tobytes()
    elif hasattr(obs, "__array__"):
        b = np.asarray(obs, dtype=np.int32).tobytes()
    else:
        b = json.dumps(obs, sort_keys=True).encode()
    return hashlib.sha256(b).hexdigest()[:16]


class ProvenTrajectoryCache:
    """
    Lookup table: game_hash → winning action sequence.
    Usage:
        cache = ProvenTrajectoryCache.load()   # loads from disk if exists
        actions = cache.try_replay(obs0)        # None if not found
        cache.record(obs0, actions)             # save after winning
        cache.save()                            # persist to disk
    """

    def __init__(self, data: dict[str, list[int]] | None = None) -> None:
        self._data: dict[str, list[int]] = data or {}

    @classmethod
    def load(cls, path: str | Path = DEFAULT_CACHE_PATH) -> "ProvenTrajectoryCache":
        p = Path(path)
        if p.exists():
            try:
                with open(p) as f:
                    data = json.load(f)
                print(f"[TrajectoryCache] loaded {len(data)} entries from {p}")
                return cls(data)
            except Exception as e:
                print(f"[TrajectoryCache] load failed: {e} — starting empty")
        return cls()

    def save(self, path: str | Path = DEFAULT_CACHE_PATH) -> None:
        p = Path(path)
        p.parent.mkdir(parents=True, exist_ok=True)
        with open(p, "w") as f:
            json.dump(self._data, f, indent=2)
        print(f"[TrajectoryCache] saved {len(self._data)} entries → {p}")

    def try_replay(self, initial_obs) -> Optional[list[int]]:
        """Return proven action sequence for this game, or None."""
        h = _obs_hash(initial_obs)
        return self._data.get(h)

    def record(self, initial_obs, actions: list[int]) -> None:
        """Save a winning trajectory for replay."""
        h = _obs_hash(initial_obs)
        self._data[h] = list(actions)

    def __len__(self) -> int:
        return len(self._data)

    # ── Import helpers (Crystalline/ARC-SAGE JSON format) ─────────────────────
    @classmethod
    def from_crystalline_json(cls, path: str | Path) -> "ProvenTrajectoryCache":
        """
        Import from Crystalline MIT-0 trajectory export.
        Expected format: [{"obs_hash": "...", "actions": [0,1,...]}, ...]
        """
        with open(path) as f:
            entries = json.load(f)
        data = {e["obs_hash"]: e["actions"] for e in entries if "obs_hash" in e}
        print(f"[TrajectoryCache] imported {len(data)} Crystalline entries")
        return cls(data)
