(data  (memory $moonbit.memory) (offset (i32.const 10000)) "\FF\FF\FF\FF\00\00\18\00\00\00\00\00\00\00\00\00\00\00\00\00")
(memory $moonbit.memory 1)
(export "memory" (memory $moonbit.memory))
(global $tlsf/ROOT
 (mut i32)
 (i32.const 0)
)
(func $tlsf/searchBlock (param $0 i32) (param $1 i32) (result i32)
 (local $2 i32)
 (if (result i32)
  (local.tee $1
   (i32.and
    (i32.load offset=4
     (i32.add
      (local.get $0)
      (i32.shl
       (local.tee $2
        (if (result i32)
         (i32.lt_u
          (local.get $1)
          (i32.const 256))
         (then
          (local.set $1
           (i32.shr_u
            (local.get $1)
            (i32.const 4)))
          (i32.const 0))
         (else
          (if
           (i32.lt_u
            (local.get $1)
            (i32.const 536870910))
           (then
            (local.set $1
             (i32.sub
              (i32.add
               (local.get $1)
               (i32.shl
                (i32.const 1)
                (i32.sub
                 (i32.const 27)
                 (i32.clz
                  (local.get $1)))))
              (i32.const 1))))
           (else))
          (local.set $2
           (i32.sub
            (i32.const 31)
            (i32.clz
             (local.get $1))))
          (local.set $1
           (i32.xor
            (i32.shr_u
             (local.get $1)
             (i32.sub
              (local.get $2)
              (i32.const 4)))
            (i32.const 16)))
          (i32.sub
           (local.get $2)
           (i32.const 7)))))
       (i32.const 2))))
    (i32.shl
     (i32.const -1)
     (local.get $1))))
  (then
   (i32.load offset=96
    (i32.add
     (local.get $0)
     (i32.shl
      (i32.add
       (i32.ctz
        (local.get $1))
       (i32.shl
        (local.get $2)
        (i32.const 4)))
      (i32.const 2)))))
  (else
   (if (result i32)
    (local.tee $1
     (i32.and
      (i32.load
       (local.get $0))
      (i32.shl
       (i32.const -1)
       (i32.add
        (local.get $2)
        (i32.const 1)))))
    (then
     (i32.load offset=96
      (i32.add
       (local.get $0)
       (i32.shl
        (i32.add
         (i32.ctz
          (i32.load offset=4
           (i32.add
            (local.get $0)
            (i32.shl
             (local.tee $1
              (i32.ctz
               (local.get $1)))
             (i32.const 2)))))
         (i32.shl
          (local.get $1)
          (i32.const 4)))
        (i32.const 2)))))
    (else
     (i32.const 0))))))
(func $tlsf/removeBlock (param $0 i32) (param $1 i32)
 (local $2 i32)
 (local $3 i32)
 (local $4 i32)
 (local $5 i32)
 (local.set $5
  (if (result i32)
   (i32.lt_u
    (local.tee $2
     (i32.and
      (i32.load
       (local.get $1))
      (i32.const -4)))
    (i32.const 256))
   (then
    (local.set $3
     (i32.shr_u
      (local.get $2)
      (i32.const 4)))
    (i32.const 0))
   (else
    (local.set $2
     (i32.sub
      (i32.const 31)
      (i32.clz
       (local.tee $3
        (select
         (i32.const 1073741820)
         (local.get $2)
         (i32.ge_u
          (local.get $2)
          (i32.const 1073741820)))))))
    (local.set $3
     (i32.xor
      (i32.shr_u
       (local.get $3)
       (i32.sub
        (local.get $2)
        (i32.const 4)))
      (i32.const 16)))
    (i32.sub
     (local.get $2)
     (i32.const 7)))))
 (local.set $2
  (i32.load offset=8
   (local.get $1)))
 (if
  (local.tee $4
   (i32.load offset=4
    (local.get $1)))
  (then
   (i32.store offset=8
    (local.get $4)
    (local.get $2)))
  (else))
 (if
  (local.get $2)
  (then
   (i32.store offset=4
    (local.get $2)
    (local.get $4)))
  (else))
 (if
  (i32.eq
   (local.get $1)
   (i32.load offset=96
    (local.tee $4
     (i32.add
      (local.get $0)
      (i32.shl
       (i32.add
        (i32.shl
         (local.get $5)
         (i32.const 4))
        (local.get $3))
       (i32.const 2))))))
  (then
   (i32.store offset=96
    (local.get $4)
    (local.get $2))
   (if
    (i32.eqz
     (local.get $2))
    (then
     (i32.store offset=4
      (local.tee $1
       (i32.add
        (local.get $0)
        (i32.shl
         (local.get $5)
         (i32.const 2))))
      (local.tee $1
       (i32.and
        (i32.load offset=4
         (local.get $1))
        (i32.rotl
         (i32.const -2)
         (local.get $3)))))
     (if
      (i32.eqz
       (local.get $1))
      (then
       (i32.store
        (local.get $0)
        (i32.and
         (i32.load
          (local.get $0))
         (i32.rotl
          (i32.const -2)
          (local.get $5)))))
      (else)))
    (else)))
  (else)))
(func $tlsf/insertBlock (param $0 i32) (param $1 i32)
 (local $2 i32)
 (local $3 i32)
 (local $4 i32)
 (local $5 i32)
 (local.set $3
  (local.tee $4
   (i32.load
    (local.get $1))))
 (if
  (i32.and
   (local.tee $4
    (i32.load
     (local.tee $2
      (i32.add
       (local.tee $5
        (i32.add
         (local.get $1)
         (i32.const 4)))
       (i32.and
        (local.get $4)
        (i32.const -4))))))
   (i32.const 1))
  (then
   (call $tlsf/removeBlock
    (local.get $0)
    (local.get $2))
   (i32.store
    (local.get $1)
    (local.tee $3
     (i32.add
      (i32.add
       (local.get $3)
       (i32.const 4))
      (i32.and
       (local.get $4)
       (i32.const -4)))))
   (local.set $4
    (i32.load
     (local.tee $2
      (i32.add
       (i32.and
        (i32.load
         (local.get $1))
        (i32.const -4))
       (local.get $5))))))
  (else))
 (if
  (i32.and
   (local.get $3)
   (i32.const 2))
  (then
   (local.set $5
    (i32.load
     (local.tee $1
      (i32.load
       (i32.sub
        (local.get $1)
        (i32.const 4))))))
   (call $tlsf/removeBlock
    (local.get $0)
    (local.get $1))
   (i32.store
    (local.get $1)
    (local.tee $3
     (i32.add
      (i32.add
       (local.get $5)
       (i32.const 4))
      (i32.and
       (local.get $3)
       (i32.const -4))))))
  (else))
 (i32.store
  (local.get $2)
  (i32.or
   (local.get $4)
   (i32.const 2)))
 (i32.store
  (i32.sub
   (local.get $2)
   (i32.const 4))
  (local.get $1))
 (local.set $3
  (if (result i32)
   (i32.lt_u
    (local.tee $2
     (i32.and
      (local.get $3)
      (i32.const -4)))
    (i32.const 256))
   (then
    (local.set $2
     (i32.shr_u
      (local.get $2)
      (i32.const 4)))
    (i32.const 0))
   (else
    (local.set $3
     (i32.sub
      (i32.const 31)
      (i32.clz
       (local.tee $2
        (select
         (i32.const 1073741820)
         (local.get $2)
         (i32.ge_u
          (local.get $2)
          (i32.const 1073741820)))))))
    (local.set $2
     (i32.xor
      (i32.shr_u
       (local.get $2)
       (i32.sub
        (local.get $3)
        (i32.const 4)))
      (i32.const 16)))
    (i32.sub
     (local.get $3)
     (i32.const 7)))))
 (local.set $4
  (i32.load offset=96
   (i32.add
    (local.get $0)
    (i32.shl
     (i32.add
      (i32.shl
       (local.get $3)
       (i32.const 4))
      (local.get $2))
     (i32.const 2)))))
 (i32.store offset=4
  (local.get $1)
  (i32.const 0))
 (i32.store offset=8
  (local.get $1)
  (local.get $4))
 (if
  (local.get $4)
  (then
   (i32.store offset=4
    (local.get $4)
    (local.get $1)))
  (else))
 (i32.store offset=96
  (i32.add
   (local.get $0)
   (i32.shl
    (i32.add
     (i32.shl
      (local.get $3)
      (i32.const 4))
     (local.get $2))
    (i32.const 2)))
  (local.get $1))
 (i32.store
  (local.get $0)
  (i32.or
   (i32.load
    (local.get $0))
   (i32.shl
    (i32.const 1)
    (local.get $3))))
 (i32.store offset=4
  (local.tee $0
   (i32.add
    (local.get $0)
    (i32.shl
     (local.get $3)
     (i32.const 2))))
  (i32.or
   (i32.load offset=4
    (local.get $0))
   (i32.shl
    (i32.const 1)
    (local.get $2)))))
(func $tlsf/addMemory (param $0 i32) (param $1 i32) (param $2 i64)
 (local $3 i32)
 (local $4 i32)
 (local $5 i32)
 (if
  (select
   (local.tee $4
    (i32.load offset=1568
     (local.get $0)))
   (i32.const 0)
   (i32.eq
    (local.tee $3
     (i32.sub
      (local.tee $1
       (i32.sub
        (i32.and
         (i32.add
          (local.get $1)
          (i32.const 19))
         (i32.const -16))
        (i32.const 4)))
      (i32.const 16)))
    (local.get $4)))
  (then
   (local.set $5
    (i32.load
     (local.get $4)))
   (local.set $1
    (local.get $3)))
  (else))
 (if
  (i32.lt_u
   (local.tee $3
    (i32.sub
     (i32.and
      (i32.wrap_i64
       (local.get $2))
      (i32.const -16))
     (local.get $1)))
   (i32.const 20))
  (then
   (return))
  (else))
 (i32.store
  (local.get $1)
  (i32.or
   (i32.and
    (local.get $5)
    (i32.const 2))
   (i32.or
    (local.tee $3
     (i32.sub
      (local.get $3)
      (i32.const 8)))
    (i32.const 1))))
 (i32.store offset=4
  (local.get $1)
  (i32.const 0))
 (i32.store offset=8
  (local.get $1)
  (i32.const 0))
 (i32.store
  (local.tee $3
   (i32.add
    (i32.add
     (local.get $1)
     (i32.const 4))
    (local.get $3)))
  (i32.const 2))
 (i32.store offset=1568
  (local.get $0)
  (local.get $3))
 (call $tlsf/insertBlock
  (local.get $0)
  (local.get $1)))
(func $tlsf/initialize
 (local $0 i32)
 (local $1 i32)
 (local $2 i32)
 (local.set $0
  (i32.and
   (i32.add
    (i32.const 10024)
    (i32.const 15))
   (i32.const -16)))
 (if
  (if (result i32)
   (i32.lt_s
    (local.tee $1
     (memory.size))
    (local.tee $2
     (i32.shr_u
      (i32.and
       (i32.add
        (local.get $0)
        (i32.const 67107))
       (i32.const -65536))
      (i32.const 16))))
   (then
    (i32.lt_s
     (memory.grow
      (i32.sub
       (local.get $2)
       (local.get $1)))
     (i32.const 0)))
   (else
    (i32.const 0)))
  (then
   (unreachable))
  (else))
 (i32.store
  (local.get $0)
  (i32.const 0))
 (i32.store offset=1568
  (local.get $0)
  (i32.const 0))
 (local.set $1
  (i32.const 0))
 (loop $label1
  (if
   (i32.lt_u
    (local.get $1)
    (i32.const 23))
   (then
    (i32.store offset=4
     (i32.add
      (local.get $0)
      (i32.shl
       (local.get $1)
       (i32.const 2)))
     (i32.const 0))
    (local.set $2
     (i32.const 0))
    (loop $label
     (if
      (i32.lt_u
       (local.get $2)
       (i32.const 16))
      (then
       (i32.store offset=96
        (i32.add
         (local.get $0)
         (i32.shl
          (i32.add
           (i32.shl
            (local.get $1)
            (i32.const 4))
           (local.get $2))
          (i32.const 2)))
        (i32.const 0))
       (local.set $2
        (i32.add
         (local.get $2)
         (i32.const 1)))
       (br $label))
      (else)))
    (local.set $1
     (i32.add
      (local.get $1)
      (i32.const 1)))
    (br $label1))
   (else)))
 (call $tlsf/addMemory
  (local.get $0)
  (i32.add
   (local.get $0)
   (i32.const 1572))
  (i64.shl
   (i64.extend_i32_s
    (memory.size))
   (i64.const 16)))
 (global.set $tlsf/ROOT
  (local.get $0)))
(func $moonbit.malloc (param $0 i32) (result i32)
 (local $1 i32)
 (local $2 i32)
 (local $3 i32)
 (local $4 i32)
 (if
  (i32.eqz
   (global.get $tlsf/ROOT))
  (then
   (call $tlsf/initialize))
  (else))
 (if
  (i32.gt_u
   (local.get $0)
   (i32.const 1073741820))
  (then
   (unreachable))
  (else))
 (if
  (i32.eqz
   (local.tee $0
    (call $tlsf/searchBlock
     (local.tee $2
      (global.get $tlsf/ROOT))
     (local.tee $1
      (if (result i32)
       (i32.le_u
        (local.get $0)
        (i32.const 12))
       (then
        (i32.const 12))
       (else
        (i32.sub
         (i32.and
          (i32.add
           (local.get $0)
           (i32.const 19))
          (i32.const -16))
         (i32.const 4))))))))
  (then
   (local.tee $0
    (memory.size))
   (if
    (i32.lt_s
     (memory.grow
      (select
       (if (result i32)
        (i32.ge_u
         (local.get $1)
         (i32.const 256))
        (then
         (if (result i32)
          (i32.lt_u
           (local.get $1)
           (i32.const 536870910))
          (then
           (i32.sub
            (i32.add
             (local.get $1)
             (i32.shl
              (i32.const 1)
              (i32.sub
               (i32.const 27)
               (i32.clz
                (local.get $1)))))
            (i32.const 1)))
          (else
           (local.get $1))))
        (else
         (local.get $1)))
       (local.tee $3
        (i32.shr_u
         (i32.and
          (i32.add
           (i32.add
            (i32.const 4)
            (i32.shl
             (i32.load offset=1568
              (local.get $2))
             (i32.ne
              (i32.sub
               (i32.shl
                (local.get $0)
                (i32.const 16))
               (i32.const 4)))))
           (i32.const 65535))
          (i32.const -65536))
         (i32.const 16)))
       (i32.gt_s
        (local.get $0)
        (local.get $3))))
     (i32.const 0))
    (then
     (if
      (i32.lt_s
       (memory.grow
        (local.get $3))
       (i32.const 0))
      (then
       (unreachable))
      (else)))
    (else))
   (call $tlsf/addMemory
    (local.get $2)
    (i32.shl
     (local.get $0)
     (i32.const 16))
    (i64.shl
     (i64.extend_i32_s
      (memory.size))
     (i64.const 16)))
   (local.set $0
    (call $tlsf/searchBlock
     (local.get $2)
     (local.get $1))))
  (else))
 (call $tlsf/removeBlock
  (local.get $2)
  (local.get $0))
 (if
  (i32.ge_u
   (local.tee $4
    (i32.sub
     (i32.and
      (local.tee $3
       (i32.load
        (local.get $0)))
      (i32.const -4))
     (local.get $1)))
   (i32.const 16))
  (then
   (i32.store
    (local.get $0)
    (i32.or
     (local.get $1)
     (i32.and
      (local.get $3)
      (i32.const 2))))
   (i32.store
    (local.tee $1
     (i32.add
      (i32.add
       (local.get $0)
       (i32.const 4))
      (local.get $1)))
    (i32.or
     (i32.sub
      (local.get $4)
      (i32.const 4))
     (i32.const 1)))
   (call $tlsf/insertBlock
    (local.get $2)
    (local.get $1)))
  (else
   (i32.store
    (local.get $0)
    (i32.and
     (local.get $3)
     (i32.const -2)))
   (i32.store
    (i32.add
     (local.tee $1
      (i32.add
       (local.get $0)
       (i32.const 4)))
     (local.tee $2
      (i32.and
       (i32.load
        (local.get $0))
       (i32.const -4))))
    (i32.and
     (i32.load
      (i32.add
       (local.get $1)
       (local.get $2)))
     (i32.const -3)))))
 (i32.add
  (local.get $0)
  (i32.const 4)))
(func $moonbit.free (param $0 i32)
 (local $1 i32)
 (local $2 i32)
 (if
  (i32.gt_u
   (i32.const 10024)
   (local.get $0))
  (then
   (return))
  (else))
 (if
  (i32.eqz
   (global.get $tlsf/ROOT))
  (then
   (call $tlsf/initialize))
  (else))
 (local.set $2
  (global.get $tlsf/ROOT))
 (local.set $1
  (i32.sub
   (local.get $0)
   (i32.const 4)))
 (if
  (if (result i32)
   (select
    (i32.and
     (local.get $0)
     (i32.const 15))
    (i32.const 1)
    (local.get $0))
   (then
    (i32.const 1))
   (else
    (i32.and
     (i32.load
      (local.get $1))
     (i32.const 1))))
  (then
   (unreachable))
  (else))
 (i32.store
  (local.get $1)
  (i32.or
   (i32.load
    (local.get $1))
   (i32.const 1)))
 (call $tlsf/insertBlock
  (local.get $2)
  (local.get $1)))
(func $moonbit.gc.malloc (param $n i32) (result i32)
 (local $raw i32)
 (local $result i32)
 (local.set $raw
  (call $moonbit.malloc
   (i32.add
    (i32.const 8)
    (local.get $n))))
 (local.set $result
  (i32.add
   (local.get $raw)
   (i32.const 8)))
 (i32.store
  (local.get $raw)
  (i32.const 1))
 (local.get $result))
(func $moonbit.store_object_meta (param $p i32) (param $v i32)
 (i32.store
  (i32.sub
   (local.get $p)
   (i32.const 4))
  (local.get $v)))
(func $moonbit.get_ref_cnt (param $p i32) (result i32)
 (i32.load
  (i32.sub
   (local.get $p)
   (i32.const 8))))
(func $moonbit.set_ref_cnt (param $p i32) (param $v i32)
 (i32.store
  (i32.sub
   (local.get $p)
   (i32.const 8))
  (local.get $v)))
(func $moonbit.make_array_header (param $kind i32) (param $elem_size_shift i32) (param $len i32) (result i32)
 (i32.or
  (i32.or
   (i32.shl
    (local.get $kind)
    (i32.const 30))
   (i32.shl
    (local.get $elem_size_shift)
    (i32.const 28)))
  (local.get $len)))
(func $moonbit.i32_array_make_raw (param $size i32) (result i32)
 (local $arr i32)
 (if
  (i32.lt_s
   (local.get $size)
   (i32.const 0))
  (then
   (unreachable))
  (else))
 (call $moonbit.store_object_meta
  (local.tee $arr
   (call $moonbit.gc.malloc
    (i32.mul
     (local.get $size)
     (i32.const 4))))
  (call $moonbit.make_array_header
   (i32.const 1)
   (i32.const 2)
   (local.get $size)))
 (local.get $arr))
(func $moonbit.ref_array_make_raw (param $size i32) (result i32)
 (local $arr i32)
 (if
  (i32.lt_s
   (local.get $size)
   (i32.const 0))
  (then
   (unreachable))
  (else))
 (call $moonbit.store_object_meta
  (local.tee $arr
   (call $moonbit.gc.malloc
    (i32.mul
     (local.get $size)
     (i32.const 4))))
  (call $moonbit.make_array_header
   (i32.const 2)
   (i32.const 2)
   (local.get $size)))
 (local.get $arr))
(func $moonbit.incref (param $ptr i32)
 (local $count i32)
 (local $rc_ptr i32)
 (local.set $rc_ptr
  (i32.sub
   (local.get $ptr)
   (i32.const 8)))
 (if
  (i32.ge_s
   (local.tee $count
    (i32.load
     (local.get $rc_ptr)))
   (i32.const 0))
  (then
   (i32.store
    (local.get $rc_ptr)
    (i32.add
     (local.get $count)
     (i32.const 1))))
  (else)))
(func $moonbit.decref (param $ptr i32)
 (local $count i32)
 (local $rc_ptr i32)
 (local.set $rc_ptr
  (i32.sub
   (local.get $ptr)
   (i32.const 8)))
 (if
  (i32.gt_s
   (local.tee $count
    (i32.load
     (local.get $rc_ptr)))
   (i32.const 1))
  (then
   (i32.store
    (local.get $rc_ptr)
    (i32.sub
     (local.get $count)
     (i32.const 1))))
  (else
   (if
    (i32.eq
     (local.get $count)
     (i32.const 1))
    (then
     (call $moonbit.gc.free
      (local.get $ptr)))
    (else)))))
(func $moonbit.gc.free (param $ptr i32)
 (local $parent i32)
 (local $curr_child_offset i32)
 (local $remaining_children_count i32)
 (local $n_ptr_fields i32)
 (local $ptr_fields_offset i32)
 (local $kind i32)
 (local $ref_array_kind i32)
 (local $vt_ptr i32)
 (local $vt_ptr_index i32)
 (local $vt_ptr_fields_offset i32)
 (local $vt_n_ptr_fields i32)
 (local $vt_header i32)
 (local $meta i32)
 (local $next i32)
 (local $addr_of_next i32)
 (local $len i32)
 (local $count i32)
 (local $free_ptr i32)
 (loop $handle_new_object
  (local.set $free_ptr
   (i32.sub
    (local.get $ptr)
    (i32.const 8)))
  (local.set $kind
   (i32.shr_u
    (local.tee $meta
     (i32.load
      (i32.sub
       (local.get $ptr)
       (i32.const 4))))
    (i32.const 30)))
  (block $cond_has_children
   (if
    (i32.eq
     (i32.const 0)
     (local.get $kind))
    (then
     (if
      (i32.eqz
       (local.tee $n_ptr_fields
        (i32.and
         (i32.shr_u
          (local.get $meta)
          (i32.const 8))
         (i32.const 2047))))
      (then)
      (else
       (local.set $ptr_fields_offset
        (i32.and
         (i32.shr_u
          (local.get $meta)
          (i32.const 19))
         (i32.const 2047)))
       (local.set $curr_child_offset
        (local.get $ptr_fields_offset))
       (local.set $remaining_children_count
        (local.get $n_ptr_fields))
       (br $cond_has_children))))
    (else
     (if
      (i32.eq
       (i32.const 2)
       (local.get $kind))
      (then
       (local.set $ref_array_kind
        (i32.and
         (i32.const 3)
         (i32.shr_u
          (local.get $meta)
          (i32.const 28))))
       (if
        (i32.eq
         (i32.const 1)
         (local.get $ref_array_kind))
        (then
         (local.set $len
          (i32.and
           (local.get $meta)
           (i32.const 268435455)))
         (local.set $free_ptr
          (i32.sub
           (local.get $free_ptr)
           (i32.const 8)))
         (local.set $vt_header
          (i32.load
           (i32.sub
            (local.get $ptr)
            (i32.add
             (i32.const 8)
             (i32.const 8)))))
         (local.set $vt_n_ptr_fields
          (i32.and
           (i32.const 2047)
           (i32.shr_u
            (local.get $vt_header)
            (i32.const 8))))
         (local.set $vt_ptr_fields_offset
          (i32.and
           (i32.const 2047)
           (i32.shr_u
            (local.get $vt_header)
            (i32.const 19))))
         (local.set $vt_ptr
          (local.get $ptr))
         (loop $vt_elems_loop
          (if
           (i32.gt_s
            (local.get $len)
            (i32.const 0))
           (then
            (local.set $len
             (i32.sub
              (local.get $len)
              (i32.const 1)))
            (local.set $vt_ptr_index
             (i32.const 0))
            (local.set $vt_ptr
             (i32.add
              (local.get $vt_ptr)
              (i32.mul
               (local.get $vt_ptr_fields_offset)
               (i32.const 4))))
            (loop $vt_ptrs_loop
             (if
              (i32.lt_s
               (local.get $vt_ptr_index)
               (local.get $vt_n_ptr_fields))
              (then
               (i32.load
                (local.get $vt_ptr))
               (if
                (i32.ne
                 (i32.const 0))
                (then
                 (call $moonbit.decref
                  (i32.load
                   (local.get $vt_ptr))))
                (else))
               (local.set $vt_ptr_index
                (i32.add
                 (local.get $vt_ptr_index)
                 (i32.const 1)))
               (local.set $vt_ptr
                (i32.add
                 (local.get $vt_ptr)
                 (i32.const 4)))
               (br $vt_ptrs_loop))
              (else)))
            (br $vt_elems_loop))
           (else))))
        (else
         (local.set $len
          (i32.and
           (local.get $meta)
           (i32.const 268435455)))
         (if
          (i32.gt_s
           (local.get $len)
           (i32.const 0))
          (then
           (local.set $curr_child_offset
            (i32.const 0))
           (local.set $remaining_children_count
            (local.get $len))
           (br $cond_has_children))
          (else)))))
      (else
       (if
        (i32.eq
         (i32.const 1)
         (local.get $kind))
        (then)
        (else
         (unreachable)))))))
   (call $moonbit.free
    (local.get $free_ptr))
   (if
    (i32.eqz
     (local.get $parent))
    (then
     (return))
    (else))
   (local.set $curr_child_offset
    (call $moonbit.get_ref_cnt
     (local.get $parent)))
   (local.set $remaining_children_count
    (i32.load
     (i32.sub
      (local.get $parent)
      (i32.const 4))))
   (local.set $ptr
    (local.get $parent))
   (local.set $free_ptr
    (i32.sub
     (local.get $ptr)
     (i32.const 8)))
   (local.set $parent
    (i32.load
     (i32.add
      (local.get $ptr)
      (i32.mul
       (local.get $curr_child_offset)
       (i32.const 4)))))
   (local.set $curr_child_offset
    (i32.add
     (local.get $curr_child_offset)
     (i32.const 1))))
  (loop $process_children
   (loop $process_children_loop
    (if
     (i32.gt_s
      (local.get $remaining_children_count)
      (i32.const 0))
     (then
      (local.set $remaining_children_count
       (i32.sub
        (local.get $remaining_children_count)
        (i32.const 1)))
      (if
       (i32.eqz
        (local.tee $next
         (i32.load
          (local.tee $addr_of_next
           (i32.add
            (local.get $ptr)
            (i32.mul
             (local.get $curr_child_offset)
             (i32.const 4)))))))
       (then
        (local.set $curr_child_offset
         (i32.add
          (local.get $curr_child_offset)
          (i32.const 1)))
        (br $process_children_loop))
       (else))
      (if
       (i32.gt_s
        (local.tee $count
         (i32.load
          (i32.sub
           (local.get $next)
           (i32.const 8))))
        (i32.const 1))
       (then
        (i32.store
         (i32.sub
          (local.get $next)
          (i32.const 8))
         (i32.sub
          (local.get $count)
          (i32.const 1))))
       (else
        (if
         (i32.eq
          (local.get $count)
          (i32.const 1))
         (then
          (if
           (i32.eq
            (local.get $remaining_children_count)
            (i32.const 0))
           (then
            (call $moonbit.free
             (local.get $free_ptr)))
           (else
            (call $moonbit.set_ref_cnt
             (local.get $ptr)
             (local.get $curr_child_offset))
            (call $moonbit.store_object_meta
             (local.get $ptr)
             (local.get $remaining_children_count))
            (i32.store
             (local.get $addr_of_next)
             (local.get $parent))
            (local.set $parent
             (local.get $ptr))))
          (local.set $ptr
           (local.get $next))
          (br $handle_new_object))
         (else))))
      (local.set $curr_child_offset
       (i32.add
        (local.get $curr_child_offset)
        (i32.const 1)))
      (br $process_children_loop))
     (else)))
   (call $moonbit.free
    (local.get $free_ptr))
   (if
    (i32.eqz
     (local.get $parent))
    (then
     (return))
    (else))
   (local.set $curr_child_offset
    (call $moonbit.get_ref_cnt
     (local.get $parent)))
   (local.set $remaining_children_count
    (i32.load
     (i32.sub
      (local.get $parent)
      (i32.const 4))))
   (local.set $ptr
    (local.get $parent))
   (local.set $free_ptr
    (i32.sub
     (local.get $ptr)
     (i32.const 8)))
   (local.set $parent
    (i32.load
     (i32.add
      (local.get $ptr)
      (i32.mul
       (local.get $curr_child_offset)
       (i32.const 4)))))
   (local.set $curr_child_offset
    (i32.add
     (local.get $curr_child_offset)
     (i32.const 1)))
   (br $process_children))
  (unreachable)))
(table $moonbit.global 1 1 funcref )
(elem
 (table $moonbit.global) (offset (i32.const 1))
 funcref
 )
