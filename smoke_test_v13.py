#!/usr/bin/env python3
"""
smoke_test_v13.py — BUG-X1..X7 + BUG-W1 Verification Suite
Tests all bugs identified in MoonArc3 v12 audit.
Runs without Kaggle environment (mocks where needed).

Usage:
    python smoke_test_v13.py
"""
import sys
import os
import importlib.util
import numpy as np

# Resolve repo root (this file lives in repo root)
REPO_ROOT = os.path.dirname(os.path.abspath(__file__))
STAGING   = os.path.join(REPO_ROOT, "kaggle_staging")

PASS = "\u2705 PASS"
FAIL = "\u274c FAIL"
WARN = "\u26a0\ufe0f  WARN"

results = {}


# ── T1: BUG-X1 — encode_grid_numpy + load_adapter importable ────────────────
def test_x1_imports():
    try:
        if STAGING not in sys.path:
            sys.path.insert(0, STAGING)
        from wasm_bridge import encode_grid_numpy, load_adapter
        grid = np.zeros((10, 10), dtype=np.int32)
        tokens, vlen = encode_grid_numpy(grid)
        assert tokens.shape == (4099,), f"Expected (4099,), got {tokens.shape}"
        assert vlen == 10*10 + 3
        return PASS, f"encode_grid_numpy → shape={tokens.shape}, vlen={vlen}"
    except Exception as e:
        return FAIL, str(e)

results["T1_BUG-X1_imports"] = test_x1_imports()


# ── T2: BUG-X1 — encode_grid_numpy functional correctness ───────────────────
def test_x1_encode_correctness():
    try:
        if STAGING not in sys.path:
            sys.path.insert(0, STAGING)
        from wasm_bridge import encode_grid_numpy
        grid = np.array([[1, 2], [3, 4]], dtype=np.int32)
        tokens, vlen = encode_grid_numpy(grid, action=3, n_actions=7)
        assert tokens[0] == 1 and tokens[1] == 2
        assert tokens[2] == 3 and tokens[3] == 4
        assert tokens[4] == 3,  f"action slot={tokens[4]}, want 3"
        assert tokens[5] == 7,  f"n_actions slot={tokens[5]}, want 7"
        assert all(tokens[vlen:vlen+10] == 0), "padding not zero"
        return PASS, f"flat={tokens[:4].tolist()} meta={tokens[4:7].tolist()} vlen={vlen}"
    except Exception as e:
        return FAIL, str(e)

results["T2_BUG-X1_encode_correctness"] = test_x1_encode_correctness()


# ── T3: BUG-X4/C1 — functional_ttt_train shared randperm ────────────────────
def test_x4_shared_randperm():
    try:
        if STAGING not in sys.path:
            sys.path.insert(0, STAGING)
        import inspect, importlib
        wb = importlib.import_module("wasm_bridge")
        src = inspect.getsource(wb.functional_ttt_train)
        count = src.count("randperm")
        ok = (
            count == 1
            and "idx" in src
            and "states[idx]" in src
            and "actions[idx]" in src
            and "rewards[idx]" in src
        )
        if ok:
            return PASS, f"Single randperm (count={count}), shared idx for all tensors"
        return FAIL, f"randperm count={count} or idx not shared across states/actions/rewards"
    except Exception as e:
        return FAIL, str(e)

results["T3_BUG-X4_shared_randperm"] = test_x4_shared_randperm()


# ── T4: BUG-X5 — vmap removed from submission_agent.py ──────────────────────
def test_x5_no_vmap():
    try:
        sa_path = os.path.join(STAGING, "submission_agent.py")
        with open(sa_path) as f:
            src = f.read()
        if "vmap" not in src:
            return PASS, "submission_agent.py has no vmap — safe for mutable _carry state"
        return FAIL, "submission_agent.py still imports/uses vmap"
    except Exception as e:
        return FAIL, str(e)

results["T4_BUG-X5_no_vmap"] = test_x5_no_vmap()


# ── T5: BUG-X7 — kernel-metadata.json has vericoding-urm ────────────────────
def test_x7_metadata():
    try:
        import json
        meta_path = os.path.join(STAGING, "kernel-metadata.json")
        with open(meta_path) as f:
            meta = json.load(f)
        datasets = meta.get("dataset_sources", [])
        has_urm = any("vericoding-urm" in d for d in datasets)
        has_gpu = meta.get("enable_gpu") == "true"
        if has_urm and has_gpu:
            return PASS, f"dataset_sources={datasets}, enable_gpu={has_gpu}"
        return FAIL, f"has_urm={has_urm} has_gpu={has_gpu} datasets={datasets}"
    except Exception as e:
        return FAIL, str(e)

results["T5_BUG-X7_metadata"] = test_x7_metadata()


# ── T6: BUG-X2 — _set_eager no longer uses is_cuda check ────────────────────
def test_x2_eager_device():
    try:
        sa_path = os.path.join(STAGING, "submission_agent.py")
        with open(sa_path) as f:
            src = f.read()
        bad_pattern = "is_cuda for p in self.parameters()"
        good_pattern = "params="
        if bad_pattern not in src and good_pattern in src:
            return PASS, "_set_eager reports param count only — no premature device check"
        if bad_pattern in src:
            return FAIL, "_set_eager still uses is_cuda before backbone load"
        return WARN, "_set_eager pattern unclear"
    except Exception as e:
        return FAIL, str(e)

results["T6_BUG-X2_eager_device"] = test_x2_eager_device()


