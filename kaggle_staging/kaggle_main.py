"""
kaggle_main.py — ARC-AGI-3 Submission Orchestrator v79

v79 vs v78:
  - Strategy 5 fallback: uses agent.choose_action() correctly (not ad-hoc zeros)
  - _replay_explorer_solution: uses StepResult from step_adapter (unified .reward/.state)
  - step_fn in beam passes 5-tuple to smart_solve (obs,r,done,trunc,info)
  - All env.step() calls go through step_adapter.safe_step where possible
  - Import: step_adapter.is_win used everywhere instead of string hacks
"""
from __future__ import annotations
import sys, os, gc, subprocess, json, time
from pathlib import Path
from dataclasses import dataclass
from typing import Optional, List, Tuple
from collections import Counter

import torch
import numpy as np

KAGGLE_INPUT   = Path("/kaggle/input")
KAGGLE_WORKING = Path("/kaggle/working")
REPO_ROOT      = Path(__file__).resolve().parent

sys.path.insert(0, str(REPO_ROOT))
sys.path.insert(0, str(REPO_ROOT / "external"))
sys.path.insert(0, str(REPO_ROOT / "external" / "urm"))


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

    profiler_enabled:   bool = True
    strategy_cache_path: str = ""

    graph_budget:  int  = 8000
    graph_enabled: bool = True

    dense_budget:  int  = 6000
    dense_enabled: bool = True

    beam_width:    int   = 4
    beam_depth:    int   = 20
    mcts_sims:     int   = 150
    time_per_game: float = 90.0

    ttt_steps:   int   = 50
    ttt_lr:      float = 5e-4
    ttt_enabled: bool  = True

    traj_cache_path: str = ""


CFG = RunConfig()
print(f"[config] device={CFG.device} fp16={CFG.fp16}")
print(f"[config] graph={CFG.graph_enabled}/{CFG.graph_budget} "
      f"dense={CFG.dense_enabled}/{CFG.dense_budget}")
print(f"[config] beam w={CFG.beam_width} d={CFG.beam_depth} "
      f"mcts={CFG.mcts_sims} t={CFG.time_per_game}s")
print(f"[config] ttt={CFG.ttt_enabled} steps={CFG.ttt_steps}")

if torch.cuda.is_available():
    _props = torch.cuda.get_device_properties(0)
    _ngpu  = torch.cuda.device_count()
    print(f"[gpu] {torch.cuda.get_device_name(0)} "
          f"VRAM={_props.total_memory//1024**3}GB n_gpus={_ngpu}")
else:
    print("[gpu] CPU only")


def _install_arc_agi() -> None:
    wh  = KAGGLE_INPUT / "competitions" / "arc-prize-2026-arc-agi-3" / "arc_agi_3_wheels"
    cmd = [sys.executable, "-m", "pip", "install", "-q"]
    pkg = ["arc-agi", "python-dotenv"]
    subprocess.check_call(
        cmd + ["--no-index", f"--find-links={wh}"] + pkg
        if wh.is_dir() else cmd + pkg
    )
    print("[install] arc-agi ok")


def _load_traj_cache():
    try:
        from trajectory_cache import ProvenTrajectoryCache
        p = CFG.traj_cache_path or str(REPO_ROOT / "proven_trajectories.json")
        return ProvenTrajectoryCache.load(p)
    except Exception as e:
        print(f"[TrajCache] disabled: {e}")
        return None


def _load_strategy_cache():
    if not CFG.profiler_enabled:
        return None
    try:
        from game_profiler import StrategyCache
        p = CFG.strategy_cache_path or str(REPO_ROOT / "strategy_cache.json")
        return StrategyCache.from_file(p)
    except Exception as e:
        print(f"[StratCache] disabled: {e}")
        return None


def _get_action_list(env):
    """Get action list with 3-level fallback."""
    for attr in ("actions", "action_space"):
        try:
            raw  = getattr(env, attr)
            acts = list(raw.actions if hasattr(raw, "actions") else raw)
            if acts and hasattr(acts[0], "is_complex"):
                return acts
        except Exception:
            continue
    try:
        acts = list(env.action_space)
        if acts:
            return acts
    except Exception:
        pass
    print("[warn] could not get action_list")
    return []