(global $_M0FP48moonarc34rhae3src4rhae8zt__init
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae8hash__hi
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae14tt__store__arr
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae10tt__lookupN5tupleS577
 i32
 (i32.const 10008)
)
(global $_M0FP48moonarc34rhae3src4rhae6zt__hi
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae6zt__lo
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae8inv__buf
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae8vis__buf
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae8mat__buf
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae9prev__buf
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae9grid__buf
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae13visited__bits
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae9risk__buf
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae9topk__buf
 (mut i32)
 (i32.const 0)
)
(func $_M0FP48moonarc34rhae3src4rhae17normalize__colors (param $_M0L4gridS415 i32) (param $_M0L1nS412 i32) (param $_M0L3outS420 i32) (result i32)
 (local $_M0L5remapS409 i32)
 (local $_M0L7_2abindS413 i32)
 (local $_M0L1cS414 i32)
 (local $_M0L7_2abindS416 i32)
 (local $_M0L2mcS417 i32)
 (local $_M0L7_2abindS418 i32)
 (local $_M0L7_2abindS419 i32)
 (local $_M0L3lenS1007 i32)
 (local $_M0L3bufS1008 i32)
 (local $_M0L6_2atmpS1009 i32)
 (local $_M0L3lenS1010 i32)
 (local $_M0L3bufS1011 i32)
 (local $_M0L6_2atmpS1012 i32)
 (local $_M0L3lenS1013 i32)
 (local $_M0L3bufS1014 i32)
 (local $_M0L6_2atmpS1015 i32)
 (local $_M0L3lenS1016 i32)
 (local $_M0L3bufS1017 i32)
 (local $_M0L3lenS1018 i32)
 (local $_M0L3bufS1019 i32)
 (local $_M0L3lenS1020 i32)
 (local $_M0L3bufS1021 i32)
 (local $_M0Lm7next__cS410 i32)
 (local $_M0Lm1iS411 i32)
 (local.set $_M0L3lenS1007
  (i32.load
   (local.tee $_M0L5remapS409
    (call $_M0MPC15array5Array4makeGiE
     (i32.const 16)
     (i32.const -1)))))
 (if
  (i32.ge_s
   (i32.const 0)
   (local.get $_M0L3lenS1007))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS1008
    (i32.load offset=4
     (local.get $_M0L5remapS409)))
   (i32.shl
    (i32.const 0)
    (i32.const 2)))
  (i32.const 0))
 (local.set $_M0Lm7next__cS410
  (i32.const 1))
 (local.set $_M0Lm1iS411
  (i32.const 0))
 (loop $loop:421
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS1009
     (local.get $_M0Lm1iS411))
    (local.get $_M0L1nS412))
   (then
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS413
        (local.get $_M0Lm1iS411))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS1020
        (i32.load
         (local.get $_M0L4gridS415)))
       (i32.ge_s
        (local.get $_M0L7_2abindS413)
        (local.get $_M0L3lenS1020))))
     (then
      (unreachable))
     (else))
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L1cS414
        (i32.load
         (i32.add
          (local.tee $_M0L3bufS1021
           (i32.load offset=4
            (local.get $_M0L4gridS415)))
          (i32.shl
           (local.get $_M0L7_2abindS413)
           (i32.const 2)))))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS1018
        (i32.load
         (local.get $_M0L5remapS409)))
       (i32.ge_s
        (local.get $_M0L1cS414)
        (local.get $_M0L3lenS1018))))
     (then
      (unreachable))
     (else))
    (local.set $_M0L2mcS417
     (if (result i32)
      (i32.eq
       (local.tee $_M0L7_2abindS416
        (i32.load
         (i32.add
          (local.tee $_M0L3bufS1019
           (i32.load offset=4
            (local.get $_M0L5remapS409)))
          (i32.shl
           (local.get $_M0L1cS414)
           (i32.const 2)))))
       (i32.const -1))
      (then
       (local.set $_M0L7_2abindS418
        (local.get $_M0Lm7next__cS410))
       (if
        (if (result i32)
         (i32.lt_s
          (local.get $_M0L1cS414)
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS1013
           (i32.load
            (local.get $_M0L5remapS409)))
          (i32.ge_s
           (local.get $_M0L1cS414)
           (local.get $_M0L3lenS1013))))
        (then
         (unreachable))
        (else))
       (i32.store
        (i32.add
         (local.tee $_M0L3bufS1014
          (i32.load offset=4
           (local.get $_M0L5remapS409)))
         (i32.shl
          (local.get $_M0L1cS414)
          (i32.const 2)))
        (local.get $_M0L7_2abindS418))
       (local.set $_M0Lm7next__cS410
        (i32.add
         (local.tee $_M0L6_2atmpS1015
          (local.get $_M0Lm7next__cS410))
         (i32.const 1)))
       (if
        (if (result i32)
         (i32.lt_s
          (local.get $_M0L1cS414)
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS1016
           (i32.load
            (local.get $_M0L5remapS409)))
          (i32.ge_s
           (local.get $_M0L1cS414)
           (local.get $_M0L3lenS1016))))
        (then
         (unreachable))
        (else))
       (i32.load
        (i32.add
         (local.tee $_M0L3bufS1017
          (i32.load offset=4
           (local.get $_M0L5remapS409)))
         (i32.shl
          (local.get $_M0L1cS414)
          (i32.const 2)))))
      (else
       (local.get $_M0L7_2abindS416))))
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS419
        (local.get $_M0Lm1iS411))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS1010
        (i32.load
         (local.get $_M0L3outS420)))
       (i32.ge_s
        (local.get $_M0L7_2abindS419)
        (local.get $_M0L3lenS1010))))
     (then
      (unreachable))
     (else))
    (i32.store
     (i32.add
      (local.tee $_M0L3bufS1011
       (i32.load offset=4
        (local.get $_M0L3outS420)))
      (i32.shl
       (local.get $_M0L7_2abindS419)
       (i32.const 2)))
     (local.get $_M0L2mcS417))
    (local.set $_M0Lm1iS411
     (i32.add
      (local.tee $_M0L6_2atmpS1012
       (local.get $_M0Lm1iS411))
      (i32.const 1)))
    (br $loop:421))
   (else
    (call $moonbit.decref
     (local.get $_M0L5remapS409)))))
 (local.get $_M0Lm7next__cS410))
(func $_M0FP48moonarc34rhae3src4rhae18canonicalize__grid (param $_M0L4gridS388 i32) (param $_M0L1hS383 i32) (param $_M0L1wS385 i32) (param $_M0L8out__bufS387 i32) (result i32)
 (local $_M0L7best__tS381 i32)
 (local $_M0L7best__hS382 i32)
 (local $_M0L7best__wS384 i32)
 (local $_M0L6_2aenvS386 i32)
 (local $_M0L1tS390 i32)
 (local $_M0L16_2areturn__valueS392 i32)
 (local $_M0L7_2abindS393 i32)
 (local $_M0L5_2aohS394 i32)
 (local $_M0L5_2aowS395 i32)
 (local $_M0L7_2abindS399 i32)
 (local $_M0L5_2asrS400 i32)
 (local $_M0L5_2ascS401 i32)
 (local $_M0L7_2abindS402 i32)
 (local $_M0L1vS403 i32)
 (local $_M0L7_2abindS404 i32)
 (local $_M0L3curS405 i32)
 (local $_M0L6_2atmpS988 i32)
 (local $_M0L3valS989 i32)
 (local $_M0L3valS990 i32)
 (local $_M0L6_2atmpS991 i32)
 (local $_M0L6_2atmpS992 i32)
 (local $_M0L6_2atmpS993 i32)
 (local $_M0L6_2atmpS994 i32)
 (local $_M0L3lenS995 i32)
 (local $_M0L3bufS996 i32)
 (local $_M0L3lenS997 i32)
 (local $_M0L3bufS998 i32)
 (local $_M0L6_2atmpS999 i32)
 (local $_M0L6_2atmpS1000 i32)
 (local $_M0L6_2atmpS1001 i32)
 (local $_M0L6_2atmpS1002 i32)
 (local $_M0L6_2atmpS1003 i32)
 (local $_M0L6_2atmpS1004 i32)
 (local $_M0L3valS1005 i32)
 (local $_M0L3valS1006 i32)
 (local $_M0L3ptrS1145 i32)
 (local $_M0L3ptrS1147 i32)
 (local $_M0L3ptrS1148 i32)
 (local $_M0L3ptrS1149 i32)
 (local $_M0L3ptrS1150 i32)
 (local $_M0Lm1tS389 i32)
 (local $_M0Lm1iS396 i32)
 (local $_M0Lm1rS397 i32)
 (local $_M0Lm1cS398 i32)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1150
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1150)
  (i32.const 0))
 (local.set $_M0L7best__tS381
  (local.get $_M0L3ptrS1150))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1149
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1149)
  (local.get $_M0L1hS383))
 (local.set $_M0L7best__hS382
  (local.get $_M0L3ptrS1149))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1148
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1148)
  (local.get $_M0L1wS385))
 (local.set $_M0L7best__wS384
  (local.get $_M0L3ptrS1148))
 (call $moonbit.incref
  (local.get $_M0L8out__bufS387))
 (call $moonbit.incref
  (local.get $_M0L7best__wS384))
 (call $moonbit.incref
  (local.get $_M0L7best__hS382))
 (call $moonbit.incref
  (local.get $_M0L4gridS388))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1147
   (call $moonbit.gc.malloc
    (i32.const 28)))
  (i32.const 1049856))
 (i32.store offset=24
  (local.get $_M0L3ptrS1147)
  (local.get $_M0L4gridS388))
 (i32.store offset=4
  (local.get $_M0L3ptrS1147)
  (local.get $_M0L1hS383))
 (i32.store
  (local.get $_M0L3ptrS1147)
  (local.get $_M0L1wS385))
 (i32.store offset=20
  (local.get $_M0L3ptrS1147)
  (local.get $_M0L7best__hS382))
 (i32.store offset=16
  (local.get $_M0L3ptrS1147)
  (local.get $_M0L7best__tS381))
 (i32.store offset=12
  (local.get $_M0L3ptrS1147)
  (local.get $_M0L7best__wS384))
 (i32.store offset=8
  (local.get $_M0L3ptrS1147)
  (local.get $_M0L8out__bufS387))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN8write__tS17
   (local.tee $_M0L6_2aenvS386
    (local.get $_M0L3ptrS1147))
   (i32.const 0)))
 (local.set $_M0Lm1tS389
  (i32.const 1))
 (loop $loop:408
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS988
     (local.get $_M0Lm1tS389))
    (i32.const 8))
   (then
    (local.set $_M0L1tS390
     (local.get $_M0Lm1tS389))
    (block $outer/1146 (result i32)
     (block $join:391
      (local.set $_M0L5_2aohS394
       (i32.load
        (local.tee $_M0L7_2abindS393
         (call $_M0FP48moonarc34rhae3src4rhae13d4__out__dims
          (local.get $_M0L1hS383)
          (local.get $_M0L1wS385)
          (local.get $_M0L1tS390)))))
      (i32.load offset=4
       (local.get $_M0L7_2abindS393))
      (call $moonbit.decref
       (local.get $_M0L7_2abindS393))
      (local.set $_M0L5_2aowS395)
      (local.set $_M0L3valS990
       (i32.load
        (local.get $_M0L7best__hS382)))
      (local.get $_M0L5_2aohS394)
      (if
       (if (result i32)
        (i32.ne
         (local.get $_M0L3valS990))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3valS989
          (i32.load
           (local.get $_M0L7best__wS384)))
         (local.get $_M0L5_2aowS395)
         (i32.ne
          (local.get $_M0L3valS989))))
       (then
        (local.set $_M0L16_2areturn__valueS392
         (i32.const 0))
        (br $join:391))
       (else))
      (local.set $_M0Lm1iS396
       (i32.const 0))
      (local.set $_M0Lm1rS397
       (i32.const 0))
      (loop $loop:407
       (if
        (i32.lt_s
         (local.tee $_M0L6_2atmpS991
          (local.get $_M0Lm1rS397))
         (local.get $_M0L5_2aohS394))
        (then
         (local.set $_M0Lm1cS398
          (i32.const 0))
         (loop $loop:406
          (if
           (i32.lt_s
            (local.tee $_M0L6_2atmpS992
             (local.get $_M0Lm1cS398))
            (local.get $_M0L5_2aowS395))
           (then
            (local.set $_M0L6_2atmpS1000
             (local.get $_M0Lm1rS397))
            (local.set $_M0L6_2atmpS1001
             (local.get $_M0Lm1cS398))
            (local.set $_M0L5_2asrS400
             (i32.load
              (local.tee $_M0L7_2abindS399
               (call $_M0FP48moonarc34rhae3src4rhae7d4__src
                (local.get $_M0L6_2atmpS1000)
                (local.get $_M0L6_2atmpS1001)
                (local.get $_M0L1hS383)
                (local.get $_M0L1wS385)
                (local.get $_M0L1tS390)))))
            (i32.load offset=4
             (local.get $_M0L7_2abindS399))
            (call $moonbit.decref
             (local.get $_M0L7_2abindS399))
            (local.set $_M0L5_2ascS401)
            (if
             (if (result i32)
              (i32.lt_s
               (local.tee $_M0L7_2abindS402
                (i32.add
                 (local.tee $_M0L6_2atmpS999
                  (i32.mul
                   (local.get $_M0L5_2asrS400)
                   (local.get $_M0L1wS385)))
                 (local.get $_M0L5_2ascS401)))
               (i32.const 0))
              (then
               (i32.const 1))
              (else
               (local.set $_M0L3lenS997
                (i32.load
                 (local.get $_M0L4gridS388)))
               (i32.ge_s
                (local.get $_M0L7_2abindS402)
                (local.get $_M0L3lenS997))))
             (then
              (unreachable))
             (else))
            (local.set $_M0L1vS403
             (i32.load
              (i32.add
               (local.tee $_M0L3bufS998
                (i32.load offset=4
                 (local.get $_M0L4gridS388)))
               (i32.shl
                (local.get $_M0L7_2abindS402)
                (i32.const 2)))))
            (if
             (if (result i32)
              (i32.lt_s
               (local.tee $_M0L7_2abindS404
                (local.get $_M0Lm1iS396))
               (i32.const 0))
              (then
               (i32.const 1))
              (else
               (local.set $_M0L3lenS995
                (i32.load
                 (local.get $_M0L8out__bufS387)))
               (i32.ge_s
                (local.get $_M0L7_2abindS404)
                (local.get $_M0L3lenS995))))
             (then
              (unreachable))
             (else))
            (local.set $_M0L3curS405
             (i32.load
              (i32.add
               (local.tee $_M0L3bufS996
                (i32.load offset=4
                 (local.get $_M0L8out__bufS387)))
               (i32.shl
                (local.get $_M0L7_2abindS404)
                (i32.const 2)))))
            (if
             (i32.lt_s
              (local.get $_M0L1vS403)
              (local.get $_M0L3curS405))
             (then
              (local.set $_M0L16_2areturn__valueS392
               (i32.const 1))
              (br $join:391))
             (else))
            (if
             (i32.gt_s
              (local.get $_M0L1vS403)
              (local.get $_M0L3curS405))
             (then
              (local.set $_M0L16_2areturn__valueS392
               (i32.const 0))
              (br $join:391))
             (else))
            (local.set $_M0Lm1iS396
             (i32.add
              (local.tee $_M0L6_2atmpS993
               (local.get $_M0Lm1iS396))
              (i32.const 1)))
            (local.set $_M0Lm1cS398
             (i32.add
              (local.tee $_M0L6_2atmpS994
               (local.get $_M0Lm1cS398))
              (i32.const 1)))
            (br $loop:406))
           (else)))
         (local.set $_M0Lm1rS397
          (i32.add
           (local.tee $_M0L6_2atmpS1002
            (local.get $_M0Lm1rS397))
           (i32.const 1)))
         (br $loop:407))
        (else)))
      (i32.const 0)
      (br $outer/1146))
     (local.get $_M0L16_2areturn__valueS392))
    (if
     (then
      (local.set $_M0L6_2atmpS1003
       (local.get $_M0Lm1tS389))
      (drop
       (call $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN8write__tS17
        (local.get $_M0L6_2aenvS386)
        (local.get $_M0L6_2atmpS1003))))
     (else))
    (local.set $_M0Lm1tS389
     (i32.add
      (local.tee $_M0L6_2atmpS1004
       (local.get $_M0Lm1tS389))
      (i32.const 1)))
    (br $loop:408))
   (else
    (call $moonbit.decref
     (local.get $_M0L6_2aenvS386)))))
 (i32.load
  (local.get $_M0L7best__hS382))
 (call $moonbit.decref
  (local.get $_M0L7best__hS382))
 (local.set $_M0L3valS1005)
 (i32.load
  (local.get $_M0L7best__wS384))
 (call $moonbit.decref
  (local.get $_M0L7best__wS384))
 (local.set $_M0L3valS1006)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1145
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1145)
  (local.get $_M0L3valS1006))
 (i32.store
  (local.get $_M0L3ptrS1145)
  (local.get $_M0L3valS1005))
 (local.get $_M0L3ptrS1145))
(func $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN8write__tS17 (param $_M0L6_2aenvS359 i32) (param $_M0L1tS367 i32) (result i32)
 (local $_M0L4gridS358 i32)
 (local $_M0L1hS360 i32)
 (local $_M0L1wS361 i32)
 (local $_M0L7best__hS362 i32)
 (local $_M0L7best__tS363 i32)
 (local $_M0L7best__wS364 i32)
 (local $_M0L8out__bufS365 i32)
 (local $_M0L7_2abindS366 i32)
 (local $_M0L5_2aohS368 i32)
 (local $_M0L5_2aowS369 i32)
 (local $_M0L7_2abindS373 i32)
 (local $_M0L5_2asrS374 i32)
 (local $_M0L5_2ascS375 i32)
 (local $_M0L7_2abindS376 i32)
 (local $_M0L7_2abindS377 i32)
 (local $_M0L7_2abindS378 i32)
 (local $_M0L6_2atmpS976 i32)
 (local $_M0L6_2atmpS977 i32)
 (local $_M0L3lenS978 i32)
 (local $_M0L3bufS979 i32)
 (local $_M0L3lenS980 i32)
 (local $_M0L3bufS981 i32)
 (local $_M0L6_2atmpS982 i32)
 (local $_M0L6_2atmpS983 i32)
 (local $_M0L6_2atmpS984 i32)
 (local $_M0L6_2atmpS985 i32)
 (local $_M0L6_2atmpS986 i32)
 (local $_M0L6_2atmpS987 i32)
 (local $_M0Lm1iS370 i32)
 (local $_M0Lm1rS371 i32)
 (local $_M0Lm1cS372 i32)
 (local.set $_M0L4gridS358
  (i32.load offset=24
   (local.get $_M0L6_2aenvS359)))
 (local.set $_M0L1hS360
  (i32.load offset=4
   (local.get $_M0L6_2aenvS359)))
 (local.set $_M0L1wS361
  (i32.load
   (local.get $_M0L6_2aenvS359)))
 (local.set $_M0L7best__hS362
  (i32.load offset=20
   (local.get $_M0L6_2aenvS359)))
 (local.set $_M0L7best__tS363
  (i32.load offset=16
   (local.get $_M0L6_2aenvS359)))
 (local.set $_M0L7best__wS364
  (i32.load offset=12
   (local.get $_M0L6_2aenvS359)))
 (local.set $_M0L8out__bufS365
  (i32.load offset=8
   (local.get $_M0L6_2aenvS359)))
 (local.set $_M0L5_2aohS368
  (i32.load
   (local.tee $_M0L7_2abindS366
    (call $_M0FP48moonarc34rhae3src4rhae13d4__out__dims
     (local.get $_M0L1hS360)
     (local.get $_M0L1wS361)
     (local.get $_M0L1tS367)))))
 (i32.load offset=4
  (local.get $_M0L7_2abindS366))
 (call $moonbit.decref
  (local.get $_M0L7_2abindS366))
 (local.set $_M0L5_2aowS369)
 (local.set $_M0Lm1iS370
  (i32.const 0))
 (local.set $_M0Lm1rS371
  (i32.const 0))
 (loop $loop:380
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS976
     (local.get $_M0Lm1rS371))
    (local.get $_M0L5_2aohS368))
   (then
    (local.set $_M0Lm1cS372
     (i32.const 0))
    (loop $loop:379
     (if
      (i32.lt_s
       (local.tee $_M0L6_2atmpS977
        (local.get $_M0Lm1cS372))
       (local.get $_M0L5_2aowS369))
      (then
       (local.set $_M0L6_2atmpS985
        (local.get $_M0Lm1rS371))
       (local.set $_M0L6_2atmpS986
        (local.get $_M0Lm1cS372))
       (local.set $_M0L5_2asrS374
        (i32.load
         (local.tee $_M0L7_2abindS373
          (call $_M0FP48moonarc34rhae3src4rhae7d4__src
           (local.get $_M0L6_2atmpS985)
           (local.get $_M0L6_2atmpS986)
           (local.get $_M0L1hS360)
           (local.get $_M0L1wS361)
           (local.get $_M0L1tS367)))))
       (i32.load offset=4
        (local.get $_M0L7_2abindS373))
       (call $moonbit.decref
        (local.get $_M0L7_2abindS373))
       (local.set $_M0L5_2ascS375)
       (local.set $_M0L7_2abindS376
        (local.get $_M0Lm1iS370))
       (if
        (if (result i32)
         (i32.lt_s
          (local.tee $_M0L7_2abindS377
           (i32.add
            (local.tee $_M0L6_2atmpS982
             (i32.mul
              (local.get $_M0L5_2asrS374)
              (local.get $_M0L1wS361)))
            (local.get $_M0L5_2ascS375)))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS980
           (i32.load
            (local.get $_M0L4gridS358)))
          (i32.ge_s
           (local.get $_M0L7_2abindS377)
           (local.get $_M0L3lenS980))))
        (then
         (unreachable))
        (else))
       (local.set $_M0L7_2abindS378
        (i32.load
         (i32.add
          (local.tee $_M0L3bufS981
           (i32.load offset=4
            (local.get $_M0L4gridS358)))
          (i32.shl
           (local.get $_M0L7_2abindS377)
           (i32.const 2)))))
       (if
        (if (result i32)
         (i32.lt_s
          (local.get $_M0L7_2abindS376)
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS978
           (i32.load
            (local.get $_M0L8out__bufS365)))
          (i32.ge_s
           (local.get $_M0L7_2abindS376)
           (local.get $_M0L3lenS978))))
        (then
         (unreachable))
        (else))
       (i32.store
        (i32.add
         (local.tee $_M0L3bufS979
          (i32.load offset=4
           (local.get $_M0L8out__bufS365)))
         (i32.shl
          (local.get $_M0L7_2abindS376)
          (i32.const 2)))
        (local.get $_M0L7_2abindS378))
       (local.set $_M0Lm1iS370
        (i32.add
         (local.tee $_M0L6_2atmpS983
          (local.get $_M0Lm1iS370))
         (i32.const 1)))
       (local.set $_M0Lm1cS372
        (i32.add
         (local.tee $_M0L6_2atmpS984
          (local.get $_M0Lm1cS372))
         (i32.const 1)))
       (br $loop:379))
      (else)))
    (local.set $_M0Lm1rS371
     (i32.add
      (local.tee $_M0L6_2atmpS987
       (local.get $_M0Lm1rS371))
      (i32.const 1)))
    (br $loop:380))
   (else)))
 (i32.store
  (local.get $_M0L7best__hS362)
  (local.get $_M0L5_2aohS368))
 (i32.store
  (local.get $_M0L7best__wS364)
  (local.get $_M0L5_2aowS369))
 (i32.store
  (local.get $_M0L7best__tS363)
  (local.get $_M0L1tS367))
 (i32.const 0))
(func $_M0FP48moonarc34rhae3src4rhae13d4__out__dims (param $_M0L1hS356 i32) (param $_M0L1wS355 i32) (param $_M0L1tS357 i32) (result i32)
 (local $_M0L3ptrS1151 i32)
 (local $_M0L3ptrS1152 i32)
 (block $join:354
  (if (result i32)
   (i32.eq
    (local.get $_M0L1tS357)
    (i32.const 1))
   (then
    (br $join:354))
   (else
    (if (result i32)
     (i32.eq
      (local.get $_M0L1tS357)
      (i32.const 3))
     (then
      (br $join:354))
     (else
      (if (result i32)
       (i32.eq
        (local.get $_M0L1tS357)
        (i32.const 6))
       (then
        (br $join:354))
       (else
        (if (result i32)
         (i32.eq
          (local.get $_M0L1tS357)
          (i32.const 7))
         (then
          (br $join:354))
         (else
          (call $moonbit.store_object_meta
           (local.tee $_M0L3ptrS1151
            (call $moonbit.gc.malloc
             (i32.const 8)))
           (i32.const 1048576))
          (i32.store offset=4
           (local.get $_M0L3ptrS1151)
           (local.get $_M0L1wS355))
          (i32.store
           (local.get $_M0L3ptrS1151)
           (local.get $_M0L1hS356))
          (local.get $_M0L3ptrS1151)))))))))
  (return))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1152
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1152)
  (local.get $_M0L1hS356))
 (i32.store
  (local.get $_M0L3ptrS1152)
  (local.get $_M0L1wS355))
 (local.get $_M0L3ptrS1152))
(func $_M0FP48moonarc34rhae3src4rhae7d4__src (param $_M0L6out__rS350 i32) (param $_M0L6out__cS351 i32) (param $_M0L1hS352 i32) (param $_M0L1wS353 i32) (param $_M0L1tS349 i32) (result i32)
 (local $_M0L6_2atmpS960 i32)
 (local $_M0L6_2atmpS961 i32)
 (local $_M0L6_2atmpS962 i32)
 (local $_M0L6_2atmpS963 i32)
 (local $_M0L6_2atmpS964 i32)
 (local $_M0L6_2atmpS965 i32)
 (local $_M0L6_2atmpS966 i32)
 (local $_M0L6_2atmpS967 i32)
 (local $_M0L6_2atmpS968 i32)
 (local $_M0L6_2atmpS969 i32)
 (local $_M0L6_2atmpS970 i32)
 (local $_M0L6_2atmpS971 i32)
 (local $_M0L6_2atmpS972 i32)
 (local $_M0L6_2atmpS973 i32)
 (local $_M0L6_2atmpS974 i32)
 (local $_M0L6_2atmpS975 i32)
 (local $_M0L3ptrS1153 i32)
 (local $_M0L3ptrS1154 i32)
 (local $_M0L3ptrS1155 i32)
 (local $_M0L3ptrS1156 i32)
 (local $_M0L3ptrS1157 i32)
 (local $_M0L3ptrS1158 i32)
 (local $_M0L3ptrS1159 i32)
 (local $_M0L3ptrS1160 i32)
 (local $_M0L3ptrS1161 i32)
 (block $switch_int/1162 (result i32)
  (block $switch_default/1163
   (block $switch_int_7/1171
    (block $switch_int_6/1170
     (block $switch_int_5/1169
      (block $switch_int_4/1168
       (block $switch_int_3/1167
        (block $switch_int_2/1166
         (block $switch_int_1/1165
          (block $switch_int_0/1164
           (local.get $_M0L1tS349)
           (br_table
            $switch_int_0/1164
            $switch_int_1/1165
            $switch_int_2/1166
            $switch_int_3/1167
            $switch_int_4/1168
            $switch_int_5/1169
            $switch_int_6/1170
            $switch_int_7/1171
            $switch_default/1163
            ))
          (call $moonbit.store_object_meta
           (local.tee $_M0L3ptrS1154
            (call $moonbit.gc.malloc
             (i32.const 8)))
           (i32.const 1048576))
          (i32.store offset=4
           (local.get $_M0L3ptrS1154)
           (local.get $_M0L6out__cS351))
          (i32.store
           (local.get $_M0L3ptrS1154)
           (local.get $_M0L6out__rS350))
          (local.get $_M0L3ptrS1154)
          (br $switch_int/1162))
         (local.set $_M0L6_2atmpS960
          (i32.sub
           (local.tee $_M0L6_2atmpS961
            (i32.sub
             (local.get $_M0L1hS352)
             (i32.const 1)))
           (local.get $_M0L6out__cS351)))
         (call $moonbit.store_object_meta
          (local.tee $_M0L3ptrS1155
           (call $moonbit.gc.malloc
            (i32.const 8)))
          (i32.const 1048576))
         (i32.store offset=4
          (local.get $_M0L3ptrS1155)
          (local.get $_M0L6out__rS350))
         (i32.store
          (local.get $_M0L3ptrS1155)
          (local.get $_M0L6_2atmpS960))
         (local.get $_M0L3ptrS1155)
         (br $switch_int/1162))
        (local.set $_M0L6_2atmpS962
         (i32.sub
          (local.tee $_M0L6_2atmpS965
           (i32.sub
            (local.get $_M0L1hS352)
            (i32.const 1)))
          (local.get $_M0L6out__rS350)))
        (local.set $_M0L6_2atmpS963
         (i32.sub
          (local.tee $_M0L6_2atmpS964
           (i32.sub
            (local.get $_M0L1wS353)
            (i32.const 1)))
          (local.get $_M0L6out__cS351)))
        (call $moonbit.store_object_meta
         (local.tee $_M0L3ptrS1156
          (call $moonbit.gc.malloc
           (i32.const 8)))
         (i32.const 1048576))
        (i32.store offset=4
         (local.get $_M0L3ptrS1156)
         (local.get $_M0L6_2atmpS963))
        (i32.store
         (local.get $_M0L3ptrS1156)
         (local.get $_M0L6_2atmpS962))
        (local.get $_M0L3ptrS1156)
        (br $switch_int/1162))
       (local.set $_M0L6_2atmpS966
        (i32.sub
         (local.tee $_M0L6_2atmpS967
          (i32.sub
           (local.get $_M0L1wS353)
           (i32.const 1)))
         (local.get $_M0L6out__rS350)))
       (call $moonbit.store_object_meta
        (local.tee $_M0L3ptrS1157
         (call $moonbit.gc.malloc
          (i32.const 8)))
        (i32.const 1048576))
       (i32.store offset=4
        (local.get $_M0L3ptrS1157)
        (local.get $_M0L6_2atmpS966))
       (i32.store
        (local.get $_M0L3ptrS1157)
        (local.get $_M0L6out__cS351))
       (local.get $_M0L3ptrS1157)
       (br $switch_int/1162))
      (local.set $_M0L6_2atmpS968
       (i32.sub
        (local.tee $_M0L6_2atmpS969
         (i32.sub
          (local.get $_M0L1wS353)
          (i32.const 1)))
        (local.get $_M0L6out__cS351)))
      (call $moonbit.store_object_meta
       (local.tee $_M0L3ptrS1158
        (call $moonbit.gc.malloc
         (i32.const 8)))
       (i32.const 1048576))
      (i32.store offset=4
       (local.get $_M0L3ptrS1158)
       (local.get $_M0L6_2atmpS968))
      (i32.store
       (local.get $_M0L3ptrS1158)
       (local.get $_M0L6out__rS350))
      (local.get $_M0L3ptrS1158)
      (br $switch_int/1162))
     (local.set $_M0L6_2atmpS970
      (i32.sub
       (local.tee $_M0L6_2atmpS971
        (i32.sub
         (local.get $_M0L1hS352)
         (i32.const 1)))
       (local.get $_M0L6out__rS350)))
     (call $moonbit.store_object_meta
      (local.tee $_M0L3ptrS1159
       (call $moonbit.gc.malloc
        (i32.const 8)))
      (i32.const 1048576))
     (i32.store offset=4
      (local.get $_M0L3ptrS1159)
      (local.get $_M0L6out__cS351))
     (i32.store
      (local.get $_M0L3ptrS1159)
      (local.get $_M0L6_2atmpS970))
     (local.get $_M0L3ptrS1159)
     (br $switch_int/1162))
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1160
      (call $moonbit.gc.malloc
       (i32.const 8)))
     (i32.const 1048576))
    (i32.store offset=4
     (local.get $_M0L3ptrS1160)
     (local.get $_M0L6out__rS350))
    (i32.store
     (local.get $_M0L3ptrS1160)
     (local.get $_M0L6out__cS351))
    (local.get $_M0L3ptrS1160)
    (br $switch_int/1162))
   (local.set $_M0L6_2atmpS972
    (i32.sub
     (local.tee $_M0L6_2atmpS975
      (i32.sub
       (local.get $_M0L1wS353)
       (i32.const 1)))
     (local.get $_M0L6out__cS351)))
   (local.set $_M0L6_2atmpS973
    (i32.sub
     (local.tee $_M0L6_2atmpS974
      (i32.sub
       (local.get $_M0L1hS352)
       (i32.const 1)))
     (local.get $_M0L6out__rS350)))
   (call $moonbit.store_object_meta
    (local.tee $_M0L3ptrS1161
     (call $moonbit.gc.malloc
      (i32.const 8)))
    (i32.const 1048576))
   (i32.store offset=4
    (local.get $_M0L3ptrS1161)
    (local.get $_M0L6_2atmpS973))
   (i32.store
    (local.get $_M0L3ptrS1161)
    (local.get $_M0L6_2atmpS972))
   (local.get $_M0L3ptrS1161)
   (br $switch_int/1162))
  (call $moonbit.store_object_meta
   (local.tee $_M0L3ptrS1153
    (call $moonbit.gc.malloc
     (i32.const 8)))
   (i32.const 1048576))
  (i32.store offset=4
   (local.get $_M0L3ptrS1153)
   (local.get $_M0L6out__cS351))
  (i32.store
   (local.get $_M0L3ptrS1153)
   (local.get $_M0L6out__rS350))
  (local.get $_M0L3ptrS1153)
  (br $switch_int/1162)))
