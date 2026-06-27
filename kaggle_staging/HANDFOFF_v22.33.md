# HANDOFF v22.33 — stan: 27-06-2026 13:30 CEST

## Repo

```
C:\Users\kross\Documents\MoonArc3-v1.3\
├── kaggle_staging/              ← CO IDZIE NA KAGGLE
│   ├── submission_agent.py      ~88KB (URMWMA + VERICODINGAgent)
│   ├── wasm_bridge.py           ~52KB (RhaeEngine 24 WASM exports)
│   ├── frame_processor.py       ~8KB (Flood fill FF, status bary, priority tiers G0-G4)
│   ├── algebra_probe.py         ~8KB (Algebra probe: absorbing, periodic, idempotent)
│   ├── graph_explorer.py        ~8KB (Frontier BFS z heuristic rankerem)
│   ├── build_notebook.py        ~16KB (scripts/build_notebook.py)
│   ├── rhae_stage1.wasm         14KB (64x64 Zobrist, 24 exportów)
│   ├── wasm_bridge.wasm         68KB (legacy)
│   ├── urm_checkpoint.pt        52MB (GPU-only, CPU nie ładuje)
│   ├── environment_files/       25 gier ARC-AGI-3
│   └── external/urm/            URM repo (GPU-only)
└── moonarc3/
    ├── rhae_stage1.wat           8261 linii WAT (linear memory, source)
    ├── rhae_stage1_64x64.wat     8261 linii (po patchu 32→64)
    ├── rhae_stage1_64x64.wasm    14072B (skompilowany)
    ├── src/rhae/                 MoonBit source (24 fn, referencyjne)
    └── patch_wasm.py             skrypt do patcha WAT
```

## Architektura — Pipeline Decyzyjny (CPU-only)

```
env → Algebra Probe (2500 stepów, wykrywa typ gry)
  │
  ├─ absorbing=YES → ACTION6×1 @ centroid          → WIN ~1 step
  ├─ repeated_win=YES → ACTIONi × 50-200            → WIN ~N steps
  ├─ period=YES → cykl ACTIONi → ACTIONj             → WIN ~period steps
  └─ complex → GraphExplorer (budget=2000)
       │
       ├─ FrameProcessor.segment_frame() → FF 4-neighbor
       │   → components[bbox, color, area, is_rect, twins]
       │   → frame_segments_to_action_groups() → G0..G4
       │
       ├─ HeuristicRanker._score_candidate(tier, cx, cy, area)
       │   confidence = 10*(5-tier) + 5*(area/max_area) + 3*novelty
       │   (0 params, manual weights, no training)
       │
       ├─ Frontier BFS: _rebuild_distances()
       │   → farthest state from frontier → _backtrack() → replay prefix
       │
       ├─ _next_untried(s_hash) → picks HIGHEST scored untried candidate
       │   → ACTION6 @ (cx, cy) → env.step()
       │   → new state → add to frontier + edges
       │   → repeat until all candidates tried at this state
       │
       └─ On WIN: solution = path of (action_idx, cx, cy)
```

## 24 WASM Exporty (rhae_stage1.wasm, 64x64 Zobrist)

| Export | Args | Returns | Użycie |
|--------|------|---------|--------|
| `rhae_canonical_hash` | h, w | lo (int) | D4 min Zobrist hash |
| `rhae_get_hash_hi` | — | hi (int) | drugie 32b hasha |
| `rhae_hash_and_check` | h, w | bitmask(2b) | hash + visited + TT |
| `rhae_invariants` | — | void (inv_buf) | 10 elementów |
| `get_inv` | i | int | inv_buf[i] |
| `rhae_build_candidates` | legal, cost, lo, hi, max_c | n_cand | 7 mat_buf wierszy |
| `rhae_topk` | n, k | void | topk sort mat_buf |
| `get_topk` | i | int | score lub -1 |
| `get_mat` | i, j | int | mat_buf[i][j] |
| `rhae_tt_lookup` | lo, hi | action(-1=miss) | transposition cache |
| `rhae_tt_store` | lo, hi, a, s | void | transposition store |
| `rhae_visited_check` | — | 0/1 | visited flag |
| `rhae_visited_mark` | — | void | mark current as visited |
| `rhae_visited_reset` | — | void | clear visited (new level) |
| `rhae_policy_gate` | — | 0/1 | policy filter |
| `set_grid_cell` | idx, val | void | write grid cell |
| `set_prev_cell` | idx, val | void | write prev grid |
| `set_visited` | ai, val | void | vis_buf per-action |
| `set_risk` | val | void | risk flag |
| `zobrist_init` | — | void | init Zobrist table |
| `zobrist_hash_grid` | grid, h, w | lo | raw (non-canonical) hash |
| `zobrist_update_cell` | lo,hi,row,col,old,new | (lo,hi) | incremental update |

