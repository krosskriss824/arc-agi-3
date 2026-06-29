"""
kaggle_main.py v79 — ARC-AGI-3 Submission Orchestrator

v79 CHANGES:
  - step_adapter.py StepResult used throughout (tuple + object API)
  - main = run_submission alias (notebook compat)
  - Strategy 5 fallback: argmax fix + proper action_list usage
  - TTT Strategy 4: runs on beam_actions obs_history
  - _beam_step: returns proper 5-tuple using _normalise
  - _replay_explorer_solution: uses safe_step/get_reward/is_win

Strategy order:
  0.   Cache replay (TrajectoryCache)
  0.5  Profile game (GameProfile)
  1.   Repeated-win
  2a.  GraphExplorer (BFS)
  2b.  DenseExplorer (4-phase)
  3.   Beam+MCTS (w=4, d=20, 150 sims)
  4.   TTT on beam obs
  5.   Agent fallback
"""
from __future__ import annotations
import sys, os, gc, subprocess, json, time
from pathlib import Path
from dataclasses import dataclass
from typing import Optional, Tuple
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

    profiler_enabled:    bool = True
    strategy_cache_path: str  = ""

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
print(f"[cfg] device={CFG.device} fp16={CFG.fp16}")
print(f"[cfg] graph={CFG.graph_enabled}/{CFG.graph_budget} dense={CFG.dense_enabled}/{CFG.dense_budget}")
print(f"[cfg] beam w={CFG.beam_width} d={CFG.beam_depth} mcts={CFG.mcts_sims} t={CFG.time_per_game}s")
print(f"[cfg] ttt={CFG.ttt_enabled} steps={CFG.ttt_steps}")

if torch.cuda.is_available():
    _props = torch.cuda.get_device_properties(0)
    print(f"[gpu] {torch.cuda.get_device_name(0)} VRAM={_props.total_memory//1024**3}GB n={torch.cuda.device_count()}")
else:
    print("[gpu] CPU only")


def _install_arc_agi() -> None:
    wh  = KAGGLE_INPUT / "competitions" / "arc-prize-2026-arc-agi-3" / "arc_agi_3_wheels"
    cmd = [sys.executable, "-m", "pip", "install", "-q"]
    pkg = ["arc-agi", "python-dotenv"]
    try:
        subprocess.check_call(
            cmd + ["--no-index", f"--find-links={wh}"] + pkg
            if wh.is_dir() else cmd + pkg
        )
        print("[install] arc-agi ok")
    except Exception as e:
        print(f"[install] warning: {e}")


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
    for attr in ("actions", "action_space"):
        try:
            raw  = getattr(env, attr)
            acts = list(raw.actions if hasattr(raw, "actions") else raw)
            if acts: return acts
        except Exception:
            continue
    try:
        acts = list(env.action_space)
        if acts: return acts
    except Exception:
        pass
    print("[warn] could not get action_list")
    return []


def _replay_explorer_solution(env, solution, action_list):
    from step_adapter import safe_step, is_win, get_reward
    env.reset()
    score = 0.0
    replay_actions: list[int] = []
    for item in solution:
        if isinstance(item, (list, tuple)) and len(item) == 3:
            aidx, cx, cy = int(item[0]), int(item[1]), int(item[2])
        else:
            aidx, cx, cy = int(item), 32, 32
        if aidx >= len(action_list): break
        result = safe_step(env, action_list[aidx], cx, cy)
        if result is None: break
        score += get_reward(result)
        replay_actions.append(aidx)
        if is_win(result): break
    return score, replay_actions


def _make_hasher():
    try:
        from wasm_bridge import canonical_hash
        return canonical_hash
    except Exception:
        return lambda g: hash(np.asarray(g, dtype=np.int32).tobytes())


def _wrap_dataparallel(agent):
    if torch.cuda.device_count() >= 2:
        if not isinstance(agent.wm, torch.nn.DataParallel):
            agent.wm = torch.nn.DataParallel(agent.wm)
            print(f"[gpu] DataParallel on {torch.cuda.device_count()} GPUs")
    return agent


def run_submission() -> None:
    _install_arc_agi()
    import arc_agi as arc
    from submission_agent import VERICODINGAgent, AgentConfig

    cfg   = AgentConfig(n_actions=CFG.n_actions, hidden_size=CFG.hidden_size,
                        device=CFG.device, fp16=False)
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
    print(f"[run] {len(game_ids)} games | traj={len(traj_cache) if traj_cache else 0}")

    results:      dict[str, float] = {}
    strategy_log: dict[str, str]   = {}

    for gid in game_ids:
        env  = arc.make(gid)
        score, strategy = _run_episode(agent, env, gid, traj_cache, strategy_cache)
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


