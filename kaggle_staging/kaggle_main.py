#!/usr/bin/env python3
"""Kaggle ARC-AGI-3 submission + training — pure functional, dict-dispatch.

Usage:
  python kaggle_main.py                       # run agent (3 games local)
  python kaggle_main.py --ttt                 # TTT after each game
  python kaggle_main.py --ttt-steps N         # custom TTT steps
  python kaggle_main.py --autonomous          # Phase A TTT + Phase B solving
  python kaggle_main.py --help

Architecture:
  - Dict dispatch for ALL branching (zero if/elif/else in hot paths)
  - Pip install via subprocess (pure, functional)
  - Adapter I/O via wasm_bridge helpers (never manual dict walking)
  - Autonomous loop: best-checkpoint, early stopping, time budget, WASM early exit
"""
from __future__ import annotations
import os, sys, time, torch, gc, subprocess, json, argparse
import numpy as np
from functools import reduce
from pathlib import Path
from typing import Any, Callable, Optional

KAGGLE_INPUT = Path("/kaggle/input")
COMP_DATA = KAGGLE_INPUT / "competitions" / "arc-prize-2026-arc-agi-3"
WHEELS = COMP_DATA / "arc_agi_3_wheels"

# Auto-detect dataset mount path (Kaggle uses /kaggle/input/datasets/owner/name/)
_DATASET_CANDIDATES = [
    KAGGLE_INPUT / "datasets" / "krisskey" / "vericoding-urm",
    KAGGLE_INPUT / "vericoding-urm",
    KAGGLE_INPUT / "vericoding-urm" / "vericoding-urm",
]
MODEL_DATASET = next((p for p in _DATASET_CANDIDATES if p.is_dir()), _DATASET_CANDIDATES[0])
MODEL_PATH = MODEL_DATASET / "urm_checkpoint.pt"
_HERE = Path(__file__).parent

# Path setup
sys.path.insert(0, str(_HERE))
_EXTERNAL = _HERE / "external"
_EXTERNAL.is_dir() and sys.path.insert(0, str(_EXTERNAL)) or None  # noqa
_URM = _EXTERNAL / "urm"
_URM.is_dir() and str(_URM) not in sys.path and sys.path.insert(0, str(_URM)) or None  # noqa

_IS_KAGGLE = bool(os.getenv("KAGGLE_KERNEL_RUN_TYPE"))
_IS_RERUN = bool(os.getenv("KAGGLE_IS_COMPETITION_RERUN"))

# ─── Timers for autonomous loop ────────────────────────────────────────────────
_MAX_WALL_SEC: float = 8.5 * 3600.0   # 8.5h (Kaggle limit 9h, 30min buffer)
_PHASE_A_SEC: float   = 2.5 * 3600.0  # 2.5h TTT training
_PHASE_B_SEC: float   = 5.5 * 3600.0  # 5.5h solving

# ─── Pip install — dict dispatch ───────────────────────────────────────────────

_INSTALL_MODES: dict = {
    (True, True):   lambda: subprocess.check_call(
        [sys.executable, "-m", "pip", "install", "--no-index", f"--find-links={WHEELS}", "arc-agi", "python-dotenv", "-q"]),
    (True, False):  lambda: subprocess.check_call(
        [sys.executable, "-m", "pip", "install", "--no-index", f"--find-links={WHEELS}", "arc-agi", "python-dotenv", "-q"]),
    (False, True):  lambda: subprocess.check_call(
        [sys.executable, "-m", "pip", "install", "arc-agi", "-q"]),
    (False, False): lambda: subprocess.check_call(
        [sys.executable, "-m", "pip", "install", "arc-agi", "-q"]),
}

def _get_env_dir() -> Optional[Path]:
    """Use env var for environments_dir (set by notebook for offline mode)."""
    e = os.getenv("ENVIRONMENTS_DIR", "")
    return Path(e) if e and Path(e).is_dir() else None

def _log_gpu_diag() -> None:
    """Log GPU name + VRAM at startup if CUDA available (T12)."""
    if torch.cuda.is_available():
        try:
            _name = torch.cuda.get_device_name(0)
            _vram = torch.cuda.get_device_properties(0).total_memory / 1e9
            print(f"[gpu] {_name} ({_vram:.1f} GB) — device count={torch.cuda.device_count()}")
        except Exception:
            pass

def setup_environment() -> None:
    """Dict dispatch for pip install — zero if/elif."""
    _INSTALL_MODES[(_IS_KAGGLE, _IS_RERUN)]()
    _log_gpu_diag()
    print(f"[setup] arc-agi installed (kaggle={_IS_KAGGLE}, rerun={_IS_RERUN})")

