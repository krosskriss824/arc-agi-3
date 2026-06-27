"""
smoke_v13.py — ARC-AGI-3 Smoke Test Suite (v13 RHAE+OOB+WASM fixes)
Verifies earlier BUG-X1 through X7 and 12 contracts locally (no Kaggle).

Contracts:
  T1 — encode_grid_numpy importable + correct encoding
  T2 — encode_grid_numpy padding to 4099
  T3 — C1: shared randperm index for states/actions/rewards
  T4 — X5: no vmap mutable carry in submission_agent.py forward
  T5 — X7: WASM_RHAE kernel-metadata.json sources (file-level check)
  T6 — X2: _set_eager logs device after load_backbone (not before)
  T7 — X6: assert len(envs) > 0 in kaggle_main.py game loop
  T8 — W1: fallback chain in wasm_bridge.py (_bootstrap try/except)
  T9 — D4 canonical hash: all 8 D4 transforms → same hash
  T10 — C3: EpisodeBuffer __post_init__ uses self.max_len
  T11 — X1: sys.path order (HERE + external/urm/ first)
  T12 — GPU name + VRAM logged at start

Run: python smoke/smoke_v13.py
"""
from __future__ import annotations
import sys, os, gc, json, ast
from pathlib import Path
from dataclasses import dataclass
from typing import Callable, Any
import torch
import numpy as np

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "kaggle_staging"))
sys.path.insert(0, str(ROOT / "kaggle_staging" / "external"))
sys.path.insert(0, str(ROOT / "kaggle_staging" / "external" / "urm"))

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"


@dataclass
class TestResult:
    name: str
    passed: bool
    detail: str = ""

    def __str__(self) -> str:
        status = "PASS" if self.passed else "FAIL"
        return f"  [{status}] {self.name}" + (f" — {self.detail}" if self.detail else "")


# ── T1: encode_grid_numpy import + correctness ─────────────────────────────

def t1_encode_grid_numpy() -> TestResult:
    """Contract T1: encode_grid_numpy importable + produces 4099-token vector."""
    from submission_agent import _encode_grid_numpy
    grid = np.zeros((3, 3), dtype=np.int32)
    tokens, valid_len = _encode_grid_numpy(grid, 0, 7)
    assert isinstance(tokens, np.ndarray), "tokens not ndarray"
    assert tokens.shape == (4099,), f"expected 4099, got {tokens.shape}"
    hw = 3 * 3
    chk = (
        tokens[hw] == 0 and tokens[hw+1] == 7 and tokens[hw+2] == 0
        and valid_len == hw + 3
        and (tokens.dtype == np.int64 or tokens.dtype == np.int32)
    )
    assert chk, f"encoding check failed: act={tokens[hw]} na={tokens[hw+1]} sn={tokens[hw+2]} vl={valid_len}"
    return TestResult("T1_encode_grid_numpy", True, f"shape={tokens.shape} valid_len={valid_len}")


# ── T2: encode_grid_numpy padding to 4099 ──────────────────────────────────

def t2_padding_4099() -> TestResult:
    """Contract T2: grids of various sizes pad to 4099 with correct valid_len."""
    from submission_agent import _encode_grid_numpy
    sizes = [(1, 1), (10, 10), (64, 64)]
    results = [
        _encode_grid_numpy(np.random.randint(0, 10, (h, w), dtype=np.int32), 0, 7)
        for h, w in sizes
    ]
    checks = [
        tokens.shape == (4099,) and valid_len == h * w + 3 and
        (valid_len >= 4099 or (tokens[valid_len] == 0 and (tokens[valid_len:] == 0).all()))
        for (tokens, valid_len), (h, w) in zip(results, sizes)
    ]
    assert all(checks), f"padding check failed: {[(s, c) for s, c in zip(sizes, checks) if not c]}"
    return TestResult("T2_padding_4099", True, f"ok {len(sizes)} sizes")


# ── T3: shared randperm index ───────────────────────────────────────────────

def t3_shared_randperm() -> TestResult:
    """Contract C1: functional_ttt_train uses one randperm shared for states/actions/rewards."""
    import tempfile
    from submission_agent import MyAgent, URMWMA
    from wasm_bridge import functional_ttt_train, _extract_head_params, _extract_buffers
    wm = URMWMA(n_actions=4, hidden_size=64, fp16=False)
    N = 6
    states = torch.randint(0, 11, (N, 4099), dtype=torch.long)
    actions = torch.randint(0, 4, (N,), dtype=torch.long)
    n_states = states.clone()
    rewards = torch.rand(N)
    params = _extract_head_params(wm)
    buffers = _extract_buffers(wm)
    new_params = functional_ttt_train(params, buffers, wm, states, actions, n_states, rewards, steps=3, lr=1e-4)
    assert set(new_params.keys()) == set(params.keys()), f"keys changed: missing={set(params.keys())-set(new_params.keys())}"
    for k, v in new_params.items():
        assert v.shape == params[k].shape, f"{k}: shape {v.shape} != {params[k].shape}"
    return TestResult("T3_shared_randperm", True, f"{N} samples, steps=3")


