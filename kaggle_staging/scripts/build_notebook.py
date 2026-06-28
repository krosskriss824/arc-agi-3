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
              "frame_processor.py", "game_profiler.py", "dense_explorer.py",
              "graph_explorer.py", "step_adapter.py",
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

# Discover environment files (Kaggle auto-extracts .zip in datasets)
_env_candidates = [
    SRC / "environment_files",                     # Kaggle auto-extracted
    WK / "environment_files",                      # manually extracted (legacy)
]
for _ecd in _env_candidates:
    if _ecd.is_dir() and len(list(_ecd.rglob("metadata.json"))) > 0:
        os.environ.setdefault("ENVIRONMENTS_DIR", str(_ecd))
        _n_meta = len(list(_ecd.rglob("metadata.json")))
        print(f"ENV: {{_ecd.name}} ({{_n_meta}} games)")
        break
else:
    # Last resort: extract from dataset zip
    _env_zip = SRC / "environment_files.zip"
    if _env_zip.exists():
        import zipfile
        with zipfile.ZipFile(_env_zip) as zf:
            zf.extractall(WK / "environment_files")
        _ed = WK / "environment_files"
        if _ed.is_dir():
            os.environ.setdefault("ENVIRONMENTS_DIR", str(_ed))
            _n_meta = len(list(_ed.rglob("metadata.json")))
            print(f"Extracted: {{_n_meta}} games to WK/environment_files")
    else:
        os.environ.setdefault("ENVIRONMENTS_DIR", str(SRC / "environment_files"))
        print(f"ENV_DIR: {{os.environ['ENVIRONMENTS_DIR']}}")

# Strategy cache type (persists across all games)
import game_profiler as _gp
_strategy_cache = _gp.StrategyCache()

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
    # Try competition input first
    _comp = Path("/kaggle/input/arc-agi-3") / "arc_agi_3_wheels"
    if _comp.is_dir():
        print(f"[ARC] wheels: {{_comp}}")
        r = subprocess.run(
            [sys.executable, "-m", "pip", "install", "-q",
             "--no-index", f"--find-links={{_comp}}",
             "arc-agi", "arcengine", "python-dotenv"],
            capture_output=True, text=True, timeout=30
        )
        if r.returncode == 0:
            import arc_agi; print("arc-agi installed (competition)"); return
        print(f"[ARC] comp wheel err: {{r.stderr[:100]}}")
    # Try dataset wheels
    _whls = sorted(SRC.glob("*.whl"))
    if _whls:
        for _w in _whls:
            r = subprocess.run(
                [sys.executable, "-m", "pip", "install", "-q", "--no-deps", str(_w)],
                capture_output=True, text=True, timeout=60
            )
            if r.returncode != 0:
                print(f"[ARC] {{_w.name}} err: {{r.stderr[:100]}}")
        try:
            import arc_agi; print("arc-agi installed (offline)"); return
        except ImportError:
            print("[ARC] install OK but import fails")
    # PyPI fallback
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

