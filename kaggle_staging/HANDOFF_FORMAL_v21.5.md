// VERICODING :: ARC-AGI-3 SOLVER :: FORMAL SPEC v21.5 (27 Jun 2026)
// ============================================================================
// Dafny-like predicate-first specification. Zero ambiguity. All state transitions
// defined as pure predicates. All bugs documented with exact cause + fix.

// ============================================================================
// §0  ACTIVE REPOSITORIES
// ============================================================================

// GitHub:  github.com/krosskriss824/arc-agi-3           (branch: master)
// Kaggle:
//   Dataset:  krisskey/vericoding-urm                   (v21.5, ~109KB zip)
//   Notebook: krisskey/arc3-urm-ttt-v21-w-replayexplorer-bfs  (v7 pushed)
// Local:    C:\Users\kross\Documents\MoonArc3-v1.3\kaggle_staging\
//           └─ scripts/build_notebook.py   (generates submission.ipynb)
//              └─ submission.ipynb         (6 cells, pushed to Kaggle)

// ============================================================================
// §1  FILE ARCHITECTURE (dependency graph, Dafny layer)
// ============================================================================

// type Layer = source | generated | binary
// type File = fn name: string, path: string, layer: Layer, depends_on: seq<string>

// const FILES: map<string, File> := {
//   "replay_explorer.py":    File("replay_explorer.py",    "kaggle_staging/", source,    []),
//   "frame_processor.py":    File("frame_processor.py",    "kaggle_staging/", source,    []),
//   "submission_agent.py":   File("submission_agent.py",   "kaggle_staging/", source,    ["wasm_bridge", "frame_processor", "replay_explorer"]),
//   "wasm_bridge.py":        File("wasm_bridge.py",        "kaggle_staging/", source,    []),
//   "build_notebook.py":     File("build_notebook.py",     "scripts/",         source,    []),
//   "submission.ipynb":      File("submission.ipynb",      "kaggle_staging/", generated, ["build_notebook"]),
//   "kernel-metadata.json":  File("kernel-metadata.json",  "kaggle_staging/", generated, ["build_notebook"]),
//   "wasm_bridge.wasm":      File("wasm_bridge.wasm",      "kaggle_staging/", binary,    []),
//   "rhae_stage1.wasm":      File("rhae_stage1.wasm",      "kaggle_staging/", binary,    []),
//   "urm_checkpoint.pt":     File("urm_checkpoint.pt",     "kaggle_staging/", binary,    []),
// }

// CONSTRAINT: build_notebook.py always overwrites kernel-metadata.json
// CONSTRAINT: kernel-metadata.json id MUST match Kaggle kernel slug
// BUG-HISTORY: v21.0 → v21.5: build_notebook.py had hardcoded "v19" kernel id
//   causing pushes to wrong kernel. Fix: line 499: s/v19-action6-centroid-blind-probe/v21-w-replayexplorer-bfs/

// ============================================================================
// §2  CORE ARCHITECTURE: ReplayExplorer (BFS reset-replay)
// ============================================================================

// class ReplayExplorer <{
//     _env: Env,
//     _hasher: fn(np.ndarray) -> int,       // WASM canonical_hash wrapper
//     _action_list: seq<GameAction>,         // env.action_space (per-game)
//     _n_actions: int,                       // len(_action_list)
//     _max_depth: int,                       // BFS depth limit (default 16)
//     _action_budget: int,                   // total env.step() calls (default 15000)
//     _step_modulus: int,                    // hash deconflict (default 3)
//     _volatile_mask: Option<np.ndarray>,    // pixel mask to zero before hash
//     _state_prefix: dict<int, seq<int>>,    // state_hash → action prefix to reach it
//     _edges: dict<(int,int), int>,          // (from_hash, action) → to_hash
//     _tried: dict<int, set<int>>,           // state_hash → set of tried actions
//     _processed: set<int>,                  // state_hash → fully explored
//     _current_prefix: seq<int>,             // actions leading to current env state
//     _effective_actions: set<int>,          // actions that changed state
//     _winning_combos: seq<seq<int>>,        // found solutions
// }>

// REQUIRES _action_list.len() == _n_actions
// REQUIRES _n_actions > 0
// REQUIRES _max_depth >= 1
// REQUIRES _action_budget >= _max_depth * _n_actions

// predicate ValidTransition(
//     hash: int, action: int, new_hash: int,
//     edges: dict<(int,int), int>
// ): bool {
//     (hash, action) in edges.Keys ==> edges[(hash, action)] == new_hash
// }

