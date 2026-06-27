
# =============================================================================
# 9. RHAE STAGE-1 WASM BRIDGE (MoonBit D4-canonical WASM, appended section)
# =============================================================================
# Loads rhae_stage1.wasm alongside wasm_bridge.wasm.
# Interface: _start() initializes MoonBit heap globals; then direct cell-set.
# Python fallback active when wasmtime unavailable (Kaggle P100 / OFFLINE).
#
# Public API consumed by submission_agent.py choose_action():
#   rhae = get_rhae()                    — singleton, lazy-init
#   lo, hi = rhae.canonical_hash(grid)  — (int,int) 64-bit split
#   new_mask = rhae.policy_gate(legal_mask, grid, n_actions)  — int bitmask
#   cands, n = rhae.build_candidates(legal_mask, path_cost, lo, hi, max_c)
#   top_acts = rhae.topk(cands, n, k)   — list[int] action indices
#   hit = rhae.hash_and_check(grid)     — bool (visited OR TT hit)
#   rhae.visited_mark(lo, hi)
#   rhae.visited_reset()
#   rhae.tt_store(lo, hi, action, score_q8)
#   result = rhae.tt_lookup(lo, hi)     — int (-1=miss, >=0: action<<16|score)

import numpy as np
import os

# ---------------------------------------------------------------------------
# 9a. RHAE WASM PATHS
# ---------------------------------------------------------------------------
_RHAE_WASM_PATHS = [
    "/kaggle/input/vericoding-urm/rhae_stage1.wasm",
    "/kaggle/working/rhae_stage1.wasm",
    os.path.join(os.path.dirname(__file__), "rhae_stage1.wasm"),
    "rhae_stage1.wasm",
]

# ---------------------------------------------------------------------------
# 9b. PURE-PYTHON FALLBACKS (identical semantics to MoonBit implementations)
# ---------------------------------------------------------------------------

_py_visited_words = [0] * 32  # 1024-bit bitset

def _py_visited_reset() -> None:
    global _py_visited_words
    _py_visited_words = [0] * 32

def _py_slot(lo: int, hi: int) -> tuple[int, int]:
    """Compute (word, bit) for visited bitset."""
    import ctypes
    xor = (lo ^ hi) & 0xFFFFFFFF
    # Same multiplier as MoonBit: -1640531527 = 0x9E3779B9 unsigned
    mul = ctypes.c_int32(xor * (-1640531527)).value
    s = mul & 1023
    return s // 32, s % 32

def _py_visited_mark(lo: int, hi: int) -> None:
    word, bit = _py_slot(lo, hi)
    _py_visited_words[word] |= (1 << bit)

def _py_visited_check(lo: int, hi: int) -> bool:
    word, bit = _py_slot(lo, hi)
    return bool((_py_visited_words[word] >> bit) & 1)

_py_tt: dict[tuple[int,int], tuple[int,int]] = {}

def _py_tt_store(lo: int, hi: int, action: int, score_q8: int) -> None:
    _py_tt[(lo & 0x7FFFFFFF, hi & 0x7FFFFFFF)] = (action, score_q8)

def _py_tt_lookup(lo: int, hi: int) -> int:
    result = _py_tt.get((lo & 0x7FFFFFFF, hi & 0x7FFFFFFF))
    return -1 if result is None else (result[0] << 16) | (result[1] & 0xFFFF)

def _py_canonical_hash(grid: np.ndarray) -> tuple[int, int]:
    lo = py_zobrist_canonical_hash(grid)
    return (lo & 0x7FFFFFFF, 0)

def _py_hash_and_check(grid: np.ndarray) -> bool:
    lo, hi = _py_canonical_hash(grid)
    return _py_visited_check(lo, hi)

def _py_policy_gate(legal_mask: int, grid: np.ndarray, n_actions: int) -> int:
    wasm_mask = py_action_prune_mask(grid)
    combined = legal_mask & wasm_mask
    return combined if combined else legal_mask

def _py_build_candidates(legal_mask: int, path_cost: int, lo: int, hi: int, max_c: int) -> list:
    acts = [i for i in range(1, 8) if (legal_mask >> (i-1)) & 1]
    return acts[:max_c]

def _py_topk(actions: list, k: int) -> list:
    return actions[:k]

# ---------------------------------------------------------------------------
# 9c. WASMTIME RHAE ENGINE
# ---------------------------------------------------------------------------

