// ═══════════════════════════════════════════════════════════════
// policy_gate.mbt — Hard-constraint + no-op + revisit filter
// Returns filtered 7-bit LegalMask
// ═══════════════════════════════════════════════════════════════

fn block_noop(inv : Array[Int]) -> Int {
  match (inv[5], inv[8]) {   // (is_sym, dyn_delta)
    (1, 0) => 0b0110000      // block ACTION5/6 (rotations on static symmetric)
    _      => 0
  }
}

fn block_revisit(risks : Array[Int], n : Int) -> Int {
  let mut blocked = 0; let mut i = 0
  while i < n && i < 7 {
    if risks[i] >= 95 { blocked = blocked | (1 << i) }
    i = i + 1
  }
  blocked
}

fn block_empty(inv : Array[Int]) -> Int {
  match inv[1] { 0 => 0b0111111; _ => 0 }
}

pub fn policy_gate(
  legal : Int, inv : Array[Int],
  _grid : Array[Int], _h : Int, _w : Int,
  risks : Array[Int], n_actions : Int
) -> Int {
  let blocked = block_noop(inv) | block_revisit(risks, n_actions) | block_empty(inv)
  let filtered = legal & (blocked.lnot())
  match filtered { 0 => match legal { 0 => 0b1000000; v => v }; v => v }
}
