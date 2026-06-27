# VERICODING Handoff — v21 (27 June 2026)

## 🎯 Current Target
ARC-AGI-3 competition (25 public games, 55 private). Score: **0.04** (v17 baseline, 1 level completed). Goal: top 3.

## 📁 File Structure & Dependencies

```
kaggle_staging/                      ← Kaggle dataset root
├── submission_agent.py              (100KB) — MAIN AGENT: VERICODINGAgent class
├── wasm_bridge.py                   (53KB)  — WASM bridge + RhaeEngine + TTT utils
├── frame_processor.py               (8KB)   — NEW (v20): segmentation + status bars + counter mask
├── replay_explorer.py               (8KB)   — NEW (v21): BFS with reset-replay (Occam technique)
├── build_notebook.py                (scripts/) — Generator: produces submission.ipynb
├── submission.ipynb                 ← auto-generated notebook for Kaggle
├── kernel-metadata.json             ← Kaggle kernel config (CPU-only, dataset sources)
├── dataset-metadata.json            ← Kaggle dataset config
├── wasm_bridge.wasm                 (68KB)  — WASM binary (MoonBit compiled, 24 exports)
├── rhae_stage1.wasm                 (14KB)  — RHAE WASM (canonical hash, topk, invariants)
├── urm_checkpoint.pt                (52MB)  — URM backbone checkpoint (soup_vast.pt)
└── wasmtime-27.0.2-py3-none-...     (6MB)   — wasmtime wheel for WASM runtime
```

### Dependency Graph
```
build_notebook.py
    └── generates → submission.ipynb
        ├── CELL_0: copies all files to /kaggle/working/
        ├── CELL_1: installs arc-agi + wasmtime + dependencies
        ├── CELL_2: imports + device detection + optional URM load
        ├── CELL_3: GPU diagnostics
        ├── CELL_4: GAME LOOP — ReplayExplorer BFS → Agent loop → TTT
        ├── CELL_5: optional TTT benchmark on trajectories
        └── CELL_6: save results + adapter metadata

submission_agent.py (VERICODINGAgent)
    ├── imports wasm_bridge.py (RhaeEngine, TTT utils)
    ├── imports frame_processor.py (FrameProcessor)
    └── imports replay_explorer.py (ReplayExplorer)

frame_processor.py
    └── standalone (numpy, scipy)

replay_explorer.py
    ├── uses agent.get_hasher() for canonical hash
    └── uses env.reset() + env.step() for BFS exploration

wasm_bridge.py
    ├── Loads rhae_stage1.wasm + wasm_bridge.wasm
    ├── RhaeEngine: 24 WASM exports (canonical_hash, invariants, topk, TT, visited)
    └── TTT utils: functional_ttt_train, pure_batch_ttt_loss
```

## 🔄 Recent Changes (v19 → v20 → v21)

### v19 (26 June) — GameAction pipeline + centroid clicks
| Change | File | Description |
|--------|------|-------------|
| `_click_centroid()` | submission_agent.py | Changed→nonzero→(32,32) pixel centroid |
| `_to_game_action(idx)` | submission_agent.py | 0-based int → GameAction enum with data |
| Blind probe | submission_agent.py | step=0 → ACTION6 at centroid |
| Blacklist activation | submission_agent.py | Dedup redundant action-hash pairs |
| `level_step` counter | submission_agent.py | Per-level step tracking |
| Game loop GameAction | build_notebook.py | env.step(act) receives GameAction object |
| **Push**: dataset v19 → `krisskey/vericoding-urm`, notebook v19 → `arc3-urm-ttt-v19-action6-centroid-blind-probe`

### v20 (27 June) — FrameProcessor + status bar masking (from just-explore)
| Change | File | Description |
|--------|------|-------------|
| `FrameProcessor` (NEW) | `frame_processor.py` | Connected components flood fill, twin detection |
| Status bar masking | submission_agent.py | grid→segment→mask→hash (UI elements zeroed) |
| Segment-based click | submission_agent.py | `_best_segment_click()` instead of pixel centroid |
| 5 priority groups | submission_agent.py | G0→G4 for action selection tiering |
| URM skip on CPU | build_notebook.py | URM loaded only if GPU detected |
| **Push**: dataset v20, notebook v20 → `arc3-urm-ttt-v20-w-status-bar-masking`

### v21 (27 June, CURRENT) — ReplayExplorer BFS + counter mask (from Occam)
| Change | File | Description |
|--------|------|-------------|
| `ReplayExplorer` (NEW) | `replay_explorer.py` | BFS with env.reset()+replay prefix (Occam technique) |
| `detect_counter_mask()` | frame_processor.py | Adaptive volatile pixel detection |
| Step-modulus hashing | submission_agent.py | `hash ^= (step % 3) << 28` |
| CELL_4 BFS-first | build_notebook.py | ReplayExplorer.solve() → if found: replay → else: agent loop |
| `get_hasher()` | submission_agent.py | Returns WASM hash function for ReplayExplorer |
| `set_step_modulus()` | submission_agent.py | Enables step-modulus hashing per game |
| **Push**: dataset v21, notebook v21 → `arc3-urm-ttt-v21-w-replayexplorer-bfs`

## 🧱 Architecture (Current)

