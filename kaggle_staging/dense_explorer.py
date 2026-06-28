"""dense_explorer.py — Dense click scan (32×2=1024 pos) + Replay BFS.

Architecture:
  Phase 1: Simple action brute (200 per action)
  Phase 2: Dense click scan (1024 positions, stride=2)
  Phase 3: Replay BFS from live clicks (reset-replay frontier)
  Phase 4: 1px refinement around unique live click states
"""
import numpy as np
from collections import deque
from step_adapter import safe_step


def _is_win(frame):
    s = getattr(frame, "state", None)
    return s is not None and "WIN" in str(s)


def _get_grid(frame):
    fr = getattr(frame, "frame", None)
    if fr is not None and len(fr) > 0:
        return np.asarray(fr[0], dtype=np.int32)
    return np.zeros((64, 64), dtype=np.int32)


def _grid_hash(grid):
    return hash(grid.tobytes())


_ALL_POSITIONS = [(x, y) for y in range(0, 64, 2) for x in range(0, 64, 2)]


class DenseExplorer:
    """Explorer: dense scan → replay BFS from live clicks."""

    def __init__(self, env, action_list, fp=None, hasher=None):
        self._env = env
        self._actions = action_list
        self._fp = fp
        self._hasher = hasher
        self._click_idx = next((i for i, a in enumerate(self._actions) if a.is_complex()), None)
        self._simple_indices = [i for i, a in enumerate(self._actions) if not a.is_complex()]
        self._budget = 0
        self._total_steps = 0
        self.solution = None
        self.live_clicks = []  # [(x, y, state_hash), ...]

    def _safe_step(self, action_idx, cx=32, cy=32):
        """Step via step_adapter.safe_step (complex=always data, fail-fast)."""
        self._total_steps += 1
        return safe_step(self._env, self._actions[action_idx], cx, cy)

    # ── Phase 1: Simple action brute ──
    def _phase1_simple_brute(self, budget):
        """Try each simple action repeatedly up to budget."""
        for aidx in self._simple_indices:
            if self._total_steps >= budget:
                return None
            self._env.reset()
            for _k in range(200):
                nf = self._safe_step(aidx)
                if nf is None:
                    break
                if _is_win(nf):
                    return [aidx] * (_k + 1)
                if self._total_steps >= budget:
                    break
        return None

    # ── Phase 2: Dense click scan (1024 positions, stride=2) ──
    def _phase2_dense_scan(self, max_positions=1024):
        """Try every click position. Return solution or list of live clicks."""
        live_clicks = []

        # Baseline: true initial state (no action executed)
        _bf = self._env.reset()
        _bg = _get_grid(_bf)
        baseline_hash = _grid_hash(_bg)

        for pi, (px, py) in enumerate(_ALL_POSITIONS):
            if pi >= max_positions or self._total_steps >= self._budget:
                break
            self._env.reset()
            nf = self._safe_step(self._click_idx, px, py)
            if nf is None:
                continue
            if _is_win(nf):
                self.solution = [self._click_idx]
                return "WIN", [(px, py, None)]
            grid = _get_grid(nf)
            h = _grid_hash(grid)
            if h != baseline_hash:
                live_clicks.append((px, py, h))
        return "LIVE_CLICKS" if live_clicks else "NO_LIVE", live_clicks

    # ── Phase 3: Replay BFS from live clicks (Occam-style) ──
    def _replay_bfs(self, live_clicks, max_steps):
        """Reset-replay BFS: env.reset() → replay prefix → try all actions.
        
        Live clicks form initial frontier nodes. Each node has a replay prefix
        (list of action tuples). Separated replay budget (avoids spending
        exploration steps on reconstruction).
        """
        if not live_clicks:
            return False
        
        # Deduplicate live clicks by state hash
        seen = set()
        frontier_nodes = []  # each: (state_hash, prefix: list[(aidx, cx, cy)])
        for px, py, h in live_clicks:
            if h not in seen:
                seen.add(h)
                frontier_nodes.append((h, [(self._click_idx, px, py)]))
        
        explored = set(seen)
        _replay_budget = max_steps  # steps allowed for replay
        
        while frontier_nodes and self._total_steps < self._budget:
            # BFS: pop shortest prefix first
            frontier_nodes.sort(key=lambda n: len(n[1]))
            cur_hash, prefix = frontier_nodes.pop(0)
            
            # Replay prefix to reach this state
            if not self._replay_prefix(prefix):
                continue
            
            # Try all actions from this state
            for aidx in range(len(self._actions)):
                if self._total_steps >= self._budget:
                    return self.solution is not None
                nf = self._safe_step(aidx)
                if nf is None:
                    continue
                if _is_win(nf):
                    self.solution = [a for a, _, _ in prefix] + [aidx]
                    return True
                ng = _get_grid(nf)
                nh = _grid_hash(ng)
                if nh not in explored:
                    explored.add(nh)
                    if self._actions[aidx].is_complex():
                        frontier_nodes.append((nh, list(prefix) + [(aidx, 32, 32)]))
                    else:
                        frontier_nodes.append((nh, list(prefix) + [(aidx, -1, -1)]))
            if self._click_idx is not None:
                for lcx, lcy, _ in live_clicks[:10]:
                    if self._total_steps >= self._budget:
                        break
                    nf = self._safe_step(self._click_idx, lcx, lcy)
                    if nf is None:
                        continue
                    if _is_win(nf):
                        self.solution = [a for a, _, _ in prefix] + [self._click_idx]
                        return True
                    ng = _get_grid(nf)
                    nh = _grid_hash(ng)
                    if nh not in explored:
                        explored.add(nh)
                        frontier_nodes.append((nh, list(prefix) + [(self._click_idx, lcx, lcy)]))
        
        return self.solution is not None
    
    def _replay_prefix(self, prefix):
        """env.reset() → step through prefix actions. Returns True if all steps succeeded."""
        self._env.reset()
        for aidx, cx, cy in prefix:
            nf = self._safe_step(aidx, cx, cy)
            if nf is None:
                return False
        return True

    # ── Phase 4: 1px refinement ──
    def _refine_live_clicks(self, live_clicks):
        """Try ±3px around unique live click centers."""
        seen = set()
        unique_centers = []
        for px, py, h in live_clicks:
            if h not in seen and len(unique_centers) < 5:
                seen.add(h)
                unique_centers.append((px, py))
        for px, py in unique_centers:
            if self._total_steps >= self._budget:
                break
            for ox in range(-3, 4):
                for oy in range(-3, 4):
                    if self._total_steps >= self._budget:
                        break
                    nx = max(0, min(63, px + ox))
                    ny = max(0, min(63, py + oy))
                    self._env.reset()
                    nf = self._safe_step(self._click_idx, nx, ny)
                    if nf is None:
                        continue
                    if _is_win(nf):
                        self.solution = [self._click_idx]
                        return True
        return False

    # ── Main entry ──
    def explore(self, max_steps=2000, dense_scan_first=True):
        """Main loop. Returns True if solution found.

        Pipeline: simple brute → dense scan → replay BFS → refinement
        """
        self._budget = max_steps
        self._total_steps = 0
        self.solution = None
        self.live_clicks = []

        # Phase 1: Simple action brute
        if self._simple_indices:
            sol = self._phase1_simple_brute(max_steps)
            if sol:
                self.solution = sol
                return True

        # Phase 2: Dense click scan
        if self._click_idx is not None and self._total_steps < self._budget:
            result, data = self._phase2_dense_scan(1024)
            if result == "WIN":
                return True
            if result == "LIVE_CLICKS":
                self.live_clicks = data

        # Phase 3: Replay BFS from live clicks
        if self.live_clicks and self._total_steps < self._budget:
            self._replay_bfs(self.live_clicks, max_steps // 2)
            if self.solution:
                return True

        # Phase 4: 1px refinement
        if not self.solution and self.live_clicks and self._total_steps < self._budget:
            self._refine_live_clicks(self.live_clicks)

        return self.solution is not None