(func $_M0FP48moonarc34rhae3src4rhae22rhae__hash__and__check (param $_M0L1hS340 i32) (param $_M0L1wS341 i32) (result i32)
 (local $_M0L2loS339 i32)
 (local $_M0L2hiS342 i32)
 (local $_M0L3visS343 i32)
 (local $_M0L7_2abindS344 i32)
 (local $_M0L4_2axS345 i32)
 (local $_M0L3tthS346 i32)
 (local.set $_M0L2loS339
  (call $_M0FP48moonarc34rhae3src4rhae21rhae__canonical__hash
   (local.get $_M0L1hS340)
   (local.get $_M0L1wS341)))
 (local.set $_M0L2hiS342
  (i32.load
   (global.get $_M0FP48moonarc34rhae3src4rhae8hash__hi)))
 (local.set $_M0L3visS343
  (if (result i32)
   (call $_M0FP48moonarc34rhae3src4rhae14visited__check
    (local.get $_M0L2loS339)
    (local.get $_M0L2hiS342))
   (then
    (i32.const 2))
   (else
    (i32.const 0))))
 (i32.load
  (local.tee $_M0L7_2abindS344
   (call $_M0FP48moonarc34rhae3src4rhae10tt__lookup
    (local.get $_M0L2loS339)
    (local.get $_M0L2hiS342))))
 (call $moonbit.decref
  (local.get $_M0L7_2abindS344))
 (local.tee $_M0L4_2axS345)
 (i32.const 1)
 (i32.eq)
 (if (result i32)
  (then
   (i32.const 1))
  (else
   (i32.const 0)))
 (local.set $_M0L3tthS346)
 (i32.or
  (local.get $_M0L3visS343)
  (local.get $_M0L3tthS346)))
(func $_M0FP48moonarc34rhae3src4rhae15rhae__tt__store (param $_M0L2loS335 i32) (param $_M0L2hiS336 i32) (param $_M0L6actionS337 i32) (param $_M0L5scoreS338 i32) (result i32)
 (call $_M0FP48moonarc34rhae3src4rhae9tt__store
  (local.get $_M0L2loS335)
  (local.get $_M0L2hiS336)
  (local.get $_M0L6actionS337)
  (local.get $_M0L5scoreS338)))
(func $_M0FP48moonarc34rhae3src4rhae16rhae__tt__lookup (param $_M0L2loS331 i32) (param $_M0L2hiS332 i32) (result i32)
 (local $_M0L7_2abindS330 i32)
 (local $_M0L8_2afoundS333 i32)
 (local $_M0L9_2aactionS334 i32)
 (local.set $_M0L8_2afoundS333
  (i32.load
   (local.tee $_M0L7_2abindS330
    (call $_M0FP48moonarc34rhae3src4rhae10tt__lookup
     (local.get $_M0L2loS331)
     (local.get $_M0L2hiS332)))))
 (i32.load offset=4
  (local.get $_M0L7_2abindS330))
 (call $moonbit.decref
  (local.get $_M0L7_2abindS330))
 (local.set $_M0L9_2aactionS334)
 (if (result i32)
  (local.get $_M0L8_2afoundS333)
  (then
   (local.get $_M0L9_2aactionS334))
  (else
   (i32.const -1))))
(func $_M0FP48moonarc34rhae3src4rhae10rhae__topk (param $_M0L7n__candS319 i32) (param $_M0L1kS329 i32) (result i32)
 (local $_M0L5pairsS317 i32)
 (local $_M0L1bS320 i32)
 (local $_M0L7_2abindS321 i32)
 (local $_M0L7_2abindS322 i32)
 (local $_M0L7_2abindS323 i32)
 (local $_M0L7_2abindS324 i32)
 (local $_M0L7_2abindS325 i32)
 (local $_M0L7_2abindS326 i32)
 (local $_M0L7_2abindS327 i32)
 (local $_M0L6_2atmpS938 i32)
 (local $_M0L3lenS939 i32)
 (local $_M0L3bufS940 i32)
 (local $_M0L3lenS941 i32)
 (local $_M0L3bufS942 i32)
 (local $_M0L6_2atmpS943 i32)
 (local $_M0L3lenS944 i32)
 (local $_M0L3bufS945 i32)
 (local $_M0L6_2atmpS946 i32)
 (local $_M0L6_2atmpS947 i32)
 (local $_M0L3lenS948 i32)
 (local $_M0L3bufS949 i32)
 (local $_M0L6_2atmpS950 i32)
 (local $_M0L6_2atmpS951 i32)
 (local $_M0L3lenS952 i32)
 (local $_M0L3bufS953 i32)
 (local $_M0L3lenS954 i32)
 (local $_M0L3bufS955 i32)
 (local $_M0L6_2atmpS956 i32)
 (local $_M0L6_2atmpS957 i32)
 (local $_M0L6_2atmpS958 i32)
 (local $_M0L6_2atmpS959 i32)
 (local $_M0Lm1iS318 i32)
 (local.set $_M0L5pairsS317
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 14)
   (i32.const 0)))
 (local.set $_M0Lm1iS318
  (i32.const 0))
 (loop $loop:328
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS938
     (local.get $_M0Lm1iS318))
    (local.get $_M0L7n__candS319))
   (then
    (local.set $_M0L1bS320
     (i32.mul
      (local.tee $_M0L6_2atmpS959
       (local.get $_M0Lm1iS318))
      (i32.const 13)))
    (local.set $_M0L7_2abindS321
     (i32.mul
      (local.tee $_M0L6_2atmpS943
       (local.get $_M0Lm1iS318))
      (i32.const 2)))
    (if
     (if (result i32)
      (i32.lt_s
       (local.get $_M0L1bS320)
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS941
        (i32.load
         (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)))
       (i32.ge_s
        (local.get $_M0L1bS320)
        (local.get $_M0L3lenS941))))
     (then
      (unreachable))
     (else))
    (local.set $_M0L7_2abindS322
     (i32.load
      (i32.add
       (local.tee $_M0L3bufS942
        (i32.load offset=4
         (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)))
       (i32.shl
        (local.get $_M0L1bS320)
        (i32.const 2)))))
    (if
     (if (result i32)
      (i32.lt_s
       (local.get $_M0L7_2abindS321)
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS939
        (i32.load
         (local.get $_M0L5pairsS317)))
       (i32.ge_s
        (local.get $_M0L7_2abindS321)
        (local.get $_M0L3lenS939))))
     (then
      (unreachable))
     (else))
    (i32.store
     (i32.add
      (local.tee $_M0L3bufS940
       (i32.load offset=4
        (local.get $_M0L5pairsS317)))
      (i32.shl
       (local.get $_M0L7_2abindS321)
       (i32.const 2)))
     (local.get $_M0L7_2abindS322))
    (local.set $_M0L7_2abindS323
     (i32.add
      (local.tee $_M0L6_2atmpS956
       (i32.mul
        (local.tee $_M0L6_2atmpS957
         (local.get $_M0Lm1iS318))
        (i32.const 2)))
      (i32.const 1)))
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS325
        (i32.add
         (local.get $_M0L1bS320)
         (i32.const 5)))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS954
        (i32.load
         (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)))
       (i32.ge_s
        (local.get $_M0L7_2abindS325)
        (local.get $_M0L3lenS954))))
     (then
      (unreachable))
     (else))
    (local.set $_M0L6_2atmpS950
     (i32.load
      (i32.add
       (local.tee $_M0L3bufS955
        (i32.load offset=4
         (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)))
       (i32.shl
        (local.get $_M0L7_2abindS325)
        (i32.const 2)))))
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS326
        (i32.add
         (local.get $_M0L1bS320)
         (i32.const 6)))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS952
        (i32.load
         (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)))
       (i32.ge_s
        (local.get $_M0L7_2abindS326)
        (local.get $_M0L3lenS952))))
     (then
      (unreachable))
     (else))
    (local.set $_M0L6_2atmpS951
     (i32.load
      (i32.add
       (local.tee $_M0L3bufS953
        (i32.load offset=4
         (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)))
       (i32.shl
        (local.get $_M0L7_2abindS326)
        (i32.const 2)))))
    (local.set $_M0L6_2atmpS946
     (i32.add
      (local.get $_M0L6_2atmpS950)
      (local.get $_M0L6_2atmpS951)))
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS327
        (i32.add
         (local.get $_M0L1bS320)
         (i32.const 4)))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS948
        (i32.load
         (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)))
       (i32.ge_s
        (local.get $_M0L7_2abindS327)
        (local.get $_M0L3lenS948))))
     (then
      (unreachable))
     (else))
    (local.set $_M0L6_2atmpS947
     (i32.load
      (i32.add
       (local.tee $_M0L3bufS949
        (i32.load offset=4
         (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)))
       (i32.shl
        (local.get $_M0L7_2abindS327)
        (i32.const 2)))))
    (local.set $_M0L7_2abindS324
     (i32.sub
      (local.get $_M0L6_2atmpS946)
      (local.get $_M0L6_2atmpS947)))
    (if
     (if (result i32)
      (i32.lt_s
       (local.get $_M0L7_2abindS323)
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS944
        (i32.load
         (local.get $_M0L5pairsS317)))
       (i32.ge_s
        (local.get $_M0L7_2abindS323)
        (local.get $_M0L3lenS944))))
     (then
      (unreachable))
     (else))
    (i32.store
     (i32.add
      (local.tee $_M0L3bufS945
       (i32.load offset=4
        (local.get $_M0L5pairsS317)))
      (i32.shl
       (local.get $_M0L7_2abindS323)
       (i32.const 2)))
     (local.get $_M0L7_2abindS324))
    (local.set $_M0Lm1iS318
     (i32.add
      (local.tee $_M0L6_2atmpS958
       (local.get $_M0Lm1iS318))
      (i32.const 1)))
    (br $loop:328))
   (else)))
 (call $_M0FP48moonarc34rhae3src4rhae16topk__candidates
  (local.get $_M0L5pairsS317)
  (local.get $_M0L7n__candS319)
  (local.get $_M0L1kS329)
  (global.get $_M0FP48moonarc34rhae3src4rhae9topk__buf))
 (call $moonbit.decref
  (local.get $_M0L5pairsS317)))
(func $_M0FP48moonarc34rhae3src4rhae23rhae__build__candidates (param $_M0L5legalS312 i32) (param $_M0L10path__costS313 i32) (param $_M0L8hash__loS314 i32) (param $_M0L10hash__hi__S315 i32) (param $_M0L6max__cS316 i32) (result i32)
 (call $_M0FP48moonarc34rhae3src4rhae22build__candidate__rows
  (local.get $_M0L5legalS312)
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (global.get $_M0FP48moonarc34rhae3src4rhae8vis__buf)
  (local.get $_M0L10path__costS313)
  (local.get $_M0L8hash__loS314)
  (local.get $_M0L10hash__hi__S315)
  (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
  (local.get $_M0L6max__cS316)))
(func $_M0FP48moonarc34rhae3src4rhae18rhae__policy__gate (param $_M0L5legalS308 i32) (param $_M0L1hS309 i32) (param $_M0L1wS310 i32) (param $_M0L10n__actionsS311 i32) (result i32)
 (call $_M0FP48moonarc34rhae3src4rhae12policy__gate
  (local.get $_M0L5legalS308)
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
  (local.get $_M0L1hS309)
  (local.get $_M0L1wS310)
  (global.get $_M0FP48moonarc34rhae3src4rhae9risk__buf)
  (local.get $_M0L10n__actionsS311)))
(func $_M0FP48moonarc34rhae3src4rhae20rhae__visited__reset (result i32)
 (call $_M0FP48moonarc34rhae3src4rhae14visited__reset))
(func $_M0FP48moonarc34rhae3src4rhae19rhae__visited__mark (param $_M0L2loS306 i32) (param $_M0L2hiS307 i32) (result i32)
 (call $_M0FP48moonarc34rhae3src4rhae13visited__mark
  (local.get $_M0L2loS306)
  (local.get $_M0L2hiS307)))
(func $_M0FP48moonarc34rhae3src4rhae20rhae__visited__check (param $_M0L2loS304 i32) (param $_M0L2hiS305 i32) (result i32)
 (if (result i32)
  (call $_M0FP48moonarc34rhae3src4rhae14visited__check
   (local.get $_M0L2loS304)
   (local.get $_M0L2hiS305))
  (then
   (i32.const 1))
  (else
   (i32.const 0))))
(func $_M0FP48moonarc34rhae3src4rhae21rhae__canonical__hash (param $_M0L1hS300 i32) (param $_M0L1wS301 i32) (result i32)
 (local $_M0L7_2abindS299 i32)
 (local $_M0L5_2aloS302 i32)
 (local $_M0L5_2ahiS303 i32)
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init))
 (local.set $_M0L5_2aloS302
  (i32.load
   (local.tee $_M0L7_2abindS299
    (call $_M0FP48moonarc34rhae3src4rhae15canonical__hash
     (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
     (local.get $_M0L1hS300)
     (local.get $_M0L1wS301)))))
 (i32.load offset=4
  (local.get $_M0L7_2abindS299))
 (call $moonbit.decref
  (local.get $_M0L7_2abindS299))
 (local.set $_M0L5_2ahiS303)
 (i32.store
  (global.get $_M0FP48moonarc34rhae3src4rhae8hash__hi)
  (local.get $_M0L5_2ahiS303))
 (local.get $_M0L5_2aloS302))
(func $_M0FP48moonarc34rhae3src4rhae16rhae__invariants (param $_M0L1hS297 i32) (param $_M0L1wS298 i32) (result i32)
 (local $_M0L3lenS936 i32)
 (local $_M0L3bufS937 i32)
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae19compute__invariants
   (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
   (global.get $_M0FP48moonarc34rhae3src4rhae9prev__buf)
   (local.get $_M0L1hS297)
   (local.get $_M0L1wS298)
   (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)))
 (local.set $_M0L3lenS936
  (i32.load
   (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)))
 (if
  (i32.ge_s
   (i32.const 1)
   (local.get $_M0L3lenS936))
  (then
   (unreachable))
  (else))
 (i32.load
  (i32.add
   (local.tee $_M0L3bufS937
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)))
   (i32.shl
    (i32.const 1)
    (i32.const 2)))))
(func $_M0FP48moonarc34rhae3src4rhae9get__topk (param $_M0L1iS296 i32) (result i32)
 (local $_M0L3lenS934 i32)
 (local $_M0L3bufS935 i32)
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L1iS296)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS934
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae9topk__buf)))
    (i32.ge_s
     (local.get $_M0L1iS296)
     (local.get $_M0L3lenS934))))
  (then
   (unreachable))
  (else))
 (i32.load
  (i32.add
   (local.tee $_M0L3bufS935
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae9topk__buf)))
   (i32.shl
    (local.get $_M0L1iS296)
    (i32.const 2)))))
(func $_M0FP48moonarc34rhae3src4rhae8get__mat (param $_M0L1iS295 i32) (result i32)
 (local $_M0L3lenS932 i32)
 (local $_M0L3bufS933 i32)
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L1iS295)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS932
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)))
    (i32.ge_s
     (local.get $_M0L1iS295)
     (local.get $_M0L3lenS932))))
  (then
   (unreachable))
  (else))
 (i32.load
  (i32.add
   (local.tee $_M0L3bufS933
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)))
   (i32.shl
    (local.get $_M0L1iS295)
    (i32.const 2)))))
(func $_M0FP48moonarc34rhae3src4rhae8get__inv (param $_M0L1iS294 i32) (result i32)
 (local $_M0L3lenS930 i32)
 (local $_M0L3bufS931 i32)
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L1iS294)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS930
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)))
    (i32.ge_s
     (local.get $_M0L1iS294)
     (local.get $_M0L3lenS930))))
  (then
   (unreachable))
  (else))
 (i32.load
  (i32.add
   (local.tee $_M0L3bufS931
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)))
   (i32.shl
    (local.get $_M0L1iS294)
    (i32.const 2)))))
(func $_M0FP48moonarc34rhae3src4rhae9set__risk (param $_M0L2aiS292 i32) (param $_M0L3valS293 i32) (result i32)
 (local $_M0L3lenS928 i32)
 (local $_M0L3bufS929 i32)
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L2aiS292)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS928
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae9risk__buf)))
    (i32.ge_s
     (local.get $_M0L2aiS292)
     (local.get $_M0L3lenS928))))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS929
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae9risk__buf)))
   (i32.shl
    (local.get $_M0L2aiS292)
    (i32.const 2)))
  (local.get $_M0L3valS293))
 (i32.const 0))
(func $_M0FP48moonarc34rhae3src4rhae12set__visited (param $_M0L2aiS290 i32) (param $_M0L3valS291 i32) (result i32)
 (local $_M0L3lenS926 i32)
 (local $_M0L3bufS927 i32)
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L2aiS290)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS926
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae8vis__buf)))
    (i32.ge_s
     (local.get $_M0L2aiS290)
     (local.get $_M0L3lenS926))))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS927
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae8vis__buf)))
   (i32.shl
    (local.get $_M0L2aiS290)
    (i32.const 2)))
  (local.get $_M0L3valS291))
 (i32.const 0))
(func $_M0FP48moonarc34rhae3src4rhae15set__prev__cell (param $_M0L3idxS288 i32) (param $_M0L3valS289 i32) (result i32)
 (local $_M0L3lenS924 i32)
 (local $_M0L3bufS925 i32)
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L3idxS288)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS924
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae9prev__buf)))
    (i32.ge_s
     (local.get $_M0L3idxS288)
     (local.get $_M0L3lenS924))))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS925
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae9prev__buf)))
   (i32.shl
    (local.get $_M0L3idxS288)
    (i32.const 2)))
  (local.get $_M0L3valS289))
 (i32.const 0))
(func $_M0FP48moonarc34rhae3src4rhae15set__grid__cell (param $_M0L3idxS286 i32) (param $_M0L3valS287 i32) (result i32)
 (local $_M0L3lenS922 i32)
 (local $_M0L3bufS923 i32)
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L3idxS286)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS922
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)))
    (i32.ge_s
     (local.get $_M0L3idxS286)
     (local.get $_M0L3lenS922))))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS923
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)))
   (i32.shl
    (local.get $_M0L3idxS286)
    (i32.const 2)))
  (local.get $_M0L3valS287))
 (i32.const 0))
(func $_M0FP48moonarc34rhae3src4rhae19compute__invariants (param $_M0L4gridS260 i32) (param $_M0L4prevS277 i32) (param $_M0L1hS256 i32) (param $_M0L1wS257 i32) (param $_M0L3outS284 i32) (result i32)
 (local $_M0L1nS255 i32)
 (local $_M0L3visS258 i32)
 (local $_M0L7n__compS259 i32)
 (local $_M0L7_2abindS261 i32)
 (local $_M0L8_2aeulerS262 i32)
 (local $_M0L11_2an__holesS263 i32)
 (local $_M0L9n__colorsS264 i32)
 (local $_M0L7_2abindS265 i32)
 (local $_M0L5_2ar0S266 i32)
 (local $_M0L5_2ar1S267 i32)
 (local $_M0L5_2ac0S268 i32)
 (local $_M0L5_2ac1S269 i32)
 (local $_M0L2bhS270 i32)
 (local $_M0L2bwS271 i32)
 (local $_M0L3symS272 i32)
 (local $_M0L7_2abindS275 i32)
 (local $_M0L7_2abindS276 i32)
 (local $_M0L7_2abindS281 i32)
 (local $_M0L4goalS283 i32)
 (local $_M0L7_2abindS285 i32)
 (local $_M0L6_2atmpS883 i32)
 (local $_M0L6_2atmpS884 i32)
 (local $_M0L6_2atmpS885 i32)
 (local $_M0L3lenS886 i32)
 (local $_M0L3bufS887 i32)
 (local $_M0L3lenS888 i32)
 (local $_M0L3bufS889 i32)
 (local $_M0L6_2atmpS890 i32)
 (local $_M0L6_2atmpS891 i32)
 (local $_M0L6_2atmpS892 i32)
 (local $_M0L6_2atmpS893 i32)
 (local $_M0L3lenS894 i32)
 (local $_M0L3bufS895 i32)
 (local $_M0L6_2atmpS896 i32)
 (local $_M0L6_2atmpS897 i32)
 (local $_M0L3lenS898 i32)
 (local $_M0L3bufS899 i32)
 (local $_M0L3lenS900 i32)
 (local $_M0L3bufS901 i32)
 (local $_M0L3lenS902 i32)
 (local $_M0L3bufS903 i32)
 (local $_M0L3lenS904 i32)
 (local $_M0L3bufS905 i32)
 (local $_M0L3lenS906 i32)
 (local $_M0L3bufS907 i32)
 (local $_M0L3lenS908 i32)
 (local $_M0L3bufS909 i32)
 (local $_M0L3lenS910 i32)
 (local $_M0L3bufS911 i32)
 (local $_M0L3lenS912 i32)
 (local $_M0L3bufS913 i32)
 (local $_M0L3lenS914 i32)
 (local $_M0L3bufS915 i32)
 (local $_M0L3lenS916 i32)
 (local $_M0L3bufS917 i32)
 (local $_M0L6_2atmpS918 i32)
 (local $_M0L6_2atmpS919 i32)
 (local $_M0L6_2atmpS920 i32)
 (local $_M0L6_2atmpS921 i32)
 (local $_M0Lm5deltaS273 i32)
 (local $_M0Lm1jS274 i32)
 (local $_M0Lm2nzS279 i32)
 (local $_M0Lm1kS280 i32)
 (local.set $_M0L3visS258
  (call $_M0MPC15array5Array4makeGiE
   (local.tee $_M0L1nS255
    (i32.mul
     (local.get $_M0L1hS256)
     (local.get $_M0L1wS257)))
   (i32.const 0)))
 (call $_M0FP48moonarc34rhae3src4rhae17count__components
  (local.get $_M0L4gridS260)
  (local.get $_M0L1hS256)
  (local.get $_M0L1wS257)
  (local.get $_M0L3visS258))
 (call $moonbit.decref
  (local.get $_M0L3visS258))
 (local.set $_M0L7n__compS259)
 (local.set $_M0L8_2aeulerS262
  (i32.load
   (local.tee $_M0L7_2abindS261
    (call $_M0FP48moonarc34rhae3src4rhae12euler__proxy
     (local.get $_M0L4gridS260)
     (local.get $_M0L1hS256)
     (local.get $_M0L1wS257)))))
 (i32.load offset=4
  (local.get $_M0L7_2abindS261))
 (call $moonbit.decref
  (local.get $_M0L7_2abindS261))
 (local.set $_M0L11_2an__holesS263)
 (local.set $_M0L9n__colorsS264
  (call $_M0FP48moonarc34rhae3src4rhae13count__colors
   (local.get $_M0L4gridS260)
   (local.get $_M0L1nS255)))
 (local.set $_M0L5_2ar0S266
  (i32.load
   (local.tee $_M0L7_2abindS265
    (call $_M0FP48moonarc34rhae3src4rhae4bbox
     (local.get $_M0L4gridS260)
     (local.get $_M0L1hS256)
     (local.get $_M0L1wS257)))))
 (local.set $_M0L5_2ar1S267
  (i32.load offset=4
   (local.get $_M0L7_2abindS265)))
 (local.set $_M0L5_2ac0S268
  (i32.load offset=8
   (local.get $_M0L7_2abindS265)))
 (i32.load offset=12
  (local.get $_M0L7_2abindS265))
 (call $moonbit.decref
  (local.get $_M0L7_2abindS265))
 (local.set $_M0L5_2ac1S269)
 (local.set $_M0L2bhS270
  (if (result i32)
   (i32.ge_s
    (local.get $_M0L5_2ar1S267)
    (local.get $_M0L5_2ar0S266))
   (then
    (i32.add
     (local.tee $_M0L6_2atmpS921
      (i32.sub
       (local.get $_M0L5_2ar1S267)
       (local.get $_M0L5_2ar0S266)))
     (i32.const 1)))
   (else
    (i32.const 0))))
 (local.set $_M0L2bwS271
  (if (result i32)
   (i32.ge_s
    (local.get $_M0L5_2ac1S269)
    (local.get $_M0L5_2ac0S268))
   (then
    (i32.add
     (local.tee $_M0L6_2atmpS920
      (i32.sub
       (local.get $_M0L5_2ac1S269)
       (local.get $_M0L5_2ac0S268)))
     (i32.const 1)))
   (else
    (i32.const 0))))
 (local.set $_M0L3symS272
  (if (result i32)
   (call $_M0FP48moonarc34rhae3src4rhae10is__sym__h
    (local.get $_M0L4gridS260)
    (local.get $_M0L1hS256)
    (local.get $_M0L1wS257))
   (then
    (i32.const 1))
   (else
    (i32.const 0))))
 (local.set $_M0Lm5deltaS273
  (i32.const 0))
 (local.set $_M0Lm1jS274
  (i32.const 0))
 (loop $loop:278
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS883
     (local.get $_M0Lm1jS274))
    (local.get $_M0L1nS255))
   (then
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS275
        (local.get $_M0Lm1jS274))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS888
        (i32.load
         (local.get $_M0L4gridS260)))
       (i32.ge_s
        (local.get $_M0L7_2abindS275)
        (local.get $_M0L3lenS888))))
     (then
      (unreachable))
     (else))
    (local.set $_M0L6_2atmpS884
     (i32.load
      (i32.add
       (local.tee $_M0L3bufS889
        (i32.load offset=4
         (local.get $_M0L4gridS260)))
       (i32.shl
        (local.get $_M0L7_2abindS275)
        (i32.const 2)))))
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS276
        (local.get $_M0Lm1jS274))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS886
        (i32.load
         (local.get $_M0L4prevS277)))
       (i32.ge_s
        (local.get $_M0L7_2abindS276)
        (local.get $_M0L3lenS886))))
     (then
      (unreachable))
     (else))
    (local.set $_M0L6_2atmpS885
     (i32.load
      (i32.add
       (local.tee $_M0L3bufS887
        (i32.load offset=4
         (local.get $_M0L4prevS277)))
       (i32.shl
        (local.get $_M0L7_2abindS276)
        (i32.const 2)))))
    (local.get $_M0L6_2atmpS884)
    (if
     (i32.ne
      (local.get $_M0L6_2atmpS885))
     (then
      (local.set $_M0Lm5deltaS273
       (i32.add
        (local.tee $_M0L6_2atmpS890
         (local.get $_M0Lm5deltaS273))
        (i32.const 1))))
     (else))
    (local.set $_M0Lm1jS274
     (i32.add
      (local.tee $_M0L6_2atmpS891
       (local.get $_M0Lm1jS274))
      (i32.const 1)))
    (br $loop:278))
   (else)))
 (local.set $_M0Lm2nzS279
  (i32.const 0))
 (local.set $_M0Lm1kS280
  (i32.const 0))
 (loop $loop:282
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS892
     (local.get $_M0Lm1kS280))
    (local.get $_M0L1nS255))
   (then
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS281
        (local.get $_M0Lm1kS280))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS894
        (i32.load
         (local.get $_M0L4gridS260)))
       (i32.ge_s
        (local.get $_M0L7_2abindS281)
        (local.get $_M0L3lenS894))))
     (then
      (unreachable))
     (else))
    (if
     (i32.gt_s
      (local.tee $_M0L6_2atmpS893
       (i32.load
        (i32.add
         (local.tee $_M0L3bufS895
          (i32.load offset=4
           (local.get $_M0L4gridS260)))
         (i32.shl
          (local.get $_M0L7_2abindS281)
          (i32.const 2)))))
      (i32.const 0))
     (then
      (local.set $_M0Lm2nzS279
       (i32.add
        (local.tee $_M0L6_2atmpS896
         (local.get $_M0Lm2nzS279))
        (i32.const 1))))
     (else))
    (local.set $_M0Lm1kS280
     (i32.add
      (local.tee $_M0L6_2atmpS897
       (local.get $_M0Lm1kS280))
      (i32.const 1)))
    (br $loop:282))
   (else)))
 (local.set $_M0L4goalS283
  (if (result i32)
   (i32.gt_s
    (local.get $_M0L1nS255)
    (i32.const 0))
   (then
    (i32.div_s
     (local.tee $_M0L6_2atmpS918
      (i32.mul
       (local.tee $_M0L6_2atmpS919
        (local.get $_M0Lm2nzS279))
       (i32.const 100)))
     (local.get $_M0L1nS255)))
   (else
    (i32.const 0))))
 (local.set $_M0L3lenS898
  (i32.load
   (local.get $_M0L3outS284)))
 (if
  (i32.ge_s
   (i32.const 0)
   (local.get $_M0L3lenS898))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS899
    (i32.load offset=4
     (local.get $_M0L3outS284)))
   (i32.shl
    (i32.const 0)
    (i32.const 2)))
  (local.get $_M0L7n__compS259))
 (local.set $_M0L3lenS900
  (i32.load
   (local.get $_M0L3outS284)))
 (if
  (i32.ge_s
   (i32.const 1)
   (local.get $_M0L3lenS900))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS901
    (i32.load offset=4
     (local.get $_M0L3outS284)))
   (i32.shl
    (i32.const 1)
    (i32.const 2)))
  (local.get $_M0L9n__colorsS264))
 (local.set $_M0L3lenS902
  (i32.load
   (local.get $_M0L3outS284)))
 (if
  (i32.ge_s
   (i32.const 2)
   (local.get $_M0L3lenS902))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS903
    (i32.load offset=4
     (local.get $_M0L3outS284)))
   (i32.shl
    (i32.const 2)
    (i32.const 2)))
  (local.get $_M0L7n__compS259))
 (local.set $_M0L3lenS904
  (i32.load
   (local.get $_M0L3outS284)))
 (if
  (i32.ge_s
   (i32.const 3)
   (local.get $_M0L3lenS904))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS905
    (i32.load offset=4
     (local.get $_M0L3outS284)))
   (i32.shl
    (i32.const 3)
    (i32.const 2)))
  (local.get $_M0L2bhS270))
 (local.set $_M0L3lenS906
  (i32.load
   (local.get $_M0L3outS284)))
 (if
  (i32.ge_s
   (i32.const 4)
   (local.get $_M0L3lenS906))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS907
    (i32.load offset=4
     (local.get $_M0L3outS284)))
   (i32.shl
    (i32.const 4)
    (i32.const 2)))
  (local.get $_M0L2bwS271))
 (local.set $_M0L3lenS908
  (i32.load
   (local.get $_M0L3outS284)))
 (if
  (i32.ge_s
   (i32.const 5)
   (local.get $_M0L3lenS908))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS909
    (i32.load offset=4
     (local.get $_M0L3outS284)))
   (i32.shl
    (i32.const 5)
    (i32.const 2)))
  (local.get $_M0L3symS272))
 (local.set $_M0L3lenS910
  (i32.load
   (local.get $_M0L3outS284)))
 (if
  (i32.ge_s
   (i32.const 6)
   (local.get $_M0L3lenS910))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS911
    (i32.load offset=4
     (local.get $_M0L3outS284)))
   (i32.shl
    (i32.const 6)
    (i32.const 2)))
  (local.get $_M0L8_2aeulerS262))
 (local.set $_M0L3lenS912
  (i32.load
   (local.get $_M0L3outS284)))
 (if
  (i32.ge_s
   (i32.const 7)
   (local.get $_M0L3lenS912))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS913
    (i32.load offset=4
     (local.get $_M0L3outS284)))
   (i32.shl
    (i32.const 7)
    (i32.const 2)))
  (local.get $_M0L11_2an__holesS263))
 (local.set $_M0L7_2abindS285
  (local.get $_M0Lm5deltaS273))
 (local.set $_M0L3lenS914
  (i32.load
   (local.get $_M0L3outS284)))
 (if
  (i32.ge_s
   (i32.const 8)
   (local.get $_M0L3lenS914))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS915
    (i32.load offset=4
     (local.get $_M0L3outS284)))
   (i32.shl
    (i32.const 8)
    (i32.const 2)))
  (local.get $_M0L7_2abindS285))
 (local.set $_M0L3lenS916
  (i32.load
   (local.get $_M0L3outS284)))
 (if
  (i32.ge_s
   (i32.const 9)
   (local.get $_M0L3lenS916))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS917
    (i32.load offset=4
     (local.get $_M0L3outS284)))
   (i32.shl
    (i32.const 9)
    (i32.const 2)))
  (local.get $_M0L4goalS283))
 (i32.const 0))
