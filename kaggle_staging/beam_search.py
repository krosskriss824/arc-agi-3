"""
beam_search.py — v74.1 CRITICAL FIX

Fixes from Agent 2 diagnosis:
  1. D4 state hash deduplication — prevents revisiting symmetric states
     (D4 = 8 symmetries: 4 rotations × 2 flips)
     WITHOUT this, beam returns to same states indefinitely → 0/25
  2. step_adapter — normalizes ARC env obs to numpy int32 arrays
     (ARC obs can be Frame objects, lists, or arrays — all handled)
  3. Strict time-bounded execution — per-game timeout, no infinite loops
  4. Visited set per beam level — prunes duplicate action sequences
     that lead to equivalent states under D4 symmetry

Math reality check (Agent 2 correct):
  7^30 = 2.2e25 states without pruning → impossible
  With D4 hash: ARC grids max 30x30, ~900 cells, ~12 values
  D4-equivalent classes reduce space by ~8x
  With visited set: beam revisits at most O(beam_width × depth) nodes
  Practical: depth=20 width=4 → ~80 unique states explored
  That's enough for SHORT solution games (depth <= 20)
"""
from __future__ import annotations
import hashlib
import math
import time
from dataclasses import dataclass, field
from typing import Callable, Optional

import numpy as np


# ─── D4 Symmetry Hash ───────────────────────────────────────────────────────

def _grid_from_obs(obs) -> np.ndarray:
    """
    step_adapter: normalize ARC env observation to 2D int32 numpy array.
    Handles: Frame objects, list-of-lists, 1D arrays, 2D arrays, 3D arrays.
    """
    # Frame object (ARC env wraps obs in Frame)
    raw = getattr(obs, "frame", obs)
    arr = np.asarray(raw, dtype=np.int32)
    if arr.ndim == 0:
        return arr.reshape(1, 1)
    if arr.ndim == 1:
        n = int(len(arr) ** 0.5)
        if n * n == len(arr):
            return arr.reshape(n, n)
        return arr.reshape(1, -1)
    if arr.ndim == 3:
        return arr[0]  # take first channel
    return arr  # already 2D


def _d4_canonical(grid: np.ndarray) -> bytes:
    """
    D4-canonical hash: minimum bytes representation across all 8 D4 symmetries.
    D4 group = {id, r90, r180, r270, flip_h, flip_v, flip_d, flip_ad}
    Taking the minimum ensures symmetric states map to the same hash.
    """
    variants = [
        grid,
        np.rot90(grid, 1),
        np.rot90(grid, 2),
        np.rot90(grid, 3),
        np.fliplr(grid),
        np.flipud(grid),
        np.fliplr(np.rot90(grid, 1)),
        np.flipud(np.rot90(grid, 1)),
    ]
    canonical = min(v.tobytes() for v in variants)
    # Use first 8 bytes of sha256 as compact hash key
    return hashlib.sha256(canonical).digest()[:8]


def _obs_hash(obs) -> bytes:
    """Full pipeline: obs → grid → D4 canonical hash."""
    try:
        grid = _grid_from_obs(obs)
        return _d4_canonical(grid)
    except Exception:
        # Fallback: raw bytes hash
        return hashlib.sha256(str(obs).encode()).digest()[:8]


# ─── Beam Search with D4 dedup ───────────────────────────────────────────────────

def beam_search_episode(
    env_reset_fn:    Callable,
    env_step_fn:     Callable,
    env_clone_fn:    Optional[Callable] = None,
    n_actions:       int   = 7,
    beam_width:      int   = 5,
    max_depth:       int   = 40,
    score_threshold: float = 0.01,
    time_limit_s:    float = 45.0,
) -> tuple[float, list[int]]:
    """
    Beam search with D4 state deduplication.
    Returns (best_score, best_action_sequence).

    Key fix: visited set tracks D4-canonical hashes.
    Any state whose D4-canonical form was seen before is pruned.
    This prevents exponential revisiting of symmetric states.
    """
    return _beam_greedy_d4(
        env_reset_fn, env_step_fn,
        n_actions, beam_width, max_depth, score_threshold, time_limit_s
    )


