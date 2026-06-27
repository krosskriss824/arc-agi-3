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
    env.step(actions[0])  # initialize game
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
            _nf = env.step(a, data={"x": 32, "y": 32} if a.is_complex() else None)
            if _nf is not None and _is_win(_nf):
                prof.repeated_win.append(i)
                break

    return prof


# ── Strategy signature ──

def compute_signature(prof):
    """Compute compact hashable signature for strategy cache.
    
    Keys: n_actions, has_complex, action_efficiency (state_changers / n_actions),
          grid_empty, absorbing_count, dead_ratio, branching_factor
    """
    n = max(1, prof.n_actions)
    return {
        "n_actions": prof.n_actions,
        "has_complex": prof.has_complex,
        "action_efficiency": round(len(prof.state_changers) / n, 2),
        "grid_empty": prof.grid_empty,
        "n_absorbing": len(prof.absorbing),
        "dead_ratio": round(len(prof.dead_actions) / n, 2),
        "n_simple": sum(1 for _ in prof.click_actions),
    }


def signature_key(sig):
    """Deterministic string key from signature dict (cache key)."""
    parts = []
    for k in ["n_actions", "has_complex", "action_efficiency",
              "grid_empty", "n_absorbing", "dead_ratio", "n_simple"]:
        parts.append(f"{k}={sig[k]}")
    return "|".join(parts)


class StrategyCache:
    """Persistent strategy cache: signature_key → best solver + params.
    
    Example: {
        "sig_X": {"solver": "dense_explore", "solved": True, "n_actions": 12},
        "sig_Y": {"solver": "simple_brute", "solved": False, "n_actions": 0},
    }
    """
    def __init__(self, data=None):
        self._data = data or {}
    
    def lookup(self, sig):
        k = signature_key(sig)
        return self._data.get(k)
    
    def store(self, sig, solver_name, solved, n_actions):
        k = signature_key(sig)
        entry = {"solver": solver_name, "solved": solved, "n_actions": n_actions}
        # Only overwrite if better (prev + solved, or if first)
        existing = self._data.get(k)
        if existing is None or (solved and not existing.get("solved")):
            self._data[k] = entry
        elif solved and n_actions < existing.get("n_actions", 9999):
            self._data[k] = entry  # shorter solution = better
    
    @classmethod
    def from_file(cls, path="strategy_cache.json"):
        try:
            import json
            with open(path) as f:
                return cls(json.load(f))
        except Exception:
            return cls()
    
    def to_file(self, path="strategy_cache.json"):
        import json
        with open(path, "w") as f:
            json.dump(self._data, f, indent=2)


# ── Simplified decision tree (3 branches: dense/segment/simple) ──

def choose_solver(prof, cache=None):
    """Uproszczony decision tree: 3 ścieżki.
    
    Returns: {"name": str, "max_steps": int, "use_segment_fallback": bool}
    """
    # 1. Check cache first
    sig = compute_signature(prof)
    cached = cache.lookup(sig) if cache else None
    if cached and cached.get("solved"):
        return {"name": cached["solver"], "max_steps": 1500, "use_segment_fallback": True}
    
    has_c = prof.has_complex
    n = prof.n_actions
    
    # 2. Decision predicates (pure, zero if/elif)
    predicates = [
        # non-complex only → simple brute
        (not has_c,
         {"name": "simple_brute", "max_steps": 1500, "use_segment_fallback": False}),
        # single complex action → dense click (no simple fallback needed)
        (has_c and n == 1,
         {"name": "dense_explore", "max_steps": 1500, "use_segment_fallback": True}),
        # multi-action with complex → dense click first, segment fallback
        (has_c and n >= 2,
         {"name": "dense_explore", "max_steps": 2000, "use_segment_fallback": True}),
    ]
    
    for cond, result in predicates:
        if cond:
            return result
    
    return {"name": "dense_explore", "max_steps": 2000, "use_segment_fallback": True}


# ── Solver stubs (used from notebook) ──

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
