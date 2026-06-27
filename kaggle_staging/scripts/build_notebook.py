#!/usr/bin/env python3
"""Build submission.ipynb for ARC-AGI-3 competition.
Usage: python scripts/build_notebook.py
Output: submission.ipynb (auto-generated, never edit manually)

ACCELERATOR = "t4" → kernel-metadata will request T4 GPU.
Change to "none" for CPU fallback.
"""
import json, pathlib, textwrap, shutil

ACCELERATOR   = "t4"          # none | t4 | p100 | rtx6000
DATASET_SLUG  = "krisskey/vericoding-urm"
COMPETITION   = "arc-prize-2026-arc-agi-3"
DATASET_PATH  = f"/kaggle/input/{DATASET_SLUG}"
COMP_PATH     = f"/kaggle/input/competitions/{COMPETITION}"

_HERE = pathlib.Path(__file__).parent
_ROOT = _HERE.parent

# ── Cell 0: Device detect + dataset copy + wasmtime offline install ──
CELL_0 = textwrap.dedent(f'''\
#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# CELL 0: Device detect + dataset copy + wasmtime offline install
# ═══════════════════════════════════════════════════════════════
import os, sys, shutil, subprocess, gc, time, json, traceback
from pathlib import Path
import torch, numpy as np

# CUDA_LAUNCH_BLOCKING=1 for accurate error line numbers (slight perf cost)
os.environ.setdefault("CUDA_LAUNCH_BLOCKING", "1")

INPUT = Path("/kaggle/input")
WK    = Path("/kaggle/working")
WK.mkdir(parents=True, exist_ok=True)

# ── P100/sm_60 guard ──
def _detect_device():
    if not torch.cuda.is_available(): return "cpu", "no CUDA"
    try:
        cap  = torch.cuda.get_device_capability(0)
        name = torch.cuda.get_device_name(0)
        if cap[0] < 7:
            print(f"[WARN] {{name}} sm_{{cap[0]*10}} < sm_70 -> CPU fallback")
            return "cpu", f"{{name}} (sm_{{cap[0]*10}} fallback)"
        torch.zeros(1, device="cuda")
        return "cuda", name
    except Exception as e:
        return "cpu", f"err:{{e}}"

DEVICE, gpu_info = _detect_device()
print(f"Device: {{DEVICE}} | {{gpu_info}}")
if DEVICE == "cuda":
    torch.backends.cudnn.benchmark = True
    torch.backends.cuda.matmul.allow_tf32 = True

# ── Find dataset ──
SRC = next((p for p in [
    INPUT / "{DATASET_SLUG}",
    INPUT / "datasets" / "krisskey" / "vericoding-urm",
] if (p / "submission_agent.py").exists()), None)
if SRC is None:
    for root, _, files in os.walk(str(INPUT)):
        if "submission_agent.py" in files and "urm_checkpoint.pt" in files:
            SRC = Path(root); break
if SRC is None: raise SystemExit("[ERR] vericoding-urm not found")
print(f"Dataset: {{SRC}}")

for fname in ["submission_agent.py", "kaggle_main.py", "wasm_bridge.py",
              "frame_processor.py", "algebra_probe.py", "graph_explorer.py",
              "wasm_bridge.wasm", "urm_checkpoint.pt", "rhae_stage1.wasm"]:
    f = SRC / fname
    if f.exists(): shutil.copy2(f, WK / fname)
if (SRC / "external").is_dir():
    shutil.copytree(SRC / "external", WK / "external", dirs_exist_ok=True)
for d in [WK/"external", WK/"external"/"urm", WK/"external"/"urm"/"models",
          WK/"external"/"urm"/"models"/"urm", WK/"agent"]:
    d.mkdir(parents=True, exist_ok=True); (d/"__init__.py").touch(exist_ok=True)
if (SRC / "agent" / "my_agent.py").exists():
    shutil.copy2(SRC / "agent" / "my_agent.py", WK / "agent" / "my_agent.py")
for p in [str(WK), str(WK/"external"), str(WK/"external"/"urm")]:
    if p not in sys.path: sys.path.insert(0, p)
os.chdir(WK)
print("Setup OK")

# ── Install wasmtime offline from dataset wheel ──
try:
    import wasmtime
    _eng = wasmtime.Engine()
    print("wasmtime OK (MoonBit WASM active)")
except Exception:
    _whl = SRC / "wasmtime-27.0.2-py3-none-manylinux1_x86_64.whl"
    if _whl.exists():
        print(f"[wasmtime] offline wheel: {{_whl.name}}")
        subprocess.run([sys.executable, "-m", "pip", "install", "-q", str(_whl), "--no-deps"],
                       capture_output=True, timeout=30)
    try:
        import wasmtime
        wasmtime.Engine()
        print("wasmtime OK (MoonBit WASM active)")
    except Exception as _e:
        print(f"[wasmtime] not available: {{_e}} - Python fallback")
''')

