"""graph_explorer.py — Frontier-based graph exploration for ARC-AGI-3.

Port of dolphin-in-a-coma/arc-agi-3-just-explore (3rd place, 17/25 levels).
Differences: WASM canonical_hash, FrameProcessor segments, WASM TT.

New: heuristic ranker (0 params) scores each candidate:
  confidence = w0*(5-tier) + w1*coverage_norm + w2*novelty

Strategy:
  1. Segment current frame → priority-tiered click candidates (cx, cy)
  2. Score all untried candidates with heuristic ranker
  3. Pick highest-scored candidate, execute ACTION6 @ (cx, cy)
  4. Record (state_hash, candidate) → result_hash edges
  5. Frontier BFS for distance tracking → pick closest frontier node
  6. On WIN: extract solution path
  7. On dead end (all candidates tried at a state): revert to previous state
"""

from collections import deque
import numpy as np
from typing import Any
from step_adapter import safe_step


class NodeInfo:
    __slots__ = ("group_of", "candidates", "tried_mask", "dead_mask", "tried_simple", "edge_data", "is_dead")
    def __init__(self, group_of, candidates):
        # group_of[i] = priority tier 0-4 for candidate i
        self.group_of = group_of
        self.candidates = candidates  # [(cx, cy, sid, area), ...]
        self.tried_mask = 0  # bit i = 1 if candidate i tried
        self.dead_mask = 0   # bit i = 1 if candidate produced no state change
        self.tried_simple = 0
        self.edge_data = {}
        self.is_dead = False


