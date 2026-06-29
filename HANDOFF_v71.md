# HANDOFF v71 — Minimal Kernel

## Current State

| Metric | Value |
|--------|-------|
| Score | 0.0400 (vc33=1.0, 24/25=0) |
| Games completed | 25/25 (zero crashes) |
| Runtime | 25s CPU |
| Last kernel | krisskey/arc3-minimal-v70 v8 |
| GitHub | master d48edd9 |

## Key Files Changed

### `kaggle_staging/submission_agent.py` lines 163-166
**Fix:** early return for `_DummyCarry` (no `steps` attribute)
```python
if not hasattr(carry, "steps"):
    return carry
return dataclasses.replace(
    carry,
    current_hidden=carry.current_hidden.to(device),
    steps=carry.steps.to(device),
```
This file is in the REPO and KAGGLE_STAGING but NOT in the Kaggle dataset. Dataset still has old version.

### `kaggle_staging/scripts/build_notebook.py`
**4 cells, minimal notebook:**
- CELL_0: copy files + install arc-agi + env discovery
- CELL_1: agent init + URM CPU load + **monkey-patch _carry_to_device**
- CELL_2: game loop + agent + **TTT on GPU/CPU** + score
- CELL_3: save metrics

**Monkey-patch** (CELL_1, after imports):
```python
_sa_orig = sa._carry_to_device
def _safe_carry(carry, device):
    if not hasattr(carry, 'steps'): return carry
    return _sa_orig(carry, device)
sa._carry_to_device = _safe_carry
```

## Known Issues

### P0: TTT crashes on P100 (CUDA kernel mismatch)
Kaggle assigns P100 (sm_60) even when ACCELERATOR=t4 requested.
URM checkpoint compiled for sm_75+ (T4). TTT on GPU crashes.
**Fix options:**
1. Force TTT to CPU: change `tdev = "cuda" if torch.cuda.is_available() else "cpu"` → `tdev = "cpu"`
2. Request RTX6000 (sm_86+ but burns GPU quota)
3. Recompile URM with sm_60 kernels (requires URM training repo)

### P1: DenseExplorer disabled
Was removed during simplification. Could find live clicks deterministically for simple games.
**Fix:** Add back in CELL_2 between `env.reset()` and main loop.

### P2: lp85 + su15 consume MAX_STEPS (10000 total)
No early-stop mechanism. Games with score=0 for 500 steps waste 33% of budget.
**Fix:** Add `if _ > 500 and score == 0.0: break` in game loop.

## Architecture Notes

```
build_notebook.py → generates submission.ipynb → kaggle kernels push
  Dataset: krisskey/vericoding-urm (has OLD submission_agent.py)
  CELL_0 copies files from dataset to /kaggle/working/
  CELL_1 monkey-patches _carry_to_device on old file
  CELL_2 runs agent loop + TTT
```

## Deployment Commands
```bash
cd kaggle_staging/scripts && python build_notebook.py && cd .. && kaggle kernels push -p .
cd C:\Users\kross\Documents\MoonArc3-v1.3 && git add -A && git commit -m "msg" && git push origin master
kaggle kernels status krisskey/arc3-minimal-v70
kaggle kernels output krisskey/arc3-minimal-v70 -p <out_dir> --force
```

## Score Bottleneck
0.04 = 1 win (vc33) out of 25. Agent plays all games without crash but only vc33's click targets happen to work. Root cause: state exploration uses segment centroids that miss pixel-perfect click targets. Real fix requires WASM stable-hash + deterministic graph exploration.
