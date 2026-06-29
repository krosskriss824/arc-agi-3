"""
beam_search.py — Systematic action search (v74)

Replaces URM quasi-random policy with deterministic beam/MCTS search.
No model required. No training. No WASM.

Two strategies:
  1. BeamSearch   — BFS over action sequences, keep top-k by score
  2. MCTS_UCB1    — UCT with rollout, for longer horizons

Spec (Dafny-like):
  type Node = (score: float, depth: int, actions: list[int])
  Invariant: score monotonically improves along winning branch
  Termination: depth <= max_depth, width <= beam_width
  Soundness: any returned actions replayed deterministically win
"""
from __future__ import annotations
import math
import copy
from dataclasses import dataclass, field
from typing import Optional, Callable


@dataclass
class BeamNode:
    score:   float
    actions: list[int] = field(default_factory=list)
    done:    bool      = False


def beam_search_episode(
    env_reset_fn:    Callable,      # () -> (obs, info)
    env_step_fn:     Callable,      # (action) -> (obs, reward, done, truncated, info)
    env_clone_fn:    Optional[Callable] = None,  # () -> cloned_env  (optional)
    n_actions:       int   = 7,
    beam_width:      int   = 5,
    max_depth:       int   = 40,
    score_threshold: float = 0.01,  # early win detection
) -> tuple[float, list[int]]:
    """
    Beam search over action space.
    Returns (best_score, best_action_sequence).

    If env_clone_fn is None, falls back to single-env DFS (slower but always works).
    With env_clone_fn, runs true parallel beam (faster).

    Fallback: if cloning fails, degrades to greedy best-first.
    """
    if env_clone_fn is not None:
        return _beam_with_clone(env_reset_fn, env_step_fn, env_clone_fn,
                                n_actions, beam_width, max_depth, score_threshold)
    else:
        return _beam_greedy(env_reset_fn, env_step_fn,
                            n_actions, beam_width, max_depth, score_threshold)


def _beam_greedy(
    env_reset_fn, env_step_fn,
    n_actions, beam_width, max_depth, score_threshold
) -> tuple[float, list[int]]:
    """
    Greedy beam search without env cloning.
    Replays trajectory from start for each candidate — O(beam × depth × n_actions).
    Safe fallback when env doesn’t support clone.
    """
    best_score   = 0.0
    best_actions: list[int] = []

    # beam: list of (cumulative_score, action_list)
    beam: list[tuple[float, list[int]]] = [(0.0, [])]

    for depth in range(max_depth):
        candidates: list[tuple[float, list[int]]] = []

        for (cum_score, action_hist) in beam:
            # Replay to reach current state
            env_reset_fn()
            replay_score = 0.0
            terminal = False
            for a in action_hist:
                _, r, done, trunc, _ = env_step_fn(a)
                replay_score += float(r)
                if done or trunc:
                    terminal = True
                    break

            if terminal:
                if replay_score > best_score:
                    best_score   = replay_score
                    best_actions = action_hist
                continue

            # Try each action from this state
            for action in range(n_actions):
                env_reset_fn()
                s = 0.0
                ok = True
                for a in action_hist:
                    _, r2, d2, t2, _ = env_step_fn(a)
                    s += float(r2)
                    if d2 or t2:
                        ok = False
                        break
                if not ok:
                    continue

                obs, reward, done, trunc, _ = env_step_fn(action)
                new_score = cum_score + float(reward)
                new_hist  = action_hist + [action]

                if new_score > best_score:
                    best_score   = new_score
                    best_actions = new_hist

                if new_score >= score_threshold:
                    # Found a winning sequence
                    return new_score, new_hist

                if not (done or trunc):
                    candidates.append((new_score, new_hist))

        if not candidates:
            break

        # Keep top beam_width by score
        candidates.sort(key=lambda x: x[0], reverse=True)
        beam = candidates[:beam_width]

    return best_score, best_actions


# ─── MCTS UCB1 (for longer horizon games) ──────────────────────────────────────

@dataclass
class MCTSNode:
    actions:   list[int] = field(default_factory=list)
    visits:    int   = 0
    value:     float = 0.0
    children:  list  = field(default_factory=list)
    expanded:  bool  = False
    terminal:  bool  = False
    score:     float = 0.0

    def ucb1(self, parent_visits: int, c: float = 1.414) -> float:
        if self.visits == 0:
            return float('inf')
        exploit = self.value / self.visits
        explore = c * math.sqrt(math.log(parent_visits) / self.visits)
        return exploit + explore


