// ═══════════════════════════════════════════════════════════════
// pattern.mbt — ARC pattern detection (symmetry, bbox, histogram)
// Independent exports (does NOT need compute_invariants)
// ═══════════════════════════════════════════════════════════════

/// Horizontal symmetry check (reuses logic from invariants.mbt)
pub fn rhae_has_hsym(h : Int, w : Int) -> Int {
  let mut r = 0
  while r < h / 2 {
    let mut c = 0
    while c < w {
      if grid_buf[r * w + c] != grid_buf[(h - 1 - r) * w + c] { return 0 }
      c = c + 1
    }
    r = r + 1
  }
  1
}

/// Vertical symmetry check
pub fn rhae_has_vsym(h : Int, w : Int) -> Int {
  let mut r = 0
  while r < h {
    let mut c = 0
    while c < w / 2 {
      if grid_buf[r * w + c] != grid_buf[r * w + (w - 1 - c)] { return 0 }
      c = c + 1
    }
    r = r + 1
  }
  1
}

/// Bounding box of given color. Writes to inv_buf[20..23]
/// Returns 1 if color found, 0 if not
pub fn rhae_bbox(h : Int, w : Int, color : Int) -> Int {
  let mut min_r = h; let mut min_c = w
  let mut max_r = -1; let mut max_c = -1
  let mut r = 0
  while r < h {
    let mut c = 0
    while c < w {
      if grid_buf[r * w + c] == color {
        if r < min_r { min_r = r }
        if c < min_c { min_c = c }
        if r > max_r { max_r = r }
        if c > max_c { max_c = c }
      }
      c = c + 1
    }
    r = r + 1
  }
  inv_buf[20] = min_r; inv_buf[21] = min_c
  inv_buf[22] = max_r; inv_buf[23] = max_c
  if max_r == -1 { 0 } else { 1 }
}

/// Count pixels of a specific color
pub fn rhae_count_color(h : Int, w : Int, color : Int) -> Int {
  let n = h * w
  let mut cnt = 0
  let mut i = 0
  while i < n {
    if grid_buf[i] == color { cnt = cnt + 1 }
    i = i + 1
  }
  cnt
}

/// Color histogram (all colors 0..9). Writes to inv_buf[30..39]
pub fn rhae_color_histogram(h : Int, w : Int) -> Unit {
  let mut c = 0
  while c < 10 {
    inv_buf[30 + c] = 0
    c = c + 1
  }
  let n = h * w
  let mut i = 0
  while i < n {
    let v = grid_buf[i]
    if v >= 0 && v <= 9 { inv_buf[30 + v] = inv_buf[30 + v] + 1 }
    i = i + 1
  }
}