# ── Cell 1: Install arc-agi from competition wheels ──
CELL_1 = textwrap.dedent(f'''\
# ═══════════════════════════════════════════════════════════════
# CELL 1: Install arc-agi from competition wheels
# ═══════════════════════════════════════════════════════════════
def install_arc_agi():
    try:
        import arc_agi; print("arc-agi OK"); return
    except ImportError: pass
    _cand = [
        SRC / "arc_wheels",               # 1. dataset offline wheels (v16.12+)
        Path("{COMP_PATH}") / "arc_agi_3_wheels",
    ]
    _wh = next((p for p in _cand if p.is_dir()), None)
    if _wh is not None:
        print(f"[ARC] wheels: {{_wh}}")
        r = subprocess.run(
            [sys.executable, "-m", "pip", "install", "-q",
             "--no-index", f"--find-links={{_wh}}", "arc-agi", "python-dotenv"],
            capture_output=True, text=True, timeout=30
        )
        if r.returncode == 0:
            import arc_agi; print("arc-agi installed"); return
        print(f"[ARC] wheel err: {{r.stderr[:200]}}")
    print("[ARC] no wheels - PyPI timeout=5s")
    try:
        r = subprocess.run(
            [sys.executable, "-m", "pip", "install", "-q",
             "--default-timeout=5", "arc-agi", "python-dotenv"],
            capture_output=True, text=True, timeout=15
        )
        if r.returncode == 0:
            import arc_agi; print("arc-agi installed (PyPI)"); return
    except: pass
    raise SystemExit("[ERR] arc-agi install failed - add Competition dataset to Inputs")
install_arc_agi()
''')

# ── Cell 2: Import agent + URM backbone ──
CELL_2 = textwrap.dedent('''\
# ═══════════════════════════════════════════════════════════════
# CELL 2: Import agent + URM backbone
# ═══════════════════════════════════════════════════════════════
import submission_agent
from submission_agent import VERICODINGAgent

CHKPT   = Path("/kaggle/working/urm_checkpoint.pt")
DEVICE  = "cuda" if torch.cuda.is_available() else "cpu"

def sga(obj, names, default=None):
    return next((getattr(obj, n) for n in names if hasattr(obj, n)), default)

agent = VERICODINGAgent("__init__")
wm    = None
# Load URM backbone only on GPU (CPU inference is too slow for 13.7M params)
if DEVICE == "cuda" and CHKPT.exists():
    wm = sga(agent, ["world_model", "worldmodel"])
    if wm is not None:
        load_fn = sga(wm, ["load_backbone", "loadbackbone"])
        if load_fn: load_fn(str(CHKPT), device=DEVICE)
        wm.eval()
        # FP16: 2× faster forward on T4 Tensor Cores
        {True: lambda: wm.to_fp16(), False: lambda: None}[hasattr(wm, "to_fp16")]()
        print("URM backbone loaded (GPU)")
    else:
        print("URM backbone not available")
else:
    print(f"URM skipped (device={DEVICE}, chkpt={CHKPT.exists()}) — CPU exploration-only mode")

try:
    from wasm_bridge import _HAS_WASM
    print(f"WASM: {'ACTIVE' if _HAS_WASM else 'Python fallback'}")
except: pass

print(f"Agent: {type(agent).__name__}, WM: {type(wm).__name__ if wm else None}, Device: {DEVICE}")
''')

