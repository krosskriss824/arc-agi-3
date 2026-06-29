"""
kaggle_main.py — ARC-AGI-3 Submission Orchestrator
v75.1 FIXES:
  - DenseExplorer solution replay uses action_list[idx] objects (not ints)
  - Complex actions go through safe_step(env, action_obj, cx, cy)
  - _get_action_list() validates .is_complex() attribute
  - Full traceback on non-fatal errors (dense + beam)
  - Strategy counter in submission summary
  - GPU diagnostics at startup

Strategy order:
  0. Cache replay (deterministic, free)
  1. DenseExplorer (4-phase: simple brute → dense scan 1024 → BFS replay → 1px refine)
  2. Beam search (w=4, d=20) + D4 hash pruning
  3. TTT on winning trajectory
  4. MCTS (inside beam, 150 sims)
  5. TTT-calibrated agent rollout (final fallback)
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
from typing import Optional, List, Tuple
from collections import Counter

import torch
import numpy as np

# ─── Paths ───────────────────────────────────────────────────────────────────────────────

KAGGLE_INPUT   = Path("/kaggle/input")
KAGGLE_WORKING = Path("/kaggle/working")
REPO_ROOT      = Path(__file__).resolve().parent   # = kaggle_staging/

sys.path.insert(0, str(REPO_ROOT))
sys.path.insert(0, str(REPO_ROOT / "external"))
sys.path.insert(0, str(REPO_ROOT / "external" / "urm"))

# ─── Config ───────────────────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class RunConfig:
    device:      str  = "cuda" if torch.cuda.is_available() else "cpu"
    fp16:        bool = torch.cuda.is_available()
    n_actions:   int  = 7
    hidden_size: int  = 512

    use_checkpoint:  bool = False
    checkpoint_name: str  = ""
    adapter_name:    str  = "adapter_global.pt"
    submission_file: str  = "submission.json"

    # Dense explorer (Strategy 1)
    dense_budget:  int   = 3000
    dense_enabled: bool  = True

    # Beam search (Strategy 2)
    beam_width:    int   = 4
    beam_depth:    int   = 20
    mcts_sims:     int   = 150
    time_per_game: float = 50.0

    # TTT (Strategy 3)
    ttt_steps:    int   = 50
    ttt_lr:       float = 5e-4
    ttt_enabled:  bool  = True

    traj_cache_path: str = ""


CFG = RunConfig()

print(f"[config] device={CFG.device} fp16={CFG.fp16}")
print(f"[config] DenseExplorer={CFG.dense_enabled} dense_budget={CFG.dense_budget}")
print(f"[config] beam_width={CFG.beam_width} beam_depth={CFG.beam_depth} mcts_sims={CFG.mcts_sims}")
print(f"[config] ttt_enabled={CFG.ttt_enabled} ttt_steps={CFG.ttt_steps}")

if torch.cuda.is_available():
    _props = torch.cuda.get_device_properties(0)
    print(f"[gpu] {torch.cuda.get_device_name(0)} | VRAM={_props.total_memory // 1024**3}GB")
else:
    print("[gpu] CPU only")


# ─── arc-agi install ────────────────────────────────────────────────────────────────────

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


# ─── Cache loader ───────────────────────────────────────────────────────────────────

def _load_traj_cache():
    try:
        from trajectory_cache import ProvenTrajectoryCache
        path = CFG.traj_cache_path or str(REPO_ROOT / "proven_trajectories.json")
        return ProvenTrajectoryCache.load(path)
    except Exception as e:
        print(f"[TrajCache] disabled: {e}")
        return None


# ─── Action list helper ─────────────────────────────────────────────────────────────────

def _get_action_list(env):
    """Return list of action objects with .is_complex() method."""
    for attr in ("actions", "action_space"):
        try:
            raw = getattr(env, attr)
            acts = list(raw.actions if hasattr(raw, "actions") else raw)
            if acts and hasattr(acts[0], "is_complex"):
                return acts
        except Exception:
            continue
    print("[warn] could not get action list with .is_complex() — DenseExplorer will be skipped")
    return []


# ─── Dense solution replay ───────────────────────────────────────────────────────────────

def _replay_dense_solution(env, solution, action_list):
    """Replay DenseExplorer solution using proper action objects + safe_step.

    explorer.solution is a list of:
      - int  → action index into action_list, click at (32,32)
      - (aidx, cx, cy) tuple  → BFS prefix item with explicit coords

    Uses safe_step() so complex actions always get data={x,y}.
    Returns (score, list_of_action_indices).
    """
    from step_adapter import safe_step
    env.reset()
    score = 0.0
    replay_actions: list[int] = []

    for item in solution:
        if isinstance(item, (list, tuple)) and len(item) == 3:
            aidx, cx, cy = int(item[0]), int(item[1]), int(item[2])
        else:
            aidx, cx, cy = int(item), 32, 32

        if aidx >= len(action_list):
            break
        action_obj = action_list[aidx]
        result = safe_step(env, action_obj, cx, cy)
        if result is None:
            break

        # Extract reward + done from result (Frame object or tuple)
        reward = 0.0
        won    = False
        if hasattr(result, "reward"):
            reward = float(result.reward)
            won    = "WIN" in str(getattr(result, "state", ""))
        elif isinstance(result, tuple) and len(result) >= 3:
            reward = float(result[1])
            won    = bool(result[2])

        score += reward
        replay_actions.append(aidx)
        if won:
            break

    return score, replay_actions


# ─── Submission runner ───────────────────────────────────────────────────────────────────

def run_submission() -> None:
    _install_arc_agi()

    import arc_agi as arc
    from submission_agent import VERICODINGAgent, AgentConfig

    cfg   = AgentConfig(
        n_actions=CFG.n_actions,
        hidden_size=CFG.hidden_size,
        device=CFG.device,
        fp16=False,
    )
    agent = VERICODINGAgent(cfg)
    agent.wm.eval()
    for p in agent.wm.parameters():
        p.requires_grad = False
    print(f"[run] DummyBackbone ready")

    traj_cache = _load_traj_cache()
    game_ids   = arc.list_games()
    assert len(game_ids) > 0, "BUG-X6: empty game list"
    print(f"[run] {len(game_ids)} games | cache={len(traj_cache) if traj_cache else 0}")

    results:      dict[str, float] = {}
    strategy_log: dict[str, str]   = {}

    for gid in game_ids:
        env   = arc.make(gid)
        score, strategy = _run_episode(agent, env, gid, traj_cache)
        results[gid]      = score
        strategy_log[gid] = strategy
        if score > 0 and traj_cache is not None:
            traj_cache.save()
        env.close()
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()

    _write_submission(results, strategy_log)


def _run_episode(agent, env, gid: str, traj_cache=None) -> Tuple[float, str]:
    """
    v75.1 multi-strategy episode pipeline.
    Returns (score, strategy_name).
    """
    t_start = time.time()
    agent.on_game_start()
    obs, info = env.reset()

    # ── STRATEGY 0: Cache replay ──────────────────────────────────────────────
    if traj_cache is not None:
        cached = traj_cache.try_replay(obs)
        if cached is not None:
            print(f"  [{gid}] ★ CACHE HIT ({len(cached)} actions)")
            score = 0.0
            for action in cached:
                obs, reward, done, truncated, _ = env.step(action)
                score += float(reward)
                if done or truncated:
                    break
            print(f"  [{gid}] cache score={score:.4f}")
            return score, "cache"

    # ── STRATEGY 1: DenseExplorer ─────────────────────────────────────────────
    if CFG.dense_enabled:
        try:
            from dense_explorer import DenseExplorer
            action_list = _get_action_list(env)
            if action_list:
                env.reset()
                explorer = DenseExplorer(env, action_list)
                found = explorer.explore(max_steps=CFG.dense_budget)
                elapsed_dense = time.time() - t_start
                if found and explorer.solution:
                    score, sol_actions = _replay_dense_solution(env, explorer.solution, action_list)
                    print(f"  [{gid}] ★ DENSE score={score:.4f} steps={explorer._total_steps} t={elapsed_dense:.1f}s")
                    if score > 0 and traj_cache is not None and sol_actions:
                        initial_obs, _ = env.reset()
                        traj_cache.record(initial_obs, sol_actions)
                    return score, "dense"
                else:
                    print(f"  [{gid}] dense no-win ({explorer._total_steps} steps, {elapsed_dense:.1f}s) → beam")
            else:
                print(f"  [{gid}] no action_list → skipping dense")
        except Exception as e:
            import traceback
            print(f"  [{gid}] DenseExplorer error (non-fatal): {e}")
            print(traceback.format_exc())

    # Time remaining for beam
    elapsed     = time.time() - t_start
    beam_budget = max(5.0, CFG.time_per_game - elapsed)

    # ── STRATEGY 2: Beam search ───────────────────────────────────────────────
    beam_score   = 0.0
    beam_actions: list[int] = []
    try:
        from beam_search import smart_solve
        _last_obs = {"obs": obs}

        def _reset():
            o, _ = env.reset()
            _last_obs["obs"] = o
            return o

        def _step(action):
            o, r, d, t, i = env.step(action)
            _last_obs["obs"] = o
            return o, r, d, t, i

        print(f"  [{gid}] beam (w={CFG.beam_width} d={CFG.beam_depth} t={beam_budget:.0f}s)...")
        beam_score, beam_actions = smart_solve(
            env_reset_fn  = _reset,
            env_step_fn   = _step,
            n_actions     = CFG.n_actions,
            time_budget_s = beam_budget,
            beam_width    = CFG.beam_width,
            beam_depth    = CFG.beam_depth,
            mcts_sims     = CFG.mcts_sims,
        )
        print(f"  [{gid}] beam score={beam_score:.4f} actions={len(beam_actions)}")
    except Exception as e:
        import traceback
        print(f"  [{gid}] beam error (non-fatal): {e}")
        print(traceback.format_exc())

    # ── STRATEGY 3: TTT on beam trajectory ─────────────────────────────────
    if CFG.ttt_enabled and beam_actions:
        try:
            from ttt_submission import ttt_on_trajectory
            env.reset()
            reward_hist = []
            for a in beam_actions:
                _, r, done, trunc, _ = env.step(a)
                reward_hist.append(float(r))
                if done or trunc:
                    break
            ttt_on_trajectory(
                agent, beam_actions, reward_hist,
                steps=CFG.ttt_steps, lr=CFG.ttt_lr
            )
            print(f"  [{gid}] TTT done ({CFG.ttt_steps} steps)")
        except Exception as e:
            print(f"  [{gid}] TTT failed (non-fatal): {e}")

    if beam_score > 0 and beam_actions:
        if traj_cache is not None:
            initial_obs, _ = env.reset()
            traj_cache.record(initial_obs, beam_actions)
        return beam_score, "beam"

    # ── STRATEGY 4+5: TTT-calibrated agent rollout (final fallback) ─────────
    env.reset()
    agent.on_game_start()
    fallback_score    = 0.0
    prev_action       = None
    fallback_actions: list[int] = []
    last_obs          = obs

    for step in range(200):
        result = agent.choose_action([last_obs], prev_action)
        last_obs, reward, done, trunc, _ = env.step(result.action)
        agent.on_step(last_obs, result.action, float(reward))
        fallback_score   += float(reward)
        prev_action       = result.action
        fallback_actions.append(result.action)
        if done or trunc:
            break

    if fallback_score > 0 and traj_cache is not None and fallback_actions:
        initial_obs, _ = env.reset()
        traj_cache.record(initial_obs, fallback_actions)

    print(f"  [{gid}] agent fallback score={fallback_score:.4f}")
    return fallback_score, "agent"


def _write_submission(results: dict[str, float], strategy_log: dict[str, str] = None) -> None:
    out_path = KAGGLE_WORKING / CFG.submission_file
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(results, indent=2))
    mean_s = sum(results.values()) / len(results) if results else 0.0
    solved  = sum(1 for v in results.values() if v > 0)
    print(f"[submission] {solved}/{len(results)} solved, mean={mean_s:.4f} → {out_path}")
    if strategy_log:
        strats = Counter(strategy_log.values())
        print(f"[strategies] {dict(strats)}")


# ─── Entry point ──────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    run_submission()