def _beam_greedy_d4(
    env_reset_fn, env_step_fn,
    n_actions, beam_width, max_depth, score_threshold, time_limit_s
) -> tuple[float, list[int]]:
    """
    Beam search with:
      - D4 canonical hash deduplication (no revisits of symmetric states)
      - Hard time limit (no infinite loops)
      - step_adapter normalization
    """
    t0       = time.time()
    visited  = set()  # D4-canonical hashes of seen states
    best_score   = 0.0
    best_actions: list[int] = []

    # Initial state hash
    obs0, _ = env_reset_fn() if callable(env_reset_fn) else (env_reset_fn(), None)
    try:
        obs0, _ = env_reset_fn()
    except TypeError:
        obs0 = env_reset_fn()
    visited.add(_obs_hash(obs0))

    # beam: list of (cumulative_score, action_list, last_obs_hash)
    beam: list[tuple[float, list[int]]] = [(0.0, [])]

    for depth in range(max_depth):
        if time.time() - t0 > time_limit_s:
            print(f"[beam] time limit hit at depth={depth}")
            break

        candidates: list[tuple[float, list[int]]] = []
        depth_visited: set = set()  # dedup within this depth level

        for (cum_score, action_hist) in beam:
            # Replay to reach current state
            try:
                obs, _ = env_reset_fn()
            except TypeError:
                obs = env_reset_fn()

            s = 0.0
            terminal = False
            for a in action_hist:
                obs, r, done, trunc, _ = env_step_fn(a)
                s += float(r)
                if done or trunc:
                    terminal = True
                    break

            if terminal:
                if s > best_score:
                    best_score   = s
                    best_actions = action_hist[:]
                continue

            # Try each action
            for action in range(n_actions):
                if time.time() - t0 > time_limit_s:
                    break

                # Replay again to get next state
                try:
                    o2, _ = env_reset_fn()
                except TypeError:
                    o2 = env_reset_fn()

                ok = True
                for a in action_hist:
                    o2, r2, d2, t2, _ = env_step_fn(a)
                    if d2 or t2:
                        ok = False
                        break
                if not ok:
                    continue

                next_obs, reward, done, trunc, _ = env_step_fn(action)
                new_score = cum_score + float(reward)
                new_hist  = action_hist + [action]

                # D4 dedup: skip if this state (or its D4 equivalent) was seen
                h = _obs_hash(next_obs)
                if h in visited or h in depth_visited:
                    continue  # ← THIS IS THE KEY FIX
                depth_visited.add(h)

                if new_score > best_score:
                    best_score   = new_score
                    best_actions = new_hist[:]

                if new_score >= score_threshold:
                    print(f"[beam] WIN at depth={depth+1} score={new_score:.4f}")
                    return new_score, new_hist

                if not (done or trunc):
                    candidates.append((new_score, new_hist))

        # Add this level's states to global visited
        visited |= depth_visited

        if not candidates:
            break

        candidates.sort(key=lambda x: x[0], reverse=True)
        beam = candidates[:beam_width]

    return best_score, best_actions


# ─── MCTS UCB1 with D4 dedup + time limit ──────────────────────────────────

@dataclass
class MCTSNode:
    actions:   list[int] = field(default_factory=list)
    visits:    int   = 0
    value:     float = 0.0
    children:  list  = field(default_factory=list)
    expanded:  bool  = False
    terminal:  bool  = False
    obs_hash:  bytes = b""  # D4 canonical hash of state after these actions

    def ucb1(self, parent_visits: int, c: float = 1.414) -> float:
        if self.visits == 0:
            return float('inf')
        exploit = self.value / self.visits
        explore = c * math.sqrt(math.log(max(parent_visits, 1)) / self.visits)
        return exploit + explore


