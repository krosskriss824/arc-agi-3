"""game_profiler.py — Lightweight game profiler (~300 steps) → decision tree → solver."""
import numpy as np
from functools import reduce

class GameProfile:
    """Formal profile of an ARC-AGI-3 game. Zero ML, all predicates."""
    __slots__ = ("n_actions", "has_complex", "grid_empty", "has_objects",
                 "n_components", "absorbing", "idempotent", "repeated_win",
                 "dead_actions", "state_changers", "click_actions",
                 "frame_shape", "action_names")
    def __init__(self):
        self.n_actions = 0
        self.has_complex = False
        self.grid_empty = True
        self.has_objects = False
        self.n_components = 0
        self.absorbing = []       # action indices that absorb all prev
        self.idempotent = []      # a∘a = a
        self.repeated_win = []    # action indices that WIN when repeated
        self.dead_actions = []    # actions that produce no state change
        self.state_changers = []  # actions that DO change state
        self.click_actions = []   # indices of complex (click) actions
        self.frame_shape = (64, 64)
        self.action_names = []

# ── Grid predicates ──

def _has_objects(grid):
    """True if grid has any non-zero pixels."""
    if grid is None or grid.size == 0: return False
    return bool(np.any(grid > 0))

def _count_components(grid):
    """Count connected components (non-zero, 4-conn)."""
    if grid is None or grid.size == 0: return 0
    h, w = grid.shape
    visited = np.zeros((h, w), dtype=bool)
    n = 0
    for y in range(h):
        for x in range(w):
            if grid[y, x] > 0 and not visited[y, x]:
                n += 1
                color = grid[y, x]
                stack = [(y, x)]
                visited[y, x] = True
                while stack:
                    cy, cx = stack.pop()
                    for dy, dx in ((-1,0),(1,0),(0,-1),(0,1)):
                        ny, nx = cy+dy, cx+dx
                        if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx] and grid[ny, nx] == color:
                            visited[ny, nx] = True
                            stack.append((ny, nx))
    return n

def _get_grid(frame):
    """Extract int32 grid from any frame format."""
    if isinstance(frame, np.ndarray) and frame.ndim == 2:
        return frame.astype(np.int32)
    try:
        fr = getattr(frame, "frame", None)
        if fr is not None and len(fr) > 0:
            return np.asarray(fr[0], dtype=np.int32)
    except Exception:
        pass
    return None

def _is_win(frame):
    s = getattr(frame, "state", None)
    return s is not None and "WIN" in str(s)

# ── Profiler ──

