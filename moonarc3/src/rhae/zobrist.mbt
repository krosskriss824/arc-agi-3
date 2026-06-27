// ═══════════════════════════════════════════════════════════════
// zobrist.mbt — Zobrist hash + Transposition Table + Visited set
// ═══════════════════════════════════════════════════════════════

let zb_rows   : Int = 32
let zb_cols   : Int = 32
let zb_colors : Int = 16
let zb_size   : Int = 16384

let zt_lo   : Array[Int]  = Array::make(16384, 0)
let zt_hi   : Array[Int]  = Array::make(16384, 0)
let zt_init : Ref[Bool]   = { val: false }

fn splitmix_lo(s : Int) -> Int {
  let z = s + 0x9E3779B9
  let z = (z ^ (z >> 16)) * 0x85EBCA6B
  let z = (z ^ (z >> 13)) * 0xC2B2AE35
  z ^ (z >> 16)
}
fn splitmix_hi(s : Int) -> Int {
  let z = s + 0x6C62272E
  let z = (z ^ (z >> 15)) * 0xBF58476D
  let z = (z ^ (z >> 13)) * 0x94D049BB
  z ^ (z >> 16)
}

pub fn zobrist_init() -> Unit {
  if zt_init.val { return }
  let mut i = 0
  while i < zb_size {
    zt_lo[i] = splitmix_lo(i * 1234567 + 42)
    zt_hi[i] = splitmix_hi(i * 7654321 + 137)
    i = i + 1
  }
  zt_init.val = true
}

fn zt_idx(row : Int, col : Int, color : Int) -> Int {
  let r = if row   < zb_rows   { row   } else { zb_rows   - 1 }
  let c = if col   < zb_cols   { col   } else { zb_cols   - 1 }
  let k = if color < zb_colors { color } else { 0 }
  (r * zb_cols + c) * zb_colors + k
}

pub fn zobrist_hash_grid(grid : Array[Int], h : Int, w : Int) -> (Int, Int) {
  zobrist_init()
  let mut lo = 0; let mut hi = 0
  let mut r = 0
  while r < h {
    let mut c = 0
    while c < w {
      let idx = zt_idx(r, c, grid[r * w + c])
      lo = lo ^ zt_lo[idx]; hi = hi ^ zt_hi[idx]
      c = c + 1
    }
    r = r + 1
  }
  (lo, hi)
}

pub fn zobrist_update_cell(
  lo_in : Int, hi_in : Int,
  row : Int, col : Int,
  old_color : Int, new_color : Int
) -> (Int, Int) {
  zobrist_init()
  let i_old = zt_idx(row, col, old_color)
  let i_new = zt_idx(row, col, new_color)
  (lo_in ^ zt_lo[i_old] ^ zt_lo[i_new],
   hi_in ^ zt_hi[i_old] ^ zt_hi[i_new])
}

// Canonical hash: min over all 8 D4 transforms (no grid materialization)
pub fn canonical_hash(grid : Array[Int], h : Int, w : Int) -> (Int, Int) {
  zobrist_init()
  let mut best_lo = 2147483647; let mut best_hi = 2147483647
  let mut t = 0
  while t < 8 {
    let mut lo = 0; let mut hi = 0
    let mut r = 0
    while r < h {
      let mut c = 0
      while c < w {
        let color = grid[r * w + c]
        let (tr, tc) = match t {
          0 => (r,     c      )
          1 => (c,     h-1-r  )
          2 => (h-1-r, w-1-c  )
          3 => (w-1-c, r      )
          4 => (r,     w-1-c  )
          5 => (h-1-r, c      )
          6 => (c,     r      )
          7 => (w-1-c, h-1-r  )
          _ => (r,     c      )
        }
        let idx = zt_idx(tr, tc, color)
        lo = lo ^ zt_lo[idx]; hi = hi ^ zt_hi[idx]
        c = c + 1
      }
      r = r + 1
    }
    if lo < best_lo || (lo == best_lo && hi < best_hi) {
      best_lo = lo; best_hi = hi
    }
    t = t + 1
  }
  (best_lo, best_hi)
}

// ── Transposition Table (open-addressed, 1024 slots × 4 Int) ──
let tt_cap    : Int = 1024
let tt_mask   : Int = 1023
let tt_stride : Int = 4
let tt_store_arr : Array[Int] = Array::make(4096, 0)

fn tt_slot(lo : Int, hi : Int) -> Int {
  ((lo ^ hi) * 0x9E3779B9) & tt_mask
}

pub fn tt_lookup(lo : Int, hi : Int) -> (Bool, Int, Int) {
  let s = tt_slot(lo, hi); let b = s * tt_stride
  if tt_store_arr[b] == lo && tt_store_arr[b+1] == hi {
    (true, tt_store_arr[b+2], tt_store_arr[b+3])
  } else {
    (false, 0, 0)
  }
}

pub fn tt_store(lo : Int, hi : Int, best_action : Int, score : Int) -> Unit {
  let s = tt_slot(lo, hi); let b = s * tt_stride
  tt_store_arr[b] = lo; tt_store_arr[b+1] = hi
  tt_store_arr[b+2] = best_action; tt_store_arr[b+3] = score
}

// ── Visited bitset (1024 bits = 32 Ints) ──
let visited_bits : Array[Int] = Array::make(32, 0)

pub fn visited_check(lo : Int, hi : Int) -> Bool {
  let s = tt_slot(lo, hi)
  ((visited_bits[s / 32] >> (s % 32)) & 1) == 1
}

pub fn visited_mark(lo : Int, hi : Int) -> Unit {
  let s = tt_slot(lo, hi)
  visited_bits[s / 32] = visited_bits[s / 32] | (1 << (s % 32))
}

pub fn visited_reset() -> Unit {
  let mut i = 0; while i < 32 { visited_bits[i] = 0; i = i + 1 }
}

/// Count unique D4 hashes for diagnostic (T9).
/// Returns 1 if all 8 transforms produce same hash (D4-canonical = correct).
pub fn d4_hashes_all(grid : Array[Int], h : Int, w : Int) -> Int {
  zobrist_init()
  let seen_lo : Array[Int] = Array::make(8, 0)
  let seen_hi : Array[Int] = Array::make(8, 0)
  let mut unique = 0
  let mut t = 0
  while t < 8 {
    let mut lo = 0; let mut hi = 0
    let mut r = 0
    while r < h {
      let mut c = 0
      while c < w {
        let color = grid[r * w + c]
        let (tr, tc) = match t {
          0 => (r,     c      )
          1 => (c,     h-1-r  )
          2 => (h-1-r, w-1-c  )
          3 => (w-1-c, r      )
          4 => (r,     w-1-c  )
          5 => (h-1-r, c      )
          6 => (c,     r      )
          7 => (w-1-c, h-1-r  )
          _ => (r,     c      )
        }
        let idx = zt_idx(tr, tc, color)
        lo = lo ^ zt_lo[idx]; hi = hi ^ zt_hi[idx]
        c = c + 1
      }
      r = r + 1
    }
    let mut is_new = true
    let mut k = 0
    while k < unique {
      if seen_lo[k] == lo && seen_hi[k] == hi { is_new = false }
      k = k + 1
    }
    if is_new {
      seen_lo[unique] = lo; seen_hi[unique] = hi
      unique = unique + 1
    }
    t = t + 1
  }
  unique
}
