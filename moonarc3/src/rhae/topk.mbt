// ═══════════════════════════════════════════════════════════════
// topk.mbt — Diversity-aware top-k selection (k <= 6)
// ═══════════════════════════════════════════════════════════════

pub fn topk_candidates(
  pairs : Array[Int],   // flat [action, score, action, score, ...]
  n     : Int,
  k     : Int,
  out   : Array[Int]
) -> Int {
  let kk   = if k > 6 { 6 } else { k }
  let used : Array[Int] = Array::make(64, 0)
  let mut n_sel = 0
  while n_sel < kk {
    let mut best_i = -1; let mut best_s = -1
    let mut i = 0
    while i < n {
      if used[i] == 0 && pairs[i*2+1] > best_s {
        best_s = pairs[i*2+1]; best_i = i
      }
      i = i + 1
    }
    if best_i == -1 || best_s < 0 { break }
    used[best_i] = 1
    out[n_sel] = pairs[best_i*2]
    n_sel = n_sel + 1
  }
  n_sel
}

pub fn build_candidate_rows(
  legal     : Int,
  inv       : Array[Int],
  vis       : Array[Int],
  path_cost : Int,
  hash_lo   : Int,
  hash_hi   : Int,
  mat       : Array[Int],
  max_c     : Int
) -> Int {
  let mut n = 0
  let mut a = 1
  while a <= 7 && n < max_c {
    if ((legal >> (a-1)) & 1) == 1 {
      let b   = n * 13
      let nov = match vis[a-1] { 0 => 100; _ => 0 }
      mat[b+0]  = a;              mat[b+1]  = hash_lo
      mat[b+2]  = hash_hi;        mat[b+3]  = path_cost
      mat[b+4]  = vis[a-1]*100;   mat[b+5]  = nov
      mat[b+6]  = inv[8];         mat[b+7]  = inv[0]
      mat[b+8]  = inv[7];         mat[b+9]  = inv[3]*inv[4]
      mat[b+10] = inv[5];         mat[b+11] = inv[8]
      mat[b+12] = inv[9]
      n = n + 1
    }
    a = a + 1
  }
  n
}
