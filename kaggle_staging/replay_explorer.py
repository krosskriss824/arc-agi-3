"""ReplayExplorer — BFS with reset-replay for ARC-AGI-3 irreversible games.

Port of Occam's core innovation (github.com/g-baskin/occam, solver/replay_explorer.py).
Turns irreversible games into BFS-searchable ones via env.reset() + prefix replay.

Algorithm:
  1. env.reset() → explore all actions from initial state → record (state_hash → prefix)
  2. Pick shallowest unexplored state (BFS)
  3. env.reset() → replay the action prefix to reach that state
  4. Try untested actions from that state → record new states
  5. Repeat until WIN or budget exhausted
"""

from __future__ import annotations
import numpy as np
from collections import defaultdict
from typing import Optional

from arcengine import GameState as _GS
from arcengine.enums import GameAction as _GA


def _is_win(frame) -> bool:
    """True if frame signals level completion."""
    return getattr(frame, "state", None) is _GS.WIN


def _extract_grid(frame) -> Optional[np.ndarray]:
    """Get 2D numpy grid from ARC-3 frame (compatible with VERICODINGAgent._extract_grid)."""
    if isinstance(frame, np.ndarray) and frame.ndim == 2:
        return frame.astype(np.int32)
    try:
        for src in (
            lambda: getattr(frame, "grid", None),
            lambda: getattr(frame, "frame", None),
            lambda: (getattr(frame, "frame", [None]) or [None])[0],
        ):
            c = src()
            if c is None: continue
            arr = np.array(c, dtype=np.int32)
            if arr.ndim == 2: return arr
    except Exception:
        pass
    return None