(func $_M0FP48moonarc34rhae3src4rhae13count__colors (param $_M0L4gridS249 i32) (param $_M0L1nS246 i32) (result i32)
 (local $_M0L4seenS244 i32)
 (local $_M0L7_2abindS247 i32)
 (local $_M0L1cS248 i32)
 (local $_M0L7_2abindS253 i32)
 (local $_M0L6_2atmpS871 i32)
 (local $_M0L3lenS872 i32)
 (local $_M0L3bufS873 i32)
 (local $_M0L6_2atmpS874 i32)
 (local $_M0L3lenS875 i32)
 (local $_M0L3bufS876 i32)
 (local $_M0L6_2atmpS877 i32)
 (local $_M0L6_2atmpS878 i32)
 (local $_M0L6_2atmpS879 i32)
 (local $_M0L3lenS880 i32)
 (local $_M0L3bufS881 i32)
 (local $_M0L6_2atmpS882 i32)
 (local $_M0Lm1iS245 i32)
 (local $_M0Lm3cntS251 i32)
 (local $_M0Lm1kS252 i32)
 (local.set $_M0L4seenS244
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 16)
   (i32.const 0)))
 (local.set $_M0Lm1iS245
  (i32.const 0))
 (loop $loop:250
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS871
     (local.get $_M0Lm1iS245))
    (local.get $_M0L1nS246))
   (then
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS247
        (local.get $_M0Lm1iS245))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS875
        (i32.load
         (local.get $_M0L4gridS249)))
       (i32.ge_s
        (local.get $_M0L7_2abindS247)
        (local.get $_M0L3lenS875))))
     (then
      (unreachable))
     (else))
    (if
     (if (result i32)
      (i32.gt_s
       (local.tee $_M0L1cS248
        (i32.load
         (i32.add
          (local.tee $_M0L3bufS876
           (i32.load offset=4
            (local.get $_M0L4gridS249)))
          (i32.shl
           (local.get $_M0L7_2abindS247)
           (i32.const 2)))))
       (i32.const 0))
      (then
       (i32.lt_s
        (local.get $_M0L1cS248)
        (i32.const 16)))
      (else
       (i32.const 0)))
     (then
      (if
       (if (result i32)
        (i32.lt_s
         (local.get $_M0L1cS248)
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS872
          (i32.load
           (local.get $_M0L4seenS244)))
         (i32.ge_s
          (local.get $_M0L1cS248)
          (local.get $_M0L3lenS872))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS873
         (i32.load offset=4
          (local.get $_M0L4seenS244)))
        (i32.shl
         (local.get $_M0L1cS248)
         (i32.const 2)))
       (i32.const 1)))
     (else))
    (local.set $_M0Lm1iS245
     (i32.add
      (local.tee $_M0L6_2atmpS874
       (local.get $_M0Lm1iS245))
      (i32.const 1)))
    (br $loop:250))
   (else)))
 (local.set $_M0Lm3cntS251
  (i32.const 0))
 (local.set $_M0Lm1kS252
  (i32.const 0))
 (loop $loop:254
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS877
     (local.get $_M0Lm1kS252))
    (i32.const 16))
   (then
    (local.set $_M0L6_2atmpS878
     (local.get $_M0Lm3cntS251))
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS253
        (local.get $_M0Lm1kS252))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS880
        (i32.load
         (local.get $_M0L4seenS244)))
       (i32.ge_s
        (local.get $_M0L7_2abindS253)
        (local.get $_M0L3lenS880))))
     (then
      (unreachable))
     (else))
    (local.set $_M0L6_2atmpS879
     (i32.load
      (i32.add
       (local.tee $_M0L3bufS881
        (i32.load offset=4
         (local.get $_M0L4seenS244)))
       (i32.shl
        (local.get $_M0L7_2abindS253)
        (i32.const 2)))))
    (local.set $_M0Lm3cntS251
     (i32.add
      (local.get $_M0L6_2atmpS878)
      (local.get $_M0L6_2atmpS879)))
    (local.set $_M0Lm1kS252
     (i32.add
      (local.tee $_M0L6_2atmpS882
       (local.get $_M0Lm1kS252))
      (i32.const 1)))
    (br $loop:254))
   (else
    (call $moonbit.decref
     (local.get $_M0L4seenS244)))))
 (local.get $_M0Lm3cntS251))
(func $_M0FP48moonarc34rhae3src4rhae10is__sym__h (param $_M0L4gridS240 i32) (param $_M0L1hS236 i32) (param $_M0L1wS238 i32) (result i32)
 (local $_M0L7_2abindS239 i32)
 (local $_M0L7_2abindS241 i32)
 (local $_M0L6_2atmpS852 i32)
 (local $_M0L6_2atmpS853 i32)
 (local $_M0L6_2atmpS854 i32)
 (local $_M0L6_2atmpS855 i32)
 (local $_M0L6_2atmpS856 i32)
 (local $_M0L3lenS857 i32)
 (local $_M0L3bufS858 i32)
 (local $_M0L6_2atmpS859 i32)
 (local $_M0L6_2atmpS860 i32)
 (local $_M0L6_2atmpS861 i32)
 (local $_M0L6_2atmpS862 i32)
 (local $_M0L6_2atmpS863 i32)
 (local $_M0L3lenS864 i32)
 (local $_M0L3bufS865 i32)
 (local $_M0L6_2atmpS866 i32)
 (local $_M0L6_2atmpS867 i32)
 (local $_M0L6_2atmpS868 i32)
 (local $_M0L6_2atmpS869 i32)
 (local $_M0L6_2atmpS870 i32)
 (local $_M0Lm1rS235 i32)
 (local $_M0Lm1cS237 i32)
 (local.set $_M0Lm1rS235
  (i32.const 0))
 (loop $loop:243
  (local.set $_M0L6_2atmpS852
   (local.get $_M0Lm1rS235))
  (local.set $_M0L6_2atmpS853
   (i32.div_s
    (local.get $_M0L1hS236)
    (i32.const 2)))
  (if
   (i32.lt_s
    (local.get $_M0L6_2atmpS852)
    (local.get $_M0L6_2atmpS853))
   (then
    (local.set $_M0Lm1cS237
     (i32.const 0))
    (loop $loop:242
     (if
      (i32.lt_s
       (local.tee $_M0L6_2atmpS854
        (local.get $_M0Lm1cS237))
       (local.get $_M0L1wS238))
      (then
       (local.set $_M0L6_2atmpS866
        (i32.mul
         (local.tee $_M0L6_2atmpS868
          (local.get $_M0Lm1rS235))
         (local.get $_M0L1wS238)))
       (local.set $_M0L6_2atmpS867
        (local.get $_M0Lm1cS237))
       (if
        (if (result i32)
         (i32.lt_s
          (local.tee $_M0L7_2abindS239
           (i32.add
            (local.get $_M0L6_2atmpS866)
            (local.get $_M0L6_2atmpS867)))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS864
           (i32.load
            (local.get $_M0L4gridS240)))
          (i32.ge_s
           (local.get $_M0L7_2abindS239)
           (local.get $_M0L3lenS864))))
        (then
         (unreachable))
        (else))
       (local.set $_M0L6_2atmpS855
        (i32.load
         (i32.add
          (local.tee $_M0L3bufS865
           (i32.load offset=4
            (local.get $_M0L4gridS240)))
          (i32.shl
           (local.get $_M0L7_2abindS239)
           (i32.const 2)))))
       (local.set $_M0L6_2atmpS862
        (i32.sub
         (local.get $_M0L1hS236)
         (i32.const 1)))
       (local.set $_M0L6_2atmpS863
        (local.get $_M0Lm1rS235))
       (local.set $_M0L6_2atmpS859
        (i32.mul
         (local.tee $_M0L6_2atmpS861
          (i32.sub
           (local.get $_M0L6_2atmpS862)
           (local.get $_M0L6_2atmpS863)))
         (local.get $_M0L1wS238)))
       (local.set $_M0L6_2atmpS860
        (local.get $_M0Lm1cS237))
       (if
        (if (result i32)
         (i32.lt_s
          (local.tee $_M0L7_2abindS241
           (i32.add
            (local.get $_M0L6_2atmpS859)
            (local.get $_M0L6_2atmpS860)))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS857
           (i32.load
            (local.get $_M0L4gridS240)))
          (i32.ge_s
           (local.get $_M0L7_2abindS241)
           (local.get $_M0L3lenS857))))
        (then
         (unreachable))
        (else))
       (local.set $_M0L6_2atmpS856
        (i32.load
         (i32.add
          (local.tee $_M0L3bufS858
           (i32.load offset=4
            (local.get $_M0L4gridS240)))
          (i32.shl
           (local.get $_M0L7_2abindS241)
           (i32.const 2)))))
       (local.get $_M0L6_2atmpS855)
       (if
        (i32.ne
         (local.get $_M0L6_2atmpS856))
        (then
         (i32.const 0)
         (return))
        (else))
       (local.set $_M0Lm1cS237
        (i32.add
         (local.tee $_M0L6_2atmpS869
          (local.get $_M0Lm1cS237))
         (i32.const 1)))
       (br $loop:242))
      (else)))
    (local.set $_M0Lm1rS235
     (i32.add
      (local.tee $_M0L6_2atmpS870
       (local.get $_M0Lm1rS235))
      (i32.const 1)))
    (br $loop:243))
   (else)))
 (i32.const 1))
(func $_M0FP48moonarc34rhae3src4rhae12euler__proxy (param $_M0L4gridS225 i32) (param $_M0L1hS220 i32) (param $_M0L1wS222 i32) (result i32)
 (local $_M0L1aS223 i32)
 (local $_M0L7_2abindS224 i32)
 (local $_M0L1bS226 i32)
 (local $_M0L7_2abindS227 i32)
 (local $_M0L1dS228 i32)
 (local $_M0L7_2abindS229 i32)
 (local $_M0L1eS230 i32)
 (local $_M0L7_2abindS231 i32)
 (local $_M0L1sS232 i32)
 (local $_M0L6_2atmpS804 i32)
 (local $_M0L6_2atmpS805 i32)
 (local $_M0L6_2atmpS806 i32)
 (local $_M0L6_2atmpS807 i32)
 (local $_M0L6_2atmpS808 i32)
 (local $_M0L6_2atmpS809 i32)
 (local $_M0L6_2atmpS810 i32)
 (local $_M0L6_2atmpS811 i32)
 (local $_M0L6_2atmpS812 i32)
 (local $_M0L6_2atmpS813 i32)
 (local $_M0L3lenS814 i32)
 (local $_M0L3bufS815 i32)
 (local $_M0L6_2atmpS816 i32)
 (local $_M0L6_2atmpS817 i32)
 (local $_M0L6_2atmpS818 i32)
 (local $_M0L6_2atmpS819 i32)
 (local $_M0L6_2atmpS820 i32)
 (local $_M0L6_2atmpS821 i32)
 (local $_M0L3lenS822 i32)
 (local $_M0L3bufS823 i32)
 (local $_M0L6_2atmpS824 i32)
 (local $_M0L6_2atmpS825 i32)
 (local $_M0L6_2atmpS826 i32)
 (local $_M0L6_2atmpS827 i32)
 (local $_M0L6_2atmpS828 i32)
 (local $_M0L3lenS829 i32)
 (local $_M0L3bufS830 i32)
 (local $_M0L6_2atmpS831 i32)
 (local $_M0L6_2atmpS832 i32)
 (local $_M0L6_2atmpS833 i32)
 (local $_M0L6_2atmpS834 i32)
 (local $_M0L6_2atmpS835 i32)
 (local $_M0L3lenS836 i32)
 (local $_M0L3bufS837 i32)
 (local $_M0L6_2atmpS838 i32)
 (local $_M0L6_2atmpS839 i32)
 (local $_M0L6_2atmpS840 i32)
 (local $_M0L6_2atmpS841 i32)
 (local $_M0L6_2atmpS842 i32)
 (local $_M0L6_2atmpS843 i32)
 (local $_M0L6_2atmpS844 i32)
 (local $_M0L6_2atmpS845 i32)
 (local $_M0L6_2atmpS846 i32)
 (local $_M0L6_2atmpS847 i32)
 (local $_M0L6_2atmpS848 i32)
 (local $_M0L6_2atmpS849 i32)
 (local $_M0L6_2atmpS850 i32)
 (local $_M0L6_2atmpS851 i32)
 (local $_M0L3ptrS1172 i32)
 (local $_M0Lm2q1S217 i32)
 (local $_M0Lm2q3S218 i32)
 (local $_M0Lm1rS219 i32)
 (local $_M0Lm1cS221 i32)
 (local.set $_M0Lm2q1S217
  (i32.const 0))
 (local.set $_M0Lm2q3S218
  (i32.const 0))
 (local.set $_M0Lm1rS219
  (i32.const 0))
 (loop $loop:234
  (local.set $_M0L6_2atmpS804
   (local.get $_M0Lm1rS219))
  (local.set $_M0L6_2atmpS805
   (i32.sub
    (local.get $_M0L1hS220)
    (i32.const 1)))
  (if
   (i32.lt_s
    (local.get $_M0L6_2atmpS804)
    (local.get $_M0L6_2atmpS805))
   (then
    (local.set $_M0Lm1cS221
     (i32.const 0))
    (loop $loop:233
     (local.set $_M0L6_2atmpS806
      (local.get $_M0Lm1cS221))
     (local.set $_M0L6_2atmpS807
      (i32.sub
       (local.get $_M0L1wS222)
       (i32.const 1)))
     (if
      (i32.lt_s
       (local.get $_M0L6_2atmpS806)
       (local.get $_M0L6_2atmpS807))
      (then
       (local.set $_M0L6_2atmpS838
        (i32.mul
         (local.tee $_M0L6_2atmpS840
          (local.get $_M0Lm1rS219))
         (local.get $_M0L1wS222)))
       (local.set $_M0L6_2atmpS839
        (local.get $_M0Lm1cS221))
       (if
        (if (result i32)
         (i32.lt_s
          (local.tee $_M0L7_2abindS224
           (i32.add
            (local.get $_M0L6_2atmpS838)
            (local.get $_M0L6_2atmpS839)))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS836
           (i32.load
            (local.get $_M0L4gridS225)))
          (i32.ge_s
           (local.get $_M0L7_2abindS224)
           (local.get $_M0L3lenS836))))
        (then
         (unreachable))
        (else))
       (local.set $_M0L1aS223
        (if (result i32)
         (i32.gt_s
          (local.tee $_M0L6_2atmpS835
           (i32.load
            (i32.add
             (local.tee $_M0L3bufS837
              (i32.load offset=4
               (local.get $_M0L4gridS225)))
             (i32.shl
              (local.get $_M0L7_2abindS224)
              (i32.const 2)))))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (i32.const 0))))
       (local.set $_M0L6_2atmpS832
        (i32.mul
         (local.tee $_M0L6_2atmpS834
          (local.get $_M0Lm1rS219))
         (local.get $_M0L1wS222)))
       (local.set $_M0L6_2atmpS833
        (local.get $_M0Lm1cS221))
       (if
        (if (result i32)
         (i32.lt_s
          (local.tee $_M0L7_2abindS227
           (i32.add
            (local.tee $_M0L6_2atmpS831
             (i32.add
              (local.get $_M0L6_2atmpS832)
              (local.get $_M0L6_2atmpS833)))
            (i32.const 1)))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS829
           (i32.load
            (local.get $_M0L4gridS225)))
          (i32.ge_s
           (local.get $_M0L7_2abindS227)
           (local.get $_M0L3lenS829))))
        (then
         (unreachable))
        (else))
       (local.set $_M0L1bS226
        (if (result i32)
         (i32.gt_s
          (local.tee $_M0L6_2atmpS828
           (i32.load
            (i32.add
             (local.tee $_M0L3bufS830
              (i32.load offset=4
               (local.get $_M0L4gridS225)))
             (i32.shl
              (local.get $_M0L7_2abindS227)
              (i32.const 2)))))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (i32.const 0))))
       (local.set $_M0L6_2atmpS824
        (i32.mul
         (local.tee $_M0L6_2atmpS826
          (i32.add
           (local.tee $_M0L6_2atmpS827
            (local.get $_M0Lm1rS219))
           (i32.const 1)))
         (local.get $_M0L1wS222)))
       (local.set $_M0L6_2atmpS825
        (local.get $_M0Lm1cS221))
       (if
        (if (result i32)
         (i32.lt_s
          (local.tee $_M0L7_2abindS229
           (i32.add
            (local.get $_M0L6_2atmpS824)
            (local.get $_M0L6_2atmpS825)))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS822
           (i32.load
            (local.get $_M0L4gridS225)))
          (i32.ge_s
           (local.get $_M0L7_2abindS229)
           (local.get $_M0L3lenS822))))
        (then
         (unreachable))
        (else))
       (local.set $_M0L1dS228
        (if (result i32)
         (i32.gt_s
          (local.tee $_M0L6_2atmpS821
           (i32.load
            (i32.add
             (local.tee $_M0L3bufS823
              (i32.load offset=4
               (local.get $_M0L4gridS225)))
             (i32.shl
              (local.get $_M0L7_2abindS229)
              (i32.const 2)))))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (i32.const 0))))
       (local.set $_M0L6_2atmpS817
        (i32.mul
         (local.tee $_M0L6_2atmpS819
          (i32.add
           (local.tee $_M0L6_2atmpS820
            (local.get $_M0Lm1rS219))
           (i32.const 1)))
         (local.get $_M0L1wS222)))
       (local.set $_M0L6_2atmpS818
        (local.get $_M0Lm1cS221))
       (if
        (if (result i32)
         (i32.lt_s
          (local.tee $_M0L7_2abindS231
           (i32.add
            (local.tee $_M0L6_2atmpS816
             (i32.add
              (local.get $_M0L6_2atmpS817)
              (local.get $_M0L6_2atmpS818)))
            (i32.const 1)))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS814
           (i32.load
            (local.get $_M0L4gridS225)))
          (i32.ge_s
           (local.get $_M0L7_2abindS231)
           (local.get $_M0L3lenS814))))
        (then
         (unreachable))
        (else))
       (local.set $_M0L1eS230
        (if (result i32)
         (i32.gt_s
          (local.tee $_M0L6_2atmpS813
           (i32.load
            (i32.add
             (local.tee $_M0L3bufS815
              (i32.load offset=4
               (local.get $_M0L4gridS225)))
             (i32.shl
              (local.get $_M0L7_2abindS231)
              (i32.const 2)))))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (i32.const 0))))
       (if
        (i32.eq
         (local.tee $_M0L1sS232
          (i32.add
           (local.tee $_M0L6_2atmpS811
            (i32.add
             (local.tee $_M0L6_2atmpS812
              (i32.add
               (local.get $_M0L1aS223)
               (local.get $_M0L1bS226)))
             (local.get $_M0L1dS228)))
           (local.get $_M0L1eS230)))
         (i32.const 1))
        (then
         (local.set $_M0Lm2q1S217
          (i32.add
           (local.tee $_M0L6_2atmpS808
            (local.get $_M0Lm2q1S217))
           (i32.const 1))))
        (else
         (if
          (i32.eq
           (local.get $_M0L1sS232)
           (i32.const 3))
          (then
           (local.set $_M0Lm2q3S218
            (i32.add
             (local.tee $_M0L6_2atmpS809
              (local.get $_M0Lm2q3S218))
             (i32.const 1))))
          (else))))
       (local.set $_M0Lm1cS221
        (i32.add
         (local.tee $_M0L6_2atmpS810
          (local.get $_M0Lm1cS221))
         (i32.const 1)))
       (br $loop:233))
      (else)))
    (local.set $_M0Lm1rS219
     (i32.add
      (local.tee $_M0L6_2atmpS841
       (local.get $_M0Lm1rS219))
      (i32.const 1)))
    (br $loop:234))
   (else)))
 (local.set $_M0L6_2atmpS850
  (local.get $_M0Lm2q1S217))
 (local.set $_M0L6_2atmpS851
  (local.get $_M0Lm2q3S218))
 (local.set $_M0L6_2atmpS842
  (i32.div_s
   (local.tee $_M0L6_2atmpS849
    (i32.sub
     (local.get $_M0L6_2atmpS850)
     (local.get $_M0L6_2atmpS851)))
   (i32.const 4)))
 (local.set $_M0L6_2atmpS844
  (local.get $_M0Lm2q3S218))
 (local.set $_M0L6_2atmpS845
  (local.get $_M0Lm2q1S217))
 (local.set $_M0L6_2atmpS843
  (if (result i32)
   (i32.gt_s
    (local.get $_M0L6_2atmpS844)
    (local.get $_M0L6_2atmpS845))
   (then
    (local.set $_M0L6_2atmpS847
     (local.get $_M0Lm2q3S218))
    (local.set $_M0L6_2atmpS848
     (local.get $_M0Lm2q1S217))
    (i32.div_s
     (local.tee $_M0L6_2atmpS846
      (i32.sub
       (local.get $_M0L6_2atmpS847)
       (local.get $_M0L6_2atmpS848)))
     (i32.const 4)))
   (else
    (i32.const 0))))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1172
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1172)
  (local.get $_M0L6_2atmpS843))
 (i32.store
  (local.get $_M0L3ptrS1172)
  (local.get $_M0L6_2atmpS842))
 (local.get $_M0L3ptrS1172))