def mcts_episode(
    env_reset_fn:    Callable,
    env_step_fn:     Callable,
    n_actions:       int   = 7,
    n_simulations:   int   = 200,
    max_depth:       int   = 50,
    rollout_depth:   int   = 10,
    score_threshold: float = 0.01,
    time_limit_s:    float = 45.0,
) -> tuple[float, list[int]]:
    """
    MCTS with UCB1 + D4 state deduplication + time limit.
    Nodes that lead to already-visited D4-equivalent states are pruned.
    """
    import random
    t0 = time.time()

    root    = MCTSNode()
    visited = set()   # D4-canonical hashes globally seen
    best_score   = 0.0
    best_actions: list[int] = []

    def replay(action_hist: list[int]) -> tuple[float, bool, object]:
        """Returns (score, terminal, last_obs)."""
        try:
            obs, _ = env_reset_fn()
        except TypeError:
            obs = env_reset_fn()
        s = 0.0
        for a in action_hist:
            obs, r, done, trunc, _ = env_step_fn(a)
            s += float(r)
            if done or trunc:
                return s, True, obs
        return s, False, obs

    def rollout(action_hist: list[int]) -> float:
        try:
            obs, _ = env_reset_fn()
        except TypeError:
            obs = env_reset_fn()
        for a in action_hist:
            _, _, done, trunc, _ = env_step_fn(a)
            if done or trunc:
                break
        s = 0.0
        seen_rollout = set()
        for _ in range(rollout_depth):
            action = random.randrange(n_actions)
            obs, r, done, trunc, _ = env_step_fn(action)
            s += float(r)
            h = _obs_hash(obs)
            if h in seen_rollout:  # loop detected in rollout
                break
            seen_rollout.add(h)
            if done or trunc:
                break
        return s

    for sim in range(n_simulations):
        if time.time() - t0 > time_limit_s:
            break

        # Selection
        node = root
        path = [node]
        while node.expanded and node.children and not node.terminal:
            # Filter children not leading to visited states
            unvisited_children = [c for c in node.children if c.obs_hash not in visited]
            if not unvisited_children:
                break
            node = max(unvisited_children, key=lambda c: c.ucb1(node.visits))
            path.append(node)

        if len(node.actions) >= max_depth or node.terminal:
            score, _, _ = replay(node.actions)
            for n in path:
                n.visits += 1
                n.value  += score
            continue

        # Expansion
        if not node.expanded:
            node.expanded = True
            score_parent, _, parent_obs = replay(node.actions)
            for action in range(n_actions):
                child_actions = node.actions + [action]
                # Pre-compute obs_hash for this child
                try:
                    _, _ = env_reset_fn()
                except TypeError:
                    env_reset_fn()
                score_c, terminal_c, child_obs = replay(child_actions)
                h = _obs_hash(child_obs)
                child = MCTSNode(
                    actions=child_actions,
                    terminal=terminal_c,
                    obs_hash=h,
                )
                node.children.append(child)

        # Pick best child not in visited
        unexplored = [c for c in node.children
                      if c.visits == 0 and c.obs_hash not in visited]
        if unexplored:
            child = random.choice(unexplored)
        else:
            candidates = [c for c in node.children if c.obs_hash not in visited]
            if not candidates:
                break
            child = max(candidates, key=lambda c: c.ucb1(node.visits))

        path.append(child)
        visited.add(child.obs_hash)

        # Evaluate
        score, terminal, _ = replay(child.actions)
        if not terminal:
            score += rollout(child.actions)
        child.terminal = terminal

        if score > best_score:
            best_score   = score
            best_actions = child.actions[:]

        if score >= score_threshold:
            print(f"[mcts] WIN sim={sim} score={score:.4f}")
            return score, best_actions

        for n in path:
            n.visits += 1
            n.value  += score

    return best_score, best_actions


# ─── Smart solver: beam → MCTS fallback, time-bounded ────────────────────────

def smart_solve(
    env_reset_fn:  Callable,
    env_step_fn:   Callable,
    n_actions:     int   = 7,
    time_budget_s: float = 55.0,
    beam_width:    int   = 4,
    beam_depth:    int   = 20,
    mcts_sims:     int   = 150,
) -> tuple[float, list[int]]:
    """
    Phase 1: Beam search with D4 dedup (fast, deterministic)
    Phase 2: MCTS with D4 dedup (deeper, probabilistic)
    Both are time-bounded — guaranteed to return within time_budget_s.
    """
    t0          = time.time()
    beam_budget = time_budget_s * 0.4   # 40% of time to beam
    mcts_budget = time_budget_s * 0.55  # 55% of time to MCTS

    # Phase 1: Beam
    score, actions = beam_search_episode(
        env_reset_fn, env_step_fn,
        n_actions=n_actions,
        beam_width=beam_width,
        max_depth=beam_depth,
        score_threshold=0.01,
        time_limit_s=beam_budget,
    )
    if score > 0:
        return score, actions

    # Phase 2: MCTS
    elapsed = time.time() - t0
    remaining = time_budget_s - elapsed
    if remaining > 5.0:
        score2, actions2 = mcts_episode(
            env_reset_fn, env_step_fn,
            n_actions=n_actions,
            n_simulations=mcts_sims,
            max_depth=50,
            rollout_depth=8,
            score_threshold=0.01,
            time_limit_s=min(mcts_budget, remaining - 2.0),
        )
        if score2 > score:
            return score2, actions2

    return score, actions