// predicate IsDeadAction(action: int, state_prefix: dict<int, seq<int>>, edges: dict<(int,int), int>): bool {
//     forall hash :: hash in state_prefix.Keys ==>
//         (hash, action) in edges.Keys ==>
//         edges[(hash, action)] == hash
// }

// predicate IsEffectiveAction(action: int, edges: dict<(int,int), int>): bool {
//     exists hash :: (hash, action) in edges.Keys && edges[(hash, action)] != hash
// }

// SEARCH STRATEGY (pure functional description):
//   solve():
//   1. env.reset() → state_hash = hash_fn(frame) ⊕ step_modulus⊕0
//   2. for depth := 0 to _max_depth:
//   3.   frontier = sorted(
//           filter(state_prefix where len(prefix) == depth ∧ hash ∉ processed),
//           key = λt: t.prefix  // lexicographic → maximize LCP
//         )
//   4.   for (state_hash, prefix) ∈ frontier:
//   5.       _replay_to(prefix)  // LCP incremental
//   6.       for action ∈ _untried_actions(state_hash):
//   7.           frame = env.step(_action_list[action])
//   8.           new_hash = hash_fn(frame) ⊕ step_modulus⊕(depth+1)
//   9.           if is_win(frame): return prefix + [action]
//   10.          if new_hash ∉ state_prefix:
//   11.              state_prefix[new_hash] = prefix + [action]
//   12.              if new_hash != state_hash: _effective_actions.add(action)

// OPTIMIZATION: _replay_to(prefix)
//   common = LCP(_current_prefix, prefix)
//   if common == |prefix|: skip (already there)
//   if common == |_current_prefix|: step(prefix[common:])     // NO reset
//   else: reset() + step(prefix)

// OPTIMIZATION: _untried_actions(state_hash)
//   tried = _tried[state_hash]
//   if _effective_actions ≠ ∅: return filter(∉ tried ∧ ∈ _effective_actions)
//   else: return filter(∉ tried, range(_n_actions))

// OPTIMIZATION: set_action6_priority()
//   Finds first ga in _action_list where ga.is_complex()
//   Moves it to index 0. This makes ACTION6 the first try on depth=0.
//   Source: farmountain EXP-035 (arXiv:2605.25931)

// ============================================================================
// §3  24 WASM EXPORTS (via RhaeEngine, rhae_stage1.wasm + wasm_bridge.wasm)
// ============================================================================

// All loaded by wasm_bridge.py into RhaeEngine class. MoonBit v0.9.3 WASM-GC
// does NOT support new exports from library packages. No new WASM functions
// possible. Only these 24 are available:

// Export                  Signature                   Use
// ======                  =========                   ===
// canonical_hash(ptr)     (ptr) -> (lo: int, hi: int) D4 Zobrist hash (8 transforms, lexicographic min)
// rhae_invariants()       () -> int                  Single inv integer
// get_inv(i)              (int) -> int               Read i-th invariant (0..9)
// rhae_build_candidates(legal, cost, lo, hi, k) -> n  Score candidates
// rhae_topk(k)            (int) -> int               Read top-k count
// get_topk(i)             (int) -> int               Read i-th topk
// rhae_tt_lookup(lo,hi)   (int,int) -> int           -1=miss, else action (1-based)
// rhae_tt_store(lo,hi,a,s)(int,int,int,int) -> void  Store in TT
// rhae_visited_reset()    () -> void                 Clear visited buffer
// set_visited(ai,val)     (int,int) -> void          Mark action visited
// get_visited(ai)         (int) -> int               Read visited flag
// load_frame(ptr,h,w)     (int,int,int) -> void      Load frame into WASM mem
// load_prev_frame(ptr,h,w)(int,int,int) -> void      Load previous frame for delta

// KNOWN BUG: Zobrist table 32×32×16 (ARC-2 legacy). For grids ≥32 px,
//   zt_idx clips row/col≥32 to 31 causing hash collisions.
//   Workaround: None (cannot extend table without new WASM build).

// ============================================================================
// §4  BUG REGISTRY (all time, never re-introduce)
// ============================================================================

// BUG-001: env_fn=None → beam search silent skip
//   File: kaggle_main.py. Fix: agent.env_fn = env.step

// BUG-002: D4 hash broken for non-square grids
//   File: wasm_bridge.py._make_d4_coeffs. Fix: cx/cy per transform

// BUG-003: vocab_size=16 vs checkpoint 12
//   File: submission_agent.py._load_backbone. Fix: urm_cfg.vocab_size=12

// BUG-004: IndexError token >= vocab_size
//   File: submission_agent.py._forward_pure. Fix: torch.clamp(state_tokens, 0, 11)

// BUG-005: dataset not mounted (competition_sources)
//   Fix: inline all dependencies in dataset zip. Kaggle API cannot set
//   competition_sources — WONTFIX.

