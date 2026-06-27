# ARC-AGI-3 — SOTA Kaggle Submission

**URM (Universal Reasoning Model) based ARC-AGI-3 solver.**

## Structure

```
arc-agi-3/
├── kaggle_staging/
│   ├── submission_agent.py   # URMWMA + VERICODINGAgent
│   ├── wasm_bridge.py        # Pure functional TTT + adapter I/O
│   └── kaggle_main.py        # Submission orchestrator
├── external/urm/models/
│   ├── urm/urm.py            # URM + URMInner + URMCarry
│   ├── layers.py             # CastedEmbedding, RMSNorm, RoPE
│   └── losses.py             # ACTLossHead, stablemax, TTT regularisers
├── smoke/
│   └── smoke_v11.py          # 4-contract smoke harness
├── CHANGELOG.md
└── README.md
```

## Kaggle Upload

1. Clone this repo on your machine
2. Copy `urm_checkpoint.pt` into `kaggle_staging/`
3. Upload the whole directory as a Kaggle dataset
4. In your submission notebook, mount the dataset and run:

```python
import subprocess, sys
subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "arc-agi", "python-dotenv"])

import sys
sys.path.insert(0, "/kaggle/input/arc-agi-3/kaggle_staging")
sys.path.insert(0, "/kaggle/input/arc-agi-3/external")

from kaggle_main import run_submission
run_submission()
```

## Smoke test (local)

```bash
python smoke/smoke_v11.py
```

## Key invariants

- Zero `torch.tensor/zeros/ones` without `device=` — BUG-A eliminated
- `action_emb` never in any adapter file — BUG-B eliminated
- No `torch.compile` anywhere — eager-only on T4/P100
- TTT is sidecar-only — not called in submission path
- `torch.cuda.empty_cache()` called once at end, not per-env
