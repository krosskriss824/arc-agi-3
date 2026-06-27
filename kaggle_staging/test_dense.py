"""Test DenseExplorer: dense click scan on all 25 games, find WINs + live clicks."""
import os, sys, time
sys.path.insert(0, '.')
os.environ['ENVIRONMENTS_DIR'] = os.path.join(os.path.dirname(__file__), 'environment_files')
from arc_agi import Arcade
from dense_explorer import DenseExplorer

def run():
    arc = Arcade()
    envs = list(arc.available_environments)
    results = {}
    t0 = time.time()
    
    for i, env_info in enumerate(envs):
        gid = str(getattr(env_info, "game_id", getattr(env_info, "id", i)))
        env = arc.make(gid)
        acts = list(env.action_space)
        
        print(f"[{i+1}/25] {gid} (n={len(acts)})...", end=" ", flush=True)
        t1 = time.time()
        
        exp = DenseExplorer(env, acts)
        solved = exp.explore(max_steps=1500)
        dt = time.time() - t1
        
        results[gid] = {
            "solved": solved,
            "solution_len": len(exp.solution) if exp.solution else 0,
            "n_live": len(exp.live_clicks),
            "budget_used": exp._total_steps,
            "time_s": round(dt, 1),
            "n_actions": len(acts),
            "has_complex": exp._click_idx is not None,
        }
        
        label = "WIN!" if solved else (f"{len(exp.live_clicks)} live" if exp.live_clicks else "no_live")
        print(f"{label} ({dt:.1f}s, {exp._total_steps}steps)")
    
    print(f"\n{'='*60}")
    print(f"Total: {sum(1 for r in results.values() if r['solved'])}/{len(results)} WIN, "
          f"{sum(1 for r in results.values() if r['n_live'] > 0)}/{len(results)} live_clicks")
    print(f"Time: {time.time()-t0:.0f}s")
    print(f"{'='*60}")
    
    for gid, r in results.items():
        if r["solved"]:
            print(f"  ✅ {gid}: WIN in {r['solution_len']} steps ({r['time_s']}s)")
        elif r["n_live"] > 0:
            print(f"  📍 {gid}: {r['n_live']} live clicks ({r['time_s']}s)")
        else:
            print(f"  ❌ {gid}: no live clicks ({r['time_s']}s)")

if __name__ == "__main__":
    run()