// BUG-006: len(colors)==0 in canonical hash
//   File: wasm_bridge.py. Fix: np.bitwise_xor.reduce(initial=np.int64(0))

// BUG-007: action_emb.weight not in TTT params dict → device mismatch
//   File: wasm_bridge.py:265. Fix: add "action_emb." to _ADAPTER_HEAD_PREFIXES

// BUG-008: GameAction regular Enum (NOT IntEnum) — GameAction(1) raises ValueError
//   File: replay_explorer.py:173; build_notebook.py. Fix: use lookup list
//   _action_list = [GA.ACTION1, ..., GA.ACTION7] instead of _GA(a+1).
//   Root class: arcengine.enums.GameAction (Enum, not IntEnum).
//   env.action_space returns the actual Enum members per game.
//   Fix applied v21.2, but regression: sk48 has no ACTION5.

// BUG-009: env.action_space varies per game (not all 7 actions available)
//   File: replay_explorer.py:73-98. Fix v21.2+: read env.action_space in __init__.
//   sk48: [ACTION1,2,3,4,6,7] — no ACTION5.
//   _action_list = list(env.action_space) dynamically.

// BUG-010: _volatile_mask not in __slots__
//   File: replay_explorer.py:59-66. Fix v21.5: add "_volatile_mask" to __slots__.
//   Symptom: AttributeError: 'ReplayExplorer' object has no attribute '_volatile_mask'.

// BUG-011: build_notebook.py hardcodes kernel id "v19..." → pushes to wrong kernel
//   File: scripts/build_notebook.py:499. Fix v21.5: s/v19-action6-centroid-blind-probe/v21-w-replayexplorer-bfs/

// ============================================================================
// §5  ACTIVE CODE CHANGES (v21.5 = latest)
// ============================================================================

// replay_explorer.py (232 lines)
//   L059-066: __slots__ with _action_list, _volatile_mask
//   L068-104: __init__(env, hasher, ...) — reads env.action_space dynamically
//   L107-165: solve() — sorted frontier for LCP maximization
//   L200-229: _replay_to() — true incremental LCP (NO reset if current is prefix of target)
//   L231-240: set_action6_priority() — moves complex action (ACTION6) to front
//   L241-253: _untried_actions() — effective-actions-first pruning
//   L176-178: set_volatile_mask(mask) — volatile pixel mask for hash

// scripts/build_notebook.py (517 lines)
//   L209-210: arc = Arcade(), env_infos, Games: 25
//   L237-276: per-game loop. Before BFS: repeated-action probe (ACTION1×200, etc.)
//   L240-264: pre-BFS counter mask detection (2 distinct actions, detect_counter_mask)
//   L266-275: ReplayExplorer with volatile_mask, action6 priority
//   L276:     explorer.solve()
//   L279-299: if solved → replay solution
//   L280-307: else → counter mask + standard agent loop
//   L499:     kernel id (FIXED v21.5)
//   L4-11:    ACCELERATOR, CELL_LABELS

// FrameProcessor (frame_processor.py)
//   detect_counter_mask(g1, g2) → np.ndarray (volatile pixels = 1)
//   segment_frame(grid) → list of connected components
//   identify_status_bars(grid) → mask of likely UI elements

// ============================================================================
// §6  VERIFIED SCORING MECHANICS (from docs.arcprize.org)
// ============================================================================

// RHAE level_score = (human_baseline / ai_actions)²  ... capped at 1.15x
// Weighted game_score  = Σ(i · level_score_i) / Σ(i)  ... i = level index (1-indexed)
// levels 6-10 contribute 55% of total game score
// Exceeding 5x human baseline actions = level fail
// env.step() ALL calls count (exploration + replay)
// Incomplete game = max_score capped at Σ(weight_1..weight_k) / Σ(weight_1..weight_N)

// ============================================================================
// §7  PUBLIC GAME TAXONOMY (farmountain EXP-033, verified on known games)
// ============================================================================

// Category            Count   Examples        Needed
// 1-blind-step        10      FT09, R11L,     ACTION6 once or similar
//                              VC33
// ACTION6 after 1     5       SB26, CD82,     ACTION6 after 1 probe
// probe                       AR25, SK48,
//                              DC22
// repeated action     8       TU93 (×50),     ACTION1×50 .. ACTION6×200
// (50-200 steps)              LS20 (×129),
//                              WA30 (×200),
//                              SC25, TR87,
//                              RE86, S5I5,
//                              BP35
// diverse explore     1       SU15            multi-action BFS
// repeated ACTION1    1       SP80            ACTION1×N (our 1.0 score in v17!)

