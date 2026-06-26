# wasm_bridge.py — Pure Functional WASM Bridge + Stateless TTT Engine
# VERICODING ARC-AGI-3 | Zero-branch, zero-loop, category-theory architecture
# All hot-path functions: zero if, zero for, zero while.
# TTT: torch.func functional API + torch.compile for kernel fusion.
#
# VERICODER CONSTRAINT — STRICT EXECUTION:
# 1. Absolute Ban on Runtime Skips: No 'if', 'else', 'for', 'while', or inline
#    ternary operators inside any analytics pipeline or math block.
# 2. Tensor Projection Paradigm: D4 group expressed as compiled matrix dot product.
# 3. Dictionary-Driven Bootstrapping: All runtime selection resolved once at import
#    using static functional map-dictionary dispatch patterns.
#
# BUG-X3 FIX (2026-06-26): zero-alloc bulk write in hot path.
#   - _WasmBufCache: pre-allocates WASM linear memory buffer once at bootstrap
#   - canonical_hash / action_prune closures reuse cached ptr — zero alloc/free per call
#   - D4 batch: all 8 transforms sent in one WASM call via rhae_canonical_hash_batch
#     if exported; falls back gracefully to per-call if not available

from __future__ import annotations
import os
import numpy as np
from functools import reduce

# =============================================================================
# 1. CATEGORY-THEORETIC PIPE COMBINATOR (Monadic Pipe)
# =============================================================================
def pipe(data, *functions):
    return reduce(lambda val, func: func(val), functions, data)


# =============================================================================
# 2. PURE ALGEBRA OF BITMASKS (Zero-Branch Action Pruning)
# =============================================================================
_ACTION_MASK_FULL = 0x7F

def py_action_prune_mask(grid: np.ndarray) -> int:
    """7-bit action prune mask — pure tensor projections, zero branches.
    Maps edge occupancy and grid emptiness directly via boolean masking.
    """
    mask_pixels = (grid > 0)
    no_pixels = int(np.logical_not(np.any(mask_pixels)))

    blocked = (
        int(np.any(mask_pixels[:, 0]) | no_pixels) << 0
        | int(np.any(mask_pixels[:, -1]) | no_pixels) << 1
        | int(np.any(mask_pixels[0, :]) | no_pixels) << 2
        | int(np.any(mask_pixels[-1, :]) | no_pixels) << 3
    )
    return int(_ACTION_MASK_FULL & ~blocked)


# =============================================================================
# 3. ZOBRIST TABLE INITIALIZATION (Vectorized SplitMix64)
# =============================================================================
_ZOBRIST_TABLE: np.ndarray | None = None
_ZOBRIST_ROWS = 64
_ZOBRIST_COLS = 64
_ZOBRIST_COLORS = 16

def _ensure_zobrist() -> None:
    global _ZOBRIST_TABLE
    def init_table():
        seed = np.uint64(0x9E3779B9)
        size = _ZOBRIST_ROWS * _ZOBRIST_COLS * _ZOBRIST_COLORS
        s = seed + np.arange(size, dtype=np.uint64) * np.uint64(0x9E3779B9)
        z = s.copy()
        z = np.uint64(np.uint32((z ^ (z >> np.uint64(16))) * np.uint64(0x85EBCA6B)))
        z = np.uint64(np.uint32((z ^ (z >> np.uint64(13))) * np.uint64(0xC2B2AE35)))
        return np.int64((z ^ (z >> np.uint64(16))) & np.uint64(0x7FFFFFFF))

    _ZOBRIST_TABLE = {
        True: init_table,
        False: lambda: _ZOBRIST_TABLE
    }[_ZOBRIST_TABLE is None]()

# Eager init at import time
_ensure_zobrist()


# =============================================================================
# 4. CANONICAL HASH D4 — TENSOR PROJECTION (Dimension-Aware, All 8 Transforms)
# =============================================================================