**Ważne:** WSZYSTKIE zwracają pojedynczy `i32` (lo-hash lub flagę). ŻADEN nie zwraca `(lo, hi)` — hi trzeba czytać osobno przez `rhae_get_hash_hi()`.

## Bug — Hasher API (KRYTYCZNY)

`agent.get_hasher()` zwraca `lambda g: int` (pojedynczy int), ale `algebra_probe._hash()` i `graph_explorer._grid_hash()` oczekują pojedynczego int. **Żadne unpacking `lo, hi = HASHER(grid)` nie działa.** Naprawione w v22.32 → `h = HASHER(grid)`.

## Obecnie Działający kernel (v16)

**Kernel:** https://www.kaggle.com/krisskey/arc3-urm-ttt-v22-w-algebra-probe-pipeline (v16)
**Czas:** ~15 min od startu, GPU oczekuje

## Status Implementacji

| Komponent | Status | Od wersji |
|-----------|--------|-----------|
| Algebra Probe (absorbing/repeated/periodic/cycle) | ✅ | v22 |
| FrameProcessor (flood fill, status bars, G0-G4) | ✅ | v20 (from just-explore) |
| WASM 64x64 Zobrist (no hash collisions) | ✅ | v22.2 |
| GraphExplorer (frontier BFS + replay) | ✅ | v22.3 |
| Heuristic Ranker (0 params, manual weights) | ✅ | v22.33 (właśnie) |
| ALL-candidates inner loop (vs 1 per state) | ✅ | v22.33 |
| Counter mask (adaptive volatile pixel) | ⏳ istnieje w FrameProcessor | do integracji |
| Dense click scan (1024 positions 2px stride) | ❌ | nie |
| Tiny MLP reranker | ❌ | nie (GPU limit) |
| Per-group historical utility | ❌ | nie |
| Ensemble (Algebra + Graph + ...) | ❌ | nie |

## Co dalej (po wyniku v22.33)

1. **Jeśli score >= 12%** → dopracuj heuristic ranker weights, push v23
2. **Jeśli score 4-8%** → GraphExplorer działa częściowo, dodaj dense click scan (~1h)
3. **Jeśli score < 4%** → bug w pipeline, wróć do algebra_probe same (to działa na prostych)
4. **Zawsze:** zbieraj statystyki per-game (który solver, ile stepów, score)

## Kluczowe ograniczenia

- **MoonBit v0.9.3 WASM-GC** → 24 eksporty z main target, 0 z library target, nie da się dodać nowych
- **WASM pipeline** → `rhae_stage1.wat` → `python patch_wasm.py` → `wat2wasm.exe`
- **WASM-GC niekompatybilny** → `moon build --target wasm-gc` produkuje 2 eksporty, nie używamy
- **GPU limit wyczerpany** → CPU-only do końca tygodnia
- **env.step() ~3-6ms** → bottleneck, ~70% czasu per-action
- **Bucket 9h Kaggle** → 25 gier × (2500 probe + 2000 explorer) = 112500 stepów × 5ms = ~10 min CPU

## Pliki do nowego sesji

1. `kaggle_staging/graph_explorer.py` — główny plik z heurystycznym rankerem
2. `kaggle_staging/frame_processor.py` — segmentacja + priorytety
3. `kaggle_staging/algebra_probe.py` — algebra action probe
4. `kaggle_staging/scripts/build_notebook.py` — integracja pipeline
5. `kaggle_staging/wasm_bridge.py:589-667` — RhaeEngine
6. `kaggle_staging/submission_agent.py:2379-2387` — get_hasher()
7. `moonarc3/patch_wasm.py` — patch 32→64 w WAT
8. `moonarc3/rhae_stage1.wat:7637-7682` — zt_idx clip (32→64)