(func $_M0FP48moonarc34rhae3src4rhae17count__components (param $_M0L4gridS192 i32) (param $_M0L1hS186 i32) (param $_M0L1wS187 i32) (param $_M0L3visS193 i32) (result i32)
 (local $_M0L5stackS185 i32)
 (local $_M0L3idxS191 i32)
 (local $_M0L7_2abindS195 i32)
 (local $_M0L7_2abindS196 i32)
 (local $_M0L7_2abindS197 i32)
 (local $_M0L7_2abindS198 i32)
 (local $_M0L7_2abindS199 i32)
 (local $_M0L2ccS200 i32)
 (local $_M0L7_2abindS201 i32)
 (local $_M0L2rrS202 i32)
 (local $_M0L7_2abindS206 i32)
 (local $_M0L7_2abindS207 i32)
 (local $_M0L5_2anrS208 i32)
 (local $_M0L5_2ancS209 i32)
 (local $_M0L2niS210 i32)
 (local $_M0L7_2abindS211 i32)
 (local $_M0L7_2abindS212 i32)
 (local $_M0L6_2atmpS745 i32)
 (local $_M0L6_2atmpS746 i32)
 (local $_M0L6_2atmpS747 i32)
 (local $_M0L3lenS748 i32)
 (local $_M0L3bufS749 i32)
 (local $_M0L6_2atmpS750 i32)
 (local $_M0L3lenS751 i32)
 (local $_M0L3bufS752 i32)
 (local $_M0L6_2atmpS753 i32)
 (local $_M0L3lenS754 i32)
 (local $_M0L3bufS755 i32)
 (local $_M0L3lenS756 i32)
 (local $_M0L3bufS757 i32)
 (local $_M0L6_2atmpS758 i32)
 (local $_M0L3lenS759 i32)
 (local $_M0L3bufS760 i32)
 (local $_M0L6_2atmpS761 i32)
 (local $_M0L6_2atmpS762 i32)
 (local $_M0L6_2atmpS763 i32)
 (local $_M0L6_2atmpS764 i32)
 (local $_M0L6_2atmpS765 i32)
 (local $_M0L6_2atmpS766 i32)
 (local $_M0L3lenS767 i32)
 (local $_M0L3bufS768 i32)
 (local $_M0L6_2atmpS769 i32)
 (local $_M0L3lenS770 i32)
 (local $_M0L3bufS771 i32)
 (local $_M0L3lenS772 i32)
 (local $_M0L3bufS773 i32)
 (local $_M0L3lenS774 i32)
 (local $_M0L3bufS775 i32)
 (local $_M0L6_2atmpS776 i32)
 (local $_M0L3lenS777 i32)
 (local $_M0L3bufS778 i32)
 (local $_M0L6_2atmpS779 i32)
 (local $_M0L6_2atmpS780 i32)
 (local $_M0L6_2atmpS781 i32)
 (local $_M0L6_2atmpS782 i32)
 (local $_M0L6_2atmpS783 i32)
 (local $_M0L8_2atupleS784 i32)
 (local $_M0L8_2atupleS785 i32)
 (local $_M0L8_2atupleS786 i32)
 (local $_M0L8_2atupleS787 i32)
 (local $_M0L6_2atmpS788 i32)
 (local $_M0L6_2atmpS789 i32)
 (local $_M0L6_2atmpS790 i32)
 (local $_M0L6_2atmpS791 i32)
 (local $_M0L3lenS792 i32)
 (local $_M0L3bufS793 i32)
 (local $_M0L3lenS794 i32)
 (local $_M0L3bufS795 i32)
 (local $_M0L6_2atmpS796 i32)
 (local $_M0L6_2atmpS797 i32)
 (local $_M0L6_2atmpS798 i32)
 (local $_M0L6_2atmpS799 i32)
 (local $_M0L6_2atmpS800 i32)
 (local $_M0L6_2atmpS801 i32)
 (local $_M0L6_2atmpS802 i32)
 (local $_M0L6_2atmpS803 i32)
 (local $_M0L6_2aptrS1173 i32)
 (local $_M0L3ptrS1174 i32)
 (local $_M0L3ptrS1175 i32)
 (local $_M0L3ptrS1176 i32)
 (local $_M0L3ptrS1177 i32)
 (local $_M0Lm5countS188 i32)
 (local $_M0Lm1rS189 i32)
 (local $_M0Lm1cS190 i32)
 (local $_M0Lm2spS194 i32)
 (local $_M0Lm7nb__bufS203 i32)
 (local $_M0Lm7nb__lenS204 i32)
 (local $_M0Lm1dS205 i32)
 (local.set $_M0L5stackS185
  (call $_M0MPC15array5Array4makeGiE
   (local.tee $_M0L6_2atmpS801
    (i32.add
     (local.tee $_M0L6_2atmpS802
      (i32.mul
       (local.tee $_M0L6_2atmpS803
        (i32.mul
         (local.get $_M0L1hS186)
         (local.get $_M0L1wS187)))
       (i32.const 2)))
     (i32.const 2)))
   (i32.const 0)))
 (local.set $_M0Lm5countS188
  (i32.const 0))
 (local.set $_M0Lm1rS189
  (i32.const 0))
 (loop $loop:216
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS745
     (local.get $_M0Lm1rS189))
    (local.get $_M0L1hS186))
   (then
    (local.set $_M0Lm1cS190
     (i32.const 0))
    (loop $loop:215
     (if
      (i32.lt_s
       (local.tee $_M0L6_2atmpS746
        (local.get $_M0Lm1cS190))
       (local.get $_M0L1wS187))
      (then
       (local.set $_M0L6_2atmpS797
        (i32.mul
         (local.tee $_M0L6_2atmpS799
          (local.get $_M0Lm1rS189))
         (local.get $_M0L1wS187)))
       (local.set $_M0L6_2atmpS798
        (local.get $_M0Lm1cS190))
       (if
        (if (result i32)
         (i32.lt_s
          (local.tee $_M0L3idxS191
           (i32.add
            (local.get $_M0L6_2atmpS797)
            (local.get $_M0L6_2atmpS798)))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS751
           (i32.load
            (local.get $_M0L4gridS192)))
          (i32.ge_s
           (local.get $_M0L3idxS191)
           (local.get $_M0L3lenS751))))
        (then
         (unreachable))
        (else))
       (if
        (if (result i32)
         (i32.gt_s
          (local.tee $_M0L6_2atmpS750
           (i32.load
            (i32.add
             (local.tee $_M0L3bufS752
              (i32.load offset=4
               (local.get $_M0L4gridS192)))
             (i32.shl
              (local.get $_M0L3idxS191)
              (i32.const 2)))))
          (i32.const 0))
         (then
          (if
           (if (result i32)
            (i32.lt_s
             (local.get $_M0L3idxS191)
             (i32.const 0))
            (then
             (i32.const 1))
            (else
             (local.set $_M0L3lenS748
              (i32.load
               (local.get $_M0L3visS193)))
             (i32.ge_s
              (local.get $_M0L3idxS191)
              (local.get $_M0L3lenS748))))
           (then
            (unreachable))
           (else))
          (i32.eq
           (local.tee $_M0L6_2atmpS747
            (i32.load
             (i32.add
              (local.tee $_M0L3bufS749
               (i32.load offset=4
                (local.get $_M0L3visS193)))
              (i32.shl
               (local.get $_M0L3idxS191)
               (i32.const 2)))))
           (i32.const 0)))
         (else
          (i32.const 0)))
        (then
         (local.set $_M0Lm5countS188
          (i32.add
           (local.tee $_M0L6_2atmpS753
            (local.get $_M0Lm5countS188))
           (i32.const 1)))
         (if
          (if (result i32)
           (i32.lt_s
            (local.get $_M0L3idxS191)
            (i32.const 0))
           (then
            (i32.const 1))
           (else
            (local.set $_M0L3lenS754
             (i32.load
              (local.get $_M0L3visS193)))
            (i32.ge_s
             (local.get $_M0L3idxS191)
             (local.get $_M0L3lenS754))))
          (then
           (unreachable))
          (else))
         (i32.store
          (i32.add
           (local.tee $_M0L3bufS755
            (i32.load offset=4
             (local.get $_M0L3visS193)))
           (i32.shl
            (local.get $_M0L3idxS191)
            (i32.const 2)))
          (i32.const 1))
         (local.set $_M0L7_2abindS195
          (local.tee $_M0Lm2spS194
           (i32.const 0)))
         (local.set $_M0L7_2abindS196
          (local.get $_M0Lm1rS189))
         (if
          (if (result i32)
           (i32.lt_s
            (local.get $_M0L7_2abindS195)
            (i32.const 0))
           (then
            (i32.const 1))
           (else
            (local.set $_M0L3lenS756
             (i32.load
              (local.get $_M0L5stackS185)))
            (i32.ge_s
             (local.get $_M0L7_2abindS195)
             (local.get $_M0L3lenS756))))
          (then
           (unreachable))
          (else))
         (i32.store
          (i32.add
           (local.tee $_M0L3bufS757
            (i32.load offset=4
             (local.get $_M0L5stackS185)))
           (i32.shl
            (local.get $_M0L7_2abindS195)
            (i32.const 2)))
          (local.get $_M0L7_2abindS196))
         (local.set $_M0L7_2abindS197
          (local.tee $_M0Lm2spS194
           (i32.add
            (local.tee $_M0L6_2atmpS758
             (local.get $_M0Lm2spS194))
            (i32.const 1))))
         (local.set $_M0L7_2abindS198
          (local.get $_M0Lm1cS190))
         (if
          (if (result i32)
           (i32.lt_s
            (local.get $_M0L7_2abindS197)
            (i32.const 0))
           (then
            (i32.const 1))
           (else
            (local.set $_M0L3lenS759
             (i32.load
              (local.get $_M0L5stackS185)))
            (i32.ge_s
             (local.get $_M0L7_2abindS197)
             (local.get $_M0L3lenS759))))
          (then
           (unreachable))
          (else))
         (i32.store
          (i32.add
           (local.tee $_M0L3bufS760
            (i32.load offset=4
             (local.get $_M0L5stackS185)))
           (i32.shl
            (local.get $_M0L7_2abindS197)
            (i32.const 2)))
          (local.get $_M0L7_2abindS198))
         (local.set $_M0Lm2spS194
          (i32.add
           (local.tee $_M0L6_2atmpS761
            (local.get $_M0Lm2spS194))
           (i32.const 1)))
         (loop $loop:214
          (if
           (i32.gt_s
            (local.tee $_M0L6_2atmpS762
             (local.get $_M0Lm2spS194))
            (i32.const 0))
           (then
            (if
             (if (result i32)
              (i32.lt_s
               (local.tee $_M0L7_2abindS199
                (local.tee $_M0Lm2spS194
                 (i32.sub
                  (local.tee $_M0L6_2atmpS763
                   (local.get $_M0Lm2spS194))
                  (i32.const 1))))
               (i32.const 0))
              (then
               (i32.const 1))
              (else
               (local.set $_M0L3lenS794
                (i32.load
                 (local.get $_M0L5stackS185)))
               (i32.ge_s
                (local.get $_M0L7_2abindS199)
                (local.get $_M0L3lenS794))))
             (then
              (unreachable))
             (else))
            (local.set $_M0L2ccS200
             (i32.load
              (i32.add
               (local.tee $_M0L3bufS795
                (i32.load offset=4
                 (local.get $_M0L5stackS185)))
               (i32.shl
                (local.get $_M0L7_2abindS199)
                (i32.const 2)))))
            (if
             (if (result i32)
              (i32.lt_s
               (local.tee $_M0L7_2abindS201
                (local.tee $_M0Lm2spS194
                 (i32.sub
                  (local.tee $_M0L6_2atmpS764
                   (local.get $_M0Lm2spS194))
                  (i32.const 1))))
               (i32.const 0))
              (then
               (i32.const 1))
              (else
               (local.set $_M0L3lenS792
                (i32.load
                 (local.get $_M0L5stackS185)))
               (i32.ge_s
                (local.get $_M0L7_2abindS201)
                (local.get $_M0L3lenS792))))
             (then
              (unreachable))
             (else))
            (local.set $_M0L6_2atmpS791
             (i32.sub
              (local.tee $_M0L2rrS202
               (i32.load
                (i32.add
                 (local.tee $_M0L3bufS793
                  (i32.load offset=4
                   (local.get $_M0L5stackS185)))
                 (i32.shl
                  (local.get $_M0L7_2abindS201)
                  (i32.const 2)))))
              (i32.const 1)))
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS1177
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS1177)
             (local.get $_M0L2ccS200))
            (i32.store
             (local.get $_M0L3ptrS1177)
             (local.get $_M0L6_2atmpS791))
            (local.set $_M0L8_2atupleS784
             (local.get $_M0L3ptrS1177))
            (local.set $_M0L6_2atmpS790
             (i32.add
              (local.get $_M0L2rrS202)
              (i32.const 1)))
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS1176
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS1176)
             (local.get $_M0L2ccS200))
            (i32.store
             (local.get $_M0L3ptrS1176)
             (local.get $_M0L6_2atmpS790))
            (local.set $_M0L8_2atupleS785
             (local.get $_M0L3ptrS1176))
            (local.set $_M0L6_2atmpS789
             (i32.sub
              (local.get $_M0L2ccS200)
              (i32.const 1)))
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS1175
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS1175)
             (local.get $_M0L6_2atmpS789))
            (i32.store
             (local.get $_M0L3ptrS1175)
             (local.get $_M0L2rrS202))
            (local.set $_M0L8_2atupleS786
             (local.get $_M0L3ptrS1175))
            (local.set $_M0L6_2atmpS788
             (i32.add
              (local.get $_M0L2ccS200)
              (i32.const 1)))
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS1174
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS1174)
             (local.get $_M0L6_2atmpS788))
            (i32.store
             (local.get $_M0L3ptrS1174)
             (local.get $_M0L2rrS202))
            (local.set $_M0L8_2atupleS787
             (local.get $_M0L3ptrS1174))
            (i32.store
             (local.tee $_M0L6_2aptrS1173
              (call $moonbit.ref_array_make_raw
               (i32.const 4)))
             (local.get $_M0L8_2atupleS784))
            (i32.store offset=4
             (local.get $_M0L6_2aptrS1173)
             (local.get $_M0L8_2atupleS785))
            (i32.store offset=8
             (local.get $_M0L6_2aptrS1173)
             (local.get $_M0L8_2atupleS786))
            (i32.store offset=12
             (local.get $_M0L6_2aptrS1173)
             (local.get $_M0L8_2atupleS787))
            (local.set $_M0Lm7nb__bufS203
             (local.get $_M0L6_2aptrS1173))
            (local.set $_M0Lm7nb__lenS204
             (i32.const 4))
            (local.set $_M0Lm1dS205
             (i32.const 0))
            (loop $loop:213
             (if
              (i32.lt_s
               (local.tee $_M0L6_2atmpS765
                (local.get $_M0Lm1dS205))
               (i32.const 4))
              (then
               (if
                (if (result i32)
                 (i32.lt_s
                  (local.tee $_M0L7_2abindS206
                   (local.get $_M0Lm1dS205))
                  (i32.const 0))
                 (then
                  (i32.const 1))
                 (else
                  (local.set $_M0L6_2atmpS782
                   (local.get $_M0Lm7nb__lenS204))
                  (i32.ge_s
                   (local.get $_M0L7_2abindS206)
                   (local.get $_M0L6_2atmpS782))))
                (then
                 (unreachable))
                (else))
               (local.set $_M0L5_2anrS208
                (i32.load
                 (local.tee $_M0L7_2abindS207
                  (i32.load
                   (i32.add
                    (local.tee $_M0L6_2atmpS783
                     (local.get $_M0Lm7nb__bufS203))
                    (i32.shl
                     (local.get $_M0L7_2abindS206)
                     (i32.const 2)))))))
               (local.set $_M0L5_2ancS209
                (i32.load offset=4
                 (local.get $_M0L7_2abindS207)))
               (if
                (if (result i32)
                 (i32.ge_s
                  (local.get $_M0L5_2anrS208)
                  (i32.const 0))
                 (then
                  (if (result i32)
                   (i32.lt_s
                    (local.get $_M0L5_2anrS208)
                    (local.get $_M0L1hS186))
                   (then
                    (if (result i32)
                     (i32.ge_s
                      (local.get $_M0L5_2ancS209)
                      (i32.const 0))
                     (then
                      (i32.lt_s
                       (local.get $_M0L5_2ancS209)
                       (local.get $_M0L1wS187)))
                     (else
                      (i32.const 0))))
                   (else
                    (i32.const 0))))
                 (else
                  (i32.const 0)))
                (then
                 (if
                  (if (result i32)
                   (i32.lt_s
                    (local.tee $_M0L2niS210
                     (i32.add
                      (local.tee $_M0L6_2atmpS780
                       (i32.mul
                        (local.get $_M0L5_2anrS208)
                        (local.get $_M0L1wS187)))
                      (local.get $_M0L5_2ancS209)))
                    (i32.const 0))
                   (then
                    (i32.const 1))
                   (else
                    (local.set $_M0L3lenS770
                     (i32.load
                      (local.get $_M0L4gridS192)))
                    (i32.ge_s
                     (local.get $_M0L2niS210)
                     (local.get $_M0L3lenS770))))
                  (then
                   (unreachable))
                  (else))
                 (if
                  (if (result i32)
                   (i32.gt_s
                    (local.tee $_M0L6_2atmpS769
                     (i32.load
                      (i32.add
                       (local.tee $_M0L3bufS771
                        (i32.load offset=4
                         (local.get $_M0L4gridS192)))
                       (i32.shl
                        (local.get $_M0L2niS210)
                        (i32.const 2)))))
                    (i32.const 0))
                   (then
                    (if
                     (if (result i32)
                      (i32.lt_s
                       (local.get $_M0L2niS210)
                       (i32.const 0))
                      (then
                       (i32.const 1))
                      (else
                       (local.set $_M0L3lenS767
                        (i32.load
                         (local.get $_M0L3visS193)))
                       (i32.ge_s
                        (local.get $_M0L2niS210)
                        (local.get $_M0L3lenS767))))
                     (then
                      (unreachable))
                     (else))
                    (i32.eq
                     (local.tee $_M0L6_2atmpS766
                      (i32.load
                       (i32.add
                        (local.tee $_M0L3bufS768
                         (i32.load offset=4
                          (local.get $_M0L3visS193)))
                        (i32.shl
                         (local.get $_M0L2niS210)
                         (i32.const 2)))))
                     (i32.const 0)))
                   (else
                    (i32.const 0)))
                  (then
                   (if
                    (if (result i32)
                     (i32.lt_s
                      (local.get $_M0L2niS210)
                      (i32.const 0))
                     (then
                      (i32.const 1))
                     (else
                      (local.set $_M0L3lenS772
                       (i32.load
                        (local.get $_M0L3visS193)))
                      (i32.ge_s
                       (local.get $_M0L2niS210)
                       (local.get $_M0L3lenS772))))
                    (then
                     (unreachable))
                    (else))
                   (i32.store
                    (i32.add
                     (local.tee $_M0L3bufS773
                      (i32.load offset=4
                       (local.get $_M0L3visS193)))
                     (i32.shl
                      (local.get $_M0L2niS210)
                      (i32.const 2)))
                    (i32.const 1))
                   (if
                    (if (result i32)
                     (i32.lt_s
                      (local.tee $_M0L7_2abindS211
                       (local.get $_M0Lm2spS194))
                      (i32.const 0))
                     (then
                      (i32.const 1))
                     (else
                      (local.set $_M0L3lenS774
                       (i32.load
                        (local.get $_M0L5stackS185)))
                      (i32.ge_s
                       (local.get $_M0L7_2abindS211)
                       (local.get $_M0L3lenS774))))
                    (then
                     (unreachable))
                    (else))
                   (i32.store
                    (i32.add
                     (local.tee $_M0L3bufS775
                      (i32.load offset=4
                       (local.get $_M0L5stackS185)))
                     (i32.shl
                      (local.get $_M0L7_2abindS211)
                      (i32.const 2)))
                    (local.get $_M0L5_2anrS208))
                   (if
                    (if (result i32)
                     (i32.lt_s
                      (local.tee $_M0L7_2abindS212
                       (local.tee $_M0Lm2spS194
                        (i32.add
                         (local.tee $_M0L6_2atmpS776
                          (local.get $_M0Lm2spS194))
                         (i32.const 1))))
                      (i32.const 0))
                     (then
                      (i32.const 1))
                     (else
                      (local.set $_M0L3lenS777
                       (i32.load
                        (local.get $_M0L5stackS185)))
                      (i32.ge_s
                       (local.get $_M0L7_2abindS212)
                       (local.get $_M0L3lenS777))))
                    (then
                     (unreachable))
                    (else))
                   (i32.store
                    (i32.add
                     (local.tee $_M0L3bufS778
                      (i32.load offset=4
                       (local.get $_M0L5stackS185)))
                     (i32.shl
                      (local.get $_M0L7_2abindS212)
                      (i32.const 2)))
                    (local.get $_M0L5_2ancS209))
                   (local.set $_M0Lm2spS194
                    (i32.add
                     (local.tee $_M0L6_2atmpS779
                      (local.get $_M0Lm2spS194))
                     (i32.const 1))))
                  (else)))
                (else))
               (local.set $_M0Lm1dS205
                (i32.add
                 (local.tee $_M0L6_2atmpS781
                  (local.get $_M0Lm1dS205))
                 (i32.const 1)))
               (br $loop:213))
              (else
               (call $moonbit.decref
                (local.get $_M0Lm7nb__bufS203)))))
            (br $loop:214))
           (else))))
        (else))
       (local.set $_M0Lm1cS190
        (i32.add
         (local.tee $_M0L6_2atmpS796
          (local.get $_M0Lm1cS190))
         (i32.const 1)))
       (br $loop:215))
      (else)))
    (local.set $_M0Lm1rS189
     (i32.add
      (local.tee $_M0L6_2atmpS800
       (local.get $_M0Lm1rS189))
      (i32.const 1)))
    (br $loop:216))
   (else
    (call $moonbit.decref
     (local.get $_M0L5stackS185)))))
 (local.get $_M0Lm5countS188))
(func $_M0FP48moonarc34rhae3src4rhae4bbox (param $_M0L4gridS182 i32) (param $_M0L1hS174 i32) (param $_M0L1wS177 i32) (result i32)
 (local $_M0L7_2abindS181 i32)
 (local $_M0L6_2atmpS723 i32)
 (local $_M0L6_2atmpS724 i32)
 (local $_M0L6_2atmpS725 i32)
 (local $_M0L3lenS726 i32)
 (local $_M0L3bufS727 i32)
 (local $_M0L6_2atmpS728 i32)
 (local $_M0L6_2atmpS729 i32)
 (local $_M0L6_2atmpS730 i32)
 (local $_M0L6_2atmpS731 i32)
 (local $_M0L6_2atmpS732 i32)
 (local $_M0L6_2atmpS733 i32)
 (local $_M0L6_2atmpS734 i32)
 (local $_M0L6_2atmpS735 i32)
 (local $_M0L6_2atmpS736 i32)
 (local $_M0L6_2atmpS737 i32)
 (local $_M0L6_2atmpS738 i32)
 (local $_M0L6_2atmpS739 i32)
 (local $_M0L6_2atmpS740 i32)
 (local $_M0L6_2atmpS741 i32)
 (local $_M0L6_2atmpS742 i32)
 (local $_M0L6_2atmpS743 i32)
 (local $_M0L6_2atmpS744 i32)
 (local $_M0L3ptrS1178 i32)
 (local $_M0Lm2r0S173 i32)
 (local $_M0Lm2r1S175 i32)
 (local $_M0Lm2c0S176 i32)
 (local $_M0Lm2c1S178 i32)
 (local $_M0Lm1rS179 i32)
 (local $_M0Lm1cS180 i32)
 (local.set $_M0Lm2r0S173
  (local.get $_M0L1hS174))
 (local.set $_M0Lm2r1S175
  (i32.const 0))
 (local.set $_M0Lm2c0S176
  (local.get $_M0L1wS177))
 (local.set $_M0Lm2c1S178
  (i32.const 0))
 (local.set $_M0Lm1rS179
  (i32.const 0))
 (loop $loop:184
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS723
     (local.get $_M0Lm1rS179))
    (local.get $_M0L1hS174))
   (then
    (local.set $_M0Lm1cS180
     (i32.const 0))
    (loop $loop:183
     (if
      (i32.lt_s
       (local.tee $_M0L6_2atmpS724
        (local.get $_M0Lm1cS180))
       (local.get $_M0L1wS177))
      (then
       (local.set $_M0L6_2atmpS728
        (i32.mul
         (local.tee $_M0L6_2atmpS730
          (local.get $_M0Lm1rS179))
         (local.get $_M0L1wS177)))
       (local.set $_M0L6_2atmpS729
        (local.get $_M0Lm1cS180))
       (if
        (if (result i32)
         (i32.lt_s
          (local.tee $_M0L7_2abindS181
           (i32.add
            (local.get $_M0L6_2atmpS728)
            (local.get $_M0L6_2atmpS729)))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS726
           (i32.load
            (local.get $_M0L4gridS182)))
          (i32.ge_s
           (local.get $_M0L7_2abindS181)
           (local.get $_M0L3lenS726))))
        (then
         (unreachable))
        (else))
       (if
        (i32.gt_s
         (local.tee $_M0L6_2atmpS725
          (i32.load
           (i32.add
            (local.tee $_M0L3bufS727
             (i32.load offset=4
              (local.get $_M0L4gridS182)))
            (i32.shl
             (local.get $_M0L7_2abindS181)
             (i32.const 2)))))
         (i32.const 0))
        (then
         (local.set $_M0L6_2atmpS731
          (local.get $_M0Lm1rS179))
         (local.set $_M0L6_2atmpS732
          (local.get $_M0Lm2r0S173))
         (if
          (i32.lt_s
           (local.get $_M0L6_2atmpS731)
           (local.get $_M0L6_2atmpS732))
          (then
           (local.set $_M0Lm2r0S173
            (local.get $_M0Lm1rS179)))
          (else))
         (local.set $_M0L6_2atmpS733
          (local.get $_M0Lm1rS179))
         (local.set $_M0L6_2atmpS734
          (local.get $_M0Lm2r1S175))
         (if
          (i32.gt_s
           (local.get $_M0L6_2atmpS733)
           (local.get $_M0L6_2atmpS734))
          (then
           (local.set $_M0Lm2r1S175
            (local.get $_M0Lm1rS179)))
          (else))
         (local.set $_M0L6_2atmpS735
          (local.get $_M0Lm1cS180))
         (local.set $_M0L6_2atmpS736
          (local.get $_M0Lm2c0S176))
         (if
          (i32.lt_s
           (local.get $_M0L6_2atmpS735)
           (local.get $_M0L6_2atmpS736))
          (then
           (local.set $_M0Lm2c0S176
            (local.get $_M0Lm1cS180)))
          (else))
         (local.set $_M0L6_2atmpS737
          (local.get $_M0Lm1cS180))
         (local.set $_M0L6_2atmpS738
          (local.get $_M0Lm2c1S178))
         (if
          (i32.gt_s
           (local.get $_M0L6_2atmpS737)
           (local.get $_M0L6_2atmpS738))
          (then
           (local.set $_M0Lm2c1S178
            (local.get $_M0Lm1cS180)))
          (else)))
        (else))
       (local.set $_M0Lm1cS180
        (i32.add
         (local.tee $_M0L6_2atmpS739
          (local.get $_M0Lm1cS180))
         (i32.const 1)))
       (br $loop:183))
      (else)))
    (local.set $_M0Lm1rS179
     (i32.add
      (local.tee $_M0L6_2atmpS740
       (local.get $_M0Lm1rS179))
      (i32.const 1)))
    (br $loop:184))
   (else)))
 (local.set $_M0L6_2atmpS741
  (local.get $_M0Lm2r0S173))
 (local.set $_M0L6_2atmpS742
  (local.get $_M0Lm2r1S175))
 (local.set $_M0L6_2atmpS743
  (local.get $_M0Lm2c0S176))
 (local.set $_M0L6_2atmpS744
  (local.get $_M0Lm2c1S178))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1178
   (call $moonbit.gc.malloc
    (i32.const 16)))
  (i32.const 2097152))
 (i32.store offset=12
  (local.get $_M0L3ptrS1178)
  (local.get $_M0L6_2atmpS744))
 (i32.store offset=8
  (local.get $_M0L3ptrS1178)
  (local.get $_M0L6_2atmpS743))
 (i32.store offset=4
  (local.get $_M0L3ptrS1178)
  (local.get $_M0L6_2atmpS742))
 (i32.store
  (local.get $_M0L3ptrS1178)
  (local.get $_M0L6_2atmpS741))
 (local.get $_M0L3ptrS1178))
(func $_M0FP48moonarc34rhae3src4rhae12policy__gate (param $_M0L5legalS169 i32) (param $_M0L3invS165 i32) (param $_M0L6__gridS170 i32) (param $_M0L3__hS171 i32) (param $_M0L3__wS172 i32) (param $_M0L5risksS166 i32) (param $_M0L10n__actionsS167 i32) (result i32)
 (local $_M0L7blockedS164 i32)
 (local $_M0L8filteredS168 i32)
 (local $_M0L6_2atmpS718 i32)
 (local $_M0L6_2atmpS719 i32)
 (local $_M0L6_2atmpS720 i32)
 (local $_M0L6_2atmpS721 i32)
 (local $_M0L6_2atmpS722 i32)
 (local.set $_M0L6_2atmpS721
  (call $_M0FP48moonarc34rhae3src4rhae11block__noop
   (local.get $_M0L3invS165)))
 (local.set $_M0L6_2atmpS722
  (call $_M0FP48moonarc34rhae3src4rhae14block__revisit
   (local.get $_M0L5risksS166)
   (local.get $_M0L10n__actionsS167)))
 (local.set $_M0L6_2atmpS719
  (i32.or
   (local.get $_M0L6_2atmpS721)
   (local.get $_M0L6_2atmpS722)))
 (local.set $_M0L6_2atmpS720
  (call $_M0FP48moonarc34rhae3src4rhae12block__empty
   (local.get $_M0L3invS165)))
 (local.set $_M0L6_2atmpS718
  (i32.xor
   (local.tee $_M0L7blockedS164
    (i32.or
     (local.get $_M0L6_2atmpS719)
     (local.get $_M0L6_2atmpS720)))
   (i32.const -1)))
 (if (result i32)
  (i32.eq
   (local.tee $_M0L8filteredS168
    (i32.and
     (local.get $_M0L5legalS169)
     (local.get $_M0L6_2atmpS718)))
   (i32.const 0))
  (then
   (if (result i32)
    (i32.eq
     (local.get $_M0L5legalS169)
     (i32.const 0))
    (then
     (i32.const 64))
    (else
     (local.get $_M0L5legalS169))))
  (else
   (local.get $_M0L8filteredS168))))
(func $_M0FP48moonarc34rhae3src4rhae12block__empty (param $_M0L3invS163 i32) (result i32)
 (local $_M0L7_2abindS162 i32)
 (local $_M0L3lenS716 i32)
 (local $_M0L3bufS717 i32)
 (local.set $_M0L3lenS716
  (i32.load
   (local.get $_M0L3invS163)))
 (if
  (i32.ge_s
   (i32.const 1)
   (local.get $_M0L3lenS716))
  (then
   (unreachable))
  (else))
 (if (result i32)
  (i32.eq
   (local.tee $_M0L7_2abindS162
    (i32.load
     (i32.add
      (local.tee $_M0L3bufS717
       (i32.load offset=4
        (local.get $_M0L3invS163)))
      (i32.shl
       (i32.const 1)
       (i32.const 2)))))
   (i32.const 0))
  (then
   (i32.const 63))
  (else
   (i32.const 0))))
(func $_M0FP48moonarc34rhae3src4rhae14block__revisit (param $_M0L5risksS160 i32) (param $_M0L1nS158 i32) (result i32)
 (local $_M0L7_2abindS159 i32)
 (local $_M0L6_2atmpS707 i32)
 (local $_M0L6_2atmpS708 i32)
 (local $_M0L6_2atmpS709 i32)
 (local $_M0L3lenS710 i32)
 (local $_M0L3bufS711 i32)
 (local $_M0L6_2atmpS712 i32)
 (local $_M0L6_2atmpS713 i32)
 (local $_M0L6_2atmpS714 i32)
 (local $_M0L6_2atmpS715 i32)
 (local $_M0Lm7blockedS156 i32)
 (local $_M0Lm1iS157 i32)
 (local.set $_M0Lm7blockedS156
  (i32.const 0))
 (local.set $_M0Lm1iS157
  (i32.const 0))
 (loop $loop:161
  (if
   (if (result i32)
    (i32.lt_s
     (local.tee $_M0L6_2atmpS708
      (local.get $_M0Lm1iS157))
     (local.get $_M0L1nS158))
    (then
     (i32.lt_s
      (local.tee $_M0L6_2atmpS707
       (local.get $_M0Lm1iS157))
      (i32.const 7)))
    (else
     (i32.const 0)))
   (then
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS159
        (local.get $_M0Lm1iS157))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS710
        (i32.load
         (local.get $_M0L5risksS160)))
       (i32.ge_s
        (local.get $_M0L7_2abindS159)
        (local.get $_M0L3lenS710))))
     (then
      (unreachable))
     (else))
    (if
     (i32.ge_s
      (local.tee $_M0L6_2atmpS709
       (i32.load
        (i32.add
         (local.tee $_M0L3bufS711
          (i32.load offset=4
           (local.get $_M0L5risksS160)))
         (i32.shl
          (local.get $_M0L7_2abindS159)
          (i32.const 2)))))
      (i32.const 95))
     (then
      (local.set $_M0L6_2atmpS712
       (local.get $_M0Lm7blockedS156))
      (local.set $_M0L6_2atmpS714
       (local.get $_M0Lm1iS157))
      (local.set $_M0L6_2atmpS713
       (i32.shl
        (i32.const 1)
        (local.get $_M0L6_2atmpS714)))
      (local.set $_M0Lm7blockedS156
       (i32.or
        (local.get $_M0L6_2atmpS712)
        (local.get $_M0L6_2atmpS713))))
     (else))
    (local.set $_M0Lm1iS157
     (i32.add
      (local.tee $_M0L6_2atmpS715
       (local.get $_M0Lm1iS157))
      (i32.const 1)))
    (br $loop:161))
   (else)))
 (local.get $_M0Lm7blockedS156))
(func $_M0FP48moonarc34rhae3src4rhae11block__noop (param $_M0L3invS154 i32) (result i32)
 (local $_M0L7_2abindS153 i32)
 (local $_M0L7_2abindS155 i32)
 (local $_M0L3lenS703 i32)
 (local $_M0L3bufS704 i32)
 (local $_M0L3lenS705 i32)
 (local $_M0L3bufS706 i32)
 (local.set $_M0L3lenS705
  (i32.load
   (local.get $_M0L3invS154)))
 (if
  (i32.ge_s
   (i32.const 5)
   (local.get $_M0L3lenS705))
  (then
   (unreachable))
  (else))
 (local.set $_M0L7_2abindS153
  (i32.load
   (i32.add
    (local.tee $_M0L3bufS706
     (i32.load offset=4
      (local.get $_M0L3invS154)))
    (i32.shl
     (i32.const 5)
     (i32.const 2)))))
 (local.set $_M0L3lenS703
  (i32.load
   (local.get $_M0L3invS154)))
 (if
  (i32.ge_s
   (i32.const 8)
   (local.get $_M0L3lenS703))
  (then
   (unreachable))
  (else))
 (local.set $_M0L7_2abindS155
  (i32.load
   (i32.add
    (local.tee $_M0L3bufS704
     (i32.load offset=4
      (local.get $_M0L3invS154)))
    (i32.shl
     (i32.const 8)
     (i32.const 2)))))
 (if (result i32)
  (i32.eq
   (local.get $_M0L7_2abindS153)
   (i32.const 1))
  (then
   (if (result i32)
    (i32.eq
     (local.get $_M0L7_2abindS155)
     (i32.const 0))
    (then
     (i32.const 48))
    (else
     (i32.const 0))))
  (else
   (i32.const 0))))
