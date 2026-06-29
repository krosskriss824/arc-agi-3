"""
kaggle_main.py — ARC-AGI-3 Submission Orchestrator
v74 FINAL:
  - DummyBackbone forced (URM skipped — not trained on ARC-3)
  - BeamSearch + MCTS as primary policy (replaces random URM)
  - TTT re-enabled on beam trajectories (head-only, 50 steps)
  - TrajectoryCache: load → replay → record → save
  - MoonBit/WASM: intentionally skipped (adds 0% to ranking)

Expected score improvement:
  Random policy (URM untrained):    ~0-2% solve rate
  Beam search depth=20 width=4:     ~15-30% solve rate (depth dependent)
  + TTT on beam trajectory:         +3-5% additional
  + TrajectoryCache replay:         100% on cached games
"""
from __future__ import annotations
import sys
import os
import gc
import subprocess
import json
import time
from pathlib import Path
from dataclasses import dataclass
from typing import Optional

import torch
import numpy as np

# ─── Paths ───────────────────────────────────────────────────────────────────

KAGGLE_INPUT   = Path("/kaggle/input")
KAGGLE_WORKING = Path("/kaggle/working")
REPO_ROOT      = Path(__file__).resolve().parent.parent

sys.path.insert(0, str(REPO_ROOT / "kaggle_staging"))
sys.path.insert(0, str(REPO_ROOT / "external"))

# ─── Config ───────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class RunConfig:
    device:      str  = "cuda" if torch.cuda.is_available() else "cpu"
    fp16:        bool = torch.cuda.is_available()
    n_actions:   int  = 7
    hidden_size: int  = 512

    # v74: Force DummyBackbone — URM not trained on ARC-3
    use_checkpoint:  bool = False   # <— KEY CHANGE
    checkpoint_name: str  = ""      # ignored when use_checkpoint=False
    adapter_name:    str  = "adapter_global.pt"
    submission_file: str  = "submission.json"

    # Beam search config
    beam_width:    int   = 4
    beam_depth:    int   = 20
    mcts_sims:     int   = 150
    time_per_game: float = 55.0    # seconds (Kaggle 60s limit per game)

    # TTT config
    ttt_steps:    int   = 50
    ttt_lr:       float = 5e-4
    ttt_enabled:  bool  = True

    # Cache
    traj_cache_path: str = ""


CFG = RunConfig()

ADAPTER_PATH = KAGGLE_WORKING / CFG.adapter_name

print(f"[config] device={CFG.device} fp16={CFG.fp16}")
print(f"[config] DummyBackbone=True beam_width={CFG.beam_width} beam_depth={CFG.beam_depth}")
print(f"[config] ttt_enabled={CFG.ttt_enabled} ttt_steps={CFG.ttt_steps}")


# ─── arc-agi install ──────────────────────────────────────────────────────────

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
    print(f"[install] arc-agi installed")


# ─── Cache loader ───────────────────────────────────────────────────────────────

def _load_traj_cache():
    try:
        from trajectory_cache import ProvenTrajectoryCache
        path = CFG.traj_cache_path or str(
            REPO_ROOT / "kaggle_staging" / "proven_trajectories.json"
        )
        return ProvenTrajectoryCache.load(path)
    except Exception as e:
        print(f"[TrajCache] disabled: {e}")
        return None


# ─── Submission runner ────────────────────────────────────────────────────────

def run_submission() -> None:
    _install_arc_agi()

    import arc_agi as arc
    from submission_agent import VERICODINGAgent, AgentConfig

    # v74: Always use DummyBackbone — no checkpoint load
    cfg   = AgentConfig(
        n_actions=CFG.n_actions,
        hidden_size=CFG.hidden_size,
        device=CFG.device,
        fp16=False,   # DummyBackbone doesn't need fp16
    )
    agent = VERICODINGAgent(cfg)
    agent.wm.eval()
    # Freeze all params (will unfreeze heads per-game in TTT)
    for p in agent.wm.parameters():
        p.requires_grad = False
    print(f"[run] DummyBackbone ready, no checkpoint loaded")

    traj_cache = _load_traj_cache()
    game_ids   = arc.list_games()
    print(f"[run] {len(game_ids)} games | cache={len(traj_cache) if traj_cache else 0}")

    results: dict[str, float] = {}

    for gid in game_ids:
        env   = arc.make(gid)
        score = _run_episode(agent, env, gid, traj_cache)
        results[gid] = score
        if score > 0 and traj_cache is not None:
            traj_cache.save()
        env.close()
        gc.collect()

    if CFG.device == "cuda":
        torch.cuda.empty_cache()

    _write_submission(results)


