// ═══════════════════════════════════════════════════════════════
// exports.mbt — WASM-exported entrypoints for Python bridge
// All param names lowercase. Int args only (WASM i32).
// ═══════════════════════════════════════════════════════════════

pub fn set_grid_cell(idx : Int, val : Int) -> Unit { grid_buf[idx] = val }
pub fn set_prev_cell(idx : Int, val : Int) -> Unit { prev_buf[idx] = val }
pub fn set_visited(ai : Int, val : Int) -> Unit { vis_buf[ai] = val }
pub fn set_risk(ai : Int, val : Int) -> Unit { risk_buf[ai] = val }
pub fn get_inv(i : Int) -> Int  { inv_buf[i]  }
pub fn get_mat(i : Int) -> Int  { mat_buf[i]  }
pub fn get_topk(i : Int) -> Int { topk_buf[i] }

pub fn rhae_invariants(h : Int, w : Int) -> Int {
  compute_invariants(grid_buf, prev_buf, h, w, inv_buf)
  inv_buf[1]
}

pub fn rhae_canonical_hash(h : Int, w : Int) -> Int {
  zobrist_init()
  let (lo, hi) = canonical_hash(grid_buf, h, w)
  hash_hi.val = hi
  lo
}

pub fn rhae_get_hash_hi() -> Int { hash_hi.val }

pub fn rhae_visited_check(lo : Int, hi : Int) -> Int {
  if visited_check(lo, hi) { 1 } else { 0 }
}

pub fn rhae_visited_mark(lo : Int, hi : Int) -> Unit { visited_mark(lo, hi) }
pub fn rhae_visited_reset() -> Unit { visited_reset() }

pub fn rhae_policy_gate(legal : Int, h : Int, w : Int, n_actions : Int) -> Int {
  policy_gate(legal, inv_buf, grid_buf, h, w, risk_buf, n_actions)
}

pub fn rhae_build_candidates(
  legal : Int, path_cost : Int,
  hash_lo : Int, hash_hi_ : Int, max_c : Int
) -> Int {
  build_candidate_rows(legal, inv_buf, vis_buf, path_cost, hash_lo, hash_hi_, mat_buf, max_c)
}

pub fn rhae_topk(n_cand : Int, k : Int) -> Int {
  let pairs : Array[Int] = Array::make(14, 0)
  let mut i = 0
  while i < n_cand {
    let b = i * 13
    pairs[i*2]   = mat_buf[b]
    pairs[i*2+1] = mat_buf[b+5] + mat_buf[b+6] - mat_buf[b+4]
    i = i + 1
  }
  topk_candidates(pairs, n_cand, k, topk_buf)
}

pub fn rhae_tt_lookup(lo : Int, hi : Int) -> Int {
  let (found, action, _) = tt_lookup(lo, hi)
  if found { action } else { -1 }
}

pub fn rhae_tt_store(lo : Int, hi : Int, action : Int, score : Int) -> Unit {
  tt_store(lo, hi, action, score)
}

pub fn rhae_hash_and_check(h : Int, w : Int) -> Int {
  let lo = rhae_canonical_hash(h, w)
  let hi = hash_hi.val
  let vis = if visited_check(lo, hi) { 2 } else { 0 }
  let tth = match tt_lookup(lo, hi) { (true, _, _) => 1; _ => 0 }
  vis | tth
}

// ── Bulk I/O ──────────────────────────────────────────────────
// (rhae_set_dims, rhae_get_bulk_h/w, rhae_copy_prev defined in bulk_io.mbt)

// ── Score ─────────────────────────────────────────────────────
// (set_target_cell, rhae_hamming, rhae_iou_scaled, rhae_score_batch, rhae_is_solved defined in score.mbt)

// ── Pattern ───────────────────────────────────────────────────
// (rhae_has_hsym, rhae_has_vsym, rhae_bbox, rhae_count_color, rhae_color_histogram defined in pattern.mbt)

// ── Batch D4 hash ─────────────────────────────────────────────
// (rhae_d4_hashes_all defined in bulk_hash.mbt)
