// ═══════════════════════════════════════════════════════════════
// bulk_io.mbt — Pre-allocated global I/O state + bulk operations
// X3 fix: rhae_copy_prev eliminates 4096 redundant set_prev_cell FFI calls
// ═══════════════════════════════════════════════════════════════

let _bulk_h : Ref[Int] = { val: 0 }
let _bulk_w : Ref[Int] = { val: 0 }

pub fn rhae_set_dims(h : Int, w : Int) -> Unit {
  _bulk_h.val = h
  _bulk_w.val = w
}

pub fn rhae_get_bulk_h() -> Int { _bulk_h.val }
pub fn rhae_get_bulk_w() -> Int { _bulk_w.val }

/// Copy grid_buf[0..n-1] to prev_buf[0..n-1] in one WASM call
/// X3 fix: replaces N individual set_prev_cell FFI calls with 1 call
pub fn rhae_copy_prev(n : Int) -> Unit {
  let mut i = 0
  while i < n {
    prev_buf[i] = grid_buf[i]
    i = i + 1
  }
}
