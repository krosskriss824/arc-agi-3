"""Local test: profile 25 games, run profiler + decision tree, report results."""
import sys, os, time
sys.path.insert(0, '.')
os.environ['ENVIRONMENTS_DIR'] = os.path.join(os.path.dirname(__file__), 'environment_files')

from arc_agi import Arcade
import game_profiler as gp

def run():
    arc = Arcade()
    envs = list(arc.available_environments)
    print(f"Games: {len(envs)}")
    
    results = {}
    t0 = time.time()
    
    for i, env_info in enumerate(envs):
        gid = str(getattr(env_info, "game_id", getattr(env_info, "id", i)))
        print(f"\n[{i+1}/{len(envs)}] {gid}...", end=" ", flush=True)
        
        try:
            env = arc.make(gid)
            t1 = time.time()
            prof = gp.profile_game(env)
            strat = gp.choose_solver(prof)
            dt = time.time() - t1
            
            results[gid] = {
                "profile_steps": prof.n_actions * 3 + 50,  # rough estimate
                "solver": strat["name"],
                "time_s": round(dt, 1),
                "n_actions": prof.n_actions,
                "has_complex": prof.has_complex,
                "grid_empty": prof.grid_empty,
                "has_objects": prof.has_objects,
                "n_components": prof.n_components,
                "repeated_win": prof.repeated_win,
                "absorbing": prof.absorbing,
                "idempotent": prof.idempotent,
                "state_changers": prof.state_changers,
                "dead_actions": prof.dead_actions,
            }
            print(f"→ {strat['name']} ({dt:.1f}s)")
            
        except Exception as e:
            print(f"ERR: {e}")
            results[gid] = {"error": str(e)}
    
    print(f"\n{'='*60}")
    print(f"Total: {len(results)} games in {time.time()-t0:.0f}s")
    print(f"{'='*60}")
    
    # Summary table
    by_solver = {}
    for gid, r in results.items():
        sol = r.get("solver", "ERR")
        by_solver.setdefault(sol, []).append(gid)
    
    print(f"\nSolvers assigned:")
    for sol, games in sorted(by_solver.items()):
        print(f"  {sol}: {len(games)} games → {', '.join(games)}")
    
    # Print details for debugging
    print(f"\nDetails:")
    for gid, r in results.items():
        if "solver" in r:
            print(f"  {gid}: solver={r['solver']} empty={r['grid_empty']} objs={r['has_objects']} "
                  f"comp={r['n_components']} rw={r['repeated_win']} abs={r['absorbing']} "
                  f"state_ch={r['state_changers']} dead={r['dead_actions']}")

if __name__ == "__main__":
    run()
