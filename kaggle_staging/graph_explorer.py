"""graph_explorer.py — Frontier-based graph exploration with priority tiers.

Port of dolphin-in-a-coma/arc-agi-3-just-explore (3rd place, 17/25 levels).
Key differences from original:
  - Uses WASM canonical_hash instead of Blake2B
  - Uses FrameProcessor segment/click instead of direct pixel ops
  - Uses WASM TT for instant win detection

Architecture:
  GraphExplorer maintains a graph of (state_hash → NodeInfo).
  NodeInfo stores priority-tiered action candidates and edge transitions.
  Frontier BFS tracks distances from the exploration boundary.
"""

from collections import deque, defaultdict
import numpy as np
from typing import Any


class NodeInfo:
    """Node in the exploration graph.
    
    Groups: list of candidate lists per priority tier (0=best, 4=worst).
    active_group: current group index being explored.
    tried_mask: bitmask of which candidates in active_group have been tried.
    """
    __slots__ = ("groups", "active_group", "tried_mask", "edge_data", "is_dead")
    
    def __init__(self, groups: list[list]):
        self.groups = groups  # list of lists: groups[0] = highest priority
        self.active_group = 0
        self.tried_mask = 0
        self.edge_data: dict[int, int] = {}  # candidate_idx → result_hash
        self.is_dead = False  # all groups exhausted


