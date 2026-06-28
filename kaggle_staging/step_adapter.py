"""step_adapter.py — Single source of truth for ARC-AGI-3 env.step().

ARC-AGI-3 contract:
  - Simple actions: env.step(action) — no data dict needed
  - Complex actions (ACTION6): env.step(action, data={"x": int, "y": int}) — ALWAYS required
  - Missing x/y for complex → fail fast (return None), NEVER bare step
"""


def safe_step(env, action, x=None, y=None):
    """Execute env.step() respecting ARC-AGI-3 action contract.

    Complex actions ALWAYS require data={"x":..,"y":..}.
    If x or y missing for complex → return None (fail fast).
    If env.step raises KeyError/TypeError/AttributeError → return None.
    """
    if action.is_complex():
        if x is None or y is None:
            return None
        try:
            return env.step(action, data={"x": int(x), "y": int(y)})
        except (KeyError, TypeError, AttributeError):
            return None
    return env.step(action)
