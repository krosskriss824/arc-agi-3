"""dense_explorer.py — Dense click scan (32×2=1024 pos) + hybrid live-click BFS.

Architecture:
  Phase 1: Simple action brute (200 per action, shared budget)
  Phase 2: Dense click scan (1024 positions, stride=2)
  Phase 3: Live click follow-up (BFS from live clicks)
  Phase 4: Fallback to segment-based GraphExplorer (if live clicks found)
  
Merges Occam 57.60% RHAE dense scan + just-explore 17/25 segment approach.
"""
import numpy as np
from collections import deque


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
    """Explorer that tries 1024 click positions to find state changes.
    
    Hybrid: dense scan → segment-based GraphExplorer if live clicks found.
    """
    
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
    
    def _step(self, action_idx, cx=32, cy=32):
        self._total_steps += 1
        ga = self._actions[action_idx]
        gd = {"x": cx, "y": cy} if ga.is_complex() else None
        return self._env.step(ga, data=gd)
    
    # ── Phase 1: Simple action brute ──
    def _phase1_simple_brute(self, budget):
        """Try each simple action repeatedly up to budget."""
        for aidx in self._simple_indices:
            if self._total_steps >= budget:
                return None
            self._env.reset()
            ga = self._actions[aidx]
            for _k in range(200):
                nf = self._step(aidx)
                if nf is None:
                    break
                if _is_win(nf):
                    return [aidx] * (_k + 1)
                if self._total_steps >= budget:
                    break
        return None
    
    # ── Phase 2: Dense click scan (1024 positions, stride=2) ──
    def _phase2_dense_scan(self, max_positions=1024):
        """Try every click position. Return solution or list of live clicks.
        
        Live click = click position that produces state diff vs baseline.
        """
        live_clicks = []
        
        # Baseline: state after reset + first step
        self._env.reset()
        _bf = self._step(0)
        _bg = _get_grid(_bf)
        baseline_hash = _grid_hash(_bg)
        
        for pi, (px, py) in enumerate(_ALL_POSITIONS):
            if pi >= max_positions or self._total_steps >= self._budget:
                break
            
            self._env.reset()
            nf = self._step(self._click_idx, px, py)
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
    
    # ── Phase 3: Follow-up on live clicks ──
    def _phase3_followup(self, live_clicks, follow_budget):
        """From each live click state, try sequences: click + simple + click."""
        # Deduplicate by state hash (max 10 unique live states)
        seen = set()
        unique_clicks = []
        for px, py, h in live_clicks:
            if h not in seen and len(unique_clicks) < 10:
                seen.add(h)
                unique_clicks.append((px, py, h))
        
        for px, py, h in unique_clicks:
            if self._total_steps >= self._budget:
                break
            
            # Strategy A: click → simple actions repeated
            for aidx in self._simple_indices:
                if self._total_steps >= self._budget:
                    break
                self._env.reset()
                nf1 = self._step(self._click_idx, px, py)
                if nf1 is None: continue
                if _is_win(nf1):
                    self.solution = [self._click_idx]
                    return True
                for _k in range(follow_budget):
                    nf2 = self._step(aidx)
                    if nf2 is None: break
                    if _is_win(nf2):
                        self.solution = [self._click_idx] + [aidx] * (_k + 1)
                        return True
            
            # Strategy B: click → click (try other live clicks from this state)
            for px2, py2, _ in live_clicks[:20]:
                if self._total_steps >= self._budget:
                    break
                if px2 == px and py2 == py: continue
                self._env.reset()
                self._step(self._click_idx, px, py)
                nf2 = self._step(self._click_idx, px2, py2)
                if nf2 is None: continue
                if _is_win(nf2):
                    self.solution = [self._click_idx, self._click_idx]
                    return True
            
            # Strategy C: click → simple ×5 → click ×5 (cycle)
            self._env.reset()
            self._step(self._click_idx, px, py)
            for _cycle in range(5):
                if self._total_steps >= self._budget:
                    break
                for aidx in self._simple_indices[:2]:  # try first 2 simple
                    nf = self._step(aidx)
                    if nf is None: break
                    if _is_win(nf):
                        self.solution = [self._click_idx]
                        return True
                for px2, py2, _ in unique_clicks[:3]:
                    nf = self._step(self._click_idx, px2, py2)
                    if nf is None: break
                    if _is_win(nf):
                        self.solution = [self._click_idx]
                        return True
        
        return False
    
    # ── Main entry ──
    def explore(self, max_steps=2000, dense_scan_first=True):
        """Main loop. Returns True if solution found.
        
        Strategy:
          1. Simple action brute (200 per action)
          2. Dense click scan (1024 positions)
          3. Follow-up on live clicks
          4. Fallback: segment-based (via external)
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
        
        # Phase 3: Follow-up on live clicks
        if self.live_clicks and self._total_steps < self._budget:
            self._phase3_followup(self.live_clicks, max_steps // 10)
            if self.solution:
                return True
        
        # Phase 4: 1px refinement around unique live clicks (catch odd coords)
        if self.live_clicks and self._total_steps < self._budget:
            seen = set()
            unique_live = []
            for px, py, h in self.live_clicks:
                if h not in seen and len(unique_live) < 5:
                    seen.add(h)
                    unique_live.append((px, py))
            for px, py in unique_live:
                if self._total_steps >= self._budget:
                    break
                for ox in range(-3, 4):
                    for oy in range(-3, 4):
                        if self._total_steps >= self._budget:
                            break
                        nx = max(0, min(63, px + ox))
                        ny = max(0, min(63, py + oy))
                        self._env.reset()
                        nf = self._step(self._click_idx, nx, ny)
                        if nf is None: continue
                        if _is_win(nf):
                            self.solution = [self._click_idx]
                            return True
        
        return self.solution is not None
