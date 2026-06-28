# HANDOFF v55 — 28 June 2026

## STATUS: FIRST WORKING PIPELINE (v54-v55)

**mean_score = 0.08** (2/25 games scored: sp80=1.0, vc33=1.0)
Previous baseline: 0/25 since v22 (28 consecutive versions with 0 score)

---

## FILE MAP

| File | Lines | Role | Status |
|---|---|---|---|
| `scripts/build_notebook.py` | 507 | Template → submission.ipynb | MODIFIED v55 |
| `submission_agent.py` | 2461 | VERICODINGAgent class | MODIFIED v55 |
| `wasm_bridge.py` | 1255 | WASM bridge + TTT engine | UNCHANGED |
| `step_adapter.py` | 24 | safe_step wrapper | UNCHANGED |
| `game_profiler.py` | 297 | Game profiling (DEAD in v55) | PRESERVED |
| `graph_explorer.py` | 421 | Graph exploration (DEAD in v55) | PRESERVED |
| `dense_explorer.py` | 235 | Dense scan (DEAD in v55) | PRESERVED |
| `frame_processor.py` | — | FrameProcessor (DEAD in v55) | PRESERVED |

---

## KAGGLE KERNEL VERSIONS (v22 slug)

| Version | Status | Score | Time | Notes |
|---|---|---|---|---|
| v22.32-v24.5 | 0/25 | 0.00 | 80-95s | Profiler+strategies corrupted agent state |
| v49 | 0/25 | 0.00 | 94s | Profiler+strategies, _rhae._exp crash |
| v50 | 0/25 | 0.00 | 95s | Stale frame bug (`_frames` missing history) |
| v51 | 0/25 | 0.00 | 40s | `_frames` fix but _rhae crash on step 2 |
| v52 | ERROR | — | — | IndentationError in CELL 5 (trajectories ref) |
| v53 | ERROR | — | 21s | Same IndentationError (patched wrong indent) |
| v54 | COMPLETE | **0.08** | 19s | **Clean agent loop + _wasm_ok guard** — 2 games score! |
| v55 | COMPLETE | **0.08** | 19s | Same as v54 + trajectories populated for TTT |

---

## BUG ROOT CAUSES (chronological, all v22-v55)

| # | Bug | File:Line | Root cause | Fix (version) |
|---|---|---|---|---|
| 1 | `env.step(ACTION6, data={})` KeyError 'x' | profiler | bare `env.step(actions[0])` for complex action without data dict | `safe_step` adapter (v23.3) |
| 2 | GraphExplorer `_get_or_create_node()` never called | `graph_explorer.py` | nodes not created at frontier-add time, frontier always empty | eager node creation at frontier add (v24.1) |
| 3 | BUG_ROOT: `_safe_step(0)` after reset shifts all states by 1 | `graph_explorer.py` + `dense_explorer.py` | `env.reset()` then immediately `_safe_step(0)`, start hash = S₁ not S₀ | `env.reset()` directly, no extra step (v24.5) |
| 4 | Profiler + strategies corrupt agent state | `build_notebook.py` CELL 4 | 300+ profile steps + graph_explore + repeated-simple-action fallback all mutate env/agent before agent loop runs | **Strip ALL** (v54) |
| 5 | `agent.choose_action([frame], None)` — stale single-frame history | `build_notebook.py` CELL 4 | Only latest frame passed, not full history `_frames` | `_frames` list with full history (v54) |
| 6 | `_rhae._exp["set_visited"]` on None | `submission_agent.py:2091` | WASM Python fallback mode leaves `_rhae._exp=None`, but code accesses it directly | `_rhae._wasm_ok` guard + runtime patch (v54) |
| 7 | `trajectories` not defined | `build_notebook.py` CELL 4 | stripped during cleanup, CELL 5 references it | restored (v55) |

---

## CURRENT ARCHITECTURE (v55 CELL 4 — simplified)

```
for idx, env_info in enumerate(env_infos):
    try:
        env = arc.make(gid)
        agent.set_game_tags(...)
        _frames = [env.reset()]
        agent.on_game_start()
        for _ in range(MAX_STEPS=2000):
            act = agent.choose_action(_frames, None)
            nf = safe_step(env, act, ...)
            score += levels_completed_delta
            _frames.append(nf)
            if WIN or GAME_OVER: break
        game_scores[gid] = score
    except: ...
```

- No profiler, no strategy selection, no GraphExplorer/DenseExplorer
- Full frame history (`_frames` list) for agent.choose_action
- `_rhae._wasm_ok` guard skips WASM-only code when running CPU fallback
- TTT (Phase B) runs after Phase A on GPU only

---

## RESULTS ANALYSIS (v55)

**Scored games:**
- **sp80**: 1.0 in 47 steps (repeated ACTION1 completes level 0, hba=39, agent hits ~47 steps)
- **vc33**: 1.0 in 410 steps (complex click game, agent found level completion via exploration)

**Non-scored games (patterns):**
- `lp85, su15`: full 2000 steps used, no level completed → budget too small for complex BFS
- `tn36, sk48, sb26`: 300-460 steps, then break (GAME_OVER or stuck) → wrong action sequences
- `ft09, r11l, sc25, cd82, dc22`: 39-128 steps, break → GAME_OVER early (agent hits terminal state)
- `ar25, g50t, ka59, lf52, m0r0, re86, wa30, tu93`: 75-288 steps → game-specific issues

**Key insight**: agent without WASM acceleration uses blake2b hashing + fallback graph explorer + random action fallback. Scores come from lucky action sequences, not systematic exploration.

---

## LIMITATIONS (v55)

| Issue | Impact | Fix required |
|---|---|---|
| No WASM (CPU Python fallback) | Canonical hash slow+unstable, no top-k pruning, no TT cache | Install wasmtime from offline wheel on GPU |
| URM not loaded on CPU | No world model for TTT or action prediction | GPU required for URM checkpoint loading |
| 2000 steps per game too tight for BFS | lp85, su15 exhaust budget without scoring | increase BUDGET or add adaptive reset |
| agent._n_actions discovery may mismatch | Random fallback returns out-of-bounds action | verify _discover_n_actions() correctness |
| Wasmtime wheel missing from local disk | Was deleted during cleanup, must re-download for dataset rebuild | Re-download from arc-agi GitHub release |
| game_profiler.py etc. are dead code | ~1000 lines unused but preserved in dataset | archive or remove |

---

## NEXT STEPS (priority order)

1. **Switch to GPU** → WASM accelerates all agent operations (hash, topk, TT, invariants)
2. **Install wasmtime from offline wheel** → `wasmtime-27.0.2-py3-none-manylinux1_x86_64.whl` lives in Kaggle dataset
3. **Load URM checkpoint** → world model enables TTT, action prediction, increased score
4. **Increase MAX_STEPS** → 2000→5000 for games that exhaust budget (lp85, su15)
5. **Add D4 canonical dedup via WASM** → consistent visited-set prevents repeated states
6. **Re-enable profiler+strategies** but only AFTER agent loop, not before

---

## GIT COMMIT HISTORY

```
258ddd2 v24.5: BUG_ROOT fix - env.reset() baseline, not _safe_step(0)
3163116 v24.3: flatten 32 arc-agi wheels in dataset root
...
ef9e278 v23.3: step_adapter.py — ALL env.step() -> safe_step
```

**Current HEAD**: `258ddd2` (v24.5)
**Uncommitted changes**: build_notebook.py, submission_agent.py, submission.ipynb (v55)
