# VERICODING — Shift Log (v11 → v19)

## Fundamental Approach Change

### Phase 1: Direct Env Loop (v11–v12)
Direct Arcade().make() + DenseExplorer BFS in Cell 3.
Problem: Arcade() requires internet / gateway. Fails in Phase A.
- v11: DenseExplorer BFS (1024 positions, 3 phases) inline in Cell 2 + direct env loop in Cell 3
- v12: + API diagnostic at top of Cell 2, universal adapter (_reset, _step)

### Phase 2: Framework Submission Path (v13–v19) ← **current**
Abandoned direct Arcade(). Switched to ARC-AGI-3-Agents framework (main.py --agent).
Phase A writes dummy parquet. Phase B copies framework boilerplate, injects agent, runs main.py.
- v13: VericodingAgent with one-hot D4 Zobrist hash (np.eye(16)), relative import (.agent), lowercase key
- v19: axis=(0,1,2) fix (not axis=None), pre-allocated self._eye16 for perf

## Bug Registry

| Bug | Introduced | Fixed In | Root Cause |
|-----|-----------|----------|------------|
| Hash color-blind (g[:,:,None]>0 broadcast) | v10 | v13 | broadcast bool mask XORs all 16 colors → identical hash for different colors |
| np.bitwise_xor.reduce no axis → shape(W,16) | v13 | v16 | default axis=0 reduces first dim only. int() on ndarray → TypeError |
| from agents.agent import Agent (absolute) | v10 | v13 | agents package not on sys.path in Phase B context |
| Framework key case mismatch | v10 | v13 | main.py lower()s --agent arg. "VericodingAgent" fails. |
| Missing main.py in working dir | v10 | v13 | os.chdir(/kaggle/working) + subprocess.run(main.py) fails if main.py not copied |

## Current Architecture (v19)
```
Cell 1: pip install arc-agi from competition wheels
Cell 2: define VericodingAgent (one-hot D4 Zobrist, axis=(0,1,2), _eye16 pre-alloc)
        → write to /tmp/my_agent.py
Cell 3 (Phase A): write dummy submission.parquet
Cell 3 (Phase B): curl gateway → copy agents/ + main.py → inject agent → main.py --agent vericoding
```

## Pending
- Phase B never tested (requires Submit click on Kaggle)
- Per-step agent framework limits exploration (no BFS, no reset)
- NO TTT/ML/backbone — purely heuristic D4-hash + frontier pixel scan