class RhaeEngine:
    """Thin Python wrapper around rhae_stage1.wasm.
    Protocol: _start() initializes heap → write grid cells → call functions.
    Thread-unsafe (single store/instance). Use as process-level singleton.
    """
    __slots__ = ("_store", "_exp", "_wasm_ok")

    def __init__(self, wasm_bytes=None):
        self._wasm_ok = False
        self._store = None
        self._exp = None
        if wasm_bytes is None:
            return
        try:
            import wasmtime
            engine = wasmtime.Engine()
            self._store = wasmtime.Store(engine)
            module = wasmtime.Module(engine, wasm_bytes)
            instance = wasmtime.Instance(self._store, module, [])
            self._exp = instance.exports(self._store)
            # CRITICAL: call _start to initialize all MoonBit heap globals
            # (visited_bits, grid_buf, mat_buf, tt_table, etc. are all heap-alloc'd)
            self._exp["_start"](self._store)
            self._wasm_ok = True
        except Exception as e:
            pass  # fallback to pure Python

    # -- Grid write helpers --
    def _write_grid(self, grid: np.ndarray) -> tuple:
        h, w = grid.shape
        flat = grid.ravel().astype(np.int32)
        for i, v in enumerate(flat):
            self._exp["set_grid_cell"](self._store, i, int(v))
            self._exp["set_prev_cell"](self._store, i, int(v))
        return h, w

    def _get_hi(self) -> int:
        return self._exp["rhae_get_hash_hi"](self._store)

    # -- Public API --
    def canonical_hash(self, grid: np.ndarray) -> tuple:
        if not self._wasm_ok:
            return _py_canonical_hash(grid)
        h, w = self._write_grid(grid)
        lo = self._exp["rhae_canonical_hash"](self._store, h, w)
        hi = self._exp["rhae_get_hash_hi"](self._store)
        return (lo & 0x7FFFFFFF, hi & 0x7FFFFFFF)

    def hash_and_check(self, grid: np.ndarray) -> bool:
        """Returns True if this grid state was already visited OR is in TT."""
        if not self._wasm_ok:
            return _py_hash_and_check(grid)
        h, w = self._write_grid(grid)
        result = self._exp["rhae_hash_and_check"](self._store, h, w)
        # bit1 = visited, bit0 = TT hit
        return bool(result & 0b11)

    def visited_mark(self, lo: int, hi: int) -> None:
        if not self._wasm_ok:
            _py_visited_mark(lo, hi)
            return
        self._exp["rhae_visited_mark"](self._store, lo & 0x7FFFFFFF, hi & 0x7FFFFFFF)

    def visited_reset(self) -> None:
        if not self._wasm_ok:
            _py_visited_reset()
            return
        self._exp["rhae_visited_reset"](self._store)

    def tt_store(self, lo: int, hi: int, action: int, score_q8: int) -> None:
        if not self._wasm_ok:
            _py_tt_store(lo, hi, action, score_q8)
            return
        self._exp["rhae_tt_store"](self._store, lo & 0x7FFFFFFF, hi & 0x7FFFFFFF, action, score_q8)

    def tt_lookup(self, lo: int, hi: int) -> int:
        """Returns -1 on miss, else action int (0-indexed) on hit."""
        if not self._wasm_ok:
            return _py_tt_lookup(lo, hi)
        return self._exp["rhae_tt_lookup"](self._store, lo & 0x7FFFFFFF, hi & 0x7FFFFFFF)

    def policy_gate(self, legal_mask: int, grid: np.ndarray, n_actions: int) -> int:
        if not self._wasm_ok:
            return _py_policy_gate(legal_mask, grid, n_actions)
        h, w = self._write_grid(grid)
        for i in range(n_actions):
            self._exp["set_risk"](self._store, i, 0)
        result = self._exp["rhae_policy_gate"](self._store, legal_mask, h, w, n_actions)
        # Ensure at least 1 action preserved
        return result if result else legal_mask

    def build_candidates(self, legal_mask: int, path_cost: int, lo: int, hi: int, max_c: int) -> tuple:
        """Returns (action_list, n_candidates). action_list: 1-indexed action ints."""
        if not self._wasm_ok:
            acts = _py_build_candidates(legal_mask, path_cost, lo, hi, max_c)
            return acts, len(acts)
        n = self._exp["rhae_build_candidates"](
            self._store, legal_mask, path_cost,
            lo & 0x7FFFFFFF, hi & 0x7FFFFFFF, max_c
        )
        CR_STRIDE = 13
        acts = [self._exp["get_mat"](self._store, r * CR_STRIDE) for r in range(n)]
        return acts, n

    def topk(self, actions: list, n_cand: int, k: int) -> list:
        if not self._wasm_ok:
            return _py_topk(actions, k)
        if n_cand == 0:
            return []
        actual_k = self._exp["rhae_topk"](self._store, n_cand, k)
        return [self._exp["get_topk"](self._store, i) for i in range(actual_k)]

    @property
    def has_wasm(self) -> bool:
        return self._wasm_ok


# ---------------------------------------------------------------------------
# 9d. SINGLETON FACTORY
# ---------------------------------------------------------------------------
_RHAE_INSTANCE = None

def get_rhae() -> RhaeEngine:
    global _RHAE_INSTANCE
    if _RHAE_INSTANCE is not None:
        return _RHAE_INSTANCE
    binary = _load_binary(_RHAE_WASM_PATHS)
    _RHAE_INSTANCE = RhaeEngine(binary)
    return _RHAE_INSTANCE

_rhae_singleton = get_rhae()
_HAS_RHAE_WASM: bool = _rhae_singleton.has_wasm
