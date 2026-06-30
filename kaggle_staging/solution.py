"""solution.py — VERICODING Deterministic ARC-AGI-3 Submission.

SINGLE FILE, zero local imports. Deterministic (no ML, no MCTS, no random).
Dependencies: arc_agi (Kaggle competition lib), numpy, standard library only.

Architecture:
  Section 1: ARC-AGI-3 Adapter (safe_step, _normalise, is_win)
  Section 2: D4 Zobrist Hash (pure numpy, deterministic)
  Section 3: DenseExplorer (BFS grid scan, 1024 positions)
  Section 4: GraphExplorer (frontier-based DFS, from dolphin-in-a-coma)
  Section 5: Orchestrator (main loop, strategy dispatch)
  Section 6: Entry point

Usage:
  from solution import solve_all
  scores = solve_all()

Output: /kaggle/working/submission.json { "game_id": score, ... }
"""

import os, sys, json, time, gc, traceback
from typing import Optional
from pathlib import Path
import numpy as np

# =============================================================================
# Section 1: ARC-AGI-3 Adapter
# =============================================================================

def safe_step(env, action, x=None, y=None):
    """Execute env.step() respecting ARC-AGI-3 action contract.
    
    Complex actions (ACTION6) ALWAYS require data={"x":..,"y":..}.
    If x or y missing for complex -> return None (fail fast).
    If env.step raises -> return None.
    """
    if action.is_complex():
        if x is None or y is None:
            return None
        try:
            return env.step(action, data={"x": int(x), "y": int(y)})
        except (KeyError, TypeError, AttributeError):
            return None
    return env.step(action)


def is_win(frame):
    """Check if frame indicates a WIN state."""
    s = getattr(frame, "state", None)
    return s is not None and "WIN" in str(s)


def get_action_list(env):
    """Get list of action OBJECTS (not int indices) from environment."""
    for attr in ("actions", "action_space"):
        try:
            raw = getattr(env, attr)
            acts = list(raw.actions if hasattr(raw, "actions") else raw)
            if acts and hasattr(acts[0], "is_complex"):
                return acts
        except Exception:
            continue
    try:
        acts = list(env.action_space)
        if acts:
            return acts  # type: ignore
    except Exception:
        pass
    return []


def _frame_score(f):
    """Extract score from a frame."""
    if f is None:
        return 0.0
    return float(getattr(f, "reward", getattr(f, "score", 0.0)))


def _is_done(f):
    """Check if game is done."""
    if f is None:
        return True
    return bool(getattr(f, "done", False))


# =============================================================================
# Section 2: D4 Zobrist Hash (deterministic, pure numpy)
# =============================================================================
# Ported from MoonBit wasm_bridge/rhae/zobrist.mbt + canon.mbt.
# Uses splitmix64 seeding for deterministic Zobrist table.

_ZOBRIST_SEED = 0x9E3779B97F4A7C15

def _splitmix64_next(state):
    """splitmix64 PRNG step. Returns (next_state, output)."""
    state = np.uint64(state)
    state += np.uint64(0x9E3779B97F4A7C15)
    z = np.uint64(state)
    z = (z ^ (z >> np.uint64(30))) * np.uint64(0xBF58476D1CE4E5B9)
    z = (z ^ (z >> np.uint64(27))) * np.uint64(0x94D049BB133111EB)
    z = z ^ (z >> np.uint64(31))
    return int(state), int(z)


def _make_zobrist_table():
    """Generate 64x64x16 Zobrist hash table (deterministic)."""
    table = np.zeros((64, 64, 16), dtype=np.int64)
    state = _ZOBRIST_SEED
    for r in range(64):
        for c in range(64):
            for col in range(16):
                state, val = _splitmix64_next(state)
                table[r, c, col] = np.int64(val)
    return table


_ZT = _make_zobrist_table()


