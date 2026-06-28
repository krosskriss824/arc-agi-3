#!/usr/bin/env python3
"""Build submission.ipynb — MINIMAL 4-cell version (v70).

Usage: python scripts/build_notebook.py  &&  kaggle kernels push -p kaggle_staging/
"""
import json, pathlib, textwrap, shutil

ACCELERATOR  = "t4"          # none | t4 | p100 | rtx6000
DATASET_SLUG = "krisskey/vericoding-urm"
COMPETITION  = "arc-prize-2026-arc-agi-3"

_HERE = pathlib.Path(__file__).parent
_ROOT = _HERE.parent

# ── Cell 0: Setup + copy files + install arc-agi ──
CELL_0 = textwrap.dedent("""\
import os, sys, shutil, subprocess, gc, json, time, traceback
from pathlib import Path
import numpy as np
import torch
import torch

WK  = Path("/kaggle/working"); WK.mkdir(parents=True, exist_ok=True)
INP = Path("/kaggle/input")

# Find dataset
SRC = INP / "datasets" / "krisskey" / "vericoding-urm"
if not SRC.exists():
    for r,_,fs in os.walk(str(INP)):
        if "submission_agent.py" in fs: SRC = Path(r); break
else:
    SRC = SRC

# Copy files
for fn in ["submission_agent.py","wasm_bridge.py","step_adapter.py",
           "frame_processor.py","game_profiler.py","dense_explorer.py","graph_explorer.py",
           "wasm_bridge.wasm","urm_checkpoint.pt","rhae_stage1.wasm"]:
    f = SRC / fn
    if f.exists(): shutil.copy2(f, WK / fn)
if (SRC/"external").is_dir():
    shutil.copytree(SRC/"external", WK/"external", dirs_exist_ok=True)
for d in [WK/"external", WK/"external"/"urm"]:
    d.mkdir(parents=True, exist_ok=True); (d/"__init__.py").touch()
for p in [str(WK), str(WK/"external")]:
    if p not in sys.path: sys.path.insert(0, p)
os.chdir(WK)

# Find environment files
for cand in [SRC/"environment_files", WK/"environment_files"]:
    if cand.is_dir() and list(cand.rglob("metadata.json")):
        os.environ["ENVIRONMENTS_DIR"] = str(cand); break
else:
    os.environ["ENVIRONMENTS_DIR"] = str(SRC/"environment_files")
print(f"OK: SRC={SRC.name}, ENV={os.environ['ENVIRONMENTS_DIR']}")

# Install arc-agi from dataset wheels
_whls = sorted(SRC.glob("*.whl"))
if _whls:
    for w in _whls:
        subprocess.run([sys.executable,"-m","pip","install","-q","--no-deps",str(w)],
                       capture_output=True, timeout=30)
try:
    import arc_agi; print("arc-agi OK")
except Exception as e:
    print(f"arc-agi FAIL: {e}")
""")

# ── Cell 1: Agent init + URM load (CPU) ──
CELL_1 = textwrap.dedent("""\
import submission_agent as sa
from submission_agent import VERICODINGAgent
from step_adapter import safe_step
from wasm_bridge import functional_ttt_train, _extract_head_params, _extract_buffers
from collections import defaultdict

agent = VERICODINGAgent("__init__")
from wasm_bridge import _HAS_WASM
print(f"WASM: {'ACTIVE' if _HAS_WASM else 'Python fallback'}")

# URM backbone (CPU)
CHKPT = Path("/kaggle/working/urm_checkpoint.pt")
wm = None
if CHKPT.exists():
    wm = getattr(agent, "world_model", getattr(agent, "worldmodel", None))
    if wm is not None:
        load_fn = getattr(wm, "load_backbone", getattr(wm, "loadbackbone", None))
        if load_fn:
            load_fn(str(CHKPT), device="cpu")
            wm.eval()
            print("URM backbone loaded (CPU)")
        else:
            wm = None
# Monkey-patch _carry_to_device for DummyCarry (dataset has old version)
_sa_orig = sa._carry_to_device
def _safe_carry(carry, device):
    if not hasattr(carry, 'steps'): return carry
    return _sa_orig(carry, device)
sa._carry_to_device = _safe_carry
print(f"[patch] _carry_to_device OK (orig={hasattr(_sa_orig,'__code__')})")

print(f"Agent: {type(agent).__name__}, WM: {type(wm).__name__ if wm else None}")
""")