def _replay_explorer_solution(env, solution, action_list):
    """Replay a solution from explorer. Uses step_adapter StepResult."""
    from step_adapter import safe_step, is_win
    env.reset()
    score = 0.0
    replay_actions: list = []
    for item in solution:
        if isinstance(item, (list, tuple)) and len(item) == 3:
            aidx, cx, cy = int(item[0]), int(item[1]), int(item[2])
        else:
            aidx, cx, cy = int(item), 32, 32
        if aidx >= len(action_list):
            break
        result = safe_step(env, action_list[aidx], cx, cy)
        if result is None:
            break
        score += result.reward
        replay_actions.append(aidx)
        if result.done or is_win(result):
            break
    return score, replay_actions


def _make_hasher():
    try:
        from wasm_bridge import canonical_hash
        return canonical_hash
    except Exception:
        return lambda g: hash(g.tobytes())


def _wrap_dataparallel(agent):
    if torch.cuda.device_count() >= 2 and torch.cuda.is_available():
        if not isinstance(agent.wm, torch.nn.DataParallel):
            agent.wm = torch.nn.DataParallel(agent.wm)
            print(f"[gpu] DataParallel on {torch.cuda.device_count()} GPUs")
    return agent


def run_submission() -> None:
    _install_arc_agi()
    import arc_agi as arc
    from submission_agent import VERICODINGAgent, AgentConfig

    cfg   = AgentConfig(
        n_actions=CFG.n_actions, hidden_size=CFG.hidden_size,
        device=CFG.device, fp16=False
    )
    agent = VERICODINGAgent(cfg)
    agent.wm.eval()
    for p in agent.wm.parameters():
        p.requires_grad = False

    agent = _wrap_dataparallel(agent)
    print("[run] agent ready")

    traj_cache     = _load_traj_cache()
    strategy_cache = _load_strategy_cache()
    game_ids       = arc.list_games()
    assert len(game_ids) > 0, "BUG: empty game list"
    print(f"[run] {len(game_ids)} games | "
          f"traj={len(traj_cache) if traj_cache else 0} | "
          f"strat={bool(strategy_cache)}")

    results:      dict = {}
    strategy_log: dict = {}

    for gid in game_ids:
        env  = arc.make(gid)
        score, strategy = _run_episode(
            agent, env, gid, traj_cache, strategy_cache
        )
        results[gid]      = score
        strategy_log[gid] = strategy
        if score > 0 and traj_cache is not None:
            traj_cache.save()
        if strategy_cache is not None:
            try:
                sp = CFG.strategy_cache_path or str(REPO_ROOT / "strategy_cache.json")
                strategy_cache.to_file(sp)
            except Exception:
                pass
        env.close()
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()

    _write_submission(results, strategy_log)