# ── Cell 3: GPU diagnostics ──
CELL_3 = textwrap.dedent('''\
# ═══════════════════════════════════════════════════════════════
# CELL 3: GPU diagnostics
# ═══════════════════════════════════════════════════════════════
if torch.cuda.is_available():
    name = torch.cuda.get_device_name(0)
    vram = torch.cuda.get_device_properties(0).total_memory / 1e9
    cap  = torch.cuda.get_device_capability(0)
    print(f"[GPU] {name} | VRAM: {vram:.1f} GB | sm_{cap[0]}{cap[1]}")
else:
    print("[GPU] CPU only")
''')

# ── Cell 4: Phase A - Algebra Probe Pipeline + Counter Mask + Optional TTT ──
CELL_4 = textwrap.dedent('''\
# ═══════════════════════════════════════════════════════════════
# CELL 4: Phase A - Algebra Probe Pipeline + Counter Mask
# ═══════════════════════════════════════════════════════════════
os.environ.setdefault("OPERATION_MODE", "offline")
os.environ.setdefault("ENVIRONMENTS_DIR", str(SRC / "environment_files"))
from arc_agi import Arcade
from arcengine import GameState as _GS, enums as _GE
from wasm_bridge import functional_ttt_train, _extract_head_params, _extract_buffers, pure_batch_ttt_loss
import algebra_probe as _ap
import graph_explorer as _ge
from frame_processor import FrameProcessor

arc       = Arcade()
env_infos = list(arc.available_environments)
print(f"Games: {len(env_infos)}")

MAX_STEPS = 200
TTT_STEPS = 30; TTT_LR = 8e-5; TTT_LAMBDA = 0.1
trajectories, game_scores = {}, {}
bfs_results = {}  # gid → (solved, n_actions, budget_used)
_best_score = 0.0
t0 = time.time()

def extract_grid(frame):
    if isinstance(frame, np.ndarray) and frame.ndim == 2: return frame.astype(np.int32)
    try:
        fr = getattr(frame, "frame", None)
        if fr and len(fr) > 0: return np.asarray(fr[0], dtype=np.int32)
    except: pass
    return None

# Pre-allocate FrameProcessor for counter mask detection
_fp_counter = FrameProcessor()

for idx, env_info in enumerate(env_infos):
    gid = str(getattr(env_info, "game_id", getattr(env_info, "id", idx)))
    env = None; sbuf, abuf, rbuf = [], [], []; score = 0.0
    try:
        env = arc.make(gid)
        agent.set_game_tags(getattr(getattr(env, "info", None), "tags", []))
        agent.set_step_modulus(3)  # enable step-modulus hashing
        frame = env.reset()
        if frame is None: continue
        agent.on_game_start()

        # ── v22: Algebra Probe Pipeline (replaces BFS entirely) ──
        hasher = agent.get_hasher()
        import algebra_probe as _ap
        _ap.set_hasher(hasher)
        _act_list = list(getattr(env, "action_space", []))
        if not _act_list:
            _act_list = [_GE.GameAction.ACTION1, _GE.GameAction.ACTION2,
                         _GE.GameAction.ACTION3, _GE.GameAction.ACTION4,
                         _GE.GameAction.ACTION5, _GE.GameAction.ACTION6,
                         _GE.GameAction.ACTION7]
        env.reset()
        agent.on_game_start()
        _algebra_tags = _ap.probe_action_algebra(env, max_probe_steps=2500)
        _strategy = _ap.choose_strategy(_algebra_tags, len(_act_list))
        print(f"  [{idx+1}] {gid}: {_strategy['reason']} ({_strategy['name']}, "
              f"indices={_strategy['action_indices']}, "
              f"max_steps={_strategy['max_steps']})")
        # Execute strategy
        _solved = False
        _solution = None
        if _strategy["name"] in ("blind_probe", "repeated_action", "periodic_probe"):
            for _a_idx in _strategy["action_indices"]:
                env.reset()
                agent.on_game_start()
                _ga = _act_list[_a_idx]
                for _k in range(_strategy["max_steps"]):
                    _gd = {"x": 32, "y": 32} if _ga.is_complex() else None
                    _nf = env.step(_ga, data=_gd)
                    if _nf is None:
                        break
                    if getattr(_nf, "state", None) is _GS.WIN:
                        _solved = True
                        _solution = [_a_idx] * (_k + 1)
                        print(f"  [{idx+1}] {gid}: {_ga.name}*{_k+1} -> WIN")
                        break
                if _solved:
                    break
        elif _strategy["name"] == "ida_star":
            # GraphExplorer: frontier-based BFS with priority-tier candidates
            _fp = FrameProcessor()
            _hfn = agent.get_hasher()
            _rbae = getattr(agent, '_rhae', None)
            _tt_lk = (lambda lo, hi: _rbae.exports[_rbae._store]["rhae_tt_lookup"](_rbae._store, lo, hi)
                      if _rbae else lambda lo, hi: -1)
            _tt_st = (lambda lo, hi, a, s: _rbae.exports[_rbae._store]["rhae_tt_store"](_rbae._store, lo, hi, a, s)
                      if _rbae else lambda lo, hi, a, s: None)
            _explorer = _ge.GraphExplorer(env, _fp, _hfn, _act_list, _tt_lk, _tt_st)
            _solved = _explorer.explore(max_steps=2000)
            if _solved and _explorer.solution:
                _solution = _explorer.solution
                print(f"  [{idx+1}] {gid}: GraphExplorer solved in {len(_solution)} actions")
        
        if _solved and _solution:
            _hba = getattr(env_info, "human_baseline_actions", len(_solution))
            _aa = len(_solution)
            score = min(1.15, (_hba / max(1, _aa)) ** 2)
            game_scores[gid] = score
            bfs_results[gid] = {"solved": True, "n_actions": len(_solution), "solver": _strategy['name']}
            _best_score = max(_best_score, score)
            continue  # solved, skip agent loop
        # Fallback: agent loop (existing code below)

            # Standard agent loop (paper)
            env.reset()
            agent.on_game_start()
            for _ in range(MAX_STEPS):
                act = agent.choose_action([frame], None)
                _act_data = getattr(agent, '_last_action_data', None)
                if wm is not None:
                    grid = extract_grid(frame)
                    if grid is not None:
                        _aid = int(act.value[0]) if hasattr(act, 'value') and isinstance(act.value, tuple) else int(act)
                        tok = wm.encode_state(grid, _aid)
                        sbuf.append(tok.squeeze(0).cpu().numpy().astype(np.int32))
                        abuf.append(_aid); rbuf.append(0.0)
                nf = env.step(act, data=_act_data)
                if nf is None: break
                r_ = float(getattr(nf, "levels_completed", 0) - getattr(frame, "levels_completed", 0))
                score += r_
                if rbuf: rbuf[-1] = r_
                frame = nf
                if getattr(frame, "state", None) in (_GS.WIN, _GS.GAME_OVER): break
            game_scores[gid] = score
            bfs_results[gid] = {"solved": False, "n_actions": 0, "budget_used": 2000}

        # ── Per-game TTT (GPU only) ──
        if len(sbuf) >= 4 and wm is not None and hasattr(wm, "to_fp16"):
            states  = torch.from_numpy(np.stack(sbuf[:-1])).long().to(DEVICE)
            actions = torch.from_numpy(np.array(abuf[:-1])).long().to(DEVICE)
            next_states = torch.from_numpy(np.stack(sbuf[1:])).long().to(DEVICE)
            rewards = torch.from_numpy(np.array(rbuf[:-1])).float().to(DEVICE)
            _snap = {k: v.data.clone() for k, v in wm.named_parameters()
                     if any(k.startswith(h) for h in ["action_head", "value_head", "action_emb"])}
            params  = {k: v.to(DEVICE) for k, v in _extract_head_params(wm).items()}
            buffers = {k: v.to(DEVICE) for k, v in _extract_buffers(wm).items()}
            new_p = functional_ttt_train(params, buffers, wm, states, actions, next_states, rewards,
                                          steps=TTT_STEPS, lr=TTT_LR, lambda_reg=TTT_LAMBDA)
            if score > 0.0:
                for k, v in wm.named_parameters():
                    if k in new_p: v.data.copy_(new_p[k])
                print(f"  [TTT] {gid} score={score:.4f} params applied")
            else:
                for k, v in wm.named_parameters():
                    if k in _snap: v.data.copy_(_snap[k])
                print(f"  [TTT] {gid} score=0.0 snapshot restored")
            _best_score = max(_best_score, score)
    except Exception as e:
        game_scores[gid] = 0.0
        print(f"  [{idx+1}] {gid} ERR: {str(e)[:100]}")
        traceback.print_exc()
    finally:
        if env:
            try: env.close()
            except: pass
        gc.collect()

n_traj = len(trajectories)
mean_s = sum(game_scores.values()) / max(1, len(game_scores))
n_solved = sum(1 for v in bfs_results.values() if v.get("solved"))
print(f"Phase A: {n_traj}/{len(env_infos)} traj, solved {n_solved}/{len(env_infos)}, mean_score={mean_s:.4f}, t={time.time()-t0:.0f}s")
''')