# Alias — for notebook compatibility: from kaggle_main import main
main = run_submission


def _run_episode(agent, env, gid: str,
                traj_cache=None, strategy_cache=None) -> Tuple[float, str]:
    from step_adapter import safe_step, is_win, get_reward, get_obs, _normalise
    t_start  = time.time()
    agent_wm = agent.wm.module if isinstance(agent.wm, torch.nn.DataParallel) else agent.wm
    agent_wm.reset_carry()
    if hasattr(agent, 'buf'): agent.buf.clear()
    obs, info = env.reset()

    # ── STRATEGY 0: Cache replay ──────────────────────────────────────────
    if traj_cache is not None:
        cached = traj_cache.try_replay(obs)
        if cached is not None:
            print(f"  [{gid}] CACHE HIT ({len(cached)} actions)")
            score = 0.0
            for action in cached:
                r = _normalise(env.step(action))
                if r:
                    score += r.reward
                    if r.done or r.truncated: break
            return score, "cache"

    # ── STRATEGY 0.5: Profile ─────────────────────────────────────────────
    prof = live_click_xy = None
    dead_actions   = set()
    active_actions = None

    if CFG.profiler_enabled:
        try:
            from game_profiler import profile_game, choose_solver, compute_signature
            prof          = profile_game(env)
            live_click_xy = prof.live_click_xy
            dead_actions  = set(prof.dead_actions)
            solver_rec    = choose_solver(prof, strategy_cache)
            print(f"  [{gid}] prof n_act={prof.n_actions} live={live_click_xy} "
                  f"dead={len(dead_actions)} solver={solver_rec['name']}")

            # Strategy 1: repeated_win
            if prof.repeated_win:
                action_list = _get_action_list(env)
                if action_list:
                    env.reset()
                    for _ai in set(prof.repeated_win):
                        if _ai >= len(action_list): continue
                        _a = action_list[_ai]
                        for _k in range(300):
                            _f = safe_step(env, _a, 32, 32)
                            if _f is None: break
                            if is_win(_f):
                                print(f"  [{gid}] REPEATED_WIN a={_ai} k={_k+1}")
                                if strategy_cache:
                                    strategy_cache.store(compute_signature(prof),
                                                        "repeated_win", True, _k+1)
                                return float(get_reward(_f)), "repeated_win"

            action_list = _get_action_list(env)
            if action_list and dead_actions:
                ai = [i for i in range(len(action_list)) if i not in dead_actions]
                if ai: active_actions = [action_list[i] for i in ai]
        except Exception as e:
            import traceback
            print(f"  [{gid}] profiler error: {e}\n{traceback.format_exc()}")

    # ── STRATEGY 2a: GraphExplorer ────────────────────────────────────────
    if CFG.graph_enabled:
        try:
            from graph_explorer import GraphExplorer
            from frame_processor import FrameProcessor
            al = active_actions or _get_action_list(env)
            if al:
                env.reset()
                ge = GraphExplorer(env=env, fp=FrameProcessor(), hasher=_make_hasher(),
                                   action_list=al, live_click_xy=live_click_xy)
                found = ge.explore(max_steps=CFG.graph_budget)
                if found and ge.solution:
                    sc, sa = _replay_explorer_solution(env, ge.solution, al)
                    print(f"  [{gid}] GRAPH sc={sc:.4f} steps={ge._total_steps}")
                    if sc > 0:
                        if traj_cache is not None and sa:
                            io, _ = env.reset(); traj_cache.record(io, sa)
                        if strategy_cache and prof:
                            strategy_cache.store(compute_signature(prof),
                                                "graph_explore", True, len(sa))
                    return sc, "graph"
                print(f"  [{gid}] graph no-win ({ge._total_steps}steps)")
        except Exception as e:
            import traceback
            print(f"  [{gid}] GraphExplorer error: {e}\n{traceback.format_exc()}")

    # ── STRATEGY 2b: DenseExplorer ────────────────────────────────────────
    if CFG.dense_enabled:
        try:
            from dense_explorer import DenseExplorer
            al = active_actions or _get_action_list(env)
            if al:
                env.reset()
                de = DenseExplorer(env, al)
                found = de.explore(max_steps=CFG.dense_budget)
                if found and de.solution:
                    sc, sa = _replay_explorer_solution(env, de.solution, al)
                    print(f"  [{gid}] DENSE sc={sc:.4f} steps={de._total_steps}")
                    if sc > 0:
                        if traj_cache is not None and sa:
                            io, _ = env.reset(); traj_cache.record(io, sa)
                        if strategy_cache and prof:
                            strategy_cache.store(compute_signature(prof),
                                                "dense_explore", True, len(sa))
                    return sc, "dense"
                print(f"  [{gid}] dense no-win ({de._total_steps}steps)")
        except Exception as e:
            import traceback
            print(f"  [{gid}] DenseExplorer error: {e}\n{traceback.format_exc()}")

    # ── STRATEGY 3: Beam+MCTS ─────────────────────────────────────────────
    beam_score   = 0.0
    beam_actions: list[int] = []
    obs_history:  list      = []
    elapsed      = time.time() - t_start
    beam_budget  = max(5.0, CFG.time_per_game - elapsed)

    try:
        from beam_search import smart_solve
        _step_obs = {"last": obs}

        def _beam_reset():
            o, _ = env.reset()
            _step_obs["last"] = o
            obs_history.clear()
            return o

        def _beam_step(action):
            """5-tuple step for beam_search.py contract."""
            r = _normalise(env.step(action))
            if r is None:
                return _step_obs["last"], 0.0, False, False, {}
            _step_obs["last"] = r.obs
            g = get_obs(r)
            if g is not None:
                obs_history.append(g.astype(np.int32))
            return r.obs, r.reward, r.done, r.truncated, {}

        print(f"  [{gid}] beam (w={CFG.beam_width} d={CFG.beam_depth} t={beam_budget:.0f}s)")
        beam_score, beam_actions = smart_solve(
            env_reset_fn  = _beam_reset,
            env_step_fn   = _beam_step,
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

    # ── STRATEGY 4: TTT ───────────────────────────────────────────────────
    if CFG.ttt_enabled and beam_actions:
        try:
            from ttt_submission import ttt_on_trajectory
            env.reset()
            ttt_obs: list = []
            ttt_rew: list = []
            for a in beam_actions:
                r = _normalise(env.step(a))
                if r is None: break
                g = get_obs(r)
                if g is not None: ttt_obs.append(g)
                ttt_rew.append(r.reward)
                if r.done or r.truncated: break
            _wm = agent.wm.module if isinstance(agent.wm, torch.nn.DataParallel) else agent.wm
            _a  = type('_A', (), {'wm': _wm})()
            ttt_on_trajectory(_a, beam_actions, ttt_rew,
                              obs_history=ttt_obs,
                              steps=CFG.ttt_steps, lr=CFG.ttt_lr)
        except Exception as e:
            print(f"  [{gid}] TTT failed (non-fatal): {e}")

    if beam_score > 0 and beam_actions:
        if traj_cache is not None:
            io, _ = env.reset(); traj_cache.record(io, beam_actions)
        return beam_score, "beam"

    # ── STRATEGY 5: Agent fallback ────────────────────────────────────────
    env.reset()
    agent_wm.reset_carry()
    fallback_score    = 0.0
    fallback_actions: list[int] = []
    al = _get_action_list(env)
    if not al:
        return 0.0, "no_actions"

    for step in range(200):
        try:
            dev = next(agent_wm.parameters()).device
            st  = torch.zeros(1, 1, dtype=torch.long, device=dev)
            out = agent_wm(st)
            logits     = out.get("action_logits", out.get("logits"))
            action_idx = int(logits[0, -1].argmax().item()) % len(al)
        except Exception:
            action_idx = step % len(al)

        r = _normalise(env.step(al[action_idx]))
        if r is None: break
        fallback_score += r.reward
        fallback_actions.append(action_idx)
        if r.done or r.truncated: break

    if fallback_score > 0 and traj_cache is not None and fallback_actions:
        io, _ = env.reset(); traj_cache.record(io, fallback_actions)

    print(f"  [{gid}] fallback sc={fallback_score:.4f}")
    return fallback_score, "agent"


def _write_submission(results: dict[str, float], strategy_log=None) -> None:
    out = KAGGLE_WORKING / CFG.submission_file
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(results, indent=2))
    solved = sum(1 for v in results.values() if v > 0)
    mean   = sum(results.values()) / len(results) if results else 0.0
    print(f"[sub] {solved}/{len(results)} solved mean={mean:.4f} -> {out}")
    if strategy_log:
        print(f"[strats] {dict(Counter(strategy_log.values()))}")


if __name__ == "__main__":
    run_submission()