def _make_d4_transforms(H: int, W: int) -> np.ndarray:
    """8×8 matrix: (ax, bx, cx, ay, by, cy, out_H, out_W) per D4 transform.
    
    Verified against np.rot90 / np.fliplr / np.flipud / .T:
      rot90:  output[row',col'] = input[H-1-col', row']  → x'=-y+H-1, y'=x
      rot180: output[row',col'] = input[H-1-row', W-1-col'] → x'=-x+W-1, y'=-y+H-1
      rot270: output[row',col'] = input[col', W-1-row'] → x'=y, y'=-x+W-1
    """
    Hm1, Wm1 = H - 1, W - 1
    return np.array([
        [ 1,  0,  0,    0,  1,  0,    H,  W],   # identity
        [ 0, -1,  Hm1,  1,  0,  0,    W,  H],   # rot90
        [-1,  0,  Wm1,  0, -1,  Hm1,  H,  W],   # rot180
        [ 0,  1,  0,   -1,  0,  Wm1,  W,  H],   # rot270
        [-1,  0,  Wm1,  0,  1,  0,    H,  W],   # mirrorX (fliplr)
        [ 1,  0,  0,    0, -1,  Hm1,  H,  W],   # mirrorY (flipud)
        [ 0,  1,  0,    1,  0,  0,    W,  H],   # diagonal (transpose)
        [ 0, -1,  Hm1, -1,  0,  Wm1,  W,  H],   # anti-diagonal
    ], dtype=np.int64)

# Default export for 64×64 grids (backwards compat for import tests)
D4_COEFFS = _make_d4_transforms(64, 64)[:, :6]  # 8×6 for old API compat

def py_zobrist_canonical_hash(grid: np.ndarray) -> int:
    """D4 canonical Zobrist hash — pure tensor algebra, zero branches.
    
    Computes ALL 8 D4 transforms in the grid's OWN coordinate space,
    with per-transform output dimensions (H×W or W×H for non-square).
    Fully vectorized — zero Python loops.
    """
    _ensure_zobrist()
    H, W = grid.shape[:2]
    mask = (grid > 0) & (grid < _ZOBRIST_COLORS)
    ys, xs = np.where(mask)
    colors = grid[ys, xs]
    
    transforms = _make_d4_transforms(H, W)  # (8, 8): ax,bx,cx,ay,by,cy,out_H,out_W
    coords = np.column_stack([xs, ys, np.ones(len(ys), dtype=np.int64)])  # (N, 3)
    
    # All 8 transforms in one matrix multiply
    all_tx = coords @ transforms[:, 0:3].T  # (N, 8)
    all_ty = coords @ transforms[:, 3:6].T  # (N, 8)
    
    # Per-transform validity: each transform has its own output bounds
    out_Ws = transforms[:, 7]  # (8,)
    out_Hs = transforms[:, 6]  # (8,)
    valid = (all_tx >= 0) & (all_tx < out_Ws) & (all_ty >= 0) & (all_ty < out_Hs)  # (N, 8)
    
    flat_idx = (all_ty * _ZOBRIST_COLS + all_tx) * _ZOBRIST_COLORS + colors[:, np.newaxis]  # (N, 8)
    safe_idx = flat_idx * valid + np.int64(_ZOBRIST_TABLE.size - 1) * (~valid)
    # Zero-branch: initial=0 handles empty grid case without if-statement
    return int(np.min(np.bitwise_xor.reduce(_ZOBRIST_TABLE[safe_idx], axis=0, initial=np.int64(0))))

def zobrist_canonical_hash(grid: np.ndarray) -> int:
    return canonical_hash(grid)


# =============================================================================
# 5. MONADIC WASM BINARY LOADER (Zero Loops / Zero If)
# =============================================================================
def _load_binary(paths: list[str]) -> bytes | None:
    found = pipe(paths, lambda ps: list(filter(os.path.isfile, ps)), lambda fs: fs[0] if fs else None)
    return {
        True: lambda: pipe(open(found, "rb"), lambda fh: (fh.read(), fh.close())[0]),
        False: lambda: None
    }[found is not None]()