# ── Cell 5: Phase B - Per-game TTT ──
CELL_5 = textwrap.dedent('''\
# ═══════════════════════════════════════════════════════════════
# CELL 5: Phase B - Per-game TTT (50 steps, lr=1e-4, head-only)
# ═══════════════════════════════════════════════════════════════
from wasm_bridge import functional_ttt_train, _extract_head_params, _extract_buffers
import torch.nn.functional as F
from torch.func import functional_call

if wm is None or not trajectories:
    print(f"[SKIP] wm={wm is not None} traj={len(trajectories)}")
    ttt_results = {}; n_improved = 0
else:
    TTT_STEPS=50; TTT_LR=1e-4; TTT_LAMBDA=0.1
    wm.train()
    params  = {k:v.to(DEVICE).requires_grad_(True) for k,v in _extract_head_params(wm).items()}
    buffers = {k:v.to(DEVICE) for k,v in _extract_buffers(wm).items()}
    ttt_results = {}; t_ttt = time.time()
    _cuda_ok = True  # track CUDA health
    for gid, traj in trajectories.items():
        if not _cuda_ok:
            print(f"  {gid}: SKIP (CUDA corrupted)")
            continue
        try:
            states  = torch.from_numpy(traj["states"]).long().to(DEVICE)
            actions = torch.from_numpy(traj["actions"]).long().to(DEVICE)
            rewards = torch.from_numpy(traj["rewards"]).float().to(DEVICE)
            if len(states) < 4: continue
            # Clamp actions to valid range BEFORE any CUDA loss computation
            _log_n = wm.action_head.out_features if hasattr(wm, 'action_head') else 7
            actions = actions.clamp(0, _log_n - 1)
            next_states = torch.cat([states[1:], states[-1:]], dim=0)
            new_p = functional_ttt_train(params, buffers, wm, states, actions, next_states, rewards,
                                          steps=TTT_STEPS, lr=TTT_LR, lambda_reg=TTT_LAMBDA)
            with torch.no_grad():
                _sa = actions[:4].clamp(0, _log_n - 1)
                b4  = F.cross_entropy(functional_call(wm, (params, buffers), (states[:4],))["action_logits"][:, :_log_n], _sa).item()
                aft = F.cross_entropy(functional_call(wm, (new_p,  buffers), (states[:4],))["action_logits"][:, :_log_n], _sa).item()
            improved = aft < b4
            if improved: params = new_p
            ttt_results[gid] = {"before":b4,"after":aft,"improved":improved}
            print(f"  {gid}: {b4:.4f}->{aft:.4f} {'Y' if improved else 'N'}")
        except RuntimeError as e:
            if "CUDA" in str(e) or "device-side assert" in str(e):
                _cuda_ok = False
                print(f"  {gid} TTT CUDA ERR: {str(e)[:80]} — skipping remaining")
            else:
                print(f"  {gid} TTT ERR: {str(e)[:80]}")
        except Exception as e:
            print(f"  {gid} TTT ERR: {str(e)[:80]}")
    n_improved = sum(1 for v in ttt_results.values() if v.get("improved"))
    print(f"Phase B: {n_improved}/{len(ttt_results)} improved, t={time.time()-t_ttt:.0f}s")
    wm.eval()
''')

