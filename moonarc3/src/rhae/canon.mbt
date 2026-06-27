// ═══════════════════════════════════════════════════════════════
// canon.mbt — D4 canonicalization + color normalization
// ═══════════════════════════════════════════════════════════════

pub fn encode_action(a : Int) -> Int { a }

pub fn decode_action(raw : Int) -> Int {
  match raw {
    r if r >= 1 && r <= 7 => r
    _ => 1
  }
}

// D4 transform: (src_r, src_c) for output pixel (out_r, out_c) given h, w, t
fn d4_src(out_r : Int, out_c : Int, h : Int, w : Int, t : Int) -> (Int, Int) {
  match t {
    0 => (out_r,       out_c      )
    1 => (h-1-out_c,   out_r      )   // rot90
    2 => (h-1-out_r,   w-1-out_c  )   // rot180
    3 => (out_c,       w-1-out_r  )   // rot270
    4 => (out_r,       w-1-out_c  )   // flipX
    5 => (h-1-out_r,   out_c      )   // flipY
    6 => (out_c,       out_r      )   // transpose
    7 => (w-1-out_c,   h-1-out_r  )   // anti-transpose
    _ => (out_r,       out_c      )
  }
}

fn d4_out_dims(h : Int, w : Int, t : Int) -> (Int, Int) {
  match t {
    1 | 3 | 6 | 7 => (w, h)
    _ => (h, w)
  }
}

// Canonicalize: write lex-min D4 transform into out_buf
// Returns (out_h, out_w)
pub fn canonicalize_grid(
  grid    : Array[Int],
  h       : Int,
  w       : Int,
  out_buf : Array[Int]
) -> (Int, Int) {
  let best_t   : Ref[Int] = { val: 0 }
  let best_h   : Ref[Int] = { val: h }
  let best_w   : Ref[Int] = { val: w }

  // Write transform t into out_buf; return true if actually written
  fn write_t(t : Int) -> Unit {
    let (oh, ow) = d4_out_dims(h, w, t)
    let mut i = 0
    let mut r = 0
    while r < oh {
      let mut c = 0
      while c < ow {
        let (sr, sc) = d4_src(r, c, h, w, t)
        out_buf[i] = grid[sr * w + sc]
        i = i + 1
        c = c + 1
      }
      r = r + 1
    }
    best_h.val = oh
    best_w.val = ow
    best_t.val = t
  }

  // Is transform t lex-less than current out_buf?
  fn is_better(t : Int) -> Bool {
    let (oh, ow) = d4_out_dims(h, w, t)
    if oh != best_h.val || ow != best_w.val { return false }
    let mut i = 0
    let mut r = 0
    while r < oh {
      let mut c = 0
      while c < ow {
        let (sr, sc) = d4_src(r, c, h, w, t)
        let v = grid[sr * w + sc]
        let cur = out_buf[i]
        if v < cur { return true  }
        if v > cur { return false }
        i = i + 1
        c = c + 1
      }
      r = r + 1
    }
    false
  }

  write_t(0)
  let mut t = 1
  while t < 8 {
    if is_better(t) { write_t(t) }
    t = t + 1
  }
  (best_h.val, best_w.val)
}

// Color normalization: first-appearance order (background 0 fixed)
pub fn normalize_colors(
  grid : Array[Int],
  n    : Int,
  out  : Array[Int]
) -> Int {
  let remap : Array[Int] = Array::make(16, -1)
  remap[0] = 0
  let next_c : Ref[Int] = { val: 1 }
  let mut i = 0
  while i < n {
    let c = grid[i]
    let mc = match remap[c] {
      -1 => { remap[c] = next_c.val; next_c.val = next_c.val + 1; remap[c] }
      v  => v
    }
    out[i] = mc
    i = i + 1
  }
  next_c.val
}