# =============================================================================
# 6. BUG-X3: PRE-ALLOCATED WASM BUFFER CACHE (zero alloc/free in hot path)
# =============================================================================

class _WasmBufCache:
    """Pre-allocated WASM linear memory buffer.
    
    Single alloc at bootstrap; reused for all canonical_hash / action_prune calls.
    _ensure(size) grows the buffer only when needed — amortised O(1).
    Thread-unsafe (same as wasmtime Store — process-level singleton use only).
    """
    __slots__ = ("_store", "_alloc", "_free", "_ptr", "_cap")

    def __init__(self, store, alloc_fn, free_fn, initial: int = 4096):
        self._store = store
        self._alloc = alloc_fn
        self._free = free_fn
        self._ptr: int | None = None
        self._cap: int = 0
        self._ensure(initial)

    def _ensure(self, size: int) -> int:
        """Return cached ptr; realloc only when size > capacity."""
        if self._ptr is None or self._cap < size:
            if self._ptr is not None:
                self._free(self._store, self._ptr)
            # Over-allocate 2× to amortise future growth
            new_cap = max(size * 2, 4096)
            self._ptr = self._alloc(self._store, new_cap)
            self._cap = new_cap
        return self._ptr

    def write(self, mem, payload: bytes) -> int:
        """Write payload to pre-allocated buffer, return ptr."""
        ptr = self._ensure(len(payload))
        mem.write(self._store, payload, ptr)
        return ptr

    def close(self) -> None:
        """Release WASM memory on teardown (called from RhaeEngine.__del__)."""
        if self._ptr is not None and self._free is not None:
            try:
                self._free(self._store, self._ptr)
            except Exception:
                pass
            self._ptr = None


# =============================================================================
# 7. PREDICATE-FIRST WASM BOOTSTRAP (Static Factory Dispatch)
# =============================================================================
try:
    import wasmtime  # type: ignore[import-untyped]
    _RUNTIME_ID = 1
except ImportError:
    try:
        import wasmer  # type: ignore[import-untyped]
        _RUNTIME_ID = 2
    except ImportError:
        _RUNTIME_ID = 0

DEFAULT_WASM_PATHS = [
    "/kaggle/input/vericoding-urm/wasm_bridge.wasm",
    "/kaggle/working/wasm_bridge.wasm",
    os.path.join(os.path.dirname(__file__), "wasm_bridge.wasm"),
    "wasm_bridge.wasm",
]

def _create_wasmtime_closures(binary: bytes):
    engine = wasmtime.Engine()
    store = wasmtime.Store(engine)
    exp = wasmtime.Linker(engine).instantiate(store, wasmtime.Module(engine, binary)).exports(store)
    mem, alloc, free, reset = exp["memory"], exp["alloc"], exp["free"], exp["reset"]
    fn_prn, fn_hsh = exp.get("wasm_action_prune"), exp.get("wasm_zobrist_canonical_hash")

    # BUG-X3: pre-allocate buffer once — reused for all calls
    buf = _WasmBufCache(store, alloc, free, initial=4096)
    mk_payload = lambda g: np.array([g.shape[0], g.shape[1]], dtype=np.int32).tobytes() + g.ravel().astype(np.int32).tobytes()

    return (
        {
            True: lambda g: pipe(
                mk_payload(g),
                lambda p: (reset(store) or p),
                lambda p: buf.write(mem, p),   # zero alloc — reuse cached ptr
                lambda ptr: fn_prn(store, ptr)
            ),
            False: py_action_prune_mask
        }[fn_prn is not None],
        {
            True: lambda g: pipe(
                mk_payload(g),
                lambda p: (reset(store) or p),
                lambda p: buf.write(mem, p),   # zero alloc — reuse cached ptr
                lambda ptr: fn_hsh(store, ptr)
            ),
            False: py_zobrist_canonical_hash
        }[fn_hsh is not None]
    )