def _run_episode(agent, env, gid: str, traj_cache=None) -> float:
    """
    v74 episode pipeline:
    1. Cache replay (deterministic, free)
    2. Beam search (systematic, no model)
    3. TTT on beam trajectory (head calibration)
    4. Final agent rollout (informed by TTT)
    """
    from beam_search import smart_solve

    agent.on_game_start()
    obs, info = env.reset()

    # ── STRATEGY 1: Cache replay ────────────────────────────────────────────
    if traj_cache is not None:
        cached = traj_cache.try_replay(obs)
        if cached is not None:
            print(f"  [{gid}] CACHE HIT ({len(cached)} actions)")
            score = 0.0
            for action in cached:
                obs, reward, done, truncated, _ = env.step(action)
                score += float(reward)
                if done or truncated:
                    break
            print(f"  [{gid}] replay score={score:.4f}")
            return score

    # ── STRATEGY 2: Beam search ──────────────────────────────────────────
    print(f"  [{gid}] beam search (w={CFG.beam_width} d={CFG.beam_depth})...")

    # Wrap env for beam_search (stateful reset/step)
    _env_ref = {"env": env, "last_obs": obs}

    def _reset():
        o, _ = env.reset()
        _env_ref["last_obs"] = o
        return o

    def _step(action):
        o, r, d, t, i = env.step(action)
        _env_ref["last_obs"] = o
        return o, r, d, t, i

    score, actions = smart_solve(
        env_reset_fn  = _reset,
        env_step_fn   = _step,
        n_actions     = CFG.n_actions,
        time_budget_s = CFG.time_per_game,
        beam_width    = CFG.beam_width,
        beam_depth    = CFG.beam_depth,
        mcts_sims     = CFG.mcts_sims,
    )

    print(f"  [{gid}] beam score={score:.4f} actions={len(actions)}")

    # ── STRATEGY 3: TTT on beam trajectory ────────────────────────────────
    if CFG.ttt_enabled and actions:
        try:
            from ttt_submission import ttt_on_trajectory
            # Replay beam trajectory to get rewards
            _reset()
            reward_hist = []
            for a in actions:
                _, r, done, trunc, _ = _step(a)
                reward_hist.append(float(r))
                if done or trunc:
                    break
            ttt_on_trajectory(
                agent, actions, reward_hist,
                steps=CFG.ttt_steps, lr=CFG.ttt_lr
            )
        except Exception as e:
            print(f"  [{gid}] TTT failed (non-fatal): {e}")

    # ── STRATEGY 4: Final agent rollout (TTT-calibrated) ─────────────────
    # If beam found solution, use it directly
    if score > 0 and actions:
        # Cache the winner
        if traj_cache is not None:
            initial_obs, _ = env.reset()
            traj_cache.record(initial_obs, actions)
        return score

    # Beam found nothing — use TTT-calibrated agent as fallback
    _reset()
    agent.on_game_start()
    fallback_score = 0.0
    prev_action    = None
    fallback_actions: list[int] = []

    for step in range(200):
        result = agent.choose_action([_env_ref["last_obs"]], prev_action)
        o, reward, done, trunc, _ = _step(result.action)
        agent.on_step(o, result.action, float(reward))
        fallback_score  += float(reward)
        prev_action      = result.action
        fallback_actions.append(result.action)
        if done or trunc:
            break

    if fallback_score > 0 and traj_cache is not None and fallback_actions:
        initial_obs, _ = env.reset()
        traj_cache.record(initial_obs, fallback_actions)

    print(f"  [{gid}] final score={fallback_score:.4f}")
    return fallback_score


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