def profile_game(env):
    """Profile a game in ~300 steps. Returns GameProfile."""
    prof = GameProfile()
    actions = list(env.action_space)
    prof.n_actions = len(actions)
    prof.action_names = [str(a).split(".")[-1] for a in actions]
    prof.has_complex = any(a.is_complex() for a in actions)
    prof.click_actions = [i for i, a in enumerate(actions) if a.is_complex()]

    # ── Step 0: Analyze initial frame ──
    env.reset()
    frame = env.step(actions[0])
    grid = _get_grid(frame)
    prof.frame_shape = grid.shape if grid is not None else (64, 64)
    prof.grid_empty = not _has_objects(grid)
    prof.has_objects = _has_objects(grid)
    prof.n_components = _count_components(grid) if not prof.grid_empty else 0

    # ── Step 1: One-step hash per action ──
    h_after_one = {}
    for i, a in enumerate(actions):
        env.reset()
        f1 = env.step(a, data={"x": 32, "y": 32} if a.is_complex() else None)
        g1 = _get_grid(f1)
        h_after_one[i] = hash(g1.tobytes()) if g1 is not None else -1
        if f1 and _is_win(f1):
            prof.repeated_win.append(i)

    # ── Step 2: Dead action detection (no state change) ──
    init_grid = _get_grid(env.step(actions[0]))
    init_h = hash(init_grid.tobytes()) if init_grid is not None else -1
    for i, a in enumerate(actions):
        env.reset()
        fa = env.step(a, data={"x": 32, "y": 32} if a.is_complex() else None)
        ga = _get_grid(fa)
        ha = hash(ga.tobytes()) if ga is not None else -1
        if ha == init_h or ha == -1:
            prof.dead_actions.append(i)
        else:
            prof.state_changers.append(i)

    # ── Step 3: Idempotence (a² == a) ──
    for i, a in enumerate(actions):
        env.reset()
        env.step(a, data={"x": 32, "y": 32} if a.is_complex() else None)
        f2 = env.step(a, data={"x": 32, "y": 32} if a.is_complex() else None)
        g2 = _get_grid(f2)
        h2a = hash(g2.tobytes()) if g2 is not None else -1
        if h2a == h_after_one.get(i) and h2a != -1:
            prof.idempotent.append(i)

    # ── Step 4: Absorbing (b∘a == a for all b) ──
    for i in prof.state_changers:
        env.reset()
        fa = env.step(actions[i], data={"x": 32, "y": 32} if actions[i].is_complex() else None)
        ga = _get_grid(fa)
        ha = hash(ga.tobytes()) if ga is not None else -1
        all_absorb = True
        for j in range(prof.n_actions):
            if i == j: continue
            env.reset()
            env.step(actions[j], data={"x": 32, "y": 32} if actions[j].is_complex() else None)
            fb = env.step(actions[i], data={"x": 32, "y": 32} if actions[i].is_complex() else None)
            gb = _get_grid(fb)
            hb = hash(gb.tobytes()) if gb is not None else -1
            if hb != ha:
                all_absorb = False
                break
        if all_absorb:
            prof.absorbing.append(i)

    # ── Step 5: Repeated win (up to 100 per action, max total 300) ──
    _budget = min(300, 100 * prof.n_actions)
    for i, a in enumerate(actions):
        if _budget <= 0: break
        env.reset()
        for k in range(1, min(100, _budget // max(1, prof.n_actions - i)) + 1):
            env.step(a, data={"x": 32, "y": 32} if a.is_complex() else None)
            if _is_win(env):
                prof.repeated_win.append(i)
                break

    return prof


# ── Decision tree (dictionary dispatch, zero if/elif in hot path) ──

_SOLVER_REGISTRY = {}

def register_solver(name, fn):
    _SOLVER_REGISTRY[name] = fn

def choose_solver(prof):
    """Pure functional decision tree: profile → solver name + params.
    Returns: {"name": str, "max_steps": int, "action_indices": list}
    """
    n = prof.n_actions
    has_c = prof.has_complex
    empty = prof.grid_empty
    objs = prof.has_objects
    ncomp = prof.n_components
    rw = prof.repeated_win
    state_ch = prof.state_changers
    dead = prof.dead_actions

    # Decision predicates → solver
    predicates = [
        # (condition, solver_name, params)
        (len(rw) > 0,
         "repeated_action", {"max_steps": 200, "indices": rw}),

        (len(prof.absorbing) > 0 and has_c and empty,
         "blind_click", {"max_steps": 1, "indices": prof.absorbing}),

        (len(prof.absorbing) > 0 and not has_c,
         "skip", {"max_steps": 1, "indices": []}),

        (n == 1 and not has_c,
         "repeated_action", {"max_steps": 200, "indices": [0]}),

        (n == 1 and has_c and not empty,
         "click_explore", {"max_steps": 500, "indices": [0]}),

        (n == 1 and has_c and empty,
         "dense_scan", {"max_steps": 500, "indices": [0]}),

        (n >= 2 and has_c and not empty,
         "graph_explore", {"max_steps": 2000}),

        (n >= 2 and has_c and empty,
         "dense_then_graph", {"max_steps": 2000}),

        (n >= 2 and not has_c,
         "repeated_action", {"max_steps": 500, "indices": state_ch or list(range(n))}),

        # Fallback
        (True, "graph_explore", {"max_steps": 2000}),
    ]

    for cond, name, params in predicates:
        if cond:
            return {"name": name, **params}
    return {"name": "graph_explore", "max_steps": 2000}


# ── Solver stubs (registered from notebook) ──

def solve_repeated_action(env, strategy, act_list):
    """Try each action repeatedly up to max_steps."""
    for _a_idx in strategy["indices"]:
        env.reset()
        _ga = act_list[_a_idx]
        for _k in range(strategy["max_steps"]):
            _gd = {"x": 32, "y": 32} if _ga.is_complex() else None
            _nf = env.step(_ga, data=_gd)
            if _nf is None: break
            if _is_win(_nf):
                return [_a_idx] * (_k + 1)
    return None