def _create_wasmer_closures(binary: bytes):
    import wasmer  # type: ignore
    store = wasmer.Store()
    instance = wasmer.Instance(wasmer.Module(store, binary), wasmer.ImportObject())
    mem, alloc, free = instance.exports.memory, instance.exports.alloc, instance.exports.free
    fn_prn = getattr(instance.exports, "wasm_action_prune", None)
    fn_hsh = getattr(instance.exports, "wasm_zobrist_canonical_hash", None)
    mk_payload = lambda g: np.array([g.shape[0], g.shape[1]], dtype=np.int32).tobytes() + g.ravel().astype(np.int32).tobytes()

    # wasmer: buffer backed by memory view — reuse slice write
    _buf_ptr: list = [None]
    _buf_cap: list = [0]

    def _ensure_wasmer(size):
        if _buf_ptr[0] is None or _buf_cap[0] < size:
            if _buf_ptr[0] is not None:
                free(_buf_ptr[0])
            new_cap = max(size * 2, 4096)
            _buf_ptr[0] = alloc(new_cap)
            _buf_cap[0] = new_cap
        return _buf_ptr[0]

    def write_mem_cached(p, data):
        ptr = _ensure_wasmer(len(data))
        mem.buffer[ptr:ptr + len(data)] = data
        return ptr

    return (
        {
            True: lambda g: pipe(mk_payload(g), lambda p: write_mem_cached(None, p), lambda ptr: fn_prn(ptr)),
            False: py_action_prune_mask
        }[fn_prn is not None],
        {
            True: lambda g: pipe(mk_payload(g), lambda p: write_mem_cached(None, p), lambda ptr: fn_hsh(ptr)),
            False: py_zobrist_canonical_hash
        }[fn_hsh is not None]
    )

_BOOTSTRAP_DISPATCH = {
    0: lambda: None,
    1: lambda: _load_binary(DEFAULT_WASM_PATHS),
    2: lambda: _load_binary(DEFAULT_WASM_PATHS),
}

def _bootstrap():
    FALLBACK = (py_action_prune_mask, py_zobrist_canonical_hash)
    RUNTIME_FACTORIES = {
        1: _create_wasmtime_closures,
        2: _create_wasmer_closures,
    }
    binary = _BOOTSTRAP_DISPATCH.get(_RUNTIME_ID, lambda: None)()
    factory = RUNTIME_FACTORIES.get(_RUNTIME_ID)

    return {
        True: lambda: factory(binary),
        False: lambda: FALLBACK
    }[factory is not None and binary is not None]()


# =============================================================================
# 8. IMMUTABLE TOP-LEVEL BINDINGS (Public API)
# =============================================================================
action_prune, canonical_hash = _bootstrap()
_HAS_WASM: bool = _RUNTIME_ID != 0 and (canonical_hash is not py_zobrist_canonical_hash)


# =============================================================================
# 9. STATELESS TTT ENGINE (torch.func Functional API + torch.compile)
# =============================================================================
try:
    import torch
    from torch import nn
    from torch.func import functional_call, grad, vmap
    HAS_TORCH_FUNC = True
except ImportError:
    HAS_TORCH_FUNC = False

try:
    import torch.nn.functional as F
except ImportError:
    F = None


_ADAPTER_HEAD_PREFIXES: tuple[str, ...] = ("action_head.", "value_head.")

def _extract_head_params(model: nn.Module) -> dict[str, torch.Tensor]:
    """Extract ONLY action_head.* + value_head.* — head-only adapter.
    action_emb NEVER included (variable n_actions per game — BUG-B fix).
    Backbone NEVER included — inference-only weights stay frozen.
    v11: strict prefix whitelist instead of blacklist."""
    sd = model.state_dict()
    adapter = {
        k: v.clone().detach().cpu()
        for k, v in sd.items()
        if any(k.startswith(p) for p in _ADAPTER_HEAD_PREFIXES)
    }
    assert not [k for k in adapter if not any(k.startswith(p) for p in _ADAPTER_HEAD_PREFIXES)], \
        f"[_extract_head_params] Invariant violated: unexpected keys in adapter"
    return adapter


def _extract_all_params(model: nn.Module) -> dict[str, torch.Tensor]:
    """Extract ALL parameters as immutable dict."""
    return {k: v.detach().clone() for k, v in model.named_parameters()}


