"""ida_star.py — Pure functional IDA* with invariant heuristic for ARC-AGI-3.

Replaces blind BFS for games where algebra probe detects complex structure
(no absorbing/periodic/repeated_win tags).

Heuristic: h(s) = Δn_components between s and best known state.
Admissible because every action changes at most 1 component.
"""

import numpy as np

# ── Heuristic: admissible lower bound on remaining steps ──

def _n_components(grid: np.ndarray) -> int:
    """Connected components via flood-fill (4-neighbor). O(H*W)."""
    if grid is None or grid.size == 0:
        return 0
    h, w = grid.shape
    visited = np.zeros((h, w), dtype=bool)
    n = 0
    for r in range(h):
        for c in range(w):
            if not visited[r, c]:
                n += 1
                color = grid[r, c]
                stack = [(r, c)]
                visited[r, c] = True
                while stack:
                    cr, cc = stack.pop()
                    for dr, dc in ((1,0), (-1,0), (0,1), (0,-1)):
                        nr, nc = cr + dr, cc + dc
                        if 0 <= nr < h and 0 <= nc < w and not visited[nr, nc] and grid[nr, nc] == color:
                            visited[nr, nc] = True
                            stack.append((nr, nc))
    return n

def make_heuristic(min_components: int):
    """Factory: returns admissible h(s) given known min n_components.
    
    h(s) = n_components(s) - min_components
    Admissible: at least 1 step needed per component above minimum.
    """
    def h(grid: np.ndarray) -> int:
        return max(0, _n_components(grid) - min_components)
    return h


# ── IDA* ──

def ida_star(env, act_list, heuristic, max_steps: int = 2000,
             max_depth: int = 50, verbose: bool = False) -> list | None:
    """Iterative Deepening A* with admissible heuristic.
    
    Args:
        env: arc_agi environment.
        act_list: list of GameAction members.
        heuristic: h(s) function returning int (admissible).
        max_steps: total env.step() budget.
        max_depth: maximum search depth.
        verbose: print search progress.
    
    Returns:
        list of 0-based action indices, or None if not found within budget.
    """
    from functools import lru_cache
    
    budget = max_steps
    used = 0
    
    # State: (grid_hash, hash_no_step, steps_from_start)
    # We track hash without step-modulus for IDA* continuity
    
    def _to_grid(frame):
        if isinstance(frame, np.ndarray) and frame.ndim == 2:
            return frame.astype(np.int32)
        try:
            fr = getattr(frame, "frame", None)
            if fr and len(fr) > 0:
                return np.asarray(fr[0], dtype=np.int32)
        except Exception:
            pass
        return None
    
    def _is_win(frame):
        return getattr(frame, "state", None) is not None and (
            str(getattr(frame, "state", "")).endswith("WIN")
        )
    
    # Enumerate hash of actions tried from each state to avoid revisiting
    # (state_hash, action) → result_hash
    transpositions = {}
    
    # Depth-limited DFS with f-bound
    def dfs(path: list, g: int, bound: int, h0: int, frame, grid) -> tuple:
        """Returns (new_bound, solution) or (INF, None)."""
        nonlocal budget, used
        
        f = g + h0
        if f > bound:
            return (f, None)
        
        if _is_win(frame):
            return (-1, path[:])
        
        if budget <= 0:
            return (float('inf'), None)
        
        if len(path) >= max_depth:
            return (float('inf'), None)
        
        min_f = float('inf')
        
        for a_idx, ga in enumerate(act_list):
            if budget <= 0:
                break
            
            # State-action transposition table: skip if already tried
            s_hash = hash(grid.tobytes())
            if (s_hash, a_idx) in transpositions:
                continue
            
            gd = {"x": 32, "y": 32} if ga.is_complex() else None
            nf = env.step(ga, data=gd)
            budget -= 1
            used += 1
            
            if nf is None:
                transpositions[(s_hash, a_idx)] = -1
                continue
            
            ng = _to_grid(nf)
            if ng is None:
                transpositions[(s_hash, a_idx)] = -1
                continue
            
            transpositions[(s_hash, a_idx)] = hash(ng.tobytes())
            
            path.append(a_idx)
            nh = heuristic(ng)
            t, sol = dfs(path, g + 1, bound, nh, nf, ng)
            path.pop()
            
            if sol is not None:
                return (-1, sol)
            
            if t < min_f:
                min_f = t
            
            # Backtrack: env.reset() + replay path
            env.reset()
            for pa in path:
                pga = act_list[pa]
                pgd = {"x": 32, "y": 32} if pga.is_complex() else None
                env.step(pga, data=pgd)
                budget -= 1
                used += 1
        
        return (min_f, None)
    
    # Main IDA* loop
    env.reset()
    frame = env.step(act_list[0])  # one probe step
    grid = _to_grid(frame)
    if grid is None:
        return None
    
    h_start = heuristic(grid)
    bound = h_start
    
    for iteration in range(100):
        if verbose:
            print(f"  IDA* iter {iteration}: bound={bound}, budget={budget}, used={used}")
        
        if budget <= 0:
            return None
        
        # Reset env
        env.reset()
        frame = env.step(act_list[0])
        grid = _to_grid(frame)
        if grid is None:
            return None
        
        t, sol = dfs([], 0, bound, h_start, frame, grid)
        
        if sol is not None:
            return sol
        
        if t == float('inf'):
            return None
        
        bound = max(bound + 1, int(t))
    
    return None
