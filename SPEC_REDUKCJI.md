# SPECYFIKACJA REDUKCJI — VERICODING DETERMINISTIC v1.0

## Cel
Zredukować 14 plików / 128KB / 5 cross-importów → 1 plik / ~50KB / 0 importów lokalnych.
W pełni deterministyczny (zero ML, zero random, zero GPU). Mieści się w kontekście modelu AI (~8K tokenów).

## Architektura docelowa: 1 plik

```
solution.py (~800 LOC)
├── Sekcja 1: ARC-AGI-3 Adapter (~30 LOC)
│   ├── safe_step(env, action, x, y) → Frame | None
│   ├── _normalise(raw) → StepResult (obs, reward, done, info)
│   ├── is_win(frame) → bool
│   └── get_action_list(env) → list[GameAction]
│
├── Sekcja 2: D4 Zobrist Hash (~50 LOC, pure numpy)
│   ├── _zt_lo/_zt_hi tables (splitmix64 seeding)
│   ├── grid_hash(grid) → int64
│   └── d4_canonical_hash(grid) → int64 (min over 8 dihedral transforms)
│
├── Sekcja 3: DenseExplorer (~120 LOC)
│   ├── DenseConfig (max_steps, stride, click_stride)
│   ├── scan_all_positions(env) → (score, solution)
│   └── replay_solution(env, solution) → score
│
├── Sekcja 4: GraphExplorer (~180 LOC)
│   ├── GraphConfig (max_steps, max_nodes, timeout)
│   ├── explore(env) → (score, solution)
│   └── _backtrack(env, path) → score
│
├── Sekcja 5: Orchestrator (~200 LOC)
│   ├── _frame_score(f) → float
│   ├── _run_episode(gid, env) → (score, strategy)
│   ├── Strategy dispatch: GraphExplorer → DenseExplorer → BFS → fallback
│   └── _write_submission(scores) → submission.json
│
└── Sekcja 7: Entry point (~50 LOC)
    ├── main(): discover games, run episodes, save results
    └── if __name__ == "__main__": main()
```

## Eliminowane pliki (10 plików, ~80KB)

| Plik | Rozmiar | Powód eliminacji | Zastąpiony przez |
|------|---------|------------------|-------------------|
| submission_agent.py | 14KB | URM neural net = stochastyczny | DenseExplorer (deterministyczny BFS) |
| beam_search.py | 12KB | MCTS z random rollouts | BFS/DFS bez random |
| mcts_planner.py | 8KB | Monte Carlo (stochastyczny) | DenseExplorer grid scan |
| ttt_submission.py | 5KB | SGD gradient descent | niepotrzebny (brak ML) |
| wasm_bridge.py | 12KB | WASM + torch → 2 code pathy | D4 hash inline (pure numpy) |
| trajectory_cache.py | 4KB | caching na kolejne gry | inline visited set |
| game_profiler.py | 12KB | profiling z env interakcją | zliczanie działań w main |
| action_budget.py | 2KB | time management | inline 2 linie |
| game_memory.py | 3KB | state store | D4 visited set |
| frame_processor.py | 8KB | grid processing | DenseExplorer wbudowany |

**Zostają: 4 pliki → wchłonięte w solution.py**
| Plik | Rozmiar | Integracja |
|------|---------|------------|
| step_adapter.py | 0.9KB | inline Sekcja 1 |
| dense_explorer.py | 9.6KB | Sekcja 3 |
| graph_explorer.py | 16KB | Sekcja 4 |
| kaggle_main.py | 22KB | Sekcja 5 |

## Determinizm: gwarancje formalne

```
// Każda funkcja zwraca IDENTYCZNY output dla tego samego inputu
predicate DeterministicPipeline()
    // 1. Brak importu random / numpy.random / torch
    ensures no "import random" in solution.py
    // 2. Brak GPU/cuda (różne precyzje numeryczne)
    ensures no "cuda" or "torch" in solution.py
    // 3. D4 hash: deterministyczny (stałe splitmix64 seed)
    ensures d4_canonical_hash(g) = d4_canonical_hash(g)  // ∀ g
    // 4. Kolejność eksploracji: stała (posortowane action list)
    ensures explore(env) = explore(env)  // ∀ env
    // 5. Brak timeout (time.time → stały budget)
    ensures all time budgets are const int
{}
```

## Dafny-level spec: kluczowe invarianty

```
// === Invariant 1: Action Contract ===
// safe_step ALWAYS receives action OBJECT, never int index
predicate ActionContract(env, action, x, y)
    requires hasattr(action, 'is_complex')
    ensures  safe_step(env, action, x, y) is None 
             XOR safe_step(env, action, x, y) is Frame
    // Jeśli action.is_complex() == True, x i y MUSZĄ być int
    // Jeśli action.is_complex() == False, x i y IGNOROWANE
{}

// === Invariant 2: Visited Set ===
// Nigdy nie odwiedzamy 2 stanów które są D4-izomorficzne
predicate D4Invariant(visited: set<int64>)
    ensures ∀ s1, s2 ∈ visited :: s1 ≠ s2
    ensures ∀ g1, g2 :: D4_equivalent(g1, g2) 
             ⇒ d4_canonical_hash(g1) = d4_canonical_hash(g2)
{}

// === Invariant 3: Termination ===
// Każda strategia kończy się w deterministycznym czasie
predicate Termination(max_steps: int)
    requires max_steps ∈ {1000, 5000, 10000}
    ensures  explore() returns within max_steps
    ensures  scan_all_positions() returns within max_steps * stride
    ensures  _run_episode() always returns (score, strategy_name)
{}
```

## Token budget (GPT-4 context)
| Komponent | LOC | Tokeny (est) |
|-----------|-----|--------------|
| Sekcja 1: adapter | 30 | ~200 |
| Sekcja 2: D4 hash | 50 | ~350 |
| Sekcja 3: DenseExplorer | 120 | ~800 |
| Sekcja 4: GraphExplorer | 180 | ~1200 |
| Sekcja 5: Orchestrator | 200 | ~1500 |
| Sekcja 6: Entry | 50 | ~350 |
| Dafny spec (above) | 100 | ~700 |
| Komentarze | ~70 | ~500 |
| **RAZEM** | **~800 LOC** | **~5600 tokens** |

## Ryzyka i mitigacje
| Ryzyko | P-stwo | Mitigacja |
|--------|--------|-----------|
| BFS na 64x64 = 4096 pozycji × 7 akcji = 28K kroków | medium | stride=2 (1024 pozycje), timeout 90s/game |
| Complex actions (ACTION6) bez x,y = None | high | brute sweep (32,32) dla ACTION6 |
| D4 hash na CPU zbyt wolny | low | numpy vectorized, ~1μs per frame |
| Kaggle pip install arc-agi fail | medium | Tier-1/2/3 fallback w install |

## Co zyskujemy
1. **Determinizm**: ta sama wersja kodu daje IDENTYCZNY wynik na każdym uruchomieniu
2. **Kontekst**: całość ~5600 tokenów = mieści się w każdym modelu z 8K+ oknem
3. **Brak zależności**: zero cross-importów, zero "nie wiem co jest w tym pliku"
4. **Weryfikowalność**: Dafny spec gwarantuje invarianty
5. **Debugowalność**: jeden plik, jeden traceback, zero "który plik importuje co"