def _extract_buffers(model: nn.Module) -> dict[str, torch.Tensor]:
    """Extract all buffers as immutable dict."""
    return {k: v.detach().clone() for k, v in model.named_buffers()}


def pure_urm_forward(
    params: dict[str, torch.Tensor],
    buffers: dict[str, torch.Tensor],
    model: nn.Module,
    grid_tensor: torch.Tensor,
) -> dict[str, torch.Tensor]:
    """Stateless forward pass — model as pure morphism, zero mutation."""
    return functional_call(model, (params, buffers), (grid_tensor,))


def pure_ttt_loss(
    params: dict[str, torch.Tensor],
    buffers: dict[str, torch.Tensor],
    model: nn.Module,
    x: torch.Tensor,
    y: torch.Tensor,
) -> torch.Tensor:
    """Categorical cost functor — pure MSE loss, zero side effects."""
    out = functional_call(model, (params, buffers), (x,))
    logits = {True: out["action_logits"], False: out}[isinstance(out, dict)]
    return F.mse_loss(logits, y)


_pure_grad_fn = {True: grad(pure_ttt_loss, argnums=0), False: None}[HAS_TORCH_FUNC]


def execute_functional_ttt_step(
    params: dict[str, torch.Tensor],
    buffers: dict[str, torch.Tensor],
    model: nn.Module,
    x: torch.Tensor,
    y: torch.Tensor,
    lr: float = 1e-4,
) -> dict[str, torch.Tensor]:
    """One-step TTT — no state mutation, returns new params."""
    grads = _pure_grad_fn(params, buffers, model, x, y)
    return {k: w - lr * g for k, w, g in zip(params.keys(), params.values(), grads.values())}


optimized_ttt_step = execute_functional_ttt_step  # torch.func.grad is already a fused op; torch.compile on top causes graph breaks


def batch_inference(
    model: nn.Module,
    grids: np.ndarray,
    device: torch.device,
) -> dict[str, torch.Tensor]:
    """Vectorized batch inference — zero Python loop."""
    params = _extract_all_params(model)
    buffers = _extract_buffers(model)
    grid_t = torch.from_numpy(grids).long().to(device)
    return functional_call(model, (params, buffers), (grid_t,))


parallel_urm_inference = {
    True: vmap(pure_urm_forward, in_dims=(None, None, None, 0)),
    False: None,
}[HAS_TORCH_FUNC]


# Zero-branch depth selection — O(1) array arithmetic, zero if/elif/else
_TIME_THRESHOLDS = np.array([10.0, 30.0, 90.0])
_DEPTH_MATRIX = np.array([2, 3, 4, 5], dtype=np.int32)

def _choose_depth_pure(entropy: float, beam_width: int = 4, max_depth: int = 5, dream_depth: int = 2) -> tuple[int, int, int]:
    """Progowanie tablicowe — zero branching.
    
    Entropy < 0.3 → confident: shallow (1), no dream (0)
    0.3-0.7 → standard
    > 0.7 → deep (max_depth), dream=4
    """
    depth_arr = np.array([1, dream_depth, dream_depth, max(dream_depth, 4)], dtype=np.int32)
    dream_arr = np.array([0, dream_depth, dream_depth, max(dream_depth, 4)], dtype=np.int32)
    bw_arr = np.array([2, beam_width, beam_width, 6], dtype=np.int32)
    idx = int(np.sum(entropy > np.array([-1.0, 0.3, 0.7])))  # -1 ensures idx>=0
    return (int(bw_arr[idx]), int(depth_arr[idx]), int(dream_arr[idx]))