// Total: 25 public games. All solvable without ML (verified by Occam 57.6% RHAE
// and farmountain 30% RHAE on 55-game private set).

// ============================================================================
// §8  KNOWN LIMITATIONS (technical debt)
// ============================================================================

// L1: Zobrist hash table 32×32×16 causes collisions for grids ≥32px.
//     Impact: degraded de-dup for large grids. Unfixable without new MoonBit build.

// L2: No local test harness (no ARC-AGI-3 env installed outside Kaggle).
//     Cannot run RHAE locally. Must push to Kaggle to see results.
//     Workaround: None until arcengine publishes standalone version.

// L3: Kaggle GPU quota 30h/week. CPU-only runs are slow but reliable.
//     P100 (sm_60) incompatible with PyTorch ≥2.6 → CPU fallback.

// L4: LCP replay requires SAME env after each step (no env checkpoint/restore).
//     env.reset() is only way to rewind. Each reset costs ~5ms.

// L5: URM checkpoint 52MB — large but required for GPU mode. Not used on CPU.

// ============================================================================
// §9  IMMEDIATE PLAN (next session)
// ============================================================================

// Goal: Achieve ≥15% RHAE (public 25 games) before 30 June.
// Strategy: Fix all 3 active bugs → Run v21.5 → Measure → Iterate.

// STEP 1: FIX BUG-008* (env.action_space may not have all 7 actions)
//   FILE: replay_explorer.py:_to_ga()
//   COND: a >= _n_actions OR a < 0
//   ACT:  return _GA.RESET
//   TRY:  validate in __init__ that _action_list is non-empty
//   VERIFY: python -c "from replay_explorer import ReplayExplorer; print('OK')"

// STEP 2: VERIFY v21.5 RUN ON KAGGLE
//   KERNEL: krisskey/arc3-urm-ttt-v21-w-replayexplorer-bfs (v7)
//   DATASET: krisskey/vericoding-urm (v21.5)
//   EXPECT: Games: 25, BFS solves ≥5 games, repeated-action finds ≥3 games
//   IF CRASH: check logs at /kaggle/working/ output

// STEP 3: ADAPTIVE BUDGET (if v21.5 baseline established)
//   Add heuristic: repeated-action signature = frame delta empty on same action 2x
//   Only raise max_actions=15000 for games matching signature
//   FILE: build_notebook.py (around L240-264)

// STEP 4: PERSISTENT TT CACHE (if needed)
//   Save rhae_tt_store results across levels within same game
//   FILE: submission_agent.py (around _graph explorer)

// STRETCH: TinyMLP reranker (9760 params, CPU)
//   Dataset: (state_vector, candidate_vector, reward) from graph explorer traces
//   Train: 120→64→32→1, cross-entropy from explorer's action choice

// ============================================================================
// §10 CONSTANT REFERENCES
// ============================================================================

// Occam (57.60% RHAE): github.com/g-baskin/occam (MIT)
// farmountain/AERA (30% private): arXiv:2605.25931 (CC0)
// StochasticGoose (12.58%): github.com/DriesSmit/ARC3-solution (Apache 2.0)
// just-explore (3rd place, 17/25): github.com/dolphin-in-a-coma/arc-agi-3-just-explore
// Ocial scoring: docs.arcprize.org/methodology
// ARC-AGI-3 starter: github.com/arcprize/ARC-AGI-3-Kaggle-Starter (Apache 2.0)

// ============================================================================
// §11 DAFNY FORMAL SPEC — Pipeline
// ============================================================================

// function Pipeline(game_id: string): RHAE
//   requires game_id in Environments
//   ensures RHAE >= 0.0
// {
//   var env := make_env(game_id);
//   var agent := make_agent();
//   var frame := env.reset();
//   var mask := tryCounterMask(env, 2);
//   var explorer := ReplayExplorer(env, agent.get_hasher(), mask);
//   var solution := explorer.solve()
//                    ?? repeatedActionProbe(env, MAX_STEPS)
//                    ?? agentLoop(env, agent);
//   if solution ≠ None then replay(env, solution) else Skip;
//   return computeRHAE(env, solution);
// }

// predicate RepeatedActionLikely(env: Env): bool {
//   // After 3 consecutive same-actions, frame delta = 0
//   var a := env.action_space[0];
//   var f1 := env.step(a);
//   var f2 := env.step(a);
//   hash(f1) == hash(f2)
// }

// ============================================================================
// §12 METADATA
// ============================================================================
// Generated: 27 June 2026 12:30 UTC
// Author: VERICODING Agent 1 (Architect)
// Target: Next session cold-start. Read this first, then read _staging/*.py.
// Token budget: Keep every line. This is the single source of truth for handoff.