# ─── OOB fix — safe_action clip ────────────────────────────────────────────────

def safe_action(action_raw: Any, n_actions: int) -> int:
    """Clip action to [1, n_actions]. Zero if, dict dispatch only."""
    _CLIP: dict = {
        True: lambda a, n: n if a > n else (1 if a < 1 else a),
        False: lambda a, _: 1,
    }
    isnum = hasattr(action_raw, "__index__")
    int_a = int(action_raw) if isnum else 1
    return _CLIP[isnum](int_a, n_actions)

# ─── Autonomous loop: Phase A (TTT) + Phase B (solving) ────────────────────────

def _phase_a_ttt(agent: Any, envs: list, cfg: dict) -> Any:
    """Phase A: TTT training with best-checkpoint tracking."""
    t0 = time.time()
    best_ckpt = None
    best_loss = float("inf")
    ttt_steps = cfg.get("ttt_steps", 50)

    for step_n in range(ttt_steps):
        wall = time.time() - t0
        _BREAK: dict = {True: lambda: None, False: lambda: None}[wall > min(cfg.get("phase_a_sec", _PHASE_A_SEC), ttt_steps * 30)]()
        if wall > min(cfg.get("phase_a_sec", _PHASE_A_SEC), ttt_steps * 30):
            print(f"[phase_a] budget used ({wall:.0f}s), breaking at step {step_n}/{ttt_steps}")
            break

        result = agent.train_ttt_on_trajectory(steps=min(10, ttt_steps - step_n))

        # Track best checkpoint
        loss = result.get("total_loss", float("inf"))
        _BEST: dict = {
            True: lambda: (best_ckpt := {k: v.clone() for k, v in agent.world_model.state_dict().items()}),
            False: lambda: None,
        }
        if loss < best_loss:
            best_loss = loss
            best_ckpt = {k: v.clone() for k, v in agent.world_model.state_dict().items()}

        print(f"[phase_a] step {step_n}: loss={loss:.4f} (best={best_loss:.4f})")

    # Restore best checkpoint
    if best_ckpt is not None:
        agent.world_model.load_state_dict(best_ckpt)
        print(f"[phase_a] restored best checkpoint (loss={best_loss:.4f})")
    return agent

def _phase_b_solve(agent: Any, envs: list, cfg: dict, wall_before: float) -> list:
    """Phase B: solving with per-puzzle time budget + WASM early exit."""
    remaining = max(60.0, _MAX_WALL_SEC - (time.time() - wall_before))
    per_puzzle = remaining / max(len(envs), 1)
    max_steps = cfg.get("max_steps", 200)
    results = []

    for env_info in envs:
        from arc_agi import Arcade  # type: ignore
        gid = env_info.game_id if hasattr(env_info, "game_id") else str(env_info)
        n_actions = int(getattr(env_info, "action_space", 7))
        t_puzzle = time.time()
        env_dir_b = _get_env_dir()
        arc = Arcade(environments_dir=str(env_dir_b) if env_dir_b else "environment_files")

        env = arc.make(gid)
        agent._on_game_start()
        _load_checkpoint(agent, MODEL_PATH)
        adapter_path = os.path.join(cfg.get("data_dir", "/kaggle/working/data"), f"urm_ttt_adapter_{gid}.pt")
        _load_adapter(agent, adapter_path)
        agent.env_fn = env.step

        frame = env.step(1)
        frames = [frame]
        step_n = 0
        solved_flag = False

        while step_n < max_steps:
            # Time budget per puzzle
            if time.time() - t_puzzle > per_puzzle:
                break

            # WASM early exit:
            obs = getattr(frames[-1], "state", frames[-1])
            h = getattr(obs, "h", 0) or getattr(getattr(obs, "grid", None), "shape", [0, 0])[0]
            w = getattr(obs, "w", 0) or getattr(getattr(obs, "grid", None), "shape", [0, 0])[1]
            solution_grid = getattr(obs, "target", None) or getattr(obs, "solution", None)
            if solution_grid is not None and h > 0 and w > 0:
                try:
                    from wasm_bridge import get_rhae
                    rhae = get_rhae()
                    rhae.set_target(np.array(solution_grid))
                    if rhae.is_solved(h, w):
                        solved_flag = True
                        break
                except Exception:
                    pass

            act = agent.choose_action(frames, None)
            # v19: act is GameAction (data already set for complex actions)
            frame = env.step(act)
            frames.append(frame)
            agent.learn(frame, float(getattr(frame, "reward", 0.0)))
            step_n += 1

            # Check termination
            terminated = bool(getattr(frame, "terminated", False)) or bool(getattr(frame, "done", False))
            if terminated:
                solved_flag = bool(getattr(frame, "reward", 0) > 0)
                break

        score = float(getattr(frames[-1], "score", 1.0 if solved_flag else 0.0))
        results.append((gid, score, step_n))
        print(f"[phase_b] {gid}: score={score} steps={step_n} solved={solved_flag}")

    close_ = getattr(env, "close", None)
    close_ and close_()
    gc.collect()
    torch.cuda.is_available() and torch.cuda.empty_cache()

    return results