def grid_hash(grid: np.ndarray) -> int:
    """Raw Zobrist hash of a grid (no D4 canonicalization)."""
    grid = np.asarray(grid, dtype=np.int32)
    h = np.int64(0)
    for r in range(min(64, grid.shape[0])):
        for c in range(min(64, grid.shape[1])):
            col = int(grid[r, c])
            if 0 <= col < 16:
                h ^= _ZT[r, c, col]
    return int(h)


# D4 dihedral transform coordinate maps (precomputed for 64x64)
_D4_COEFFS = [
    # identity
    (lambda r, c: (r, c), 64, 64),
    # rot90
    (lambda r, c: (c, 63 - r), 64, 64),
    # rot180
    (lambda r, c: (63 - r, 63 - c), 64, 64),
    # rot270
    (lambda r, c: (63 - c, r), 64, 64),
    # reflect-h
    (lambda r, c: (r, 63 - c), 64, 64),
    # reflect-v
    (lambda r, c: (63 - r, c), 64, 64),
    # reflect-major-diag
    (lambda r, c: (c, r), 64, 64),
    # reflect-minor-diag
    (lambda r, c: (63 - c, 63 - r), 64, 64),
]


def _apply_d4(grid, idx):
    """Apply D4 transform #idx to a grid. Returns (transformed, out_h, out_w)."""
    fn, _, _ = _D4_COEFFS[idx]
    # Determine output shape from first corner
    tr, tc = fn(0, 0)
    out_h = abs(tr - fn(63, 0)[0]) + 1 if tr != fn(63, 0)[0] else 64
    out_w = abs(tc - fn(0, 63)[1]) + 1 if tc != fn(0, 63)[1] else 64
    out = np.zeros((out_h, out_w), dtype=np.int32)
    for r in range(grid.shape[0]):
        for c in range(grid.shape[1]):
            tr, tc = fn(r, c)
            if 0 <= tr < out_h and 0 <= tc < out_w:
                out[tr, tc] = grid[r, c]
    return out


def d4_canonical_hash(grid: np.ndarray) -> int:
    """D4-canonical Zobrist hash: min over 8 dihedral transforms.
    
    Two grids that are D4-symmetric will have the same canonical hash.
    """
    grid = np.asarray(grid, dtype=np.int32)
    hashes = []
    for i in range(8):
        transformed = _apply_d4(grid, i)
        hashes.append(grid_hash(transformed))
    return min(hashes)


def fast_grid_hash(grid: np.ndarray) -> int:
    """Fast non-canonical grid hash (md5-based, no D4)."""
    import hashlib
    data = np.asarray(grid, dtype=np.int32).tobytes()
    return int(hashlib.md5(data).hexdigest()[:16], 16)


# =============================================================================
# Section 3: DenseExplorer (deterministic BFS, no ML)
# =============================================================================

_ALL_POSITIONS = [(x, y) for y in range(0, 64, 2) for x in range(0, 64, 2)]


