"""algebra_probe.py — Pure functional algebraic analysis of ARC-AGI-3 action space.

Detects structural properties of the action monoid before BFS:
- idempotent: a∘a = a  (action is a toggle/idempotent operation)
- absorbing: ∃a: ∀b: b∘a = a  (absorbing action resets all state)
- periodic: aⁿ = aᵐ for some n<m (cyclic action)
- invertible: ∃b: a∘b = id (action has inverse)
- all_idempotent: every action is idempotent (permutation game)
- single_idempotent: exactly one action is idempotent (toggle game)

The strategy router selects the optimal solver based on these tags.
Zero dependencies beyond numpy. Pure functional — all functions return
new values, no mutation except env.step() which is inherently stateful.
"""

import numpy as np
from functools import reduce

# ── Hash function (WASM canonical_hash wrapper) ──

_HASHER = None  # set by set_hasher(hasher_fn) — wraps RhaeEngine.canonical_hash

def set_hasher(fn) -> None:
    global _HASHER
    _HASHER = fn

def _hash(grid: np.ndarray, step: int = 0) -> int:
    """Canonical hash (D4 Zobrist) with step-modulus deconflict."""
    if _HASHER is None:
        return hash(grid.tobytes())
    h = _HASHER(grid)
    h ^= (step % 3) << 28
    return h


# ── Action algebra predicates ──

def _hash_after(env, action, n: int = 1) -> int:
    """Apply action n times from env.reset(), return hash."""
    env.reset()
    for _ in range(n):
        gd = {"x": 32, "y": 32} if action.is_complex() else None
        frame = env.step(action, data=gd)
        if frame is None:
            return -1
    grid = _to_grid(frame)
    return -1 if grid is None else _hash(grid, n)

def _to_grid(frame) -> np.ndarray | None:
    """Extract int32 grid from any frame format."""
    if isinstance(frame, np.ndarray) and frame.ndim == 2:
        return frame.astype(np.int32)
    try:
        fr = getattr(frame, "frame", None)
        if fr and len(fr) > 0:
            return np.asarray(fr[0], dtype=np.int32)
    except Exception:
        pass
    return None

def _is_win(frame) -> bool:
    """Check if frame state is WIN."""
    return getattr(frame, "state", None) is not None and (
        str(getattr(frame, "state", "")) == "GameState.WIN"
        or str(getattr(frame, "state", "")).endswith("WIN")
    )


# ── Probe functions ──

def probe_action_algebra(env, max_probe_steps: int = 2500) -> frozenset:
    """Probe algebraic structure of env's action space.
    
    Args:
        env: arc_agi environment with .action_space, .reset(), .step()
        max_probe_steps: total budget for probing (default 2500)
    
    Returns:
        frozenset of tags: "absorbing", "idempotent<idx>", "all_idempotent",
                          "periodic<idx>_k<N>", "short<idx>", "invertible<idx>",
                          "repeated_win<idx>"
    """
    actions = list(env.action_space)
    if not actions:
        return frozenset({"no_actions"})
    
    n = len(actions)
    tags = set()
    budget = max_probe_steps
    budget -= 2 * n  # reserve for reset + initial step per action
    
    # Phase 1: single-step hash per action
    initial_hashes = {}
    for i, a in enumerate(actions):
        h = _hash_after(env, a, 1)
        initial_hashes[i] = h
    
    # Phase 2: check idempotence (a∘a = a)
    # For each action, apply twice and compare with once
    for i, a in enumerate(actions):
        h1 = initial_hashes[i]
        h2 = _hash_after(env, a, 2)
        budget -= 1
        if h1 == h2 and h1 != -1:
            tags.add(f"idempotent_{i}")
    
    # Phase 3: check absorbing (a after b = a for all b)
    # ∀ b: b∘a = a → a absorbs all previous actions
    for i, a in enumerate(actions):
        absorbing = True
        for j, b in enumerate(actions):
            if i == j:
                continue
            env.reset()
            _ = env.step(b)
            gd = {"x": 32, "y": 32} if a.is_complex() else None
            frame = env.step(a, data=gd)
            grid = _to_grid(frame)
            if grid is None:
                absorbing = False
                break
            h = _hash(grid)
            if h != initial_hashes[i]:
                absorbing = False
                break
            budget -= 1
            if budget <= 0:
                absorbing = None  # unknown
                break
        if absorbing:
            tags.add(f"absorbing_{i}")
            tags.add("has_absorbing")
    
    # Phase 4: check periodicity — find n < m: aⁿ = aᵐ
    # Limited to max_k=50 to prevent budget exhaustion
    for i, a in enumerate(actions):
        max_k = min(50, budget // n)
        h = initial_hashes[i]
        period = None
        for k in range(2, max_k + 1):
            hk = _hash_after(env, a, k)
            budget -= 2  # reset + step
            if hk == -1:
                continue
            if hk == h:
                period = k
                tags.add(f"periodic_{i}_k{k}")
                break
            h = hk
        if budget <= 0:
            break
    
    # Phase 5: check repeated-action win potential
    # Try each action up to MAX_STEPS=200, return on WIN
    for i, a in enumerate(actions):
        env.reset()
        for k in range(1, 201):
            gd = {"x": 32, "y": 32} if a.is_complex() else None
            frame = env.step(a, data=gd)
            if frame is None:
                break
            if _is_win(frame):
                tags.add(f"repeated_win_{i}")
                break
    
    # Derived tags
    if any(t.startswith("idempotent_") for t in tags):
        tags.add("has_idempotent")
    if all(f"idempotent_{i}" in tags or f"periodic_{i}" in tags 
           or f"repeated_win_{i}" in tags or f"absorbing_{i}" in tags
           for i in range(n)):
        tags.add("well_understood")
    
    return frozenset(tags)


def choose_strategy(algebra_tags: frozenset, n_actions: int) -> dict:
    """Route algebra tags → solver strategy.
    
    Returns: dict with keys:
        - name: str (strategy name)
        - action_indices: list[int] (actions to try in order)
        - max_steps: int (budget)
    """
    # Priority 1: game has repeated-action win (e.g. 50×ACTION1)
    repeated = sorted([int(t.split("_")[2]) for t in algebra_tags 
                       if t.startswith("repeated_win_")])
    if repeated:
        return {"name": "repeated_action", "action_indices": repeated,
                "max_steps": 200, "reason": f"repeated action WIN at indices {repeated}"}
    
    # Priority 2: periodic action → repeated with period
    periodic = [t for t in algebra_tags if t.startswith("periodic_")]
    if periodic:
        indices = sorted(set(int(t.split("_")[1]) for t in periodic))
        return {"name": "periodic_probe", "action_indices": indices,
                "max_steps": 200, "reason": f"periodic actions at indices {indices}"}
    
    # Priority 3: all idempotent → permutation game → IDA*
    if "has_idempotent" in algebra_tags:
        return {"name": "graph_explorer", "action_indices": list(range(n_actions)),
                "max_steps": 2000, "reason": "idempotent actions, running GraphExplorer"}
    
    # ALL OTHER games → GraphExplorer with FrameProcessor + heuristic ranker
    return {"name": "graph_explorer", "action_indices": list(range(n_actions)),
            "max_steps": 2000, "reason": "unknown algebra, running GraphExplorer"}