# ── Cell 2: Game loop + agent + _rhae guard + TTT ──
CELL_2 = textwrap.dedent("""\
from arc_agi import Arcade, EnvironmentInfo, OperationMode
from arcengine import GameState as _GS, enums as _GE
import submission_agent as _sa_mod

MAX_STEPS = 5000

def _frame_win(nf):
    s = getattr(nf, "state", None) if nf is not None else None
    return s is not None and ("WIN" in str(s) or (hasattr(s,'value') and str(s.value)=="WIN"))

game_scores, trajectories = {}, {}
t0 = time.time()

# Discover games
_ENV_DIR = Path(os.environ.get("ENVIRONMENTS_DIR",""))
env_infos = []
for mf in sorted(_ENV_DIR.rglob("metadata.json")):
    jd = json.loads(mf.read_text())
    jd["local_dir"] = str(mf.parent)
    env_infos.append(EnvironmentInfo.model_validate(jd))
print(f"Games: {len(env_infos)}")

arc = Arcade(operation_mode=OperationMode.OFFLINE)

for idx, ei in enumerate(env_infos):
    gid = str(getattr(ei, "game_id", getattr(ei, "id", idx)))
    env = None; score = 0.0; _frames = [None]; nf = None; sbuf, abuf = [], []
    try:
        env = arc.make(gid)
        agent.set_game_tags(getattr(getattr(env,"info",None),"tags",[]))
        agent.set_step_modulus(3)
        act_list = list(getattr(env,"action_space",[]))
        if not act_list:
            act_list = [_GE.GameAction.ACTION1,_GE.GameAction.ACTION2,_GE.GameAction.ACTION3,
                        _GE.GameAction.ACTION4,_GE.GameAction.ACTION5,_GE.GameAction.ACTION6,_GE.GameAction.ACTION7]
        _frames = [env.reset()]
        if _frames[0] is None: continue
        agent.on_game_start()

        # _rhae guard: never None
        _rhae = __import__("submission_agent")._rhae
        if _rhae._exp is None:
            _rhae._exp = defaultdict(lambda: lambda *a,**kw: None)

        for _ in range(MAX_STEPS):
            act = agent.choose_action(_frames, None)
            ad = getattr(agent, "_last_action_data", None)
            pframe = _frames[-1]
            if wm is not None and pframe is not None:
                grid = getattr(pframe,"frame",None)
                if grid is not None and len(grid)>0:
                    g = np.asarray(grid[0], dtype=np.int32)
                    aid = act.value[0] if isinstance(getattr(act,"value",None),tuple) else getattr(act,"value",0)
                    tok = wm.encode_state(g, aid)
                    sbuf.append(tok.squeeze(0).cpu().numpy().astype(np.int32))
                    abuf.append(aid)
            if ad:
                nf = safe_step(env, act, x=ad.get("x"), y=ad.get("y"))
            else:
                nf = safe_step(env, act)
            if nf is None: break
            score += float(getattr(nf,"levels_completed",0)-getattr(pframe,"levels_completed",0))
            _frames.append(nf)
            if getattr(nf,"state",None) is _GS.GAME_OVER: break
            if _frame_win(nf): break

        game_scores[gid] = score
        print(f"  [{idx+1}] {gid}: score={score:.4f}, steps={max(0,len(_frames)-1)}")

        # Per-game TTT (CPU/GPU)
        if len(sbuf)>=4 and wm is not None:
            try:
                tdev = "cuda" if torch.cuda.is_available() else "cpu"
                s = torch.from_numpy(np.stack(sbuf)).long().to(tdev)
                a = torch.from_numpy(np.array(abuf)).long().to(tdev)
                ns = torch.cat([s[1:],s[-1:]],dim=0)
                rw = torch.zeros(len(s), device=tdev)
                params = {k:v.to(tdev).requires_grad_(True) for k,v in _extract_head_params(wm).items()}
                bufs = {k:v.to(tdev) for k,v in _extract_buffers(wm).items()}
                new_p = functional_ttt_train(params, bufs, wm, s, a, ns, rw, steps=30, lr=8e-5, lambda_reg=0.1)
                if score>0.0:
                    for k,v in wm.named_parameters():
                        if k in new_p: v.data.copy_(new_p[k].cpu())
                    print(f"    [TTT] params applied (tdev={tdev})")
                if tdev == "cuda":
                    torch.cuda.empty_cache()
            except Exception as _tte:
                print(f"    [TTT] skipped: {_tte}")

    except Exception as e:
        game_scores[gid] = 0.0
        print(f"  [{idx+1}] {gid} ERR: {str(e)[:100]}")
    finally:
        if env:
            try: env.close()
            except: pass
        gc.collect()

mean_s = float(np.mean(list(game_scores.values()))) if game_scores else 0.0
n_traj = len(game_scores)
print(f"Phase A: {n_traj}/{len(env_infos)} traj, mean_score={mean_s:.4f}, t={time.time()-t0:.0f}s")
""")