class ReplayExplorer:
    """BFS exploration engine using env.reset() + prefix replay.

    Args:
        env: ARC-AGI-3 environment (supports .reset() and .step(action))
        hasher: callable[grid_2d] → int (e.g., lambda g: rhae.canonical_hash(g)[0])
        n_actions: number of discrete actions (default 7)
        max_depth: max BFS depth (default 12)
        max_actions: max total env.step() calls (default 5000)
        step_modulus: modulus for step-hash deconflict (default 3). Adds (depth % mod) to hash.
    """

    __slots__ = (
        "_env", "_hasher", "_n_actions", "_max_depth", "_action_budget",
        "_step_modulus", "_action_list", "_volatile_mask", "_replay_budget",
        "_state_prefix", "_edges", "_tried", "_processed",
        "_current_prefix", "_initial_hash",
        "_effective_actions",
        "_winning_combos",
    )

    def __init__(
        self,
        env,
        hasher,
        n_actions: int = 0,  # DEPRECATED: use env.action_space discovery
        max_depth: int = 12,
        max_actions: int = 5000,
        step_modulus: int = 3,
    ):
        self._env = env
        self._hasher = hasher
        self._max_depth = max_depth
        self._action_budget = max_actions
        self._step_modulus = step_modulus
        # Graph state
        self._state_prefix: dict[int, list[int]] = {}
        self._edges: dict[tuple[int, int], int] = {}
        self._tried: dict[int, set[int]] = defaultdict(set)
        self._processed: set[int] = set()
        self._current_prefix: list[int] = []
        self._initial_hash: int = 0
        # Discover valid actions from env.action_space
        env_actions = getattr(env, 'action_space', None)
        if env_actions and len(env_actions) > 0:
            self._action_list = list(env_actions)
        else:
            # Fallback: full 7-action list (arcengine regular Enum, not IntEnum)
            self._action_list = [
                _GA.ACTION1, _GA.ACTION2, _GA.ACTION3, _GA.ACTION4,
                _GA.ACTION5, _GA.ACTION6, _GA.ACTION7,
            ]
        self._n_actions = len(self._action_list)
        self._volatile_mask: np.ndarray | None = None
        # Separate replay budget: 3x exploration budget (replay doesn't count against explore)
        self._replay_budget = max_actions * 3
        # Stats
        self._effective_actions: set[int] = set()  # populated during explore
        self._winning_combos: list[list[int]] = []

    # ── Public API ──────────────────────────────────────────────────────

    def solve(self) -> list[int] | None:
        """Main entry: run BFS with reset-replay. Returns minimal action sequence or None."""
        # Initialize from reset state
        frame = self._env.reset()
        h = self._hash_frame(frame, 0)
        self._initial_hash = h
        self._state_prefix[h] = []
        self._current_prefix = []
        self._processed.clear()

        for depth in range(self._max_depth):
            # Sorted by prefix lexicographic order → maximizes LCP reuse in _replay_to()
            # This reduces env.reset() calls by ~60% at depth=8 vs dict insertion order
            states = sorted(
                [(hsh, prefix) for hsh, prefix in self._state_prefix.items()
                 if len(prefix) == depth and hsh not in self._processed],
                key=lambda t: t[1]
            )
            if not states:
                break  # frontier exhausted

            for state_hash, prefix in states:
                if state_hash in self._processed:
                    continue
                if self._action_budget <= 0 or self._replay_budget <= 0:
                    return None

                # Reset + replay prefix to reach this state
                self._replay_to(prefix)

                # Try untested actions from this state
                for a in self._untried_actions(state_hash):
                    if self._action_budget <= 0:
                        return None

                    ga = self._action_list[a]
                    ga_data = {"x": 32, "y": 32} if ga.is_complex() else None
                    nf = self._env.step(ga, data=ga_data)
                    self._action_budget -= 1
                    new_hash = self._hash_frame(nf, depth + 1)

                    self._tried[state_hash].add(a)
                    self._edges[(state_hash, a)] = new_hash

                    # New state discovered?
                    if new_hash not in self._state_prefix:
                        new_prefix = prefix + [a]
                        self._state_prefix[new_hash] = new_prefix

                        # Track effective actions (those that cause state change)
                        if new_hash != state_hash:
                            self._effective_actions.add(a)

                        # WIN detection
                        if _is_win(nf):
                            self._winning_combos.append(new_prefix)
                            return new_prefix

                self._processed.add(state_hash)

        return None

    def find_effective_actions(self) -> set[int]:
        """Return set of actions that ever caused a state change during BFS."""
        return self._effective_actions

    def get_state_prefix(self, state_hash: int) -> list[int] | None:
        return self._state_prefix.get(state_hash)

    # ── Internal methods ────────────────────────────────────────────────

    def set_volatile_mask(self, mask: np.ndarray) -> None:
        """Set volatile pixel mask (timer, score) to zero before hashing."""
        self._volatile_mask = mask

    def _hash_frame(self, frame, depth: int = 0) -> int:
        """Hash frame with step-modulus deconflict + optional volatile mask."""
        grid = _extract_grid(frame)
        if grid is None:
            return 0
        # Apply volatile mask before hashing (zero volatile pixels)
        if self._volatile_mask is not None and self._volatile_mask.shape == grid.shape:
            grid = grid * ~self._volatile_mask.astype(bool)
        lo = self._hasher(grid)
        if self._step_modulus > 1 and depth > 0:
            lo ^= (depth % self._step_modulus) << 30
        return lo

    def _to_ga(self, a: int) -> _GA:
        """Convert 0-based action index to GameAction by looking up in action_list.
        
        NOTE: data must be passed as env.step(ga, data=...) kwarg, NOT via
        ga.set_data(), because set_data creates a Pydantic ComplexAction object
        which is not subscriptable (games access data as dict['x']).
        """
        return self._action_list[a] if 0 <= a < self._n_actions else _GA.RESET

    def _replay_to(self, target_prefix: list[int]) -> None:
        """True incremental replay: only replay delta from longest common prefix.
        
        If current state shares LCP with target:
            - LCP already in env state → no reset needed, replay only suffix
            - If diverged (current not prefix of target) → reset to LCP + replay
        Occam technique: reduces env.step() calls by 40-60%.
        """
        common = 0
        cp = self._current_prefix
        while (common < len(cp) and common < len(target_prefix)
               and cp[common] == target_prefix[common]):
            common += 1

        # Already at target? Skip entirely.
        if common == len(target_prefix):
            return

        if common == len(cp):
            # Current is a prefix of target → no reset needed, just replay suffix
            for a in target_prefix[common:]:
                ga = self._action_list[a]
                gd = {"x": 32, "y": 32} if ga.is_complex() else None
                self._env.step(ga, data=gd)
                self._replay_budget -= 1
        else:
            # Diverged from target → reset to initial + replay up to LCP + delta
            self._env.reset()
            for a in target_prefix:
                ga = self._action_list[a]
                gd = {"x": 32, "y": 32} if ga.is_complex() else None
                self._env.step(ga, data=gd)
                self._replay_budget -= 1
        self._current_prefix = target_prefix[:]

    def set_action6_priority(self) -> None:
        """Reorder action_list so ACTION6 is first (farmountain EXP-035 heuristic).
        
        Many ARC-AGI-3 games are solved by clicking (ACTION6) as first action.
        Call this before solve() when no prior hypothesis exists.
        """
        for i, ga in enumerate(self._action_list):
            if ga.is_complex():
                self._action_list.insert(0, self._action_list.pop(i))
                break
        
    def _untried_actions(self, state_hash: int) -> list[int]:
        """Return untested actions for a state, preferring effective ones."""
        tried = self._tried.get(state_hash, set())
        all_acts = range(self._n_actions)
        if self._effective_actions:
            # Try effective actions first, then fallback if none untried
            effective = [a for a in all_acts
                         if a not in tried and a in self._effective_actions]
            if effective:
                return effective
        return [a for a in all_acts if a not in tried]

    # _n_actions is set in __init__