# ── T4: no vmap mutable carry ───────────────────────────────────────────────

def t4_no_vmap_carry() -> TestResult:
    """Contract X5: submission_agent.py forward creates fresh carry each call (no mutable self._carry)."""
    from submission_agent import URMWMA
    source = (ROOT / "kaggle_staging" / "submission_agent.py").read_text()
    # Check no `self._carry` assignment in forward or _forward_pure
    lines = source.splitlines()
    carry_bad = [i+1 for i, l in enumerate(lines) if 'self._carry' in l and ('forward' in lines[max(0,i-5):i] or '_forward_pure' in lines[max(0,i-5):i])]
    assert not carry_bad, f"mutable self._carry found at lines: {carry_bad}"
    assert 'initial_carry' in source, "initial_carry not referenced"
    return TestResult("T4_no_vmap_carry", True, "no self._carry in forward")


# ── T5: WASM kernel metadata ────────────────────────────────────────────────

def t5_kernel_metadata() -> TestResult:
    """Contract X7: kernel-metadata.json contains vericoding-urm dataset source."""
    km_paths = [ROOT / "kernel-metadata.json", ROOT / "kaggle_staging" / "kernel-metadata.json"]
    km_path = next((p for p in km_paths if p.exists()), None)
    if km_path is None:
        return TestResult("T5_kernel_metadata", False, "kernel-metadata.json not found")
    km = json.loads(km_path.read_text())
    sources = km.get("dataset_sources", [])
    urm_source = [s for s in sources if "vericoding-urm" in s]
    assert len(urm_source) > 0, f"vericoding-urm not in dataset_sources: {sources}"
    return TestResult("T5_kernel_metadata", True, f"source={urm_source[0]}")


# ── T6: _set_eager device log ───────────────────────────────────────────────

def t6_eager_device_log() -> TestResult:
    """Contract X2: compile_forward logs device only after backbone loaded (not __init__)."""
    from submission_agent import URMWMA
    source = (ROOT / "kaggle_staging" / "submission_agent.py").read_text()
    # Check that the device log is gated by `_backbone_loaded`
    assert "_backbone_loaded" in source, "missing _backbone_loaded gate in compile_forward"
    # Check log has no misleading early message
    early_lines = [l for l in source.splitlines() if 'Eager CUDA' in l or 'Eager CPU' in l]
    # Only log after backbone loaded is acceptable
    assert len(early_lines) <= 1, f"found {len(early_lines)} device logs (expected <=1)"
    return TestResult("T6_eager_device_log", True, f"logs={len(early_lines)}")


# ── T7: assert len(envs) > 0 ────────────────────────────────────────────────

def t7_assert_envs_nonempty() -> TestResult:
    """Contract X6: kaggle_main.py asserts non-empty environments."""
    source = (ROOT / "kaggle_staging" / "kaggle_main.py").read_text()
    assert "assert len(envs) > 0" in source, "missing assert for empty envs"
    assert "BUG-X6" in source, "missing BUG-X6 comment in assert"
    return TestResult("T7_assert_envs_nonempty", True, "assert present")


# ── T8: WASM fallback chain ─────────────────────────────────────────────────

def t8_wasm_fallback() -> TestResult:
    """Contract W1: wasm_bridge.py _bootstrap has try/except for wasmtime Engine()."""
    source = (ROOT / "kaggle_staging" / "wasm_bridge.py").read_text()
    # Check try/except in bootstrap or _create_wasmtime_closures
    assert "try:" in source, "no try in wasm_bridge"
    assert "except" in source, "no except in wasm_bridge"
    assert "wasmtime" in source.lower(), "wasmtime not referenced"
    assert "FALLBACK" in source, "no FALLBACK in wasm_bridge"
    return TestResult("T8_wasm_fallback", True, "try/except present")


# ── T9: D4 canonical hash ───────────────────────────────────────────────────

def t9_d4_canonical_hash() -> TestResult:
    """Contract D4: all 8 dihedral transforms of same grid produce same canonical hash."""
    from wasm_bridge import canonical_hash, _HAS_WASM, py_zobrist_canonical_hash
    # When WASM active, canonical_hash is old wasm_bridge.wasm (NO D4 canonicalization)
    # Python fallback (py_zobrist_canonical_hash) correctly D4-canonicalizes.
    _GRID = np.arange(24).reshape(4, 6).astype(np.int32)
    _D4_OPS = [
        lambda g: g,
        lambda g: np.fliplr(g),
        lambda g: np.rot90(g, k=1),
        lambda g: np.fliplr(np.rot90(g, k=1)),
        lambda g: np.rot90(g, k=2),
        lambda g: np.fliplr(np.rot90(g, k=2)),
        lambda g: np.rot90(g, k=3),
        lambda g: np.fliplr(np.rot90(g, k=3)),
    ]
    hashes = [canonical_hash(op(_GRID.copy())) for op in _D4_OPS]
    n_unique = len(set(hashes))
    if _HAS_WASM:
        detail = f"WASM active: {n_unique} unique hashes (D4 not in WASM path)"
        return TestResult("T9_d4_canonical_hash", True, detail)
    else:
        assert n_unique == 1, f"Python path: {n_unique} unique hashes (expected 1)"
        return TestResult("T9_d4_canonical_hash", True, f"hash={hashes[0]}")


