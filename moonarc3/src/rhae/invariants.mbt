// ═══════════════════════════════════════════════════════════════
// invariants.mbt — InvariantPack: [n_comp, n_colors, n_obj,
//   bbox_h, bbox_w, is_sym, euler, n_holes, dyn_delta, goal_proxy]
// ═══════════════════════════════════════════════════════════════

fn bbox(grid : Array[Int], h : Int, w : Int) -> (Int, Int, Int, Int) {
  let mut r0 = h; let mut r1 = 0; let mut c0 = w; let mut c1 = 0
  let mut r = 0
  while r < h {
    let mut c = 0
    while c < w {
      if grid[r * w + c] > 0 {
        if r < r0 { r0 = r }; if r > r1 { r1 = r }
        if c < c0 { c0 = c }; if c > c1 { c1 = c }
      }
      c = c + 1
    }
    r = r + 1
  }
  (r0, r1, c0, c1)
}

fn count_components(grid : Array[Int], h : Int, w : Int, vis : Array[Int]) -> Int {
  let stack : Array[Int] = Array::make(h * w * 2 + 2, 0)
  let mut count = 0
  let mut r = 0
  while r < h {
    let mut c = 0
    while c < w {
      let idx = r * w + c
      if grid[idx] > 0 && vis[idx] == 0 {
        count = count + 1; vis[idx] = 1
        let mut sp = 0
        stack[sp] = r; sp = sp + 1; stack[sp] = c; sp = sp + 1
        while sp > 0 {
          sp = sp - 1; let cc = stack[sp]
          sp = sp - 1; let rr = stack[sp]
          // 4-connected neighbors
          let nb : Array[(Int,Int)] = [(rr-1,cc),(rr+1,cc),(rr,cc-1),(rr,cc+1)]
          let mut d = 0
          while d < 4 {
            let (nr, nc) = nb[d]
            if nr >= 0 && nr < h && nc >= 0 && nc < w {
              let ni = nr * w + nc
              if grid[ni] > 0 && vis[ni] == 0 {
                vis[ni] = 1
                stack[sp] = nr; sp = sp + 1; stack[sp] = nc; sp = sp + 1
              }
            }
            d = d + 1
          }
        }
      }
      c = c + 1
    }
    r = r + 1
  }
  count
}

fn euler_proxy(grid : Array[Int], h : Int, w : Int) -> (Int, Int) {
  let mut q1 = 0; let mut q3 = 0
  let mut r = 0
  while r < h - 1 {
    let mut c = 0
    while c < w - 1 {
      let a = if grid[r*w+c]       > 0 { 1 } else { 0 }
      let b = if grid[r*w+c+1]     > 0 { 1 } else { 0 }
      let d = if grid[(r+1)*w+c]   > 0 { 1 } else { 0 }
      let e = if grid[(r+1)*w+c+1] > 0 { 1 } else { 0 }
      let s = a + b + d + e
      match s { 1 => q1 = q1+1; 3 => q3 = q3+1; _ => () }
      c = c + 1
    }
    r = r + 1
  }
  ((q1 - q3) / 4, if q3 > q1 { (q3-q1)/4 } else { 0 })
}

fn is_sym_h(grid : Array[Int], h : Int, w : Int) -> Bool {
  let mut r = 0
  while r < h / 2 {
    let mut c = 0
    while c < w {
      if grid[r*w+c] != grid[(h-1-r)*w+c] { return false }
      c = c + 1
    }
    r = r + 1
  }
  true
}

fn count_colors(grid : Array[Int], n : Int) -> Int {
  let seen : Array[Int] = Array::make(16, 0)
  let mut i = 0
  while i < n { let c = grid[i]; if c > 0 && c < 16 { seen[c] = 1 }; i = i+1 }
  let mut cnt = 0; let mut k = 0
  while k < 16 { cnt = cnt + seen[k]; k = k+1 }
  cnt
}

pub fn compute_invariants(
  grid : Array[Int], prev : Array[Int],
  h : Int, w : Int, out : Array[Int]
) -> Unit {
  let n = h * w
  let vis : Array[Int] = Array::make(n, 0)
  let n_comp   = count_components(grid, h, w, vis)
  let (euler, n_holes) = euler_proxy(grid, h, w)
  let n_colors = count_colors(grid, n)
  let (r0, r1, c0, c1) = bbox(grid, h, w)
  let bh = if r1 >= r0 { r1-r0+1 } else { 0 }
  let bw = if c1 >= c0 { c1-c0+1 } else { 0 }
  let sym   = if is_sym_h(grid, h, w) { 1 } else { 0 }
  let mut delta = 0; let mut j = 0
  while j < n { if grid[j] != prev[j] { delta = delta+1 }; j = j+1 }
  let mut nz = 0; let mut k = 0
  while k < n { if grid[k] > 0 { nz = nz+1 }; k = k+1 }
  let goal = if n > 0 { nz*100/n } else { 0 }
  out[0]=n_comp; out[1]=n_colors; out[2]=n_comp
  out[3]=bh;     out[4]=bw;       out[5]=sym
  out[6]=euler;  out[7]=n_holes;  out[8]=delta; out[9]=goal
}
