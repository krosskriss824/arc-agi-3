# VERICODING — ARC-AGI-3 Solver

**Neuro-symbolic solver for the Abstraction and Reasoning Corpus (ARC-AGI-3).
Combines deterministic graph exploration with neural Test-Time Training.**

[Paper](https://github.com/krosskriss824/arc-agi-3) · [Kaggle Competition](https://kaggle.com/competitions/arc-prize-2026-arc-agi-3) · [ARC-AGI-3 Dataset](https://kaggle.com/datasets/krisskey/vericoding-urm)

## Structure

```
arc-agi-3/
├── moonarc3/                          # MoonBit source (RHAE engine)
│   ├── src/rhae/                      #   D4 Zobrist hash, invariants, policy gate
│   │   ├── canon.mbt                 #   D4 canonicalization (8 dihedral transforms)
│   │   ├── zobrist.mbt               #   Zobrist hash table (splitmix64)
│   │   ├── invariants.mbt            #   Grid invariants: components, bbox, Euler, holes
│   │   ├── policy_gate.mbt           #   Policy gate network
│   │   └── exports.mbt               #   WASM FFI exports
│   └── rhae_stage1.wat               #   WebAssembly Text (human-readable WASM)
├── kaggle_staging/                    # Kaggle submission package
│   ├── solution.py                   #   Deterministic single-file solver (no ML)
│   ├── kaggle_main.py                #   Full pipeline orchestrator
│   ├── submission_agent.py           #   VERICODINGAgent (URMWMA backbone)
│   ├── wasm_bridge.py                #   Python ↔ WASM bridge
│   └── kernel-metadata.json          #   Kaggle kernel config
├── external/urm/models/              # URM neural architecture
│   ├── urm/urm.py                    #   URM + URMInner + URMCarry
│   ├── layers.py                     #   CastedEmbedding, RMSNorm, RoPE
│   └── losses.py                     #   ACTLossHead, stablemax, TTT regularisers
├── smoke/                            # Smoke tests
│   └── smoke_v11.py
└── CHANGELOG.md
```

## Architecture

Two-tier strategy pipeline:

### Tier 1: Deterministic Search (CPU, no ML)
- **DenseExplorer** — 1024-position BFS grid scan (stride 2), replay from live clicks
- **GraphExplorer** — Frontier-based DFS with D4-canonical visited set
- **SimpleAgent** — Deterministic action-priority fallback loop

### Tier 2: Neural TTT (GPU optional)
- **URMWMA** — 13.7M param seq2seq backbone with 4-head policy
- **Test-Time Training** — 50-step SGD on action/value heads from beam trajectories
- **WASM acceleration** — MoonBit-compiled RHAE engine for fast hashing

## Kaggle Submission

The dataset is at `kaggle_staging/`. Upload as Kaggle dataset and run:

```python
from solution import solve_all
scores = solve_all()
```

or with the full pipeline:

```python
from kaggle_main import run_submission
run_submission()
```

## Local smoke test

```bash
python smoke/smoke_v11.py
```

## Key invariants

- Deterministic mode: zero `import random`, zero ML, zero GPU
- Neural mode: zero `torch.tensor/zeros/ones` without `device=`
- Action contract: complex actions always receive `data={"x":int,"y":int}`
- D4-visited: never revisit D4-isomorphic states
- No `torch.compile` — eager-only on T4/P100