(func $_M0FP48moonarc34rhae3src4rhae22build__candidate__rows (param $_M0L5legalS119 i32) (param $_M0L3invS139 i32) (param $_M0L3visS123 i32) (param $_M0L10path__costS132 i32) (param $_M0L8hash__loS128 i32) (param $_M0L8hash__hiS130 i32) (param $_M0L3matS126 i32) (param $_M0L6max__cS118 i32) (result i32)
 (local $_M0L1bS120 i32)
 (local $_M0L7_2abindS121 i32)
 (local $_M0L7_2abindS122 i32)
 (local $_M0L3novS124 i32)
 (local $_M0L7_2abindS125 i32)
 (local $_M0L7_2abindS127 i32)
 (local $_M0L7_2abindS129 i32)
 (local $_M0L7_2abindS131 i32)
 (local $_M0L7_2abindS133 i32)
 (local $_M0L7_2abindS134 i32)
 (local $_M0L7_2abindS135 i32)
 (local $_M0L7_2abindS136 i32)
 (local $_M0L7_2abindS137 i32)
 (local $_M0L7_2abindS138 i32)
 (local $_M0L7_2abindS140 i32)
 (local $_M0L7_2abindS141 i32)
 (local $_M0L7_2abindS142 i32)
 (local $_M0L7_2abindS143 i32)
 (local $_M0L7_2abindS144 i32)
 (local $_M0L7_2abindS145 i32)
 (local $_M0L7_2abindS146 i32)
 (local $_M0L7_2abindS147 i32)
 (local $_M0L7_2abindS148 i32)
 (local $_M0L7_2abindS149 i32)
 (local $_M0L7_2abindS150 i32)
 (local $_M0L7_2abindS151 i32)
 (local $_M0L6_2atmpS643 i32)
 (local $_M0L6_2atmpS644 i32)
 (local $_M0L6_2atmpS645 i32)
 (local $_M0L6_2atmpS646 i32)
 (local $_M0L6_2atmpS647 i32)
 (local $_M0L6_2atmpS648 i32)
 (local $_M0L3lenS649 i32)
 (local $_M0L3bufS650 i32)
 (local $_M0L3lenS651 i32)
 (local $_M0L3bufS652 i32)
 (local $_M0L3lenS653 i32)
 (local $_M0L3bufS654 i32)
 (local $_M0L3lenS655 i32)
 (local $_M0L3bufS656 i32)
 (local $_M0L3lenS657 i32)
 (local $_M0L3bufS658 i32)
 (local $_M0L6_2atmpS659 i32)
 (local $_M0L3lenS660 i32)
 (local $_M0L3bufS661 i32)
 (local $_M0L6_2atmpS662 i32)
 (local $_M0L3lenS663 i32)
 (local $_M0L3bufS664 i32)
 (local $_M0L3lenS665 i32)
 (local $_M0L3bufS666 i32)
 (local $_M0L3lenS667 i32)
 (local $_M0L3bufS668 i32)
 (local $_M0L3lenS669 i32)
 (local $_M0L3bufS670 i32)
 (local $_M0L3lenS671 i32)
 (local $_M0L3bufS672 i32)
 (local $_M0L3lenS673 i32)
 (local $_M0L3bufS674 i32)
 (local $_M0L3lenS675 i32)
 (local $_M0L3bufS676 i32)
 (local $_M0L3lenS677 i32)
 (local $_M0L3bufS678 i32)
 (local $_M0L6_2atmpS679 i32)
 (local $_M0L6_2atmpS680 i32)
 (local $_M0L3lenS681 i32)
 (local $_M0L3bufS682 i32)
 (local $_M0L3lenS683 i32)
 (local $_M0L3bufS684 i32)
 (local $_M0L3lenS685 i32)
 (local $_M0L3bufS686 i32)
 (local $_M0L3lenS687 i32)
 (local $_M0L3bufS688 i32)
 (local $_M0L3lenS689 i32)
 (local $_M0L3bufS690 i32)
 (local $_M0L3lenS691 i32)
 (local $_M0L3bufS692 i32)
 (local $_M0L3lenS693 i32)
 (local $_M0L3bufS694 i32)
 (local $_M0L3lenS695 i32)
 (local $_M0L3bufS696 i32)
 (local $_M0L6_2atmpS697 i32)
 (local $_M0L3lenS698 i32)
 (local $_M0L3bufS699 i32)
 (local $_M0L6_2atmpS700 i32)
 (local $_M0L6_2atmpS701 i32)
 (local $_M0L6_2atmpS702 i32)
 (local $_M0Lm1nS116 i32)
 (local $_M0Lm1aS117 i32)
 (local.set $_M0Lm1nS116
  (i32.const 0))
 (local.set $_M0Lm1aS117
  (i32.const 1))
 (loop $loop:152
  (if
   (if (result i32)
    (i32.le_s
     (local.tee $_M0L6_2atmpS644
      (local.get $_M0Lm1aS117))
     (i32.const 7))
    (then
     (i32.lt_s
      (local.tee $_M0L6_2atmpS643
       (local.get $_M0Lm1nS116))
      (local.get $_M0L6max__cS118)))
    (else
     (i32.const 0)))
   (then
    (local.set $_M0L6_2atmpS647
     (i32.sub
      (local.tee $_M0L6_2atmpS648
       (local.get $_M0Lm1aS117))
      (i32.const 1)))
    (if
     (i32.eq
      (local.tee $_M0L6_2atmpS645
       (i32.and
        (local.tee $_M0L6_2atmpS646
         (i32.shr_s
          (local.get $_M0L5legalS119)
          (local.get $_M0L6_2atmpS647)))
        (i32.const 1)))
      (i32.const 1))
     (then
      (local.set $_M0L1bS120
       (i32.mul
        (local.tee $_M0L6_2atmpS701
         (local.get $_M0Lm1nS116))
        (i32.const 13)))
      (if
       (if (result i32)
        (i32.lt_s
         (local.tee $_M0L7_2abindS121
          (i32.sub
           (local.tee $_M0L6_2atmpS700
            (local.get $_M0Lm1aS117))
           (i32.const 1)))
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS698
          (i32.load
           (local.get $_M0L3visS123)))
         (i32.ge_s
          (local.get $_M0L7_2abindS121)
          (local.get $_M0L3lenS698))))
       (then
        (unreachable))
       (else))
      (local.set $_M0L3novS124
       (if (result i32)
        (i32.eq
         (local.tee $_M0L7_2abindS122
          (i32.load
           (i32.add
            (local.tee $_M0L3bufS699
             (i32.load offset=4
              (local.get $_M0L3visS123)))
            (i32.shl
             (local.get $_M0L7_2abindS121)
             (i32.const 2)))))
         (i32.const 0))
        (then
         (i32.const 100))
        (else
         (i32.const 0))))
      (local.set $_M0L7_2abindS125
       (local.get $_M0Lm1aS117))
      (if
       (if (result i32)
        (i32.lt_s
         (local.get $_M0L1bS120)
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS649
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L1bS120)
          (local.get $_M0L3lenS649))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS650
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L1bS120)
         (i32.const 2)))
       (local.get $_M0L7_2abindS125))
      (if
       (if (result i32)
        (i32.lt_s
         (local.tee $_M0L7_2abindS127
          (i32.add
           (local.get $_M0L1bS120)
           (i32.const 1)))
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS651
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS127)
          (local.get $_M0L3lenS651))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS652
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS127)
         (i32.const 2)))
       (local.get $_M0L8hash__loS128))
      (if
       (if (result i32)
        (i32.lt_s
         (local.tee $_M0L7_2abindS129
          (i32.add
           (local.get $_M0L1bS120)
           (i32.const 2)))
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS653
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS129)
          (local.get $_M0L3lenS653))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS654
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS129)
         (i32.const 2)))
       (local.get $_M0L8hash__hiS130))
      (if
       (if (result i32)
        (i32.lt_s
         (local.tee $_M0L7_2abindS131
          (i32.add
           (local.get $_M0L1bS120)
           (i32.const 3)))
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS655
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS131)
          (local.get $_M0L3lenS655))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS656
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS131)
         (i32.const 2)))
       (local.get $_M0L10path__costS132))
      (local.set $_M0L7_2abindS133
       (i32.add
        (local.get $_M0L1bS120)
        (i32.const 4)))
      (if
       (if (result i32)
        (i32.lt_s
         (local.tee $_M0L7_2abindS135
          (i32.sub
           (local.tee $_M0L6_2atmpS662
            (local.get $_M0Lm1aS117))
           (i32.const 1)))
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS660
          (i32.load
           (local.get $_M0L3visS123)))
         (i32.ge_s
          (local.get $_M0L7_2abindS135)
          (local.get $_M0L3lenS660))))
       (then
        (unreachable))
       (else))
      (local.set $_M0L7_2abindS134
       (i32.mul
        (local.tee $_M0L6_2atmpS659
         (i32.load
          (i32.add
           (local.tee $_M0L3bufS661
            (i32.load offset=4
             (local.get $_M0L3visS123)))
           (i32.shl
            (local.get $_M0L7_2abindS135)
            (i32.const 2)))))
        (i32.const 100)))
      (if
       (if (result i32)
        (i32.lt_s
         (local.get $_M0L7_2abindS133)
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS657
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS133)
          (local.get $_M0L3lenS657))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS658
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS133)
         (i32.const 2)))
       (local.get $_M0L7_2abindS134))
      (if
       (if (result i32)
        (i32.lt_s
         (local.tee $_M0L7_2abindS136
          (i32.add
           (local.get $_M0L1bS120)
           (i32.const 5)))
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS663
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS136)
          (local.get $_M0L3lenS663))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS664
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS136)
         (i32.const 2)))
       (local.get $_M0L3novS124))
      (local.set $_M0L7_2abindS137
       (i32.add
        (local.get $_M0L1bS120)
        (i32.const 6)))
      (local.set $_M0L3lenS667
       (i32.load
        (local.get $_M0L3invS139)))
      (if
       (i32.ge_s
        (i32.const 8)
        (local.get $_M0L3lenS667))
       (then
        (unreachable))
       (else))
      (local.set $_M0L7_2abindS138
       (i32.load
        (i32.add
         (local.tee $_M0L3bufS668
          (i32.load offset=4
           (local.get $_M0L3invS139)))
         (i32.shl
          (i32.const 8)
          (i32.const 2)))))
      (if
       (if (result i32)
        (i32.lt_s
         (local.get $_M0L7_2abindS137)
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS665
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS137)
          (local.get $_M0L3lenS665))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS666
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS137)
         (i32.const 2)))
       (local.get $_M0L7_2abindS138))
      (local.set $_M0L7_2abindS140
       (i32.add
        (local.get $_M0L1bS120)
        (i32.const 7)))
      (local.set $_M0L3lenS671
       (i32.load
        (local.get $_M0L3invS139)))
      (if
       (i32.ge_s
        (i32.const 0)
        (local.get $_M0L3lenS671))
       (then
        (unreachable))
       (else))
      (local.set $_M0L7_2abindS141
       (i32.load
        (i32.add
         (local.tee $_M0L3bufS672
          (i32.load offset=4
           (local.get $_M0L3invS139)))
         (i32.shl
          (i32.const 0)
          (i32.const 2)))))
      (if
       (if (result i32)
        (i32.lt_s
         (local.get $_M0L7_2abindS140)
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS669
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS140)
          (local.get $_M0L3lenS669))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS670
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS140)
         (i32.const 2)))
       (local.get $_M0L7_2abindS141))
      (local.set $_M0L7_2abindS142
       (i32.add
        (local.get $_M0L1bS120)
        (i32.const 8)))
      (local.set $_M0L3lenS675
       (i32.load
        (local.get $_M0L3invS139)))
      (if
       (i32.ge_s
        (i32.const 7)
        (local.get $_M0L3lenS675))
       (then
        (unreachable))
       (else))
      (local.set $_M0L7_2abindS143
       (i32.load
        (i32.add
         (local.tee $_M0L3bufS676
          (i32.load offset=4
           (local.get $_M0L3invS139)))
         (i32.shl
          (i32.const 7)
          (i32.const 2)))))
      (if
       (if (result i32)
        (i32.lt_s
         (local.get $_M0L7_2abindS142)
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS673
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS142)
          (local.get $_M0L3lenS673))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS674
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS142)
         (i32.const 2)))
       (local.get $_M0L7_2abindS143))
      (local.set $_M0L7_2abindS144
       (i32.add
        (local.get $_M0L1bS120)
        (i32.const 9)))
      (local.set $_M0L3lenS683
       (i32.load
        (local.get $_M0L3invS139)))
      (if
       (i32.ge_s
        (i32.const 3)
        (local.get $_M0L3lenS683))
       (then
        (unreachable))
       (else))
      (local.set $_M0L6_2atmpS679
       (i32.load
        (i32.add
         (local.tee $_M0L3bufS684
          (i32.load offset=4
           (local.get $_M0L3invS139)))
         (i32.shl
          (i32.const 3)
          (i32.const 2)))))
      (local.set $_M0L3lenS681
       (i32.load
        (local.get $_M0L3invS139)))
      (if
       (i32.ge_s
        (i32.const 4)
        (local.get $_M0L3lenS681))
       (then
        (unreachable))
       (else))
      (local.set $_M0L6_2atmpS680
       (i32.load
        (i32.add
         (local.tee $_M0L3bufS682
          (i32.load offset=4
           (local.get $_M0L3invS139)))
         (i32.shl
          (i32.const 4)
          (i32.const 2)))))
      (local.set $_M0L7_2abindS145
       (i32.mul
        (local.get $_M0L6_2atmpS679)
        (local.get $_M0L6_2atmpS680)))
      (if
       (if (result i32)
        (i32.lt_s
         (local.get $_M0L7_2abindS144)
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS677
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS144)
          (local.get $_M0L3lenS677))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS678
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS144)
         (i32.const 2)))
       (local.get $_M0L7_2abindS145))
      (local.set $_M0L7_2abindS146
       (i32.add
        (local.get $_M0L1bS120)
        (i32.const 10)))
      (local.set $_M0L3lenS687
       (i32.load
        (local.get $_M0L3invS139)))
      (if
       (i32.ge_s
        (i32.const 5)
        (local.get $_M0L3lenS687))
       (then
        (unreachable))
       (else))
      (local.set $_M0L7_2abindS147
       (i32.load
        (i32.add
         (local.tee $_M0L3bufS688
          (i32.load offset=4
           (local.get $_M0L3invS139)))
         (i32.shl
          (i32.const 5)
          (i32.const 2)))))
      (if
       (if (result i32)
        (i32.lt_s
         (local.get $_M0L7_2abindS146)
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS685
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS146)
          (local.get $_M0L3lenS685))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS686
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS146)
         (i32.const 2)))
       (local.get $_M0L7_2abindS147))
      (local.set $_M0L7_2abindS148
       (i32.add
        (local.get $_M0L1bS120)
        (i32.const 11)))
      (local.set $_M0L3lenS691
       (i32.load
        (local.get $_M0L3invS139)))
      (if
       (i32.ge_s
        (i32.const 8)
        (local.get $_M0L3lenS691))
       (then
        (unreachable))
       (else))
      (local.set $_M0L7_2abindS149
       (i32.load
        (i32.add
         (local.tee $_M0L3bufS692
          (i32.load offset=4
           (local.get $_M0L3invS139)))
         (i32.shl
          (i32.const 8)
          (i32.const 2)))))
      (if
       (if (result i32)
        (i32.lt_s
         (local.get $_M0L7_2abindS148)
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS689
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS148)
          (local.get $_M0L3lenS689))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS690
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS148)
         (i32.const 2)))
       (local.get $_M0L7_2abindS149))
      (local.set $_M0L7_2abindS150
       (i32.add
        (local.get $_M0L1bS120)
        (i32.const 12)))
      (local.set $_M0L3lenS695
       (i32.load
        (local.get $_M0L3invS139)))
      (if
       (i32.ge_s
        (i32.const 9)
        (local.get $_M0L3lenS695))
       (then
        (unreachable))
       (else))
      (local.set $_M0L7_2abindS151
       (i32.load
        (i32.add
         (local.tee $_M0L3bufS696
          (i32.load offset=4
           (local.get $_M0L3invS139)))
         (i32.shl
          (i32.const 9)
          (i32.const 2)))))
      (if
       (if (result i32)
        (i32.lt_s
         (local.get $_M0L7_2abindS150)
         (i32.const 0))
        (then
         (i32.const 1))
        (else
         (local.set $_M0L3lenS693
          (i32.load
           (local.get $_M0L3matS126)))
         (i32.ge_s
          (local.get $_M0L7_2abindS150)
          (local.get $_M0L3lenS693))))
       (then
        (unreachable))
       (else))
      (i32.store
       (i32.add
        (local.tee $_M0L3bufS694
         (i32.load offset=4
          (local.get $_M0L3matS126)))
        (i32.shl
         (local.get $_M0L7_2abindS150)
         (i32.const 2)))
       (local.get $_M0L7_2abindS151))
      (local.set $_M0Lm1nS116
       (i32.add
        (local.tee $_M0L6_2atmpS697
         (local.get $_M0Lm1nS116))
        (i32.const 1))))
     (else))
    (local.set $_M0Lm1aS117
     (i32.add
      (local.tee $_M0L6_2atmpS702
       (local.get $_M0Lm1aS117))
      (i32.const 1)))
    (br $loop:152))
   (else)))
 (local.get $_M0Lm1nS116))
(func $_M0FP48moonarc34rhae3src4rhae16topk__candidates (param $_M0L5pairsS107 i32) (param $_M0L1nS104 i32) (param $_M0L1kS98 i32) (param $_M0L3outS115 i32) (result i32)
 (local $_M0L2kkS97 i32)
 (local $_M0L4usedS99 i32)
 (local $_M0L7_2abindS105 i32)
 (local $_M0L7_2abindS106 i32)
 (local $_M0L7_2abindS108 i32)
 (local $_M0L7_2abindS111 i32)
 (local $_M0L7_2abindS112 i32)
 (local $_M0L7_2abindS113 i32)
 (local $_M0L7_2abindS114 i32)
 (local $_M0L6_2atmpS617 i32)
 (local $_M0L6_2atmpS618 i32)
 (local $_M0L6_2atmpS619 i32)
 (local $_M0L6_2atmpS620 i32)
 (local $_M0L3lenS621 i32)
 (local $_M0L3bufS622 i32)
 (local $_M0L6_2atmpS623 i32)
 (local $_M0L6_2atmpS624 i32)
 (local $_M0L6_2atmpS625 i32)
 (local $_M0L3lenS626 i32)
 (local $_M0L3bufS627 i32)
 (local $_M0L3lenS628 i32)
 (local $_M0L3bufS629 i32)
 (local $_M0L6_2atmpS630 i32)
 (local $_M0L6_2atmpS631 i32)
 (local $_M0L6_2atmpS632 i32)
 (local $_M0L6_2atmpS633 i32)
 (local $_M0L6_2atmpS634 i32)
 (local $_M0L3lenS635 i32)
 (local $_M0L3bufS636 i32)
 (local $_M0L3lenS637 i32)
 (local $_M0L3bufS638 i32)
 (local $_M0L3lenS639 i32)
 (local $_M0L3bufS640 i32)
 (local $_M0L6_2atmpS641 i32)
 (local $_M0L6_2atmpS642 i32)
 (local $_M0Lm6n__selS100 i32)
 (local $_M0Lm7best__iS101 i32)
 (local $_M0Lm7best__sS102 i32)
 (local $_M0Lm1iS103 i32)
 (local.set $_M0L2kkS97
  (if (result i32)
   (i32.gt_s
    (local.get $_M0L1kS98)
    (i32.const 6))
   (then
    (i32.const 6))
   (else
    (local.get $_M0L1kS98))))
 (local.set $_M0L4usedS99
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 64)
   (i32.const 0)))
 (local.set $_M0Lm6n__selS100
  (i32.const 0))
 (block $break:110
  (loop $loop:110
   (if
    (i32.lt_s
     (local.tee $_M0L6_2atmpS617
      (local.get $_M0Lm6n__selS100))
     (local.get $_M0L2kkS97))
    (then
     (local.set $_M0Lm7best__iS101
      (i32.const -1))
     (local.set $_M0Lm7best__sS102
      (i32.const -1))
     (local.set $_M0Lm1iS103
      (i32.const 0))
     (loop $loop:109
      (if
       (i32.lt_s
        (local.tee $_M0L6_2atmpS618
         (local.get $_M0Lm1iS103))
        (local.get $_M0L1nS104))
       (then
        (if
         (if (result i32)
          (i32.lt_s
           (local.tee $_M0L7_2abindS105
            (local.get $_M0Lm1iS103))
           (i32.const 0))
          (then
           (i32.const 1))
          (else
           (local.set $_M0L3lenS626
            (i32.load
             (local.get $_M0L4usedS99)))
           (i32.ge_s
            (local.get $_M0L7_2abindS105)
            (local.get $_M0L3lenS626))))
         (then
          (unreachable))
         (else))
        (if
         (if (result i32)
          (i32.eq
           (local.tee $_M0L6_2atmpS625
            (i32.load
             (i32.add
              (local.tee $_M0L3bufS627
               (i32.load offset=4
                (local.get $_M0L4usedS99)))
              (i32.shl
               (local.get $_M0L7_2abindS105)
               (i32.const 2)))))
           (i32.const 0))
          (then
           (if
            (if (result i32)
             (i32.lt_s
              (local.tee $_M0L7_2abindS106
               (i32.add
                (local.tee $_M0L6_2atmpS623
                 (i32.mul
                  (local.tee $_M0L6_2atmpS624
                   (local.get $_M0Lm1iS103))
                  (i32.const 2)))
                (i32.const 1)))
              (i32.const 0))
             (then
              (i32.const 1))
             (else
              (local.set $_M0L3lenS621
               (i32.load
                (local.get $_M0L5pairsS107)))
              (i32.ge_s
               (local.get $_M0L7_2abindS106)
               (local.get $_M0L3lenS621))))
            (then
             (unreachable))
            (else))
           (local.set $_M0L6_2atmpS619
            (i32.load
             (i32.add
              (local.tee $_M0L3bufS622
               (i32.load offset=4
                (local.get $_M0L5pairsS107)))
              (i32.shl
               (local.get $_M0L7_2abindS106)
               (i32.const 2)))))
           (local.set $_M0L6_2atmpS620
            (local.get $_M0Lm7best__sS102))
           (i32.gt_s
            (local.get $_M0L6_2atmpS619)
            (local.get $_M0L6_2atmpS620)))
          (else
           (i32.const 0)))
         (then
          (if
           (if (result i32)
            (i32.lt_s
             (local.tee $_M0L7_2abindS108
              (i32.add
               (local.tee $_M0L6_2atmpS630
                (i32.mul
                 (local.tee $_M0L6_2atmpS631
                  (local.get $_M0Lm1iS103))
                 (i32.const 2)))
               (i32.const 1)))
             (i32.const 0))
            (then
             (i32.const 1))
            (else
             (local.set $_M0L3lenS628
              (i32.load
               (local.get $_M0L5pairsS107)))
             (i32.ge_s
              (local.get $_M0L7_2abindS108)
              (local.get $_M0L3lenS628))))
           (then
            (unreachable))
           (else))
          (local.set $_M0Lm7best__sS102
           (i32.load
            (i32.add
             (local.tee $_M0L3bufS629
              (i32.load offset=4
               (local.get $_M0L5pairsS107)))
             (i32.shl
              (local.get $_M0L7_2abindS108)
              (i32.const 2)))))
          (local.set $_M0Lm7best__iS101
           (local.get $_M0Lm1iS103)))
         (else))
        (local.set $_M0Lm1iS103
         (i32.add
          (local.tee $_M0L6_2atmpS632
           (local.get $_M0Lm1iS103))
          (i32.const 1)))
        (br $loop:109))
       (else)))
     (if
      (if (result i32)
       (i32.eq
        (local.tee $_M0L6_2atmpS634
         (local.get $_M0Lm7best__iS101))
        (i32.const -1))
       (then
        (i32.const 1))
       (else
        (i32.lt_s
         (local.tee $_M0L6_2atmpS633
          (local.get $_M0Lm7best__sS102))
         (i32.const 0))))
      (then
       (call $moonbit.decref
        (local.get $_M0L4usedS99))
       (br $break:110))
      (else))
     (if
      (if (result i32)
       (i32.lt_s
        (local.tee $_M0L7_2abindS111
         (local.get $_M0Lm7best__iS101))
        (i32.const 0))
       (then
        (i32.const 1))
       (else
        (local.set $_M0L3lenS635
         (i32.load
          (local.get $_M0L4usedS99)))
        (i32.ge_s
         (local.get $_M0L7_2abindS111)
         (local.get $_M0L3lenS635))))
      (then
       (unreachable))
      (else))
     (i32.store
      (i32.add
       (local.tee $_M0L3bufS636
        (i32.load offset=4
         (local.get $_M0L4usedS99)))
       (i32.shl
        (local.get $_M0L7_2abindS111)
        (i32.const 2)))
      (i32.const 1))
     (local.set $_M0L7_2abindS112
      (local.get $_M0Lm6n__selS100))
     (if
      (if (result i32)
       (i32.lt_s
        (local.tee $_M0L7_2abindS113
         (i32.mul
          (local.tee $_M0L6_2atmpS641
           (local.get $_M0Lm7best__iS101))
          (i32.const 2)))
        (i32.const 0))
       (then
        (i32.const 1))
       (else
        (local.set $_M0L3lenS639
         (i32.load
          (local.get $_M0L5pairsS107)))
        (i32.ge_s
         (local.get $_M0L7_2abindS113)
         (local.get $_M0L3lenS639))))
      (then
       (unreachable))
      (else))
     (local.set $_M0L7_2abindS114
      (i32.load
       (i32.add
        (local.tee $_M0L3bufS640
         (i32.load offset=4
          (local.get $_M0L5pairsS107)))
        (i32.shl
         (local.get $_M0L7_2abindS113)
         (i32.const 2)))))
     (if
      (if (result i32)
       (i32.lt_s
        (local.get $_M0L7_2abindS112)
        (i32.const 0))
       (then
        (i32.const 1))
       (else
        (local.set $_M0L3lenS637
         (i32.load
          (local.get $_M0L3outS115)))
        (i32.ge_s
         (local.get $_M0L7_2abindS112)
         (local.get $_M0L3lenS637))))
      (then
       (unreachable))
      (else))
     (i32.store
      (i32.add
       (local.tee $_M0L3bufS638
        (i32.load offset=4
         (local.get $_M0L3outS115)))
       (i32.shl
        (local.get $_M0L7_2abindS112)
        (i32.const 2)))
      (local.get $_M0L7_2abindS114))
     (local.set $_M0Lm6n__selS100
      (i32.add
       (local.tee $_M0L6_2atmpS642
        (local.get $_M0Lm6n__selS100))
       (i32.const 1)))
     (br $loop:110))
    (else
     (call $moonbit.decref
      (local.get $_M0L4usedS99))))))
 (local.get $_M0Lm6n__selS100))
(func $_M0FP48moonarc34rhae3src4rhae14visited__reset (result i32)
 (local $_M0L7_2abindS95 i32)
 (local $_M0L6_2atmpS613 i32)
 (local $_M0L3lenS614 i32)
 (local $_M0L3bufS615 i32)
 (local $_M0L6_2atmpS616 i32)
 (local $_M0Lm1iS94 i32)
 (local.set $_M0Lm1iS94
  (i32.const 0))
 (loop $loop:96
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS613
     (local.get $_M0Lm1iS94))
    (i32.const 32))
   (then
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS95
        (local.get $_M0Lm1iS94))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS614
        (i32.load
         (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)))
       (i32.ge_s
        (local.get $_M0L7_2abindS95)
        (local.get $_M0L3lenS614))))
     (then
      (unreachable))
     (else))
    (i32.store
     (i32.add
      (local.tee $_M0L3bufS615
       (i32.load offset=4
        (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)))
      (i32.shl
       (local.get $_M0L7_2abindS95)
       (i32.const 2)))
     (i32.const 0))
    (local.set $_M0Lm1iS94
     (i32.add
      (local.tee $_M0L6_2atmpS616
       (local.get $_M0Lm1iS94))
      (i32.const 1)))
    (br $loop:96))
   (else)))
 (i32.const 0))
(func $_M0FP48moonarc34rhae3src4rhae13visited__mark (param $_M0L2loS89 i32) (param $_M0L2hiS90 i32) (result i32)
 (local $_M0L1sS88 i32)
 (local $_M0L7_2abindS91 i32)
 (local $_M0L7_2abindS92 i32)
 (local $_M0L7_2abindS93 i32)
 (local $_M0L3lenS604 i32)
 (local $_M0L3bufS605 i32)
 (local $_M0L6_2atmpS606 i32)
 (local $_M0L6_2atmpS607 i32)
 (local $_M0L6_2atmpS608 i32)
 (local $_M0L3lenS609 i32)
 (local $_M0L3bufS610 i32)
 (local $_M0L6_2atmpS611 i32)
 (local $_M0L6_2atmpS612 i32)
 (local.set $_M0L7_2abindS91
  (i32.div_s
   (local.tee $_M0L1sS88
    (i32.and
     (local.tee $_M0L6_2atmpS611
      (i32.mul
       (local.tee $_M0L6_2atmpS612
        (i32.xor
         (local.get $_M0L2loS89)
         (local.get $_M0L2hiS90)))
       (i32.const -1640531527)))
     (i32.const 1023)))
   (i32.const 32)))
 (if
  (if (result i32)
   (i32.lt_s
    (local.tee $_M0L7_2abindS93
     (i32.div_s
      (local.get $_M0L1sS88)
      (i32.const 32)))
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS609
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)))
    (i32.ge_s
     (local.get $_M0L7_2abindS93)
     (local.get $_M0L3lenS609))))
  (then
   (unreachable))
  (else))
 (local.set $_M0L6_2atmpS606
  (i32.load
   (i32.add
    (local.tee $_M0L3bufS610
     (i32.load offset=4
      (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)))
    (i32.shl
     (local.get $_M0L7_2abindS93)
     (i32.const 2)))))
 (local.set $_M0L6_2atmpS608
  (i32.rem_s
   (local.get $_M0L1sS88)
   (i32.const 32)))
 (local.set $_M0L6_2atmpS607
  (i32.shl
   (i32.const 1)
   (local.get $_M0L6_2atmpS608)))
 (local.set $_M0L7_2abindS92
  (i32.or
   (local.get $_M0L6_2atmpS606)
   (local.get $_M0L6_2atmpS607)))
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L7_2abindS91)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS604
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)))
    (i32.ge_s
     (local.get $_M0L7_2abindS91)
     (local.get $_M0L3lenS604))))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS605
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)))
   (i32.shl
    (local.get $_M0L7_2abindS91)
    (i32.const 2)))
  (local.get $_M0L7_2abindS92))
 (i32.const 0))