class DenseExplorer:
    """Deterministic BFS grid scan explorer.
    
    Phases:
      1. Simple action brute (repeat each simple action 200x)
      2. Dense click scan (1024 positions, stride=2)
      3. Replay BFS from live clicks (reset-replay frontier)
    """
    
    def __init__(self, env, action_list):
        self._env = env
        self._actions = action_list
        self._click_idx = next((i for i, a in enumerate(self._actions) if a.is_complex()), None)
        self._simple_indices = [i for i, a in enumerate(self._actions) if not a.is_complex()]
        self._budget = 0
        self._total_steps = 0
        self.solution = None
        self.live_clicks = []
    
    def _safe_step(self, action_idx, cx=0, cy=0):
        self._total_steps += 1
        return safe_step(self._env, self._actions[action_idx], cx, cy)
    
    def _grid(self, frame):
        fr = getattr(frame, "frame", None)
        if fr is not None and len(fr) > 0:
            return np.asarray(fr[0], dtype=np.int32)
        return np.zeros((64, 64), dtype=np.int32)
    
    def _grid_any(self, obj):
        if isinstance(obj, np.ndarray):
            return obj.astype(np.int32) if obj.ndim == 2 else obj[0].astype(np.int32)
        if isinstance(obj, tuple):
            return self._grid_any(obj[0])
        return self._grid(obj)
    
    # Phase 1: Simple action brute
    def _phase1(self, budget):
        for aidx in self._simple_indices:
            if self._total_steps >= budget:
                return None
            self._env.reset()
            for _k in range(200):
                nf = self._safe_step(aidx)
                if nf is None:
                    break
                if is_win(nf):
                    return [aidx] * (_k + 1)
                if self._total_steps >= budget:
                    break
        return None
    
    # Phase 2: Dense click scan (1024 positions)
    def _phase2(self, max_pos=1024):
        live = []
        self._env.reset()
        if self._simple_indices:
            bf = self._safe_step(self._simple_indices[0])
        else:
            bf = self._safe_step(self._click_idx, 0, 0) if self._click_idx is not None else None
        base_hash = fast_grid_hash(self._grid(bf)) if bf else 0
        
        for pi, (px, py) in enumerate(_ALL_POSITIONS):
            if pi >= max_pos or self._total_steps >= self._budget:
                break
            self._env.reset()
            nf = self._safe_step(self._click_idx, px, py)
            if nf is None:
                continue
            if is_win(nf):
                self.solution = [(self._click_idx, px, py)]
                return "WIN", [(px, py, 0)]
            h = fast_grid_hash(self._grid(nf))
            if h != base_hash:
                live.append((px, py, h))
        return "LIVE" if live else "NONE", live
    
    # Phase 3: BFS from live clicks
    def _phase3(self, live, max_steps):
        if not live:
            return False
        seen = set()
        frontier = []
        for px, py, h in live:
            if h not in seen:
                seen.add(h)
                frontier.append((h, [(self._click_idx, px, py)], [(px, py)]))
        explored = set(seen)
        
        while frontier and self._total_steps < max_steps:
            frontier.sort(key=lambda n: len(n[1]))
            cur_h, prefix, xy_list = frontier.pop(0)
            self._env.reset()
            ok = True
            for aidx, cx, cy in prefix:
                if self._safe_step(aidx, cx, cy) is None:
                    ok = False
                    break
            if not ok:
                continue
            
            for aidx in self._simple_indices:
                if self._total_steps >= max_steps:
                    return self.solution is not None
                nf = self._safe_step(aidx)
                if nf is None:
                    continue
                if is_win(nf):
                    self.solution = [a for a, _, _ in prefix] + [aidx]
                    return True
                nh = fast_grid_hash(self._grid(nf))
                if nh not in explored:
                    explored.add(nh)
                    frontier.append((nh, list(prefix) + [(aidx, 32, 32)], xy_list))
            
            for lcx, lcy in list(dict.fromkeys([(x, y) for x, y, _ in live]))[:10]:
                if self._click_idx is not None:
                    if self._total_steps >= max_steps:
                        break
                    nf = self._safe_step(self._click_idx, lcx, lcy)
                    if nf is None:
                        continue
                    if is_win(nf):
                        self.solution = [a for a, _, _ in prefix] + [(self._click_idx, lcx, lcy)]
                        return True
                    nh = fast_grid_hash(self._grid(nf))
                    if nh not in explored:
                        explored.add(nh)
                        frontier.append((nh, list(prefix) + [(self._click_idx, lcx, lcy)], [(lcx, lcy)]))
        return self.solution is not None
    
    def explore(self, max_steps=2000):
        self._budget = max_steps
        self._total_steps = 0
        self.solution = None
        self.live_clicks = []
        
        if self._simple_indices:
            sol = self._phase1(max_steps)
            if sol:
                self.solution = sol
                return True
        
        if self._click_idx is not None and self._total_steps < self._budget:
            result, data = self._phase2(1024)
            if result == "WIN":
                return True
            if result == "LIVE":
                self.live_clicks = data
        
        if self.live_clicks and self._total_steps < self._budget:
            self._phase3(self.live_clicks, max_steps // 2)
        
        return self.solution is not None


# =============================================================================
# Section 4: Agent Loop (backend fallback)
# =============================================================================

class SimpleAgent:
    """Deterministic action-priority agent (no ML).
    
    Chooses actions in fixed priority order: click positions first (if complex),
    then simple actions in order. No randomness.
    """
    
    def __init__(self, action_list):
        self._actions = action_list
        self._pos_idx = 0
        self._action_idx = 0
        self._all_positions = [(x, y) for y in range(0, 64, 4) for x in range(0, 64, 4)]
        self._click_idx = next((i for i, a in enumerate(self._actions) if a.is_complex()), None)
        self._simple_indices = [i for i, a in enumerate(self._actions) if not a.is_complex()]
    
    def choose_action(self, obs):
        """Pick next action deterministically. Returns (action_idx, x, y) or None."""
        if self._pos_idx < len(self._all_positions) and self._click_idx is not None:
            px, py = self._all_positions[self._pos_idx]
            self._pos_idx += 1
            return (self._click_idx, px, py)
        if self._action_idx < len(self._simple_indices):
            aidx = self._simple_indices[self._action_idx]
            self._action_idx += 1
            return (aidx, 32, 32)
        return None


# =============================================================================
# Section 5: Orchestrator (main loop)
# =============================================================================

def _install_arc_agi():
    """Install arc-agi pip package from best available source."""
    import subprocess
    DS = "/kaggle/input/datasets/krisskey/vericoding-urm"
    
    # Tier 1: bundled wheels in dataset
    if os.path.isdir(DS):
        whl_files = [os.path.join(DS, f) for f in ["arc_agi-0.9.8-py3-none-any.whl", "arcengine-0.9.3-py3-none-any.whl"]]
        if all(os.path.exists(f) for f in whl_files):
            for w in whl_files:
                subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", w])
            print("[install] arc-agi from dataset wheels")
            return
    
    # Tier 2: competition mount
    CMP = "/kaggle/input/competitions/arc-prize-2026-arc-agi-3/arc_agi_3_wheels"
    if os.path.isdir(CMP):
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-q",
            "--no-index", f"--find-links={CMP}", "arc-agi"])
        print("[install] arc-agi from competition")
        return
    
    # Tier 3: pip fallback
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "arc-agi"])
    print("[install] arc-agi from pypi")