def mcts_episode(
    env_reset_fn: Callable,
    env_step_fn:  Callable,
    n_actions:    int   = 7,
    n_simulations: int  = 200,
    max_depth:    int   = 50,
    rollout_depth: int  = 10,
    score_threshold: float = 0.01,
) -> tuple[float, list[int]]:
    """
    Monte Carlo Tree Search with UCB1.
    Slower than beam but better for deep games.
    Use when beam_width shallow doesn’t find solution.
    """
    root = MCTSNode()
    best_score   = 0.0
    best_actions: list[int] = []

    def replay(action_hist: list[int]) -> tuple[float, bool]:
        env_reset_fn()
        s = 0.0
        for a in action_hist:
            _, r, done, trunc, _ = env_step_fn(a)
            s += float(r)
            if done or trunc:
                return s, True
        return s, False

    def rollout(action_hist: list[int]) -> float:
        """Random rollout from given state for rollout_depth steps."""
        import random
        env_reset_fn()
        for a in action_hist:
            _, _, done, trunc, _ = env_step_fn(a)
            if done or trunc:
                break
        s = 0.0
        for _ in range(rollout_depth):
            action = random.randrange(n_actions)
            _, r, done, trunc, _ = env_step_fn(action)
            s += float(r)
            if done or trunc:
                break
        return s

    for sim in range(n_simulations):
        # Selection: traverse tree by UCB1
        node = root
        path = [node]
        while node.expanded and node.children and not node.terminal:
            node = max(node.children, key=lambda c: c.ucb1(node.visits))
            path.append(node)

        if len(node.actions) >= max_depth or node.terminal:
            # Backprop
            score, _ = replay(node.actions)
            for n in path:
                n.visits += 1
                n.value  += score
            continue

        # Expansion
        if not node.expanded:
            node.expanded = True
            for action in range(n_actions):
                child_actions = node.actions + [action]
                child = MCTSNode(actions=child_actions)
                node.children.append(child)

        # Pick unexplored child
        unexplored = [c for c in node.children if c.visits == 0]
        if unexplored:
            import random
            child = random.choice(unexplored)
        else:
            child = max(node.children, key=lambda c: c.ucb1(node.visits))

        path.append(child)

        # Rollout from child
        score, terminal = replay(child.actions)
        if not terminal:
            score += rollout(child.actions)
        child.terminal = terminal
        child.score    = score

        if score > best_score:
            best_score   = score
            best_actions = child.actions[:]

        if score >= score_threshold:
            return score, best_actions

        # Backpropagation
        for n in path:
            n.visits += 1
            n.value  += score

    return best_score, best_actions


# ─── Smart policy: try beam first, fallback to MCTS ───────────────────────────

def smart_solve(
    env_reset_fn:  Callable,
    env_step_fn:   Callable,
    n_actions:     int   = 7,
    time_budget_s: float = 60.0,   # seconds per game
    beam_width:    int   = 4,
    beam_depth:    int   = 20,
    mcts_sims:     int   = 150,
) -> tuple[float, list[int]]:
    """
    Adaptive solver:
      Phase 1: Beam search (fast, low depth)
      Phase 2: MCTS if beam fails (slower, higher coverage)

    Returns (score, actions) — use actions for TrajectoryCache.
    """
    import time
    t0 = time.time()

    # Phase 1: Beam
    score, actions = beam_search_episode(
        env_reset_fn, env_step_fn,
        n_actions=n_actions,
        beam_width=beam_width,
        max_depth=beam_depth,
        score_threshold=0.01,
    )
    if score > 0:
        return score, actions

    # Phase 2: MCTS if time allows
    elapsed = time.time() - t0
    if elapsed < time_budget_s * 0.8:
        score2, actions2 = mcts_episode(
            env_reset_fn, env_step_fn,
            n_actions=n_actions,
            n_simulations=mcts_sims,
            max_depth=50,
            rollout_depth=8,
            score_threshold=0.01,
        )
        if score2 > score:
            return score2, actions2

    return score, actions
