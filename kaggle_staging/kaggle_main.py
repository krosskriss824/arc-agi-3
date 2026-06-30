"""
kaggle_main.py — ARC-AGI-3 Submission Orchestrator
Refactor v19: FrameGraphExplorer + WASM hash wired into game loop.

FIXES (v19):
  GRAPH:  on_game_start(n_actions, tags) — configures FrameGraphExplorer priority tiers
  HASH:   _hash_grid() — WASM canonical_hash via get_rhae(), Python fallback
  STEP:   choose_action receives current_hash; on_step receives to_hash
  SYNC:   update_action_space(n) after every env.step()
  LOG:    result.source ("graph"/"urm") logged per-step; WIN path length logged

FIXES (v13, retained):
  X6: assert len(game_ids) > 0 — fails early if dataset missing
  X1: sys.path order ensures kaggle_staging/ resolved before external/
  GPU: explicit CUDA device name logged at startup

Invariants:
  - DEVICE set once at startup, never changed
  - agent constructed ONCE via build_agent factory
  - get_rhae() singleton — WASM loaded once, reused across all episodes
  - torch.cuda.empty_cache() called ONCE at end, not per-env
  - TTT not imported here
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

import numpy as np
import torch

# ─── Paths ───────────────────────────────────────────────────────────────────────

KAGGLE_INPUT   = Path("/kaggle/input")
KAGGLE_WORKING = Path("/kaggle/working")
REPO_ROOT      = Path(__file__).resolve().parent.parent

# FIX X1: kaggle_staging/ first — ensures wasm_bridge resolves locally
sys.path.insert(0, str(REPO_ROOT / "kaggle_staging"))
sys.path.insert(1, str(REPO_ROOT / "external"))

# ─── Config ─────────────────────────────────────────────────────────────────────

@dataclass(frozen=True)
class RunConfig:
    device:          str  = "cuda" if torch.cuda.is_available() else "cpu"
    n_actions:       int  = 7
    hidden_size:     int  = 512
    max_steps:       int  = 200
    checkpoint_name: str  = "urm_checkpoint.pt"
    adapter_name:    str  = "adapter_global.pt"
    submission_file: str  = "submission.json"


CFG = RunConfig()

CHECKPOINT_PATH = REPO_ROOT / "kaggle_staging" / CFG.checkpoint_name
ADAPTER_PATH    = KAGGLE_WORKING / CFG.adapter_name


# ─── arc-agi install — conditional, wheels preferred ───────────────────────

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


# ─── WASM hash helper ───────────────────────────────────────────────────────

# Lazy-init WASM singleton — None until first use
_rhae = None


def _get_rhae():
    """Lazy singleton for RhaeEngine. Returns None if WASM unavailable."""
    global _rhae
    if _rhae is not None:
        return _rhae
    try:
        from wasm_bridge import get_rhae
        _rhae = get_rhae()
        print("[hash] WASM canonical_hash active")
    except Exception as e:
        print(f"[hash] WASM unavailable ({e}) — using Python fallback hash")
        _rhae = False  # sentinel: tried and failed
    return _rhae if _rhae else None


def _hash_grid(grid: np.ndarray) -> int:
    """
    Compute state hash for FrameGraphExplorer.
    Primary:  WASM D4-canonical hash via RhaeEngine.canonical_hash()
    Fallback: hash(grid.tobytes()) — not D4-canonical but stable
    Returns int — safe as dict key.
    """
    rhae = _get_rhae()
    if rhae is not None:
        try:
            lo, hi = rhae.canonical_hash(grid)
            return int(lo) | (int(hi) << 32)
        except Exception:
            pass
    # Python fallback
    return int(hash(grid.tobytes()) & 0xFFFFFFFFFFFFFFFF)


def _obs_to_grid(obs) -> np.ndarray:
    """Extract grid from obs regardless of format."""
    if isinstance(obs, np.ndarray):
        return obs
    if isinstance(obs, dict):
        for key in ("grid", "observation", "input"):
            if key in obs:
                return np.asarray(obs[key])
    return np.asarray(obs)


# ─── Submission runner ─────────────────────────────────────────────────────────

def run_submission() -> None:
    _install_arc_agi()

    import arc_agi as arc
    from submission_agent import build_agent

    # GPU diagnostic — confirms T4/RTX 6000 Pro detection
    if torch.cuda.is_available():
        gpu_name = torch.cuda.get_device_name(0)
        gpu_mem  = torch.cuda.get_device_properties(0).total_memory / 1e9
        print(f"[run] GPU: {gpu_name} | VRAM: {gpu_mem:.1f} GB")
    print(f"[run] device={CFG.device}")

    agent = build_agent(
        checkpoint_path=str(CHECKPOINT_PATH) if CHECKPOINT_PATH.exists() else None,
        adapter_path=str(ADAPTER_PATH) if ADAPTER_PATH.exists() else None,
        n_actions=CFG.n_actions,
        hidden_size=CFG.hidden_size,
        device=CFG.device,
    )

    # Warm up WASM singleton before game loop
    _get_rhae()

    game_ids = arc.list_games()
    # FIX X6: fail early and clearly if competition dataset not mounted
    assert len(game_ids) > 0, (
        "[run] arc.list_games() returned 0 games. "
        "Check that arc-prize-2026-arc-agi-3 competition dataset is attached."
    )
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
    Run one episode. Returns cumulative reward.

    v19 additions:
      - on_game_start(n_actions, tags): configures FrameGraphExplorer
      - _hash_grid(obs): WASM D4-canonical hash for graph dedup
      - choose_action(frames, prev, current_hash): graph explorer first
      - on_step(obs, action, reward, to_hash): registers graph transition
      - update_action_space(n): syncs n_actions after each step
      - WIN detection: logs minimal path length
    """
    import arc_agi as arc

    obs, info = env.reset()

    # Extract game metadata BEFORE first step
    n_actions = len(env.action_space) if hasattr(env, "action_space") else CFG.n_actions
    tags: list[str] = []
    if hasattr(env, "info") and hasattr(env.info, "tags"):
        tags = list(env.info.tags)
    elif hasattr(info, "tags"):
        tags = list(info.tags)

    # v19: configure FrameGraphExplorer priority tiers BEFORE first action
    agent.on_game_start(n_actions=n_actions, tags=tags)

    score        = 0.0
    prev_action: Optional[int] = None
    last_conf:   float = 0.0
    graph_steps: int   = 0
    urm_steps:   int   = 0

    # Hash initial state for graph registration
    current_hash: Optional[int] = _hash_grid(_obs_to_grid(obs))

    for step_i in range(CFG.max_steps):
        result = agent.choose_action(
            frames=[obs],
            prev_action=prev_action,
            current_hash=current_hash,
        )

        obs, reward, done, truncated, _info = env.step(result.action)
        score       += float(reward)
        prev_action  = result.action
        last_conf    = result.confidence

        # Compute next state hash for graph transition registration
        next_hash: Optional[int] = _hash_grid(_obs_to_grid(obs))

        # v19: pass to_hash for graph edge registration
        agent.on_step(
            obs, result.action, float(reward), to_hash=next_hash
        )

        # v19: sync action space size after each step
        if hasattr(env, "action_space"):
            agent.update_action_space(len(env.action_space))

        # Track source breakdown for logging
        if result.source == "graph":
            graph_steps += 1
        else:
            urm_steps += 1

        current_hash = next_hash

        if done or truncated:
            # WIN detection: log minimal path length
            win_path = agent.explorer.extract_win_path()
            if win_path is not None:
                print(
                    f"  [{gid}] WIN at step={step_i+1} "
                    f"path_len={len(win_path)} "
                    f"graph={graph_steps} urm={urm_steps}"
                )
            else:
                print(
                    f"  [{gid}] done step={step_i+1} "
                    f"score={score:.4f} conf={last_conf:.4f} "
                    f"graph={graph_steps} urm={urm_steps}"
                )
            break
    else:
        print(
            f"  [{gid}] timeout score={score:.4f} "
            f"graph={graph_steps} urm={urm_steps}"
        )

    return score


def _write_submission(results: dict[str, float]) -> None:
    out_path = KAGGLE_WORKING / CFG.submission_file
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(results, indent=2))
    total = sum(results.values())
    print(f"[submission] written to {out_path} ({len(results)} games, total={total:.4f})")


# ─── Entry point ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    run_submission()