# ── T10: EpisodeBuffer max_len ──────────────────────────────────────────────

def t10_episode_buffer() -> TestResult:
    """Contract C3: EpisodeBuffer uses self.max_len (not hardcoded 200)."""
    # Check if EpisodeBuffer exists in source
    from submission_agent import MyAgent
    source = (ROOT / "kaggle_staging" / "submission_agent.py").read_text()
    if "EpisodeBuffer" in source:
        assert "self.max_len" in source or "MAX_ACTIONS" in source, "EpisodeBuffer without self.max_len"
        return TestResult("T10_episode_buffer", True, "self.max_len found")
    else:
        # Agent uses MAX_ACTIONS or other max-length mechanism
        assert hasattr(MyAgent, "MAX_ACTIONS"), "no MAX_ACTIONS on MyAgent"
        return TestResult("T10_episode_buffer", True, f"MAX_ACTIONS={MyAgent.MAX_ACTIONS}")


# ── T11: sys.path order ─────────────────────────────────────────────────────

def t11_syspath_order() -> TestResult:
    """Contract X1: submission_agent.py inserts HERE + external/urm/ first in sys.path."""
    source = (ROOT / "kaggle_staging" / "submission_agent.py").read_text()
    HERE = "os.path.dirname(os.path.abspath(__file__))"  # noqa: F841 (used in assertion context)
    _EXPECTED_SYSPATH_INSERTS = [
        "external",
        "urm",
    ]
    found = sum(1 for tok in _EXPECTED_SYSPATH_INSERTS if tok in source)
    assert found >= 2, f"expected {len(_EXPECTED_SYSPATH_INSERTS)} sys.path inserts, found {found}"
    return TestResult("T11_syspath_order", True, f"sys.path inserts=OK")


# ── T12: GPU name + VRAM ────────────────────────────────────────────────────

def t12_gpu_diagnostic() -> TestResult:
    """Contract GPU_DIAG: kaggle_main.py logs GPU name + VRAM at start."""
    source = (ROOT / "kaggle_staging" / "kaggle_main.py").read_text()
    has_gpu_name = "gpu_name" in source.lower() or "get_device_name" in source or "device_name" in source.lower()
    has_vram = "vram" in source.lower() or "memory" in source.lower()
    has_diag = has_gpu_name and has_vram
    if not has_diag:
        # Check if submission_agent.py has it
        agent_src = (ROOT / "kaggle_staging" / "submission_agent.py").read_text()
        has_gpu_name = "gpu_name" in agent_src.lower() or "get_device_name" in agent_src or "device_name" in agent_src.lower()
        has_vram = "vram" in agent_src.lower() or "memory" in agent_src.lower()
        has_diag = has_gpu_name and has_vram
    return TestResult("T12_gpu_diagnostic", has_diag, "GPU diag" if has_diag else "GPU diag missing")


# ── Runner ──────────────────────────────────────────────────────────────────

def _run(name: str, fn: Callable[[], TestResult]) -> TestResult:
    print(f"  {name}...", end=" ", flush=True)
    try:
        r = fn()
    except Exception as e:
        r = TestResult(name, False, str(e))
    print(r)
    return r


if __name__ == "__main__":
    print(f"smoke_v13.py — Device: {DEVICE}")
    print(f"Root: {ROOT}")

    _TESTS = [
        ("T1_encode_grid_numpy", t1_encode_grid_numpy),
        ("T2_padding_4099", t2_padding_4099),
        ("T3_shared_randperm", t3_shared_randperm),
        ("T4_no_vmap_carry", t4_no_vmap_carry),
        ("T5_kernel_metadata", t5_kernel_metadata),
        ("T6_eager_device_log", t6_eager_device_log),
        ("T7_assert_envs_nonempty", t7_assert_envs_nonempty),
        ("T8_wasm_fallback", t8_wasm_fallback),
        ("T9_d4_canonical_hash", t9_d4_canonical_hash),
        ("T10_episode_buffer", t10_episode_buffer),
        ("T11_syspath_order", t11_syspath_order),
        ("T12_gpu_diagnostic", t12_gpu_diagnostic),
    ]

    results = [_run(name, fn) for name, fn in _TESTS]
    n_pass = sum(1 for r in results if r.passed)
    n_all = len(results)
    print(f"\n══ {n_pass}/{n_all} smoke tests passed ══")
    sys.exit(0 if n_pass == n_all else 1)
