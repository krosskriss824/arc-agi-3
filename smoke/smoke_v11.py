"""
smoke_v11.py — ARC-AGI-3 Smoke Test Harness
SOTA refactor v11: 4 isolated test contracts, no manual .to(device),
no torch.cuda.empty_cache() in loops, pure assertion-based pass/fail.

Tests:
  smoke_cpu_mini        — Phase1 device discipline (CPU, 3 envs, no backbone)
  smoke_adapter         — Phase2 head-only adapter round-trip
  smoke_ttt_isolated    — Phase3 functional TTT on fake tensors (CUDA/CPU)
  smoke_cuda_full       — Phase4 end-to-end 20 envs full pipeline

Run: python smoke/smoke_v11.py
"""
from __future__ import annotations
import sys
import os
import gc
import subprocess
from pathlib import Path
from dataclasses import dataclass
from typing import Callable

import torch
import numpy as np

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "kaggle_staging"))
sys.path.insert(0, str(ROOT / "external"))

DEVICE     = "cuda" if torch.cuda.is_available() else "cpu"
CHECKPOINT = ROOT / "kaggle_staging" / "urm_checkpoint.pt"
INPUT      = Path("/kaggle/input")


# ─── arc-agi install ──────────────────────────────────────────────────────────

def _install_arc_agi() -> None:
    wh  = INPUT / "competitions" / "arc-prize-2026-arc-agi-3" / "arc_agi_3_wheels"
    cmd = [sys.executable, "-m", "pip", "install", "-q"]
    cmd += (["--no-index", f"--find-links={wh}", "arc-agi", "python-dotenv"]
            if wh.is_dir() else ["arc-agi", "python-dotenv"])
    subprocess.check_call(cmd)


# ─── Test result type ─────────────────────────────────────────────────────────

@dataclass
class TestResult:
    name:    str
    passed:  bool
    detail:  str = ""

    def __str__(self) -> str:
        status = "PASS" if self.passed else "FAIL"
        return f"  [{status}] {self.name}" + (f" — {self.detail}" if self.detail else "")


# ─── Test 1: CPU mini — Phase1 device discipline ─────────────────────────────

def smoke_cpu_mini() -> TestResult:
    """
    3 envs, CPU, no backbone load.
    Validates device discipline without CUDA dependency.
    If wrapper_CUDA__index_select fires here → Phase1 not complete.
    """
    import arc_agi as arc
    from submission_agent import VERICODINGAgent, AgentConfig

    cfg   = AgentConfig(n_actions=7, hidden_size=512, device="cpu")
    agent = VERICODINGAgent(cfg)
    agent.wm.eval()

    gids  = list(arc.list_games())[:3]
    for gid in gids:
        env = arc.make(gid)
        agent.on_game_start()
        obs, _ = env.reset()
        for _ in range(10):
            result = agent.choose_action([obs], None)
            obs, _, done, trunc, _ = env.step(result.action)
            if done or trunc:
                break
        env.close()

    del agent
    gc.collect()
    return TestResult("smoke_cpu_mini", True, f"{len(gids)} envs passed")


# ─── Test 2: Adapter round-trip — Phase2 head-only ───────────────────────────

def smoke_adapter() -> TestResult:
    """
    save_adapter → load_adapter on different n_actions model.
    Asserts: action_emb absent, action_head + value_head present.
    """
    import tempfile
    from submission_agent import URMWMA, AgentConfig
    from wasm_bridge import save_adapter, load_adapter, extract_head_params

    cfg1 = AgentConfig(n_actions=7,  hidden_size=512, device=DEVICE)
    cfg2 = AgentConfig(n_actions=11, hidden_size=512, device=DEVICE)  # different n_actions
    wm1  = URMWMA(cfg1).to(DEVICE)
    wm2  = URMWMA(cfg2).to(DEVICE)

    with tempfile.NamedTemporaryFile(suffix=".pt", delete=False) as f:
        tmp = f.name

    save_adapter(wm1, tmp)
    loaded = torch.load(tmp, map_location="cpu", weights_only=True)

    # Invariant assertions
    bad_emb = [k for k in loaded if "action_emb" in k]
    assert not bad_emb, f"action_emb in adapter: {bad_emb}"
    assert any("action_head" in k for k in loaded), "action_head missing"
    assert any("value_head"  in k for k in loaded), "value_head missing"

    # Load into different n_actions model — must not raise
    keys = load_adapter(wm2, tmp)
    os.unlink(tmp)

    return TestResult("smoke_adapter", True, f"keys={keys}")