# ── Cell 6: Save adapter + metrics ──
CELL_6 = textwrap.dedent('''\
# ═══════════════════════════════════════════════════════════════
# CELL 6: Save adapter + metrics
# ═══════════════════════════════════════════════════════════════
ADAPTER_OUT = Path("/kaggle/working/urm_ttt_adapter.pt")
METRICS_OUT = Path("/kaggle/working/training_metrics.json")

if wm is not None:
    adapter = _extract_head_params(wm)
    adapter = {k: v for k, v in adapter.items() if "action_emb" not in k}
    torch.save(adapter, ADAPTER_OUT)
    print(f"Adapter: {ADAPTER_OUT} ({ADAPTER_OUT.stat().st_size/1024:.1f}KB)")
else:
    torch.save({}, ADAPTER_OUT); print("Empty adapter saved")

metrics = {
    "device": DEVICE, "gpu": gpu_info,
    "n_games": len(env_infos),
    "n_trajectories": len(trajectories),
    "n_ttt": len(ttt_results) if "ttt_results" in dir() else 0,
    "n_improved": n_improved if "n_improved" in dir() else 0,
    "pre_ttt_mean": float(np.mean(list(game_scores.values()))) if game_scores else 0.0,
    "ts": time.strftime("%Y-%m-%dT%H:%M:%S"),
}
METRICS_OUT.write_text(json.dumps(metrics, indent=2))
print(f"Metrics: {METRICS_OUT}")
print(f"=== TRAINING DONE ===")
print(f"Pre-TTT mean: {metrics['pre_ttt_mean']:.4f}")
print(f"Improved: {metrics['n_improved']}/{metrics['n_ttt']}")

if DEVICE == "cuda": torch.cuda.empty_cache()
gc.collect()
''')

