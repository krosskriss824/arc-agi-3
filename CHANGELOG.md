# ARC-AGI-3 Changelog

## v11 — 2026-06-24 (SOTA Refactor)

### Architecture changes
- All modules: pure algebraic types via `dataclass(frozen=True)` and `NamedTuple`
- All modules: zero bare `torch.tensor/zeros/ones/arange` without `device=`
- All modules: device derived from `next(self.parameters()).device` or input tensor — single source of truth per function

### submission_agent.py
- `URMWMA`: `compile_forward` replaced by `_set_eager()` — documented eager-only invariant
- `URMWMA.forward`: `device = state_tokens.device` derived once at top, used everywhere
- `URMWMA.load_backbone`: strips `_orig_mod.` prefix, moves all params atomically via single `.to(device)` call
- `VERICODINGAgent`: `build_agent` factory replaces scattered `.to()` calls
- `ActionResult`: `NamedTuple` replaces bare dict — typed return
- `AgentConfig`: `dataclass(frozen=True)` — immutable config
- `EpisodeBuffer`: bounded `collections.deque`, `as_tensors` method

### wasm_bridge.py
- `pure_batch_ttt_loss`: zero tensor uses `device=batch_states.device`, reg dispatch via dict pattern (no if-chain)
- `functional_ttt_train`: `torch.randperm(n, device=device)` — no CPU index leakage; `TTTConfig` algebraic config
- `extract_head_params`: asserts `_HEAD_PREFIXES` invariant, returns CPU-detached dict
- `save_adapter` / `load_adapter`: `weights_only=True` on load, defensive prefix filter
- `encode_grid_numpy`: pure NumPy, no tensors

### external/urm/models/urm/urm.py
- `URMConfig`: `dataclass(frozen=True)` — replaces scattered magic numbers
- `URMCarry`: `NamedTuple` — immutable carry, documents device contract
- `URMInner._assert_carry_device`: explicit device assertions on every forward call
- `URMInner.empty_carry`: all tensors use `device=device` parameter
- `URM.initial_carry`: device from `batch["inputs"].device` only
- `URM._reset_carry`: pure `torch.where` pattern-matching — no loops
- `URM.forward`: stochastic halt via `torch.randint_like` / `torch.rand_like` (device-propagating)

### external/urm/models/layers.py
- `CastedEmbedding`, `CastedLinear`, `CastedSparseEmbedding`: config via `dataclass(frozen=True)`
- `RMSNorm`: added — used in transformer blocks
- `RotaryEmbedding`: buffers registered via `register_buffer` — device propagates with `.to()`

### external/urm/models/losses.py
- `value_logits_to_scalar`: support tensor uses `device=value_logits.device` — no CPU tensor
- `ACTLossHead`: pure vectorised forward, no loops
- `kl_reg_loss`, `mse_anchor_reg`: added — used in TTT regularisation

### kaggle_main.py
- `RunConfig`: `dataclass(frozen=True)` — all config in one place
- `_install_arc_agi`: conditional wheels/PyPI, documented
- `_run_episode`: extracted — clean episode loop, no torch ops
- `torch.cuda.empty_cache()`: called ONCE after all games, not in loop
- No TTT imports — submission invariant enforced at module level

### smoke/smoke_v11.py
- 4 isolated test contracts with `TestResult` type
- No external `.to(DEVICE)` calls — validates `build_agent` factory
- `smoke_cpu_mini`: no backbone, CPU only — pure device discipline test
- `smoke_adapter`: different n_actions models, asserts no `action_emb`
- `smoke_ttt_isolated`: fake tensors, verifies param keys + device
- `smoke_cuda_full`: 20 envs, single `empty_cache` at end

### Bugs fixed
- BUG-A: `wrapper_CUDA__index_select` — eliminated via device discipline throughout
- BUG-B: adapter shape mismatch — `action_emb` never in global adapter
- BUG-C: action space variability — adapter head-only, `n_actions`-agnostic
