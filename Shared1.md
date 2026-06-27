# Shared1.md — ARC-AGI-3 VERICODING-URM Change Log
## v11 — 2026-06-24 CEST (Planner: Perplexity Computer)

---

## Summary

Surgical SOTA-level patches applied to production Kaggle dataset `krisskey/vericoding-urm`.
All changes preserve original architecture (MCTS, Curiosity, Zobrist, WASM bridge).
Only broken device discipline, adapter invariant, and smoke harness patched.

---

## Files Changed

### `wasm_bridge.py`
| # | Change | Phase | Bug Fixed |
|---|--------|-------|-----------|
| 1 | `_extract_head_params`: replaced blacklist (`not backbone`, `not action_emb`) with **strict prefix whitelist** (`action_head.*`, `value_head.*` only). Added assertion. | Phase 2 | BUG-B adapter shape mismatch |
| 2 | `pure_batch_ttt_loss`: verified `torch.tensor(0.0, device=batch_states.device)` — already correct | Phase 1 | BUG-A index_select |
| 3 | `functional_ttt_train`: verified `torch.randperm(n, device=device)` — already correct | Phase 1 | BUG-A index_select |

### `external/urm/models/urm/urm.py`
| # | Change | Phase | Bug Fixed |
|---|--------|-------|-----------|
| 1 | `URM.forward`: `new_steps = torch.where(carry.halted, torch.zeros_like(carry.steps), carry.steps)` — replaced Python int `0` with `torch.zeros_like` (explicit device-propagating tensor) | Phase 1 | BUG-A device coercion |
| 2 | Verified: `empty_carry` has `device = next(self.parameters()).device` fallback | Phase 1 | — |
| 3 | Verified: `initial_carry` creates all tensors with `device=device` | Phase 1 | — |
| 4 | Verified: `torch.rand_like`, `torch.randint_like` in halt exploration — device-propagating, correct | Phase 1 | — |

### `kaggle_main.py`
| # | Change | Phase | Bug Fixed |
|---|--------|-------|-----------|
| 1 | Removed `render_mode="none"` from `arc.make()` calls — avoids arc-agi warning | Phase 4 | Warning |
| 2 | Verified: no `torch.cuda.empty_cache()` in per-env loop — already correct | Phase 4 | Performance |
| 3 | Verified: adapter save is already head-only (`action_head` + `value_head` only, no `action_emb`) | Phase 2 | BUG-B |

### `external/urm/models/layers.py`
| # | Change | Phase | Bug Fixed |
|---|--------|-------|-----------|
| 1 | Documented `__init__`-time `torch.empty/zeros` without `device=` — these are `nn.Parameter` constructors that correctly live on CPU at init and are moved by `.to(device)` later. NOT hot-path bugs. | Phase 1 | Documentation |

---

## Invariants Verified (All Hold Post-Patch)

```
Inv0: submission_notebook_mode ≡ InferenceOnly                     ✓
Inv1: ∀ hot-path new tensors: device= explicit or _like propagation ✓
Inv2: adapter_keys ⊆ {"action_head.*", "value_head.*"}             ✓ (strict whitelist)
Inv3: URMWMA compile_forward → eager-only                           ✓
Inv4: TTT ≡ sidecar only (not called in submission path)            ✓
Inv5: render_mode="none" removed                                    ✓
```

---

## Scan Results (Pre/Post Patch)

| File | Bare constructors before | After |
|---|---|---|
| `submission_agent.py` | 0 violations | 0 violations |
| `wasm_bridge.py` | 1 (_extract_head_params logic) | 0 |
| `urm/urm.py` | 1 (int `0` in torch.where) | 0 |
| `layers.py` | 3 (nn.Parameter init — not bugs) | documented |
| `sparse_embedding.py` | 2 (register_buffer — not bugs) | documented |
| `kaggle_main.py` | 1 (render_mode warning) | 0 |

---

## Files NOT Changed (Verified Clean)

- `external/urm/models/losses.py` — no bare constructors
- `external/urm/models/common.py` — no hot-path constructors
- `external/urm/models/muon.py` — optimizer, not submission path
- `external/urm/puzzle_dataset.py` — training only, not submission
- `external/urm/utils.py` — utilities, verified clean
- `wasm_bridge.wasm` — binary, unchanged
- `urm_checkpoint.pt` — weights, unchanged

---

## Next Steps (Agent 2 TODO)

- [ ] Run `smoke_v11.py` on Kaggle T4 after dataset update
- [ ] Verify no `wrapper_CUDA__index_select` in logs
- [ ] If TTT training needed: run `functional_ttt_train` in sidecar notebook, save adapter via `_extract_head_params`, upload as separate dataset
- [ ] Per-game adapters: use `adapter_path_for_game(base_dir, game_id, n_actions)` pattern

---

*Architect: Perplexity Computer | Coder/Vericoder: Agent 2*
*Repo: https://github.com/krosskriss824/arc-agi-3*
*Dataset: https://www.kaggle.com/datasets/krisskey/vericoding-urm*

## v13 — 2026-06-24 P100 CUDA guard patch

**submission_agent.py — BUG-D: P100/sm_60 CUDA incompatibility in agent internals**

Root cause: `torch.cuda.is_available()` returns `True` on P100 even though PyTorch ≥2.0
only supports sm_70+. Any CUDA kernel call then raises `AcceleratorError: no kernel image`.

Fix: injected `_cuda_safe() → bool` helper (lines 20-27) that checks `capability[0] >= 7`.
Replaced 4 call sites:
- line 195: `URMWMA._setup_compile` `use_cuda` fallback
- line 1748: `EpisodicMemory.__init__` device arg
- line 1764: fp16 upgrade gate
- line 1789: torch.compile warm-up gate

`_cuda_safe()` definition:
```python
def _cuda_safe() -> bool:
    if not HAS_TORCH or not torch.cuda.is_available(): return False
    try:
        cap = torch.cuda.get_device_capability(0)
        return cap[0] >= 7
    except Exception:
        return False
```

## v14 — Stage 1 RHAE (2026-06-25)
### New files
- `rhae_stage1.wasm` (14KB): MoonBit 0.10.1 D4-canonical hash + policy gate
  - 24 exports: rhae_canonical_hash, rhae_policy_gate, rhae_build_candidates, rhae_topk,
    rhae_visited_check/mark/reset, rhae_tt_lookup/store, rhae_hash_and_check, rhae_get_hash_hi,
    set_grid_cell, set_prev_cell, set_risk, set_visited, get_inv, get_mat, get_topk,
    zobrist_init, zobrist_hash_grid, zobrist_update_cell
  - Build: moonc link-core → WAT export injection → wat2wasm
  - Bug fixed: _start() must be called to init heap globals before WASM use

### Modified files
- `wasm_bridge.py`: Added section 9 — RhaeEngine class + get_rhae() singleton
  - Full Python fallback (py_visited_*, py_tt_*, py_canonical_hash)
  - _HAS_RHAE_WASM flag for conditional activation
- `submission_agent.py`:
  - Import: get_rhae, _HAS_RHAE_WASM
  - choose_action: D4-canonical hash replaces hash(tobytes()), policy_gate replaces action_prune
  - visited_mark/reset per episode for trajectory deduplication