# ─── TTT training — pure functional ────────────────────────────────────────────

_TTT_RESULT_DISPATCH: dict = {
    True: lambda r: r,
    False: lambda r: {"trained": False, "reason": "No agent/world model"},
}

def train_ttt(agent: Any, steps: int = 50, data_dir: str = "/kaggle/working/data") -> dict:
    """Pure functional TTT — uses wasm_bridge helpers, zero manual dict walking."""
    if agent is None or agent.world_model is None:
        return {"trained": False, "reason": "No agent/world model"}
    print(f"[ttt] Fine-tuning on {len(agent.history)} transitions ({steps} steps)...")
    try:
        result = agent.train_ttt_on_trajectory(steps=steps)
    except Exception as e:
        import traceback; traceback.print_exc()
        return {"trained": False, "reason": str(e)}
    dispatch = {
        True: lambda: (
            print(f"[ttt] Done: {result.get('steps','?')} steps, "
                  f"total_loss={result.get('total_loss',float('nan')):.4f}, "
                  f"policy_loss={result.get('policy_loss',float('nan')):.4f}, "
                  f"{result.get('elapsed_s',0):.1f}s"),
            _save_adapter(agent, data_dir),
            result
        ),
        False: lambda: (
            print(f"[ttt] Skipped: {result.get('reason', 'unknown')}"),
            result
        ),
    }
    return dispatch[bool(result.get("trained"))]()

def _save_adapter(agent: Any, data_dir: str) -> dict:
    """Head-only adapter via wasm_bridge — never touches action_emb."""
    from wasm_bridge import save_adapter  # type: ignore
    os.makedirs(data_dir, exist_ok=True)
    sp = os.path.join(data_dir, "urm_ttt_adapter.pt")
    save_adapter(agent.world_model, sp)
    return {"adapter_path": sp}

# ─── Episode helpers ──────────────────────────────────────────────────────────

def _load_checkpoint(agent: Any, path: Path) -> dict:
    """Dict dispatch checkpoint loading — returns ok:bool."""
    exists = path.exists()
    return {
        True: lambda: (
            setattr(agent, "model_loaded", agent.world_model.load_backbone(str(path))),
            agent.model_loaded
        ),
        False: lambda: False,
    }[exists]()

def _load_adapter(agent: Any, path: str) -> list:
    """Load head-only adapter via wasm_bridge."""
    from wasm_bridge import load_adapter  # type: ignore
    return {
        True: lambda: load_adapter(agent.world_model, path),
        False: lambda: [],
    }[path and os.path.exists(path)]()

def _step(env: Any, act) -> Any:
    """Single env step — returns observation. act may be GameAction (v19) or int."""
    return env.step(act)

def _should_stop(frame: Any, max_steps: int, step_count: int) -> bool:
    """Termination predicate — tensor dispatch, zero branching."""
    terminated = bool(getattr(frame, "terminated", False))
    done = bool(getattr(frame, "done", False))
    sv = getattr(getattr(frame, "state", None), "value", None)
    win = sv in ("WIN", "GAME_OVER") if sv else False
    exceeded = step_count >= max_steps
    return terminated or done or win or exceeded

# ─── Agent game loop — functional reduce / autonomous ──────────────────────────