(func $_M0FP48moonarc34rhae3src4rhae14visited__check (param $_M0L2loS85 i32) (param $_M0L2hiS86 i32) (result i32)
 (local $_M0L1sS84 i32)
 (local $_M0L7_2abindS87 i32)
 (local $_M0L6_2atmpS596 i32)
 (local $_M0L6_2atmpS597 i32)
 (local $_M0L6_2atmpS598 i32)
 (local $_M0L6_2atmpS599 i32)
 (local $_M0L3lenS600 i32)
 (local $_M0L3bufS601 i32)
 (local $_M0L6_2atmpS602 i32)
 (local $_M0L6_2atmpS603 i32)
 (if
  (if (result i32)
   (i32.lt_s
    (local.tee $_M0L7_2abindS87
     (i32.div_s
      (local.tee $_M0L1sS84
       (i32.and
        (local.tee $_M0L6_2atmpS602
         (i32.mul
          (local.tee $_M0L6_2atmpS603
           (i32.xor
            (local.get $_M0L2loS85)
            (local.get $_M0L2hiS86)))
          (i32.const -1640531527)))
        (i32.const 1023)))
      (i32.const 32)))
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS600
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)))
    (i32.ge_s
     (local.get $_M0L7_2abindS87)
     (local.get $_M0L3lenS600))))
  (then
   (unreachable))
  (else))
 (local.set $_M0L6_2atmpS598
  (i32.load
   (i32.add
    (local.tee $_M0L3bufS601
     (i32.load offset=4
      (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)))
    (i32.shl
     (local.get $_M0L7_2abindS87)
     (i32.const 2)))))
 (local.set $_M0L6_2atmpS599
  (i32.rem_s
   (local.get $_M0L1sS84)
   (i32.const 32)))
 (i32.eq
  (local.tee $_M0L6_2atmpS596
   (i32.and
    (local.tee $_M0L6_2atmpS597
     (i32.shr_s
      (local.get $_M0L6_2atmpS598)
      (local.get $_M0L6_2atmpS599)))
    (i32.const 1)))
  (i32.const 1)))
(func $_M0FP48moonarc34rhae3src4rhae9tt__store (param $_M0L2loS76 i32) (param $_M0L2hiS77 i32) (param $_M0L12best__actionS81 i32) (param $_M0L5scoreS83 i32) (result i32)
 (local $_M0L1sS75 i32)
 (local $_M0L1bS78 i32)
 (local $_M0L7_2abindS79 i32)
 (local $_M0L7_2abindS80 i32)
 (local $_M0L7_2abindS82 i32)
 (local $_M0L3lenS586 i32)
 (local $_M0L3bufS587 i32)
 (local $_M0L3lenS588 i32)
 (local $_M0L3bufS589 i32)
 (local $_M0L3lenS590 i32)
 (local $_M0L3bufS591 i32)
 (local $_M0L3lenS592 i32)
 (local $_M0L3bufS593 i32)
 (local $_M0L6_2atmpS594 i32)
 (local $_M0L6_2atmpS595 i32)
 (if
  (if (result i32)
   (i32.lt_s
    (local.tee $_M0L1bS78
     (i32.mul
      (local.tee $_M0L1sS75
       (i32.and
        (local.tee $_M0L6_2atmpS594
         (i32.mul
          (local.tee $_M0L6_2atmpS595
           (i32.xor
            (local.get $_M0L2loS76)
            (local.get $_M0L2hiS77)))
          (i32.const -1640531527)))
        (i32.const 1023)))
      (i32.const 4)))
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS586
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
    (i32.ge_s
     (local.get $_M0L1bS78)
     (local.get $_M0L3lenS586))))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS587
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
   (i32.shl
    (local.get $_M0L1bS78)
    (i32.const 2)))
  (local.get $_M0L2loS76))
 (if
  (if (result i32)
   (i32.lt_s
    (local.tee $_M0L7_2abindS79
     (i32.add
      (local.get $_M0L1bS78)
      (i32.const 1)))
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS588
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
    (i32.ge_s
     (local.get $_M0L7_2abindS79)
     (local.get $_M0L3lenS588))))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS589
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
   (i32.shl
    (local.get $_M0L7_2abindS79)
    (i32.const 2)))
  (local.get $_M0L2hiS77))
 (if
  (if (result i32)
   (i32.lt_s
    (local.tee $_M0L7_2abindS80
     (i32.add
      (local.get $_M0L1bS78)
      (i32.const 2)))
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS590
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
    (i32.ge_s
     (local.get $_M0L7_2abindS80)
     (local.get $_M0L3lenS590))))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS591
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
   (i32.shl
    (local.get $_M0L7_2abindS80)
    (i32.const 2)))
  (local.get $_M0L12best__actionS81))
 (if
  (if (result i32)
   (i32.lt_s
    (local.tee $_M0L7_2abindS82
     (i32.add
      (local.get $_M0L1bS78)
      (i32.const 3)))
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS592
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
    (i32.ge_s
     (local.get $_M0L7_2abindS82)
     (local.get $_M0L3lenS592))))
  (then
   (unreachable))
  (else))
 (i32.store
  (i32.add
   (local.tee $_M0L3bufS593
    (i32.load offset=4
     (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
   (i32.shl
    (local.get $_M0L7_2abindS82)
    (i32.const 2)))
  (local.get $_M0L5scoreS83))
 (i32.const 0))
(func $_M0FP48moonarc34rhae3src4rhae10tt__lookup (param $_M0L2loS69 i32) (param $_M0L2hiS70 i32) (result i32)
 (local $_M0L1sS68 i32)
 (local $_M0L1bS71 i32)
 (local $_M0L7_2abindS72 i32)
 (local $_M0L7_2abindS73 i32)
 (local $_M0L7_2abindS74 i32)
 (local $_M0L6_2atmpS572 i32)
 (local $_M0L3lenS573 i32)
 (local $_M0L3bufS574 i32)
 (local $_M0L6_2atmpS575 i32)
 (local $_M0L3lenS576 i32)
 (local $_M0L3bufS577 i32)
 (local $_M0L6_2atmpS578 i32)
 (local $_M0L6_2atmpS579 i32)
 (local $_M0L3lenS580 i32)
 (local $_M0L3bufS581 i32)
 (local $_M0L3lenS582 i32)
 (local $_M0L3bufS583 i32)
 (local $_M0L6_2atmpS584 i32)
 (local $_M0L6_2atmpS585 i32)
 (local $_M0L3ptrS1179 i32)
 (if
  (if (result i32)
   (i32.lt_s
    (local.tee $_M0L1bS71
     (i32.mul
      (local.tee $_M0L1sS68
       (i32.and
        (local.tee $_M0L6_2atmpS584
         (i32.mul
          (local.tee $_M0L6_2atmpS585
           (i32.xor
            (local.get $_M0L2loS69)
            (local.get $_M0L2hiS70)))
          (i32.const -1640531527)))
        (i32.const 1023)))
      (i32.const 4)))
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS576
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
    (i32.ge_s
     (local.get $_M0L1bS71)
     (local.get $_M0L3lenS576))))
  (then
   (unreachable))
  (else))
 (if (result i32)
  (if (result i32)
   (i32.eq
    (local.tee $_M0L6_2atmpS575
     (i32.load
      (i32.add
       (local.tee $_M0L3bufS577
        (i32.load offset=4
         (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
       (i32.shl
        (local.get $_M0L1bS71)
        (i32.const 2)))))
    (local.get $_M0L2loS69))
   (then
    (if
     (if (result i32)
      (i32.lt_s
       (local.tee $_M0L7_2abindS72
        (i32.add
         (local.get $_M0L1bS71)
         (i32.const 1)))
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS573
        (i32.load
         (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
       (i32.ge_s
        (local.get $_M0L7_2abindS72)
        (local.get $_M0L3lenS573))))
     (then
      (unreachable))
     (else))
    (i32.eq
     (local.tee $_M0L6_2atmpS572
      (i32.load
       (i32.add
        (local.tee $_M0L3bufS574
         (i32.load offset=4
          (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
        (i32.shl
         (local.get $_M0L7_2abindS72)
         (i32.const 2)))))
     (local.get $_M0L2hiS70)))
   (else
    (i32.const 0)))
  (then
   (if
    (if (result i32)
     (i32.lt_s
      (local.tee $_M0L7_2abindS73
       (i32.add
        (local.get $_M0L1bS71)
        (i32.const 2)))
      (i32.const 0))
     (then
      (i32.const 1))
     (else
      (local.set $_M0L3lenS582
       (i32.load
        (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
      (i32.ge_s
       (local.get $_M0L7_2abindS73)
       (local.get $_M0L3lenS582))))
    (then
     (unreachable))
    (else))
   (local.set $_M0L6_2atmpS578
    (i32.load
     (i32.add
      (local.tee $_M0L3bufS583
       (i32.load offset=4
        (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
      (i32.shl
       (local.get $_M0L7_2abindS73)
       (i32.const 2)))))
   (if
    (if (result i32)
     (i32.lt_s
      (local.tee $_M0L7_2abindS74
       (i32.add
        (local.get $_M0L1bS71)
        (i32.const 3)))
      (i32.const 0))
     (then
      (i32.const 1))
     (else
      (local.set $_M0L3lenS580
       (i32.load
        (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
      (i32.ge_s
       (local.get $_M0L7_2abindS74)
       (local.get $_M0L3lenS580))))
    (then
     (unreachable))
    (else))
   (local.set $_M0L6_2atmpS579
    (i32.load
     (i32.add
      (local.tee $_M0L3bufS581
       (i32.load offset=4
        (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)))
      (i32.shl
       (local.get $_M0L7_2abindS74)
       (i32.const 2)))))
   (call $moonbit.store_object_meta
    (local.tee $_M0L3ptrS1179
     (call $moonbit.gc.malloc
      (i32.const 12)))
    (i32.const 1572864))
   (i32.store offset=8
    (local.get $_M0L3ptrS1179)
    (local.get $_M0L6_2atmpS579))
   (i32.store offset=4
    (local.get $_M0L3ptrS1179)
    (local.get $_M0L6_2atmpS578))
   (i32.store
    (local.get $_M0L3ptrS1179)
    (i32.const 1))
   (local.get $_M0L3ptrS1179))
  (else
   (call $moonbit.incref
    (global.get $_M0FP48moonarc34rhae3src4rhae10tt__lookupN5tupleS577))
   (global.get $_M0FP48moonarc34rhae3src4rhae10tt__lookupN5tupleS577))))
(func $_M0FP48moonarc34rhae3src4rhae15canonical__hash (param $_M0L4gridS57 i32) (param $_M0L1hS52 i32) (param $_M0L1wS54 i32) (result i32)
 (local $_M0L7_2abindS55 i32)
 (local $_M0L5colorS56 i32)
 (local $_M0L2trS59 i32)
 (local $_M0L2tcS60 i32)
 (local $_M0L3idxS61 i32)
 (local $_M0L7_2abindS62 i32)
 (local $_M0L6_2atmpS511 i32)
 (local $_M0L6_2atmpS512 i32)
 (local $_M0L6_2atmpS513 i32)
 (local $_M0L6_2atmpS514 i32)
 (local $_M0L6_2atmpS515 i32)
 (local $_M0L3lenS516 i32)
 (local $_M0L3bufS517 i32)
 (local $_M0L6_2atmpS518 i32)
 (local $_M0L6_2atmpS519 i32)
 (local $_M0L3lenS520 i32)
 (local $_M0L3bufS521 i32)
 (local $_M0L6_2atmpS522 i32)
 (local $_M0L6_2atmpS523 i32)
 (local $_M0L6_2atmpS524 i32)
 (local $_M0L6_2atmpS525 i32)
 (local $_M0L6_2atmpS526 i32)
 (local $_M0L6_2atmpS527 i32)
 (local $_M0L6_2atmpS528 i32)
 (local $_M0L6_2atmpS529 i32)
 (local $_M0L6_2atmpS530 i32)
 (local $_M0L6_2atmpS531 i32)
 (local $_M0L6_2atmpS532 i32)
 (local $_M0L6_2atmpS533 i32)
 (local $_M0L6_2atmpS534 i32)
 (local $_M0L6_2atmpS535 i32)
 (local $_M0L6_2atmpS536 i32)
 (local $_M0L6_2atmpS537 i32)
 (local $_M0L6_2atmpS538 i32)
 (local $_M0L6_2atmpS539 i32)
 (local $_M0L6_2atmpS540 i32)
 (local $_M0L6_2atmpS541 i32)
 (local $_M0L6_2atmpS542 i32)
 (local $_M0L6_2atmpS543 i32)
 (local $_M0L6_2atmpS544 i32)
 (local $_M0L6_2atmpS545 i32)
 (local $_M0L6_2atmpS546 i32)
 (local $_M0L6_2atmpS547 i32)
 (local $_M0L6_2atmpS548 i32)
 (local $_M0L6_2atmpS549 i32)
 (local $_M0L6_2atmpS550 i32)
 (local $_M0L6_2atmpS551 i32)
 (local $_M0L6_2atmpS552 i32)
 (local $_M0L6_2atmpS553 i32)
 (local $_M0L6_2atmpS554 i32)
 (local $_M0L6_2atmpS555 i32)
 (local $_M0L6_2atmpS556 i32)
 (local $_M0L3lenS557 i32)
 (local $_M0L3bufS558 i32)
 (local $_M0L6_2atmpS559 i32)
 (local $_M0L6_2atmpS560 i32)
 (local $_M0L6_2atmpS561 i32)
 (local $_M0L6_2atmpS562 i32)
 (local $_M0L6_2atmpS563 i32)
 (local $_M0L6_2atmpS564 i32)
 (local $_M0L6_2atmpS565 i32)
 (local $_M0L6_2atmpS566 i32)
 (local $_M0L6_2atmpS567 i32)
 (local $_M0L6_2atmpS568 i32)
 (local $_M0L6_2atmpS569 i32)
 (local $_M0L6_2atmpS570 i32)
 (local $_M0L6_2atmpS571 i32)
 (local $_M0L3ptrS1180 i32)
 (local $_M0Lm8best__loS46 i32)
 (local $_M0Lm8best__hiS47 i32)
 (local $_M0Lm1tS48 i32)
 (local $_M0Lm2loS49 i32)
 (local $_M0Lm2hiS50 i32)
 (local $_M0Lm1rS51 i32)
 (local $_M0Lm1cS53 i32)
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init))
 (local.set $_M0Lm8best__loS46
  (i32.const 2147483647))
 (local.set $_M0Lm8best__hiS47
  (i32.const 2147483647))
 (local.set $_M0Lm1tS48
  (i32.const 0))
 (loop $loop:65
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS511
     (local.get $_M0Lm1tS48))
    (i32.const 8))
   (then
    (local.set $_M0Lm2loS49
     (i32.const 0))
    (local.set $_M0Lm2hiS50
     (i32.const 0))
    (local.set $_M0Lm1rS51
     (i32.const 0))
    (loop $loop:64
     (if
      (i32.lt_s
       (local.tee $_M0L6_2atmpS512
        (local.get $_M0Lm1rS51))
       (local.get $_M0L1hS52))
      (then
       (local.set $_M0Lm1cS53
        (i32.const 0))
       (loop $loop:63
        (if
         (i32.lt_s
          (local.tee $_M0L6_2atmpS513
           (local.get $_M0Lm1cS53))
          (local.get $_M0L1wS54))
         (then
          (local.set $_M0L6_2atmpS559
           (i32.mul
            (local.tee $_M0L6_2atmpS561
             (local.get $_M0Lm1rS51))
            (local.get $_M0L1wS54)))
          (local.set $_M0L6_2atmpS560
           (local.get $_M0Lm1cS53))
          (if
           (if (result i32)
            (i32.lt_s
             (local.tee $_M0L7_2abindS55
              (i32.add
               (local.get $_M0L6_2atmpS559)
               (local.get $_M0L6_2atmpS560)))
             (i32.const 0))
            (then
             (i32.const 1))
            (else
             (local.set $_M0L3lenS557
              (i32.load
               (local.get $_M0L4gridS57)))
             (i32.ge_s
              (local.get $_M0L7_2abindS55)
              (local.get $_M0L3lenS557))))
           (then
            (unreachable))
           (else))
          (local.set $_M0L5colorS56
           (i32.load
            (i32.add
             (local.tee $_M0L3bufS558
              (i32.load offset=4
               (local.get $_M0L4gridS57)))
             (i32.shl
              (local.get $_M0L7_2abindS55)
              (i32.const 2)))))
          (block $outer/1181 (result i32)
           (block $join:58
            (local.set $_M0L7_2abindS62
             (local.get $_M0Lm1tS48))
            (block $switch_int/1182
             (block $switch_default/1183
              (block $switch_int_7/1191
               (block $switch_int_6/1190
                (block $switch_int_5/1189
                 (block $switch_int_4/1188
                  (block $switch_int_3/1187
                   (block $switch_int_2/1186
                    (block $switch_int_1/1185
                     (block $switch_int_0/1184
                      (local.get $_M0L7_2abindS62)
                      (br_table
                       $switch_int_0/1184
                       $switch_int_1/1185
                       $switch_int_2/1186
                       $switch_int_3/1187
                       $switch_int_4/1188
                       $switch_int_5/1189
                       $switch_int_6/1190
                       $switch_int_7/1191
                       $switch_default/1183
                       ))
                     (local.set $_M0L6_2atmpS523
                      (local.get $_M0Lm1rS51))
                     (local.set $_M0L6_2atmpS524
                      (local.get $_M0Lm1cS53))
                     (local.get $_M0L6_2atmpS523)
                     (local.set $_M0L2tcS60
                      (local.get $_M0L6_2atmpS524))
                     (local.set $_M0L2trS59)
                     (br $join:58))
                    (local.set $_M0L6_2atmpS525
                     (local.get $_M0Lm1cS53))
                    (local.set $_M0L6_2atmpS527
                     (i32.sub
                      (local.get $_M0L1hS52)
                      (i32.const 1)))
                    (local.set $_M0L6_2atmpS528
                     (local.get $_M0Lm1rS51))
                    (local.set $_M0L6_2atmpS526
                     (i32.sub
                      (local.get $_M0L6_2atmpS527)
                      (local.get $_M0L6_2atmpS528)))
                    (local.get $_M0L6_2atmpS525)
                    (local.set $_M0L2tcS60
                     (local.get $_M0L6_2atmpS526))
                    (local.set $_M0L2trS59)
                    (br $join:58))
                   (local.set $_M0L6_2atmpS533
                    (i32.sub
                     (local.get $_M0L1hS52)
                     (i32.const 1)))
                   (local.set $_M0L6_2atmpS534
                    (local.get $_M0Lm1rS51))
                   (local.set $_M0L6_2atmpS529
                    (i32.sub
                     (local.get $_M0L6_2atmpS533)
                     (local.get $_M0L6_2atmpS534)))
                   (local.set $_M0L6_2atmpS531
                    (i32.sub
                     (local.get $_M0L1wS54)
                     (i32.const 1)))
                   (local.set $_M0L6_2atmpS532
                    (local.get $_M0Lm1cS53))
                   (local.set $_M0L6_2atmpS530
                    (i32.sub
                     (local.get $_M0L6_2atmpS531)
                     (local.get $_M0L6_2atmpS532)))
                   (local.get $_M0L6_2atmpS529)
                   (local.set $_M0L2tcS60
                    (local.get $_M0L6_2atmpS530))
                   (local.set $_M0L2trS59)
                   (br $join:58))
                  (local.set $_M0L6_2atmpS537
                   (i32.sub
                    (local.get $_M0L1wS54)
                    (i32.const 1)))
                  (local.set $_M0L6_2atmpS538
                   (local.get $_M0Lm1cS53))
                  (local.set $_M0L6_2atmpS535
                   (i32.sub
                    (local.get $_M0L6_2atmpS537)
                    (local.get $_M0L6_2atmpS538)))
                  (local.set $_M0L6_2atmpS536
                   (local.get $_M0Lm1rS51))
                  (local.get $_M0L6_2atmpS535)
                  (local.set $_M0L2tcS60
                   (local.get $_M0L6_2atmpS536))
                  (local.set $_M0L2trS59)
                  (br $join:58))
                 (local.set $_M0L6_2atmpS539
                  (local.get $_M0Lm1rS51))
                 (local.set $_M0L6_2atmpS541
                  (i32.sub
                   (local.get $_M0L1wS54)
                   (i32.const 1)))
                 (local.set $_M0L6_2atmpS542
                  (local.get $_M0Lm1cS53))
                 (local.set $_M0L6_2atmpS540
                  (i32.sub
                   (local.get $_M0L6_2atmpS541)
                   (local.get $_M0L6_2atmpS542)))
                 (local.get $_M0L6_2atmpS539)
                 (local.set $_M0L2tcS60
                  (local.get $_M0L6_2atmpS540))
                 (local.set $_M0L2trS59)
                 (br $join:58))
                (local.set $_M0L6_2atmpS545
                 (i32.sub
                  (local.get $_M0L1hS52)
                  (i32.const 1)))
                (local.set $_M0L6_2atmpS546
                 (local.get $_M0Lm1rS51))
                (local.set $_M0L6_2atmpS543
                 (i32.sub
                  (local.get $_M0L6_2atmpS545)
                  (local.get $_M0L6_2atmpS546)))
                (local.set $_M0L6_2atmpS544
                 (local.get $_M0Lm1cS53))
                (local.get $_M0L6_2atmpS543)
                (local.set $_M0L2tcS60
                 (local.get $_M0L6_2atmpS544))
                (local.set $_M0L2trS59)
                (br $join:58))
               (local.set $_M0L6_2atmpS547
                (local.get $_M0Lm1cS53))
               (local.set $_M0L6_2atmpS548
                (local.get $_M0Lm1rS51))
               (local.get $_M0L6_2atmpS547)
               (local.set $_M0L2tcS60
                (local.get $_M0L6_2atmpS548))
               (local.set $_M0L2trS59)
               (br $join:58))
              (local.set $_M0L6_2atmpS553
               (i32.sub
                (local.get $_M0L1wS54)
                (i32.const 1)))
              (local.set $_M0L6_2atmpS554
               (local.get $_M0Lm1cS53))
              (local.set $_M0L6_2atmpS549
               (i32.sub
                (local.get $_M0L6_2atmpS553)
                (local.get $_M0L6_2atmpS554)))
              (local.set $_M0L6_2atmpS551
               (i32.sub
                (local.get $_M0L1hS52)
                (i32.const 1)))
              (local.set $_M0L6_2atmpS552
               (local.get $_M0Lm1rS51))
              (local.set $_M0L6_2atmpS550
               (i32.sub
                (local.get $_M0L6_2atmpS551)
                (local.get $_M0L6_2atmpS552)))
              (local.get $_M0L6_2atmpS549)
              (local.set $_M0L2tcS60
               (local.get $_M0L6_2atmpS550))
              (local.set $_M0L2trS59)
              (br $join:58))
             (local.set $_M0L6_2atmpS555
              (local.get $_M0Lm1rS51))
             (local.set $_M0L6_2atmpS556
              (local.get $_M0Lm1cS53))
             (local.get $_M0L6_2atmpS555)
             (local.set $_M0L2tcS60
              (local.get $_M0L6_2atmpS556))
             (local.set $_M0L2trS59)
             (br $join:58))
            (i32.const 0)
            (br $outer/1181))
           (local.set $_M0L3idxS61
            (call $_M0FP48moonarc34rhae3src4rhae7zt__idx
             (local.get $_M0L2trS59)
             (local.get $_M0L2tcS60)
             (local.get $_M0L5colorS56)))
           (local.set $_M0L6_2atmpS514
            (local.get $_M0Lm2loS49))
           (if
            (if (result i32)
             (i32.lt_s
              (local.get $_M0L3idxS61)
              (i32.const 0))
             (then
              (i32.const 1))
             (else
              (local.set $_M0L3lenS516
               (i32.load
                (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)))
              (i32.ge_s
               (local.get $_M0L3idxS61)
               (local.get $_M0L3lenS516))))
            (then
             (unreachable))
            (else))
           (local.set $_M0L6_2atmpS515
            (i32.load
             (i32.add
              (local.tee $_M0L3bufS517
               (i32.load offset=4
                (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)))
              (i32.shl
               (local.get $_M0L3idxS61)
               (i32.const 2)))))
           (local.set $_M0Lm2loS49
            (i32.xor
             (local.get $_M0L6_2atmpS514)
             (local.get $_M0L6_2atmpS515)))
           (local.set $_M0L6_2atmpS518
            (local.get $_M0Lm2hiS50))
           (if
            (if (result i32)
             (i32.lt_s
              (local.get $_M0L3idxS61)
              (i32.const 0))
             (then
              (i32.const 1))
             (else
              (local.set $_M0L3lenS520
               (i32.load
                (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)))
              (i32.ge_s
               (local.get $_M0L3idxS61)
               (local.get $_M0L3lenS520))))
            (then
             (unreachable))
            (else))
           (local.set $_M0L6_2atmpS519
            (i32.load
             (i32.add
              (local.tee $_M0L3bufS521
               (i32.load offset=4
                (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)))
              (i32.shl
               (local.get $_M0L3idxS61)
               (i32.const 2)))))
           (local.set $_M0Lm2hiS50
            (i32.xor
             (local.get $_M0L6_2atmpS518)
             (local.get $_M0L6_2atmpS519)))
           (local.set $_M0Lm1cS53
            (i32.add
             (local.tee $_M0L6_2atmpS522
              (local.get $_M0Lm1cS53))
             (i32.const 1)))
           (i32.const 0))
          (drop)
          (br $loop:63))
         (else)))
       (local.set $_M0Lm1rS51
        (i32.add
         (local.tee $_M0L6_2atmpS562
          (local.get $_M0Lm1rS51))
         (i32.const 1)))
       (br $loop:64))
      (else)))
    (local.set $_M0L6_2atmpS567
     (local.get $_M0Lm2loS49))
    (local.set $_M0L6_2atmpS568
     (local.get $_M0Lm8best__loS46))
    (if
     (if (result i32)
      (i32.lt_s
       (local.get $_M0L6_2atmpS567)
       (local.get $_M0L6_2atmpS568))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L6_2atmpS565
        (local.get $_M0Lm2loS49))
       (local.set $_M0L6_2atmpS566
        (local.get $_M0Lm8best__loS46))
       (if (result i32)
        (i32.eq
         (local.get $_M0L6_2atmpS565)
         (local.get $_M0L6_2atmpS566))
        (then
         (local.set $_M0L6_2atmpS563
          (local.get $_M0Lm2hiS50))
         (local.set $_M0L6_2atmpS564
          (local.get $_M0Lm8best__hiS47))
         (i32.lt_s
          (local.get $_M0L6_2atmpS563)
          (local.get $_M0L6_2atmpS564)))
        (else
         (i32.const 0)))))
     (then
      (local.set $_M0Lm8best__loS46
       (local.get $_M0Lm2loS49))
      (local.set $_M0Lm8best__hiS47
       (local.get $_M0Lm2hiS50)))
     (else))
    (local.set $_M0Lm1tS48
     (i32.add
      (local.tee $_M0L6_2atmpS569
       (local.get $_M0Lm1tS48))
      (i32.const 1)))
    (br $loop:65))
   (else)))
 (local.set $_M0L6_2atmpS570
  (local.get $_M0Lm8best__loS46))
 (local.set $_M0L6_2atmpS571
  (local.get $_M0Lm8best__hiS47))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1180
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1180)
  (local.get $_M0L6_2atmpS571))
 (i32.store
  (local.get $_M0L3ptrS1180)
  (local.get $_M0L6_2atmpS570))
 (local.get $_M0L3ptrS1180))
(func $_M0FP48moonarc34rhae3src4rhae21zobrist__update__cell (param $_M0L6lo__inS44 i32) (param $_M0L6hi__inS45 i32) (param $_M0L3rowS39 i32) (param $_M0L3colS40 i32) (param $_M0L10old__colorS41 i32) (param $_M0L10new__colorS43 i32) (result i32)
 (local $_M0L6i__oldS38 i32)
 (local $_M0L6i__newS42 i32)
 (local $_M0L6_2atmpS495 i32)
 (local $_M0L6_2atmpS496 i32)
 (local $_M0L6_2atmpS497 i32)
 (local $_M0L6_2atmpS498 i32)
 (local $_M0L3lenS499 i32)
 (local $_M0L3bufS500 i32)
 (local $_M0L6_2atmpS501 i32)
 (local $_M0L3lenS502 i32)
 (local $_M0L3bufS503 i32)
 (local $_M0L6_2atmpS504 i32)
 (local $_M0L6_2atmpS505 i32)
 (local $_M0L3lenS506 i32)
 (local $_M0L3bufS507 i32)
 (local $_M0L6_2atmpS508 i32)
 (local $_M0L3lenS509 i32)
 (local $_M0L3bufS510 i32)
 (local $_M0L3ptrS1192 i32)
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init))
 (local.set $_M0L6i__oldS38
  (call $_M0FP48moonarc34rhae3src4rhae7zt__idx
   (local.get $_M0L3rowS39)
   (local.get $_M0L3colS40)
   (local.get $_M0L10old__colorS41)))
 (local.set $_M0L6i__newS42
  (call $_M0FP48moonarc34rhae3src4rhae7zt__idx
   (local.get $_M0L3rowS39)
   (local.get $_M0L3colS40)
   (local.get $_M0L10new__colorS43)))
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L6i__oldS38)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS509
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)))
    (i32.ge_s
     (local.get $_M0L6i__oldS38)
     (local.get $_M0L3lenS509))))
  (then
   (unreachable))
  (else))
 (local.set $_M0L6_2atmpS508
  (i32.load
   (i32.add
    (local.tee $_M0L3bufS510
     (i32.load offset=4
      (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)))
    (i32.shl
     (local.get $_M0L6i__oldS38)
     (i32.const 2)))))
 (local.set $_M0L6_2atmpS504
  (i32.xor
   (local.get $_M0L6lo__inS44)
   (local.get $_M0L6_2atmpS508)))
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L6i__newS42)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS506
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)))
    (i32.ge_s
     (local.get $_M0L6i__newS42)
     (local.get $_M0L3lenS506))))
  (then
   (unreachable))
  (else))
 (local.set $_M0L6_2atmpS505
  (i32.load
   (i32.add
    (local.tee $_M0L3bufS507
     (i32.load offset=4
      (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)))
    (i32.shl
     (local.get $_M0L6i__newS42)
     (i32.const 2)))))
 (local.set $_M0L6_2atmpS495
  (i32.xor
   (local.get $_M0L6_2atmpS504)
   (local.get $_M0L6_2atmpS505)))
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L6i__oldS38)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS502
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)))
    (i32.ge_s
     (local.get $_M0L6i__oldS38)
     (local.get $_M0L3lenS502))))
  (then
   (unreachable))
  (else))
 (local.set $_M0L6_2atmpS501
  (i32.load
   (i32.add
    (local.tee $_M0L3bufS503
     (i32.load offset=4
      (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)))
    (i32.shl
     (local.get $_M0L6i__oldS38)
     (i32.const 2)))))
 (local.set $_M0L6_2atmpS497
  (i32.xor
   (local.get $_M0L6hi__inS45)
   (local.get $_M0L6_2atmpS501)))
 (if
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L6i__newS42)
    (i32.const 0))
   (then
    (i32.const 1))
   (else
    (local.set $_M0L3lenS499
     (i32.load
      (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)))
    (i32.ge_s
     (local.get $_M0L6i__newS42)
     (local.get $_M0L3lenS499))))
  (then
   (unreachable))
  (else))
 (local.set $_M0L6_2atmpS498
  (i32.load
   (i32.add
    (local.tee $_M0L3bufS500
     (i32.load offset=4
      (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)))
    (i32.shl
     (local.get $_M0L6i__newS42)
     (i32.const 2)))))
 (local.set $_M0L6_2atmpS496
  (i32.xor
   (local.get $_M0L6_2atmpS497)
   (local.get $_M0L6_2atmpS498)))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1192
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1192)
  (local.get $_M0L6_2atmpS496))
 (i32.store
  (local.get $_M0L3ptrS1192)
  (local.get $_M0L6_2atmpS495))
 (local.get $_M0L3ptrS1192))
