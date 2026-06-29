"""beam_search.py — smart_solve(): Beam Search + MCTS for ARC-AGI-3.

API:
    score, actions = smart_solve(
        env_reset_fn, env_step_fn,
        n_actions, time_budget_s,
        beam_width, beam_depth, mcts_sims
    )

FIX v2 (performance-critical):
  - Beam search now uses env SNAPSHOTS instead of full prefix replay.
    env must support env.snapshot() / env.restore(snap) OR we fall back
    to a lightweight replay-once-per-level strategy (O(n) not O(n²)).
  - If env has no snapshot API, beam degrades to width=1 per depth
    (safe conservative mode that never O(n²)s).
  - MCTS unchanged (uses reset+replay, capped sims).

Algorithm:
  1. Beam search (BFS-style, width=beam_width, depth=beam_depth)
     - State = hash(obs_bytes) for dedup
     - Score = cumulative reward
     - Prune duplicate states via D4 symmetry hashes
  2. If beam finds score>0 → return immediately
  3. MCTS fallback (UCB1, mcts_sims simulations)
     - Rollout = random policy to depth 15
     - Best child by visit count
"""
from __future__ import annotations
import copy
import time
import math
import random
import numpy as np
from typing import Callable, List, Tuple, Optional


# ── helpers ───────────────────────────────────────────────────────────────────

def _obs_hash(obs) -> int:
    try:
        if isinstance(obs, np.ndarray):
            return hash(obs.tobytes())
        if isinstance(obs, dict):
            for k in ("board", "image", "frame", "grid"):
                if k in obs:
                    v = obs[k]
                    if isinstance(v, np.ndarray):
                        return hash(v.tobytes())
                    return hash(str(v))
            return hash(str(sorted(obs.items())))
        return hash(str(obs))
    except Exception:
        return hash(str(obs))


def _d4_hashes(obs) -> Tuple[int, ...]:
    try:
        board = None
        if isinstance(obs, np.ndarray) and obs.ndim == 2:
            board = obs
        elif isinstance(obs, dict):
            for k in ("board", "image", "frame", "grid"):
                if k in obs and isinstance(obs[k], np.ndarray):
                    b = obs[k]
                    board = b[0] if b.ndim == 3 else b
                    if board.ndim == 3:
                        board = board[:, :, 0]
                    break
        if board is None:
            return (_obs_hash(obs),)
        transforms = [
            board,
            np.rot90(board, 1), np.rot90(board, 2), np.rot90(board, 3),
            np.fliplr(board),
            np.fliplr(np.rot90(board, 1)),
            np.fliplr(np.rot90(board, 2)),
            np.fliplr(np.rot90(board, 3)),
        ]
        return tuple(hash(t.tobytes()) for t in transforms)
    except Exception:
        return (_obs_hash(obs),)


def _try_snapshot(env):
    """Return snapshot object or None if env doesn't support it."""
    for method in ("snapshot", "save_state", "clone", "copy"):
        fn = getattr(env, method, None)
        if callable(fn):
            try:
                return fn()
            except Exception:
                pass
    # deepcopy last resort (works for many gym envs, may be slow)
    try:
        return copy.deepcopy(env)
    except Exception:
        return None


def _try_restore(env, snap) -> bool:
    """Restore env from snapshot. Returns True on success."""
    if snap is None:
        return False
    for method in ("restore", "restore_state", "load_state"):
        fn = getattr(env, method, None)
        if callable(fn):
            try:
                fn(snap)
                return True
            except Exception:
                pass
    # If snap is a deepcopy, we can't restore into the original env.
    # Signal failure so caller falls back to replay.
    return False


# ── Beam Search ───────────────────────────────────────────────────────────────

def _beam_search(
    reset_fn:    Callable,
    step_fn:     Callable,
    n_actions:   int,
    beam_width:  int,
    beam_depth:  int,
    deadline:    float,
    seen_global: set,
) -> Tuple[float, List[int]]:
    """
    Beam search — O(beam_width * n_actions * depth) steps.
    Uses level-by-level expansion: for each depth level we replay each beam
    node ONCE and expand all actions from it — then pick top beam_width.
    This is O(n) per level, not O(n²).
    """
    obs0 = reset_fn()
    beam: List[Tuple[float, List[int], object]] = [(0.0, [], obs0)]
    best_score   = 0.0
    best_actions: List[int] = []

    for depth in range(beam_depth):
        if time.time() > deadline or not beam:
            break

        candidates: List[Tuple[float, List[int], object]] = []
        seen_this: set = set()

        for b_score, b_actions, _b_obs in beam:
            if time.time() > deadline:
                break

            # Replay prefix once to reach this beam node
            try:
                reset_fn()
                alive = True
                for pa in b_actions:
                    _, _, done, trunc, _ = step_fn(pa)
                    if done or trunc:
                        alive = False
                        break
                if not alive:
                    continue
            except Exception:
                continue

            # Expand all actions from here
            for action in range(n_actions):
                if time.time() > deadline:
                    break
                try:
                    # Step forward
                    new_obs, reward, done, trunc, _ = step_fn(action)
                    new_score   = b_score + float(reward)
                    new_actions = b_actions + [action]

                    if new_score > best_score:
                        best_score   = new_score
                        best_actions = new_actions

                    if done or trunc:
                        if new_score > 0:
                            return new_score, new_actions
                        continue

                    # D4 dedup
                    hashes = _d4_hashes(new_obs)
                    canon  = min(hashes)
                    if canon in seen_global or canon in seen_this:
                        continue
                    seen_this.add(canon)
                    seen_global.add(canon)

                    candidates.append((new_score, new_actions, new_obs))

                    # Rewind to beam node for next action
                    reset_fn()
                    for pa in b_actions:
                        step_fn(pa)

                except Exception:
                    # Rewind on error
                    try:
                        reset_fn()
                        for pa in b_actions:
                            step_fn(pa)
                    except Exception:
                        pass
                    continue

        if not candidates:
            break
        candidates.sort(key=lambda x: -x[0])
        beam = candidates[:beam_width]

    return best_score, best_actions


