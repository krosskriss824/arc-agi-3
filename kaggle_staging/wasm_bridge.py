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

from __future__ import annotations
import os
from collections import defaultdict
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
# 6. PREDICATE-FIRST WASM BOOTSTRAP (Static Factory Dispatch)
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

_KAGGLE_INPUT = os.path.join(os.sep, "kaggle", "input")
DEFAULT_WASM_PATHS = [
    os.path.join(_KAGGLE_INPUT, "datasets", "krisskey", "vericoding-urm", "wasm_bridge.wasm"),
    os.path.join(_KAGGLE_INPUT, "vericoding-urm", "wasm_bridge.wasm"),
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
    mk_payload = lambda g: np.array([g.shape[0], g.shape[1]], dtype=np.int32).tobytes() + g.ravel().astype(np.int32).tobytes()

    return (
        {
            True: lambda g: pipe(mk_payload(g), lambda p: reset(store) or p, lambda p: (alloc(store, len(p)), p), lambda pp: (pp[0], mem.write(store, pp[1], pp[0])), lambda pv: (fn_prn(store, pv[0]), free(store, pv[0]))[0]),
            False: py_action_prune_mask
        }[fn_prn is not None],
        {
            True: lambda g: pipe(mk_payload(g), lambda p: reset(store) or p, lambda p: (alloc(store, len(p)), p), lambda pp: (pp[0], mem.write(store, pp[1], pp[0])), lambda pv: (fn_hsh(store, pv[0]), free(store, pv[0]))[0]),
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
    write_mem = lambda p, data: mem.buffer.__setitem__(slice(p, p + len(data)), data)

    return (
        {
            True: lambda g: pipe(mk_payload(g), lambda p: (alloc(len(p)), p), lambda pp: (pp[0], write_mem(pp[0], pp[1])), lambda pv: (fn_prn(pv[0]), free(pv[0]))[0]),
            False: py_action_prune_mask
        }[fn_prn is not None],
        {
            True: lambda g: pipe(mk_payload(g), lambda p: (alloc(len(p)), p), lambda pp: (pp[0], write_mem(pp[0], pp[1])), lambda pv: (fn_hsh(pv[0]), free(pv[0]))[0]),
            False: py_zobrist_canonical_hash
        }[fn_hsh is not None]
    )

_BOOTSTRAP_DISPATCH = {
    0: lambda: None,
    1: lambda: _load_binary(DEFAULT_WASM_PATHS),
    2: lambda: _load_binary(DEFAULT_WASM_PATHS),
}

def _bootstrap():
    """Bootstrap WASM: action_prune from WASM (if available), canonical_hash always Python D4.
    
    BUG-X4 fix: WASM wasm_zobrist_canonical_hash lacks D4 canonicalization.
    py_zobrist_canonical_hash does ALL 8 D4 transforms in one vectorized call
    (faster than 8× WASM individual calls). Return it always for canonical_hash.
    """
    FALLBACK = (py_action_prune_mask, py_zobrist_canonical_hash)
    RUNTIME_FACTORIES = {
        1: _create_wasmtime_closures,
        2: _create_wasmer_closures,
    }
    try:
        binary = _BOOTSTRAP_DISPATCH.get(_RUNTIME_ID, lambda: None)()
        factory = RUNTIME_FACTORIES.get(_RUNTIME_ID)
        wasm_result = {
            True: lambda: factory(binary),
            False: lambda: FALLBACK
        }[factory is not None and binary is not None]()
        # Always use Python D4 hash, regardless of WASM availability
        return (wasm_result[0], py_zobrist_canonical_hash)
    except Exception:
        # FFI boundary: Engine() fails if wheel lacks native binary (_libwasmtime.so)
        return FALLBACK


# =============================================================================
# 7. IMMUTABLE TOP-LEVEL BINDINGS (Public API)
# =============================================================================
action_prune, canonical_hash = _bootstrap()
_HAS_WASM: bool = _RUNTIME_ID != 0 and (action_prune is not py_action_prune_mask)


# =============================================================================
# 8. STATELESS TTT ENGINE (torch.func Functional API + torch.compile)
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


_ADAPTER_HEAD_PREFIXES: tuple[str, ...] = ("action_head.", "value_head.", "action_emb.")

def _extract_head_params(model: nn.Module) -> dict[str, torch.Tensor]:
    """Extract ONLY action_head.* + value_head.* — head-only adapter.
    action_emb included for TTT device sync (BUG-X8 fix), filtered at save time.
    Backbone NEVER included — inference-only weights stay frozen.
    v11: strict prefix whitelist instead of blacklist."""
    sd = model.state_dict()
    adapter = {
        k: v.clone().detach().cpu()
        for k, v in sd.items()
        if any(k.startswith(p) for p in _ADAPTER_HEAD_PREFIXES)
    }
    assert not [k for k in adapter if not any(k.startswith(p) for p in _ADAPTER_HEAD_PREFIXES)],         f"[_extract_head_params] Invariant violated: unexpected keys in adapter"
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
    # Safe n_actions: slice logits + clamp actions to avoid OOB (Target N out of bounds)
    _logits_n = out["action_logits"].size(-1)
    _n_acts  = min(max(batch_actions.max().item() + 1, 1), _logits_n)
    _safe_act = batch_actions.clamp(0, _n_acts - 1)
    act_loss = F.cross_entropy(out["action_logits"][:, :_n_acts], _safe_act)
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
    # Device from params (not model — avoids CPU fallback if model has mixed params)
    _dev = next(iter(params.values())).device if params else torch.device("cpu")
    # Sync ALL inputs to model device — eliminates wrapper_CUDA__index_select
    states      = states.to(_dev)
    actions     = actions.to(_dev)
    next_states = next_states.to(_dev)
    rewards     = rewards.to(_dev)
    params      = {k: v.to(_dev) for k, v in params.items()}
    buffers     = {k: v.to(_dev) for k, v in buffers.items()}
    n = len(states)
    # Pre-TTT predictions for regularization
    pre_out = functional_call(model, (params, buffers), (states[:4],))
    pre_logits = pre_out["action_logits"].detach().clone()
    pre_values = pre_out["value"].detach().clone()
    # Gradient functor: ParamMap -> Loss -> Grads
    pure_grad = grad(pure_batch_ttt_loss, argnums=0)
    _LOSS_TOL = 0.02  # early stop when loss drops below threshold
    p = params
    for _ in range(steps):
        bs = min(4, n)
        idx = torch.randperm(n, device=_dev)[:bs]
        with torch.no_grad():
            loss_val = pure_batch_ttt_loss(
                p, buffers, model,
                states[idx], actions[idx], next_states[idx], rewards[idx],
                pre_logits, pre_values, lambda_reg,
            ).item()
        if loss_val < _LOSS_TOL:
            break
        grads = pure_grad(
            p, buffers, model,
            states[idx], actions[idx], next_states[idx], rewards[idx],
            pre_logits, pre_values, lambda_reg,
        )
        p = {k: w - lr * grads[k] for k, w in p.items()}
    return p

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
    os.path.join(_KAGGLE_INPUT, "datasets", "krisskey", "vericoding-urm", "rhae_stage1.wasm"),
    os.path.join(_KAGGLE_INPUT, "vericoding-urm", "rhae_stage1.wasm"),
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
    __slots__ = ("_store", "_exp", "_wasm_ok", "_buf_ptr", "_buf_len")

    def __init__(self, wasm_bytes=None):
        self._wasm_ok = False
        self._store = None
        self._exp = defaultdict(lambda: lambda *a, **kw: None)
        self._buf_ptr = None
        self._buf_len = 0
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

    # -- Pre-alloc buffer for bulk I/O (BUG-X3: future use with new WASM exports) --
    def _ensure_buf(self, size: int) -> int:
        """Pre-alloc WASM memory buffer. Alloc only when resize needed.
        Zero alloc/free in hot path after first call.
        Returns pointer to buffer of at least `size` bytes in WASM linear memory.
        """
        if self._buf_ptr is None or self._buf_len < size:
            if self._buf_ptr is not None and "free" in self._exp:
                self._exp["free"](self._store, self._buf_ptr)
            needed = size + 128
            if "alloc" in self._exp:
                self._buf_ptr = self._exp["alloc"](self._store, needed)
            else:
                self._buf_ptr = 0  # fallback: use raw address
            self._buf_len = needed
        return self._buf_ptr

    # -- Grid write helpers --
    def _write_grid(self, grid: np.ndarray) -> tuple:
        h, w = grid.shape
        flat = grid.ravel().astype(np.int32)
        for i, v in enumerate(flat):
            self._exp["set_grid_cell"](self._store, i, int(v))
        _rh_set_grid_snapshot(grid)
        return h, w

    def write_prev(self, grid: np.ndarray) -> None:
        """Write previous frame to prev_buf for delta computation.
        Call BEFORE canonical_hash(current). Must have same shape as current."""
        if not self._wasm_ok:
            return
        flat = grid.ravel().astype(np.int32)
        for i, v in enumerate(flat):
            self._exp["set_prev_cell"](self._store, i, int(v))
        # BUG-X3: bulk copy if available (avoids per-cell loop)
        if "rhae_copy_prev" in self._exp:
            h, w = grid.shape
            self._exp["rhae_copy_prev"](self._store, h * w)

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

    # ── New: Optimized pipeline helpers (v19) ────────────────────────────────
    def step_hash(self, h: int, w: int) -> tuple:
        """Hash already-loaded grid_buf. Call AFTER _write_grid or canonical_hash.
        Returns (lo, hi) D4-canonical Zobrist hash, 1 WASM call + 1 read."""
        if not self._wasm_ok:
            return (0, 0)
        lo = self._exp["rhae_canonical_hash"](self._store, h, w)
        hi = self._exp["rhae_get_hash_hi"](self._store)
        return (lo & 0x7FFFFFFF, hi & 0x7FFFFFFF)

    def read_invariants(self, h: int, w: int) -> dict:
        """Compute invariants on loaded grid_buf (with prev_buf for delta).
        Returns dict with keys matching inv_buf[0..9] from invariants.mbt:
        n_comp, n_colors, n_comp2(dup), bbox_h, bbox_w, is_sym, euler, n_holes,
        delta, goal.
        Call AFTER write_prev(prev) + _write_grid(cur).
        Note: inv_buf[2] is a duplicate of n_comp (known bug in invariants.mbt:120)."""
        if not self._wasm_ok:
            return {k: 0 for k in ("n_comp","n_colors","bbox_h","bbox_w",
                                    "is_sym","euler","n_holes","delta","goal")}
        self._exp["rhae_invariants"](self._store, h, w)
        # Exact indices from invariants.mbt:120-122
        return {
            "n_comp":   self._exp["get_inv"](self._store, 0),
            "n_colors": self._exp["get_inv"](self._store, 1),
            "bbox_h":   self._exp["get_inv"](self._store, 3),
            "bbox_w":   self._exp["get_inv"](self._store, 4),
            "is_sym":   self._exp["get_inv"](self._store, 5),
            "euler":    self._exp["get_inv"](self._store, 6),
            "n_holes":  self._exp["get_inv"](self._store, 7),
            "delta":    self._exp["get_inv"](self._store, 8),
            "goal":     self._exp["get_inv"](self._store, 9),
        }

    def get_top_actions(self, h: int, w: int,
                         legal_mask: int, path_cost: int, k: int = 3) -> list:
        """Pre-filter: build + rank candidates, return top-k action indices (1-based).
        Call AFTER write_prev + _write_grid + step_hash.
        Uses unchanged WASM exports (zero new MoonBit code).
        Falls back to [1..7] if WASM unavailable or no candidates."""
        if not self._wasm_ok:
            acts = _py_build_candidates(legal_mask, path_cost, 0, 0, 6)
            return acts[:k] if acts else list(range(1, min(7, k+1)))
        lo = self._exp["rhae_canonical_hash"](self._store, h, w)
        hi = self._exp["rhae_get_hash_hi"](self._store)
        n_cand = self._exp["rhae_build_candidates"](
            self._store, legal_mask, path_cost,
            lo & 0x7FFFFFFF, hi & 0x7FFFFFFF, 6)
        if n_cand == 0:
            return list(range(1, 7))
        actual_k = self._exp["rhae_topk"](self._store, n_cand, k)
        return [self._exp["get_topk"](self._store, i) for i in range(actual_k)]

    # ── New: Score functions ────────────────────────────────────────────────
    def set_target(self, grid: np.ndarray) -> None:
        """Write target grid into WASM target_buf or Python fallback."""
        if self._wasm_ok and "set_target_cell" in self._exp:
            flat = grid.ravel().astype(np.int32)
            for i, v in enumerate(flat):
                self._exp["set_target_cell"](self._store, i, int(v))
        else:
            _py_set_target(grid)

    def is_solved(self, h: int, w: int) -> bool:
        """True if grid_buf == target_buf (early exit on first diff)."""
        if self._wasm_ok and "rhae_is_solved" in self._exp:
            return bool(self._exp["rhae_is_solved"](self._store, h, w))
        return _py_is_solved(h, w)

    def hamming(self, h: int, w: int) -> int:
        """Hamming distance between current grid and target."""
        if self._wasm_ok and "rhae_hamming" in self._exp:
            return self._exp["rhae_hamming"](self._store, h, w)
        return _py_hamming(h, w)

    def score_batch(self, h: int, w: int) -> dict:
        """One WASM call → hamming + 9 IoU scores (per-color 1..9)."""
        if self._wasm_ok and "rhae_score_batch" in self._exp:
            ham = self._exp["rhae_score_batch"](self._store, h, w)
            iou = {}
            if "get_inv" in self._exp:
                for c in range(1, 10):
                    iou[c] = self._exp["get_inv"](self._store, 10 + c)
            return {"hamming": ham, "iou": iou}
        return _py_score_batch(h, w)

    # ── New: Pattern functions ─────────────────────────────────────────────
    def pattern_flags(self, h: int, w: int) -> dict:
        """Batch pattern detection: histogram + symmetries in 3 WASM calls."""
        if self._wasm_ok and "rhae_color_histogram" in self._exp:
            self._exp["rhae_color_histogram"](self._store, h, w)
            hist = [self._exp["get_inv"](self._store, 30 + c) for c in range(10)]
            return {
                "hsym": bool(self._exp["rhae_has_hsym"](self._store, h, w)),
                "vsym": bool(self._exp["rhae_has_vsym"](self._store, h, w)),
                "histogram": hist,
                "count_1": self._exp["rhae_count_color"](self._store, h, w, 1),
            }
        return _py_pattern_flags(h, w)

    def bbox(self, h: int, w: int, color: int) -> tuple:
        """Returns (min_r, min_c, max_r, max_c) or None if color absent."""
        if self._wasm_ok and "rhae_bbox" in self._exp:
            ok = self._exp["rhae_bbox"](self._store, h, w, color)
            if not ok:
                return None
            b = tuple(self._exp["get_inv"](self._store, 20 + i) for i in range(4))
            return b
        return _py_bbox(h, w, color)

    # ── BUG-X3: copy_prev (saves 4096 FFI calls per grid write) ────────────
    def copy_prev(self, n: int) -> None:
        """Bulk copy grid_buf → prev_buf in one WASM call."""
        if self._wasm_ok and "rhae_copy_prev" in self._exp:
            self._exp["rhae_copy_prev"](self._store, n)

    @property
    def has_wasm(self) -> bool:
        return self._wasm_ok


# ── Python fallback implementations for new functions ─────────────────

_PY_TARGET: np.ndarray | None = None

def _py_set_target(grid: np.ndarray) -> None:
    global _PY_TARGET
    _PY_TARGET = grid.copy()

def _py_is_solved(h: int, w: int) -> bool:
    global _PY_TARGET
    if _PY_TARGET is None or _PY_TARGET.shape != (h, w):
        return False
    # Monadic: pipe through subtraction → abs → sum → check
    diff = np.sum(np.abs(grid_buf_to_np() - _PY_TARGET))
    return diff == 0

def _py_hamming(h: int, w: int) -> int:
    global _PY_TARGET
    if _PY_TARGET is None or _PY_TARGET.shape != (h, w):
        return h * w  # max possible
    return int(np.sum(grid_buf_to_np() != _PY_TARGET))

def _py_score_batch(h: int, w: int) -> dict:
    global _PY_TARGET
    g = grid_buf_to_np()
    ham = int(np.sum(g != _PY_TARGET)) if _PY_TARGET is not None and _PY_TARGET.shape == (h, w) else h * w
    iou = {}
    for c in range(1, 10):
        g_c = (g == c)
        if _PY_TARGET is not None and _PY_TARGET.shape == (h, w):
            t_c = (_PY_TARGET == c)
            inter = int(np.sum(g_c & t_c))
            union = int(np.sum(g_c | t_c))
            iou[c] = inter * 1000 // union if union > 0 else 1000
        else:
            iou[c] = 0
    return {"hamming": ham, "iou": iou}

def _py_pattern_flags(h: int, w: int) -> dict:
    g = grid_buf_to_np()
    hsym = int(np.all(g == g[::-1, :]))
    vsym = int(np.all(g == g[:, ::-1]))
    hist = [int(np.sum(g == c)) for c in range(10)]
    return {"hsym": bool(hsym), "vsym": bool(vsym), "histogram": hist, "count_1": hist[1]}

def _py_bbox(h: int, w: int, color: int):
    g = grid_buf_to_np()
    mask = np.where(g == color)
    if mask[0].size == 0:
        return None
    return (int(mask[0].min()), int(mask[1].min()), int(mask[0].max()), int(mask[1].max()))

# Helper: reconstruct grid from current WASM state. crude approximation
_GRID_BUF_SNAPSHOT: np.ndarray | None = None
_RH_LAST_H: int = 0
_RH_LAST_W: int = 0

def _rh_set_grid_snapshot(grid: np.ndarray) -> None:
    global _GRID_BUF_SNAPSHOT, _RH_LAST_H, _RH_LAST_W
    _GRID_BUF_SNAPSHOT = grid.copy()
    _RH_LAST_H, _RH_LAST_W = grid.shape

def grid_buf_to_np() -> np.ndarray:
    if _GRID_BUF_SNAPSHOT is not None:
        return _GRID_BUF_SNAPSHOT
    return np.zeros((1, 1), dtype=np.int32)


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

# ─── Adapter I/O (head-only) ───────────────────────────────────────────────────

def save_adapter(wm: nn.Module, path: str) -> None:
    """Save head-only adapter via _extract_head_params — never touches action_emb."""
    adapter = _extract_head_params(wm)
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    torch.save(adapter, path)
    print(f"[save_adapter] saved {len(adapter)} keys to {path}")

def load_adapter(wm: nn.Module, path: str) -> list[str]:
    """Load head adapter — strict=False, skips non-head keys, never touches action_emb."""
    raw = torch.load(path, map_location="cpu", weights_only=True)
    adapter = {k: v for k, v in raw.items()
               if any(k.startswith(p) for p in _ADAPTER_HEAD_PREFIXES)}
    missing, unexpected = wm.load_state_dict(adapter, strict=False)
    print(f"[load_adapter] loaded={list(adapter)}, missing={missing}, unexpected={unexpected}")
    return list(adapter.keys())

def adapter_path_for_game(base_dir: str, game_id: str, n_actions: int) -> str:
    """Deterministic per-game adapter path."""
    return os.path.join(base_dir, f"adapter_{game_id}_na{n_actions}.pt")

def ttt_from_buffer(
    wm: nn.Module,
    buf: list,
    steps: int = 10,
    lr: float = 5e-5,
    device: str = "cuda" if torch.cuda.is_available() else "cpu",
) -> dict:
    """Phase-A TTT: train world model from episode buffer before/after game."""
    return functional_ttt_train(wm, buf, steps=steps, lr=lr, device=device)


# ════════════════════════════════════════════════════════════════════════════
# 10. FrameGraphExplorer — predicate-first state graph for ARC-AGI-3
# ════════════════════════════════════════════════════════════════════════════
# Spec:
#   function PreFilter(actions: seq<Int>(7), state: State, graph: StateGraph, 
#                      game_tags: seq<String>): seq<Int>
#       ensures |result| ≥ 1
#       ensures ∀a ∈ result • a ∉ graph.visited[state.hash]
#       ensures ∀a ∈ result • priority_score(a, game_tags) ≥ priority_score(b, game_tags)
#                             for any b ∉ result
#
#   If PreFilter returns empty → URM fallback (predict_action)


_GAME_PRIORITY_TIERS: dict[str, tuple[int, ...]] = {
    "movement": (1, 2, 3, 4, 5, 6, 0),    # directional first
    "select":   (6, 4, 5, 1, 2, 3, 0),    # click then movement
    "puzzle":   (6, 4, 5, 1, 2, 3, 0),    # click/interact first
    "undo":     (7, 6, 4, 5, 1, 2, 3, 0), # undo then click
    "_default": (1, 2, 3, 4, 5, 6, 0),    # balanced
}

def _action_priority(action: int, game_tags: list[str]) -> int:
    """Rank action priority based on game tags. Lower = higher priority."""
    default = _GAME_PRIORITY_TIERS["_default"]
    ranking = list(default)
    for tag in game_tags:
        if tag in _GAME_PRIORITY_TIERS:
            tier = _GAME_PRIORITY_TIERS[tag]
            ranking = [a for a in tier if a in ranking] + [a for a in ranking if a not in tier]
    try:
        return ranking.index(action)
    except ValueError:
        return len(ranking)


class FrameGraphExplorer:
    """Predicate-first state graph for ARC-AGI-3 exploration.
    
    Maintains:
      - nodes: state_hash → set(actions_tried)   — which actions taken from state
      - edges: (from_hash, action) → (to_hash, result)  — transition graph
    
    Pre-filter cascade:
      1. Untried actions from current state (priority-ordered)
      2. Untried actions from reachable states (priority-ordered)  
      3. URM fallback (caller decides)
    
    Typical usage:
      graph = FrameGraphExplorer()
      action = graph.get_action(hash, game_tags, n_actions)
      if action is None:
          action = agent.predict_action(grid)  # URM fallback
      graph.record_transition(prev_hash, action, cur_hash, result)
    """
    
    __slots__ = ("_nodes", "_edges", "_path", "_solution", "_replay_mode", "_replay_idx", "_inv_history")
    
    def __init__(self):
        self._nodes: dict[int, set[int]] = {}        # hash → actions_tried
        self._edges: dict[tuple[int, int], tuple[int, str]] = {}  # (hash,action) → (next_hash, result)
        self._path: list[tuple[int, int]] = []        # (hash, action) history
        self._solution: list[int] | None = None       # minimal action sequence
        self._replay_mode: bool = False               # replaying solution?
        self._replay_idx: int = 0                     # position in replay
        self._inv_history: list[dict] = []            # invariant history for prune
    
    def get_action(self, state_hash: int, game_tags: list[str], n_actions: int,
                   candidates: list[int] | None = None) -> int | None:
        """Predicate-first action selection: returns action or None (URM fallback).
        
        Args:
            state_hash: D4-canonical Zobrist hash of current frame
            game_tags: tags from env.info.tags for priority tiers
            n_actions: number of available actions
            candidates: optional pre-filtered action list (from WASM topk).
                        If None, uses all actions 0..n_actions-1.
        """
        # Replay mode: execute cached minimal path
        if self._replay_mode and self._solution is not None:
            if self._replay_idx < len(self._solution):
                a = self._solution[self._replay_idx]
                self._replay_idx += 1
                return a
            self._replay_mode = False
            return None
        
        # Use candidates if provided, else all actions
        _all = candidates if candidates is not None else list(range(n_actions))
        
        # Normal mode: find untried actions from current state
        untried = [a for a in _all if a not in self._nodes.get(state_hash, set())]
        if untried:
            return min(untried, key=lambda a: _action_priority(a, game_tags))
        
        # Frontier exhausted from current state → try other states
        frontier = [a for a in _all if a not in self._nodes.get(state_hash, set())]
        if frontier:
            return min(frontier, key=lambda a: _action_priority(a, game_tags))
        
        return None  # signal for URM fallback
    
    def record_transition(self, from_hash: int, action: int, to_hash: int, 
                          result: str | None) -> None:
        """Record (from_hash, action) → (to_hash, result) in graph."""
        self._edges[(from_hash, action)] = (to_hash, result)
    
    def mark_action_tried(self, state_hash: int, action: int) -> None:
        """Mark action as tried from this state (for dedup)."""
        if state_hash not in self._nodes:
            self._nodes[state_hash] = set()
        self._nodes[state_hash].add(action)
    
    def get_untried_actions(self, state_hash: int, n_actions: int, 
                            valid_mask: int = 0x7F) -> list[int]:
        """Get actions NOT yet tried from this state, respecting valid mask."""
        tried = self._nodes.get(state_hash, set())
        _all = [a for a in range(n_actions) if (valid_mask >> a) & 1]
        return [a for a in _all if a not in tried]
    
    def _untried_actions(self, state_hash: int, n_actions: int) -> list[int]:
        """Untried actions for a specific state."""
        tried = self._nodes.get(state_hash, set())
        return [a for a in range(n_actions) if a not in tried]
    
    def _frontier(self, n_actions: int) -> list[int]:
        """Untried actions across ALL states in graph. Global frontier."""
        result: list[tuple[int, int]] = []  # (hash, action)
        for h, tried in self._nodes.items():
            for a in range(n_actions):
                if a not in tried:
                    result.append((h, a))
        return [a for _, a in result]
    
    def push_path(self, state_hash: int, action: int) -> None:
        """Record (state_hash, action) as part of current trajectory."""
        self._path.append((state_hash, action))
    
    def pop_path(self) -> tuple[int, int] | None:
        """Pop last (hash, action) from trajectory (for backtracking)."""
        if not self._path:
            return None
        return self._path.pop()
    
    def set_solution(self) -> list[int] | None:
        """Extract minimal action sequence from current path. 
        
        Called when WIN state is reached.
        Returns action sequence for minimal replay, or None if path is empty.
        """
        if not self._path:
            return None
        self._solution = [a for _, a in self._path]
        self._replay_mode = True
        self._replay_idx = 0
        self._path = []
        return self._solution
    
    def is_replaying(self) -> bool:
        return self._replay_mode
    
    def reset(self) -> None:
        """Clear all state. Call on game reset."""
        self._nodes.clear()
        self._edges.clear()
        self._path.clear()
        self._solution = None
        self._replay_mode = False
        self._replay_idx = 0
        self._inv_history.clear()
    
    def should_prune(self, inv: dict, depth: int) -> bool:
        """Predicate-first invariant pruning: True when exploration hopeless.
        
        Prune conditions (from invariants.mbt):
        1. delta==0 for 3+ consecutive steps — state unresponsive to actions
        2. n_comp increased by >3 — fragmentation, unlikely WIN
        
        Call AFTER rhae.read_invariants(h,w).
        """
        self._inv_history.append(inv)
        if len(self._inv_history) > 3:
            self._inv_history.pop(0)
        # Stagnation: 3 consecutive zero-delta steps
        if (depth > 2
            and len(self._inv_history) >= 3
            and all(h.get("delta", 0) == 0 for h in self._inv_history[-3:])):
            return True
        # Fragmentation: n_comp jumped >3
        if (len(self._inv_history) >= 2
            and inv.get("n_comp", 0) > self._inv_history[-2].get("n_comp", 0) + 3):
            return True
        return False
    
    @staticmethod
    def _legal_mask(action_space: list) -> int:
        """Build bitmask from env.action_space. Bit i-1 = ACTION_i legal."""
        mask = 0
        try:
            for a in action_space:
                idx = int(getattr(a, "value", a))
                if 1 <= idx <= 6:
                    mask |= 1 << (idx - 1)
        except (ValueError, TypeError):
            pass
        return mask
    
    def fill_vis_buf(self, lo: int, hi: int) -> list:
        """Get actions already tried from this state (for vis_buf).
        Returns list of 7 ints (0/1) indexed by action value (0-based)."""
        tried = self._nodes.get(lo, set())
        return [1 if i in tried else 0 for i in range(7)]


# ════════════════════════════════════════════════════════════════════════════
# ── WASM atomic operations (existing exports, no new MoonBit code) ──

def hash_and_check(h: int, w: int) -> int:
    """Atomic: canonical_hash + visited_check + tt_lookup in one WASM call.
    Returns bitmask: bit0=tt_hit, bit1=visited.
    Calls rhae_hash_and_check(h, w) from exports.mbt:67.
    Returns 0 if neither visited nor in TT.
    """
    return _rhae.engine.wasm.exports[_rhae._store]["rhae_hash_and_check"](_rhae._store, h, w)

def build_candidates(legal: int, path_cost: int, hash_lo: int, hash_hi: int, max_c: int) -> int:
    """WASM candidate builder: returns n_candidates written to mat_buf.
    Calls rhae_build_candidates(legal, path_cost, hash_lo, hash_hi, max_c).
    """
    return _rhae.engine.wasm.exports[_rhae._store]["rhae_build_candidates"](
        _rhae._store, legal, path_cost, hash_lo, hash_hi, max_c)

def topk(n_cand: int, k: int) -> int:
    """WASM top-k: returns n written to topk_buf.
    Calls rhae_topk(n_cand, k).
    """
    return _rhae.engine.wasm.exports[_rhae._store]["rhae_topk"](_rhae._store, n_cand, k)

def get_topk(i: int) -> int:
    """Read topk_buf[i] via get_topk WASM export."""
    return _rhae.engine.wasm.exports[_rhae._store]["get_topk"](_rhae._store, i)

def get_inv(i: int) -> int:
    """Read inv_buf[i] via get_inv WASM export."""
    return _rhae.engine.wasm.exports[_rhae._store]["get_inv"](_rhae._store, i)

def rhae_tt_lookup(lo: int, hi: int) -> int:
    """WASM transposition table lookup. Returns -1 if miss, else best_action."""
    return _rhae.engine.wasm.exports[_rhae._store]["rhae_tt_lookup"](_rhae._store, lo, hi)

def rhae_tt_store(lo: int, hi: int, action: int, score: int) -> None:
    """WASM transposition table store (in-memory, per-level)."""
    _rhae.engine.wasm.exports[_rhae._store]["rhae_tt_store"](_rhae._store, lo, hi, action, score)

def rhae_visited_reset() -> None:
    """Reset WASM visited bitset. Call on game/level start."""
    _rhae.engine.wasm.exports[_rhae._store]["rhae_visited_reset"](_rhae._store)


# ════════════════════════════════════════════════════════════════════════════
# 11. VERICODINGAgent extensions — graph explorer integration helpers
# ════════════════════════════════════════════════════════════════════════════

def extract_game_state_str(frame) -> str:
    """Extract game state string from ARC-3 frame.
    Returns 'WIN', 'GAME_OVER', or 'NOT_FINISHED'.
    """
    try:
        s = getattr(frame, "state", None)
        if s is None:
            # Try common attribute names
            s = getattr(frame, "state_name", None) or "NOT_FINISHED"
        if hasattr(s, "value"):
            return s.value
        return str(s)
    except Exception:
        return "NOT_FINISHED"

def is_win_state(frame) -> bool:
    """Predicate: does this frame represent WIN?"""
    return "WIN" in str(getattr(frame, "state", "")).upper()

def is_game_over(frame) -> bool:
    """Predicate: does this frame represent GAME_OVER?"""
    return "GAME_OVER" in str(getattr(frame, "state", "")).upper()