# ── Cell 3: Save ──
CELL_3 = textwrap.dedent("""\
ADAPTER = Path("/kaggle/working/urm_ttt_adapter.pt")
METRICS = Path("/kaggle/working/training_metrics.json")

if wm is not None:
    ad = _extract_head_params(wm)
    ad = {k:v for k,v in ad.items() if "action_emb" not in k}
    torch.save(ad, ADAPTER)
else:
    torch.save({}, ADAPTER)

metrics = {"n_games":len(env_infos),"n_trajectories":len(trajectories),
           "pre_ttt_mean":float(np.mean(list(game_scores.values()))) if game_scores else 0.0,
           "ts":time.strftime("%Y-%m-%dT%H:%M:%S")}
METRICS.write_text(json.dumps(metrics, indent=2))
print(f"=== DONE === mean={metrics['pre_ttt_mean']:.4f}")
""")

# ── Build notebook ──
def cell(src): return {"cell_type":"code","execution_count":None,"metadata":{},"outputs":[],"source":src}

accel_map = {"none":"none","t4":"nvidiaTeslaT4","p100":"nvidiaTeslaP100","rtx6000":"nvidiaRtx6000"}
nb = {
    "nbformat":4, "nbformat_minor":5,
    "metadata":{
        "kernelspec":{"display_name":"Python 3","language":"python","name":"python3"},
        "language_info":{"name":"python","version":"3.10.0"},
        "kaggle":{"accelerator":accel_map[ACCELERATOR],"isInternetEnabled":False,"isGpuEnabled":ACCELERATOR!="none","language":"python","sourceType":"notebook"},
    },
    "cells":[cell(c) for c in [CELL_0, CELL_1, CELL_2, CELL_3]],
}

_OUT = _ROOT / "submission.ipynb"
_OUT.write_text(json.dumps(nb, indent=2))
print(f"[build] {_OUT} ({_OUT.stat().st_size}B) | ACCEL={ACCELERATOR}")

KM = _ROOT / "kernel-metadata.json"
km = {
    "id":"krisskey/arc3-minimal-v70",
    "title":"ARC3 minimal v70",
    "code_file":"submission.ipynb","language":"python","kernel_type":"notebook",
    "is_private":True,"enable_gpu":True,"enable_tpu":False,"enable_internet":False,
    "dataset_sources":[DATASET_SLUG],"competition_sources":[],"kernel_sources":[],
}
KM.write_text(json.dumps(km, indent=2))
print(f"[build] {KM}")