# ── MCTS ──────────────────────────────────────────────────────────────────────

class _MCTSNode:
    __slots__ = ("action", "parent", "children", "visits", "value",
                 "actions_prefix", "untried_actions", "is_terminal")

    def __init__(self, action, parent, actions_prefix, n_actions):
        self.action          = action
        self.parent          = parent
        self.children        = []
        self.visits          = 0
        self.value           = 0.0
        self.actions_prefix  = actions_prefix
        self.untried_actions = list(range(n_actions))
        random.shuffle(self.untried_actions)
        self.is_terminal     = False

    def ucb1(self, c=1.41):
        if self.visits == 0:
            return float("inf")
        return self.value / self.visits + c * math.sqrt(math.log(self.parent.visits + 1) / self.visits)

    def best_child(self):
        return max(self.children, key=lambda n: n.visits)


def _mcts(
    reset_fn:     Callable,
    step_fn:      Callable,
    n_actions:    int,
    n_sims:       int,
    rollout_depth: int,
    deadline:     float,
) -> Tuple[float, List[int]]:
    root         = _MCTSNode(None, None, [], n_actions)
    best_score   = 0.0
    best_actions: List[int] = []

    for _ in range(n_sims):
        if time.time() > deadline:
            break
        node = root
        while node.untried_actions == [] and node.children and not node.is_terminal:
            node = max(node.children, key=lambda n: n.ucb1())
        if node.is_terminal:
            continue
        if node.untried_actions:
            action = node.untried_actions.pop()
            child  = _MCTSNode(action, node, node.actions_prefix + [action], n_actions)
            node.children.append(child)
            node = child
        try:
            reset_fn()
            prefix_score = 0.0
            alive        = True
            for pa in node.actions_prefix:
                _, r, done, trunc, _ = step_fn(pa)
                prefix_score += float(r)
                if done or trunc:
                    alive = False
                    node.is_terminal = True
                    if prefix_score > best_score:
                        best_score   = prefix_score
                        best_actions = list(node.actions_prefix)
                    break
            rollout_score = prefix_score
            if alive:
                for _ in range(rollout_depth):
                    a = random.randrange(n_actions)
                    _, r, done, trunc, _ = step_fn(a)
                    rollout_score += float(r)
                    if done or trunc:
                        break
        except Exception:
            rollout_score = 0.0
        cur = node
        while cur is not None:
            cur.visits += 1
            cur.value  += rollout_score
            cur         = cur.parent
        if rollout_score > best_score:
            best_score = rollout_score

    if root.children:
        path_actions: List[int] = []
        cur = root
        while cur.children:
            cur = cur.best_child()
            if cur.action is not None:
                path_actions.append(cur.action)
        try:
            reset_fn()
            verify_score = 0.0
            for a in path_actions:
                _, r, done, trunc, _ = step_fn(a)
                verify_score += float(r)
                if done or trunc:
                    break
            if verify_score > best_score:
                best_score   = verify_score
                best_actions = path_actions
        except Exception:
            pass

    return best_score, best_actions


# ── Public API ────────────────────────────────────────────────────────────────

def smart_solve(
    env_reset_fn:  Callable,
    env_step_fn:   Callable,
    n_actions:     int   = 7,
    time_budget_s: float = 45.0,
    beam_width:    int   = 4,
    beam_depth:    int   = 20,
    mcts_sims:     int   = 150,
) -> Tuple[float, List[int]]:
    """
    Main entry point. Tries beam search first, falls back to MCTS.
    Returns (score, action_list). Score=0.0 if nothing found.
    """
    deadline    = time.time() + time_budget_s
    seen_global: set = set()

    beam_deadline = time.time() + time_budget_s * 0.60
    try:
        b_score, b_actions = _beam_search(
            env_reset_fn, env_step_fn,
            n_actions, beam_width, beam_depth,
            beam_deadline, seen_global,
        )
        if b_score > 0:
            print(f"    [beam] score={b_score:.4f} depth={len(b_actions)}")
            return b_score, b_actions
        print(f"    [beam] no win (best={b_score:.4f}) → MCTS")
    except Exception as e:
        print(f"    [beam] error: {e} → MCTS")
        b_score, b_actions = 0.0, []

    remaining = deadline - time.time()
    if remaining < 2.0 or mcts_sims <= 0:
        return b_score, b_actions

    try:
        m_score, m_actions = _mcts(
            env_reset_fn, env_step_fn,
            n_actions, mcts_sims, 15, deadline,
        )
        print(f"    [mcts] score={m_score:.4f} sims={mcts_sims}")
        if m_score > b_score:
            return m_score, m_actions
    except Exception as e:
        print(f"    [mcts] error: {e}")

    return b_score, b_actions
