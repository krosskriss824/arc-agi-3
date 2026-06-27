# frame_processor.py — Connected components + status bar masking + priority tiers
# Ported from dolphin-in-a-coma/arc-agi-3-just-explore (3rd place, 17/25 levels)
# Adapted for VERICODING WASM canonical_hash substrate.

import numpy as np
from collections import deque
from typing import Any, Optional

class FrameProcessor:
    """Segment frame into connected components, identify status bars, assign priority tiers."""

    OFFSETS4 = ((-1, 0), (1, 0), (0, -1), (0, 1))

    def __init__(self):
        self.connectivity_rank = 4
        self.status_bar_mode = "rule"
        self.status_bar_distance_threshold = 3
        self.status_bar_ratio_threshold = 5
        self.status_bar_twins_threshold = 3
        self.frame_shape = (64, 64)
        self.status_bar_color = 16
        self.minimal_width = 2
        self.maximal_width = 32
        self.non_salient_color = set([0, 1, 2, 3, 4, 5])
        self.salient_color = set([6, 7, 8, 9, 10, 11, 12, 13, 14, 15])

    def segment_frame(self, frame: np.ndarray) -> tuple[np.ndarray, list[dict]]:
        """Flood fill → connected components (same color, 4-connectivity).
        
        Returns: (label_map, components) where components is list of dicts:
            - bounding_box: (x1, y1, x2, y2)
            - color: int
            - area: pixel count
            - is_rectangle: bool
            - number_of_twins: int
            - twin_ids: list
        """
        h, w = frame.shape
        label_map = np.zeros((h, w), dtype=int) - 1
        components = []
        cid = -1
        offsets = self.OFFSETS4

        for y in range(h):
            for x in range(w):
                if label_map[y, x] != -1:
                    continue
                cid += 1
                color = int(frame[y, x])
                q = deque([(y, x)])
                label_map[y, x] = cid
                min_x = max_x = x
                min_y = max_y = y
                area = 0
                while q:
                    cy, cx = q.popleft()
                    area += 1
                    min_x, max_x = min(min_x, cx), max(max_x, cx)
                    min_y, max_y = min(min_y, cy), max(max_y, cy)
                    for dy, dx in offsets:
                        ny, nx = cy + dy, cx + dx
                        if 0 <= ny < h and 0 <= nx < w and label_map[ny, nx] == -1 and frame[ny, nx] == color:
                            label_map[ny, nx] = cid
                            q.append((ny, nx))
                rect_area = (max_x - min_x + 1) * (max_y - min_y + 1)
                components.append(dict(
                    bounding_box=(min_x, min_y, max_x, max_y),
                    color=color, area=area,
                    is_rectangle=(area == rect_area),
                ))

        # Second pass: twin detection
        for i, comp in enumerate(components):
            twins = [j for j, other in enumerate(components) if i != j
                     and other["area"] == comp["area"]
                     and other["is_rectangle"] == comp["is_rectangle"]
                     and other["color"] == comp["color"]]
            comp["number_of_twins"] = len(twins)
            comp["twin_ids"] = twins

        return label_map, components

    def identify_status_bars(self, segmented_frame: np.ndarray, frame_segments: list[dict]) -> tuple[list, np.ndarray]:
        """Return (status_bar_segments_list, status_bar_mask). Mask=True for UI elements."""
        checked_segment_ids = set()
        status_bar_segment_ids_list = []
        for i, segment in enumerate(frame_segments):
            if i in checked_segment_ids:
                continue
            checked_segment_ids.add(i)
            on_edge_list = self._check_segment_on_edge(segment)
            if not on_edge_list:
                continue
            directions = []
            if 'left' in on_edge_list or 'right' in on_edge_list:
                directions.append('vertical')
            if 'top' in on_edge_list or 'bottom' in on_edge_list:
                directions.append('horizontal')
            direction = 'any' if len(directions) == 2 else directions[0]
            if not self._check_segment_ratio(segment, direction=direction):
                twin_ids = self._segment_twins_on_edge(segment, frame_segments, on_edge_list)
                for tid in twin_ids:
                    checked_segment_ids.add(tid)
                if len(twin_ids) + 1 < self.status_bar_twins_threshold:
                    continue
                status_bar_segment_ids = [i] + twin_ids
            else:
                status_bar_segment_ids = [i]
            status_bar_segment_ids_list.append(status_bar_segment_ids)

        status_bar_mask = np.zeros(segmented_frame.shape, dtype=bool)
        for sids in status_bar_segment_ids_list:
            for sid in sids:
                status_bar_mask[segmented_frame == sid] = 1
        return status_bar_segment_ids_list, status_bar_mask

    def _check_segment_on_edge(self, segment: dict) -> list[str]:
        """Check if segment bbox touches screen edge. Returns list of edge names."""
        x1, y1, x2, y2 = segment["bounding_box"]
        d = self.status_bar_distance_threshold
        result = []
        if max(x1, x2) < d:
            result.append('left')
        if min(x1, x2) > self.frame_shape[1] - d:
            result.append('right')
        if max(y1, y2) < d:
            result.append('top')
        if min(y1, y2) > self.frame_shape[0] - d:
            result.append('bottom')
        return result

    def _check_segment_ratio(self, segment: dict, direction: str = 'any') -> bool:
        """True if segment is elongated enough to be a status bar."""
        x1, y1, x2, y2 = segment["bounding_box"]
        xl = x2 - x1 + 1
        yl = y2 - y1 + 1
        r = self.status_bar_ratio_threshold
        if xl / yl >= r and direction in ('any', 'horizontal'):
            return True
        if yl / xl >= r and direction in ('any', 'vertical'):
            return True
        return False

    def _segment_twins_on_edge(self, segment: dict, frame_segments: list[dict], edges: list[str]) -> list[int]:
        """Find twin segments on same edge."""
        return [tid for tid in segment["twin_ids"]
                if self._check_segment_on_edge(frame_segments[tid])
                and any(e in self._check_segment_on_edge(frame_segments[tid]) for e in edges)]

    def frame_segments_to_action_groups(self, frame_segments: list[dict], n_groups: int = 5) -> list[list[int]]:
        """Assign segments to priority groups (0=best, 4=worst).
        
        5 groups:
            G0: salient + medium width
            G1: medium width (non-salient)
            G2: salient (too small/too large)
            G3: all non-status-bar
            G4: status bar segments
        """
        groups = [set() for _ in range(n_groups)]
        for sid, seg in enumerate(frame_segments):
            x1, y1, x2, y2 = seg["bounding_box"]
            xw, yw = x2 - x1 + 1, y2 - y1 + 1
            is_salient = seg["color"] in self.salient_color
            is_medium = self.minimal_width <= xw <= self.maximal_width and self.minimal_width <= yw <= self.maximal_width
            if is_salient and is_medium:
                groups[0].add(sid)
            elif is_medium:
                groups[1].add(sid)
            elif is_salient:
                groups[2].add(sid)
            elif seg["color"] != self.status_bar_color:
                groups[3].add(sid)
            else:
                groups[4].add(sid)
        return [list(g) for g in groups]

    def detect_counter_mask(self, frame1: np.ndarray, frame2: np.ndarray) -> np.ndarray:
        """Adaptive counter mask: pixels that changed between TWO DIFFERENT ACTIONS.
        
        Occam technique: take frame after action A, frame after action B.
        Pixels that changed in BOTH are likely volatile UI (timer, score).
        Returns: bool mask, True = volatile pixel.
        """
        if frame1.shape != frame2.shape:
            return np.zeros(self.frame_shape, dtype=bool)
        return (frame1 != frame2).astype(bool)

    def compute_click_point(self, segmented_frame: np.ndarray, segment_id: int) -> tuple[int, int]:
        """Return CENTROID of segment (mean of all pixel positions). Deterministic."""
        mask = segmented_frame == segment_id
        ys, xs = mask.nonzero()
        if len(ys) == 0:
            return 32, 32
        return int(np.mean(xs)), int(np.mean(ys))