class GraphExplorer:
    """Frontier-based graph exploration for ARC-AGI-3.
    
    Usage:
        explorer = GraphExplorer(env, frame_processor, hasher, action_list)
        solved = explorer.explore(max_steps=5000)
        if solved: return explorer.solution
    
    Strategy:
        1. Get current state hash (WASM canonical)
        2. Segment frame → priority groups → candidates
        3. Find next untried candidate in current group
        4. Execute ACTION6 @ candidate centroid
        5. Record transition: (state_hash, candidate) → result_hash
        6. On WIN: extract reverse path → solution
        7. On no new candidates: advance group or mark state dead
    """

    def __init__(self, env, fp, hasher, action_list, tt_lookup=None, tt_store=None):
        self._env = env
        self._fp = fp
        self._hasher = hasher  # fn(grid) → int
        self._action_list = action_list
        self._tt_lookup = tt_lookup  # fn(lo, hi) → int or -1
        self._tt_store = tt_store    # fn(lo, hi, action, score)
        
        self._nodes: dict[int, NodeInfo] = {}
        self._edges: dict[tuple[int, int], tuple[int, int]] = {}  # (s_hash, cand) → (s'_hash, nf)
        self._frontier: set[int] = set()
        self._path: list[tuple[int, int, int]] = []  # (candidate, cx, cy) for replay
        self._distances: dict[int, int] = {}
        self._grid_cache: dict[int, Any] = {}  # hash → frame reference
        
        self._goal_hash: int | None = None
        self._total_steps = 0
        self._exploration_budget = 0
        self._best_hash = 0
        self._best_distance = 999999
        
        self.solution: list[int] | None = None
    
    def _grid_hash(self, grid: np.ndarray) -> int:
        return self._hasher(grid)
    
    def _step(self, action_idx: int, cx: int = 32, cy: int = 32):
        """Execute env.step with given action. Returns next frame."""
        self._total_steps += 1
        ga = self._action_list[action_idx]
        gd = {"x": cx, "y": cy} if ga.is_complex() else None
        return self._env.step(ga, data=gd)
    
    def _is_win(self, frame) -> bool:
        return getattr(frame, "state", None) is not None and "WIN" in str(getattr(frame, "state", ""))
    
    def _backtrack(self, to_hash: int):
        """Reset env and replay path up to given state hash."""
        self._env.reset()
        for cand, cx, cy in self._path:
            nf = self._step(cand, cx, cy)
            if nf is None:
                break
            ch = self._grid_hash(getattr(nf, "frame", [np.zeros((64,64), dtype=np.int32)])[0])
            if ch == to_hash:
                break
    
    def _rebuild_distances(self):
        """BFS from all frontier nodes. Distance = steps from frontier."""
        self._distances = {}
        dq = deque()
        for fh in self._frontier:
            self._distances[fh] = 0
            dq.append(fh)
        while dq:
            cur = dq.popleft()
            nd = self._distances[cur] + 1
            for (sh, _), (th, _) in self._edges.items():
                if th == cur and sh not in self._distances:
                    self._distances[sh] = nd
                    dq.append(sh)
    
    def _candidates_from_frame(self, frame) -> list:
        """Use FrameProcessor to get click candidates with priority tiers."""
        fr = getattr(frame, "frame", None)
        if fr is None or len(fr) == 0:
            return []
        grid = np.asarray(fr[0], dtype=np.int32)
        label_map, components = self._fp.segment_frame(grid)
        groups = self._fp.frame_segments_to_action_groups(components, 5)
        candidates = []
        for gid, seg_ids in enumerate(groups):
            for sid in seg_ids:
                cx, cy = self._fp.compute_click_point(label_map, sid)
                candidates.append((gid, cx, cy, sid))
        return candidates  # [(group, cx, cy, segment_id), ...]
    
    def _get_or_create_node(self, state_hash: int, frame) -> NodeInfo:
        if state_hash not in self._nodes:
            cands = self._candidates_from_frame(frame)
            # Group candidates by priority tier
            groups = [[] for _ in range(5)]
            for gid, cx, cy, sid in cands:
                if gid < 5:
                    groups[gid].append((cx, cy, sid))
            self._nodes[state_hash] = NodeInfo(groups)
        return self._nodes[state_hash]
    
    def _next_untried(self, state_hash: int) -> tuple | None:
        """Return next untried (candidate, cx, cy) or None if all exhausted."""
        node = self._nodes.get(state_hash)
        if node is None or node.is_dead:
            return None
        
        # Try active group
        while node.active_group < 5:
            group = node.groups[node.active_group]
            if not group:
                node.active_group += 1
                continue
            for i, (cx, cy, sid) in enumerate(group):
                if not (node.tried_mask >> i & 1):
                    node.tried_mask |= 1 << i
                    return (sid, cx, cy)
            # Group exhausted, advance
            node.active_group += 1
            node.tried_mask = 0
        
        # All groups exhausted
        node.is_dead = True
        return None
    
    def _get_grid(self, frame) -> np.ndarray:
        fr = getattr(frame, "frame", None)
        if fr is not None and len(fr) > 0:
            return np.asarray(fr[0], dtype=np.int32)
        return np.zeros((64, 64), dtype=np.int32)
    
    def explore(self, max_steps: int) -> bool:
        """Main exploration loop. Returns True if goal found."""
        self._exploration_budget = max_steps
        self._total_steps = 0
        self._nodes.clear()
        self._edges.clear()
        self._frontier.clear()
        self._path.clear()
        self.solution = None
        
        self._env.reset()
        frame = self._step(0)  # ACTION1 as probe
        if frame is None:
            return False
        grid = self._get_grid(frame)
        start_hash = self._grid_hash(grid)
        self._frontier.add(start_hash)
        self._grid_cache[start_hash] = frame
        
        while self._total_steps < self._exploration_budget:
            if not self._frontier:
                break
            
            # Rebuild distances
            self._rebuild_distances()
            
            # Pick closest frontier node
            frontier_sorted = sorted(self._frontier, key=lambda h: -self._distances.get(h, 0)) if self._frontier else []
            if not frontier_sorted:
                break
            
            cur_hash = frontier_sorted[0]
            cur_node = self._nodes.get(cur_hash)
            if cur_node and cur_node.is_dead:
                self._frontier.discard(cur_hash)
                continue
            
            # Reset env and replay to this state
            self._backtrack(cur_hash)
            
            # Get current frame after replay
            frame = self._step(0, 32, 32)  # small probe to get frame
            self._total_steps -= 1  # don't count, just for frame grab
            
            # Get or create node for this state
            node = self._get_or_create_node(cur_hash, frame)
            
            # Find next untried candidate
            next_c = self._next_untried(cur_hash)
            if next_c is None:
                self._frontier.discard(cur_hash)
                continue
            
            sid, cx, cy = next_c
            
            # Execute candidate action (ACTION6 @ click point)
            nf = self._step(5, cx, cy)  # ACTION6 = index 5
            
            if nf is None:
                continue
            
            # Check win
            if self._is_win(nf):
                self._path.append((sid, cx, cy))
                self.solution = [a for a, _, _ in self._path]
                return True
            
            ng = self._get_grid(nf)
            nhash = self._grid_hash(ng)
            
            # Record edge
            self._edges[(cur_hash, sid)] = (nhash, nf)
            node.edge_data[sid] = nhash
            
            if nhash != cur_hash and nhash not in self._nodes:
                self._frontier.add(nhash)
                self._grid_cache[nhash] = nf
                self._path.append((sid, cx, cy))
            
            # Check suspicious transition
            if nhash == cur_hash:
                # Same state — action is dead, mark as tried
                pass
        
        return False
    
    def has_solution(self) -> bool:
        return self.solution is not None