class GraphExplorer:
    # Heuristic weights (manual, 0 params, no training)
    # Can be overridden per-instance for adaptive search
    W_TIER    = 10.0  # priority tier (G0=5 → 50pts, G4=1 → 10pts)
    W_AREA    = 5.0   # coverage area (larger = more likely target)
    W_NOVELTY = 3.0   # never tried in any state = bonus

    # Default weight configs for adaptive search
    WEIGHT_CONFIGS = [
        {"W_TIER": 10, "W_AREA": 5,  "W_NOVELTY": 3},   # salience-first (default)
        {"W_TIER": 5,  "W_AREA": 5,  "W_NOVELTY": 10},  # novelty-first (explore)
        {"W_TIER": 15, "W_AREA": 3,  "W_NOVELTY": 2},   # tier-first (conservative)
    ]
    W_WASM    = 1.0   # WASM build_candidates score (0-100)

    def __init__(self, env, fp, hasher, action_list, tt_lookup=None, tt_store=None,
                 wasm_scorer=None, weights=None, live_click_xy=None):
        self._env = env
        self._fp = fp
        self._hasher = hasher
        self._actions = action_list
        self._click_idx = next((i for i, a in enumerate(self._actions) if a.is_complex()), None)
        self._simple_indices = [i for i, a in enumerate(self._actions) if not a.is_complex()]
        self._tt_lk = tt_lookup
        self._tt_st = tt_store
        self._wasm_scorer = wasm_scorer
        self._live_xy = live_click_xy  # (x, y) from profiler, or None
        # Instance weights (overridable for adaptive search)
        self._weights = weights or {"W_TIER": 10.0, "W_AREA": 5.0, "W_NOVELTY": 3.0}  # fn(cx, cy) → score or None

        self._nodes = {}
        self._edges = {}
        self._frontier = set()
        self._path = []
        self._distances = {}
        self._global_tried = set()  # all (cx, cy) tried across states
        self._counter_mask = None  # volatile pixel mask (detected via detect_counter_mask)
        self._prefix = {}  # hash -> [(a,cx,cy)...] prefix to reach each state
        self._total_steps = 0
        self._budget = 0
        self.solution = None
        self._initial_done = False  # first node gets dense scan

    def _grid_hash(self, grid):
        """Hash with counter mask (volatile pixels zeroed)."""
        if self._counter_mask is not None and self._counter_mask.shape == grid.shape:
            masked = grid.copy()
            masked[self._counter_mask] = 0
            return self._hasher(masked)
        return self._hasher(grid)

    def _backtrack(self, to_hash):
        """Reset env and replay prefix to reach to_hash."""
        prefix = self._prefix.get(to_hash, [])
        self._env.reset()
        for aidx, cx, cy in prefix:
            nf = self._safe_step(aidx, cx, cy)
            if nf is None:
                break

    def _safe_step(self, action_idx, cx=32, cy=32):
        """Step via step_adapter.safe_step (complex=always data, fail-fast)."""
        self._total_steps += 1
        return safe_step(self._env, self._actions[action_idx], cx, cy)

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

    def _candidates_from_frame(self, frame, dense_scan=False):
        fr = getattr(frame, "frame", None)
        if fr is None or len(fr) == 0:
            return []
        grid = np.asarray(fr[0], dtype=np.int32)
        # Apply counter mask before segmentation (zero out volatile pixels)
        if self._counter_mask is not None and self._counter_mask.shape == grid.shape:
            grid = grid.copy()
            grid[self._counter_mask] = 0
        result = []
        has_clickable = False
        if not dense_scan:
            # Normal segment-based candidate generation
            label_map, components = self._fp.segment_frame(grid)
            groups = self._fp.frame_segments_to_action_groups(components, 5)
            for gid, seg_ids in enumerate(groups):
                for sid in seg_ids:
                    if self._click_idx is None:
                        continue
                    cx, cy = self._fp.compute_click_point(label_map, sid)
                    area = components[sid]["area"] if sid < len(components) else 1
                    # Skip background segment (all-black, area=4096) unless it's the only one
                    if area >= 3072 and len(components) > 1 and components[sid]["color"] == 0:
                        continue
                    result.append((gid, cx, cy, sid, area))
                    has_clickable = True
            # Dense scan fallback: if no clickable candidates (all-black grid), generate 8×8 grid
            if not has_clickable and self._click_idx is not None:
                for gx in range(0, 64, 8):
                    for gy in range(0, 64, 8):
                        result.append((3, gx, gy, -1, 1))
        else:
            # Dense scan: stride 2 (1024 positions) for initial state exploration
            if self._click_idx is not None:
                for gx in range(0, 64, 2):
                    for gy in range(0, 64, 2):
                        result.append((3, gx, gy, -1, 1))
                has_clickable = True
        return result

    def _score_candidate(self, tier, cx, cy, area, max_area):
        """Heuristic confidence score using instance weights."""
        w = self._weights
        tier_score = (5 - tier) * w["W_TIER"]
        area_norm = (area / max(1, max_area)) * w["W_AREA"]
        novelty = w["W_NOVELTY"] if (cx, cy) not in self._global_tried else 0.0
        return tier_score + area_norm + novelty

    def _get_or_create_node(self, s_hash, frame):
        if s_hash not in self._nodes:
            use_dense = not self._initial_done
            self._initial_done = True
            cands = self._candidates_from_frame(frame, dense_scan=use_dense)
            groups_list = [[] for _ in range(5)]
            areas = {}
            for gid, cx, cy, sid, area in cands:
                if gid < 5:
                    groups_list[gid].append((cx, cy, sid, area))
                    areas[(cx, cy)] = area
            # Flatten all candidates into one list with their group
            all_cands = []
            group_of = []
            max_area = 1
            for gid in range(5):
                for cx, cy, sid, area in groups_list[gid]:
                    all_cands.append((cx, cy, sid, area))
                    group_of.append(gid)
                    max_area = max(max_area, area)
            # Inject profiler live_click_xy as highest-priority candidate
            if self._live_xy is not None:
                lx, ly = self._live_xy
                all_cands.insert(0, (lx, ly, -2, max_area))
                group_of.insert(0, 0)
            # Sort by heuristic score descending
            scored = [(self._score_candidate(group_of[i], cx, cy, area, max_area), i)
                      for i, (cx, cy, _, area) in enumerate(all_cands)]
            scored.sort(key=lambda x: -x[0])
            # Reorder candidates by score
            sorted_cands = [all_cands[i] for _, i in scored]
            sorted_groups = [group_of[i] for _, i in scored]
            self._nodes[s_hash] = NodeInfo(sorted_groups, sorted_cands)
        return self._nodes[s_hash]

    def _next_untried(self, s_hash):
        """Return (action_idx, cx, cy) or None if all exhausted.
        Picks highest-scored untried candidate."""
        node = self._nodes.get(s_hash)
        if node is None or node.is_dead:
            return None

        # Find best untried click candidate
        best_idx = -1
        best_score = -9999.0
        for i in range(len(node.candidates)):
            if not (node.tried_mask >> i & 1) and not (node.dead_mask >> i & 1):
                cx, cy, sid, area = node.candidates[i]
                gid = node.group_of[i]
                max_area = max(a for _, _, _, a in node.candidates) if node.candidates else 1
                s = self._score_candidate(gid, cx, cy, area, max_area)
                if s > best_score:
                    best_score = s
                    best_idx = i

        if best_idx >= 0:
            node.tried_mask |= 1 << best_idx
            cx, cy, _, _ = node.candidates[best_idx]
            self._global_tried.add((cx, cy))
            return (self._click_idx, cx, cy)

        # Fallback: try simple actions
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
        self._global_tried.clear()
        self._prefix.clear()
        self.solution = None

        self._env.reset()
        frame = self._safe_step(0)
        if frame is None:
            return False
        grid = self._get_grid(frame)
        start_hash = self._grid_hash(grid)
        self._frontier.add(start_hash)

        # ── Adaptive weight search (3 configs × 50 steps = 150 step budget) ──
        _best_weights = self._weights
        _best_count = -1
        _trial_budget = min(50, max_steps // 10)
        if _trial_budget >= 10 and not self._simple_indices:
            for _cfg_idx, _cfg in enumerate(self.WEIGHT_CONFIGS):
                if self._total_steps >= max_steps * 0.75:
                    break
                self._weights = _cfg
                self._nodes.clear()
                self._edges.clear()
                self._frontier.clear()
                self._path.clear()
                self._distances.clear()
                self._global_tried.clear()
                self._prefix.clear()
                frame = self._env.reset()  # TRUE initial state, no action executed
                if frame is None:
                    self._weights = _best_weights
                    break
                grid = self._get_grid(frame)
                sh = self._grid_hash(grid)
                self._frontier.add(sh)
                self._get_or_create_node(sh, frame)
                _found = 0
                # Run _trial_budget steps with this config
                _trial_steps = 0
                _prev_budget = self._budget
                self._budget = self._total_steps + _trial_budget
                while self._total_steps < self._budget and self._frontier:
                    self._rebuild_distances()
                    ordered = sorted(self._frontier, key=lambda h: -self._distances.get(h, 0))
                    if not ordered:
                        break
                    cur_h = ordered[0]
                    cn = self._nodes.get(cur_h)
                    if cn and cn.is_dead:
                        self._frontier.discard(cur_h)
                        continue
                    cs = self._next_untried(cur_h)
                    if cs is None:
                        self._frontier.discard(cur_h)
                        continue
                    aidx, cx, cy = cs
                    nf = self._safe_step(aidx, cx, cy)
                    if nf is None:
                        continue
                    ng = self._get_grid(nf)
                    nh = self._grid_hash(ng)
                    sk = cx * 1000 + cy
                    self._edges[(cur_h, sk)] = (nh, nf)
                    if nh != cur_h and nh not in self._nodes:
                        self._frontier.add(nh)
                        self._get_or_create_node(nh, nf)
                        _found += 1
                self._budget = _prev_budget
                if _found > _best_count:
                    _best_count = _found
                    _best_weights = dict(_cfg)
                    if _found >= 3:
                        break  # good enough
            self._weights = _best_weights

        # Reset for main exploration with winning weights
        self._nodes.clear()
        self._edges.clear()
        self._frontier.clear()
        self._path.clear()
        self._distances.clear()
        self._global_tried.clear()
        self._prefix.clear()
        frame = self._env.reset()  # TRUE initial state, no action executed
        if frame is None:
            return False
        grid = self._get_grid(frame)
        start_hash = self._grid_hash(grid)
        self._frontier.add(start_hash)
        self._get_or_create_node(start_hash, frame)

        # ── Counter mask: detect volatile pixels (timer/score) ──
        # Occam technique: take frame after two DIFFERENT actions,
        # pixels that changed in BOTH are volatile (timer, score).
        if len(self._actions) > 1:
            _act0 = self._safe_step(0, 32, 32)
            _g0 = self._get_grid(_act0) if _act0 is not None else None
            self._backtrack(start_hash)
            _act1 = self._safe_step(1, 32, 32) if len(self._actions) > 1 else None
            _g1 = self._get_grid(_act1) if _act1 is not None else None
            if _g0 is not None and _g1 is not None:
                _mask0 = (grid != _g0)
                _mask1 = (grid != _g1)
                self._counter_mask = (_mask0 & _mask1)
        # Reset env to initial state before main loop
        self._backtrack(start_hash)

        while self._total_steps < self._budget:
            if not self._frontier:
                break

            self._rebuild_distances()
            ordered = sorted(self._frontier, key=lambda h: -self._distances.get(h, 0))
            if not ordered:
                break

            cur_hash = ordered[0]
            cur_node = self._nodes.get(cur_hash)
            if cur_node and cur_node.is_dead:
                self._frontier.discard(cur_hash)
                continue

            self._backtrack(cur_hash)
            _tries_here = 0

            # ── TRY ALL CANDIDATES AT THIS STATE ──
            while True:
                cand_seq = self._next_untried(cur_hash)
                if cand_seq is None:
                    self._frontier.discard(cur_hash)
                    break

                aidx, cx, cy = cand_seq
                nf = self._safe_step(aidx, cx, cy)

                if nf is None:
                    continue

                if self._is_win(nf):
                    self._path.append((aidx, cx, cy))
                    self.solution = [int(a) for a, _, _ in self._path]
                    return True

                ng = self._get_grid(nf)
                nhash = self._grid_hash(ng)

                seg_key = cx * 1000 + cy
                self._edges[(cur_hash, seg_key)] = (nhash, nf)

                if nhash == cur_hash:
                    # Dead action: no state change, ban this candidate
                    for _i, (_cx, _cy, _, _) in enumerate(cur_node.candidates):
                        if _cx == cx and _cy == cy:
                            cur_node.dead_mask |= 1 << _i
                            break

                if nhash != cur_hash and nhash not in self._nodes:
                    self._frontier.add(nhash)
                    self._get_or_create_node(nhash, nf)
                    self._path.append((aidx, cx, cy))
                    self._prefix[nhash] = self._prefix.get(cur_hash, []) + [(aidx, cx, cy)]

                if self._total_steps >= self._budget:
                    return False

                self._backtrack(cur_hash)

        return False
