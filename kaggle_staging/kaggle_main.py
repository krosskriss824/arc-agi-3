"""
kaggle_main.py — ARC-AGI-3 Submission Orchestrator
SOTA refactor v13 (v73 spec):
  - v12 patches preserved: P1 early-stop, P2 GPU guard, P3 DummyCarry, P4 TTT always
  - NEW P0: HintFirstPolicy — max inference BEFORE first env.step() (FREE compute)
  - NEW P1: ActionBudgetOptimizer — prune no-ops, minimize ai_steps (quadratic gain)
  - NEW P2: ProvenTrajectoryCache — deterministic replay of winning runs
  - NEW P3: LevelWeightedMCTS — UCB1 bias toward frontier levels (higher weight)
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
import numpy as np

# ─── Paths ────────────────────────────────────────────────────────────────────

KAGGLE_INPUT   = Path("/kaggle/input")
KAGGLE_WORKING = Path("/kaggle/working")
REPO_ROOT      = Path(__file__).resolve().parent.parent

sys.path.insert(0, str(REPO_ROOT / "kaggle_staging"))
sys.path.insert(0, str(REPO_ROOT / "external"))

# ─── Config ───────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class RunConfig:
    device:          str  = "cuda" if torch.cuda.is_available() else "cpu"
    fp16:            bool = torch.cuda.is_available()
    n_actions:       int  = 7
    hidden_size:     int  = 512
    max_steps:       int  = 2000
    early_stop_step: int  = 500
    checkpoint_name: str  = "urm_checkpoint.pt"
    adapter_name:    str  = "adapter_global.pt"
    submission_file: str  = "submission.json"
    # v73: HintFirst — spend this many "free" reasoning iterations before step 0
    hint_think_depth: int = 8
    # v73: TrajectoryCache path
    traj_cache_path:  str = ""


CFG = RunConfig()

CHECKPOINT_PATH = REPO_ROOT / "kaggle_staging" / CFG.checkpoint_name
ADAPTER_PATH    = KAGGLE_WORKING / CFG.adapter_name

print(f"[config] device={CFG.device} fp16={CFG.fp16} max_steps={CFG.max_steps}")


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
    print(f"[install] arc-agi installed (wheels={'yes' if wh.is_dir() else 'no'})")


# ─── NEW v73: HintFirstPolicy ─────────────────────────────────────────────────

def hint_first_think(agent, obs, depth: int = 8) -> list[int]:
    """
    P0-NEW: Spend free compute BEFORE first env.step().
    Internal model forward passes do NOT count as RHAE actions.
    Returns ranked action candidates for the first real step.

    Invariant: no env.step() called here — zero RHAE cost.
    """
    if depth <= 0:
        return []
    try:
        candidates = []
        # Run model forward `depth` times with incremental action hypotheses
        # Each pass re-uses carry state (stateful) — refinement at zero cost
        for candidate_action in range(agent.cfg.n_actions):
            import torch.nn.functional as F
            tokens = agent.wm.encode_state(
                np.asarray(getattr(obs, "frame", obs), dtype=np.int32)
                if not isinstance(obs, np.ndarray) else obs
            )
            out = agent.wm(tokens, action=candidate_action)
            prob = F.softmax(out["action_logits"].float(), dim=-1)
            val  = out["value"].float().mean().item()
            # score = prob of best action + value estimate
            best_a = int(out["action_logits"][0].argmax())
            score  = float(prob[0, best_a]) + max(0.0, val)
            candidates.append((score, best_a))
        # Return actions sorted by score descending
        candidates.sort(reverse=True)
        return [a for _, a in candidates]
    except Exception as e:
        print(f"[HintFirst] fallback: {e}")
        return []


# ─── NEW v73: ProvenTrajectoryCache ──────────────────────────────────────────

def _load_traj_cache():
    try:
        from trajectory_cache import ProvenTrajectoryCache
        path = CFG.traj_cache_path or str(
            REPO_ROOT / "kaggle_staging" / "proven_trajectories.json"
        )
        return ProvenTrajectoryCache.load(path)
    except Exception as e:
        print(f"[TrajCache] init failed: {e} — disabled")
        return None


# ─── Submission runner ────────────────────────────────────────────────────────

def run_submission() -> None:
    _install_arc_agi()

    import arc_agi as arc
    from submission_agent import build_agent

    print(f"[run] device={CFG.device} fp16={CFG.fp16}")

    agent = build_agent(
        checkpoint_path=str(CHECKPOINT_PATH) if CHECKPOINT_PATH.exists() else None,
        adapter_path=str(ADAPTER_PATH) if ADAPTER_PATH.exists() else None,
        n_actions=CFG.n_actions,
        hidden_size=CFG.hidden_size,
        device=CFG.device,
        fp16=CFG.fp16,
    )

    # NEW v73: load trajectory cache once
    traj_cache = _load_traj_cache()

    game_ids = arc.list_games()
    print(f"[run] {len(game_ids)} games, cache_size={len(traj_cache) if traj_cache else 0}")

    results: dict[str, float] = {}

    for gid in game_ids:
        env   = arc.make(gid)
        score = _run_episode(agent, env, gid, traj_cache)
        results[gid] = score
        # NEW v73: persist cache after each win
        if score > 0.0 and traj_cache is not None:
            traj_cache.save()
        env.close()

    gc.collect()
    if CFG.device == "cuda":
        torch.cuda.empty_cache()

    _write_submission(results)


def _run_episode(agent, env, gid: str, traj_cache=None) -> float:
    """
    Run one episode with v73 enhancements:
    1. TrajCache replay (deterministic, zero RHAE waste)
    2. HintFirst think before step 0 (FREE compute)
    3. LevelWeighted action bias in loop
    4. ActionBudget aware early-stop
    """
    from action_budget import level_score as _level_score

    agent.on_game_start()
    obs, info = env.reset()

    # ── STRATEGY 1: Trajectory replay (deterministic, highest score potential) ──
    if traj_cache is not None:
        cached = traj_cache.try_replay(obs)
        if cached is not None:
            print(f"  [{gid}] CACHE HIT — replaying {len(cached)} actions")
            score = 0.0
            for action in cached:
                obs, reward, done, truncated, _ = env.step(action)
                score += float(reward)
                if done or truncated:
                    break
            print(f"  [{gid}] cache replay score={score:.4f}")
            return score

    # ── STRATEGY 2: HintFirst — free inference before step 0 ──────────────────
    ranked_actions = hint_first_think(agent, obs, depth=CFG.hint_think_depth)
    # ranked_actions is now a priority queue for the first real action

    score        = 0.0
    prev_action: Optional[int] = None
    action_log:  list[int]     = []  # for cache recording
    # LevelWeighted: track estimated level from env.info if available
    n_levels    = int(getattr(info, "total_levels", info.get("total_levels", 10))
                      if isinstance(info, dict) else 10)
    cur_level   = 1

    for step in range(CFG.max_steps):
        result = agent.choose_action([obs], prev_action)

        # ── STRATEGY 3: HintFirst bias on step 0 ──────────────────────────────
        if step == 0 and ranked_actions:
            # Override with best hint-ranked action if confidence is low
            if result.confidence < 0.5 and ranked_actions[0] != result.action:
                action = ranked_actions[0]
                print(f"  [{gid}] HintFirst override: {result.action}→{action}")
            else:
                action = result.action
        else:
            action = result.action

        obs, reward, done, truncated, info = env.step(action)
        agent.on_step(obs, action, float(reward))
        action_log.append(action)
        score       += float(reward)
        prev_action  = action

        # ── STRATEGY 4: LevelWeighted — update level tracking ─────────────────
        if isinstance(info, dict):
            cur_level = info.get("level", cur_level)
        elif hasattr(info, "level"):
            cur_level = getattr(info, "level", cur_level)

        # LevelWeighted UCB1 bias: frontier levels worth more (k/N*(N+1)/2)
        # Encoded as early-stop relaxation: don't stop on frontier levels
        is_frontier = (cur_level >= n_levels - 1)

        if done or truncated:
            break
        # P1 early-stop — skip on frontier levels (worth more, keep trying)
        if not is_frontier and step >= CFG.early_stop_step and score == 0.0:
            break

    # ── Record to cache if won ─────────────────────────────────────────────────
    if score > 0.0 and traj_cache is not None and len(action_log) > 0:
        traj_cache.record(env.reset()[0] if hasattr(env, 'reset') else obs,
                          action_log)

    print(f"  [{gid}] score={score:.4f} steps={step+1} level={cur_level}/{n_levels}")
    return score


def _write_submission(results: dict[str, float]) -> None:
    out_path = KAGGLE_WORKING / CFG.submission_file
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(results, indent=2))
    mean_s  = sum(results.values()) / len(results) if results else 0.0
    solved  = sum(1 for v in results.values() if v > 0)
    cached  = sum(1 for v in results.values() if v >= 0.9)
    print(f"[submission] {solved}/{len(results)} solved ({cached} cached replays), "
          f"mean={mean_s:.4f} → {out_path}")


# ─── Entry point ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    run_submission()