def frame_score(f) -> float:
    if f is None:
        return 0.0
    return float(getattr(f, "reward", getattr(f, "score", 0.0)))


def is_done(f) -> bool:
    if f is None:
        return True
    return bool(getattr(f, "done", False)) or ("WIN" in str(getattr(f, "state", "")))


def run_episode(agent, env, gid: str) -> tuple[float, str]:
    """Run one game episode with deterministic strategy pipeline.
    
    Strategies (in order):
      0. DenseExplorer (BFS grid scan)
      1. SimpleAgent loop (fallback)
    """
    t0 = time.time()
    strategy = "none"
    total_score = 0.0
    
    try:
        al = get_action_list(env)
        if not al:
            print(f"  [{gid}] ERROR: empty action_list")
            return 0.0, "no_actions"
        
        # Strategy 0: DenseExplorer
        explorer = DenseExplorer(env, al)
        found = explorer.explore(max_steps=5000)
        if found and explorer.solution:
            strategy = "dense"
            env.reset()
            total_score = 0.0
            for item in explorer.solution:
                if isinstance(item, (list, tuple)) and len(item) == 3:
                    aidx, cx, cy = int(item[0]), int(item[1]), int(item[2])
                else:
                    aidx, cx, cy = int(item), 32, 32
                if aidx >= len(al):
                    break
                f = safe_step(env, al[aidx], cx, cy)
                if f is None:
                    break
                total_score += frame_score(f)
                if is_done(f):
                    break
            print(f"  [{gid}] dense WIN sc={total_score:.4f}")
            return total_score, "dense"
        
        # Strategy 1: SimpleAgent fallback loop
        simple_agent = SimpleAgent(al)
        step = 0
        max_steps = 1000
        frame = env.reset()
        score = 0.0
        
        while step < max_steps:
            choice = simple_agent.choose_action(frame)
            if choice is None:
                break
            aidx, cx, cy = choice
            f = safe_step(env, al[aidx], cx, cy)
            if f is None:
                step += 1
                continue
            score += frame_score(f)
            if is_done(f):
                total_score = score
                strategy = "agent"
                print(f"  [{gid}] agent WIN sc={score:.4f} steps={step}")
                return total_score, strategy
            step += 1
        
        # If we get here, no solution found
        if step > 0:
            print(f"  [{gid}] fallback steps={step} sc={score:.4f}")
        
        # One final full-reset agent attempt with steps directly
        env.reset()
        score2 = 0.0
        for _step in range(200):
            choice = simple_agent.choose_action(env)
            if choice is None:
                break
            aidx, cx, cy = choice
            f = safe_step(env, al[aidx], cx, cy)
            if f is None:
                continue
            score2 += frame_score(f)
            if is_done(f):
                print(f"  [{gid}] agent2 WIN sc={score2:.4f}")
                return score2, "agent2"
        
        elapsed = time.time() - t0
        print(f"  [{gid}] no-win ({step}steps {elapsed:.1f}s)")
        return 0.0, "no_solution"
    
    except Exception as e:
        elapsed = time.time() - t0
            print(f"  [{gid}] ERROR {e} ({elapsed:.1f}s)")
            traceback.print_exc()
        return 0.0, "error"


