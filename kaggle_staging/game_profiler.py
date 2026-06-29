"""game_profiler.py — Lightweight game profiler (~300 steps) → decision tree → solver.

FIX v2:
  - _is_win uses step_adapter.is_win (works on both tuple and object returns)
  - profile_game: complex-action guard for Step 0 (uses first simple action or fallback)
  - profile_game: pass x,y=32,32 only for complex actions; simple actions pass nothing
  - repeated_win dedup (set)
"""
import numpy as np
from step_adapter import safe_step, is_win


class GameProfile:
    """Formal profile of an ARC-AGI-3 game. Zero ML, all predicates."""
    __slots__ = ("n_actions", "has_complex", "grid_empty", "has_objects",
                 "n_components", "absorbing", "idempotent", "repeated_win",
                 "dead_actions", "state_changers", "click_actions",
                  "frame_shape", "action_names", "live_click_found", "live_click_xy")
    def __init__(self):
        self.n_actions      = 0
        self.has_complex    = False
        self.grid_empty     = True
        self.has_objects    = False
        self.n_components   = 0
        self.absorbing      = []
        self.idempotent     = []
        self.repeated_win   = []   # deduplicated
        self.dead_actions   = []
        self.state_changers = []
        self.click_actions  = []
        self.frame_shape    = (64, 64)
        self.action_names   = []
        self.live_click_found = False
        self.live_click_xy    = None


# ── Grid helpers ──────────────────────────────────────────────────────────────

def _has_objects(grid):
    if grid is None or grid.size == 0:
        return False
    return bool(np.any(grid > 0))


def _count_components(grid):
    if grid is None or grid.size == 0:
        return 0
    h, w = grid.shape
    visited = np.zeros((h, w), dtype=bool)
    n = 0
    for y in range(h):
        for x in range(w):
            if grid[y, x] > 0 and not visited[y, x]:
                n += 1
                stack = [(y, x)]
                visited[y, x] = True
                while stack:
                    cy, cx = stack.pop()
                    for dy, dx in ((-1,0),(1,0),(0,-1),(0,1)):
                        ny, nx = cy+dy, cx+dx
                        if 0<=ny<h and 0<=nx<w and not visited[ny,nx] and grid[ny,nx]==grid[cy,cx]:
                            visited[ny, nx] = True
                            stack.append((ny, nx))
    return n


def _get_grid(result):
    """Extract int32 2D grid from StepResult or raw frame."""
    if result is None:
        return None
    # StepResult: obs is in .obs
    obs = getattr(result, "obs", result)
    if isinstance(obs, np.ndarray):
        if obs.ndim == 2:
            return obs.astype(np.int32)
        if obs.ndim == 3:
            return obs[0].astype(np.int32)
    if isinstance(obs, dict):
        for k in ("board", "image", "frame", "grid"):
            if k in obs:
                v = np.asarray(obs[k], dtype=np.int32)
                return v[0] if v.ndim == 3 else v
    # Legacy: frame object with .frame attribute
    try:
        fr = getattr(obs, "frame", None)
        if fr is not None:
            arr = np.asarray(fr, dtype=np.int32)
            return arr[0] if arr.ndim == 3 else arr
    except Exception:
        pass
    return None


def _step_any(env, action, x=32, y=32):
    """Step with or without coordinates depending on action complexity."""
    if action.is_complex():
        return safe_step(env, action, x, y)
    return safe_step(env, action)


# ── Profiler ──────────────────────────────────────────────────────────────────

