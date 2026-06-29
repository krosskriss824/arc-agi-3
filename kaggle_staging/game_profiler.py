"""game_profiler.py v2 — uses step_adapter StepResult; is_win fixed for tuple API."""
import numpy as np
from step_adapter import safe_step, is_win, get_obs


class GameProfile:
    __slots__ = ("n_actions", "has_complex", "grid_empty", "has_objects",
                 "n_components", "absorbing", "idempotent", "repeated_win",
                 "dead_actions", "state_changers", "click_actions",
                 "frame_shape", "action_names", "live_click_found", "live_click_xy")
    def __init__(self):
        self.n_actions = 0; self.has_complex = False; self.grid_empty = True
        self.has_objects = False; self.n_components = 0; self.absorbing = []
        self.idempotent = []; self.repeated_win = []; self.dead_actions = []
        self.state_changers = []; self.click_actions = []; self.frame_shape = (64, 64)
        self.action_names = []; self.live_click_found = False; self.live_click_xy = None


def _has_objects(grid):
    return grid is not None and grid.size > 0 and bool(np.any(grid > 0))


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
                stack = [(y, x)]; visited[y, x] = True
                while stack:
                    cy, cx = stack.pop()
                    for dy, dx in ((-1,0),(1,0),(0,-1),(0,1)):
                        ny, nx = cy+dy, cx+dx
                        if 0<=ny<h and 0<=nx<w and not visited[ny,nx] and grid[ny,nx]==grid[cy,cx]:
                            visited[ny,nx] = True; stack.append((ny,nx))
    return n


def _grid_hash(result):
    g = get_obs(result)
    return hash(g.tobytes()) if g is not None else -1


def profile_game(env):
    prof = GameProfile()
    actions = list(env.action_space)
    prof.n_actions = len(actions)
    prof.action_names = [str(a).split('.')[-1] for a in actions]
    prof.has_complex = any(a.is_complex() for a in actions)
    prof.click_actions = [i for i, a in enumerate(actions) if a.is_complex()]

    # Initial grid via action[0]
    env.reset()
    r0 = safe_step(env, actions[0], 32, 32)
    g0 = get_obs(r0)
    prof.frame_shape  = g0.shape if g0 is not None else (64, 64)
    prof.grid_empty   = not _has_objects(g0)
    prof.has_objects  = _has_objects(g0)
    prof.n_components = _count_components(g0) if not prof.grid_empty else 0

    # Live-click probe
    if prof.has_complex:
        env.reset()
        base = safe_step(env, actions[0], 32, 32)
        bh   = _grid_hash(base)
        ca   = actions[prof.click_actions[0]]
        for px, py in [(32,32),(16,16),(48,48),(16,48),(48,16)]:
            env.reset()
            f = safe_step(env, ca, px, py)
            h = _grid_hash(f)
            if h != bh and h != -1:
                prof.live_click_found = True; prof.live_click_xy = (px, py); break

    # One-step hashes + immediate win
    h_one = {}
    for i, a in enumerate(actions):
        env.reset()
        f = safe_step(env, a, 32, 32)
        h_one[i] = _grid_hash(f)
        if is_win(f): prof.repeated_win.append(i)

    # Dead action detection
    env.reset()
    init_h = _grid_hash(safe_step(env, actions[0], 32, 32))
    for i, a in enumerate(actions):
        env.reset()
        f = safe_step(env, a, 32, 32)
        h = _grid_hash(f)
        if h == init_h or h == -1: prof.dead_actions.append(i)
        else: prof.state_changers.append(i)

    # Idempotence check
    for i, a in enumerate(actions):
        env.reset()
        safe_step(env, a, 32, 32)
        f2 = safe_step(env, a, 32, 32)
        if _grid_hash(f2) == h_one.get(i) and h_one.get(i) != -1:
            prof.idempotent.append(i)

    # Absorbing check
    for i in prof.state_changers:
        env.reset()
        fa = safe_step(env, actions[i], 32, 32)
        ha = _grid_hash(fa)
        all_abs = True
        for j in range(prof.n_actions):
            if i == j: continue
            env.reset()
            safe_step(env, actions[j], 32, 32)
            fb = safe_step(env, actions[i], 32, 32)
            if _grid_hash(fb) != ha: all_abs = False; break
        if all_abs: prof.absorbing.append(i)

    # Repeated win (multi-step)
    budget = min(300, 100 * prof.n_actions)
    for i, a in enumerate(actions):
        if budget <= 0: break
        if i in prof.repeated_win: continue
        env.reset()
        for k in range(1, min(100, max(1, budget // max(1, prof.n_actions - i))) + 1):
            f = safe_step(env, a, 32, 32)
            if is_win(f): prof.repeated_win.append(i); break
        budget -= k

    return prof


def compute_signature(prof):
    n = max(1, prof.n_actions)
    return {
        "n_actions":        prof.n_actions,
        "has_complex":      prof.has_complex,
        "action_efficiency": round(len(prof.state_changers) / n, 2),
        "grid_empty":       prof.grid_empty,
        "n_absorbing":      len(prof.absorbing),
        "dead_ratio":       round(len(prof.dead_actions) / n, 2),
        "n_simple":         len(prof.click_actions),
        "live_click_found": prof.live_click_found,
    }


def signature_key(sig):
    return "|".join(f"{k}={sig[k]}" for k in
        ["n_actions","has_complex","action_efficiency","grid_empty",
         "n_absorbing","dead_ratio","n_simple","live_click_found"])


class StrategyCache:
    def __init__(self, data=None): self._data = data or {}
    def lookup(self, sig): return self._data.get(signature_key(sig))
    def store(self, sig, solver_name, solved, n_actions):
        k = signature_key(sig)
        entry = {"solver": solver_name, "solved": solved, "n_actions": n_actions}
        ex = self._data.get(k)
        if ex is None or (solved and not ex.get("solved")) or \
           (solved and n_actions < ex.get("n_actions", 9999)):
            self._data[k] = entry
    @classmethod
    def from_file(cls, path="strategy_cache.json"):
        try:
            import json
            with open(path) as f: return cls(json.load(f))
        except Exception: return cls()
    def to_file(self, path="strategy_cache.json"):
        import json
        with open(path, "w") as f: json.dump(self._data, f, indent=2)


def choose_solver(prof, cache=None):
    sig = compute_signature(prof)
    cached = cache.lookup(sig) if cache else None
    if cached and cached.get("solved"):
        return {"name": cached["solver"], "max_steps": 1500, "use_segment_fallback": True}
    decision = {
        (False, False): {"name": "simple_brute",  "max_steps": 1500, "use_segment_fallback": False},
        (False, True):  {"name": "simple_brute",  "max_steps": 1500, "use_segment_fallback": False},
        (True,  True):  {"name": "graph_explore", "max_steps": 2000, "use_segment_fallback": True},
        (True,  False): {"name": "dense_explore", "max_steps": 2000, "use_segment_fallback": True},
    }
    return decision.get((prof.has_complex, prof.live_click_found),
                        {"name": "fallback", "max_steps": 500, "use_segment_fallback": False})