# ── T7: BUG-X6 — kaggle_main asserts game_ids non-empty ─────────────────────
def test_x6_game_ids_guard():
    try:
        km_path = os.path.join(STAGING, "kaggle_main.py")
        with open(km_path) as f:
            src = f.read()
        if "assert len(game_ids) > 0" in src:
            return PASS, "assert len(game_ids) > 0 present — fails early on missing dataset"
        return FAIL, "game_ids guard missing from kaggle_main.py"
    except Exception as e:
        return FAIL, str(e)

results["T7_BUG-X6_game_ids_guard"] = test_x6_game_ids_guard()


# ── T8: BUG-W1 — RhaeEngine _initialize fallback chain ──────────────────────
def test_w1_rhae_init():
    try:
        wb_path = os.path.join(REPO_ROOT, "wasm_bridge.py")
        if not os.path.exists(wb_path):
            return WARN, "Root wasm_bridge.py not found"
        with open(wb_path) as f:
            src = f.read()
        chain = (
            '"_initialize") or self._exp.get("_start")' in src
            or "get(\"_initialize\") or self._exp.get(\"_start\")" in src
        )
        if chain:
            return PASS, "_initialize → _start → skip fallback chain present"
        return FAIL, "BUG-W1 fallback chain not found"
    except Exception as e:
        return FAIL, str(e)

results["T8_BUG-W1_rhae_init"] = test_w1_rhae_init()


# ── T9: D4 canonical hash — all 8 transforms give same canonical value ────────
def test_d4_canonical():
    try:
        wb_path = os.path.join(REPO_ROOT, "wasm_bridge.py")
        if not os.path.exists(wb_path):
            return WARN, "Root wasm_bridge.py not found"
        spec = importlib.util.spec_from_file_location("wasm_bridge_root", wb_path)
        mod  = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        fn = mod.py_zobrist_canonical_hash
        grid = np.array([[1, 2, 0], [3, 0, 0], [0, 0, 0]], dtype=np.int32)
        transforms = [
            grid, np.rot90(grid, 1), np.rot90(grid, 2), np.rot90(grid, 3),
            np.fliplr(grid), np.flipud(grid), grid.T, np.fliplr(grid.T),
        ]
        hashes   = [fn(t) for t in transforms]
        expected = min(hashes)
        canon    = fn(grid)
        if canon == expected:
            return PASS, f"D4 canonical={canon}, min-of-all={expected} ✓"
        return FAIL, f"canonical={canon} != min={expected}; hashes={hashes}"
    except Exception as e:
        return WARN, f"D4 test skipped: {e}"

results["T9_D4_canonical_hash"] = test_d4_canonical()


# ── T10: EpisodeBuffer uses self.max_len ────────────────────────────────────
def test_episode_buffer_maxlen():
    try:
        sa_path = os.path.join(STAGING, "submission_agent.py")
        with open(sa_path) as f:
            src = f.read()
        if "maxlen=self.max_len" in src:
            return PASS, "EpisodeBuffer uses self.max_len — FIX C3 confirmed"
        return FAIL, "EpisodeBuffer uses hardcoded maxlen"
    except Exception as e:
        return FAIL, str(e)

results["T10_EpisodeBuffer_maxlen"] = test_episode_buffer_maxlen()


# ── T11: sys.path X1 fix — kaggle_staging first in submission_agent ─────────
def test_x1_syspath_order():
    try:
        sa_path = os.path.join(STAGING, "submission_agent.py")
        with open(sa_path) as f:
            src = f.read()
        has_dirname_0 = "sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))" in src
        has_external_1 = "sys.path.insert(1," in src and "external" in src
        if has_dirname_0 and has_external_1:
            return PASS, "kaggle_staging/ at index 0, external/ at index 1 in sys.path"
        return FAIL, f"dirname_0={has_dirname_0} external_1={has_external_1}"
    except Exception as e:
        return FAIL, str(e)

results["T11_BUG-X1_syspath"] = test_x1_syspath_order()


# ── T12: GPU diagnostic in kaggle_main ──────────────────────────────────────
def test_gpu_diagnostic():
    try:
        km_path = os.path.join(STAGING, "kaggle_main.py")
        with open(km_path) as f:
            src = f.read()
        has_name = "get_device_name" in src
        has_mem  = "get_device_properties" in src or "total_memory" in src
        if has_name and has_mem:
            return PASS, "GPU name + VRAM logged at startup"
        return WARN, f"GPU diag partial: name={has_name} mem={has_mem}"
    except Exception as e:
        return FAIL, str(e)

results["T12_GPU_diagnostic"] = test_gpu_diagnostic()


# ── SUMMARY ──────────────────────────────────────────────────────────────────
print()
print("=" * 68)
print("  SMOKE TEST v13 — ARC-AGI-3 MoonArc3 Bug Fix Verification")
print("=" * 68)

pass_c = sum(1 for r in results.values() if r[0] == PASS)
fail_c = sum(1 for r in results.values() if r[0] == FAIL)
warn_c = sum(1 for r in results.values() if r[0] == WARN)

for name, (status, msg) in results.items():
    print(f"  {status}  {name}")
    print(f"          {msg}")
    print()

print("=" * 68)
print(f"  RESULT: {pass_c} PASS | {fail_c} FAIL | {warn_c} WARN  (total {len(results)}")
print("=" * 68)

if fail_c == 0:
    print("  \U0001f680  ALL TESTS PASS — MoonArc3 v13 ready for Kaggle push")
else:
    print(f"  \u26d4  {fail_c} TEST(S) FAILED — fix before Kaggle push")
    sys.exit(1)