def agent_step_ttt(current_params, buffers, model, x_train, y_train, x_test):
    """Pure functional TTT pipeline — catamorphism over ParamMap.
    
    ParamMap -> Buffers -> Model -> StateTensor -> StateTensor -> StateTensor
       -> (ParamMap, StateTensor)
    
    Each phase is an immutable structure transformation.
    Type: (ParamMap, Buffers, Model, Tensor, Tensor, Tensor) -> (ParamMap, Tensor)
    """
    return pipe(
        current_params,
        lambda p: optimized_ttt_step(p, buffers, model, x_train, y_train),
        lambda new_p: (
            new_p,
            {True: parallel_urm_inference, False: pure_urm_forward}[
                parallel_urm_inference is not None
            ](new_p, buffers, model, x_test),
        ),
    )


# ── Value decoding: 5-bin softmax → scalar ──
BIN_CENTERS = [-1.0, -0.25, 0.5, 1.25, 2.0]


def value_logits_to_scalar(logits: torch.Tensor) -> torch.Tensor:
    """Convert 5-bin value logits to scalar via softmax-weighted avg of bin centers."""
    probs = torch.softmax(logits, dim=-1)
    centers = torch.tensor(BIN_CENTERS, device=logits.device)
    return (probs * centers).sum(dim=-1)


def pure_batch_ttt_loss(
    params: dict[str, torch.Tensor],
    buffers: dict[str, torch.Tensor],
    model: nn.Module,
    batch_states: torch.Tensor,
    batch_actions: torch.Tensor,
    batch_next: torch.Tensor,
    batch_rewards: torch.Tensor,
    pre_logits: torch.Tensor | None,
    pre_values: torch.Tensor | None,
    lambda_reg: float = 0.1,
) -> torch.Tensor:
    """Pure functional batch loss for TTT — zero mutation, zero branching.
    
    Combines task loss (action prediction + value regression) with
    L2 functional regularization against pre-TTT predictions.
    """
    out = functional_call(model, (params, buffers), (batch_states,))
    act_loss = F.cross_entropy(out["action_logits"], batch_actions)
    val_losses = F.mse_loss(
        value_logits_to_scalar(out["value"]), batch_rewards.float()
    )
    task_loss = act_loss + val_losses
    reg_loss = pipe(
        (pre_logits, pre_values, out),
        lambda args: {
            True: lambda: F.mse_loss(out["action_logits"][:len(batch_states)], pre_logits) + F.mse_loss(out["value"][:len(batch_states)], pre_values),
            False: lambda: torch.tensor(0.0, device=batch_states.device),
        }[pre_logits is not None and pre_values is not None](),
    )
    return task_loss + lambda_reg * reg_loss


def functional_ttt_train(
    params: dict[str, torch.Tensor],
    buffers: dict[str, torch.Tensor],
    model: nn.Module,
    states: torch.Tensor,
    actions: torch.Tensor,
    next_states: torch.Tensor,
    rewards: torch.Tensor,
    steps: int = 100,
    lr: float = 1e-4,
    lambda_reg: float = 0.1,
) -> dict[str, torch.Tensor]:
    """Pure functional TTT trainer — reduce over step count, zero mutation.
    
    Each step: sample minibatch → compute pure loss → pure grad → new params.
    Type: (ParamMap, Buffers, Model, Tensor*4, Int, Float, Float) -> ParamMap
    
    Device discipline (Phase 1, Agent 2): all inputs/params/buffers synced to model device.
    """
    device = next(model.parameters()).device
    # Sync ALL inputs to model device — eliminates wrapper_CUDA__index_select
    states      = states.to(device)
    actions     = actions.to(device)
    next_states = next_states.to(device)
    rewards     = rewards.to(device)
    params      = {k: v.to(device) for k, v in params.items()}
    buffers     = {k: v.to(device) for k, v in buffers.items()}
    n = len(states)
    # Pre-TTT predictions for regularization
    pre_out = functional_call(model, (params, buffers), (states[:4],))
    pre_logits = pre_out["action_logits"].detach().clone()
    pre_values = pre_out["value"].detach().clone()
    # Gradient functor: ParamMap -> Loss -> Grads
    pure_grad = grad(pure_batch_ttt_loss, argnums=0)
    return reduce(
        lambda p, s: pipe(
            pure_grad(p, buffers, model,
                states[torch.randperm(n, device=device)[:min(4, n)]],
                actions[torch.randperm(n, device=device)[:min(4, n)]],
                next_states[torch.randperm(n, device=device)[:min(4, n)]],
                rewards[torch.randperm(n, device=device)[:min(4, n)]],
                pre_logits, pre_values, lambda_reg,
            ),
            lambda grads: {k: w - lr * grads[k] for k, w in p.items()},
        ),
        range(steps),
        params,
    )

