"""
kaggle_main.py — ARC-AGI-3 Submission Orchestrator
v75 MULTI-STRATEGY:
  Strategy 0: Cache replay (deterministic, free)
  Strategy 1: DenseExplorer (4-phase: simple brute → dense scan 1024 → BFS replay → 1px refine)
  Strategy 2: Beam search (w=4, d=20) + D4 hash pruning
  Strategy 3: TTT on winning trajectory (beam or dense)
  Strategy 4: MCTS fallback (150 sims)
  Strategy 5: TTT-calibrated agent rollout (final fallback)

Why DenseExplorer first:
  - 1024 positions × brute force = guaranteed coverage of ALL click targets
  - Phase 2 BFS builds winning paths from every "live" cell that changes state
  - No model needed, deterministic, fast (<5s typical)
  - Proven approach for ARC-style click/color puzzles
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

import torch
import numpy as np

# ─── Paths ───────────────────────────────────────────────────────────────────────────────

KAGGLE_INPUT   = Path("/kaggle/input")
KAGGLE_WORKING = Path("/kaggle/working")
REPO_ROOT      = Path(__file__).resolve().parent

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

    # v75: DummyBackbone forced — URM not trained on ARC-3
    use_checkpoint:  bool = False
    checkpoint_name: str  = ""
    adapter_name:    str  = "adapter_global.pt"
    submission_file: str  = "submission.json"

    # Dense explorer config (Strategy 1)
    dense_budget:  int   = 3000   # max steps for DenseExplorer
    dense_enabled: bool  = True

    # Beam search config (Strategy 2)
    beam_width:    int   = 4
    beam_depth:    int   = 20
    mcts_sims:     int   = 150
    time_per_game: float = 50.0   # seconds budget per game

    # TTT config (Strategy 3)
    ttt_steps:    int   = 50
    ttt_lr:       float = 5e-4
    ttt_enabled:  bool  = True

    # Cache
    traj_cache_path: str = ""


CFG = RunConfig()

print(f"[config] device={CFG.device} fp16={CFG.fp16}")
print(f"[config] DenseExplorer={CFG.dense_enabled} dense_budget={CFG.dense_budget}")
print(f"[config] beam_width={CFG.beam_width} beam_depth={CFG.beam_depth} mcts_sims={CFG.mcts_sims}")
print(f"[config] ttt_enabled={CFG.ttt_enabled} ttt_steps={CFG.ttt_steps}")

if torch.cuda.is_available():
    print(f"[gpu] {torch.cuda.get_device_name(0)} | VRAM={torch.cuda.get_device_properties(0).total_memory//1024**3}GB")


# ─── arc-agi install ──────────────────────────────────────────────────────────────────────

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


# ─── Cache loader ─────────────────────────────────────────────────────────────────────

def _load_traj_cache():
    try:
        from trajectory_cache import ProvenTrajectoryCache
        path = CFG.traj_cache_path or str(
            REPO_ROOT / "proven_trajectories.json"
        )
        return ProvenTrajectoryCache.load(path)
    except Exception as e:
        print(f"[TrajCache] disabled: {e}")
        return None


# ─── Action list helper ───────────────────────────────────────────────────────────────────

def _get_action_list(env):
    """Get action list from env (arc-agi API)."""
    try:
        return list(env.actions)
    except Exception:
        try:
            return list(env.action_space.actions)
        except Exception:
            return list(range(CFG.n_actions))


# ─── Submission runner ────────────────────────────────────────────────────────────────────

def run_submission() -> None:
    _install_arc_agi()

    import arc_agi as arc
    from submission_agent import VERICODINGAgent, AgentConfig

    assert hasattr(arc, 'list_games'), "arc_agi API missing list_games"

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
    v75 multi-strategy episode pipeline:
    0. Cache replay
    1. DenseExplorer (4-phase brute/scan/BFS/refine)
    2. Beam search + D4 hash
    3. TTT on winning trajectory
    4. MCTS fallback
    5. TTT-calibrated agent rollout
    Returns: (score, strategy_name)
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
                    # Replay solution from fresh state
                    env.reset()
                    score = 0.0
                    sol_actions: list = []
                    for step_item in explorer.solution:
                        # solution items are action indices (int)
                        ai = step_item if isinstance(step_item, int) else step_item[0]
                        _, reward, done, trunc, _ = env.step(ai)
                        score += float(reward)
                        sol_actions.append(ai)
                        if done or trunc:
                            break
                    print(f"  [{gid}] ★ DENSE score={score:.4f} steps={explorer._total_steps} t={elapsed_dense:.1f}s")
                    if score > 0 and traj_cache is not None and sol_actions:
                        initial_obs, _ = env.reset()
                        traj_cache.record(initial_obs, sol_actions)
                    return score, "dense"
                else:
                    print(f"  [{gid}] dense no-win ({explorer._total_steps} steps, {elapsed_dense:.1f}s) → beam")
        except Exception as e:
            print(f"  [{gid}] DenseExplorer error (non-fatal): {e}")

    # Time check before beam
    elapsed = time.time() - t_start
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
        print(f"  [{gid}] beam error (non-fatal): {e}")

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

    # Beam solved — cache + return
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
    # Strategy breakdown
    if strategy_log:
        from collections import Counter
        strats = Counter(strategy_log.values())
        print(f"[strategies] {dict(strats)}")


# ─── Entry point ──────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    run_submission()