def _run_episode(
    agent, env, gid: str,
    traj_cache=None, strategy_cache=None
) -> Tuple[float, str]:
    from step_adapter import safe_step, is_win

    t_start  = time.time()
    agent_wm = agent.wm.module \
               if isinstance(agent.wm, torch.nn.DataParallel) \
               else agent.wm
    agent_wm.reset_carry()
    if hasattr(agent, "buf"):
        agent.buf.clear()
    obs, info = env.reset()

    # ── STRATEGY 0: Cache replay ─────────────────────────────────────────
    if traj_cache is not None:
        cached = traj_cache.try_replay(obs)
        if cached is not None:
            print(f"  [{gid}] CACHE HIT ({len(cached)} actions)")
            score = 0.0
            for action in cached:
                raw = env.step(action)
                r   = raw[1] if isinstance(raw, (tuple,list)) else float(getattr(raw,"reward",0))
                d   = raw[2] if isinstance(raw, (tuple,list)) else bool(getattr(raw,"done",False))
                t   = raw[3] if isinstance(raw, (tuple,list)) else bool(getattr(raw,"truncated",False))
                score += float(r)
                if d or t:
                    break
            return score, "cache"

    # ── STRATEGY 0.5: Profile game ───────────────────────────────────────
    prof = live_click_xy = None
    dead_actions   = set()
    active_actions = None

    if CFG.profiler_enabled:
        try:
            from game_profiler import (profile_game, choose_solver,
                                        compute_signature)
            prof          = profile_game(env)
            live_click_xy = prof.live_click_xy
            dead_actions  = set(prof.dead_actions)
            solver_rec    = choose_solver(prof, strategy_cache)
            print(f"  [{gid}] prof: n_act={prof.n_actions} "
                  f"live={live_click_xy} dead={len(dead_actions)} "
                  f"rw={bool(prof.repeated_win)} solver={solver_rec['name']}")

            # Strategy 1: repeated_win
            if prof.repeated_win:
                action_list = _get_action_list(env)
                if action_list:
                    env.reset()
                    for _ai in set(prof.repeated_win):
                        if _ai >= len(action_list):
                            continue
                        _a = action_list[_ai]
                        for _k in range(300):
                            _nf = safe_step(env, _a, 32, 32)
                            if _nf is None:
                                break
                            if is_win(_nf):
                                print(f"  [{gid}] REPEATED_WIN a={_ai} k={_k+1}")
                                if strategy_cache:
                                    strategy_cache.store(
                                        compute_signature(prof),
                                        "repeated_win", True, _k+1
                                    )
                                return float(_nf.reward), "repeated_win"

            action_list = _get_action_list(env)
            if action_list and dead_actions:
                ai = [i for i in range(len(action_list)) if i not in dead_actions]
                if ai:
                    active_actions = [action_list[i] for i in ai]
        except Exception as e:
            import traceback
            print(f"  [{gid}] profiler error: {e}\n{traceback.format_exc()}")

    # ── STRATEGY 2a: GraphExplorer ───────────────────────────────────────
    if CFG.graph_enabled:
        try:
            from graph_explorer import GraphExplorer
            from frame_processor import FrameProcessor
            al = active_actions or _get_action_list(env)
            if al:
                env.reset()
                ge    = GraphExplorer(
                    env=env, fp=FrameProcessor(),
                    hasher=_make_hasher(),
                    action_list=al,
                    live_click_xy=live_click_xy
                )
                found = ge.explore(max_steps=CFG.graph_budget)
                t_g   = time.time() - t_start
                if found and ge.solution:
                    sc, sa = _replay_explorer_solution(env, ge.solution, al)
                    print(f"  [{gid}] GRAPH sc={sc:.4f} "
                          f"steps={ge._total_steps} t={t_g:.1f}s")
                    if sc > 0:
                        if traj_cache is not None and sa:
                            io, _ = env.reset()
                            traj_cache.record(io, sa)
                        if strategy_cache and prof:
                            strategy_cache.store(
                                compute_signature(prof),
                                "graph_explore", True, len(sa)
                            )
                    return sc, "graph"
                print(f"  [{gid}] graph no-win "
                      f"({ge._total_steps}steps {t_g:.1f}s)")
        except Exception as e:
            import traceback
            print(f"  [{gid}] GraphExplorer error: {e}\n{traceback.format_exc()}")

    # ── STRATEGY 2b: DenseExplorer ───────────────────────────────────────
    if CFG.dense_enabled:
        try:
            from dense_explorer import DenseExplorer
            al = active_actions or _get_action_list(env)
            if al:
                env.reset()
                de    = DenseExplorer(env, al)
                found = de.explore(max_steps=CFG.dense_budget)
                t_d   = time.time() - t_start
                if found and de.solution:
                    sc, sa = _replay_explorer_solution(env, de.solution, al)
                    print(f"  [{gid}] DENSE sc={sc:.4f} "
                          f"steps={de._total_steps} t={t_d:.1f}s)")
                    if sc > 0:
                        if traj_cache is not None and sa:
                            io, _ = env.reset()
                            traj_cache.record(io, sa)
                        if strategy_cache and prof:
                            strategy_cache.store(
                                compute_signature(prof),
                                "dense_explore", True, len(sa)
                            )
                    return sc, "dense"
                print(f"  [{gid}] dense no-win "
                      f"({de._total_steps}steps {t_d:.1f}s)")
        except Exception as e:
            import traceback
            print(f"  [{gid}] DenseExplorer error: {e}\n{traceback.format_exc()}")

    # ── STRATEGY 3: Beam+MCTS ─────────────────────────────────────────────
    beam_score   = 0.0
    beam_actions: list = []
    obs_history:  list = []

    elapsed     = time.time() - t_start
    beam_budget = max(5.0, CFG.time_per_game - elapsed)

    try:
        from beam_search import smart_solve
        _buf = {"obs": obs}

        def _reset():
            o, _ = env.reset()
            _buf["obs"] = o
            obs_history.clear()
            return o

        def _step(action):
            # smart_solve expects 5-tuple: (obs,r,done,trunc,info)
            raw = env.step(action)
            if isinstance(raw, (tuple, list)) and len(raw) >= 4:
                o, r, d, t = raw[0], raw[1], raw[2], raw[3]
                i = raw[4] if len(raw) > 4 else {}
            else:
                o = getattr(raw, "obs",   getattr(raw, "observation", raw))
                r = float(getattr(raw, "reward", 0.0))
                d = bool(getattr(raw, "done", False))
                t = bool(getattr(raw, "truncated", False))
                i = {}
            _buf["obs"] = o
            obs_history.append(
                np.asarray(o, dtype=np.int32)
                if isinstance(o, (np.ndarray, list))
                else o
            )
            return o, r, d, t, i

        print(f"  [{gid}] beam "
              f"(w={CFG.beam_width} d={CFG.beam_depth} t={beam_budget:.0f}s)...")
        beam_score, beam_actions = smart_solve(
            env_reset_fn  = _reset,
            env_step_fn   = _step,
            n_actions     = CFG.n_actions,
            time_budget_s = beam_budget,
            beam_width    = CFG.beam_width,
            beam_depth    = CFG.beam_depth,
            mcts_sims     = CFG.mcts_sims,
        )
        print(f"  [{gid}] beam sc={beam_score:.4f} actions={len(beam_actions)}")
    except Exception as e:
        import traceback
        print(f"  [{gid}] beam error: {e}\n{traceback.format_exc()}")

    # ── STRATEGY 4: TTT on beam obs ───────────────────────────────────────
    if CFG.ttt_enabled and beam_actions:
        try:
            from ttt_submission import ttt_on_trajectory
            env.reset()
            ttt_obs: list = []
            ttt_rew: list = []
            for a in beam_actions:
                raw = env.step(a)
                if isinstance(raw, (tuple, list)) and len(raw) >= 4:
                    o, r, d, t = raw[0], raw[1], raw[2], raw[3]
                else:
                    o = getattr(raw, "obs", raw)
                    r = float(getattr(raw, "reward", 0.0))
                    d = bool(getattr(raw, "done", False))
                    t = bool(getattr(raw, "truncated", False))
                ttt_obs.append(
                    np.asarray(o, dtype=np.int32)
                    if isinstance(o, (np.ndarray, list)) else o
                )
                ttt_rew.append(float(r))
                if d or t:
                    break
            _real_agent = type("_A", (), {
                "wm": agent_wm
            })()
            ttt_on_trajectory(
                _real_agent, beam_actions, ttt_rew,
                obs_history=ttt_obs,
                steps=CFG.ttt_steps, lr=CFG.ttt_lr
            )
        except Exception as e:
            print(f"  [{gid}] TTT failed (non-fatal): {e}")

    if beam_score > 0 and beam_actions:
        if traj_cache is not None:
            io, _ = env.reset()
            traj_cache.record(io, beam_actions)
        return beam_score, "beam"

    # ── STRATEGY 5: Agent fallback (choose_action) ─────────────────────
    env.reset()
    agent_wm.reset_carry()
    if hasattr(agent, "buf"):
        agent.buf.clear()

    # Rebuild a minimal agent-like object pointing at the real (unwrapped) wm
    from submission_agent import VERICODINGAgent, AgentConfig
    _fallback_agent         = VERICODINGAgent(agent_wm.cfg)
    _fallback_agent.wm      = agent_wm
    _fallback_agent.wm.eval()

    fallback_score    = 0.0
    prev_action       = None
    fallback_actions: list = []
    last_obs_raw      = obs

    for _step_i in range(200):
        try:
            result = _fallback_agent.choose_action([last_obs_raw], prev_action)
        except Exception:
            result = type("AR", (), {"action": 0})()

        raw = env.step(result.action)
        if isinstance(raw, (tuple, list)) and len(raw) >= 4:
            last_obs_raw = raw[0]
            r = float(raw[1])
            d = bool(raw[2])
            t = bool(raw[3])
        else:
            last_obs_raw = getattr(raw, "obs", raw)
            r = float(getattr(raw, "reward", 0.0))
            d = bool(getattr(raw, "done", False))
            t = bool(getattr(raw, "truncated", False))

        fallback_score += r
        prev_action     = result.action
        fallback_actions.append(result.action)
        if d or t:
            break

    if fallback_score > 0 and traj_cache is not None and fallback_actions:
        io, _ = env.reset()
        traj_cache.record(io, fallback_actions)

    print(f"  [{gid}] fallback sc={fallback_score:.4f}")
    return fallback_score, "agent"


def _write_submission(results: dict, strategy_log=None) -> None:
    out = KAGGLE_WORKING / CFG.submission_file
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(results, indent=2))
    solved = sum(1 for v in results.values() if v > 0)
    mean   = sum(results.values()) / len(results) if results else 0.0
    print(f"[sub] {solved}/{len(results)} solved mean={mean:.4f} → {out}")
    if strategy_log:
        print(f"[strats] {dict(Counter(strategy_log.values()))}")


if __name__ == "__main__":
    run_submission()