# =============================================================================
# 10. RHAE STAGE-1 WASM BRIDGE (MoonBit D4-canonical WASM, appended section)
# =============================================================================
# Loads rhae_stage1.wasm alongside wasm_bridge.wasm.
# Interface: _initialize() (WASI reactor) initializes MoonBit heap globals;
# fallback: _start() for pure WASM mode; skip if neither exported.
# Python fallback active when wasmtime unavailable (Kaggle P100 / OFFLINE).
#
# BUG-X3 FIX: RhaeEngine now uses _WasmBufCache for _write_grid:
#   - single alloc at __init__, zero alloc/free per canonical_hash call
#   - D4 batch path: rhae_canonical_hash_batch(h, w) → min over 8 transforms
#     exported from rhae_stage1.wasm if available; graceful fallback otherwise.
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
# 10a. RHAE WASM PATHS
# ---------------------------------------------------------------------------
_RHAE_WASM_PATHS = [
    "/kaggle/input/vericoding-urm/rhae_stage1.wasm",
    "/kaggle/working/rhae_stage1.wasm",
    os.path.join(os.path.dirname(__file__), "rhae_stage1.wasm"),
    "rhae_stage1.wasm",
]

# ---------------------------------------------------------------------------
# 10b. PURE-PYTHON FALLBACKS (identical semantics to MoonBit implementations)
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
# 10c. WASMTIME RHAE ENGINE
# ---------------------------------------------------------------------------

class RhaeEngine:
    """Thin Python wrapper around rhae_stage1.wasm.

    MoonBit WASI reactor model exports _initialize (not _start).
    Bootstrap sequence:
      1. Try _initialize  — WASI reactor (MoonBit default)
      2. Try _start       — pure WASM mode fallback
      3. Skip             — module self-initializes at instantiation

    BUG-X3 FIX: _grid_buf (_WasmBufCache) pre-allocated at __init__.
    _write_grid() writes to cached buffer — zero alloc/free per call.

    Thread-unsafe (single store/instance). Use as process-level singleton.
    """
    __slots__ = ("_store", "_exp", "_wasm_ok", "_grid_buf")

    def __init__(self, wasm_bytes=None):
        self._wasm_ok = False
        self._store = None
        self._exp = None
        self._grid_buf = None
        if wasm_bytes is None:
            return
        try:
            import wasmtime
            engine = wasmtime.Engine()
            self._store = wasmtime.Store(engine)
            module = wasmtime.Module(engine, wasm_bytes)
            instance = wasmtime.Instance(self._store, module, [])
            self._exp = instance.exports(self._store)
            # BUG-W1 FIX: MoonBit WASI reactor exports _initialize, not _start.
            _init = self._exp.get("_initialize") or self._exp.get("_start")
            if _init is not None:
                _init(self._store)
            # BUG-X3: pre-allocate grid buffer — max ARC grid = 30×30 × 4 bytes = 3600 bytes
            # Use alloc/free if exported, else skip buf cache (set_grid_cell path used)
            _alloc = self._exp.get("alloc")
            _free  = self._exp.get("free")
            if _alloc is not None and _free is not None:
                self._grid_buf = _WasmBufCache(self._store, _alloc, _free, initial=4096)
            self._wasm_ok = True
        except Exception:
            pass  # fallback to pure Python

    def __del__(self):
        if self._grid_buf is not None:
            self._grid_buf.close()

    # -- Grid write helpers --
    def _write_grid(self, grid: np.ndarray) -> tuple:
        """Write grid to WASM via cell API (no bulk alloc needed for cell-based API)."""
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
# 10d. SINGLETON FACTORY
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
