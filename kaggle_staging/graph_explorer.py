"""graph_explorer.py — Frontier-based graph exploration for ARC-AGI-3.

Port of dolphin-in-a-coma/arc-agi-3-just-explore (3rd place, 17/25 levels).
Differences: WASM canonical_hash, FrameProcessor segments, WASM TT.

Strategy:
  1. Segment current frame → priority-tiered click candidates (cx, cy)
  2. Try untried candidates via ACTION6 @ (cx, cy)
  3. Record (state_hash, candidate) → result_hash edges
  4. Frontier BFS for distance tracking → pick closest frontier node
  5. On WIN: extract solution path
  6. On dead end (all candidates tried at a state): revert to previous state
"""

from collections import deque
import numpy as np
from typing import Any


class NodeInfo:
    __slots__ = ("groups", "active_group", "tried_mask", "tried_simple", "edge_data", "is_dead")
    def __init__(self, groups):
        self.groups = groups
        self.active_group = 0
        self.tried_mask = 0  # bitmask for current group
        self.tried_simple = 0  # bitmask for simple (non-click) actions tried
        self.edge_data = {}
        self.is_dead = False


class GraphExplorer:
    def __init__(self, env, fp, hasher, action_list, tt_lookup=None, tt_store=None):
        self._env = env
        self._fp = fp
        self._hasher = hasher
        self._actions = action_list
        # find first complex (click) action for candidate clicks
        self._click_idx = next((i for i, a in enumerate(self._actions) if a.is_complex()), None)
        self._simple_indices = [i for i, a in enumerate(self._actions) if not a.is_complex()]
        self._tt_lk = tt_lookup
        self._tt_st = tt_store

        self._nodes = {}
        self._edges = {}  # (state_hash, seg_id) -> (result_hash, frame)
        self._frontier = set()
        self._path = []  # list of (action_idx, cx, cy)
        self._distances = {}
        self._total_steps = 0
        self._budget = 0
        self.solution = None

    def _grid_hash(self, grid):
        return self._hasher(grid)

    def _step(self, action_idx, cx=32, cy=32):
        self._total_steps += 1
        ga = self._actions[action_idx]
        gd = {"x": cx, "y": cy} if ga.is_complex() else None
        return self._env.step(ga, data=gd)

    def _is_win(self, frame):
        s = getattr(frame, "state", None)
        return s is not None and "WIN" in str(s)

    def _get_grid(self, frame):
        fr = getattr(frame, "frame", None)
        if fr is not None and len(fr) > 0:
            return np.asarray(fr[0], dtype=np.int32)
        return np.zeros((64, 64), dtype=np.int32)

    def _rebuild_distances(self):
        self._distances.clear()
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

    def _candidates_from_frame(self, frame):
        fr = getattr(frame, "frame", None)
        if fr is None or len(fr) == 0:
            return []
        grid = np.asarray(fr[0], dtype=np.int32)
        label_map, components = self._fp.segment_frame(grid)
        groups = self._fp.frame_segments_to_action_groups(components, 5)
        result = []
        for gid, seg_ids in enumerate(groups):
            for sid in seg_ids:
                if self._click_idx is not None:
                    cx, cy = self._fp.compute_click_point(label_map, sid)
                    result.append((gid, cx, cy, sid))
        return result

    def _get_or_create_node(self, s_hash, frame):
        if s_hash not in self._nodes:
            cands = self._candidates_from_frame(frame)
            groups = [[], [], [], [], []]
            for gid, cx, cy, sid in cands:
                if gid < 5:
                    groups[gid].append((cx, cy, sid))
            self._nodes[s_hash] = NodeInfo(groups)
        return self._nodes[s_hash]

    def _next_untried(self, s_hash):
        """Return (action_idx, cx, cy) or None if all exhausted."""
        node = self._nodes.get(s_hash)
        if node is None or node.is_dead:
            return None

        # Phase 1: try click candidates from FrameProcessor
        while node.active_group < 5:
            group = node.groups[node.active_group]
            if not group:
                node.active_group += 1
                continue
            for i, (cx, cy, _) in enumerate(group):
                if not (node.tried_mask >> i & 1):
                    node.tried_mask |= 1 << i
                    if self._click_idx is not None:
                        return (self._click_idx, cx, cy)
            node.active_group += 1
            node.tried_mask = 0

        # Phase 2: try simple (non-click) actions
        for i, aidx in enumerate(self._simple_indices):
            if not (node.tried_simple >> i & 1):
                node.tried_simple |= 1 << i
                return (aidx, 32, 32)

        node.is_dead = True
        return None

    def explore(self, max_steps=2000):
        """Main loop. Returns True if goal found."""
        self._budget = max_steps
        self._total_steps = 0
        self._nodes.clear()
        self._edges.clear()
        self._frontier.clear()
        self._path.clear()
        self._distances.clear()
        self.solution = None

        # initial probe
        self._env.reset()
        frame = self._step(0)
        if frame is None:
            return False
        grid = self._get_grid(frame)
        start_hash = self._grid_hash(grid)
        self._frontier.add(start_hash)

        while self._total_steps < self._budget:
            if not self._frontier:
                break

            self._rebuild_distances()
            # farthest frontier node first (breadth-first frontier)
            ordered = sorted(self._frontier, key=lambda h: -self._distances.get(h, 0))
            if not ordered:
                break

            cur_hash = ordered[0]
            cur_node = self._nodes.get(cur_hash)
            if cur_node and cur_node.is_dead:
                self._frontier.discard(cur_hash)
                continue

            # replay to this state
            cand_seq = self._next_untried(cur_hash)
            if cand_seq is None:
                self._frontier.discard(cur_hash)
                continue

            aidx, cx, cy = cand_seq
            nf = self._step(aidx, cx, cy)

            if nf is None:
                continue

            if self._is_win(nf):
                self._path.append((aidx, cx, cy))
                self.solution = [int(a) for a, _, _ in self._path]
                return True

            ng = self._get_grid(nf)
            nhash = self._grid_hash(ng)

            seg_key = cx * 1000 + cy  # unique per candidate
            self._edges[(cur_hash, seg_key)] = (nhash, nf)

            if nhash != cur_hash and nhash not in self._nodes:
                self._frontier.add(nhash)
                self._path.append((aidx, cx, cy))

        return False