(func $_M0FP48moonarc34rhae3src4rhae19zobrist__hash__grid (param $_M0L4gridS35 i32) (param $_M0L1hS30 i32) (param $_M0L1wS32 i32) (result i32)
 (local $_M0L3idxS33 i32)
 (local $_M0L7_2abindS34 i32)
 (local $_M0L6_2atmpS473 i32)
 (local $_M0L6_2atmpS474 i32)
 (local $_M0L6_2atmpS475 i32)
 (local $_M0L6_2atmpS476 i32)
 (local $_M0L3lenS477 i32)
 (local $_M0L3bufS478 i32)
 (local $_M0L6_2atmpS479 i32)
 (local $_M0L6_2atmpS480 i32)
 (local $_M0L3lenS481 i32)
 (local $_M0L3bufS482 i32)
 (local $_M0L6_2atmpS483 i32)
 (local $_M0L6_2atmpS484 i32)
 (local $_M0L6_2atmpS485 i32)
 (local $_M0L6_2atmpS486 i32)
 (local $_M0L3lenS487 i32)
 (local $_M0L3bufS488 i32)
 (local $_M0L6_2atmpS489 i32)
 (local $_M0L6_2atmpS490 i32)
 (local $_M0L6_2atmpS491 i32)
 (local $_M0L6_2atmpS492 i32)
 (local $_M0L6_2atmpS493 i32)
 (local $_M0L6_2atmpS494 i32)
 (local $_M0L3ptrS1193 i32)
 (local $_M0Lm2loS27 i32)
 (local $_M0Lm2hiS28 i32)
 (local $_M0Lm1rS29 i32)
 (local $_M0Lm1cS31 i32)
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init))
 (local.set $_M0Lm2loS27
  (i32.const 0))
 (local.set $_M0Lm2hiS28
  (i32.const 0))
 (local.set $_M0Lm1rS29
  (i32.const 0))
 (loop $loop:37
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS473
     (local.get $_M0Lm1rS29))
    (local.get $_M0L1hS30))
   (then
    (local.set $_M0Lm1cS31
     (i32.const 0))
    (loop $loop:36
     (if
      (i32.lt_s
       (local.tee $_M0L6_2atmpS474
        (local.get $_M0Lm1cS31))
       (local.get $_M0L1wS32))
      (then
       (local.set $_M0L6_2atmpS484
        (local.get $_M0Lm1rS29))
       (local.set $_M0L6_2atmpS485
        (local.get $_M0Lm1cS31))
       (local.set $_M0L6_2atmpS489
        (i32.mul
         (local.tee $_M0L6_2atmpS491
          (local.get $_M0Lm1rS29))
         (local.get $_M0L1wS32)))
       (local.set $_M0L6_2atmpS490
        (local.get $_M0Lm1cS31))
       (if
        (if (result i32)
         (i32.lt_s
          (local.tee $_M0L7_2abindS34
           (i32.add
            (local.get $_M0L6_2atmpS489)
            (local.get $_M0L6_2atmpS490)))
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS487
           (i32.load
            (local.get $_M0L4gridS35)))
          (i32.ge_s
           (local.get $_M0L7_2abindS34)
           (local.get $_M0L3lenS487))))
        (then
         (unreachable))
        (else))
       (local.set $_M0L6_2atmpS486
        (i32.load
         (i32.add
          (local.tee $_M0L3bufS488
           (i32.load offset=4
            (local.get $_M0L4gridS35)))
          (i32.shl
           (local.get $_M0L7_2abindS34)
           (i32.const 2)))))
       (local.set $_M0L3idxS33
        (call $_M0FP48moonarc34rhae3src4rhae7zt__idx
         (local.get $_M0L6_2atmpS484)
         (local.get $_M0L6_2atmpS485)
         (local.get $_M0L6_2atmpS486)))
       (local.set $_M0L6_2atmpS475
        (local.get $_M0Lm2loS27))
       (if
        (if (result i32)
         (i32.lt_s
          (local.get $_M0L3idxS33)
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS477
           (i32.load
            (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)))
          (i32.ge_s
           (local.get $_M0L3idxS33)
           (local.get $_M0L3lenS477))))
        (then
         (unreachable))
        (else))
       (local.set $_M0L6_2atmpS476
        (i32.load
         (i32.add
          (local.tee $_M0L3bufS478
           (i32.load offset=4
            (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)))
          (i32.shl
           (local.get $_M0L3idxS33)
           (i32.const 2)))))
       (local.set $_M0Lm2loS27
        (i32.xor
         (local.get $_M0L6_2atmpS475)
         (local.get $_M0L6_2atmpS476)))
       (local.set $_M0L6_2atmpS479
        (local.get $_M0Lm2hiS28))
       (if
        (if (result i32)
         (i32.lt_s
          (local.get $_M0L3idxS33)
          (i32.const 0))
         (then
          (i32.const 1))
         (else
          (local.set $_M0L3lenS481
           (i32.load
            (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)))
          (i32.ge_s
           (local.get $_M0L3idxS33)
           (local.get $_M0L3lenS481))))
        (then
         (unreachable))
        (else))
       (local.set $_M0L6_2atmpS480
        (i32.load
         (i32.add
          (local.tee $_M0L3bufS482
           (i32.load offset=4
            (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)))
          (i32.shl
           (local.get $_M0L3idxS33)
           (i32.const 2)))))
       (local.set $_M0Lm2hiS28
        (i32.xor
         (local.get $_M0L6_2atmpS479)
         (local.get $_M0L6_2atmpS480)))
       (local.set $_M0Lm1cS31
        (i32.add
         (local.tee $_M0L6_2atmpS483
          (local.get $_M0Lm1cS31))
         (i32.const 1)))
       (br $loop:36))
      (else)))
    (local.set $_M0Lm1rS29
     (i32.add
      (local.tee $_M0L6_2atmpS492
       (local.get $_M0Lm1rS29))
      (i32.const 1)))
    (br $loop:37))
   (else)))
 (local.set $_M0L6_2atmpS493
  (local.get $_M0Lm2loS27))
 (local.set $_M0L6_2atmpS494
  (local.get $_M0Lm2hiS28))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1193
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1193)
  (local.get $_M0L6_2atmpS494))
 (i32.store
  (local.get $_M0L3ptrS1193)
  (local.get $_M0L6_2atmpS493))
 (local.get $_M0L3ptrS1193))
(func $_M0FP48moonarc34rhae3src4rhae7zt__idx (param $_M0L3rowS22 i32) (param $_M0L3colS24 i32) (param $_M0L5colorS26 i32) (result i32)
 (local $_M0L1rS21 i32)
 (local $_M0L1cS23 i32)
 (local $_M0L1kS25 i32)
 (local $_M0L6_2atmpS470 i32)
 (local $_M0L6_2atmpS471 i32)
 (local $_M0L6_2atmpS472 i32)
 (local.set $_M0L1rS21
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L3rowS22)
    (i32.const 64))
   (then
    (local.get $_M0L3rowS22))
   (else
    (i32.const 63))))
 (local.set $_M0L1cS23
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L3colS24)
    (i32.const 64))
   (then
    (local.get $_M0L3colS24))
   (else
    (i32.const 63))))
 (local.set $_M0L1kS25
  (if (result i32)
   (i32.lt_s
    (local.get $_M0L5colorS26)
    (i32.const 16))
   (then
    (local.get $_M0L5colorS26))
   (else
    (i32.const 0))))
 (i32.add
  (local.tee $_M0L6_2atmpS470
   (i32.mul
    (local.tee $_M0L6_2atmpS471
     (i32.add
      (local.tee $_M0L6_2atmpS472
       (i32.mul
        (local.get $_M0L1rS21)
        (i32.const 64)))
      (local.get $_M0L1cS23)))
    (i32.const 16)))
  (local.get $_M0L1kS25)))
(func $_M0FP48moonarc34rhae3src4rhae13zobrist__init (result i32)
 (local $_M0L7_2abindS16 i32)
 (local $_M0L7_2abindS17 i32)
 (local $_M0L7_2abindS18 i32)
 (local $_M0L7_2abindS19 i32)
 (local $_M0L6_2atmpS458 i32)
 (local $_M0L3lenS459 i32)
 (local $_M0L3bufS460 i32)
 (local $_M0L6_2atmpS461 i32)
 (local $_M0L6_2atmpS462 i32)
 (local $_M0L6_2atmpS463 i32)
 (local $_M0L3lenS464 i32)
 (local $_M0L3bufS465 i32)
 (local $_M0L6_2atmpS466 i32)
 (local $_M0L6_2atmpS467 i32)
 (local $_M0L6_2atmpS468 i32)
 (local $_M0L6_2atmpS469 i32)
 (local $_M0Lm1iS15 i32)
 (if
  (i32.load
   (global.get $_M0FP48moonarc34rhae3src4rhae8zt__init))
  (then
   (i32.const 0)
   (return))
  (else))
 (local.set $_M0Lm1iS15
  (i32.const 0))
 (loop $loop:20
  (if
   (i32.lt_s
    (local.tee $_M0L6_2atmpS458
     (local.get $_M0Lm1iS15))
    (i32.const 65536))
   (then
    (local.set $_M0L7_2abindS16
     (local.get $_M0Lm1iS15))
    (local.set $_M0L7_2abindS17
     (call $_M0FP48moonarc34rhae3src4rhae12splitmix__lo
      (local.tee $_M0L6_2atmpS461
       (i32.add
        (local.tee $_M0L6_2atmpS462
         (i32.mul
          (local.tee $_M0L6_2atmpS463
           (local.get $_M0Lm1iS15))
          (i32.const 1234567)))
        (i32.const 42)))))
    (if
     (if (result i32)
      (i32.lt_s
       (local.get $_M0L7_2abindS16)
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS459
        (i32.load
         (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)))
       (i32.ge_s
        (local.get $_M0L7_2abindS16)
        (local.get $_M0L3lenS459))))
     (then
      (unreachable))
     (else))
    (i32.store
     (i32.add
      (local.tee $_M0L3bufS460
       (i32.load offset=4
        (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)))
      (i32.shl
       (local.get $_M0L7_2abindS16)
       (i32.const 2)))
     (local.get $_M0L7_2abindS17))
    (local.set $_M0L7_2abindS18
     (local.get $_M0Lm1iS15))
    (local.set $_M0L7_2abindS19
     (call $_M0FP48moonarc34rhae3src4rhae12splitmix__hi
      (local.tee $_M0L6_2atmpS466
       (i32.add
        (local.tee $_M0L6_2atmpS467
         (i32.mul
          (local.tee $_M0L6_2atmpS468
           (local.get $_M0Lm1iS15))
          (i32.const 7654321)))
        (i32.const 137)))))
    (if
     (if (result i32)
      (i32.lt_s
       (local.get $_M0L7_2abindS18)
       (i32.const 0))
      (then
       (i32.const 1))
      (else
       (local.set $_M0L3lenS464
        (i32.load
         (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)))
       (i32.ge_s
        (local.get $_M0L7_2abindS18)
        (local.get $_M0L3lenS464))))
     (then
      (unreachable))
     (else))
    (i32.store
     (i32.add
      (local.tee $_M0L3bufS465
       (i32.load offset=4
        (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)))
      (i32.shl
       (local.get $_M0L7_2abindS18)
       (i32.const 2)))
     (local.get $_M0L7_2abindS19))
    (local.set $_M0Lm1iS15
     (i32.add
      (local.tee $_M0L6_2atmpS469
       (local.get $_M0Lm1iS15))
      (i32.const 1)))
    (br $loop:20))
   (else)))
 (i32.store
  (global.get $_M0FP48moonarc34rhae3src4rhae8zt__init)
  (i32.const 1))
 (i32.const 0))
(func $_M0FP48moonarc34rhae3src4rhae12splitmix__hi (param $_M0L1sS12 i32) (result i32)
 (local $_M0L1zS11 i32)
 (local $_M0L1zS13 i32)
 (local $_M0L1zS14 i32)
 (local $_M0L6_2atmpS453 i32)
 (local $_M0L6_2atmpS454 i32)
 (local $_M0L6_2atmpS455 i32)
 (local $_M0L6_2atmpS456 i32)
 (local $_M0L6_2atmpS457 i32)
 (local.set $_M0L6_2atmpS457
  (i32.shr_s
   (local.tee $_M0L1zS11
    (i32.add
     (local.get $_M0L1sS12)
     (i32.const 1818371886)))
   (i32.const 15)))
 (local.set $_M0L6_2atmpS455
  (i32.shr_s
   (local.tee $_M0L1zS13
    (i32.mul
     (local.tee $_M0L6_2atmpS456
      (i32.xor
       (local.get $_M0L1zS11)
       (local.get $_M0L6_2atmpS457)))
     (i32.const -1084733587)))
   (i32.const 13)))
 (local.set $_M0L6_2atmpS453
  (i32.shr_s
   (local.tee $_M0L1zS14
    (i32.mul
     (local.tee $_M0L6_2atmpS454
      (i32.xor
       (local.get $_M0L1zS13)
       (local.get $_M0L6_2atmpS455)))
     (i32.const -1798288965)))
   (i32.const 16)))
 (i32.xor
  (local.get $_M0L1zS14)
  (local.get $_M0L6_2atmpS453)))
(func $_M0FP48moonarc34rhae3src4rhae12splitmix__lo (param $_M0L1sS8 i32) (result i32)
 (local $_M0L1zS7 i32)
 (local $_M0L1zS9 i32)
 (local $_M0L1zS10 i32)
 (local $_M0L6_2atmpS448 i32)
 (local $_M0L6_2atmpS449 i32)
 (local $_M0L6_2atmpS450 i32)
 (local $_M0L6_2atmpS451 i32)
 (local $_M0L6_2atmpS452 i32)
 (local.set $_M0L6_2atmpS452
  (i32.shr_s
   (local.tee $_M0L1zS7
    (i32.add
     (local.get $_M0L1sS8)
     (i32.const -1640531527)))
   (i32.const 16)))
 (local.set $_M0L6_2atmpS450
  (i32.shr_s
   (local.tee $_M0L1zS9
    (i32.mul
     (local.tee $_M0L6_2atmpS451
      (i32.xor
       (local.get $_M0L1zS7)
       (local.get $_M0L6_2atmpS452)))
     (i32.const -2048144789)))
   (i32.const 13)))
 (local.set $_M0L6_2atmpS448
  (i32.shr_s
   (local.tee $_M0L1zS10
    (i32.mul
     (local.tee $_M0L6_2atmpS449
      (i32.xor
       (local.get $_M0L1zS9)
       (local.get $_M0L6_2atmpS450)))
     (i32.const -1028477387)))
   (i32.const 16)))
 (i32.xor
  (local.get $_M0L1zS10)
  (local.get $_M0L6_2atmpS448)))
(func $_M0MPC15array5Array4makeGiE (param $_M0L3lenS3 i32) (param $_M0L4elemS5 i32) (result i32)
 (local $_M0L3arrS2 i32)
 (local $_M0L1iS4 i32)
 (local $_M0L3bufS446 i32)
 (local $_M0L6_2atmpS447 i32)
 (local.set $_M0L3arrS2
  (call $_M0MPC15array5Array12make__uninitGiE
   (local.get $_M0L3lenS3)))
 (i32.const 0)
 (loop $loop:6 (param i32)
  (local.tee $_M0L1iS4)
  (local.get $_M0L3lenS3)
  (i32.lt_s)
  (if
   (then
    (i32.store
     (i32.add
      (local.tee $_M0L3bufS446
       (i32.load offset=4
        (local.get $_M0L3arrS2)))
      (i32.shl
       (local.get $_M0L1iS4)
       (i32.const 2)))
     (local.get $_M0L4elemS5))
    (local.tee $_M0L6_2atmpS447
     (i32.add
      (local.get $_M0L1iS4)
      (i32.const 1)))
    (br $loop:6))
   (else)))
 (local.get $_M0L3arrS2))
(func $_M0MPC15array5Array12make__uninitGiE (param $_M0L3lenS1 i32) (result i32)
 (local $_M0L6_2atmpS445 i32)
 (local $_M0L3ptrS1194 i32)
 (local.set $_M0L6_2atmpS445
  (call $moonbit.i32_array_make_raw
   (local.get $_M0L3lenS1)))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1194
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 524544))
 (i32.store
  (local.get $_M0L3ptrS1194)
  (local.get $_M0L3lenS1))
 (i32.store offset=4
  (local.get $_M0L3ptrS1194)
  (local.get $_M0L6_2atmpS445))
 (local.get $_M0L3ptrS1194))
(start $_M0FP017____moonbit__init)
(func $_M0FP017____moonbit__init
 (local $_M0L3ptrS1195 i32)
 (local $_M0L3ptrS1196 i32)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1196
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1196)
  (i32.const 0))
 (global.set $_M0FP48moonarc34rhae3src4rhae8zt__init
  (local.get $_M0L3ptrS1196))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1195
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1195)
  (i32.const 0))
 (global.set $_M0FP48moonarc34rhae3src4rhae8hash__hi
  (local.get $_M0L3ptrS1195))
 (global.set $_M0FP48moonarc34rhae3src4rhae14tt__store__arr
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 4096)
   (i32.const 0)))
 (global.set $_M0FP48moonarc34rhae3src4rhae6zt__hi
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 65536)
   (i32.const 0)))
 (global.set $_M0FP48moonarc34rhae3src4rhae6zt__lo
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 65536)
   (i32.const 0)))
 (global.set $_M0FP48moonarc34rhae3src4rhae8inv__buf
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 10)
   (i32.const 0)))
 (global.set $_M0FP48moonarc34rhae3src4rhae8vis__buf
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 7)
   (i32.const 0)))
 (global.set $_M0FP48moonarc34rhae3src4rhae8mat__buf
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 91)
   (i32.const 0)))
 (global.set $_M0FP48moonarc34rhae3src4rhae9prev__buf
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 4096)
   (i32.const 0)))
 (global.set $_M0FP48moonarc34rhae3src4rhae9grid__buf
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 4096)
   (i32.const 0)))
 (global.set $_M0FP48moonarc34rhae3src4rhae13visited__bits
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 32)
   (i32.const 0)))
 (global.set $_M0FP48moonarc34rhae3src4rhae9risk__buf
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 7)
   (i32.const 0)))
 (global.set $_M0FP48moonarc34rhae3src4rhae9topk__buf
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 6)
   (i32.const 0))))
(func $_M0FP017____moonbit__main
 (local $_M0L11dummy__gridS422 i32)
 (local $_M0L10dummy__outS423 i32)
 (local $_M0L10dummy__invS424 i32)
 (local $_M0L10dummy__visS425 i32)
 (local $_M0L10dummy__matS426 i32)
 (local $_M0L9dummy__tkS427 i32)
 (local $_M0L8dummy__pS428 i32)
 (local $_M0L4_2apS442 i32)
 (local $_M0L6_2atmpS1140 i32)
 (local $_M0L6_2atmpS1141 i32)
 (local $_M0L6_2atmpS1142 i32)
 (local $_M0L6_2atmpS1143 i32)
 (local $_M0L6_2atmpS1144 i32)
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae15set__grid__cell
   (i32.const 0)
   (i32.const 1)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae15set__prev__cell
   (i32.const 0)
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae12set__visited
   (i32.const 0)
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae9set__risk
   (i32.const 0)
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae8get__inv
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae8get__mat
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae9get__topk
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae16rhae__invariants
   (i32.const 8)
   (i32.const 8)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae21rhae__canonical__hash
   (i32.const 8)
   (i32.const 8)))
 (drop
  (i32.load
   (global.get $_M0FP48moonarc34rhae3src4rhae8hash__hi)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae20rhae__visited__check
   (i32.const 0)
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae19rhae__visited__mark
   (i32.const 0)
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae20rhae__visited__reset))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae18rhae__policy__gate
   (i32.const 127)
   (i32.const 8)
   (i32.const 8)
   (i32.const 7)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae23rhae__build__candidates
   (i32.const 127)
   (i32.const 0)
   (i32.const 0)
   (i32.const 0)
   (i32.const 7)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae10rhae__topk
   (i32.const 7)
   (i32.const 6)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae16rhae__tt__lookup
   (i32.const 0)
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae15rhae__tt__store
   (i32.const 0)
   (i32.const 0)
   (i32.const 1)
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae22rhae__hash__and__check
   (i32.const 8)
   (i32.const 8)))
 (drop
  (if (result i32)
   (if (result i32)
    (i32.ge_s
     (local.tee $_M0L4_2apS442
      (i32.const 3))
     (i32.const 1))
    (then
     (i32.le_s
      (local.get $_M0L4_2apS442)
      (i32.const 7)))
    (else
     (i32.const 0)))
   (then
    (local.get $_M0L4_2apS442))
   (else
    (i32.const 1))))
 (local.set $_M0L11dummy__gridS422
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 64)
   (i32.const 0)))
 (local.set $_M0L10dummy__outS423
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 64)
   (i32.const 0)))
 (local.set $_M0L10dummy__invS424
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 10)
   (i32.const 0)))
 (local.set $_M0L10dummy__visS425
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 7)
   (i32.const 0)))
 (local.set $_M0L10dummy__matS426
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 91)
   (i32.const 0)))
 (local.set $_M0L9dummy__tkS427
  (call $_M0MPC15array5Array4makeGiE
   (i32.const 6)
   (i32.const 0)))
 (call $moonbit.decref
  (local.tee $_M0L6_2atmpS1144
   (call $_M0FP48moonarc34rhae3src4rhae18canonicalize__grid
    (local.get $_M0L11dummy__gridS422)
    (i32.const 8)
    (i32.const 8)
    (local.get $_M0L10dummy__outS423))))
 (call $_M0FP48moonarc34rhae3src4rhae17normalize__colors
  (local.get $_M0L11dummy__gridS422)
  (i32.const 64)
  (local.get $_M0L10dummy__outS423))
 (call $moonbit.decref
  (local.get $_M0L10dummy__outS423))
 (drop)
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae19compute__invariants
   (local.get $_M0L11dummy__gridS422)
   (local.get $_M0L11dummy__gridS422)
   (i32.const 8)
   (i32.const 8)
   (local.get $_M0L10dummy__invS424)))
 (call $moonbit.decref
  (local.tee $_M0L6_2atmpS1143
   (call $_M0FP48moonarc34rhae3src4rhae19zobrist__hash__grid
    (local.get $_M0L11dummy__gridS422)
    (i32.const 8)
    (i32.const 8))))
 (call $moonbit.decref
  (local.tee $_M0L6_2atmpS1142
   (call $_M0FP48moonarc34rhae3src4rhae21zobrist__update__cell
    (i32.const 0)
    (i32.const 0)
    (i32.const 0)
    (i32.const 0)
    (i32.const 0)
    (i32.const 1))))
 (call $moonbit.decref
  (local.tee $_M0L6_2atmpS1141
   (call $_M0FP48moonarc34rhae3src4rhae15canonical__hash
    (local.get $_M0L11dummy__gridS422)
    (i32.const 8)
    (i32.const 8))))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae14visited__check
   (i32.const 0)
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae13visited__mark
   (i32.const 0)
   (i32.const 0)))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae14visited__reset))
 (call $moonbit.decref
  (local.tee $_M0L6_2atmpS1140
   (call $_M0FP48moonarc34rhae3src4rhae10tt__lookup
    (i32.const 0)
    (i32.const 0))))
 (drop
  (call $_M0FP48moonarc34rhae3src4rhae9tt__store
   (i32.const 0)
   (i32.const 0)
   (i32.const 1)
   (i32.const 0)))
 (call $_M0FP48moonarc34rhae3src4rhae12policy__gate
  (i32.const 127)
  (local.get $_M0L10dummy__invS424)
  (local.get $_M0L11dummy__gridS422)
  (i32.const 8)
  (i32.const 8)
  (local.get $_M0L10dummy__visS425)
  (i32.const 7))
 (call $moonbit.decref
  (local.get $_M0L11dummy__gridS422))
 (drop)
 (call $_M0FP48moonarc34rhae3src4rhae22build__candidate__rows
  (i32.const 127)
  (local.get $_M0L10dummy__invS424)
  (local.get $_M0L10dummy__visS425)
  (i32.const 0)
  (i32.const 0)
  (i32.const 0)
  (local.get $_M0L10dummy__matS426)
  (i32.const 7))
 (call $moonbit.decref
  (local.get $_M0L10dummy__invS424))
 (call $moonbit.decref
  (local.get $_M0L10dummy__visS425))
 (call $moonbit.decref
  (local.get $_M0L10dummy__matS426))
 (drop)
 (call $_M0FP48moonarc34rhae3src4rhae16topk__candidates
  (local.tee $_M0L8dummy__pS428
   (call $_M0MPC15array5Array4makeGiE
    (i32.const 14)
    (i32.const 0)))
  (i32.const 7)
  (i32.const 6)
  (local.get $_M0L9dummy__tkS427))
 (call $moonbit.decref
  (local.get $_M0L8dummy__pS428))
 (call $moonbit.decref
  (local.get $_M0L9dummy__tkS427))
 (drop))
(export "_start" (func $_M0FP017____moonbit__main))
(func $rhae_get_hash_hi (result i32)
 (i32.load
  (global.get $_M0FP48moonarc34rhae3src4rhae8hash__hi)))
(export "rhae_get_hash_hi" (func $rhae_get_hash_hi))
(export "rhae_invariants" (func $_M0FP48moonarc34rhae3src4rhae16rhae__invariants))
(export "rhae_canonical_hash" (func $_M0FP48moonarc34rhae3src4rhae21rhae__canonical__hash))
(export "rhae_hash_and_check" (func $_M0FP48moonarc34rhae3src4rhae22rhae__hash__and__check))
(export "rhae_visited_check" (func $_M0FP48moonarc34rhae3src4rhae20rhae__visited__check))
(export "rhae_visited_mark" (func $_M0FP48moonarc34rhae3src4rhae19rhae__visited__mark))
(export "rhae_visited_reset" (func $_M0FP48moonarc34rhae3src4rhae20rhae__visited__reset))
(export "rhae_policy_gate" (func $_M0FP48moonarc34rhae3src4rhae18rhae__policy__gate))
(export "rhae_build_candidates" (func $_M0FP48moonarc34rhae3src4rhae23rhae__build__candidates))
(export "rhae_topk" (func $_M0FP48moonarc34rhae3src4rhae10rhae__topk))
(export "rhae_tt_lookup" (func $_M0FP48moonarc34rhae3src4rhae16rhae__tt__lookup))
(export "rhae_tt_store" (func $_M0FP48moonarc34rhae3src4rhae15rhae__tt__store))
(export "set_grid_cell" (func $_M0FP48moonarc34rhae3src4rhae15set__grid__cell))
(export "set_prev_cell" (func $_M0FP48moonarc34rhae3src4rhae15set__prev__cell))
(export "set_visited" (func $_M0FP48moonarc34rhae3src4rhae12set__visited))
(export "set_risk" (func $_M0FP48moonarc34rhae3src4rhae9set__risk))
(export "get_inv" (func $_M0FP48moonarc34rhae3src4rhae8get__inv))
(export "get_mat" (func $_M0FP48moonarc34rhae3src4rhae8get__mat))
(export "get_topk" (func $_M0FP48moonarc34rhae3src4rhae9get__topk))
(export "zobrist_init" (func $_M0FP48moonarc34rhae3src4rhae13zobrist__init))
(export "zobrist_hash_grid" (func $_M0FP48moonarc34rhae3src4rhae19zobrist__hash__grid))
(export "zobrist_update_cell" (func $_M0FP48moonarc34rhae3src4rhae21zobrist__update__cell))
