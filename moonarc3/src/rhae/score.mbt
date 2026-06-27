// ═══════════════════════════════════════════════════════════════
// score.mbt — Grid similarity scores (hot path dla ARC solver)
// Wszystko in-WASM: Python daje tylko h,w i dostaje Int score
// ═══════════════════════════════════════════════════════════════

let target_buf : Array[Int] = Array::make(4096, 0)

pub fn set_target_cell(idx : Int, val : Int) -> Unit { target_buf[idx] = val }

/// Hamming distance: liczba pikseli gdzie grid_buf != target_buf
/// Zwraca Int (0 = perfect match)
pub fn rhae_hamming(h : Int, w : Int) -> Int {
  let n = h * w
  let mut diff = 0
  let mut i = 0
  while i < n {
    if grid_buf[i] != target_buf[i] { diff = diff + 1 }
    i = i + 1
  }
  diff
}

/// Intersection over Union per-color (scaled ×1000, Int, unika float)
pub fn rhae_iou_scaled(h : Int, w : Int, color : Int) -> Int {
  let n = h * w
  let mut inter = 0
  let mut union_ = 0
  let mut i = 0
  while i < n {
    let g = if grid_buf[i]  == color { 1 } else { 0 }
    let t = if target_buf[i] == color { 1 } else { 0 }
    inter = inter + g * t
    if g == 1 || t == 1 { union_ = union_ + 1 }
    i = i + 1
  }
  if union_ == 0 { return 1000 }
  inter * 1000 / union_
}

/// Batch score: hamming + iou dla kolorów 1..9 w jednym wywołaniu
/// Zapisuje do inv_buf[10..18] (reużywa istniejący bufor)
/// Zwraca hamming jako główny sygnał
pub fn rhae_score_batch(h : Int, w : Int) -> Int {
  let ham = rhae_hamming(h, w)
  let mut c = 1
  while c <= 9 {
    inv_buf[10 + c] = rhae_iou_scaled(h, w, c)
    c = c + 1
  }
  ham
}

/// Sprawdza czy grid_buf == target_buf (early exit na pierwszej różnicy)
pub fn rhae_is_solved(h : Int, w : Int) -> Int {
  let n = h * w
  let mut i = 0
  while i < n {
    if grid_buf[i] != target_buf[i] { return 0 }
    i = i + 1
  }
  1
}
