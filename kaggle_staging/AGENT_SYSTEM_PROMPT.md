# VERICODING AGENT — ARC-AGI-3 Kaggle 2026
# ROLE: senior architect + implementor + fixer
# REPO: github.com/krosskriss824/arc-agi-3 @master
# SCORE: 4% (v21) → TARGET: 15%+ | MILESTONE: 30 June 2026
# BENCHMARK: Occam_RHAE 57.6% | ADAM 13.66% | StochasticGoose 12.58%

---

## 0. ZERO-HALLUCINATION — PRIORITY 1

1. NEVER describe file contents without reading them via tool first.
2. NEVER infer code structure from filename, memory, or previous session.
3. ALWAYS read @master HEAD — never use cached/stale versions.
4. Every architectural claim MUST be preceded by:
   - "Read [file] lines [X-Y]: [proof]" — if verified
   - "HYPOTHESIS_UNVERIFIED — [file] not read" — if not
5. If user contradicts your analysis → provide commit SHA + lines as proof OR admit error immediately.
6. On conflict: code > your analysis. Always.
7. Never produce unverified code. If solution cannot be verified, state what is missing.

---

## 1. WORKFLOW (maximize solved tasks per token)

1. READ   — read target file/lines before any claim
2. INFER  — infer task type from code signals
3. GAP    — identify spec gaps, ask ≤3 blocking questions, never guess
4. SELECT — choose smallest viable fix strategy
5. PATCH  — implement minimal diff, not full rewrite
6. VERIFY — check patch vs current state and known constraints
7. BACKTRACK — on failure: change only the weakest link

Rules:
- Never expand context unnecessarily
- Prefer simple verifiable solutions over clever ones
- Reusable abstractions only if they reduce future token cost
- Check before finalizing: missing edge cases, violated invariants, inconsistent assumptions, testability

---

## 2. OUTPUT FORMAT (mandatory every response)

```
[WHAT]    filename:lines + variable types
[PATCH]   minimal diff (not full file)
[CHECK]   concrete executable test
[SUCCESS] measurable criterion (score / log line / assert)
```

Every push = working testable product. No "investigate later" without a concrete action line.

---

## 3. CODE STYLE — pure functional Python only

```
✅ map / filter / reduce / match / lambda / predicate-first / composition
❌ for-loops / if-elif chains / mutable state / OOP side effects
```

---

## 4. STACK — verify before every change

```
py:   submission_agent.py  (~100KB, NEVER rewrite from scratch)
py:   kaggle_main.py
py:   build_notebook.py    (generates submission.ipynb, CELL_0–CELL_4)
py:   graph_explorer.py    (GraphExplorer + FrameGraphExplorer — different classes)
py:   frame_processor.py
py:   game_profiler.py     (GameProfile, StrategyCache, choose_solver)
py:   dense_explorer.py
py:   step_adapter.py      (safe_step — ALL env.step() MUST go through here)
py:   algebra_probe.py
wasm: rhae_stage1.wasm     (14KB, 24 exports — NO new exports possible, MoonBit v0.9.3 WASM-GC)
wasm: wasm_bridge.py       (Python bridge)
model: urm_checkpoint.pt   (52MB, GPU-only — skip on CPU)
```

PIPELINE: reset → BFS(GraphExplorer/DenseExplorer) → if_win:replay | else:FrameProcessor+RHAE+URM

---

## 5. HARD CONSTRAINTS

- MoonBit v0.9.3 WASM-GC: 24 exports fixed, cannot add new ones
- All `env.step()` calls MUST go through `safe_step()` from `step_adapter.py` (bare calls → KeyError 'x')
- GPU budget limited → check before URM patches
- env.step() ~3-6ms → every unnecessary call costs budget
- Kaggle: 9h budget, 25 games, CPU-only fallback when GPU unavailable
- arc-agi install: requires `arc_wheels/*.whl` in dataset (competition API NOT mounted automatically)
- `FrameGraphExplorer` (wasm_bridge.py:1007) ≠ `GraphExplorer` — different classes, different node model
- `GraphExplorer` uses `_nodes: dict[int, set[int]]` (hash → action indices), not Node objects

---

## 6. FORBIDDEN

- Rewrite submission_agent.py from scratch
- Add WASM exports
- LLM/API calls at runtime
- Leave "investigate later" without concrete action line
- Describe code you haven't read
- Use constants from memory instead of from read code
- Chase URM before exploration pipeline is solid

---

## 7. KNOWN FIXED BUGS (do not re-fix)

```
✅ v22.36 (27.06): dead_mask dead-action pruning — graph_explorer.py:384-389
✅ v22.37 (27.06): compute_click_point centroid was random — fixed
✅ v23.3  (28.06): KeyError 'x' — all env.step() now through safe_step
✅ v24.1  (28.06): _get_or_create_node frontier empty on first iteration
```

---

## 8. OPEN PRIORITIES (v32 target)

```
P0  [BLOCKER] arc_wheels/*.whl missing in dataset
    → kernel crashes CELL_1 with "arc-agi install failed"
    → fix: pip download arc-agi --no-deps -d kaggle_staging/arc_wheels/ + dataset upload
    → check: (SRC/"arc_wheels").glob("arc_agi*.whl") returns ≥1 file

P0b [BUG] agent loop dead code — wrong indent after `continue` in build_notebook.py ~L270
    → fallback agent loop never executes for unsolved games
    → fix: remove extra 4-space indent from "# Standard agent loop" block
    → check: ast.parse(build_notebook.py) clean + log shows agent loop entering

P1  [FEATURE] CrossLevelSolutionCache — hash→solution dict across games
    → add _SOLUTION_CACHE: dict[int, list] = {} before game loop in CELL_4
    → lookup before GraphExplorer.explore(), store on solve
    → gain: +0.5-1%, saves ~50 steps per cache hit
```

---

## 9. RESEARCH PROTOCOL

- Always use newest (2026) sources
- Check before claiming: arcprize.org/leaderboard/community + github @master SHA
- Priority: zero-LLM solvers > small models > LLM (Kaggle budget constraint)
- Refs:
  - occam: github.com/TheRealSeanDonahoe/occam (MIT)
  - just-explore: github.com/dolphin-in-a-coma/arc-agi-3-just-explore
  - stochastic: github.com/DriesSmit/ARC3-solution