def solve_all() -> dict[str, float]:
    """Main entry point: run all ARC-AGI-3 games, return scores dict."""
    _install_arc_agi()
    
    from arc_agi import Arcade
    
    cfg = {"device": "cpu"}
    print(f"[solver] deterministic mode, device=cpu")
    
    results = {}
    game_list = Arcade.available_environments
    
    if not game_list or len(game_list) == 0:
        # Fallback: scan metadata files manually
        print("[solver] Arcade.available_environments empty, scanning manually...")
        import glob
        meta_files = glob.glob("/kaggle/input/**/*.json", recursive=True)
        game_ids = set()
        for mf in meta_files:
            try:
                with open(mf) as f:
                    md = json.load(f)
                gid = md.get("game_id") or md.get("id")
                if gid and len(str(gid)) > 5:
                    game_ids.add(str(gid))
            except: pass
        if not game_ids:
            print("[solver] FATAL: no games found")
            return {}
        game_list = list(game_ids)
        print(f"[solver] found {len(game_list)} games via metadata scan")
    
    games = sorted(game_list)
    print(f"[solver] {len(games)} games to run")
    
    for gid in games:
        t0 = time.time()
        try:
            env = Arcade.make(gid)
            score, strategy = run_episode(None, env, str(gid))
            env.close()
            gc.collect()
            results[str(gid)] = score
        except Exception as e:
            traceback.print_exc()
            results[str(gid)] = 0.0
            print(f"  [{gid}] FATAL: {e}")
        
        elapsed = time.time() - t0
        print(f"  [{gid}] done ({elapsed:.1f}s)")
    
    solved = sum(1 for v in results.values() if v > 0.0)
    mean = sum(results.values()) / max(1, len(results))
    print(f"[sub] {solved}/{len(results)} solved mean={mean:.4f}")
    
    # Output submission.json
    out_path = "/kaggle/working/submission.json"
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(results, f)
    print(f"[sub] -> {out_path}")
    
    return results


# =============================================================================
# Section 6: Entry point
# =============================================================================

if __name__ == "__main__":
    try:
        scores = solve_all()
        print(f"Done. {sum(1 for v in scores.values() if v > 0.0)}/{len(scores)} solved")
    except Exception as e:
        traceback.print_exc()
        print(f"FATAL: {e}")
