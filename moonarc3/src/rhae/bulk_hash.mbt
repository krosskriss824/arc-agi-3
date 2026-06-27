// ═══════════════════════════════════════════════════════════════
// bulk_hash.mbt — Batch D4 hash diagnostic
// NOTE: canonical_hash() in zobrist.mbt ALREADY does D4 min.
// This module exposes diagnostic: count unique D4 hashes (for T9).
// ═══════════════════════════════════════════════════════════════

/// Count unique D4 hashes for diagnostic (T9).
/// Returns number of unique hashes across 8 transforms (1 = perfect D4).
pub fn rhae_d4_hashes_all(h : Int, w : Int) -> Int {
  d4_hashes_all(grid_buf, h, w)
}