# ─── Test 3: TTT isolated — Phase3 functional ────────────────────────────────

def smoke_ttt_isolated() -> TestResult:
    """
    functional_ttt_train on 8 fake samples.
    Validates: device discipline, pure params returned, same keys.
    """
    from submission_agent import URMWMA, AgentConfig
    from wasm_bridge import functional_ttt_train, TTTConfig
    from torch.func import functional_call

    cfg   = AgentConfig(n_actions=7, hidden_size=512, device=DEVICE)
    wm    = URMWMA(cfg).to(DEVICE)
    params  = dict(wm.named_parameters())
    buffers = dict(wm.named_buffers())

    N = 8
    mk = lambda *s, dtype=torch.long: torch.randint(0, 7, s, device=DEVICE, dtype=dtype)
    states      = torch.randint(0, 11, (N, 4099), device=DEVICE, dtype=torch.long)
    actions     = mk(N)
    next_states = torch.randint(0, 11, (N, 4099), device=DEVICE, dtype=torch.long)
    rewards     = torch.rand(N, device=DEVICE)

    ttt_cfg = TTTConfig(steps=3, lr=1e-4)
    new_params = functional_ttt_train(
        params, buffers, wm,
        states, actions, next_states, rewards,
        cfg=ttt_cfg,
    )

    assert set(new_params.keys()) == set(params.keys()), "param keys changed"
    # verify all new params on correct device
    bad_dev = [k for k, v in new_params.items() if v.device != torch.device(DEVICE)]
    assert not bad_dev, f"params on wrong device: {bad_dev}"

    return TestResult("smoke_ttt_isolated", True, f"steps={ttt_cfg.steps} device={DEVICE}")


# ─── Test 4: CUDA full — Phase4 end-to-end ───────────────────────────────────

def smoke_cuda_full() -> TestResult:
    """
    20 envs, CUDA (skip if unavailable), full backbone.
    Agent built via build_agent factory — no external .to() calls.
    """
    if DEVICE != "cuda":
        return TestResult("smoke_cuda_full", True, "SKIP (no CUDA)")

    import arc_agi as arc
    from submission_agent import build_agent

    ckpt = str(CHECKPOINT) if CHECKPOINT.exists() else None
    agent = build_agent(
        checkpoint_path=ckpt,
        n_actions=7,
        hidden_size=512,
        device=DEVICE,
    )

    gids   = list(arc.list_games())[:20]
    passed = 0
    scores = {}

    for gid in gids:
        env   = arc.make(gid)
        agent.on_game_start()
        obs, _ = env.reset()
        score  = 0.0
        try:
            for _ in range(200):
                result = agent.choose_action([obs], None)
                obs, r, done, trunc, _ = env.step(result.action)
                agent.on_step(obs, result.action, float(r))
                score += float(r)
                if done or trunc:
                    break
            passed += 1
        except Exception as e:
            scores[gid] = f"ERROR: {e}"
            continue
        finally:
            env.close()
        scores[gid] = round(score, 4)

    del agent
    gc.collect()
    # single cache flush
    torch.cuda.empty_cache()

    detail = f"{passed}/{len(gids)} envs OK | scores={scores}"
    return TestResult("smoke_cuda_full", passed >= 18, detail)


# ─── Runner ───────────────────────────────────────────────────────────────────

def _run(name: str, fn: Callable[[], TestResult]) -> TestResult:
    print(f"\n── {name} ──")
    try:
        r = fn()
    except Exception as e:
        r = TestResult(name, False, str(e))
    print(r)
    return r


if __name__ == "__main__":
    _install_arc_agi()

    results = [
        _run("smoke_cpu_mini",     smoke_cpu_mini),
        _run("smoke_adapter",      smoke_adapter),
        _run("smoke_ttt_isolated", smoke_ttt_isolated),
        _run("smoke_cuda_full",    smoke_cuda_full),
    ]

    n_pass = sum(1 for r in results if r.passed)
    n_all  = len(results)
    print(f"\n══ {n_pass}/{n_all} tests passed ══")
    sys.exit(0 if n_pass == n_all else 1)
