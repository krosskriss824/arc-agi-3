"""
kaggle_main.py — ARC-AGI-3 Submission Orchestrator
SOTA refactor v12:
  - P1: max_steps 200→2000, early-stop at step>500 with score==0
  - P2: GPU guard — prefer CUDA, FP16 on T4
  - clean submission path, device setup once
  - TTT sidecar via wasm_bridge (not in this file)
"""
from __future__ import annotations
import sys
import os
import gc
import subprocess
import json
from pathlib import Path
from dataclasses import dataclass
from typing import Optional

import torch

# ─── Paths ────────────────────────────────────────────────────────────────────

KAGGLE_INPUT   = Path("/kaggle/input")
KAGGLE_WORKING = Path("/kaggle/working")
REPO_ROOT      = Path(__file__).resolve().parent.parent

sys.path.insert(0, str(REPO_ROOT / "kaggle_staging"))
sys.path.insert(0, str(REPO_ROOT / "external"))

# ─── Config ───────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class RunConfig:
    # P2: GPU guard — auto-detect CUDA
    device:          str  = "cuda" if torch.cuda.is_available() else "cpu"
    fp16:            bool = torch.cuda.is_available()   # FP16 on GPU only
    n_actions:       int  = 7
    hidden_size:     int  = 512
    # P1: raised from 200 to 2000; early-stop guards against infinite loops
    max_steps:       int  = 2000
    early_stop_step: int  = 500   # abort if score==0 after this many steps
    checkpoint_name: str  = "urm_checkpoint.pt"
    adapter_name:    str  = "adapter_global.pt"
    submission_file: str  = "submission.json"


CFG = RunConfig()

CHECKPOINT_PATH = REPO_ROOT / "kaggle_staging" / CFG.checkpoint_name
ADAPTER_PATH    = KAGGLE_WORKING / CFG.adapter_name

print(f"[config] device={CFG.device} fp16={CFG.fp16} max_steps={CFG.max_steps}")


# ─── arc-agi install — conditional, wheels preferred ─────────────────────────

def _install_arc_agi() -> None:
    wh = (
        KAGGLE_INPUT
        / "competitions"
        / "arc-prize-2026-arc-agi-3"
        / "arc_agi_3_wheels"
    )
    base_cmd = [sys.executable, "-m", "pip", "install", "-q"]
    packages  = ["arc-agi", "python-dotenv"]
    cmd = (
        base_cmd + ["--no-index", f"--find-links={wh}"] + packages
        if wh.is_dir()
        else base_cmd + packages
    )
    subprocess.check_call(cmd)
    print(f"[install] arc-agi installed (wheels={'yes' if wh.is_dir() else 'no'})")


# ─── Submission runner ────────────────────────────────────────────────────────

def run_submission() -> None:
    _install_arc_agi()

    import arc_agi as arc
    from submission_agent import build_agent

    print(f"[run] device={CFG.device} fp16={CFG.fp16}")

    # P2: build agent with GPU + optional FP16
    agent = build_agent(
        checkpoint_path=str(CHECKPOINT_PATH) if CHECKPOINT_PATH.exists() else None,
        adapter_path=str(ADAPTER_PATH) if ADAPTER_PATH.exists() else None,
        n_actions=CFG.n_actions,
        hidden_size=CFG.hidden_size,
        device=CFG.device,
        fp16=CFG.fp16,
    )

    game_ids = arc.list_games()
    print(f"[run] {len(game_ids)} games")

    results: dict[str, float] = {}

    for gid in game_ids:
        env   = arc.make(gid)
        score = _run_episode(agent, env, gid)
        results[gid] = score
        env.close()

    gc.collect()
    if CFG.device == "cuda":
        torch.cuda.empty_cache()

    _write_submission(results)


def _run_episode(agent, env, gid: str) -> float:
    """
    Run one episode.
    P1: early-stop — if score==0 after early_stop_step steps, abort.
    """
    agent.on_game_start()
    obs, _info = env.reset()
    score       = 0.0
    prev_action: Optional[int] = None

    for step in range(CFG.max_steps):
        result = agent.choose_action([obs], prev_action)
        obs, reward, done, truncated, _info = env.step(result.action)
        agent.on_step(obs, result.action, float(reward))
        score      += float(reward)
        prev_action = result.action
        if done or truncated:
            break
        # P1: early-stop — don't waste budget on unwinnable games
        if step >= CFG.early_stop_step and score == 0.0:
            break

    print(f"  [{gid}] score={score:.4f} steps={step+1}")
    return score


def _write_submission(results: dict[str, float]) -> None:
    out_path = KAGGLE_WORKING / CFG.submission_file
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(results, indent=2))
    mean_s = sum(results.values()) / len(results) if results else 0.0
    solved  = sum(1 for v in results.values() if v > 0)
    print(f"[submission] {solved}/{len(results)} solved, mean={mean_s:.4f} → {out_path}")


# ─── Entry point ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    run_submission()
