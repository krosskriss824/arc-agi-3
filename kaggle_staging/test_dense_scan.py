"""Test dense click scan: 32x32 = 1024 positions, find state-changing clicks."""
import os, sys, time
sys.path.insert(0, '.')
os.environ['ENVIRONMENTS_DIR'] = os.path.join(os.path.dirname(__file__), 'environment_files')
from arc_agi import Arcade

# Config
STRIDE = 2  # 2px stride → 32×32 = 1024 positions
MAX_STEPS = 2000  # total budget per game
WIN_BUDGET = 200  # max steps to try for WIN after finding state change

def _is_win(frame):
    s = getattr(frame, "state", None)
    return s is not None and "WIN" in str(s)

def test_dense_scan():
    arc = Arcade()
    envs = list(arc.available_environments)
    total_found = 0
    total_win = 0
    
    for i, env_info in enumerate(envs):
        gid = str(getattr(env_info, "game_id", getattr(env_info, "id", i)))
        env = arc.make(gid)
        acts = list(env.action_space)
        cpx = [i for i, a in enumerate(acts) if a.is_complex()]
        simple = [i for i, a in enumerate(acts) if not a.is_complex()]
        
        print(f"[{i+1}/25] {gid} (n={len(acts)}, cpx={len(cpx)}, sim={len(simple)})...", end=" ", flush=True)
        
        baseline_h = None
        changed = 0
        win = False
        budget = min(MAX_STEPS, 1024 + 200 * max(1, len(simple)))
        
        t0 = time.time()
        
        # Phase 1: Try simple actions (up to 200 each)
        for si in simple:
            env.reset()
            for k in range(WIN_BUDGET):
                nf = env.step(acts[si])
                if nf is None: break
                if _is_win(nf):
                    win = True
                    break
            if win: break
        
        if not win:
            # Phase 2: Dense click scan (1024 positions)
            yx_positions = [(y, x) for y in range(0, 64, STRIDE) for x in range(0, 64, STRIDE)]
            for pi, (py, px) in enumerate(yx_positions):
                if pi >= min(budget, 1024): break
                if win: break
                
                env.reset()
                nf = env.step(acts[cpx[0]], data={"x": px, "y": py})
                if nf is None: continue
                
                if _is_win(nf):
                    win = True
                    break
                
                # Check if state changed vs baseline
                if baseline_h is None:
                    env.reset()
                    bf = env.step(acts[cpx[0]], data={"x": px, "y": py})
                    if bf:
                        import numpy as np
                        fr = getattr(bf, "frame", None)
                        if fr and len(fr) > 0:
                            bg = np.asarray(fr[0], dtype=np.int32)
                            baseline_h = hash(bg.tobytes())
                
                fr = getattr(nf, "frame", None)
                if fr and len(fr) > 0:
                    import numpy as np
                    ng = np.asarray(fr[0], dtype=np.int32)
                    nh = hash(ng.tobytes())
                    if nh != baseline_h:
                        changed += 1
            
            if cpx and not win:
                # Phase 3: Try state-changing clicks repeatedly
                env.reset()
                for k in range(WIN_BUDGET):
                    pi = k % min(1024, budget)
                    py, px = 32, 32
                    if pi < len(yx_positions):
                        py, px = yx_positions[pi]
                    nf = env.step(acts[cpx[0]], data={"x": px, "y": py})
                    if nf is None: break
                    if _is_win(nf):
                        win = True
                        break
        
        dt = time.time() - t0
        total_found += 1 if changed > 0 or simple else 0
        total_win += 1 if win else 0
        
        label = "WIN!" if win else (f"state_changed={changed}" if changed > 0 else "no_change")
        print(f"{label} ({dt:.1f}s)")

    print(f"\n{'='*50}")
    print(f"Total: {total_win}/25 WIN, {total_found}/25 state_change_found")
    print(f"{'='*50}")

if __name__ == "__main__":
    test_dense_scan()