### Pipeline — per game
```
Step 0: env.reset()
Step 1: ReplayExplorer.solve()  [NEW v21]
            ├── BFS depth 0..12
            ├── env.reset() → replay prefix → try actions
            ├── CANONICAL_HASH via WASM for state identity
            ├── STEP-MODULUS hash to distinguish states by depth
            ├── COUNTER MASK: volatile pixel detection
            └── if WIN found → return action path
Step 2: if solution found → replay it
Step 3: if NO solution → FrameProcessor + agent loop
            ├── FrameProcessor.segment_frame() → flood fill components
            ├── FrameProcessor.identify_status_bars() → status bar mask
            ├── FrameProcessor.detect_counter_mask() → volatile pixel mask [v21]
            ├── Apply mask to grid → CANONICAL_HASH (D4 Zobrist via WASM)
            ├── FrameGraphExplorer (priority tiers + frontier dedup)
            ├── WASM topk pre-filter (7→3 candidates via vis_buf)
            ├── TT lookup/store (65K entries, D4-canonical hashes)
            └── URM fallback (only if GPU available)
Step 4: Per-game TTT fine-tuning (only if URM + GPU)
Step 5: Results saved → adapter_metadata.json
```

### WASM exports used (24 total, all via RhaeEngine)
| Export | Signature | Use |
|--------|-----------|-----|
| `canonical_hash(ptr)` | → (lo, hi) | D4 Zobrist hash (all 8 transforms, lexicographic min) |
| `rhae_invariants()` | → int | Single inv integer from inv_buf[0..9] |
| `get_inv(i)` | → int | Read i-th invariant (n_comp, n_colors, bbox, etc.) |
| `rhae_build_candidates(legal, cost, lo, hi, k)` | → n | Build candidate scores |
| `rhae_topk(k)` | → n | Read top-k from candidates |
| `get_topk(i)` | → int | Read i-th topk |
| `rhae_tt_lookup(lo, hi)` | → int (-1=miss, 1-based action) | TT lookup |
| `rhae_tt_store(lo, hi, action, score)` | → void | TT store |
| `rhae_visited_reset()` | → void | Clear visited buffer per level |
| `set_visited(ai, val)` | → void | Mark action as visited |
| `get_visited(ai)` | → int | Read action visited flag |
| `load_frame(ptr, h, w)` | → void | Load frame into WASM memory |
| `load_prev_frame(ptr, h, w)` | → void | Load previous frame for delta |

### URM (52MB checkpoint, CPU-only fallback)
- Loaded only if GPU (cuda) detected
- 4-head seq2seq (O/R/C/Geo), seq_len=4099, vocab_size=12
- TTT fine-tuning disabled when no GPU
- Not used in primary pipeline — only as fallback for action selection

## ⚠️ Key Constraints & Known Bugs

| # | Issue | Status | Workaround |
|---|-------|--------|------------|
| 1 | Kaggle GPU quota 30h/week | ACTIVE | CPU-only mode (enable_gpu: false) |
| 2 | P100 (sm_60) incompatible with PyTorch ≥2.6 | ACTIVE | _detect_device() → CPU fallback |
| 3 | Kaggle API cannot set `competition_sources` | WONTFIX | All dependencies zipped in dataset |
| 4 | Zobrist hash table 32×32×16 (ARC-2 legacy) | KNOWN | Collisions for grids ≥32px. Fix: Python fallback |
| 5 | ACTION6 click needs GameAction.set_data() | FIXED v19 | `_to_game_action()` handles |
| 6 | URM TTT on CPU too slow (3h+) | MITIGATED | Skip TTT if no GPU |
| 7 | Zobrist D4 canonical integer overflow | FIXED v16 | `np.int64` accumulator |

## 📋 Action Plan — Next Steps

### Priority 1: ReplayExplorer refinement (v22, 1-2h)
- [ ] Add incremental replay optimization (Occam technique: DFS-order prefix reuse)
- [ ] Add winning combo cache (carry solutions across levels within game)
- [ ] Add action effectiveness tracking (prune actions that never change state)
- [ ] Add A* heuristic (optional, based on frontier distance)

### Priority 2: Dense click scan (v22, 1h)
- [ ] `ReplayExplorer.dense_click_scan()`: enumerate 64×64 at step=2 (1024 positions)
- [ ] For each click: record outcome hash → dedup → compact virtual action list
- [ ] Only for games with `env.info.tags` containing "click" or ACTION6

### Priority 3: URM re-enablement (v23, when GPU quota refreshes)
- [ ] Re-enable URM inference on GPU
- [ ] TTT fine-tuning on agent exploration data (not just trajectory)
- [ ] Fusion: BFS solution paths → URM supervised fine-tuning

### Priority 4: TinyMLP reranker (v23-v24, CPU-only)
- [ ] Dataset collection: (state_vector, candidate_vector, reward)
- [ ] TinyMLP (9760 params: 120→64→32→1)
- [ ] Replace URM fallback with MLP reranker

## 🚫 What NOT To Do
- ❌ Don't rewrite submission_agent.py from scratch (17KB HybridAgentV20 is too risky)
- ❌ Don't add new WASM exports (MoonBit v0.9.3 WASM-GC blocks library exports)
- ❌ Don't use LLM/API calls (budget + latency dead end for ARC-AGI-3)
- ❌ Don't chase URM improvements before exploration pipeline is solid
- ❌ Don't spend GPU time on CPU-compatible tests

## 🔗 Links
- Latest notebook: https://www.kaggle.com/krisskey/arc3-urm-ttt-v21-w-replayexplorer-bfs
- Latest dataset: https://www.kaggle.com/datasets/krisskey/vericoding-urm
- Occam (57.60% RHAE): https://github.com/g-baskin/occam
- just-explore (3rd place): https://github.com/dolphin-in-a-coma/arc-agi-3-just-explore
- Score formula: https://docs.arcprize.org/methodology

---

*Generated for Agent 2 handoff. Questions → verify against actual source code before acting.*