# ── Cell 4: Phase A - Game Profiler + DenseExplorer + StrategyCache ──
CELL_4 = textwrap.dedent('''\
# ═══════════════════════════════════════════════════════════════
# CELL 4: Phase A - Game Profiler + DenseExplorer + StrategyCache
# ═══════════════════════════════════════════════════════════════
os.environ.setdefault("OPERATION_MODE", "offline")
os.environ.setdefault("ENVIRONMENTS_DIR", str(SRC / "environment_files"))
from arc_agi import Arcade, EnvironmentInfo
from arcengine import GameState as _GS, enums as _GE
from wasm_bridge import functional_ttt_train, _extract_head_params, _extract_buffers, pure_batch_ttt_loss
from step_adapter import safe_step
import dense_explorer as _de
from collections import defaultdict

# Discover games — try competition input first, then dataset environment_files
_COMP_ENV = Path("/kaggle/input/arc-agi-3/environment_files")
_DATASET_ENV = Path(os.environ.get("ENVIRONMENTS_DIR", str(SRC / "environment_files")))
_ENV_DIR = _COMP_ENV if _COMP_ENV.is_dir() else _DATASET_ENV
os.environ.setdefault("ENVIRONMENTS_DIR", str(_ENV_DIR))
env_infos = []
for _mf in sorted(_ENV_DIR.rglob("metadata.json")):
    _jd = json.loads(_mf.read_text(encoding="utf-8"))
    _jd["local_dir"] = str(_mf.parent)
    env_infos.append(EnvironmentInfo.model_validate(_jd))
print(f"Games: {len(env_infos)} [dir: {{_ENV_DIR.name if _ENV_DIR == _COMP_ENV else 'dataset'}}]")

# Arcade for game loading (make/g)
arc = Arcade()

MAX_STEPS = 5000
TTT_STEPS = 30; TTT_LR = 8e-5; TTT_LAMBDA = 0.1

def extract_grid(frame):
    if isinstance(frame, np.ndarray) and frame.ndim == 2: return frame.astype(np.int32)
    try:
        fr = getattr(frame, "frame", None)
        if fr and len(fr) > 0: return np.asarray(fr[0], dtype=np.int32)
    except: pass
    return None

def _frame_win(nf):
    s = getattr(nf, "state", None) if nf is not None else None
    return s is not None and ("WIN" in str(s) or (hasattr(s, 'value') and str(s.value) == "WIN"))

game_scores, bfs_results, trajectories = {}, {}, {}
_best_score = 0.0
t0 = time.time()

for idx, env_info in enumerate(env_infos):
    gid = str(getattr(env_info, "game_id", getattr(env_info, "id", idx)))
    env = None; sbuf, abuf, rbuf = [], [], []; score = 0.0; _frames = [None]; nf = None
    try:
        env = arc.make(gid)
        agent.set_game_tags(getattr(getattr(env, "info", None), "tags", []))
        agent.set_step_modulus(3)
        _act_list = list(getattr(env, "action_space", []))
        if not _act_list:
            _act_list = [_GE.GameAction.ACTION1, _GE.GameAction.ACTION2,
                         _GE.GameAction.ACTION3, _GE.GameAction.ACTION4,
                         _GE.GameAction.ACTION5, _GE.GameAction.ACTION6,
                         _GE.GameAction.ACTION7]
        _frames = [env.reset()]
        if _frames[0] is None: continue
        agent.on_game_start()
        
        # ── DenseExplorer pre-scan: find live clicks (200 steps budget) ──
        _de_inst = _de.DenseExplorer(env, _act_list)
        if _de_inst._click_idx is not None:
            _de_inst.explore(max_steps=200)
            _hint_xy = _de_inst.live_clicks[0][:2] if _de_inst.live_clicks else None
            if _de_inst.solution:
                # Solution found: replay and collect score
                _frames = [env.reset()]
                for _aidx in _de_inst.solution:
                    _a = _act_list[_aidx]
                    _cx, _cy = _hint_xy if _hint_xy else (32, 32)
                    nf = safe_step(env, _a, x=_cx, y=_cy)
                    if nf is None: break
                    score += float(getattr(nf, "levels_completed", 0) - getattr(_frames[-1], "levels_completed", 0))
                    _frames.append(nf)
                    if _frame_win(nf) or getattr(nf, "state", None) is _GS.GAME_OVER: break
                if _frame_win(nf):
                    if sbuf: trajectories[gid] = {"states": np.stack(sbuf), "actions": np.array(abuf), "rewards": np.array(rbuf)}
                    game_scores[gid] = score
                    _nf_state = getattr(nf, "state", None)
                    bfs_results[gid] = {"solved": _nf_state is not None and "WIN" in str(_nf_state), "n_actions": 0, "budget_used": len(_frames) - 1}
                    print(f"  [{idx+1}] {gid}: score={score:.4f}, steps={len(_frames)-1} [DenseExplorer]")
                    _best_score = max(_best_score, score)
                    continue
        else:
            _hint_xy = None
        
        # Reset env after DenseExplorer pre-scan (env may be desynced)
        _frames = [env.reset()]

        # ── Force _rhae._exp to never be None (crash guard for CPU/WASM fallback) ──
        _rhae_inst = __import__("submission_agent")._rhae
        if _rhae_inst._exp is None:
            _rhae_inst._exp = defaultdict(lambda: lambda *a, **kw: None)

        for _ in range(MAX_STEPS):
            act = agent.choose_action(_frames, None)
            _act_data = getattr(agent, '_last_action_data', None)
            _pframe = _frames[-1]
            if wm is not None:
                grid = extract_grid(_pframe)
                if grid is not None:
                    _aid = act.value[0] if isinstance(getattr(act, 'value', None), tuple) else getattr(act, 'value', 0)
                    tok = wm.encode_state(grid, _aid)
                    sbuf.append(tok.squeeze(0).cpu().numpy().astype(np.int32))
                    abuf.append(_aid); rbuf.append(0.0)
            if _act_data:
                nf = safe_step(env, act, x=_act_data.get("x"), y=_act_data.get("y"))
            else:
                nf = safe_step(env, act)
            if nf is None: break
            r_ = float(getattr(nf, "levels_completed", 0) - getattr(_pframe, "levels_completed", 0))
            score += r_
            if rbuf: rbuf[-1] = r_
            _frames.append(nf)
            if getattr(nf, "state", None) is _GS.GAME_OVER: break
            if _frame_win(nf): break
        if sbuf: trajectories[gid] = {"states": np.stack(sbuf), "actions": np.array(abuf), "rewards": np.array(rbuf)}
        game_scores[gid] = score
        _nf_state = getattr(nf, "state", None)
        bfs_results[gid] = {"solved": _nf_state is not None and "WIN" in str(_nf_state), "n_actions": 0, "budget_used": max(0, len(_frames) - 1) if _frames else 0}
        print(f"  [{idx+1}] {gid}: score={score:.4f}, steps={max(0, len(_frames) - 1) if _frames else 0}")

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
    print(f"  [{idx+1}] {gid}: final score={score:.4f}, steps={max(0, len(_frames) - 1)}")

n_traj = len(game_scores)  # removed trajectories ref
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
    "enable_gpu": True,
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