def profile_game(env):
    """Profile a game in ~300 steps. Returns GameProfile."""
    prof    = GameProfile()
    actions = list(env.action_space)
    prof.n_actions    = len(actions)
    prof.action_names = [str(a).split(".")[-1] for a in actions]
    prof.has_complex  = any(a.is_complex() for a in actions)
    prof.click_actions = [i for i, a in enumerate(actions) if a.is_complex()]

    # Pick a safe "probe" action that won't crash (prefer simple)
    simple_actions  = [a for a in actions if not a.is_complex()]
    probe_action    = simple_actions[0] if simple_actions else actions[0]

    # ── Step 0: Analyze initial frame ──
    env.reset()
    frame0 = _step_any(env, probe_action)
    grid0  = _get_grid(frame0)
    prof.frame_shape  = grid0.shape if grid0 is not None else (64, 64)
    prof.grid_empty   = not _has_objects(grid0)
    prof.has_objects  = _has_objects(grid0)
    prof.n_components = _count_components(grid0) if not prof.grid_empty else 0

    # ── Step 0.5: Quick live-click probe ──
    if prof.has_complex and prof.click_actions:
        env.reset()
        baseline   = _step_any(env, probe_action)
        bg         = _get_grid(baseline)
        bh         = hash(bg.tobytes()) if bg is not None else -1
        click_act  = actions[prof.click_actions[0]]
        for px, py in [(32,32),(16,16),(48,48),(16,48),(48,16)]:
            env.reset()
            f = safe_step(env, click_act, px, py)
            g = _get_grid(f)
            h = hash(g.tobytes()) if g is not None else -1
            if h != bh and h != -1:
                prof.live_click_found = True
                prof.live_click_xy    = (px, py)
                break

    # ── Step 1: One-step hash + immediate win check ──
    h_after_one    = {}
    repeated_wins  = set()
    for i, a in enumerate(actions):
        env.reset()
        f1 = _step_any(env, a)
        g1 = _get_grid(f1)
        h_after_one[i] = hash(g1.tobytes()) if g1 is not None else -1
        if is_win(f1):
            repeated_wins.add(i)

    # ── Step 2: Dead action detection ──
    env.reset()
    init_frame = _step_any(env, probe_action)
    init_grid  = _get_grid(init_frame)
    init_h     = hash(init_grid.tobytes()) if init_grid is not None else -1
    for i, a in enumerate(actions):
        env.reset()
        fa = _step_any(env, a)
        ga = _get_grid(fa)
        ha = hash(ga.tobytes()) if ga is not None else -1
        if ha == init_h or ha == -1:
            prof.dead_actions.append(i)
        else:
            prof.state_changers.append(i)

    # ── Step 3: Idempotence (a² == a) ──
    for i, a in enumerate(actions):
        env.reset()
        _step_any(env, a)
        f2 = _step_any(env, a)
        g2 = _get_grid(f2)
        h2 = hash(g2.tobytes()) if g2 is not None else -1
        if h2 == h_after_one.get(i) and h2 != -1:
            prof.idempotent.append(i)

    # ── Step 4: Absorbing (b∘a == a for all b tested) ──
    for i in prof.state_changers:
        env.reset()
        fa = _step_any(env, actions[i])
        ga = _get_grid(fa)
        ha = hash(ga.tobytes()) if ga is not None else -1
        all_absorb = True
        for j in range(min(prof.n_actions, 4)):  # cap at 4 to limit budget
            if i == j:
                continue
            env.reset()
            _step_any(env, actions[j])
            fb = _step_any(env, actions[i])
            gb = _get_grid(fb)
            hb = hash(gb.tobytes()) if gb is not None else -1
            if hb != ha:
                all_absorb = False
                break
        if all_absorb:
            prof.absorbing.append(i)

    # ── Step 5: Repeated win (budget-capped) ──
    _budget = min(200, 40 * prof.n_actions)
    for i, a in enumerate(actions):
        if _budget <= 0:
            break
        if i in repeated_wins:
            continue
        env.reset()
        per_action = max(1, _budget // max(1, prof.n_actions - i))
        for k in range(per_action):
            nf = _step_any(env, a)
            if is_win(nf):
                repeated_wins.add(i)
                break
            _budget -= 1

    prof.repeated_win = list(repeated_wins)
    return prof


# ── Strategy signature ────────────────────────────────────────────────────────

def compute_signature(prof):
    n = max(1, prof.n_actions)
    return {
        "n_actions":          prof.n_actions,
        "has_complex":        prof.has_complex,
        "action_efficiency":  round(len(prof.state_changers) / n, 2),
        "grid_empty":         prof.grid_empty,
        "n_absorbing":        len(prof.absorbing),
        "dead_ratio":         round(len(prof.dead_actions) / n, 2),
        "n_simple":           sum(1 for _ in prof.click_actions),
        "live_click_found":   prof.live_click_found,
    }


def signature_key(sig):
    parts = []
    for k in ["n_actions","has_complex","action_efficiency",
              "grid_empty","n_absorbing","dead_ratio","n_simple","live_click_found"]:
        parts.append(f"{k}={sig[k]}")
    return "|".join(parts)


class StrategyCache:
    def __init__(self, data=None):
        self._data = data or {}

    def lookup(self, sig):
        return self._data.get(signature_key(sig))

    def store(self, sig, solver_name, solved, n_actions):
        k = signature_key(sig)
        existing = self._data.get(k)
        entry = {"solver": solver_name, "solved": solved, "n_actions": n_actions}
        if existing is None or (solved and not existing.get("solved")):
            self._data[k] = entry
        elif solved and n_actions < existing.get("n_actions", 9999):
            self._data[k] = entry

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


def choose_solver(prof, cache=None):
    sig    = compute_signature(prof)
    cached = cache.lookup(sig) if cache else None
    if cached and cached.get("solved"):
        return {"name": cached["solver"], "max_steps": 1500, "use_segment_fallback": True}
    has_c = prof.has_complex
    lcf   = prof.live_click_found
    decision = {
        (False, False): {"name": "simple_brute",  "max_steps": 1500, "use_segment_fallback": False},
        (False, True):  {"name": "simple_brute",  "max_steps": 1500, "use_segment_fallback": False},
        (True,  True):  {"name": "graph_explore", "max_steps": 2000, "use_segment_fallback": True},
        (True,  False): {"name": "dense_explore", "max_steps": 2000, "use_segment_fallback": True},
    }
    return decision.get((has_c, lcf), {"name": "fallback", "max_steps": 500, "use_segment_fallback": False})


def solve_repeated_action(env, strategy, act_list):
    for _a_idx in strategy["indices"]:
        env.reset()
        _ga = act_list[_a_idx]
        for _k in range(strategy["max_steps"]):
            _nf = _step_any(env, _ga)
            if _nf is None:
                break
            if is_win(_nf):
                return [_a_idx] * (_k + 1)
    return None
