// ── Candidate row field indices (CR_STRIDE = 13) ──
pub let cr_action       : Int = 0
pub let cr_canon_hash   : Int = 1
pub let cr_parent_hash  : Int = 2
pub let cr_path_cost    : Int = 3
pub let cr_revisit_risk : Int = 4
pub let cr_novelty      : Int = 5
pub let cr_info_gain    : Int = 6
pub let cr_topo_0       : Int = 7
pub let cr_topo_1       : Int = 8
pub let cr_geom_0       : Int = 9
pub let cr_geom_1       : Int = 10
pub let cr_dyn_0        : Int = 11
pub let cr_goal_0       : Int = 12
pub let cr_stride       : Int = 13

// ── Shared flat buffers: Python writes input, reads output ──
pub let grid_buf  : Array[Int] = Array::make(4096, 0)
pub let prev_buf  : Array[Int] = Array::make(4096, 0)
pub let inv_buf  : Array[Int] = Array::make(40,   0)  // [0..9]=invariants, [10..19]=score, [20..29]=bbox, [30..39]=histogram
pub let vis_buf   : Array[Int] = Array::make(7,    0)
pub let risk_buf  : Array[Int] = Array::make(7,    0)
pub let mat_buf   : Array[Int] = Array::make(91,   0)
pub let topk_buf  : Array[Int] = Array::make(6,    0)
pub let hash_hi   : Ref[Int]   = { val: 0 }