# ── Build notebook JSON ──
def make_cell(source: str) -> dict:
    return {"cell_type": "code", "execution_count": None, "metadata": {}, "outputs": [], "source": source}

nb = {
    "nbformat": 4,
    "nbformat_minor": 5,
    "metadata": {
        "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"},
        "language_info": {"name": "python", "version": "3.10.0"},
    },
    "cells": [make_cell(c) for c in [CELL_0, CELL_1, CELL_2, CELL_3, CELL_4, CELL_5, CELL_6]],
}

_OUT = _ROOT / "submission.ipynb"
_OUT.write_text(json.dumps(nb, indent=2))
print(f"[build_notebook] Written: {_OUT} ({_OUT.stat().st_size} bytes)")
print(f"[build_notebook] ACCELERATOR={ACCELERATOR} | Dataset={DATASET_SLUG}")

# ── Also update kernel-metadata.json ──
KM = _ROOT / "kernel-metadata.json"
km = {
    "id": "krisskey/arc3-urm-ttt-v22-w-algebra-probe-pipeline",
    "title": "ARC3 URM TTT v22 w/Algebra Probe Pipeline",
    "code_file": "submission.ipynb",
    "language": "python",
    "kernel_type": "notebook",
    "is_private": True,
    "enable_gpu": False,
    "enable_tpu": False,
    "enable_internet": False,
    "dataset_sources": [DATASET_SLUG],
    "competition_sources": [],
    "kernel_sources": [],
}
KM.write_text(json.dumps(km, indent=2))
print(f"[build_notebook] Updated: {KM}")

# ── Verify agent/my_agent.py exists ──
if not (_ROOT / "agent" / "my_agent.py").exists():
    print(f"[build_notebook] WARN: agent/my_agent.py not found")