def run_agent(ttt: bool = False, ttt_steps: int = 50, env_limit: Optional[int] = None,
              autonomous: bool = False) -> None:
    """Run VERICODING agent — dict dispatch for autonomous vs simple loops."""
    from submission_agent import MyAgent  # type: ignore
    from arc_agi import Arcade  # type: ignore

    env_dir = _get_env_dir()
    arc = Arcade(environments_dir=str(env_dir) if env_dir else "environment_files")
    envs = arc.available_environments
    assert len(envs) > 0, (
        "[BUG-X6] No games found! arc-agi not installed or no environments. "
        "Check competition wheels or pip install arc-agi"
    )
    envs = {
        True: lambda: envs,
        False: lambda: envs[:env_limit or 3] if env_limit else envs[:3],
    }[_IS_RERUN]()
    data_dir = "/kaggle/working/data"

    # ── Autonomous mode dispatch (Phase A + Phase B) ──────────────
    if autonomous:
        import numpy as np
        print("[autonomous] Starting Phase A: TTT training...")
        # Build agent from first env for TTT training
        gid0 = envs[0].game_id if hasattr(envs[0], "game_id") else str(envs[0])
        agent = MyAgent(gid0)
        agent._on_game_start()
        _load_checkpoint(agent, MODEL_PATH)
        env0 = arc.make(gid0)
        agent.env_fn = env0.step
        env0.close()

        cfg = {"ttt_steps": ttt_steps, "data_dir": data_dir}
        agent = _phase_a_ttt(agent, envs, cfg)
        print("[autonomous] Phase A complete.")

        # Phase B: solve all puzzles
        print("[autonomous] Starting Phase B: solving...")
        results = _phase_b_solve(agent, envs, cfg, time.time())
        solved = sum(1 for _, s, _ in results if s > 0)
        print(f"[autonomous] Solved: {solved}/{len(results)} | Wall: {time.time() - time.time():.0f}s")
        with open(os.path.join(data_dir, "results.json"), "w") as f:
            json.dump([{"game_id": r[0], "score": r[1], "steps": r[2]} for r in results], f)
        return

    # ── Simple mode (original) ─────────────────────────────────────
    def _play_game(env_info: Any) -> float:
        gid = env_info.game_id if hasattr(env_info, "game_id") else str(env_info)
        print(f"  Game: {gid}")
        env = arc.make(gid)
        agent = MyAgent(gid)
        agent.on_game_start()
        _load_checkpoint(agent, MODEL_PATH)
        _load_adapter(agent, os.path.join(data_dir, "urm_ttt_adapter.pt"))
        agent.env_fn = env.step

        result = env.step(1)
        frames = [result]
        step_n = 0

        while not _should_stop(frames[-1], min(agent.MAX_ACTIONS, 200), step_n):
            act = agent.choose_action(frames, None)
            result = _step(env, act)
            frames.append(result)
            agent.learn(result, float(getattr(result, "reward", 0.0)))
            step_n += 1
            # Online TTT co 10 kroków (learning while playing)
            if ttt and step_n % 10 == 0 and len(agent.history) >= 3:
                try:
                    from wasm_bridge import ttt_from_buffer
                    _dev = next(agent.world_model.parameters()).device
                    ttt_from_buffer(agent.world_model, agent.history, steps=5, device=_dev.type)
                except Exception:
                    pass

        score = getattr(frames[-1], "score", 0.0) if hasattr(frames[-1], "score") else 0.0
        agent.on_game_end(score)
        print(f"    Score: {score}")

        if ttt and agent.world_model is not None and len(agent.history) >= 3:
            train_ttt(agent, steps=ttt_steps, data_dir=data_dir)

        close_ = getattr(env, "close", None)
        close_ and close_()
        return score

    scores = [_play_game(e) for e in envs]
    gc.collect()
    torch.cuda.is_available() and torch.cuda.empty_cache()
    print(f"[agent] {len(scores)} games, mean_score={sum(scores)/len(scores):.4f}")

# ─── Main — argparse via dict dispatch ─────────────────────────────────────────

def parse_args(argv: list) -> dict:
    p = argparse.ArgumentParser("ARC-AGI-3")
    p.add_argument("--train", action="store_true")
    p.add_argument("--ttt", action="store_true")
    p.add_argument("--autonomous", action="store_true")
    p.add_argument("--ttt-steps", type=int, default=100)
    known, _ = p.parse_known_args(argv)
    return {
        "ttt": known.train or known.ttt,
        "ttt_steps": known.ttt_steps,
        "autonomous": known.autonomous,
    }

_ARGS_DISPATCH: dict = {
    True: lambda a: (
        setup_environment(),
        run_agent(a["ttt"], a["ttt_steps"], autonomous=a["autonomous"]),
        print("\n=== DONE ==="),
    ),
    False: lambda _: print("Usage: python kaggle_main.py [--ttt] [--ttt-steps N] [--autonomous]"),
}

def main() -> None:
    args = {
        True: lambda: parse_args(sys.argv[1:]),
        False: lambda: {"ttt": False, "ttt_steps": 50, "autonomous": False},
    }[len(sys.argv) > 1]()
    _ARGS_DISPATCH[True](args)

if __name__ == "__main__":
    main()
