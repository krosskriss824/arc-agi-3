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
    (i32.const 10000)
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
   (i32.const 10000)
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
(func $moonbit.array_length (param $arr i32) (result i32)
 (i32.and
  (i32.load
   (i32.sub
    (local.get $arr)
    (i32.const 4)))
  (i32.const 268435455)))
(func $moonbit.check_range (param $index i32) (param $lo i32) (param $hi i32)
 (if
  (i32.le_s
   (local.get $index)
   (local.get $hi))
  (then
   (if
    (i32.ge_s
     (local.get $index)
     (local.get $lo))
    (then)
    (else
     (unreachable))))
  (else
   (unreachable))))
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
(global $_M0FP48moonarc34rhae3src4rhae8zb__rows
 i32
 (i32.const 64)
)
(global $_M0FP48moonarc34rhae3src4rhae8zb__cols
 i32
 (i32.const 64)
)
(global $_M0FP48moonarc34rhae3src4rhae10zb__colors
 i32
 (i32.const 16)
)
(global $_M0FP48moonarc34rhae3src4rhae8zb__size
 i32
 (i32.const 65536)
)
(global $_M0FP48moonarc34rhae3src4rhae8zt__init
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae8tt__mask
 i32
 (i32.const 1023)
)
(global $_M0FP48moonarc34rhae3src4rhae10tt__stride
 i32
 (i32.const 4)
)
(global $_M0FP48moonarc34rhae3src4rhae8hash__hi
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae9__bulk__h
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae9__bulk__w
 (mut i32)
 (i32.const 0)
)
(global $_M0FP48moonarc34rhae3src4rhae14tt__store__arr
 (mut i32)
 (i32.const 0)
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
(global $_M0FP48moonarc34rhae3src4rhae11target__buf
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
(func $_M0FP48moonarc34rhae3src4rhae21rhae__d4__hashes__all (param $_M0L1hS470 i32) (param $_M0L1wS471 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae bulk_hash.mbt 10 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae15d4__hashes__all
  (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
  (local.get $_M0L1hS470)
  (local.get $_M0L1wS471))
 (; source_pos moonarc3/rhae/src/rhae bulk_hash.mbt 10 31 ;))
(func $_M0FP48moonarc34rhae3src4rhae16rhae__copy__prev (param $_M0L1nS468 i32) (result i32)
 (local $_M0L1iS467 i32)
 (local $_M0L3valS1164 i32)
 (local $_M0L3valS1165 i32)
 (local $_M0L6_2atmpS1166 i32)
 (local $_M0L3valS1167 i32)
 (local $_M0L6_2atmpS1168 i32)
 (local $_M0L3valS1169 i32)
 (local $_M0L3ptrS1179 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 20 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1179
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1179)
  (i32.const 0))
 (local.set $_M0L1iS467
  (local.get $_M0L3ptrS1179))
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 21 2 ;)
 (loop $loop:469
  (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 21 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS1164
    (i32.load
     (local.get $_M0L1iS467)))
   (local.get $_M0L1nS468))
  (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 21 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 22 4 ;)
    (local.set $_M0L3valS1165
     (i32.load
      (local.get $_M0L1iS467)))
    (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 22 18 ;)
    (local.set $_M0L3valS1167
     (i32.load
      (local.get $_M0L1iS467)))
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
     (local.get $_M0L3valS1167))
    (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 22 29 ;)
    (local.set $_M0L6_2atmpS1166)
    (call $_M0MPC15array5Array3setGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae9prev__buf)
     (local.get $_M0L3valS1165)
     (local.get $_M0L6_2atmpS1166))
    (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 22 29 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 23 4 ;)
    (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 23 8 ;)
    (i32.add
     (local.tee $_M0L3valS1169
      (i32.load
       (local.get $_M0L1iS467)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 23 13 ;)
    (local.set $_M0L6_2atmpS1168)
    (i32.store
     (local.get $_M0L1iS467)
     (local.get $_M0L6_2atmpS1168))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 23 13 ;)
    (drop)
    (br $loop:469))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS467)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 24 3 ;)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 24 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae18rhae__get__bulk__w (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 15 34 ;)
 (i32.load
  (global.get $_M0FP48moonarc34rhae3src4rhae9__bulk__w))
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 15 45 ;))
(func $_M0FP48moonarc34rhae3src4rhae18rhae__get__bulk__h (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 14 34 ;)
 (i32.load
  (global.get $_M0FP48moonarc34rhae3src4rhae9__bulk__h))
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 14 45 ;))
(func $_M0FP48moonarc34rhae3src4rhae15rhae__set__dims (param $_M0L1hS465 i32) (param $_M0L1wS466 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 10 2 ;)
 (i32.store
  (global.get $_M0FP48moonarc34rhae3src4rhae9__bulk__h)
  (local.get $_M0L1hS465))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 10 17 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 11 2 ;)
 (i32.store
  (global.get $_M0FP48moonarc34rhae3src4rhae9__bulk__w)
  (local.get $_M0L1wS466))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 11 17 ;))
(func $_M0FP48moonarc34rhae3src4rhae17normalize__colors (param $_M0L4gridS458 i32) (param $_M0L1nS456 i32) (param $_M0L3outS463 i32) (result i32)
 (local $_M0L5remapS453 i32)
 (local $_M0L7next__cS454 i32)
 (local $_M0L1iS455 i32)
 (local $_M0L1cS457 i32)
 (local $_M0L2mcS459 i32)
 (local $_M0L1vS461 i32)
 (local $_M0L7_2abindS462 i32)
 (local $_M0L3valS1156 i32)
 (local $_M0L3valS1157 i32)
 (local $_M0L6_2atmpS1158 i32)
 (local $_M0L3valS1159 i32)
 (local $_M0L3valS1160 i32)
 (local $_M0L6_2atmpS1161 i32)
 (local $_M0L3valS1162 i32)
 (local $_M0L3valS1163 i32)
 (local $_M0L3ptrS1181 i32)
 (local $_M0L3ptrS1182 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 105 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 105 27 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 16)
  (i32.const -1))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 105 46 ;)
 (local.set $_M0L5remapS453)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 106 2 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L5remapS453)
  (i32.const 0)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 106 14 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 107 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 107 26 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1182
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1182)
  (i32.const 1))
 (local.get $_M0L3ptrS1182)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 107 36 ;)
 (local.set $_M0L7next__cS454)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 108 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1181
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1181)
  (i32.const 0))
 (local.set $_M0L1iS455
  (local.get $_M0L3ptrS1181))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 109 2 ;)
 (loop $loop:464
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 109 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS1156
    (i32.load
     (local.get $_M0L1iS455)))
   (local.get $_M0L1nS456))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 109 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 110 4 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 110 12 ;)
    (local.set $_M0L3valS1163
     (i32.load
      (local.get $_M0L1iS455)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4gridS458)
     (local.get $_M0L3valS1163))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 110 19 ;)
    (local.set $_M0L1cS457)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 111 4 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 111 13 ;)
    (block $outer/1180 (result i32)
     (block $join:460
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 111 13 ;)
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 111 19 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L5remapS453)
       (local.get $_M0L1cS457))
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 111 27 ;)
      (local.tee $_M0L7_2abindS462)
      (i32.const -1)
      (i32.eq)
      (if (result i32)
       (then
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 14 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 25 ;)
        (i32.load
         (local.get $_M0L7next__cS454))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 35 ;)
        (local.set $_M0L3valS1160)
        (call $_M0MPC15array5Array3setGiE
         (local.get $_M0L5remapS453)
         (local.get $_M0L1cS457)
         (local.get $_M0L3valS1160))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 35 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 37 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 50 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 50 ;)
        (i32.load
         (local.get $_M0L7next__cS454))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 60 ;)
        (local.tee $_M0L3valS1162)
        (i32.const 1)
        (i32.add)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 64 ;)
        (local.set $_M0L6_2atmpS1161)
        (i32.store
         (local.get $_M0L7next__cS454)
         (local.get $_M0L6_2atmpS1161))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 64 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 66 ;)
        (call $_M0MPC15array5Array2atGiE
         (local.get $_M0L5remapS453)
         (local.get $_M0L1cS457))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 74 ;))
       (else
        (local.set $_M0L1vS461
         (local.get $_M0L7_2abindS462))
        (br $join:460)))
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 114 5 ;)
      (br $outer/1180))
     (local.get $_M0L1vS461))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 114 5 ;)
    (local.set $_M0L2mcS459)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 115 4 ;)
    (local.set $_M0L3valS1157
     (i32.load
      (local.get $_M0L1iS455)))
    (call $_M0MPC15array5Array3setGiE
     (local.get $_M0L3outS463)
     (local.get $_M0L3valS1157)
     (local.get $_M0L2mcS459))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 115 15 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 4 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 8 ;)
    (i32.add
     (local.tee $_M0L3valS1159
      (i32.load
       (local.get $_M0L1iS455)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 13 ;)
    (local.set $_M0L6_2atmpS1158)
    (i32.store
     (local.get $_M0L1iS455)
     (local.get $_M0L6_2atmpS1158))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 13 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 13 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 13 ;)
    (drop)
    (br $loop:464))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS455))
    (call $moonbit.decref
     (local.get $_M0L5remapS453)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 117 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 118 2 ;)
 (i32.load
  (local.get $_M0L7next__cS454))
 (call $moonbit.decref
  (local.get $_M0L7next__cS454))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 118 12 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 118 12 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 118 12 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 118 12 ;))
(func $_M0FP48moonarc34rhae3src4rhae18canonicalize__grid (param $_M0L4gridS421 i32) (param $_M0L1hS406 i32) (param $_M0L1wS408 i32) (param $_M0L8out__bufS420 i32) (result i32)
 (local $_M0L7best__tS404 i32)
 (local $_M0L7best__hS405 i32)
 (local $_M0L7best__wS407 i32)
 (local $_M0L8write__tS409 i32)
 (local $_M0L10is__betterS430 i32)
 (local $_M0L1tS451 i32)
 (local $_M0L3valS1149 i32)
 (local $_M0L3valS1150 i32)
 (local $_M0L3valS1151 i32)
 (local $_M0L6_2atmpS1152 i32)
 (local $_M0L3valS1153 i32)
 (local $_M0L3valS1154 i32)
 (local $_M0L3valS1155 i32)
 (local $_M0L3ptrS1183 i32)
 (local $_M0L3ptrS1184 i32)
 (local $_M0L3ptrS1185 i32)
 (local $_M0L3ptrS1186 i32)
 (local $_M0L3ptrS1187 i32)
 (local $_M0L3ptrS1188 i32)
 (local $_M0L3ptrS1189 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 44 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 44 28 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1189
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1189)
  (i32.const 0))
 (local.get $_M0L3ptrS1189)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 44 38 ;)
 (local.set $_M0L7best__tS404)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 45 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 45 28 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1188
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1188)
  (local.get $_M0L1hS406))
 (local.get $_M0L3ptrS1188)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 45 38 ;)
 (local.set $_M0L7best__hS405)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 46 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 46 28 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1187
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1187)
  (local.get $_M0L1wS408))
 (local.get $_M0L3ptrS1187)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 46 38 ;)
 (local.set $_M0L7best__wS407)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 49 2 ;)
 (call $moonbit.incref
  (local.get $_M0L4gridS421))
 (call $moonbit.incref
  (local.get $_M0L8out__bufS420))
 (call $moonbit.incref
  (local.get $_M0L7best__wS407))
 (call $moonbit.incref
  (local.get $_M0L7best__hS405))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1186
   (call $moonbit.gc.malloc
    (i32.const 28)))
  (i32.const 1049856))
 (i32.store offset=24
  (local.get $_M0L3ptrS1186)
  (local.get $_M0L7best__tS404))
 (i32.store offset=20
  (local.get $_M0L3ptrS1186)
  (local.get $_M0L7best__hS405))
 (i32.store offset=4
  (local.get $_M0L3ptrS1186)
  (local.get $_M0L1hS406))
 (i32.store offset=16
  (local.get $_M0L3ptrS1186)
  (local.get $_M0L7best__wS407))
 (i32.store
  (local.get $_M0L3ptrS1186)
  (local.get $_M0L1wS408))
 (i32.store offset=12
  (local.get $_M0L3ptrS1186)
  (local.get $_M0L8out__bufS420))
 (i32.store offset=8
  (local.get $_M0L3ptrS1186)
  (local.get $_M0L4gridS421))
 (local.set $_M0L8write__tS409
  (local.get $_M0L3ptrS1186))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 69 2 ;)
 (call $moonbit.incref
  (local.get $_M0L4gridS421))
 (call $moonbit.incref
  (local.get $_M0L8out__bufS420))
 (call $moonbit.incref
  (local.get $_M0L7best__wS407))
 (call $moonbit.incref
  (local.get $_M0L7best__hS405))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1185
   (call $moonbit.gc.malloc
    (i32.const 24)))
  (i32.const 1049600))
 (i32.store offset=20
  (local.get $_M0L3ptrS1185)
  (local.get $_M0L7best__hS405))
 (i32.store offset=4
  (local.get $_M0L3ptrS1185)
  (local.get $_M0L1hS406))
 (i32.store offset=16
  (local.get $_M0L3ptrS1185)
  (local.get $_M0L7best__wS407))
 (i32.store
  (local.get $_M0L3ptrS1185)
  (local.get $_M0L1wS408))
 (i32.store offset=12
  (local.get $_M0L3ptrS1185)
  (local.get $_M0L8out__bufS420))
 (i32.store offset=8
  (local.get $_M0L3ptrS1185)
  (local.get $_M0L4gridS421))
 (local.set $_M0L10is__betterS430
  (local.get $_M0L3ptrS1185))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 90 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN8write__tS409
  (local.get $_M0L8write__tS409)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 90 12 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 91 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1184
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1184)
  (i32.const 1))
 (local.set $_M0L1tS451
  (local.get $_M0L3ptrS1184))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 92 2 ;)
 (loop $loop:452
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 92 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS1149
    (i32.load
     (local.get $_M0L1tS451)))
   (i32.const 8))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 92 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 4 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 7 ;)
    (local.set $_M0L3valS1150
     (i32.load
      (local.get $_M0L1tS451)))
    (call $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN10is__betterS430
     (local.get $_M0L10is__betterS430)
     (local.get $_M0L3valS1150))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 19 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 22 ;)
      (local.set $_M0L3valS1151
       (i32.load
        (local.get $_M0L1tS451)))
      (call $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN8write__tS409
       (local.get $_M0L8write__tS409)
       (local.get $_M0L3valS1151))
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 32 ;)
      (drop))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 34 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 94 4 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 94 8 ;)
    (i32.add
     (local.tee $_M0L3valS1153
      (i32.load
       (local.get $_M0L1tS451)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 94 13 ;)
    (local.set $_M0L6_2atmpS1152)
    (i32.store
     (local.get $_M0L1tS451)
     (local.get $_M0L6_2atmpS1152))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 94 13 ;)
    (drop)
    (br $loop:452))
   (else
    (call $moonbit.decref
     (local.get $_M0L1tS451))
    (call $moonbit.decref
     (local.get $_M0L10is__betterS430))
    (call $moonbit.decref
     (local.get $_M0L8write__tS409)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 95 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 3 ;)
 (i32.load
  (local.get $_M0L7best__hS405))
 (call $moonbit.decref
  (local.get $_M0L7best__hS405))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 13 ;)
 (local.set $_M0L3valS1154)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 15 ;)
 (i32.load
  (local.get $_M0L7best__wS407))
 (call $moonbit.decref
  (local.get $_M0L7best__wS407))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 25 ;)
 (local.set $_M0L3valS1155)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1183
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1183)
  (local.get $_M0L3valS1155))
 (i32.store
  (local.get $_M0L3ptrS1183)
  (local.get $_M0L3valS1154))
 (local.get $_M0L3ptrS1183)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;))
(func $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN10is__betterS430 (param $_M0L6_2aenvS1133 i32) (param $_M0L1tS431 i32) (result i32)
 (local $_M0L7best__hS405 i32)
 (local $_M0L1hS406 i32)
 (local $_M0L7best__wS407 i32)
 (local $_M0L1wS408 i32)
 (local $_M0L8out__bufS420 i32)
 (local $_M0L4gridS421 i32)
 (local $_M0L2ohS433 i32)
 (local $_M0L2owS434 i32)
 (local $_M0L1iS435 i32)
 (local $_M0L1rS436 i32)
 (local $_M0L1cS437 i32)
 (local $_M0L2srS439 i32)
 (local $_M0L2scS440 i32)
 (local $_M0L1vS441 i32)
 (local $_M0L3curS442 i32)
 (local $_M0L7_2abindS443 i32)
 (local $_M0L5_2asrS444 i32)
 (local $_M0L5_2ascS445 i32)
 (local $_M0L7_2abindS448 i32)
 (local $_M0L5_2aohS449 i32)
 (local $_M0L5_2aowS450 i32)
 (local $_M0L3valS1134 i32)
 (local $_M0L3valS1135 i32)
 (local $_M0L3valS1136 i32)
 (local $_M0L3valS1137 i32)
 (local $_M0L6_2atmpS1138 i32)
 (local $_M0L3valS1139 i32)
 (local $_M0L6_2atmpS1140 i32)
 (local $_M0L3valS1141 i32)
 (local $_M0L3valS1142 i32)
 (local $_M0L6_2atmpS1143 i32)
 (local $_M0L6_2atmpS1144 i32)
 (local $_M0L3valS1145 i32)
 (local $_M0L3valS1146 i32)
 (local $_M0L6_2atmpS1147 i32)
 (local $_M0L3valS1148 i32)
 (local $_M0L3ptrS1191 i32)
 (local $_M0L3ptrS1192 i32)
 (local $_M0L3ptrS1193 i32)
 (; prologue_end ;)
 (local.set $_M0L7best__hS405
  (i32.load offset=20
   (local.get $_M0L6_2aenvS1133)))
 (local.set $_M0L1hS406
  (i32.load offset=4
   (local.get $_M0L6_2aenvS1133)))
 (local.set $_M0L7best__wS407
  (i32.load offset=16
   (local.get $_M0L6_2aenvS1133)))
 (local.set $_M0L1wS408
  (i32.load
   (local.get $_M0L6_2aenvS1133)))
 (local.set $_M0L8out__bufS420
  (i32.load offset=12
   (local.get $_M0L6_2aenvS1133)))
 (local.set $_M0L4gridS421
  (i32.load offset=8
   (local.get $_M0L6_2aenvS1133)))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 70 4 ;)
 (block $join:432
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 70 4 ;)
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 70 19 ;)
  (call $_M0FP48moonarc34rhae3src4rhae13d4__out__dims
   (local.get $_M0L1hS406)
   (local.get $_M0L1wS408)
   (local.get $_M0L1tS431))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 70 39 ;)
  (local.tee $_M0L7_2abindS448)
  (i32.load)
  (local.set $_M0L5_2aohS449)
  (i32.load offset=4
   (local.get $_M0L7_2abindS448))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS448))
  (local.set $_M0L5_2aowS450)
  (local.get $_M0L5_2aohS449)
  (local.set $_M0L2owS434
   (local.get $_M0L5_2aowS450))
  (local.set $_M0L2ohS433)
  (br $join:432))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 4 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 7 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 7 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 13 ;)
 (i32.load
  (local.get $_M0L7best__hS405))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 23 ;)
 (local.set $_M0L3valS1135)
 (local.get $_M0L2ohS433)
 (i32.ne
  (local.get $_M0L3valS1135))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 23 ;)
 (if (result i32)
  (then
   (i32.const 1))
  (else
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 27 ;)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 33 ;)
   (i32.load
    (local.get $_M0L7best__wS407))
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 43 ;)
   (local.set $_M0L3valS1134)
   (local.get $_M0L2owS434)
   (i32.ne
    (local.get $_M0L3valS1134))
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 43 ;)))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 43 ;)
 (if
  (then
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 46 ;)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 53 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 58 ;)
   (return))
  (else))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 60 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 72 4 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1193
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1193)
  (i32.const 0))
 (local.set $_M0L1iS435
  (local.get $_M0L3ptrS1193))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 73 4 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1192
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1192)
  (i32.const 0))
 (local.set $_M0L1rS436
  (local.get $_M0L3ptrS1192))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 74 4 ;)
 (loop $loop:447
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 74 10 ;)
  (i32.lt_s
   (local.tee $_M0L3valS1136
    (i32.load
     (local.get $_M0L1rS436)))
   (local.get $_M0L2ohS433))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 74 16 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 75 6 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1191
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1191)
     (i32.const 0))
    (local.set $_M0L1cS437
     (local.get $_M0L3ptrS1191))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 76 6 ;)
    (loop $loop:446
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 76 12 ;)
     (i32.lt_s
      (local.tee $_M0L3valS1137
       (i32.load
        (local.get $_M0L1cS437)))
      (local.get $_M0L2owS434))
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 76 18 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 77 8 ;)
       (block $outer/1190 (result i32)
        (block $join:438
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 77 8 ;)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 77 23 ;)
         (local.set $_M0L3valS1145
          (i32.load
           (local.get $_M0L1rS436)))
         (local.set $_M0L3valS1146
          (i32.load
           (local.get $_M0L1cS437)))
         (call $_M0FP48moonarc34rhae3src4rhae7d4__src
          (local.get $_M0L3valS1145)
          (local.get $_M0L3valS1146)
          (local.get $_M0L1hS406)
          (local.get $_M0L1wS408)
          (local.get $_M0L1tS431))
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 77 44 ;)
         (local.tee $_M0L7_2abindS443)
         (i32.load)
         (local.set $_M0L5_2asrS444)
         (i32.load offset=4
          (local.get $_M0L7_2abindS443))
         (call $moonbit.decref
          (local.get $_M0L7_2abindS443))
         (local.set $_M0L5_2ascS445)
         (local.get $_M0L5_2asrS444)
         (local.set $_M0L2scS440
          (local.get $_M0L5_2ascS445))
         (local.set $_M0L2srS439)
         (br $join:438))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 16 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 21 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 21 ;)
        (i32.mul
         (local.get $_M0L2srS439)
         (local.get $_M0L1wS408))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 27 ;)
        (local.tee $_M0L6_2atmpS1144)
        (local.get $_M0L2scS440)
        (i32.add)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 32 ;)
        (local.set $_M0L6_2atmpS1143)
        (call $_M0MPC15array5Array2atGiE
         (local.get $_M0L4gridS421)
         (local.get $_M0L6_2atmpS1143))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 33 ;)
        (local.set $_M0L1vS441)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 79 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 79 18 ;)
        (local.set $_M0L3valS1142
         (i32.load
          (local.get $_M0L1iS435)))
        (call $_M0MPC15array5Array2atGiE
         (local.get $_M0L8out__bufS420)
         (local.get $_M0L3valS1142))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 79 28 ;)
        (local.set $_M0L3curS442)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 80 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 80 11 ;)
        (i32.lt_s
         (local.get $_M0L1vS441)
         (local.get $_M0L3curS442))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 80 18 ;)
        (if
         (then
          (call $moonbit.decref
           (local.get $_M0L1cS437))
          (call $moonbit.decref
           (local.get $_M0L1rS436))
          (call $moonbit.decref
           (local.get $_M0L1iS435))
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 80 21 ;)
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 80 28 ;)
          (i32.const 1)
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 80 32 ;)
          (return))
         (else))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 80 35 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 81 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 81 11 ;)
        (i32.gt_s
         (local.get $_M0L1vS441)
         (local.get $_M0L3curS442))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 81 18 ;)
        (if
         (then
          (call $moonbit.decref
           (local.get $_M0L1cS437))
          (call $moonbit.decref
           (local.get $_M0L1rS436))
          (call $moonbit.decref
           (local.get $_M0L1iS435))
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 81 21 ;)
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 81 28 ;)
          (i32.const 0)
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 81 33 ;)
          (return))
         (else))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 81 35 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 82 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 82 12 ;)
        (i32.add
         (local.tee $_M0L3valS1139
          (i32.load
           (local.get $_M0L1iS435)))
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 82 17 ;)
        (local.set $_M0L6_2atmpS1138)
        (i32.store
         (local.get $_M0L1iS435)
         (local.get $_M0L6_2atmpS1138))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 82 17 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 12 ;)
        (i32.add
         (local.tee $_M0L3valS1141
          (i32.load
           (local.get $_M0L1cS437)))
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 17 ;)
        (local.set $_M0L6_2atmpS1140)
        (i32.store
         (local.get $_M0L1cS437)
         (local.get $_M0L6_2atmpS1140))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 17 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 17 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 17 ;))
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 17 ;)
       (drop)
       (br $loop:446))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS437)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 84 7 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 85 6 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 85 10 ;)
    (i32.add
     (local.tee $_M0L3valS1148
      (i32.load
       (local.get $_M0L1rS436)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 85 15 ;)
    (local.set $_M0L6_2atmpS1147)
    (i32.store
     (local.get $_M0L1rS436)
     (local.get $_M0L6_2atmpS1147))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 85 15 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 85 15 ;)
    (drop)
    (br $loop:447))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS436))
    (call $moonbit.decref
     (local.get $_M0L1iS435)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 86 5 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 87 4 ;)
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 87 9 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 87 9 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 87 9 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 87 9 ;))
(func $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN8write__tS409 (param $_M0L6_2aenvS1118 i32) (param $_M0L1tS410 i32) (result i32)
 (local $_M0L7best__tS404 i32)
 (local $_M0L7best__hS405 i32)
 (local $_M0L1hS406 i32)
 (local $_M0L7best__wS407 i32)
 (local $_M0L1wS408 i32)
 (local $_M0L2ohS412 i32)
 (local $_M0L2owS413 i32)
 (local $_M0L1iS414 i32)
 (local $_M0L1rS415 i32)
 (local $_M0L1cS416 i32)
 (local $_M0L2srS418 i32)
 (local $_M0L2scS419 i32)
 (local $_M0L8out__bufS420 i32)
 (local $_M0L4gridS421 i32)
 (local $_M0L7_2abindS422 i32)
 (local $_M0L5_2asrS423 i32)
 (local $_M0L5_2ascS424 i32)
 (local $_M0L7_2abindS427 i32)
 (local $_M0L5_2aohS428 i32)
 (local $_M0L5_2aowS429 i32)
 (local $_M0L3valS1119 i32)
 (local $_M0L3valS1120 i32)
 (local $_M0L3valS1121 i32)
 (local $_M0L6_2atmpS1122 i32)
 (local $_M0L6_2atmpS1123 i32)
 (local $_M0L6_2atmpS1124 i32)
 (local $_M0L6_2atmpS1125 i32)
 (local $_M0L3valS1126 i32)
 (local $_M0L6_2atmpS1127 i32)
 (local $_M0L3valS1128 i32)
 (local $_M0L3valS1129 i32)
 (local $_M0L3valS1130 i32)
 (local $_M0L6_2atmpS1131 i32)
 (local $_M0L3valS1132 i32)
 (local $_M0L3ptrS1195 i32)
 (local $_M0L3ptrS1196 i32)
 (local $_M0L3ptrS1197 i32)
 (; prologue_end ;)
 (local.set $_M0L7best__tS404
  (i32.load offset=24
   (local.get $_M0L6_2aenvS1118)))
 (local.set $_M0L7best__hS405
  (i32.load offset=20
   (local.get $_M0L6_2aenvS1118)))
 (local.set $_M0L1hS406
  (i32.load offset=4
   (local.get $_M0L6_2aenvS1118)))
 (local.set $_M0L7best__wS407
  (i32.load offset=16
   (local.get $_M0L6_2aenvS1118)))
 (local.set $_M0L1wS408
  (i32.load
   (local.get $_M0L6_2aenvS1118)))
 (local.set $_M0L8out__bufS420
  (i32.load offset=12
   (local.get $_M0L6_2aenvS1118)))
 (local.set $_M0L4gridS421
  (i32.load offset=8
   (local.get $_M0L6_2aenvS1118)))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 50 4 ;)
 (block $join:411
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 50 4 ;)
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 50 19 ;)
  (call $_M0FP48moonarc34rhae3src4rhae13d4__out__dims
   (local.get $_M0L1hS406)
   (local.get $_M0L1wS408)
   (local.get $_M0L1tS410))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 50 39 ;)
  (local.tee $_M0L7_2abindS427)
  (i32.load)
  (local.set $_M0L5_2aohS428)
  (i32.load offset=4
   (local.get $_M0L7_2abindS427))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS427))
  (local.set $_M0L5_2aowS429)
  (local.get $_M0L5_2aohS428)
  (local.set $_M0L2owS413
   (local.get $_M0L5_2aowS429))
  (local.set $_M0L2ohS412)
  (br $join:411))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 51 4 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1197
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1197)
  (i32.const 0))
 (local.set $_M0L1iS414
  (local.get $_M0L3ptrS1197))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 52 4 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1196
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1196)
  (i32.const 0))
 (local.set $_M0L1rS415
  (local.get $_M0L3ptrS1196))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 53 4 ;)
 (loop $loop:426
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 53 10 ;)
  (i32.lt_s
   (local.tee $_M0L3valS1119
    (i32.load
     (local.get $_M0L1rS415)))
   (local.get $_M0L2ohS412))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 53 16 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 54 6 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1195
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1195)
     (i32.const 0))
    (local.set $_M0L1cS416
     (local.get $_M0L3ptrS1195))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 55 6 ;)
    (loop $loop:425
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 55 12 ;)
     (i32.lt_s
      (local.tee $_M0L3valS1120
       (i32.load
        (local.get $_M0L1cS416)))
      (local.get $_M0L2owS413))
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 55 18 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 56 8 ;)
       (block $outer/1194 (result i32)
        (block $join:417
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 56 8 ;)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 56 23 ;)
         (local.set $_M0L3valS1129
          (i32.load
           (local.get $_M0L1rS415)))
         (local.set $_M0L3valS1130
          (i32.load
           (local.get $_M0L1cS416)))
         (call $_M0FP48moonarc34rhae3src4rhae7d4__src
          (local.get $_M0L3valS1129)
          (local.get $_M0L3valS1130)
          (local.get $_M0L1hS406)
          (local.get $_M0L1wS408)
          (local.get $_M0L1tS410))
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 56 44 ;)
         (local.tee $_M0L7_2abindS422)
         (i32.load)
         (local.set $_M0L5_2asrS423)
         (i32.load offset=4
          (local.get $_M0L7_2abindS422))
         (call $moonbit.decref
          (local.get $_M0L7_2abindS422))
         (local.set $_M0L5_2ascS424)
         (local.get $_M0L5_2asrS423)
         (local.set $_M0L2scS419
          (local.get $_M0L5_2ascS424))
         (local.set $_M0L2srS418)
         (br $join:417))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 8 ;)
        (local.set $_M0L3valS1121
         (i32.load
          (local.get $_M0L1iS414)))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 21 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 26 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 26 ;)
        (i32.mul
         (local.get $_M0L2srS418)
         (local.get $_M0L1wS408))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 32 ;)
        (local.tee $_M0L6_2atmpS1124)
        (local.get $_M0L2scS419)
        (i32.add)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 37 ;)
        (local.set $_M0L6_2atmpS1123)
        (call $_M0MPC15array5Array2atGiE
         (local.get $_M0L4gridS421)
         (local.get $_M0L6_2atmpS1123))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 38 ;)
        (local.set $_M0L6_2atmpS1122)
        (call $_M0MPC15array5Array3setGiE
         (local.get $_M0L8out__bufS420)
         (local.get $_M0L3valS1121)
         (local.get $_M0L6_2atmpS1122))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 38 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 58 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 58 12 ;)
        (i32.add
         (local.tee $_M0L3valS1126
          (i32.load
           (local.get $_M0L1iS414)))
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 58 17 ;)
        (local.set $_M0L6_2atmpS1125)
        (i32.store
         (local.get $_M0L1iS414)
         (local.get $_M0L6_2atmpS1125))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 58 17 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 59 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 59 12 ;)
        (i32.add
         (local.tee $_M0L3valS1128
          (i32.load
           (local.get $_M0L1cS416)))
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 59 17 ;)
        (local.set $_M0L6_2atmpS1127)
        (i32.store
         (local.get $_M0L1cS416)
         (local.get $_M0L6_2atmpS1127))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 59 17 ;))
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 59 17 ;)
       (drop)
       (br $loop:425))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS416)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 60 7 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 61 6 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 61 10 ;)
    (i32.add
     (local.tee $_M0L3valS1132
      (i32.load
       (local.get $_M0L1rS415)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 61 15 ;)
    (local.set $_M0L6_2atmpS1131)
    (i32.store
     (local.get $_M0L1rS415)
     (local.get $_M0L6_2atmpS1131))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 61 15 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 61 15 ;)
    (drop)
    (br $loop:426))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS415))
    (call $moonbit.decref
     (local.get $_M0L1iS414)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 62 5 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 63 4 ;)
 (i32.store
  (local.get $_M0L7best__hS405)
  (local.get $_M0L2ohS412))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 63 19 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 64 4 ;)
 (i32.store
  (local.get $_M0L7best__wS407)
  (local.get $_M0L2owS413))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 64 19 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 65 4 ;)
 (i32.store
  (local.get $_M0L7best__tS404)
  (local.get $_M0L1tS410))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 65 18 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 65 18 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 65 18 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 65 18 ;))
(func $_M0FP48moonarc34rhae3src4rhae13d4__out__dims (param $_M0L1hS402 i32) (param $_M0L1wS401 i32) (param $_M0L1tS403 i32) (result i32)
 (local $_M0L3ptrS1198 i32)
 (local $_M0L3ptrS1199 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 30 2 ;)
 (block $join:400
  (if (result i32)
   (i32.eq
    (local.get $_M0L1tS403)
    (i32.const 1))
   (then
    (br $join:400))
   (else
    (if (result i32)
     (i32.eq
      (local.get $_M0L1tS403)
      (i32.const 3))
     (then
      (br $join:400))
     (else
      (if (result i32)
       (i32.eq
        (local.get $_M0L1tS403)
        (i32.const 6))
       (then
        (br $join:400))
       (else
        (if (result i32)
         (i32.eq
          (local.get $_M0L1tS403)
          (i32.const 7))
         (then
          (br $join:400))
         (else
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 32 9 ;)
          (call $moonbit.store_object_meta
           (local.tee $_M0L3ptrS1198
            (call $moonbit.gc.malloc
             (i32.const 8)))
           (i32.const 1048576))
          (i32.store offset=4
           (local.get $_M0L3ptrS1198)
           (local.get $_M0L1wS401))
          (i32.store
           (local.get $_M0L3ptrS1198)
           (local.get $_M0L1hS402))
          (local.get $_M0L3ptrS1198)
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 32 15 ;)))))))))
  (return))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 31 21 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1199
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1199)
  (local.get $_M0L1hS402))
 (i32.store
  (local.get $_M0L3ptrS1199)
  (local.get $_M0L1wS401))
 (local.get $_M0L3ptrS1199)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 31 27 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 33 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae7d4__src (param $_M0L6out__rS396 i32) (param $_M0L6out__cS397 i32) (param $_M0L1hS398 i32) (param $_M0L1wS399 i32) (param $_M0L1tS395 i32) (result i32)
 (local $_M0L6_2atmpS1102 i32)
 (local $_M0L6_2atmpS1103 i32)
 (local $_M0L6_2atmpS1104 i32)
 (local $_M0L6_2atmpS1105 i32)
 (local $_M0L6_2atmpS1106 i32)
 (local $_M0L6_2atmpS1107 i32)
 (local $_M0L6_2atmpS1108 i32)
 (local $_M0L6_2atmpS1109 i32)
 (local $_M0L6_2atmpS1110 i32)
 (local $_M0L6_2atmpS1111 i32)
 (local $_M0L6_2atmpS1112 i32)
 (local $_M0L6_2atmpS1113 i32)
 (local $_M0L6_2atmpS1114 i32)
 (local $_M0L6_2atmpS1115 i32)
 (local $_M0L6_2atmpS1116 i32)
 (local $_M0L6_2atmpS1117 i32)
 (local $_M0L3ptrS1200 i32)
 (local $_M0L3ptrS1201 i32)
 (local $_M0L3ptrS1202 i32)
 (local $_M0L3ptrS1203 i32)
 (local $_M0L3ptrS1204 i32)
 (local $_M0L3ptrS1205 i32)
 (local $_M0L3ptrS1206 i32)
 (local $_M0L3ptrS1207 i32)
 (local $_M0L3ptrS1208 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 16 2 ;)
 (block $switch_int/1209 (result i32)
  (block $switch_default/1210
   (block $switch_int_7/1218
    (block $switch_int_6/1217
     (block $switch_int_5/1216
      (block $switch_int_4/1215
       (block $switch_int_3/1214
        (block $switch_int_2/1213
         (block $switch_int_1/1212
          (block $switch_int_0/1211
           (local.get $_M0L1tS395)
           (br_table
            $switch_int_0/1211
            $switch_int_1/1212
            $switch_int_2/1213
            $switch_int_3/1214
            $switch_int_4/1215
            $switch_int_5/1216
            $switch_int_6/1217
            $switch_int_7/1218
            $switch_default/1210
            ))
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 17 9 ;)
          (call $moonbit.store_object_meta
           (local.tee $_M0L3ptrS1201
            (call $moonbit.gc.malloc
             (i32.const 8)))
           (i32.const 1048576))
          (i32.store offset=4
           (local.get $_M0L3ptrS1201)
           (local.get $_M0L6out__cS397))
          (i32.store
           (local.get $_M0L3ptrS1201)
           (local.get $_M0L6out__rS396))
          (local.get $_M0L3ptrS1201)
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 17 35 ;)
          (br $switch_int/1209))
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 9 ;)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 10 ;)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 10 ;)
         (i32.sub
          (local.get $_M0L1hS398)
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 13 ;)
         (local.tee $_M0L6_2atmpS1103)
         (local.get $_M0L6out__cS397)
         (i32.sub)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 19 ;)
         (local.set $_M0L6_2atmpS1102)
         (call $moonbit.store_object_meta
          (local.tee $_M0L3ptrS1202
           (call $moonbit.gc.malloc
            (i32.const 8)))
          (i32.const 1048576))
         (i32.store offset=4
          (local.get $_M0L3ptrS1202)
          (local.get $_M0L6out__rS396))
         (i32.store
          (local.get $_M0L3ptrS1202)
          (local.get $_M0L6_2atmpS1102))
         (local.get $_M0L3ptrS1202)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 35 ;)
         (br $switch_int/1209))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 9 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 10 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 10 ;)
        (i32.sub
         (local.get $_M0L1hS398)
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 13 ;)
        (local.tee $_M0L6_2atmpS1107)
        (local.get $_M0L6out__rS396)
        (i32.sub)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 19 ;)
        (local.set $_M0L6_2atmpS1104)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 23 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 23 ;)
        (i32.sub
         (local.get $_M0L1wS399)
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 26 ;)
        (local.tee $_M0L6_2atmpS1106)
        (local.get $_M0L6out__cS397)
        (i32.sub)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 32 ;)
        (local.set $_M0L6_2atmpS1105)
        (call $moonbit.store_object_meta
         (local.tee $_M0L3ptrS1203
          (call $moonbit.gc.malloc
           (i32.const 8)))
         (i32.const 1048576))
        (i32.store offset=4
         (local.get $_M0L3ptrS1203)
         (local.get $_M0L6_2atmpS1105))
        (i32.store
         (local.get $_M0L3ptrS1203)
         (local.get $_M0L6_2atmpS1104))
        (local.get $_M0L3ptrS1203)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 35 ;)
        (br $switch_int/1209))
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 9 ;)
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 23 ;)
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 23 ;)
       (i32.sub
        (local.get $_M0L1wS399)
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 26 ;)
       (local.tee $_M0L6_2atmpS1109)
       (local.get $_M0L6out__rS396)
       (i32.sub)
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 32 ;)
       (local.set $_M0L6_2atmpS1108)
       (call $moonbit.store_object_meta
        (local.tee $_M0L3ptrS1204
         (call $moonbit.gc.malloc
          (i32.const 8)))
        (i32.const 1048576))
       (i32.store offset=4
        (local.get $_M0L3ptrS1204)
        (local.get $_M0L6_2atmpS1108))
       (i32.store
        (local.get $_M0L3ptrS1204)
        (local.get $_M0L6out__cS397))
       (local.get $_M0L3ptrS1204)
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 35 ;)
       (br $switch_int/1209))
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 9 ;)
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 23 ;)
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 23 ;)
      (i32.sub
       (local.get $_M0L1wS399)
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 26 ;)
      (local.tee $_M0L6_2atmpS1111)
      (local.get $_M0L6out__cS397)
      (i32.sub)
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 32 ;)
      (local.set $_M0L6_2atmpS1110)
      (call $moonbit.store_object_meta
       (local.tee $_M0L3ptrS1205
        (call $moonbit.gc.malloc
         (i32.const 8)))
       (i32.const 1048576))
      (i32.store offset=4
       (local.get $_M0L3ptrS1205)
       (local.get $_M0L6_2atmpS1110))
      (i32.store
       (local.get $_M0L3ptrS1205)
       (local.get $_M0L6out__rS396))
      (local.get $_M0L3ptrS1205)
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 35 ;)
      (br $switch_int/1209))
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 9 ;)
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 10 ;)
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 10 ;)
     (i32.sub
      (local.get $_M0L1hS398)
      (i32.const 1))
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 13 ;)
     (local.tee $_M0L6_2atmpS1113)
     (local.get $_M0L6out__rS396)
     (i32.sub)
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 19 ;)
     (local.set $_M0L6_2atmpS1112)
     (call $moonbit.store_object_meta
      (local.tee $_M0L3ptrS1206
       (call $moonbit.gc.malloc
        (i32.const 8)))
      (i32.const 1048576))
     (i32.store offset=4
      (local.get $_M0L3ptrS1206)
      (local.get $_M0L6out__cS397))
     (i32.store
      (local.get $_M0L3ptrS1206)
      (local.get $_M0L6_2atmpS1112))
     (local.get $_M0L3ptrS1206)
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 35 ;)
     (br $switch_int/1209))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 23 9 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1207
      (call $moonbit.gc.malloc
       (i32.const 8)))
     (i32.const 1048576))
    (i32.store offset=4
     (local.get $_M0L3ptrS1207)
     (local.get $_M0L6out__rS396))
    (i32.store
     (local.get $_M0L3ptrS1207)
     (local.get $_M0L6out__cS397))
    (local.get $_M0L3ptrS1207)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 23 35 ;)
    (br $switch_int/1209))
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 9 ;)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 10 ;)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 10 ;)
   (i32.sub
    (local.get $_M0L1wS399)
    (i32.const 1))
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 13 ;)
   (local.tee $_M0L6_2atmpS1117)
   (local.get $_M0L6out__cS397)
   (i32.sub)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 19 ;)
   (local.set $_M0L6_2atmpS1114)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 23 ;)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 23 ;)
   (i32.sub
    (local.get $_M0L1hS398)
    (i32.const 1))
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 26 ;)
   (local.tee $_M0L6_2atmpS1116)
   (local.get $_M0L6out__rS396)
   (i32.sub)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 32 ;)
   (local.set $_M0L6_2atmpS1115)
   (call $moonbit.store_object_meta
    (local.tee $_M0L3ptrS1208
     (call $moonbit.gc.malloc
      (i32.const 8)))
    (i32.const 1048576))
   (i32.store offset=4
    (local.get $_M0L3ptrS1208)
    (local.get $_M0L6_2atmpS1115))
   (i32.store
    (local.get $_M0L3ptrS1208)
    (local.get $_M0L6_2atmpS1114))
   (local.get $_M0L3ptrS1208)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 35 ;)
   (br $switch_int/1209))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 25 9 ;)
  (call $moonbit.store_object_meta
   (local.tee $_M0L3ptrS1200
    (call $moonbit.gc.malloc
     (i32.const 8)))
   (i32.const 1048576))
  (i32.store offset=4
   (local.get $_M0L3ptrS1200)
   (local.get $_M0L6out__cS397))
  (i32.store
   (local.get $_M0L3ptrS1200)
   (local.get $_M0L6out__rS396))
  (local.get $_M0L3ptrS1200)
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 25 35 ;)
  (br $switch_int/1209))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 26 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae14decode__action (param $_M0L3rawS394 i32) (result i32)
 (local $_M0L1rS393 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 8 2 ;)
 (block $join:392
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 9 ;)
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 9 ;)
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 9 ;)
  (i32.ge_s
   (local.get $_M0L3rawS394)
   (i32.const 1))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 15 ;)
  (if (result i32)
   (then
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 19 ;)
    (i32.le_s
     (local.get $_M0L3rawS394)
     (i32.const 7))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 25 ;))
   (else
    (i32.const 0)))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 25 ;)
  (if (result i32)
   (then
    (local.set $_M0L1rS393
     (local.get $_M0L3rawS394))
    (br $join:392))
   (else
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 10 9 ;)
    (i32.const 1)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 10 10 ;)))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 25 ;)
  (return))
 (local.get $_M0L1rS393)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 11 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae14encode__action (param $_M0L1aS391 i32) (result i32)
 (; prologue_end ;)
 (local.get $_M0L1aS391))
(func $_M0FP48moonarc34rhae3src4rhae22rhae__hash__and__check (param $_M0L1hS384 i32) (param $_M0L1wS385 i32) (result i32)
 (local $_M0L2loS383 i32)
 (local $_M0L2hiS386 i32)
 (local $_M0L3visS387 i32)
 (local $_M0L3tthS388 i32)
 (local $_M0L7_2abindS389 i32)
 (local $_M0L4_2axS390 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 68 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 68 11 ;)
 (call $_M0FP48moonarc34rhae3src4rhae21rhae__canonical__hash
  (local.get $_M0L1hS384)
  (local.get $_M0L1wS385))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 68 36 ;)
 (local.set $_M0L2loS383)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 69 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 69 11 ;)
 (i32.load
  (global.get $_M0FP48moonarc34rhae3src4rhae8hash__hi))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 69 22 ;)
 (local.set $_M0L2hiS386)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 12 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 15 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14visited__check
  (local.get $_M0L2loS383)
  (local.get $_M0L2hiS386))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 36 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 39 ;)
   (i32.const 2)
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 40 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 50 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 51 ;)))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 53 ;)
 (local.set $_M0L3visS387)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 12 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 18 ;)
 (call $_M0FP48moonarc34rhae3src4rhae10tt__lookup
  (local.get $_M0L2loS383)
  (local.get $_M0L2hiS386))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 35 ;)
 (local.tee $_M0L7_2abindS389)
 (i32.load)
 (call $moonbit.decref
  (local.get $_M0L7_2abindS389))
 (local.tee $_M0L4_2axS390)
 (i32.const 1)
 (i32.eq)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 54 ;)
   (i32.const 1)
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 55 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 62 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 63 ;)))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 65 ;)
 (local.set $_M0L3tthS388)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 2 ;)
 (i32.or
  (local.get $_M0L3visS387)
  (local.get $_M0L3tthS388))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 11 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 11 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 11 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 11 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 11 ;))
(func $_M0FP48moonarc34rhae3src4rhae15rhae__tt__store (param $_M0L2loS379 i32) (param $_M0L2hiS380 i32) (param $_M0L6actionS381 i32) (param $_M0L5scoreS382 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 64 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae9tt__store
  (local.get $_M0L2loS379)
  (local.get $_M0L2hiS380)
  (local.get $_M0L6actionS381)
  (local.get $_M0L5scoreS382))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 64 33 ;))
(func $_M0FP48moonarc34rhae3src4rhae16rhae__tt__lookup (param $_M0L2loS375 i32) (param $_M0L2hiS376 i32) (result i32)
 (local $_M0L6actionS372 i32)
 (local $_M0L5foundS373 i32)
 (local $_M0L7_2abindS374 i32)
 (local $_M0L8_2afoundS377 i32)
 (local $_M0L9_2aactionS378 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 59 2 ;)
 (block $join:371
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 59 2 ;)
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 59 27 ;)
  (call $_M0FP48moonarc34rhae3src4rhae10tt__lookup
   (local.get $_M0L2loS375)
   (local.get $_M0L2hiS376))
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 59 44 ;)
  (local.tee $_M0L7_2abindS374)
  (i32.load)
  (local.set $_M0L8_2afoundS377)
  (i32.load offset=4
   (local.get $_M0L7_2abindS374))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS374))
  (local.tee $_M0L9_2aactionS378)
  (local.set $_M0L5foundS373
   (local.get $_M0L8_2afoundS377))
  (local.set $_M0L6actionS372)
  (br $join:371))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 60 2 ;)
 (if (result i32)
  (local.get $_M0L5foundS373)
  (then
   (local.get $_M0L6actionS372))
  (else
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 60 29 ;)
   (i32.const -1)
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 60 31 ;)))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 60 33 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 60 33 ;))
(func $_M0FP48moonarc34rhae3src4rhae10rhae__topk (param $_M0L7n__candS367 i32) (param $_M0L1kS370 i32) (result i32)
 (local $_M0L5pairsS365 i32)
 (local $_M0L1iS366 i32)
 (local $_M0L1bS368 i32)
 (local $_M0L3valS1084 i32)
 (local $_M0L6_2atmpS1085 i32)
 (local $_M0L6_2atmpS1086 i32)
 (local $_M0L3valS1087 i32)
 (local $_M0L6_2atmpS1088 i32)
 (local $_M0L6_2atmpS1089 i32)
 (local $_M0L6_2atmpS1090 i32)
 (local $_M0L6_2atmpS1091 i32)
 (local $_M0L6_2atmpS1092 i32)
 (local $_M0L6_2atmpS1093 i32)
 (local $_M0L6_2atmpS1094 i32)
 (local $_M0L6_2atmpS1095 i32)
 (local $_M0L6_2atmpS1096 i32)
 (local $_M0L6_2atmpS1097 i32)
 (local $_M0L3valS1098 i32)
 (local $_M0L6_2atmpS1099 i32)
 (local $_M0L3valS1100 i32)
 (local $_M0L3valS1101 i32)
 (local $_M0L3ptrS1219 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 47 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 47 27 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 14)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 47 45 ;)
 (local.set $_M0L5pairsS365)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 48 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1219
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1219)
  (i32.const 0))
 (local.set $_M0L1iS366
  (local.get $_M0L3ptrS1219))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 49 2 ;)
 (loop $loop:369
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 49 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS1084
    (i32.load
     (local.get $_M0L1iS366)))
   (local.get $_M0L7n__candS367))
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 49 18 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 50 4 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 50 12 ;)
    (i32.mul
     (local.tee $_M0L3valS1101
      (i32.load
       (local.get $_M0L1iS366)))
     (i32.const 13))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 50 18 ;)
    (local.set $_M0L1bS368)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 4 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 10 ;)
    (i32.mul
     (local.tee $_M0L3valS1087
      (i32.load
       (local.get $_M0L1iS366)))
     (i32.const 2))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 13 ;)
    (local.set $_M0L6_2atmpS1085)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 19 ;)
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
     (local.get $_M0L1bS368))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 29 ;)
    (local.set $_M0L6_2atmpS1086)
    (call $_M0MPC15array5Array3setGiE
     (local.get $_M0L5pairsS365)
     (local.get $_M0L6_2atmpS1085)
     (local.get $_M0L6_2atmpS1086))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 29 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 4 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 10 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 10 ;)
    (i32.mul
     (local.tee $_M0L3valS1098
      (i32.load
       (local.get $_M0L1iS366)))
     (i32.const 2))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 13 ;)
    (local.tee $_M0L6_2atmpS1097)
    (i32.const 1)
    (i32.add)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 15 ;)
    (local.set $_M0L6_2atmpS1088)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 19 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 19 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 19 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 27 ;)
    (i32.add
     (local.get $_M0L1bS368)
     (i32.const 5))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 30 ;)
    (local.set $_M0L6_2atmpS1096)
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
     (local.get $_M0L6_2atmpS1096))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 31 ;)
    (local.set $_M0L6_2atmpS1093)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 34 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 42 ;)
    (i32.add
     (local.get $_M0L1bS368)
     (i32.const 6))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 45 ;)
    (local.set $_M0L6_2atmpS1095)
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
     (local.get $_M0L6_2atmpS1095))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 46 ;)
    (local.set $_M0L6_2atmpS1094)
    (i32.add
     (local.get $_M0L6_2atmpS1093)
     (local.get $_M0L6_2atmpS1094))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 46 ;)
    (local.set $_M0L6_2atmpS1090)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 49 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 57 ;)
    (i32.add
     (local.get $_M0L1bS368)
     (i32.const 4))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 60 ;)
    (local.set $_M0L6_2atmpS1092)
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
     (local.get $_M0L6_2atmpS1092))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 61 ;)
    (local.set $_M0L6_2atmpS1091)
    (i32.sub
     (local.get $_M0L6_2atmpS1090)
     (local.get $_M0L6_2atmpS1091))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 61 ;)
    (local.set $_M0L6_2atmpS1089)
    (call $_M0MPC15array5Array3setGiE
     (local.get $_M0L5pairsS365)
     (local.get $_M0L6_2atmpS1088)
     (local.get $_M0L6_2atmpS1089))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 61 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 53 4 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 53 8 ;)
    (i32.add
     (local.tee $_M0L3valS1100
      (i32.load
       (local.get $_M0L1iS366)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 53 13 ;)
    (local.set $_M0L6_2atmpS1099)
    (i32.store
     (local.get $_M0L1iS366)
     (local.get $_M0L6_2atmpS1099))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 53 13 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 53 13 ;)
    (drop)
    (br $loop:369))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS366)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 54 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 55 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae16topk__candidates
  (local.get $_M0L5pairsS365)
  (local.get $_M0L7n__candS367)
  (local.get $_M0L1kS370)
  (global.get $_M0FP48moonarc34rhae3src4rhae9topk__buf))
 (call $moonbit.decref
  (local.get $_M0L5pairsS365))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 55 45 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 55 45 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 55 45 ;))
(func $_M0FP48moonarc34rhae3src4rhae23rhae__build__candidates (param $_M0L5legalS360 i32) (param $_M0L10path__costS361 i32) (param $_M0L8hash__loS362 i32) (param $_M0L10hash__hi__S363 i32) (param $_M0L6max__cS364 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 43 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae22build__candidate__rows
  (local.get $_M0L5legalS360)
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (global.get $_M0FP48moonarc34rhae3src4rhae8vis__buf)
  (local.get $_M0L10path__costS361)
  (local.get $_M0L8hash__loS362)
  (local.get $_M0L10hash__hi__S363)
  (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
  (local.get $_M0L6max__cS364))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 43 93 ;))
(func $_M0FP48moonarc34rhae3src4rhae18rhae__policy__gate (param $_M0L5legalS356 i32) (param $_M0L1hS357 i32) (param $_M0L1wS358 i32) (param $_M0L10n__actionsS359 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 36 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae12policy__gate
  (local.get $_M0L5legalS356)
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
  (local.get $_M0L1hS357)
  (local.get $_M0L1wS358)
  (global.get $_M0FP48moonarc34rhae3src4rhae9risk__buf)
  (local.get $_M0L10n__actionsS359))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 36 66 ;))
(func $_M0FP48moonarc34rhae3src4rhae20rhae__visited__reset (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 33 38 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14visited__reset)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 33 53 ;))
(func $_M0FP48moonarc34rhae3src4rhae19rhae__visited__mark (param $_M0L2loS354 i32) (param $_M0L2hiS355 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 32 55 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13visited__mark
  (local.get $_M0L2loS354)
  (local.get $_M0L2hiS355))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 32 75 ;))
(func $_M0FP48moonarc34rhae3src4rhae20rhae__visited__check (param $_M0L2loS352 i32) (param $_M0L2hiS353 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 29 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 29 5 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14visited__check
  (local.get $_M0L2loS352)
  (local.get $_M0L2hiS353))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 29 26 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 29 29 ;)
   (i32.const 1)
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 29 30 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 29 40 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 29 41 ;)))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 29 43 ;))
(func $_M0FP48moonarc34rhae3src4rhae19rhae__get__hash__hi (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 26 35 ;)
 (i32.load
  (global.get $_M0FP48moonarc34rhae3src4rhae8hash__hi))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 26 46 ;))
(func $_M0FP48moonarc34rhae3src4rhae21rhae__canonical__hash (param $_M0L1hS348 i32) (param $_M0L1wS349 i32) (result i32)
 (local $_M0L2loS345 i32)
 (local $_M0L2hiS346 i32)
 (local $_M0L7_2abindS347 i32)
 (local $_M0L5_2aloS350 i32)
 (local $_M0L5_2ahiS351 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 20 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 20 16 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 21 2 ;)
 (block $join:344
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 21 2 ;)
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 21 17 ;)
  (call $_M0FP48moonarc34rhae3src4rhae15canonical__hash
   (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
   (local.get $_M0L1hS348)
   (local.get $_M0L1wS349))
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 21 47 ;)
  (local.tee $_M0L7_2abindS347)
  (i32.load)
  (local.set $_M0L5_2aloS350)
  (i32.load offset=4
   (local.get $_M0L7_2abindS347))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS347))
  (local.set $_M0L5_2ahiS351)
  (local.get $_M0L5_2aloS350)
  (local.set $_M0L2hiS346
   (local.get $_M0L5_2ahiS351))
  (local.set $_M0L2loS345)
  (br $join:344))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 22 2 ;)
 (i32.store
  (global.get $_M0FP48moonarc34rhae3src4rhae8hash__hi)
  (local.get $_M0L2hiS346))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 22 18 ;)
 (drop)
 (local.get $_M0L2loS345)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 23 4 ;))
(func $_M0FP48moonarc34rhae3src4rhae16rhae__invariants (param $_M0L1hS342 i32) (param $_M0L1wS343 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 15 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae19compute__invariants
  (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
  (global.get $_M0FP48moonarc34rhae3src4rhae9prev__buf)
  (local.get $_M0L1hS342)
  (local.get $_M0L1wS343)
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 15 55 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 16 2 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 16 12 ;))
(func $_M0FP48moonarc34rhae3src4rhae9get__topk (param $_M0L1iS341 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 12 34 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae9topk__buf)
  (local.get $_M0L1iS341))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 12 45 ;))
(func $_M0FP48moonarc34rhae3src4rhae8get__mat (param $_M0L1iS340 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 11 34 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
  (local.get $_M0L1iS340))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 11 44 ;))
(func $_M0FP48moonarc34rhae3src4rhae8get__inv (param $_M0L1iS339 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 10 34 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (local.get $_M0L1iS339))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 10 44 ;))
(func $_M0FP48moonarc34rhae3src4rhae9set__risk (param $_M0L2aiS337 i32) (param $_M0L3valS338 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 9 47 ;)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae9risk__buf)
  (local.get $_M0L2aiS337)
  (local.get $_M0L3valS338))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 9 65 ;))
(func $_M0FP48moonarc34rhae3src4rhae12set__visited (param $_M0L2aiS335 i32) (param $_M0L3valS336 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 8 50 ;)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8vis__buf)
  (local.get $_M0L2aiS335)
  (local.get $_M0L3valS336))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 8 67 ;))
(func $_M0FP48moonarc34rhae3src4rhae15set__prev__cell (param $_M0L3idxS333 i32) (param $_M0L3valS334 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 7 53 ;)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae9prev__buf)
  (local.get $_M0L3idxS333)
  (local.get $_M0L3valS334))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 7 72 ;))
(func $_M0FP48moonarc34rhae3src4rhae15set__grid__cell (param $_M0L3idxS331 i32) (param $_M0L3valS332 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 6 53 ;)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
  (local.get $_M0L3idxS331)
  (local.get $_M0L3valS332))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 6 72 ;))
(func $_M0FP48moonarc34rhae3src4rhae19compute__invariants (param $_M0L4gridS301 i32) (param $_M0L4prevS316 i32) (param $_M0L1hS297 i32) (param $_M0L1wS298 i32) (param $_M0L3outS322 i32) (result i32)
 (local $_M0L1nS296 i32)
 (local $_M0L3visS299 i32)
 (local $_M0L7n__compS300 i32)
 (local $_M0L5eulerS303 i32)
 (local $_M0L8n__holesS304 i32)
 (local $_M0L9n__colorsS305 i32)
 (local $_M0L2c0S307 i32)
 (local $_M0L2r0S308 i32)
 (local $_M0L2r1S309 i32)
 (local $_M0L2c1S310 i32)
 (local $_M0L2bhS311 i32)
 (local $_M0L2bwS312 i32)
 (local $_M0L3symS313 i32)
 (local $_M0L5deltaS314 i32)
 (local $_M0L1jS315 i32)
 (local $_M0L2nzS318 i32)
 (local $_M0L1kS319 i32)
 (local $_M0L4goalS321 i32)
 (local $_M0L7_2abindS323 i32)
 (local $_M0L5_2ar0S324 i32)
 (local $_M0L5_2ar1S325 i32)
 (local $_M0L5_2ac0S326 i32)
 (local $_M0L5_2ac1S327 i32)
 (local $_M0L7_2abindS328 i32)
 (local $_M0L8_2aeulerS329 i32)
 (local $_M0L11_2an__holesS330 i32)
 (local $_M0L3valS1063 i32)
 (local $_M0L6_2atmpS1064 i32)
 (local $_M0L6_2atmpS1065 i32)
 (local $_M0L3valS1066 i32)
 (local $_M0L3valS1067 i32)
 (local $_M0L6_2atmpS1068 i32)
 (local $_M0L3valS1069 i32)
 (local $_M0L6_2atmpS1070 i32)
 (local $_M0L3valS1071 i32)
 (local $_M0L3valS1072 i32)
 (local $_M0L6_2atmpS1073 i32)
 (local $_M0L3valS1074 i32)
 (local $_M0L6_2atmpS1075 i32)
 (local $_M0L3valS1076 i32)
 (local $_M0L6_2atmpS1077 i32)
 (local $_M0L3valS1078 i32)
 (local $_M0L3valS1079 i32)
 (local $_M0L6_2atmpS1080 i32)
 (local $_M0L3valS1081 i32)
 (local $_M0L6_2atmpS1082 i32)
 (local $_M0L6_2atmpS1083 i32)
 (local $_M0L3ptrS1220 i32)
 (local $_M0L3ptrS1221 i32)
 (local $_M0L3ptrS1222 i32)
 (local $_M0L3ptrS1223 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 106 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 106 10 ;)
 (i32.mul
  (local.get $_M0L1hS297)
  (local.get $_M0L1wS298))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 106 15 ;)
 (local.set $_M0L1nS296)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 107 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 107 25 ;)
 (call $_M0MPC15array5Array4makeGiE
  (local.get $_M0L1nS296)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 107 42 ;)
 (local.set $_M0L3visS299)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 108 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 108 17 ;)
 (call $_M0FP48moonarc34rhae3src4rhae17count__components
  (local.get $_M0L4gridS301)
  (local.get $_M0L1hS297)
  (local.get $_M0L1wS298)
  (local.get $_M0L3visS299))
 (call $moonbit.decref
  (local.get $_M0L3visS299))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 108 50 ;)
 (local.set $_M0L7n__compS300)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 109 2 ;)
 (block $join:302
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 109 2 ;)
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 109 25 ;)
  (call $_M0FP48moonarc34rhae3src4rhae12euler__proxy
   (local.get $_M0L4gridS301)
   (local.get $_M0L1hS297)
   (local.get $_M0L1wS298))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 109 48 ;)
  (local.tee $_M0L7_2abindS328)
  (i32.load)
  (local.set $_M0L8_2aeulerS329)
  (i32.load offset=4
   (local.get $_M0L7_2abindS328))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS328))
  (local.set $_M0L11_2an__holesS330)
  (local.get $_M0L8_2aeulerS329)
  (local.set $_M0L8n__holesS304
   (local.get $_M0L11_2an__holesS330))
  (local.set $_M0L5eulerS303)
  (br $join:302))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 110 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 110 17 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13count__colors
  (local.get $_M0L4gridS301)
  (local.get $_M0L1nS296))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 110 38 ;)
 (local.set $_M0L9n__colorsS305)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 111 2 ;)
 (block $join:306
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 111 2 ;)
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 111 25 ;)
  (call $_M0FP48moonarc34rhae3src4rhae4bbox
   (local.get $_M0L4gridS301)
   (local.get $_M0L1hS297)
   (local.get $_M0L1wS298))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 111 41 ;)
  (local.tee $_M0L7_2abindS323)
  (i32.load)
  (local.set $_M0L5_2ar0S324)
  (local.set $_M0L5_2ar1S325
   (i32.load offset=4
    (local.get $_M0L7_2abindS323)))
  (local.set $_M0L5_2ac0S326
   (i32.load offset=8
    (local.get $_M0L7_2abindS323)))
  (i32.load offset=12
   (local.get $_M0L7_2abindS323))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS323))
  (local.set $_M0L5_2ac1S327)
  (local.get $_M0L5_2ac0S326)
  (local.get $_M0L5_2ar0S324)
  (local.get $_M0L5_2ar1S325)
  (local.set $_M0L2c1S310
   (local.get $_M0L5_2ac1S327))
  (local.set $_M0L2r1S309)
  (local.set $_M0L2r0S308)
  (local.set $_M0L2c0S307)
  (br $join:306))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 11 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 14 ;)
 (i32.ge_s
  (local.get $_M0L2r1S309)
  (local.get $_M0L2r0S308))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 22 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 25 ;)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 25 ;)
   (i32.sub
    (local.get $_M0L2r1S309)
    (local.get $_M0L2r0S308))
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 30 ;)
   (local.tee $_M0L6_2atmpS1083)
   (i32.const 1)
   (i32.add)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 32 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 42 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 43 ;)))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 45 ;)
 (local.set $_M0L2bhS311)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 11 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 14 ;)
 (i32.ge_s
  (local.get $_M0L2c1S310)
  (local.get $_M0L2c0S307))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 22 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 25 ;)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 25 ;)
   (i32.sub
    (local.get $_M0L2c1S310)
    (local.get $_M0L2c0S307))
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 30 ;)
   (local.tee $_M0L6_2atmpS1082)
   (i32.const 1)
   (i32.add)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 32 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 42 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 43 ;)))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 45 ;)
 (local.set $_M0L2bwS312)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 14 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 17 ;)
 (call $_M0FP48moonarc34rhae3src4rhae10is__sym__h
  (local.get $_M0L4gridS301)
  (local.get $_M0L1hS297)
  (local.get $_M0L1wS298))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 37 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 40 ;)
   (i32.const 1)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 41 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 51 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 52 ;)))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 54 ;)
 (local.set $_M0L3symS313)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 115 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1223
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1223)
  (i32.const 0))
 (local.set $_M0L5deltaS314
  (local.get $_M0L3ptrS1223))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 115 21 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1222
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1222)
  (i32.const 0))
 (local.set $_M0L1jS315
  (local.get $_M0L3ptrS1222))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 2 ;)
 (loop $loop:317
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS1063
    (i32.load
     (local.get $_M0L1jS315)))
   (local.get $_M0L1nS296))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 16 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 19 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 19 ;)
    (local.set $_M0L3valS1067
     (i32.load
      (local.get $_M0L1jS315)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4gridS301)
     (local.get $_M0L3valS1067))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 26 ;)
    (local.set $_M0L6_2atmpS1064)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 30 ;)
    (local.set $_M0L3valS1066
     (i32.load
      (local.get $_M0L1jS315)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4prevS316)
     (local.get $_M0L3valS1066))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 37 ;)
    (local.set $_M0L6_2atmpS1065)
    (local.get $_M0L6_2atmpS1064)
    (i32.ne
     (local.get $_M0L6_2atmpS1065))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 37 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 40 ;)
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 48 ;)
      (i32.add
       (local.tee $_M0L3valS1069
        (i32.load
         (local.get $_M0L5deltaS314)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 55 ;)
      (local.set $_M0L6_2atmpS1068)
      (i32.store
       (local.get $_M0L5deltaS314)
       (local.get $_M0L6_2atmpS1068))
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 55 ;)
      (drop))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 57 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 59 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 63 ;)
    (i32.add
     (local.tee $_M0L3valS1071
      (i32.load
       (local.get $_M0L1jS315)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 66 ;)
    (local.set $_M0L6_2atmpS1070)
    (i32.store
     (local.get $_M0L1jS315)
     (local.get $_M0L6_2atmpS1070))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 66 ;)
    (drop)
    (br $loop:317))
   (else
    (call $moonbit.decref
     (local.get $_M0L1jS315)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 68 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 117 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1221
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1221)
  (i32.const 0))
 (local.set $_M0L2nzS318
  (local.get $_M0L3ptrS1221))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 117 18 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1220
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1220)
  (i32.const 0))
 (local.set $_M0L1kS319
  (local.get $_M0L3ptrS1220))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 2 ;)
 (loop $loop:320
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS1072
    (i32.load
     (local.get $_M0L1kS319)))
   (local.get $_M0L1nS296))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 16 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 19 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 19 ;)
    (local.set $_M0L3valS1074
     (i32.load
      (local.get $_M0L1kS319)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4gridS301)
     (local.get $_M0L3valS1074))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 26 ;)
    (local.tee $_M0L6_2atmpS1073)
    (i32.const 0)
    (i32.gt_s)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 30 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 33 ;)
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 38 ;)
      (i32.add
       (local.tee $_M0L3valS1076
        (i32.load
         (local.get $_M0L2nzS318)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 42 ;)
      (local.set $_M0L6_2atmpS1075)
      (i32.store
       (local.get $_M0L2nzS318)
       (local.get $_M0L6_2atmpS1075))
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 42 ;)
      (drop))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 44 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 46 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 50 ;)
    (i32.add
     (local.tee $_M0L3valS1078
      (i32.load
       (local.get $_M0L1kS319)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 53 ;)
    (local.set $_M0L6_2atmpS1077)
    (i32.store
     (local.get $_M0L1kS319)
     (local.get $_M0L6_2atmpS1077))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 53 ;)
    (drop)
    (br $loop:320))
   (else
    (call $moonbit.decref
     (local.get $_M0L1kS319)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 55 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 13 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 16 ;)
 (i32.gt_s
  (local.get $_M0L1nS296)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 21 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 24 ;)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 24 ;)
   (i32.load
    (local.get $_M0L2nzS318))
   (call $moonbit.decref
    (local.get $_M0L2nzS318))
   (local.tee $_M0L3valS1081)
   (i32.const 100)
   (i32.mul)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 30 ;)
   (local.tee $_M0L6_2atmpS1080)
   (local.get $_M0L1nS296)
   (i32.div_s)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 32 ;))
  (else
   (call $moonbit.decref
    (local.get $_M0L2nzS318))
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 42 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 43 ;)))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 45 ;)
 (local.set $_M0L4goalS321)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 2 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS322)
  (i32.const 0)
  (local.get $_M0L7n__compS300))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 15 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 17 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS322)
  (i32.const 1)
  (local.get $_M0L9n__colorsS305))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 32 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 34 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS322)
  (i32.const 2)
  (local.get $_M0L7n__compS300))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 47 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 2 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS322)
  (i32.const 3)
  (local.get $_M0L2bhS311))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 11 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 17 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS322)
  (i32.const 4)
  (local.get $_M0L2bwS312))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 26 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 34 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS322)
  (i32.const 5)
  (local.get $_M0L3symS313))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 44 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 2 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS322)
  (i32.const 6)
  (local.get $_M0L5eulerS303))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 14 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 17 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS322)
  (i32.const 7)
  (local.get $_M0L8n__holesS304))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 31 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 34 ;)
 (i32.load
  (local.get $_M0L5deltaS314))
 (call $moonbit.decref
  (local.get $_M0L5deltaS314))
 (local.set $_M0L3valS1079)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS322)
  (i32.const 8)
  (local.get $_M0L3valS1079))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 46 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 48 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS322)
  (i32.const 9)
  (local.get $_M0L4goalS321))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 59 ;))
(func $_M0FP48moonarc34rhae3src4rhae13count__colors (param $_M0L4gridS291 i32) (param $_M0L1nS289 i32) (result i32)
 (local $_M0L4seenS287 i32)
 (local $_M0L1iS288 i32)
 (local $_M0L1cS290 i32)
 (local $_M0L3cntS293 i32)
 (local $_M0L1kS294 i32)
 (local $_M0L3valS1052 i32)
 (local $_M0L6_2atmpS1053 i32)
 (local $_M0L3valS1054 i32)
 (local $_M0L3valS1055 i32)
 (local $_M0L3valS1056 i32)
 (local $_M0L6_2atmpS1057 i32)
 (local $_M0L3valS1058 i32)
 (local $_M0L6_2atmpS1059 i32)
 (local $_M0L3valS1060 i32)
 (local $_M0L6_2atmpS1061 i32)
 (local $_M0L3valS1062 i32)
 (local $_M0L3ptrS1224 i32)
 (local $_M0L3ptrS1225 i32)
 (local $_M0L3ptrS1226 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 94 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 94 26 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 16)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 94 44 ;)
 (local.set $_M0L4seenS287)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 95 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1226
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1226)
  (i32.const 0))
 (local.set $_M0L1iS288
  (local.get $_M0L3ptrS1226))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 2 ;)
 (loop $loop:292
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS1052
    (i32.load
     (local.get $_M0L1iS288)))
   (local.get $_M0L1nS289))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 16 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 24 ;)
    (local.set $_M0L3valS1055
     (i32.load
      (local.get $_M0L1iS288)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4gridS291)
     (local.get $_M0L3valS1055))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 31 ;)
    (local.set $_M0L1cS290)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 33 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 36 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 36 ;)
    (i32.gt_s
     (local.get $_M0L1cS290)
     (i32.const 0))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 41 ;)
    (if (result i32)
     (then
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 45 ;)
      (i32.lt_s
       (local.get $_M0L1cS290)
       (i32.const 16))
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 51 ;))
     (else
      (i32.const 0)))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 51 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 54 ;)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L4seenS287)
       (local.get $_M0L1cS290)
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 65 ;)
      (drop))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 67 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 69 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 73 ;)
    (i32.add
     (local.tee $_M0L3valS1054
      (i32.load
       (local.get $_M0L1iS288)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 76 ;)
    (local.set $_M0L6_2atmpS1053)
    (i32.store
     (local.get $_M0L1iS288)
     (local.get $_M0L6_2atmpS1053))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 76 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 76 ;)
    (drop)
    (br $loop:292))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS288)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 78 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 97 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1225
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1225)
  (i32.const 0))
 (local.set $_M0L3cntS293
  (local.get $_M0L3ptrS1225))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 97 19 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1224
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1224)
  (i32.const 0))
 (local.set $_M0L1kS294
  (local.get $_M0L3ptrS1224))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 2 ;)
 (loop $loop:295
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS1056
    (i32.load
     (local.get $_M0L1kS294)))
   (i32.const 16))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 14 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 17 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 23 ;)
    (local.set $_M0L3valS1058
     (i32.load
      (local.get $_M0L3cntS293)))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 29 ;)
    (local.set $_M0L3valS1060
     (i32.load
      (local.get $_M0L1kS294)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4seenS287)
     (local.get $_M0L3valS1060))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 36 ;)
    (local.set $_M0L6_2atmpS1059)
    (i32.add
     (local.get $_M0L3valS1058)
     (local.get $_M0L6_2atmpS1059))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 36 ;)
    (local.set $_M0L6_2atmpS1057)
    (i32.store
     (local.get $_M0L3cntS293)
     (local.get $_M0L6_2atmpS1057))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 36 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 38 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 42 ;)
    (i32.add
     (local.tee $_M0L3valS1062
      (i32.load
       (local.get $_M0L1kS294)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 45 ;)
    (local.set $_M0L6_2atmpS1061)
    (i32.store
     (local.get $_M0L1kS294)
     (local.get $_M0L6_2atmpS1061))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 45 ;)
    (drop)
    (br $loop:295))
   (else
    (call $moonbit.decref
     (local.get $_M0L1kS294))
    (call $moonbit.decref
     (local.get $_M0L4seenS287)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 47 ;)
 (drop)
 (i32.load
  (local.get $_M0L3cntS293))
 (call $moonbit.decref
  (local.get $_M0L3cntS293))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 99 5 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 99 5 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 99 5 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 99 5 ;))
(func $_M0FP48moonarc34rhae3src4rhae10is__sym__h (param $_M0L4gridS284 i32) (param $_M0L1hS281 i32) (param $_M0L1wS283 i32) (result i32)
 (local $_M0L1rS280 i32)
 (local $_M0L1cS282 i32)
 (local $_M0L3valS1033 i32)
 (local $_M0L6_2atmpS1034 i32)
 (local $_M0L3valS1035 i32)
 (local $_M0L6_2atmpS1036 i32)
 (local $_M0L6_2atmpS1037 i32)
 (local $_M0L6_2atmpS1038 i32)
 (local $_M0L6_2atmpS1039 i32)
 (local $_M0L3valS1040 i32)
 (local $_M0L6_2atmpS1041 i32)
 (local $_M0L6_2atmpS1042 i32)
 (local $_M0L3valS1043 i32)
 (local $_M0L6_2atmpS1044 i32)
 (local $_M0L6_2atmpS1045 i32)
 (local $_M0L3valS1046 i32)
 (local $_M0L3valS1047 i32)
 (local $_M0L6_2atmpS1048 i32)
 (local $_M0L3valS1049 i32)
 (local $_M0L6_2atmpS1050 i32)
 (local $_M0L3valS1051 i32)
 (local $_M0L3ptrS1227 i32)
 (local $_M0L3ptrS1228 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 81 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1228
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1228)
  (i32.const 0))
 (local.set $_M0L1rS280
  (local.get $_M0L3ptrS1228))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 82 2 ;)
 (loop $loop:286
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 82 8 ;)
  (local.set $_M0L3valS1033
   (i32.load
    (local.get $_M0L1rS280)))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 82 12 ;)
  (i32.div_s
   (local.get $_M0L1hS281)
   (i32.const 2))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 82 17 ;)
  (local.set $_M0L6_2atmpS1034)
  (i32.lt_s
   (local.get $_M0L3valS1033)
   (local.get $_M0L6_2atmpS1034))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 82 17 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 83 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1227
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1227)
     (i32.const 0))
    (local.set $_M0L1cS282
     (local.get $_M0L3ptrS1227))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 84 4 ;)
    (loop $loop:285
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 84 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS1035
       (i32.load
        (local.get $_M0L1cS282)))
      (local.get $_M0L1wS283))
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 84 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 14 ;)
       (i32.mul
        (local.tee $_M0L3valS1047
         (i32.load
          (local.get $_M0L1rS280)))
        (local.get $_M0L1wS283))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 17 ;)
       (local.set $_M0L6_2atmpS1045)
       (local.set $_M0L3valS1046
        (i32.load
         (local.get $_M0L1cS282)))
       (i32.add
        (local.get $_M0L6_2atmpS1045)
        (local.get $_M0L3valS1046))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 19 ;)
       (local.set $_M0L6_2atmpS1044)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS284)
        (local.get $_M0L6_2atmpS1044))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 20 ;)
       (local.set $_M0L6_2atmpS1036)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 24 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 29 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 29 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 30 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 30 ;)
       (i32.sub
        (local.get $_M0L1hS281)
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 33 ;)
       (local.set $_M0L6_2atmpS1042)
       (local.set $_M0L3valS1043
        (i32.load
         (local.get $_M0L1rS280)))
       (i32.sub
        (local.get $_M0L6_2atmpS1042)
        (local.get $_M0L3valS1043))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 35 ;)
       (local.tee $_M0L6_2atmpS1041)
       (local.get $_M0L1wS283)
       (i32.mul)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 38 ;)
       (local.set $_M0L6_2atmpS1039)
       (local.set $_M0L3valS1040
        (i32.load
         (local.get $_M0L1cS282)))
       (i32.add
        (local.get $_M0L6_2atmpS1039)
        (local.get $_M0L3valS1040))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 40 ;)
       (local.set $_M0L6_2atmpS1038)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS284)
        (local.get $_M0L6_2atmpS1038))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 41 ;)
       (local.set $_M0L6_2atmpS1037)
       (local.get $_M0L6_2atmpS1036)
       (i32.ne
        (local.get $_M0L6_2atmpS1037))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 41 ;)
       (if
        (then
         (call $moonbit.decref
          (local.get $_M0L1cS282))
         (call $moonbit.decref
          (local.get $_M0L1rS280))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 44 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 51 ;)
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 56 ;)
         (return))
        (else))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 58 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 86 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 86 10 ;)
       (i32.add
        (local.tee $_M0L3valS1049
         (i32.load
          (local.get $_M0L1cS282)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 86 15 ;)
       (local.set $_M0L6_2atmpS1048)
       (i32.store
        (local.get $_M0L1cS282)
        (local.get $_M0L6_2atmpS1048))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 86 15 ;)
       (drop)
       (br $loop:285))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS282)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 87 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 88 4 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 88 8 ;)
    (i32.add
     (local.tee $_M0L3valS1051
      (i32.load
       (local.get $_M0L1rS280)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 88 13 ;)
    (local.set $_M0L6_2atmpS1050)
    (i32.store
     (local.get $_M0L1rS280)
     (local.get $_M0L6_2atmpS1050))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 88 13 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 88 13 ;)
    (drop)
    (br $loop:286))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS280)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 89 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 90 2 ;)
 (i32.const 1)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 90 6 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 90 6 ;))
(func $_M0FP48moonarc34rhae3src4rhae12euler__proxy (param $_M0L4gridS273 i32) (param $_M0L1hS269 i32) (param $_M0L1wS271 i32) (result i32)
 (local $_M0L2q1S266 i32)
 (local $_M0L2q3S267 i32)
 (local $_M0L1rS268 i32)
 (local $_M0L1cS270 i32)
 (local $_M0L1aS272 i32)
 (local $_M0L1bS274 i32)
 (local $_M0L1dS275 i32)
 (local $_M0L1eS276 i32)
 (local $_M0L1sS277 i32)
 (local $_M0L3valS985 i32)
 (local $_M0L6_2atmpS986 i32)
 (local $_M0L3valS987 i32)
 (local $_M0L6_2atmpS988 i32)
 (local $_M0L6_2atmpS989 i32)
 (local $_M0L3valS990 i32)
 (local $_M0L6_2atmpS991 i32)
 (local $_M0L3valS992 i32)
 (local $_M0L6_2atmpS993 i32)
 (local $_M0L3valS994 i32)
 (local $_M0L6_2atmpS995 i32)
 (local $_M0L6_2atmpS996 i32)
 (local $_M0L6_2atmpS997 i32)
 (local $_M0L6_2atmpS998 i32)
 (local $_M0L6_2atmpS999 i32)
 (local $_M0L6_2atmpS1000 i32)
 (local $_M0L3valS1001 i32)
 (local $_M0L6_2atmpS1002 i32)
 (local $_M0L3valS1003 i32)
 (local $_M0L6_2atmpS1004 i32)
 (local $_M0L6_2atmpS1005 i32)
 (local $_M0L6_2atmpS1006 i32)
 (local $_M0L3valS1007 i32)
 (local $_M0L6_2atmpS1008 i32)
 (local $_M0L3valS1009 i32)
 (local $_M0L6_2atmpS1010 i32)
 (local $_M0L6_2atmpS1011 i32)
 (local $_M0L6_2atmpS1012 i32)
 (local $_M0L6_2atmpS1013 i32)
 (local $_M0L3valS1014 i32)
 (local $_M0L3valS1015 i32)
 (local $_M0L6_2atmpS1016 i32)
 (local $_M0L6_2atmpS1017 i32)
 (local $_M0L6_2atmpS1018 i32)
 (local $_M0L3valS1019 i32)
 (local $_M0L3valS1020 i32)
 (local $_M0L6_2atmpS1021 i32)
 (local $_M0L3valS1022 i32)
 (local $_M0L6_2atmpS1023 i32)
 (local $_M0L6_2atmpS1024 i32)
 (local $_M0L3valS1025 i32)
 (local $_M0L3valS1026 i32)
 (local $_M0L6_2atmpS1027 i32)
 (local $_M0L3valS1028 i32)
 (local $_M0L3valS1029 i32)
 (local $_M0L6_2atmpS1030 i32)
 (local $_M0L3valS1031 i32)
 (local $_M0L3valS1032 i32)
 (local $_M0L3ptrS1229 i32)
 (local $_M0L3ptrS1230 i32)
 (local $_M0L3ptrS1231 i32)
 (local $_M0L3ptrS1232 i32)
 (local $_M0L3ptrS1233 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 62 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1233
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1233)
  (i32.const 0))
 (local.set $_M0L2q1S266
  (local.get $_M0L3ptrS1233))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 62 18 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1232
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1232)
  (i32.const 0))
 (local.set $_M0L2q3S267
  (local.get $_M0L3ptrS1232))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 63 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1231
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1231)
  (i32.const 0))
 (local.set $_M0L1rS268
  (local.get $_M0L3ptrS1231))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 64 2 ;)
 (loop $loop:279
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 64 8 ;)
  (local.set $_M0L3valS985
   (i32.load
    (local.get $_M0L1rS268)))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 64 12 ;)
  (i32.sub
   (local.get $_M0L1hS269)
   (i32.const 1))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 64 17 ;)
  (local.set $_M0L6_2atmpS986)
  (i32.lt_s
   (local.get $_M0L3valS985)
   (local.get $_M0L6_2atmpS986))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 64 17 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 65 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1230
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1230)
     (i32.const 0))
    (local.set $_M0L1cS270
     (local.get $_M0L3ptrS1230))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 66 4 ;)
    (loop $loop:278
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 66 10 ;)
     (local.set $_M0L3valS987
      (i32.load
       (local.get $_M0L1cS270)))
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 66 14 ;)
     (i32.sub
      (local.get $_M0L1wS271)
      (i32.const 1))
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 66 19 ;)
     (local.set $_M0L6_2atmpS988)
     (i32.lt_s
      (local.get $_M0L3valS987)
      (local.get $_M0L6_2atmpS988))
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 66 19 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 22 ;)
       (i32.mul
        (local.tee $_M0L3valS1020
         (i32.load
          (local.get $_M0L1rS268)))
        (local.get $_M0L1wS271))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 25 ;)
       (local.set $_M0L6_2atmpS1018)
       (local.set $_M0L3valS1019
        (i32.load
         (local.get $_M0L1cS270)))
       (i32.add
        (local.get $_M0L6_2atmpS1018)
        (local.get $_M0L3valS1019))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 27 ;)
       (local.set $_M0L6_2atmpS1017)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS273)
        (local.get $_M0L6_2atmpS1017))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 28 ;)
       (local.tee $_M0L6_2atmpS1016)
       (i32.const 0)
       (i32.gt_s)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 38 ;)
       (if (result i32)
        (then
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 41 ;)
         (i32.const 1)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 42 ;))
        (else
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 52 ;)
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 53 ;)))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 55 ;)
       (local.set $_M0L1aS272)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 22 ;)
       (i32.mul
        (local.tee $_M0L3valS1015
         (i32.load
          (local.get $_M0L1rS268)))
        (local.get $_M0L1wS271))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 25 ;)
       (local.set $_M0L6_2atmpS1013)
       (local.set $_M0L3valS1014
        (i32.load
         (local.get $_M0L1cS270)))
       (i32.add
        (local.get $_M0L6_2atmpS1013)
        (local.get $_M0L3valS1014))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 27 ;)
       (local.tee $_M0L6_2atmpS1012)
       (i32.const 1)
       (i32.add)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 29 ;)
       (local.set $_M0L6_2atmpS1011)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS273)
        (local.get $_M0L6_2atmpS1011))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 30 ;)
       (local.tee $_M0L6_2atmpS1010)
       (i32.const 0)
       (i32.gt_s)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 38 ;)
       (if (result i32)
        (then
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 41 ;)
         (i32.const 1)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 42 ;))
        (else
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 52 ;)
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 53 ;)))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 55 ;)
       (local.set $_M0L1bS274)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 23 ;)
       (i32.add
        (local.tee $_M0L3valS1009
         (i32.load
          (local.get $_M0L1rS268)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 26 ;)
       (local.tee $_M0L6_2atmpS1008)
       (local.get $_M0L1wS271)
       (i32.mul)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 29 ;)
       (local.set $_M0L6_2atmpS1006)
       (local.set $_M0L3valS1007
        (i32.load
         (local.get $_M0L1cS270)))
       (i32.add
        (local.get $_M0L6_2atmpS1006)
        (local.get $_M0L3valS1007))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 31 ;)
       (local.set $_M0L6_2atmpS1005)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS273)
        (local.get $_M0L6_2atmpS1005))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 32 ;)
       (local.tee $_M0L6_2atmpS1004)
       (i32.const 0)
       (i32.gt_s)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 38 ;)
       (if (result i32)
        (then
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 41 ;)
         (i32.const 1)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 42 ;))
        (else
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 52 ;)
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 53 ;)))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 55 ;)
       (local.set $_M0L1dS275)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 23 ;)
       (i32.add
        (local.tee $_M0L3valS1003
         (i32.load
          (local.get $_M0L1rS268)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 26 ;)
       (local.tee $_M0L6_2atmpS1002)
       (local.get $_M0L1wS271)
       (i32.mul)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 29 ;)
       (local.set $_M0L6_2atmpS1000)
       (local.set $_M0L3valS1001
        (i32.load
         (local.get $_M0L1cS270)))
       (i32.add
        (local.get $_M0L6_2atmpS1000)
        (local.get $_M0L3valS1001))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 31 ;)
       (local.tee $_M0L6_2atmpS999)
       (i32.const 1)
       (i32.add)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 33 ;)
       (local.set $_M0L6_2atmpS998)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS273)
        (local.get $_M0L6_2atmpS998))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 34 ;)
       (local.tee $_M0L6_2atmpS997)
       (i32.const 0)
       (i32.gt_s)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 38 ;)
       (if (result i32)
        (then
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 41 ;)
         (i32.const 1)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 42 ;))
        (else
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 52 ;)
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 53 ;)))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 55 ;)
       (local.set $_M0L1eS276)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 14 ;)
       (i32.add
        (local.get $_M0L1aS272)
        (local.get $_M0L1bS274))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 19 ;)
       (local.tee $_M0L6_2atmpS996)
       (local.get $_M0L1dS275)
       (i32.add)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 23 ;)
       (local.tee $_M0L6_2atmpS995)
       (local.get $_M0L1eS276)
       (i32.add)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 27 ;)
       (local.set $_M0L1sS277)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 6 ;)
       (if
        (i32.eq
         (local.get $_M0L1sS277)
         (i32.const 1))
        (then
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 21 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 26 ;)
         (i32.add
          (local.tee $_M0L3valS990
           (i32.load
            (local.get $_M0L2q1S266)))
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 30 ;)
         (local.set $_M0L6_2atmpS989)
         (i32.store
          (local.get $_M0L2q1S266)
          (local.get $_M0L6_2atmpS989))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 30 ;)
         (drop))
        (else
         (if
          (i32.eq
           (local.get $_M0L1sS277)
           (i32.const 3))
          (then
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 37 ;)
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 42 ;)
           (i32.add
            (local.tee $_M0L3valS992
             (i32.load
              (local.get $_M0L2q3S267)))
            (i32.const 1))
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 46 ;)
           (local.set $_M0L6_2atmpS991)
           (i32.store
            (local.get $_M0L2q3S267)
            (local.get $_M0L6_2atmpS991))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 46 ;)
           (drop))
          (else
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 53 ;)
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 55 ;)
           (drop)))))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 57 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 10 ;)
       (i32.add
        (local.tee $_M0L3valS994
         (i32.load
          (local.get $_M0L1cS270)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (local.set $_M0L6_2atmpS993)
       (i32.store
        (local.get $_M0L1cS270)
        (local.get $_M0L6_2atmpS993))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (drop)
       (br $loop:278))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS270)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 74 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 75 4 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 75 8 ;)
    (i32.add
     (local.tee $_M0L3valS1022
      (i32.load
       (local.get $_M0L1rS268)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 75 13 ;)
    (local.set $_M0L6_2atmpS1021)
    (i32.store
     (local.get $_M0L1rS268)
     (local.get $_M0L6_2atmpS1021))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 75 13 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 75 13 ;)
    (drop)
    (br $loop:279))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS268)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 76 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 3 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 4 ;)
 (local.set $_M0L3valS1031
  (i32.load
   (local.get $_M0L2q1S266)))
 (local.set $_M0L3valS1032
  (i32.load
   (local.get $_M0L2q3S267)))
 (i32.sub
  (local.get $_M0L3valS1031)
  (local.get $_M0L3valS1032))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 11 ;)
 (local.tee $_M0L6_2atmpS1030)
 (i32.const 4)
 (i32.div_s)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 16 ;)
 (local.set $_M0L6_2atmpS1023)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 21 ;)
 (local.set $_M0L3valS1025
  (i32.load
   (local.get $_M0L2q3S267)))
 (local.set $_M0L3valS1026
  (i32.load
   (local.get $_M0L2q1S266)))
 (i32.gt_s
  (local.get $_M0L3valS1025)
  (local.get $_M0L3valS1026))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 28 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 31 ;)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 32 ;)
   (i32.load
    (local.get $_M0L2q3S267))
   (call $moonbit.decref
    (local.get $_M0L2q3S267))
   (local.set $_M0L3valS1028)
   (i32.load
    (local.get $_M0L2q1S266))
   (call $moonbit.decref
    (local.get $_M0L2q1S266))
   (local.set $_M0L3valS1029)
   (i32.sub
    (local.get $_M0L3valS1028)
    (local.get $_M0L3valS1029))
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 37 ;)
   (local.tee $_M0L6_2atmpS1027)
   (i32.const 4)
   (i32.div_s)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 40 ;))
  (else
   (call $moonbit.decref
    (local.get $_M0L2q3S267))
   (call $moonbit.decref
    (local.get $_M0L2q1S266))
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 50 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 51 ;)))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 53 ;)
 (local.set $_M0L6_2atmpS1024)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1229
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1229)
  (local.get $_M0L6_2atmpS1024))
 (i32.store
  (local.get $_M0L3ptrS1229)
  (local.get $_M0L6_2atmpS1023))
 (local.get $_M0L3ptrS1229)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 54 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 54 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 54 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 54 ;))
(func $_M0FP48moonarc34rhae3src4rhae17count__components (param $_M0L4gridS248 i32) (param $_M0L1hS242 i32) (param $_M0L1wS243 i32) (param $_M0L3visS249 i32) (result i32)
 (local $_M0L5stackS241 i32)
 (local $_M0L5countS244 i32)
 (local $_M0L1rS245 i32)
 (local $_M0L1cS246 i32)
 (local $_M0L3idxS247 i32)
 (local $_M0L2spS250 i32)
 (local $_M0L2ccS251 i32)
 (local $_M0L2rrS252 i32)
 (local $_M0L2nbS253 i32)
 (local $_M0L1dS254 i32)
 (local $_M0L2nrS256 i32)
 (local $_M0L2ncS257 i32)
 (local $_M0L2niS258 i32)
 (local $_M0L7_2abindS259 i32)
 (local $_M0L5_2anrS260 i32)
 (local $_M0L5_2ancS261 i32)
 (local $_M0L3valS932 i32)
 (local $_M0L3valS933 i32)
 (local $_M0L6_2atmpS934 i32)
 (local $_M0L6_2atmpS935 i32)
 (local $_M0L6_2atmpS936 i32)
 (local $_M0L3valS937 i32)
 (local $_M0L3valS938 i32)
 (local $_M0L3valS939 i32)
 (local $_M0L6_2atmpS940 i32)
 (local $_M0L3valS941 i32)
 (local $_M0L3valS942 i32)
 (local $_M0L3valS943 i32)
 (local $_M0L6_2atmpS944 i32)
 (local $_M0L3valS945 i32)
 (local $_M0L3valS946 i32)
 (local $_M0L6_2atmpS947 i32)
 (local $_M0L3valS948 i32)
 (local $_M0L6_2atmpS949 i32)
 (local $_M0L3valS950 i32)
 (local $_M0L3valS951 i32)
 (local $_M0L6_2atmpS952 i32)
 (local $_M0L6_2atmpS953 i32)
 (local $_M0L3valS954 i32)
 (local $_M0L6_2atmpS955 i32)
 (local $_M0L3valS956 i32)
 (local $_M0L3valS957 i32)
 (local $_M0L6_2atmpS958 i32)
 (local $_M0L3valS959 i32)
 (local $_M0L6_2atmpS960 i32)
 (local $_M0L6_2atmpS961 i32)
 (local $_M0L3valS962 i32)
 (local $_M0L3valS963 i32)
 (local $_M0L6_2atmpS964 i32)
 (local $_M0L8_2atupleS965 i32)
 (local $_M0L8_2atupleS966 i32)
 (local $_M0L8_2atupleS967 i32)
 (local $_M0L8_2atupleS968 i32)
 (local $_M0L6_2atmpS969 i32)
 (local $_M0L6_2atmpS970 i32)
 (local $_M0L6_2atmpS971 i32)
 (local $_M0L6_2atmpS972 i32)
 (local $_M0L3valS973 i32)
 (local $_M0L3valS974 i32)
 (local $_M0L6_2atmpS975 i32)
 (local $_M0L3valS976 i32)
 (local $_M0L6_2atmpS977 i32)
 (local $_M0L3valS978 i32)
 (local $_M0L3valS979 i32)
 (local $_M0L6_2atmpS980 i32)
 (local $_M0L3valS981 i32)
 (local $_M0L6_2atmpS982 i32)
 (local $_M0L6_2atmpS983 i32)
 (local $_M0L6_2atmpS984 i32)
 (local $_M0L3ptrS1235 i32)
 (local $_M0L3ptrS1236 i32)
 (local $_M0L6_2aptrS1237 i32)
 (local $_M0L3ptrS1238 i32)
 (local $_M0L3ptrS1239 i32)
 (local $_M0L3ptrS1240 i32)
 (local $_M0L3ptrS1241 i32)
 (local $_M0L3ptrS1242 i32)
 (local $_M0L3ptrS1243 i32)
 (local $_M0L3ptrS1244 i32)
 (local $_M0L3ptrS1245 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 27 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 39 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 39 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 39 ;)
 (i32.mul
  (local.get $_M0L1hS242)
  (local.get $_M0L1wS243))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 44 ;)
 (local.tee $_M0L6_2atmpS984)
 (i32.const 2)
 (i32.mul)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 48 ;)
 (local.tee $_M0L6_2atmpS983)
 (i32.const 2)
 (i32.add)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 52 ;)
 (local.tee $_M0L6_2atmpS982)
 (i32.const 0)
 (call $_M0MPC15array5Array4makeGiE)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 56 ;)
 (local.set $_M0L5stackS241)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 25 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1245
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1245)
  (i32.const 0))
 (local.set $_M0L5countS244
  (local.get $_M0L3ptrS1245))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 26 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1244
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1244)
  (i32.const 0))
 (local.set $_M0L1rS245
  (local.get $_M0L3ptrS1244))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 27 2 ;)
 (loop $loop:265
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 27 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS932
    (i32.load
     (local.get $_M0L1rS245)))
   (local.get $_M0L1hS242))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 27 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 28 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1243
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1243)
     (i32.const 0))
    (local.set $_M0L1cS246
     (local.get $_M0L3ptrS1243))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 29 4 ;)
    (loop $loop:264
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 29 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS933
       (i32.load
        (local.get $_M0L1cS246)))
      (local.get $_M0L1wS243))
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 29 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 30 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 30 16 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 30 16 ;)
       (i32.mul
        (local.tee $_M0L3valS979
         (i32.load
          (local.get $_M0L1rS245)))
        (local.get $_M0L1wS243))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 30 21 ;)
       (local.set $_M0L6_2atmpS977)
       (local.set $_M0L3valS978
        (i32.load
         (local.get $_M0L1cS246)))
       (i32.add
        (local.get $_M0L6_2atmpS977)
        (local.get $_M0L3valS978))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 30 25 ;)
       (local.set $_M0L3idxS247)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 9 ;)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS248)
        (local.get $_M0L3idxS247))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 18 ;)
       (local.tee $_M0L6_2atmpS935)
       (i32.const 0)
       (i32.gt_s)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 22 ;)
       (if (result i32)
        (then
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 26 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 26 ;)
         (call $_M0MPC15array5Array2atGiE
          (local.get $_M0L3visS249)
          (local.get $_M0L3idxS247))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 34 ;)
         (local.tee $_M0L6_2atmpS934)
         (i32.const 0)
         (i32.eq)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 39 ;))
        (else
         (i32.const 0)))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 39 ;)
       (if
        (then
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 32 8 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 32 16 ;)
         (i32.add
          (local.tee $_M0L3valS937
           (i32.load
            (local.get $_M0L5countS244)))
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 32 25 ;)
         (local.set $_M0L6_2atmpS936)
         (i32.store
          (local.get $_M0L5countS244)
          (local.get $_M0L6_2atmpS936))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 32 25 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 32 27 ;)
         (call $_M0MPC15array5Array3setGiE
          (local.get $_M0L3visS249)
          (local.get $_M0L3idxS247)
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 32 39 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 33 8 ;)
         (call $moonbit.store_object_meta
          (local.tee $_M0L3ptrS1242
           (call $moonbit.gc.malloc
            (i32.const 4)))
          (i32.const 524288))
         (i32.store
          (local.get $_M0L3ptrS1242)
          (i32.const 0))
         (local.set $_M0L2spS250
          (local.get $_M0L3ptrS1242))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 8 ;)
         (local.set $_M0L3valS938
          (i32.load
           (local.get $_M0L2spS250)))
         (local.set $_M0L3valS939
          (i32.load
           (local.get $_M0L1rS245)))
         (call $_M0MPC15array5Array3setGiE
          (local.get $_M0L5stackS241)
          (local.get $_M0L3valS938)
          (local.get $_M0L3valS939))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 21 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 23 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 28 ;)
         (i32.add
          (local.tee $_M0L3valS941
           (i32.load
            (local.get $_M0L2spS250)))
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 34 ;)
         (local.set $_M0L6_2atmpS940)
         (i32.store
          (local.get $_M0L2spS250)
          (local.get $_M0L6_2atmpS940))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 34 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 36 ;)
         (local.set $_M0L3valS942
          (i32.load
           (local.get $_M0L2spS250)))
         (local.set $_M0L3valS943
          (i32.load
           (local.get $_M0L1cS246)))
         (call $_M0MPC15array5Array3setGiE
          (local.get $_M0L5stackS241)
          (local.get $_M0L3valS942)
          (local.get $_M0L3valS943))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 49 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 51 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 56 ;)
         (i32.add
          (local.tee $_M0L3valS945
           (i32.load
            (local.get $_M0L2spS250)))
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 62 ;)
         (local.set $_M0L6_2atmpS944)
         (i32.store
          (local.get $_M0L2spS250)
          (local.get $_M0L6_2atmpS944))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 62 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 35 8 ;)
         (loop $loop:263
          (; source_pos moonarc3/rhae/src/rhae invariants.mbt 35 14 ;)
          (i32.gt_s
           (local.tee $_M0L3valS946
            (i32.load
             (local.get $_M0L2spS250)))
           (i32.const 0))
          (; source_pos moonarc3/rhae/src/rhae invariants.mbt 35 20 ;)
          (if
           (then
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 10 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 15 ;)
            (i32.sub
             (local.tee $_M0L3valS948
              (i32.load
               (local.get $_M0L2spS250)))
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 21 ;)
            (local.set $_M0L6_2atmpS947)
            (i32.store
             (local.get $_M0L2spS250)
             (local.get $_M0L6_2atmpS947))
            (i32.const 0)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 21 ;)
            (drop)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 23 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 32 ;)
            (local.set $_M0L3valS974
             (i32.load
              (local.get $_M0L2spS250)))
            (call $_M0MPC15array5Array2atGiE
             (local.get $_M0L5stackS241)
             (local.get $_M0L3valS974))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 41 ;)
            (local.set $_M0L2ccS251)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 10 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 15 ;)
            (i32.sub
             (local.tee $_M0L3valS950
              (i32.load
               (local.get $_M0L2spS250)))
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 21 ;)
            (local.set $_M0L6_2atmpS949)
            (i32.store
             (local.get $_M0L2spS250)
             (local.get $_M0L6_2atmpS949))
            (i32.const 0)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 21 ;)
            (drop)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 23 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 32 ;)
            (local.set $_M0L3valS973
             (i32.load
              (local.get $_M0L2spS250)))
            (call $_M0MPC15array5Array2atGiE
             (local.get $_M0L5stackS241)
             (local.get $_M0L3valS973))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 41 ;)
            (local.set $_M0L2rrS252)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 10 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 38 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 39 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 40 ;)
            (i32.sub
             (local.get $_M0L2rrS252)
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 44 ;)
            (local.set $_M0L6_2atmpS972)
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS1241
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS1241)
             (local.get $_M0L2ccS251))
            (i32.store
             (local.get $_M0L3ptrS1241)
             (local.get $_M0L6_2atmpS972))
            (local.get $_M0L3ptrS1241)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 48 ;)
            (local.set $_M0L8_2atupleS965)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 49 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 50 ;)
            (i32.add
             (local.get $_M0L2rrS252)
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 54 ;)
            (local.set $_M0L6_2atmpS971)
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS1240
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS1240)
             (local.get $_M0L2ccS251))
            (i32.store
             (local.get $_M0L3ptrS1240)
             (local.get $_M0L6_2atmpS971))
            (local.get $_M0L3ptrS1240)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 58 ;)
            (local.set $_M0L8_2atupleS966)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 59 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 63 ;)
            (i32.sub
             (local.get $_M0L2ccS251)
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 67 ;)
            (local.set $_M0L6_2atmpS970)
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS1239
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS1239)
             (local.get $_M0L6_2atmpS970))
            (i32.store
             (local.get $_M0L3ptrS1239)
             (local.get $_M0L2rrS252))
            (local.get $_M0L3ptrS1239)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 68 ;)
            (local.set $_M0L8_2atupleS967)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 69 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 73 ;)
            (i32.add
             (local.get $_M0L2ccS251)
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 77 ;)
            (local.set $_M0L6_2atmpS969)
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS1238
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS1238)
             (local.get $_M0L6_2atmpS969))
            (i32.store
             (local.get $_M0L3ptrS1238)
             (local.get $_M0L2rrS252))
            (local.get $_M0L3ptrS1238)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 78 ;)
            (local.set $_M0L8_2atupleS968)
            (i32.store
             (local.tee $_M0L6_2aptrS1237
              (call $moonbit.ref_array_make_raw
               (i32.const 4)))
             (local.get $_M0L8_2atupleS965))
            (i32.store offset=4
             (local.get $_M0L6_2aptrS1237)
             (local.get $_M0L8_2atupleS966))
            (i32.store offset=8
             (local.get $_M0L6_2aptrS1237)
             (local.get $_M0L8_2atupleS967))
            (i32.store offset=12
             (local.get $_M0L6_2aptrS1237)
             (local.get $_M0L8_2atupleS968))
            (local.set $_M0L6_2atmpS964
             (local.get $_M0L6_2aptrS1237))
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS1236
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 524544))
            (i32.store
             (local.get $_M0L3ptrS1236)
             (i32.const 4))
            (i32.store offset=4
             (local.get $_M0L3ptrS1236)
             (local.get $_M0L6_2atmpS964))
            (local.get $_M0L3ptrS1236)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 79 ;)
            (local.set $_M0L2nbS253)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 40 10 ;)
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS1235
              (call $moonbit.gc.malloc
               (i32.const 4)))
             (i32.const 524288))
            (i32.store
             (local.get $_M0L3ptrS1235)
             (i32.const 0))
            (local.set $_M0L1dS254
             (local.get $_M0L3ptrS1235))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 41 10 ;)
            (loop $loop:262
             (; source_pos moonarc3/rhae/src/rhae invariants.mbt 41 16 ;)
             (i32.lt_s
              (local.tee $_M0L3valS951
               (i32.load
                (local.get $_M0L1dS254)))
              (i32.const 4))
             (; source_pos moonarc3/rhae/src/rhae invariants.mbt 41 21 ;)
             (if
              (then
               (; source_pos moonarc3/rhae/src/rhae invariants.mbt 42 12 ;)
               (block $outer/1234 (result i32)
                (block $join:255
                 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 42 12 ;)
                 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 42 27 ;)
                 (local.set $_M0L3valS963
                  (i32.load
                   (local.get $_M0L1dS254)))
                 (call $_M0MPC15array5Array2atGUiiEE
                  (local.get $_M0L2nbS253)
                  (local.get $_M0L3valS963))
                 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 42 32 ;)
                 (local.tee $_M0L7_2abindS259)
                 (i32.load)
                 (local.set $_M0L5_2anrS260)
                 (i32.load offset=4
                  (local.get $_M0L7_2abindS259))
                 (call $moonbit.decref
                  (local.get $_M0L7_2abindS259))
                 (local.set $_M0L5_2ancS261)
                 (local.get $_M0L5_2anrS260)
                 (local.set $_M0L2ncS257
                  (local.get $_M0L5_2ancS261))
                 (local.set $_M0L2nrS256)
                 (br $join:255))
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 12 ;)
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 15 ;)
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 15 ;)
                (i32.ge_s
                 (local.get $_M0L2nrS256)
                 (i32.const 0))
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 22 ;)
                (if (result i32)
                 (then
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 26 ;)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 26 ;)
                  (i32.lt_s
                   (local.get $_M0L2nrS256)
                   (local.get $_M0L1hS242))
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 32 ;)
                  (if (result i32)
                   (then
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 36 ;)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 36 ;)
                    (i32.ge_s
                     (local.get $_M0L2ncS257)
                     (i32.const 0))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 43 ;)
                    (if (result i32)
                     (then
                      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 47 ;)
                      (i32.lt_s
                       (local.get $_M0L2ncS257)
                       (local.get $_M0L1wS243))
                      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 53 ;))
                     (else
                      (i32.const 0)))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 53 ;))
                   (else
                    (i32.const 0)))
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 53 ;))
                 (else
                  (i32.const 0)))
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 53 ;)
                (if
                 (then
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 44 14 ;)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 44 23 ;)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 44 23 ;)
                  (i32.mul
                   (local.get $_M0L2nrS256)
                   (local.get $_M0L1wS243))
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 44 29 ;)
                  (local.tee $_M0L6_2atmpS960)
                  (local.get $_M0L2ncS257)
                  (i32.add)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 44 34 ;)
                  (local.set $_M0L2niS258)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 14 ;)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 17 ;)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 17 ;)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 17 ;)
                  (call $_M0MPC15array5Array2atGiE
                   (local.get $_M0L4gridS248)
                   (local.get $_M0L2niS258))
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 25 ;)
                  (local.tee $_M0L6_2atmpS953)
                  (i32.const 0)
                  (i32.gt_s)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 29 ;)
                  (if (result i32)
                   (then
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 33 ;)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 33 ;)
                    (call $_M0MPC15array5Array2atGiE
                     (local.get $_M0L3visS249)
                     (local.get $_M0L2niS258))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 40 ;)
                    (local.tee $_M0L6_2atmpS952)
                    (i32.const 0)
                    (i32.eq)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 45 ;))
                   (else
                    (i32.const 0)))
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 45 ;)
                  (if
                   (then
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 46 16 ;)
                    (call $_M0MPC15array5Array3setGiE
                     (local.get $_M0L3visS249)
                     (local.get $_M0L2niS258)
                     (i32.const 1))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 46 27 ;)
                    (drop)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 16 ;)
                    (local.set $_M0L3valS954
                     (i32.load
                      (local.get $_M0L2spS250)))
                    (call $_M0MPC15array5Array3setGiE
                     (local.get $_M0L5stackS241)
                     (local.get $_M0L3valS954)
                     (local.get $_M0L2nrS256))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 30 ;)
                    (drop)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 32 ;)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 37 ;)
                    (i32.add
                     (local.tee $_M0L3valS956
                      (i32.load
                       (local.get $_M0L2spS250)))
                     (i32.const 1))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 43 ;)
                    (local.set $_M0L6_2atmpS955)
                    (i32.store
                     (local.get $_M0L2spS250)
                     (local.get $_M0L6_2atmpS955))
                    (i32.const 0)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 43 ;)
                    (drop)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 45 ;)
                    (local.set $_M0L3valS957
                     (i32.load
                      (local.get $_M0L2spS250)))
                    (call $_M0MPC15array5Array3setGiE
                     (local.get $_M0L5stackS241)
                     (local.get $_M0L3valS957)
                     (local.get $_M0L2ncS257))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 59 ;)
                    (drop)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 61 ;)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 66 ;)
                    (i32.add
                     (local.tee $_M0L3valS959
                      (i32.load
                       (local.get $_M0L2spS250)))
                     (i32.const 1))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 72 ;)
                    (local.set $_M0L6_2atmpS958)
                    (i32.store
                     (local.get $_M0L2spS250)
                     (local.get $_M0L6_2atmpS958))
                    (i32.const 0)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 72 ;)
                    (drop))
                   (else))
                  (i32.const 0)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 48 15 ;)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 48 15 ;)
                  (drop))
                 (else))
                (i32.const 0)
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 49 13 ;)
                (drop)
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 50 12 ;)
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 50 16 ;)
                (i32.add
                 (local.tee $_M0L3valS962
                  (i32.load
                   (local.get $_M0L1dS254)))
                 (i32.const 1))
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 50 21 ;)
                (local.set $_M0L6_2atmpS961)
                (i32.store
                 (local.get $_M0L1dS254)
                 (local.get $_M0L6_2atmpS961))
                (i32.const 0)
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 50 21 ;))
               (; source_pos moonarc3/rhae/src/rhae invariants.mbt 50 21 ;)
               (drop)
               (br $loop:262))
              (else
               (call $moonbit.decref
                (local.get $_M0L1dS254))
               (call $moonbit.decref
                (local.get $_M0L2nbS253)))))
            (i32.const 0)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 51 11 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 51 11 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 51 11 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 51 11 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 51 11 ;)
            (drop)
            (br $loop:263))
           (else
            (call $moonbit.decref
             (local.get $_M0L2spS250)))))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 52 9 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 52 9 ;)
         (drop))
        (else))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 53 7 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 54 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 54 10 ;)
       (i32.add
        (local.tee $_M0L3valS976
         (i32.load
          (local.get $_M0L1cS246)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 54 15 ;)
       (local.set $_M0L6_2atmpS975)
       (i32.store
        (local.get $_M0L1cS246)
        (local.get $_M0L6_2atmpS975))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 54 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 54 15 ;)
       (drop)
       (br $loop:264))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS246)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 55 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 56 4 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 56 8 ;)
    (i32.add
     (local.tee $_M0L3valS981
      (i32.load
       (local.get $_M0L1rS245)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 56 13 ;)
    (local.set $_M0L6_2atmpS980)
    (i32.store
     (local.get $_M0L1rS245)
     (local.get $_M0L6_2atmpS980))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 56 13 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 56 13 ;)
    (drop)
    (br $loop:265))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS245))
    (call $moonbit.decref
     (local.get $_M0L5stackS241)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 57 3 ;)
 (drop)
 (i32.load
  (local.get $_M0L5countS244))
 (call $moonbit.decref
  (local.get $_M0L5countS244))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 58 7 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 58 7 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 58 7 ;))
(func $_M0FP48moonarc34rhae3src4rhae4bbox (param $_M0L4gridS238 i32) (param $_M0L1hS231 i32) (param $_M0L1wS234 i32) (result i32)
 (local $_M0L2r0S230 i32)
 (local $_M0L2r1S232 i32)
 (local $_M0L2c0S233 i32)
 (local $_M0L2c1S235 i32)
 (local $_M0L1rS236 i32)
 (local $_M0L1cS237 i32)
 (local $_M0L3valS905 i32)
 (local $_M0L3valS906 i32)
 (local $_M0L6_2atmpS907 i32)
 (local $_M0L6_2atmpS908 i32)
 (local $_M0L6_2atmpS909 i32)
 (local $_M0L3valS910 i32)
 (local $_M0L3valS911 i32)
 (local $_M0L3valS912 i32)
 (local $_M0L3valS913 i32)
 (local $_M0L3valS914 i32)
 (local $_M0L3valS915 i32)
 (local $_M0L3valS916 i32)
 (local $_M0L3valS917 i32)
 (local $_M0L3valS918 i32)
 (local $_M0L3valS919 i32)
 (local $_M0L3valS920 i32)
 (local $_M0L3valS921 i32)
 (local $_M0L3valS922 i32)
 (local $_M0L3valS923 i32)
 (local $_M0L6_2atmpS924 i32)
 (local $_M0L3valS925 i32)
 (local $_M0L6_2atmpS926 i32)
 (local $_M0L3valS927 i32)
 (local $_M0L3valS928 i32)
 (local $_M0L3valS929 i32)
 (local $_M0L3valS930 i32)
 (local $_M0L3valS931 i32)
 (local $_M0L3ptrS1246 i32)
 (local $_M0L3ptrS1247 i32)
 (local $_M0L3ptrS1248 i32)
 (local $_M0L3ptrS1249 i32)
 (local $_M0L3ptrS1250 i32)
 (local $_M0L3ptrS1251 i32)
 (local $_M0L3ptrS1252 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 7 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1252
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1252)
  (local.get $_M0L1hS231))
 (local.set $_M0L2r0S230
  (local.get $_M0L3ptrS1252))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 7 18 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1251
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1251)
  (i32.const 0))
 (local.set $_M0L2r1S232
  (local.get $_M0L3ptrS1251))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 7 34 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1250
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1250)
  (local.get $_M0L1wS234))
 (local.set $_M0L2c0S233
  (local.get $_M0L3ptrS1250))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 7 50 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1249
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1249)
  (i32.const 0))
 (local.set $_M0L2c1S235
  (local.get $_M0L3ptrS1249))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 8 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1248
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1248)
  (i32.const 0))
 (local.set $_M0L1rS236
  (local.get $_M0L3ptrS1248))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 9 2 ;)
 (loop $loop:240
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 9 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS905
    (i32.load
     (local.get $_M0L1rS236)))
   (local.get $_M0L1hS231))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 9 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 10 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1247
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1247)
     (i32.const 0))
    (local.set $_M0L1cS237
     (local.get $_M0L3ptrS1247))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 11 4 ;)
    (loop $loop:239
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 11 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS906
       (i32.load
        (local.get $_M0L1cS237)))
      (local.get $_M0L1wS234))
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 11 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 14 ;)
       (i32.mul
        (local.tee $_M0L3valS911
         (i32.load
          (local.get $_M0L1rS236)))
        (local.get $_M0L1wS234))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 19 ;)
       (local.set $_M0L6_2atmpS909)
       (local.set $_M0L3valS910
        (i32.load
         (local.get $_M0L1cS237)))
       (i32.add
        (local.get $_M0L6_2atmpS909)
        (local.get $_M0L3valS910))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 23 ;)
       (local.set $_M0L6_2atmpS908)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS238)
        (local.get $_M0L6_2atmpS908))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 24 ;)
       (local.tee $_M0L6_2atmpS907)
       (i32.const 0)
       (i32.gt_s)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 28 ;)
       (if
        (then
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 8 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 11 ;)
         (local.set $_M0L3valS912
          (i32.load
           (local.get $_M0L1rS236)))
         (local.set $_M0L3valS913
          (i32.load
           (local.get $_M0L2r0S230)))
         (i32.lt_s
          (local.get $_M0L3valS912)
          (local.get $_M0L3valS913))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 17 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 20 ;)
           (local.set $_M0L3valS914
            (i32.load
             (local.get $_M0L1rS236)))
           (i32.store
            (local.get $_M0L2r0S230)
            (local.get $_M0L3valS914))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 26 ;)
           (drop))
          (else))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 28 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 30 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 33 ;)
         (local.set $_M0L3valS915
          (i32.load
           (local.get $_M0L1rS236)))
         (local.set $_M0L3valS916
          (i32.load
           (local.get $_M0L2r1S232)))
         (i32.gt_s
          (local.get $_M0L3valS915)
          (local.get $_M0L3valS916))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 39 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 42 ;)
           (local.set $_M0L3valS917
            (i32.load
             (local.get $_M0L1rS236)))
           (i32.store
            (local.get $_M0L2r1S232)
            (local.get $_M0L3valS917))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 48 ;)
           (drop))
          (else))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 50 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 8 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 11 ;)
         (local.set $_M0L3valS918
          (i32.load
           (local.get $_M0L1cS237)))
         (local.set $_M0L3valS919
          (i32.load
           (local.get $_M0L2c0S233)))
         (i32.lt_s
          (local.get $_M0L3valS918)
          (local.get $_M0L3valS919))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 17 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 20 ;)
           (local.set $_M0L3valS920
            (i32.load
             (local.get $_M0L1cS237)))
           (i32.store
            (local.get $_M0L2c0S233)
            (local.get $_M0L3valS920))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 26 ;)
           (drop))
          (else))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 28 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 30 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 33 ;)
         (local.set $_M0L3valS921
          (i32.load
           (local.get $_M0L1cS237)))
         (local.set $_M0L3valS922
          (i32.load
           (local.get $_M0L2c1S235)))
         (i32.gt_s
          (local.get $_M0L3valS921)
          (local.get $_M0L3valS922))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 39 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 42 ;)
           (local.set $_M0L3valS923
            (i32.load
             (local.get $_M0L1cS237)))
           (i32.store
            (local.get $_M0L2c1S235)
            (local.get $_M0L3valS923))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 48 ;)
           (drop))
          (else))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 50 ;)
         (drop))
        (else))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 15 7 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 16 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 16 10 ;)
       (i32.add
        (local.tee $_M0L3valS925
         (i32.load
          (local.get $_M0L1cS237)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 16 15 ;)
       (local.set $_M0L6_2atmpS924)
       (i32.store
        (local.get $_M0L1cS237)
        (local.get $_M0L6_2atmpS924))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 16 15 ;)
       (drop)
       (br $loop:239))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS237)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 17 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 18 4 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 18 8 ;)
    (i32.add
     (local.tee $_M0L3valS927
      (i32.load
       (local.get $_M0L1rS236)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 18 13 ;)
    (local.set $_M0L6_2atmpS926)
    (i32.store
     (local.get $_M0L1rS236)
     (local.get $_M0L6_2atmpS926))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 18 13 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 18 13 ;)
    (drop)
    (br $loop:240))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS236)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 19 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 2 ;)
 (i32.load
  (local.get $_M0L2r0S230))
 (call $moonbit.decref
  (local.get $_M0L2r0S230))
 (local.set $_M0L3valS928)
 (i32.load
  (local.get $_M0L2r1S232))
 (call $moonbit.decref
  (local.get $_M0L2r1S232))
 (local.set $_M0L3valS929)
 (i32.load
  (local.get $_M0L2c0S233))
 (call $moonbit.decref
  (local.get $_M0L2c0S233))
 (local.set $_M0L3valS930)
 (i32.load
  (local.get $_M0L2c1S235))
 (call $moonbit.decref
  (local.get $_M0L2c1S235))
 (local.set $_M0L3valS931)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1246
   (call $moonbit.gc.malloc
    (i32.const 16)))
  (i32.const 2097152))
 (i32.store offset=12
  (local.get $_M0L3ptrS1246)
  (local.get $_M0L3valS931))
 (i32.store offset=8
  (local.get $_M0L3ptrS1246)
  (local.get $_M0L3valS930))
 (i32.store offset=4
  (local.get $_M0L3ptrS1246)
  (local.get $_M0L3valS929))
 (i32.store
  (local.get $_M0L3ptrS1246)
  (local.get $_M0L3valS928))
 (local.get $_M0L3ptrS1246)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;))
(func $_M0FP48moonarc34rhae3src4rhae22rhae__color__histogram (param $_M0L1hS225 i32) (param $_M0L1wS226 i32) (result i32)
 (local $_M0L1cS222 i32)
 (local $_M0L1nS224 i32)
 (local $_M0L1iS227 i32)
 (local $_M0L1vS228 i32)
 (local $_M0L3valS892 i32)
 (local $_M0L6_2atmpS893 i32)
 (local $_M0L3valS894 i32)
 (local $_M0L6_2atmpS895 i32)
 (local $_M0L3valS896 i32)
 (local $_M0L3valS897 i32)
 (local $_M0L6_2atmpS898 i32)
 (local $_M0L6_2atmpS899 i32)
 (local $_M0L6_2atmpS900 i32)
 (local $_M0L6_2atmpS901 i32)
 (local $_M0L6_2atmpS902 i32)
 (local $_M0L3valS903 i32)
 (local $_M0L3valS904 i32)
 (local $_M0L3ptrS1253 i32)
 (local $_M0L3ptrS1254 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 72 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1254
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1254)
  (i32.const 0))
 (local.set $_M0L1cS222
  (local.get $_M0L3ptrS1254))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 73 2 ;)
 (loop $loop:223
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 73 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS892
    (i32.load
     (local.get $_M0L1cS222)))
   (i32.const 10))
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 73 14 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 74 4 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 74 12 ;)
    (local.set $_M0L3valS894
     (i32.load
      (local.get $_M0L1cS222)))
    (i32.add
     (i32.const 30)
     (local.get $_M0L3valS894))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 74 18 ;)
    (local.set $_M0L6_2atmpS893)
    (call $_M0MPC15array5Array3setGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
     (local.get $_M0L6_2atmpS893)
     (i32.const 0))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 74 23 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 75 4 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 75 8 ;)
    (i32.add
     (local.tee $_M0L3valS896
      (i32.load
       (local.get $_M0L1cS222)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 75 13 ;)
    (local.set $_M0L6_2atmpS895)
    (i32.store
     (local.get $_M0L1cS222)
     (local.get $_M0L6_2atmpS895))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 75 13 ;)
    (drop)
    (br $loop:223))
   (else
    (call $moonbit.decref
     (local.get $_M0L1cS222)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 76 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 77 2 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 77 10 ;)
 (i32.mul
  (local.get $_M0L1hS225)
  (local.get $_M0L1wS226))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 77 15 ;)
 (local.set $_M0L1nS224)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 78 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1253
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1253)
  (i32.const 0))
 (local.set $_M0L1iS227
  (local.get $_M0L3ptrS1253))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 79 2 ;)
 (loop $loop:229
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 79 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS897
    (i32.load
     (local.get $_M0L1iS227)))
   (local.get $_M0L1nS224))
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 79 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 80 4 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 80 12 ;)
    (local.set $_M0L3valS904
     (i32.load
      (local.get $_M0L1iS227)))
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
     (local.get $_M0L3valS904))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 80 23 ;)
    (local.set $_M0L1vS228)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 4 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 7 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 7 ;)
    (i32.ge_s
     (local.get $_M0L1vS228)
     (i32.const 0))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 13 ;)
    (if (result i32)
     (then
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 17 ;)
      (i32.le_s
       (local.get $_M0L1vS228)
       (i32.const 9))
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 23 ;))
     (else
      (i32.const 0)))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 23 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 26 ;)
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 34 ;)
      (i32.add
       (i32.const 30)
       (local.get $_M0L1vS228))
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 40 ;)
      (local.set $_M0L6_2atmpS898)
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 44 ;)
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 44 ;)
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 52 ;)
      (i32.add
       (i32.const 30)
       (local.get $_M0L1vS228))
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 58 ;)
      (local.set $_M0L6_2atmpS901)
      (call $_M0MPC15array5Array2atGiE
       (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
       (local.get $_M0L6_2atmpS901))
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 59 ;)
      (local.tee $_M0L6_2atmpS900)
      (i32.const 1)
      (i32.add)
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 63 ;)
      (local.set $_M0L6_2atmpS899)
      (call $_M0MPC15array5Array3setGiE
       (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
       (local.get $_M0L6_2atmpS898)
       (local.get $_M0L6_2atmpS899))
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 63 ;)
      (drop))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 81 65 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 82 4 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 82 8 ;)
    (i32.add
     (local.tee $_M0L3valS903
      (i32.load
       (local.get $_M0L1iS227)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 82 13 ;)
    (local.set $_M0L6_2atmpS902)
    (i32.store
     (local.get $_M0L1iS227)
     (local.get $_M0L6_2atmpS902))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 82 13 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 82 13 ;)
    (drop)
    (br $loop:229))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS227)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 83 3 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 83 3 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 83 3 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 83 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae18rhae__count__color (param $_M0L1hS216 i32) (param $_M0L1wS217 i32) (param $_M0L5colorS220 i32) (result i32)
 (local $_M0L1nS215 i32)
 (local $_M0L3cntS218 i32)
 (local $_M0L1iS219 i32)
 (local $_M0L3valS885 i32)
 (local $_M0L6_2atmpS886 i32)
 (local $_M0L3valS887 i32)
 (local $_M0L6_2atmpS888 i32)
 (local $_M0L3valS889 i32)
 (local $_M0L6_2atmpS890 i32)
 (local $_M0L3valS891 i32)
 (local $_M0L3ptrS1255 i32)
 (local $_M0L3ptrS1256 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 60 2 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 60 10 ;)
 (i32.mul
  (local.get $_M0L1hS216)
  (local.get $_M0L1wS217))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 60 15 ;)
 (local.set $_M0L1nS215)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 61 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1256
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1256)
  (i32.const 0))
 (local.set $_M0L3cntS218
  (local.get $_M0L3ptrS1256))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 62 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1255
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1255)
  (i32.const 0))
 (local.set $_M0L1iS219
  (local.get $_M0L3ptrS1255))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 63 2 ;)
 (loop $loop:221
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 63 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS885
    (i32.load
     (local.get $_M0L1iS219)))
   (local.get $_M0L1nS215))
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 63 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 64 4 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 64 7 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 64 7 ;)
    (local.set $_M0L3valS887
     (i32.load
      (local.get $_M0L1iS219)))
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
     (local.get $_M0L3valS887))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 64 18 ;)
    (local.tee $_M0L6_2atmpS886)
    (local.get $_M0L5colorS220)
    (i32.eq)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 64 27 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 64 30 ;)
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 64 36 ;)
      (i32.add
       (local.tee $_M0L3valS889
        (i32.load
         (local.get $_M0L3cntS218)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 64 43 ;)
      (local.set $_M0L6_2atmpS888)
      (i32.store
       (local.get $_M0L3cntS218)
       (local.get $_M0L6_2atmpS888))
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae pattern.mbt 64 43 ;)
      (drop))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 64 45 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 65 4 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 65 8 ;)
    (i32.add
     (local.tee $_M0L3valS891
      (i32.load
       (local.get $_M0L1iS219)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 65 13 ;)
    (local.set $_M0L6_2atmpS890)
    (i32.store
     (local.get $_M0L1iS219)
     (local.get $_M0L6_2atmpS890))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 65 13 ;)
    (drop)
    (br $loop:221))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS219)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 66 3 ;)
 (drop)
 (i32.load
  (local.get $_M0L3cntS218))
 (call $moonbit.decref
  (local.get $_M0L3cntS218))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 67 5 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 67 5 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 67 5 ;))
(func $_M0FP48moonarc34rhae3src4rhae10rhae__bbox (param $_M0L1hS205 i32) (param $_M0L1wS207 i32) (param $_M0L5colorS212 i32) (result i32)
 (local $_M0L6min__rS204 i32)
 (local $_M0L6min__cS206 i32)
 (local $_M0L6max__rS208 i32)
 (local $_M0L6max__cS209 i32)
 (local $_M0L1rS210 i32)
 (local $_M0L1cS211 i32)
 (local $_M0L3valS857 i32)
 (local $_M0L3valS858 i32)
 (local $_M0L6_2atmpS859 i32)
 (local $_M0L6_2atmpS860 i32)
 (local $_M0L6_2atmpS861 i32)
 (local $_M0L3valS862 i32)
 (local $_M0L3valS863 i32)
 (local $_M0L3valS864 i32)
 (local $_M0L3valS865 i32)
 (local $_M0L3valS866 i32)
 (local $_M0L3valS867 i32)
 (local $_M0L3valS868 i32)
 (local $_M0L3valS869 i32)
 (local $_M0L3valS870 i32)
 (local $_M0L3valS871 i32)
 (local $_M0L3valS872 i32)
 (local $_M0L3valS873 i32)
 (local $_M0L3valS874 i32)
 (local $_M0L3valS875 i32)
 (local $_M0L6_2atmpS876 i32)
 (local $_M0L3valS877 i32)
 (local $_M0L6_2atmpS878 i32)
 (local $_M0L3valS879 i32)
 (local $_M0L3valS880 i32)
 (local $_M0L3valS881 i32)
 (local $_M0L3valS882 i32)
 (local $_M0L3valS883 i32)
 (local $_M0L3valS884 i32)
 (local $_M0L3ptrS1257 i32)
 (local $_M0L3ptrS1258 i32)
 (local $_M0L3ptrS1259 i32)
 (local $_M0L3ptrS1260 i32)
 (local $_M0L3ptrS1261 i32)
 (local $_M0L3ptrS1262 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 37 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1262
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1262)
  (local.get $_M0L1hS205))
 (local.set $_M0L6min__rS204
  (local.get $_M0L3ptrS1262))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 37 21 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1261
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1261)
  (local.get $_M0L1wS207))
 (local.set $_M0L6min__cS206
  (local.get $_M0L3ptrS1261))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 38 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1260
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1260)
  (i32.const -1))
 (local.set $_M0L6max__rS208
  (local.get $_M0L3ptrS1260))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 38 22 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1259
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1259)
  (i32.const -1))
 (local.set $_M0L6max__cS209
  (local.get $_M0L3ptrS1259))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 39 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1258
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1258)
  (i32.const 0))
 (local.set $_M0L1rS210
  (local.get $_M0L3ptrS1258))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 40 2 ;)
 (loop $loop:214
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 40 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS857
    (i32.load
     (local.get $_M0L1rS210)))
   (local.get $_M0L1hS205))
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 40 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 41 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1257
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1257)
     (i32.const 0))
    (local.set $_M0L1cS211
     (local.get $_M0L3ptrS1257))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 42 4 ;)
    (loop $loop:213
     (; source_pos moonarc3/rhae/src/rhae pattern.mbt 42 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS858
       (i32.load
        (local.get $_M0L1cS211)))
      (local.get $_M0L1wS207))
     (; source_pos moonarc3/rhae/src/rhae pattern.mbt 42 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 43 6 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 43 9 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 43 9 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 43 18 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 43 18 ;)
       (i32.mul
        (local.tee $_M0L3valS863
         (i32.load
          (local.get $_M0L1rS210)))
        (local.get $_M0L1wS207))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 43 23 ;)
       (local.set $_M0L6_2atmpS861)
       (local.set $_M0L3valS862
        (i32.load
         (local.get $_M0L1cS211)))
       (i32.add
        (local.get $_M0L6_2atmpS861)
        (local.get $_M0L3valS862))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 43 27 ;)
       (local.set $_M0L6_2atmpS860)
       (call $_M0MPC15array5Array2atGiE
        (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
        (local.get $_M0L6_2atmpS860))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 43 28 ;)
       (local.tee $_M0L6_2atmpS859)
       (local.get $_M0L5colorS212)
       (i32.eq)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 43 37 ;)
       (if
        (then
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 44 8 ;)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 44 11 ;)
         (local.set $_M0L3valS864
          (i32.load
           (local.get $_M0L1rS210)))
         (local.set $_M0L3valS865
          (i32.load
           (local.get $_M0L6min__rS204)))
         (i32.lt_s
          (local.get $_M0L3valS864)
          (local.get $_M0L3valS865))
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 44 20 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae pattern.mbt 44 23 ;)
           (local.set $_M0L3valS866
            (i32.load
             (local.get $_M0L1rS210)))
           (i32.store
            (local.get $_M0L6min__rS204)
            (local.get $_M0L3valS866))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae pattern.mbt 44 32 ;)
           (drop))
          (else))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 44 34 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 45 8 ;)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 45 11 ;)
         (local.set $_M0L3valS867
          (i32.load
           (local.get $_M0L1cS211)))
         (local.set $_M0L3valS868
          (i32.load
           (local.get $_M0L6min__cS206)))
         (i32.lt_s
          (local.get $_M0L3valS867)
          (local.get $_M0L3valS868))
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 45 20 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae pattern.mbt 45 23 ;)
           (local.set $_M0L3valS869
            (i32.load
             (local.get $_M0L1cS211)))
           (i32.store
            (local.get $_M0L6min__cS206)
            (local.get $_M0L3valS869))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae pattern.mbt 45 32 ;)
           (drop))
          (else))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 45 34 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 46 8 ;)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 46 11 ;)
         (local.set $_M0L3valS870
          (i32.load
           (local.get $_M0L1rS210)))
         (local.set $_M0L3valS871
          (i32.load
           (local.get $_M0L6max__rS208)))
         (i32.gt_s
          (local.get $_M0L3valS870)
          (local.get $_M0L3valS871))
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 46 20 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae pattern.mbt 46 23 ;)
           (local.set $_M0L3valS872
            (i32.load
             (local.get $_M0L1rS210)))
           (i32.store
            (local.get $_M0L6max__rS208)
            (local.get $_M0L3valS872))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae pattern.mbt 46 32 ;)
           (drop))
          (else))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 46 34 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 47 8 ;)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 47 11 ;)
         (local.set $_M0L3valS873
          (i32.load
           (local.get $_M0L1cS211)))
         (local.set $_M0L3valS874
          (i32.load
           (local.get $_M0L6max__cS209)))
         (i32.gt_s
          (local.get $_M0L3valS873)
          (local.get $_M0L3valS874))
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 47 20 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae pattern.mbt 47 23 ;)
           (local.set $_M0L3valS875
            (i32.load
             (local.get $_M0L1cS211)))
           (i32.store
            (local.get $_M0L6max__cS209)
            (local.get $_M0L3valS875))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae pattern.mbt 47 32 ;)
           (drop))
          (else))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 47 34 ;)
         (drop))
        (else))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 48 7 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 49 6 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 49 10 ;)
       (i32.add
        (local.tee $_M0L3valS877
         (i32.load
          (local.get $_M0L1cS211)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 49 15 ;)
       (local.set $_M0L6_2atmpS876)
       (i32.store
        (local.get $_M0L1cS211)
        (local.get $_M0L6_2atmpS876))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 49 15 ;)
       (drop)
       (br $loop:213))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS211)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 50 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 51 4 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 51 8 ;)
    (i32.add
     (local.tee $_M0L3valS879
      (i32.load
       (local.get $_M0L1rS210)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 51 13 ;)
    (local.set $_M0L6_2atmpS878)
    (i32.store
     (local.get $_M0L1rS210)
     (local.get $_M0L6_2atmpS878))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 51 13 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 51 13 ;)
    (drop)
    (br $loop:214))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS210)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 52 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 53 2 ;)
 (i32.load
  (local.get $_M0L6min__rS204))
 (call $moonbit.decref
  (local.get $_M0L6min__rS204))
 (local.set $_M0L3valS880)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (i32.const 20)
  (local.get $_M0L3valS880))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 53 21 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 53 23 ;)
 (i32.load
  (local.get $_M0L6min__cS206))
 (call $moonbit.decref
  (local.get $_M0L6min__cS206))
 (local.set $_M0L3valS881)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (i32.const 21)
  (local.get $_M0L3valS881))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 53 42 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 54 2 ;)
 (local.set $_M0L3valS882
  (i32.load
   (local.get $_M0L6max__rS208)))
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (i32.const 22)
  (local.get $_M0L3valS882))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 54 21 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 54 23 ;)
 (i32.load
  (local.get $_M0L6max__cS209))
 (call $moonbit.decref
  (local.get $_M0L6max__cS209))
 (local.set $_M0L3valS883)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (i32.const 23)
  (local.get $_M0L3valS883))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 54 42 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 2 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 5 ;)
 (i32.load
  (local.get $_M0L6max__rS208))
 (call $moonbit.decref
  (local.get $_M0L6max__rS208))
 (local.tee $_M0L3valS884)
 (i32.const -1)
 (i32.eq)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 16 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 19 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 20 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 30 ;)
   (i32.const 1)
   (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 31 ;)))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 33 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 33 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 33 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 33 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 33 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 55 33 ;))
(func $_M0FP48moonarc34rhae3src4rhae15rhae__has__vsym (param $_M0L1hS199 i32) (param $_M0L1wS201 i32) (result i32)
 (local $_M0L1rS198 i32)
 (local $_M0L1cS200 i32)
 (local $_M0L3valS838 i32)
 (local $_M0L3valS839 i32)
 (local $_M0L6_2atmpS840 i32)
 (local $_M0L6_2atmpS841 i32)
 (local $_M0L6_2atmpS842 i32)
 (local $_M0L6_2atmpS843 i32)
 (local $_M0L6_2atmpS844 i32)
 (local $_M0L6_2atmpS845 i32)
 (local $_M0L6_2atmpS846 i32)
 (local $_M0L3valS847 i32)
 (local $_M0L3valS848 i32)
 (local $_M0L6_2atmpS849 i32)
 (local $_M0L6_2atmpS850 i32)
 (local $_M0L3valS851 i32)
 (local $_M0L3valS852 i32)
 (local $_M0L6_2atmpS853 i32)
 (local $_M0L3valS854 i32)
 (local $_M0L6_2atmpS855 i32)
 (local $_M0L3valS856 i32)
 (local $_M0L3ptrS1263 i32)
 (local $_M0L3ptrS1264 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 22 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1264
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1264)
  (i32.const 0))
 (local.set $_M0L1rS198
  (local.get $_M0L3ptrS1264))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 23 2 ;)
 (loop $loop:203
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 23 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS838
    (i32.load
     (local.get $_M0L1rS198)))
   (local.get $_M0L1hS199))
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 23 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 24 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1263
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1263)
     (i32.const 0))
    (local.set $_M0L1cS200
     (local.get $_M0L3ptrS1263))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 25 4 ;)
    (loop $loop:202
     (; source_pos moonarc3/rhae/src/rhae pattern.mbt 25 10 ;)
     (local.set $_M0L3valS839
      (i32.load
       (local.get $_M0L1cS200)))
     (; source_pos moonarc3/rhae/src/rhae pattern.mbt 25 14 ;)
     (i32.div_s
      (local.get $_M0L1wS201)
      (i32.const 2))
     (; source_pos moonarc3/rhae/src/rhae pattern.mbt 25 19 ;)
     (local.set $_M0L6_2atmpS840)
     (i32.lt_s
      (local.get $_M0L3valS839)
      (local.get $_M0L6_2atmpS840))
     (; source_pos moonarc3/rhae/src/rhae pattern.mbt 25 19 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 6 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 9 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 9 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 18 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 18 ;)
       (i32.mul
        (local.tee $_M0L3valS852
         (i32.load
          (local.get $_M0L1rS198)))
        (local.get $_M0L1wS201))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 23 ;)
       (local.set $_M0L6_2atmpS850)
       (local.set $_M0L3valS851
        (i32.load
         (local.get $_M0L1cS200)))
       (i32.add
        (local.get $_M0L6_2atmpS850)
        (local.get $_M0L3valS851))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 27 ;)
       (local.set $_M0L6_2atmpS849)
       (call $_M0MPC15array5Array2atGiE
        (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
        (local.get $_M0L6_2atmpS849))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 28 ;)
       (local.set $_M0L6_2atmpS841)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 32 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 41 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 41 ;)
       (i32.mul
        (local.tee $_M0L3valS848
         (i32.load
          (local.get $_M0L1rS198)))
        (local.get $_M0L1wS201))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 46 ;)
       (local.set $_M0L6_2atmpS844)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 50 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 50 ;)
       (i32.sub
        (local.get $_M0L1wS201)
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 55 ;)
       (local.set $_M0L6_2atmpS846)
       (local.set $_M0L3valS847
        (i32.load
         (local.get $_M0L1cS200)))
       (i32.sub
        (local.get $_M0L6_2atmpS846)
        (local.get $_M0L3valS847))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 59 ;)
       (local.set $_M0L6_2atmpS845)
       (i32.add
        (local.get $_M0L6_2atmpS844)
        (local.get $_M0L6_2atmpS845))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 60 ;)
       (local.set $_M0L6_2atmpS843)
       (call $_M0MPC15array5Array2atGiE
        (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
        (local.get $_M0L6_2atmpS843))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 61 ;)
       (local.set $_M0L6_2atmpS842)
       (local.get $_M0L6_2atmpS841)
       (i32.ne
        (local.get $_M0L6_2atmpS842))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 61 ;)
       (if
        (then
         (call $moonbit.decref
          (local.get $_M0L1cS200))
         (call $moonbit.decref
          (local.get $_M0L1rS198))
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 64 ;)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 71 ;)
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 72 ;)
         (return))
        (else))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 26 74 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 27 6 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 27 10 ;)
       (i32.add
        (local.tee $_M0L3valS854
         (i32.load
          (local.get $_M0L1cS200)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 27 15 ;)
       (local.set $_M0L6_2atmpS853)
       (i32.store
        (local.get $_M0L1cS200)
        (local.get $_M0L6_2atmpS853))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 27 15 ;)
       (drop)
       (br $loop:202))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS200)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 28 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 29 4 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 29 8 ;)
    (i32.add
     (local.tee $_M0L3valS856
      (i32.load
       (local.get $_M0L1rS198)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 29 13 ;)
    (local.set $_M0L6_2atmpS855)
    (i32.store
     (local.get $_M0L1rS198)
     (local.get $_M0L6_2atmpS855))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 29 13 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 29 13 ;)
    (drop)
    (br $loop:203))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS198)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 30 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 31 2 ;)
 (i32.const 1)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 31 3 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 31 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae15rhae__has__hsym (param $_M0L1hS193 i32) (param $_M0L1wS195 i32) (result i32)
 (local $_M0L1rS192 i32)
 (local $_M0L1cS194 i32)
 (local $_M0L3valS819 i32)
 (local $_M0L6_2atmpS820 i32)
 (local $_M0L3valS821 i32)
 (local $_M0L6_2atmpS822 i32)
 (local $_M0L6_2atmpS823 i32)
 (local $_M0L6_2atmpS824 i32)
 (local $_M0L6_2atmpS825 i32)
 (local $_M0L3valS826 i32)
 (local $_M0L6_2atmpS827 i32)
 (local $_M0L6_2atmpS828 i32)
 (local $_M0L3valS829 i32)
 (local $_M0L6_2atmpS830 i32)
 (local $_M0L6_2atmpS831 i32)
 (local $_M0L3valS832 i32)
 (local $_M0L3valS833 i32)
 (local $_M0L6_2atmpS834 i32)
 (local $_M0L3valS835 i32)
 (local $_M0L6_2atmpS836 i32)
 (local $_M0L3valS837 i32)
 (local $_M0L3ptrS1265 i32)
 (local $_M0L3ptrS1266 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 8 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1266
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1266)
  (i32.const 0))
 (local.set $_M0L1rS192
  (local.get $_M0L3ptrS1266))
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 9 2 ;)
 (loop $loop:197
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 9 8 ;)
  (local.set $_M0L3valS819
   (i32.load
    (local.get $_M0L1rS192)))
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 9 12 ;)
  (i32.div_s
   (local.get $_M0L1hS193)
   (i32.const 2))
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 9 17 ;)
  (local.set $_M0L6_2atmpS820)
  (i32.lt_s
   (local.get $_M0L3valS819)
   (local.get $_M0L6_2atmpS820))
  (; source_pos moonarc3/rhae/src/rhae pattern.mbt 9 17 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 10 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1265
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1265)
     (i32.const 0))
    (local.set $_M0L1cS194
     (local.get $_M0L3ptrS1265))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 11 4 ;)
    (loop $loop:196
     (; source_pos moonarc3/rhae/src/rhae pattern.mbt 11 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS821
       (i32.load
        (local.get $_M0L1cS194)))
      (local.get $_M0L1wS195))
     (; source_pos moonarc3/rhae/src/rhae pattern.mbt 11 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 6 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 9 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 9 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 18 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 18 ;)
       (i32.mul
        (local.tee $_M0L3valS833
         (i32.load
          (local.get $_M0L1rS192)))
        (local.get $_M0L1wS195))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 23 ;)
       (local.set $_M0L6_2atmpS831)
       (local.set $_M0L3valS832
        (i32.load
         (local.get $_M0L1cS194)))
       (i32.add
        (local.get $_M0L6_2atmpS831)
        (local.get $_M0L3valS832))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 27 ;)
       (local.set $_M0L6_2atmpS830)
       (call $_M0MPC15array5Array2atGiE
        (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
        (local.get $_M0L6_2atmpS830))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 28 ;)
       (local.set $_M0L6_2atmpS822)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 32 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 41 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 41 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 42 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 42 ;)
       (i32.sub
        (local.get $_M0L1hS193)
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 47 ;)
       (local.set $_M0L6_2atmpS828)
       (local.set $_M0L3valS829
        (i32.load
         (local.get $_M0L1rS192)))
       (i32.sub
        (local.get $_M0L6_2atmpS828)
        (local.get $_M0L3valS829))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 51 ;)
       (local.tee $_M0L6_2atmpS827)
       (local.get $_M0L1wS195)
       (i32.mul)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 56 ;)
       (local.set $_M0L6_2atmpS825)
       (local.set $_M0L3valS826
        (i32.load
         (local.get $_M0L1cS194)))
       (i32.add
        (local.get $_M0L6_2atmpS825)
        (local.get $_M0L3valS826))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 60 ;)
       (local.set $_M0L6_2atmpS824)
       (call $_M0MPC15array5Array2atGiE
        (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
        (local.get $_M0L6_2atmpS824))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 61 ;)
       (local.set $_M0L6_2atmpS823)
       (local.get $_M0L6_2atmpS822)
       (i32.ne
        (local.get $_M0L6_2atmpS823))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 61 ;)
       (if
        (then
         (call $moonbit.decref
          (local.get $_M0L1cS194))
         (call $moonbit.decref
          (local.get $_M0L1rS192))
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 64 ;)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 71 ;)
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 72 ;)
         (return))
        (else))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 12 74 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 13 6 ;)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 13 10 ;)
       (i32.add
        (local.tee $_M0L3valS835
         (i32.load
          (local.get $_M0L1cS194)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 13 15 ;)
       (local.set $_M0L6_2atmpS834)
       (i32.store
        (local.get $_M0L1cS194)
        (local.get $_M0L6_2atmpS834))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae pattern.mbt 13 15 ;)
       (drop)
       (br $loop:196))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS194)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 14 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 15 4 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 15 8 ;)
    (i32.add
     (local.tee $_M0L3valS837
      (i32.load
       (local.get $_M0L1rS192)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 15 13 ;)
    (local.set $_M0L6_2atmpS836)
    (i32.store
     (local.get $_M0L1rS192)
     (local.get $_M0L6_2atmpS836))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 15 13 ;)
    (; source_pos moonarc3/rhae/src/rhae pattern.mbt 15 13 ;)
    (drop)
    (br $loop:197))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS192)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 16 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 17 2 ;)
 (i32.const 1)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 17 3 ;)
 (; source_pos moonarc3/rhae/src/rhae pattern.mbt 17 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae12policy__gate (param $_M0L5legalS184 i32) (param $_M0L3invS180 i32) (param $_M0L6__gridS189 i32) (param $_M0L3__hS190 i32) (param $_M0L3__wS191 i32) (param $_M0L5risksS181 i32) (param $_M0L10n__actionsS182 i32) (result i32)
 (local $_M0L7blockedS179 i32)
 (local $_M0L8filteredS183 i32)
 (local $_M0L1vS186 i32)
 (local $_M0L1vS188 i32)
 (local $_M0L6_2atmpS814 i32)
 (local $_M0L6_2atmpS815 i32)
 (local $_M0L6_2atmpS816 i32)
 (local $_M0L6_2atmpS817 i32)
 (local $_M0L6_2atmpS818 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 2 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 16 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 16 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 16 ;)
 (call $_M0FP48moonarc34rhae3src4rhae11block__noop
  (local.get $_M0L3invS180))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 31 ;)
 (local.set $_M0L6_2atmpS817)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 34 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14block__revisit
  (local.get $_M0L5risksS181)
  (local.get $_M0L10n__actionsS182))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 65 ;)
 (local.set $_M0L6_2atmpS818)
 (i32.or
  (local.get $_M0L6_2atmpS817)
  (local.get $_M0L6_2atmpS818))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 65 ;)
 (local.set $_M0L6_2atmpS815)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 68 ;)
 (call $_M0FP48moonarc34rhae3src4rhae12block__empty
  (local.get $_M0L3invS180))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 84 ;)
 (local.set $_M0L6_2atmpS816)
 (i32.or
  (local.get $_M0L6_2atmpS815)
  (local.get $_M0L6_2atmpS816))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 84 ;)
 (local.set $_M0L7blockedS179)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 32 2 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 32 17 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 32 26 ;)
 (i32.xor
  (local.get $_M0L7blockedS179)
  (i32.const -1))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 32 40 ;)
 (local.set $_M0L6_2atmpS814)
 (i32.and
  (local.get $_M0L5legalS184)
  (local.get $_M0L6_2atmpS814))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 32 41 ;)
 (local.set $_M0L8filteredS183)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 2 ;)
 (block $join:185
  (if (result i32)
   (i32.eq
    (local.get $_M0L8filteredS183)
    (i32.const 0))
   (then
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 24 ;)
    (block $join:187
     (if (result i32)
      (i32.eq
       (local.get $_M0L5legalS184)
       (i32.const 0))
      (then
       (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 43 ;)
       (i32.const 64)
       (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 52 ;))
      (else
       (local.set $_M0L1vS188
        (local.get $_M0L5legalS184))
       (br $join:187)))
     (return))
    (local.get $_M0L1vS188)
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 62 ;))
   (else
    (local.set $_M0L1vS186
     (local.get $_M0L8filteredS183))
    (br $join:185)))
  (return))
 (local.get $_M0L1vS186)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 72 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 72 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 72 ;))
(func $_M0FP48moonarc34rhae3src4rhae12block__empty (param $_M0L3invS178 i32) (result i32)
 (local $_M0L7_2abindS177 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 23 2 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 23 8 ;)
 (call $_M0MPC15array5Array2atGiE
  (local.get $_M0L3invS178)
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 23 14 ;)
 (local.tee $_M0L7_2abindS177)
 (i32.const 0)
 (i32.eq)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 23 22 ;)
   (i32.const 63)
   (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 23 31 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 23 38 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 23 39 ;)))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 23 41 ;))
(func $_M0FP48moonarc34rhae3src4rhae14block__revisit (param $_M0L5risksS175 i32) (param $_M0L1nS174 i32) (result i32)
 (local $_M0L7blockedS172 i32)
 (local $_M0L1iS173 i32)
 (local $_M0L3valS804 i32)
 (local $_M0L3valS805 i32)
 (local $_M0L6_2atmpS806 i32)
 (local $_M0L3valS807 i32)
 (local $_M0L6_2atmpS808 i32)
 (local $_M0L3valS809 i32)
 (local $_M0L6_2atmpS810 i32)
 (local $_M0L3valS811 i32)
 (local $_M0L6_2atmpS812 i32)
 (local $_M0L3valS813 i32)
 (local $_M0L3ptrS1267 i32)
 (local $_M0L3ptrS1268 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 14 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1268
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1268)
  (i32.const 0))
 (local.set $_M0L7blockedS172
  (local.get $_M0L3ptrS1268))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 14 23 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1267
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1267)
  (i32.const 0))
 (local.set $_M0L1iS173
  (local.get $_M0L3ptrS1267))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 2 ;)
 (loop $loop:176
  (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 8 ;)
  (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS805
    (i32.load
     (local.get $_M0L1iS173)))
   (local.get $_M0L1nS174))
  (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 13 ;)
  (if (result i32)
   (then
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 17 ;)
    (i32.lt_s
     (local.tee $_M0L3valS804
      (i32.load
       (local.get $_M0L1iS173)))
     (i32.const 7))
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 22 ;))
   (else
    (i32.const 0)))
  (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 22 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 4 ;)
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 7 ;)
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 7 ;)
    (local.set $_M0L3valS807
     (i32.load
      (local.get $_M0L1iS173)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L5risksS175)
     (local.get $_M0L3valS807))
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 15 ;)
    (local.tee $_M0L6_2atmpS806)
    (i32.const 95)
    (i32.ge_s)
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 21 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 24 ;)
      (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 34 ;)
      (local.set $_M0L3valS809
       (i32.load
        (local.get $_M0L7blockedS172)))
      (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 45 ;)
      (local.set $_M0L3valS811
       (i32.load
        (local.get $_M0L1iS173)))
      (i32.shl
       (i32.const 1)
       (local.get $_M0L3valS811))
      (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 51 ;)
      (local.set $_M0L6_2atmpS810)
      (i32.or
       (local.get $_M0L3valS809)
       (local.get $_M0L6_2atmpS810))
      (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 52 ;)
      (local.set $_M0L6_2atmpS808)
      (i32.store
       (local.get $_M0L7blockedS172)
       (local.get $_M0L6_2atmpS808))
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 52 ;)
      (drop))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 54 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 17 4 ;)
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 17 8 ;)
    (i32.add
     (local.tee $_M0L3valS813
      (i32.load
       (local.get $_M0L1iS173)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 17 13 ;)
    (local.set $_M0L6_2atmpS812)
    (i32.store
     (local.get $_M0L1iS173)
     (local.get $_M0L6_2atmpS812))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 17 13 ;)
    (drop)
    (br $loop:176))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS173)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 18 3 ;)
 (drop)
 (i32.load
  (local.get $_M0L7blockedS172))
 (call $moonbit.decref
  (local.get $_M0L7blockedS172))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 19 9 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 19 9 ;))
(func $_M0FP48moonarc34rhae3src4rhae11block__noop (param $_M0L3invS170 i32) (result i32)
 (local $_M0L7_2abindS169 i32)
 (local $_M0L7_2abindS171 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 2 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 9 ;)
 (call $_M0MPC15array5Array2atGiE
  (local.get $_M0L3invS170)
  (i32.const 5))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 15 ;)
 (local.set $_M0L7_2abindS169)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 17 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 17 ;)
 (call $_M0MPC15array5Array2atGiE
  (local.get $_M0L3invS170)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 23 ;)
 (local.set $_M0L7_2abindS171)
 (if (result i32)
  (i32.eq
   (local.get $_M0L7_2abindS169)
   (i32.const 1))
  (then
   (if (result i32)
    (i32.eq
     (local.get $_M0L7_2abindS171)
     (i32.const 0))
    (then
     (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 8 14 ;)
     (i32.const 48)
     (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 8 23 ;))
    (else
     (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 9 14 ;)
     (i32.const 0)
     (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 9 15 ;))))
  (else
   (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 9 14 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 9 15 ;)))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 23 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 10 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae16rhae__is__solved (param $_M0L1hS165 i32) (param $_M0L1wS166 i32) (result i32)
 (local $_M0L1nS164 i32)
 (local $_M0L1iS167 i32)
 (local $_M0L3valS797 i32)
 (local $_M0L6_2atmpS798 i32)
 (local $_M0L6_2atmpS799 i32)
 (local $_M0L3valS800 i32)
 (local $_M0L3valS801 i32)
 (local $_M0L6_2atmpS802 i32)
 (local $_M0L3valS803 i32)
 (local $_M0L3ptrS1269 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 55 2 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 55 10 ;)
 (i32.mul
  (local.get $_M0L1hS165)
  (local.get $_M0L1wS166))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 55 15 ;)
 (local.set $_M0L1nS164)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 56 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1269
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1269)
  (i32.const 0))
 (local.set $_M0L1iS167
  (local.get $_M0L3ptrS1269))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 57 2 ;)
 (loop $loop:168
  (; source_pos moonarc3/rhae/src/rhae score.mbt 57 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS797
    (i32.load
     (local.get $_M0L1iS167)))
   (local.get $_M0L1nS164))
  (; source_pos moonarc3/rhae/src/rhae score.mbt 57 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae score.mbt 58 4 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 58 7 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 58 7 ;)
    (local.set $_M0L3valS801
     (i32.load
      (local.get $_M0L1iS167)))
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
     (local.get $_M0L3valS801))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 58 18 ;)
    (local.set $_M0L6_2atmpS798)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 58 22 ;)
    (local.set $_M0L3valS800
     (i32.load
      (local.get $_M0L1iS167)))
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae11target__buf)
     (local.get $_M0L3valS800))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 58 35 ;)
    (local.set $_M0L6_2atmpS799)
    (local.get $_M0L6_2atmpS798)
    (i32.ne
     (local.get $_M0L6_2atmpS799))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 58 35 ;)
    (if
     (then
      (call $moonbit.decref
       (local.get $_M0L1iS167))
      (; source_pos moonarc3/rhae/src/rhae score.mbt 58 38 ;)
      (; source_pos moonarc3/rhae/src/rhae score.mbt 58 45 ;)
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae score.mbt 58 46 ;)
      (return))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 58 48 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 59 4 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 59 8 ;)
    (i32.add
     (local.tee $_M0L3valS803
      (i32.load
       (local.get $_M0L1iS167)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 59 13 ;)
    (local.set $_M0L6_2atmpS802)
    (i32.store
     (local.get $_M0L1iS167)
     (local.get $_M0L6_2atmpS802))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 59 13 ;)
    (drop)
    (br $loop:168))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS167)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 60 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 61 2 ;)
 (i32.const 1)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 61 3 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 61 3 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 61 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae18rhae__score__batch (param $_M0L1hS160 i32) (param $_M0L1wS161 i32) (result i32)
 (local $_M0L3hamS159 i32)
 (local $_M0L1cS162 i32)
 (local $_M0L3valS790 i32)
 (local $_M0L6_2atmpS791 i32)
 (local $_M0L6_2atmpS792 i32)
 (local $_M0L3valS793 i32)
 (local $_M0L3valS794 i32)
 (local $_M0L6_2atmpS795 i32)
 (local $_M0L3valS796 i32)
 (local $_M0L3ptrS1270 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 44 2 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 44 12 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13rhae__hamming
  (local.get $_M0L1hS160)
  (local.get $_M0L1wS161))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 44 30 ;)
 (local.set $_M0L3hamS159)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 45 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1270
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1270)
  (i32.const 1))
 (local.set $_M0L1cS162
  (local.get $_M0L3ptrS1270))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 46 2 ;)
 (loop $loop:163
  (; source_pos moonarc3/rhae/src/rhae score.mbt 46 8 ;)
  (i32.le_s
   (local.tee $_M0L3valS790
    (i32.load
     (local.get $_M0L1cS162)))
   (i32.const 9))
  (; source_pos moonarc3/rhae/src/rhae score.mbt 46 14 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae score.mbt 47 4 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 47 12 ;)
    (local.set $_M0L3valS794
     (i32.load
      (local.get $_M0L1cS162)))
    (i32.add
     (i32.const 10)
     (local.get $_M0L3valS794))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 47 18 ;)
    (local.set $_M0L6_2atmpS791)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 47 22 ;)
    (local.set $_M0L3valS793
     (i32.load
      (local.get $_M0L1cS162)))
    (call $_M0FP48moonarc34rhae3src4rhae17rhae__iou__scaled
     (local.get $_M0L1hS160)
     (local.get $_M0L1wS161)
     (local.get $_M0L3valS793))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 47 46 ;)
    (local.set $_M0L6_2atmpS792)
    (call $_M0MPC15array5Array3setGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
     (local.get $_M0L6_2atmpS791)
     (local.get $_M0L6_2atmpS792))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 47 46 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 48 4 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 48 8 ;)
    (i32.add
     (local.tee $_M0L3valS796
      (i32.load
       (local.get $_M0L1cS162)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 48 13 ;)
    (local.set $_M0L6_2atmpS795)
    (i32.store
     (local.get $_M0L1cS162)
     (local.get $_M0L6_2atmpS795))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 48 13 ;)
    (drop)
    (br $loop:163))
   (else
    (call $moonbit.decref
     (local.get $_M0L1cS162)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 49 3 ;)
 (drop)
 (local.get $_M0L3hamS159)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 50 5 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 50 5 ;))
(func $_M0FP48moonarc34rhae3src4rhae17rhae__iou__scaled (param $_M0L1hS150 i32) (param $_M0L1wS151 i32) (param $_M0L5colorS156 i32) (result i32)
 (local $_M0L1nS149 i32)
 (local $_M0L5interS152 i32)
 (local $_M0L7union__S153 i32)
 (local $_M0L1iS154 i32)
 (local $_M0L1gS155 i32)
 (local $_M0L1tS157 i32)
 (local $_M0L3valS774 i32)
 (local $_M0L6_2atmpS775 i32)
 (local $_M0L3valS776 i32)
 (local $_M0L6_2atmpS777 i32)
 (local $_M0L6_2atmpS778 i32)
 (local $_M0L3valS779 i32)
 (local $_M0L6_2atmpS780 i32)
 (local $_M0L3valS781 i32)
 (local $_M0L6_2atmpS782 i32)
 (local $_M0L3valS783 i32)
 (local $_M0L6_2atmpS784 i32)
 (local $_M0L3valS785 i32)
 (local $_M0L3valS786 i32)
 (local $_M0L6_2atmpS787 i32)
 (local $_M0L3valS788 i32)
 (local $_M0L3valS789 i32)
 (local $_M0L3ptrS1271 i32)
 (local $_M0L3ptrS1272 i32)
 (local $_M0L3ptrS1273 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 25 2 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 25 10 ;)
 (i32.mul
  (local.get $_M0L1hS150)
  (local.get $_M0L1wS151))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 25 15 ;)
 (local.set $_M0L1nS149)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 26 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1273
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1273)
  (i32.const 0))
 (local.set $_M0L5interS152
  (local.get $_M0L3ptrS1273))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 27 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1272
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1272)
  (i32.const 0))
 (local.set $_M0L7union__S153
  (local.get $_M0L3ptrS1272))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 28 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1271
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1271)
  (i32.const 0))
 (local.set $_M0L1iS154
  (local.get $_M0L3ptrS1271))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 29 2 ;)
 (loop $loop:158
  (; source_pos moonarc3/rhae/src/rhae score.mbt 29 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS774
    (i32.load
     (local.get $_M0L1iS154)))
   (local.get $_M0L1nS149))
  (; source_pos moonarc3/rhae/src/rhae score.mbt 29 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae score.mbt 30 4 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 30 12 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 30 15 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 30 15 ;)
    (local.set $_M0L3valS785
     (i32.load
      (local.get $_M0L1iS154)))
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
     (local.get $_M0L3valS785))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 30 26 ;)
    (local.tee $_M0L6_2atmpS784)
    (local.get $_M0L5colorS156)
    (i32.eq)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 30 36 ;)
    (if (result i32)
     (then
      (; source_pos moonarc3/rhae/src/rhae score.mbt 30 39 ;)
      (i32.const 1)
      (; source_pos moonarc3/rhae/src/rhae score.mbt 30 40 ;))
     (else
      (; source_pos moonarc3/rhae/src/rhae score.mbt 30 50 ;)
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae score.mbt 30 51 ;)))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 30 53 ;)
    (local.set $_M0L1gS155)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 31 4 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 31 12 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 31 15 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 31 15 ;)
    (local.set $_M0L3valS783
     (i32.load
      (local.get $_M0L1iS154)))
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae11target__buf)
     (local.get $_M0L3valS783))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 31 28 ;)
    (local.tee $_M0L6_2atmpS782)
    (local.get $_M0L5colorS156)
    (i32.eq)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 31 37 ;)
    (if (result i32)
     (then
      (; source_pos moonarc3/rhae/src/rhae score.mbt 31 40 ;)
      (i32.const 1)
      (; source_pos moonarc3/rhae/src/rhae score.mbt 31 41 ;))
     (else
      (; source_pos moonarc3/rhae/src/rhae score.mbt 31 51 ;)
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae score.mbt 31 52 ;)))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 31 54 ;)
    (local.set $_M0L1tS157)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 32 4 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 32 12 ;)
    (local.set $_M0L3valS776
     (i32.load
      (local.get $_M0L5interS152)))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 32 20 ;)
    (i32.mul
     (local.get $_M0L1gS155)
     (local.get $_M0L1tS157))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 32 25 ;)
    (local.set $_M0L6_2atmpS777)
    (i32.add
     (local.get $_M0L3valS776)
     (local.get $_M0L6_2atmpS777))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 32 25 ;)
    (local.set $_M0L6_2atmpS775)
    (i32.store
     (local.get $_M0L5interS152)
     (local.get $_M0L6_2atmpS775))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 32 25 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 33 4 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 33 7 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 33 7 ;)
    (i32.eq
     (local.get $_M0L1gS155)
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 33 13 ;)
    (if (result i32)
     (then
      (i32.const 1))
     (else
      (; source_pos moonarc3/rhae/src/rhae score.mbt 33 17 ;)
      (i32.eq
       (local.get $_M0L1tS157)
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae score.mbt 33 23 ;)))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 33 23 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae score.mbt 33 26 ;)
      (; source_pos moonarc3/rhae/src/rhae score.mbt 33 35 ;)
      (i32.add
       (local.tee $_M0L3valS779
        (i32.load
         (local.get $_M0L7union__S153)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae score.mbt 33 45 ;)
      (local.set $_M0L6_2atmpS778)
      (i32.store
       (local.get $_M0L7union__S153)
       (local.get $_M0L6_2atmpS778))
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae score.mbt 33 45 ;)
      (drop))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 33 47 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 34 4 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 34 8 ;)
    (i32.add
     (local.tee $_M0L3valS781
      (i32.load
       (local.get $_M0L1iS154)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 34 13 ;)
    (local.set $_M0L6_2atmpS780)
    (i32.store
     (local.get $_M0L1iS154)
     (local.get $_M0L6_2atmpS780))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 34 13 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 34 13 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 34 13 ;)
    (drop)
    (br $loop:158))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS154)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 35 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 36 2 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 36 5 ;)
 (i32.eq
  (local.tee $_M0L3valS786
   (i32.load
    (local.get $_M0L7union__S153)))
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 36 16 ;)
 (if
  (then
   (call $moonbit.decref
    (local.get $_M0L7union__S153))
   (call $moonbit.decref
    (local.get $_M0L5interS152))
   (; source_pos moonarc3/rhae/src/rhae score.mbt 36 19 ;)
   (; source_pos moonarc3/rhae/src/rhae score.mbt 36 26 ;)
   (i32.const 1000)
   (; source_pos moonarc3/rhae/src/rhae score.mbt 36 30 ;)
   (return))
  (else))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 36 32 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 37 2 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 37 2 ;)
 (i32.load
  (local.get $_M0L5interS152))
 (call $moonbit.decref
  (local.get $_M0L5interS152))
 (local.tee $_M0L3valS789)
 (i32.const 1000)
 (i32.mul)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 37 14 ;)
 (local.set $_M0L6_2atmpS787)
 (i32.load
  (local.get $_M0L7union__S153))
 (call $moonbit.decref
  (local.get $_M0L7union__S153))
 (local.set $_M0L3valS788)
 (i32.div_s
  (local.get $_M0L6_2atmpS787)
  (local.get $_M0L3valS788))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 37 23 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 37 23 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 37 23 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 37 23 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 37 23 ;))
(func $_M0FP48moonarc34rhae3src4rhae13rhae__hamming (param $_M0L1hS144 i32) (param $_M0L1wS145 i32) (result i32)
 (local $_M0L1nS143 i32)
 (local $_M0L4diffS146 i32)
 (local $_M0L1iS147 i32)
 (local $_M0L3valS765 i32)
 (local $_M0L6_2atmpS766 i32)
 (local $_M0L6_2atmpS767 i32)
 (local $_M0L3valS768 i32)
 (local $_M0L3valS769 i32)
 (local $_M0L6_2atmpS770 i32)
 (local $_M0L3valS771 i32)
 (local $_M0L6_2atmpS772 i32)
 (local $_M0L3valS773 i32)
 (local $_M0L3ptrS1274 i32)
 (local $_M0L3ptrS1275 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 13 2 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 13 10 ;)
 (i32.mul
  (local.get $_M0L1hS144)
  (local.get $_M0L1wS145))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 13 15 ;)
 (local.set $_M0L1nS143)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 14 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1275
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1275)
  (i32.const 0))
 (local.set $_M0L4diffS146
  (local.get $_M0L3ptrS1275))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 15 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1274
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1274)
  (i32.const 0))
 (local.set $_M0L1iS147
  (local.get $_M0L3ptrS1274))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 16 2 ;)
 (loop $loop:148
  (; source_pos moonarc3/rhae/src/rhae score.mbt 16 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS765
    (i32.load
     (local.get $_M0L1iS147)))
   (local.get $_M0L1nS143))
  (; source_pos moonarc3/rhae/src/rhae score.mbt 16 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae score.mbt 17 4 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 17 7 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 17 7 ;)
    (local.set $_M0L3valS769
     (i32.load
      (local.get $_M0L1iS147)))
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
     (local.get $_M0L3valS769))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 17 18 ;)
    (local.set $_M0L6_2atmpS766)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 17 22 ;)
    (local.set $_M0L3valS768
     (i32.load
      (local.get $_M0L1iS147)))
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae11target__buf)
     (local.get $_M0L3valS768))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 17 35 ;)
    (local.set $_M0L6_2atmpS767)
    (local.get $_M0L6_2atmpS766)
    (i32.ne
     (local.get $_M0L6_2atmpS767))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 17 35 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae score.mbt 17 38 ;)
      (; source_pos moonarc3/rhae/src/rhae score.mbt 17 45 ;)
      (i32.add
       (local.tee $_M0L3valS771
        (i32.load
         (local.get $_M0L4diffS146)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae score.mbt 17 53 ;)
      (local.set $_M0L6_2atmpS770)
      (i32.store
       (local.get $_M0L4diffS146)
       (local.get $_M0L6_2atmpS770))
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae score.mbt 17 53 ;)
      (drop))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 17 55 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 18 4 ;)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 18 8 ;)
    (i32.add
     (local.tee $_M0L3valS773
      (i32.load
       (local.get $_M0L1iS147)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae score.mbt 18 13 ;)
    (local.set $_M0L6_2atmpS772)
    (i32.store
     (local.get $_M0L1iS147)
     (local.get $_M0L6_2atmpS772))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae score.mbt 18 13 ;)
    (drop)
    (br $loop:148))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS147)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 19 3 ;)
 (drop)
 (i32.load
  (local.get $_M0L4diffS146))
 (call $moonbit.decref
  (local.get $_M0L4diffS146))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 20 6 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 20 6 ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 20 6 ;))
(func $_M0FP48moonarc34rhae3src4rhae17set__target__cell (param $_M0L3idxS141 i32) (param $_M0L3valS142 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 8 55 ;)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae11target__buf)
  (local.get $_M0L3idxS141)
  (local.get $_M0L3valS142))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 8 76 ;))
(func $_M0FP48moonarc34rhae3src4rhae22build__candidate__rows (param $_M0L5legalS130 i32) (param $_M0L3invS139 i32) (param $_M0L3visS134 i32) (param $_M0L10path__costS138 i32) (param $_M0L8hash__loS136 i32) (param $_M0L8hash__hiS137 i32) (param $_M0L3matS135 i32) (param $_M0L6max__cS129 i32) (result i32)
 (local $_M0L1nS127 i32)
 (local $_M0L1aS128 i32)
 (local $_M0L1bS131 i32)
 (local $_M0L3novS132 i32)
 (local $_M0L7_2abindS133 i32)
 (local $_M0L3valS726 i32)
 (local $_M0L3valS727 i32)
 (local $_M0L6_2atmpS728 i32)
 (local $_M0L6_2atmpS729 i32)
 (local $_M0L6_2atmpS730 i32)
 (local $_M0L3valS731 i32)
 (local $_M0L3valS732 i32)
 (local $_M0L6_2atmpS733 i32)
 (local $_M0L6_2atmpS734 i32)
 (local $_M0L6_2atmpS735 i32)
 (local $_M0L6_2atmpS736 i32)
 (local $_M0L6_2atmpS737 i32)
 (local $_M0L6_2atmpS738 i32)
 (local $_M0L6_2atmpS739 i32)
 (local $_M0L3valS740 i32)
 (local $_M0L6_2atmpS741 i32)
 (local $_M0L6_2atmpS742 i32)
 (local $_M0L6_2atmpS743 i32)
 (local $_M0L6_2atmpS744 i32)
 (local $_M0L6_2atmpS745 i32)
 (local $_M0L6_2atmpS746 i32)
 (local $_M0L6_2atmpS747 i32)
 (local $_M0L6_2atmpS748 i32)
 (local $_M0L6_2atmpS749 i32)
 (local $_M0L6_2atmpS750 i32)
 (local $_M0L6_2atmpS751 i32)
 (local $_M0L6_2atmpS752 i32)
 (local $_M0L6_2atmpS753 i32)
 (local $_M0L6_2atmpS754 i32)
 (local $_M0L6_2atmpS755 i32)
 (local $_M0L6_2atmpS756 i32)
 (local $_M0L6_2atmpS757 i32)
 (local $_M0L6_2atmpS758 i32)
 (local $_M0L3valS759 i32)
 (local $_M0L6_2atmpS760 i32)
 (local $_M0L3valS761 i32)
 (local $_M0L3valS762 i32)
 (local $_M0L6_2atmpS763 i32)
 (local $_M0L3valS764 i32)
 (local $_M0L3ptrS1276 i32)
 (local $_M0L3ptrS1277 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 41 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1277
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1277)
  (i32.const 0))
 (local.set $_M0L1nS127
  (local.get $_M0L3ptrS1277))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 42 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1276
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1276)
  (i32.const 1))
 (local.set $_M0L1aS128
  (local.get $_M0L3ptrS1276))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 2 ;)
 (loop $loop:140
  (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 8 ;)
  (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 8 ;)
  (i32.le_s
   (local.tee $_M0L3valS727
    (i32.load
     (local.get $_M0L1aS128)))
   (i32.const 7))
  (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 14 ;)
  (if (result i32)
   (then
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 18 ;)
    (i32.lt_s
     (local.tee $_M0L3valS726
      (i32.load
       (local.get $_M0L1nS127)))
     (local.get $_M0L6max__cS129))
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 27 ;))
   (else
    (i32.const 0)))
  (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 27 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 4 ;)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 7 ;)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 8 ;)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 9 ;)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 19 ;)
    (i32.sub
     (local.tee $_M0L3valS731
      (i32.load
       (local.get $_M0L1aS128)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 22 ;)
    (local.set $_M0L6_2atmpS730)
    (i32.shr_s
     (local.get $_M0L5legalS130)
     (local.get $_M0L6_2atmpS730))
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 23 ;)
    (local.tee $_M0L6_2atmpS729)
    (i32.const 1)
    (i32.and)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 28 ;)
    (local.tee $_M0L6_2atmpS728)
    (i32.const 1)
    (i32.eq)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 34 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 45 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 45 16 ;)
      (i32.mul
       (local.tee $_M0L3valS762
        (i32.load
         (local.get $_M0L1nS127)))
       (i32.const 13))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 45 22 ;)
      (local.set $_M0L1bS131)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 16 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 22 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 26 ;)
      (i32.sub
       (local.tee $_M0L3valS761
        (i32.load
         (local.get $_M0L1aS128)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 29 ;)
      (local.set $_M0L6_2atmpS760)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3visS134)
       (local.get $_M0L6_2atmpS760))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 30 ;)
      (local.tee $_M0L7_2abindS133)
      (i32.const 0)
      (i32.eq)
      (if (result i32)
       (then
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 38 ;)
        (i32.const 100)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 41 ;))
       (else
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 48 ;)
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 49 ;)))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 51 ;)
      (local.set $_M0L3novS132)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 6 ;)
      (local.set $_M0L3valS732
       (i32.load
        (local.get $_M0L1aS128)))
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L1bS131)
       (local.get $_M0L3valS732))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 19 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 38 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 41 ;)
      (local.set $_M0L6_2atmpS733)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS733)
       (local.get $_M0L8hash__loS136))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 53 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 10 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 2))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 13 ;)
      (local.set $_M0L6_2atmpS734)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS734)
       (local.get $_M0L8hash__hiS137))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 25 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 38 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 3))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 41 ;)
      (local.set $_M0L6_2atmpS735)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS735)
       (local.get $_M0L10path__costS138))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 55 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 10 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 4))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 13 ;)
      (local.set $_M0L6_2atmpS736)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 18 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 18 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 22 ;)
      (i32.sub
       (local.tee $_M0L3valS740
        (i32.load
         (local.get $_M0L1aS128)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 25 ;)
      (local.set $_M0L6_2atmpS739)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3visS134)
       (local.get $_M0L6_2atmpS739))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 26 ;)
      (local.tee $_M0L6_2atmpS738)
      (i32.const 100)
      (i32.mul)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 30 ;)
      (local.set $_M0L6_2atmpS737)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS736)
       (local.get $_M0L6_2atmpS737))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 30 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 38 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 5))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 41 ;)
      (local.set $_M0L6_2atmpS741)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS741)
       (local.get $_M0L3novS132))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 49 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 10 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 6))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 13 ;)
      (local.set $_M0L6_2atmpS742)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 18 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS139)
       (i32.const 8))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 24 ;)
      (local.set $_M0L6_2atmpS743)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS742)
       (local.get $_M0L6_2atmpS743))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 24 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 38 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 7))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 41 ;)
      (local.set $_M0L6_2atmpS744)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 46 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS139)
       (i32.const 0))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 52 ;)
      (local.set $_M0L6_2atmpS745)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS744)
       (local.get $_M0L6_2atmpS745))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 52 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 10 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 8))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 13 ;)
      (local.set $_M0L6_2atmpS746)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 18 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS139)
       (i32.const 7))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 24 ;)
      (local.set $_M0L6_2atmpS747)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS746)
       (local.get $_M0L6_2atmpS747))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 24 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 38 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 9))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 41 ;)
      (local.set $_M0L6_2atmpS748)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 46 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 46 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS139)
       (i32.const 3))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 52 ;)
      (local.set $_M0L6_2atmpS750)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 53 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS139)
       (i32.const 4))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 59 ;)
      (local.set $_M0L6_2atmpS751)
      (i32.mul
       (local.get $_M0L6_2atmpS750)
       (local.get $_M0L6_2atmpS751))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 59 ;)
      (local.set $_M0L6_2atmpS749)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS748)
       (local.get $_M0L6_2atmpS749))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 59 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 10 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 10))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 14 ;)
      (local.set $_M0L6_2atmpS752)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 18 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS139)
       (i32.const 5))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 24 ;)
      (local.set $_M0L6_2atmpS753)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS752)
       (local.get $_M0L6_2atmpS753))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 24 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 38 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 11))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 42 ;)
      (local.set $_M0L6_2atmpS754)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 46 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS139)
       (i32.const 8))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 52 ;)
      (local.set $_M0L6_2atmpS755)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS754)
       (local.get $_M0L6_2atmpS755))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 52 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 10 ;)
      (i32.add
       (local.get $_M0L1bS131)
       (i32.const 12))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 14 ;)
      (local.set $_M0L6_2atmpS756)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 18 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS139)
       (i32.const 9))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 24 ;)
      (local.set $_M0L6_2atmpS757)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS135)
       (local.get $_M0L6_2atmpS756)
       (local.get $_M0L6_2atmpS757))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 24 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 54 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 54 10 ;)
      (i32.add
       (local.tee $_M0L3valS759
        (i32.load
         (local.get $_M0L1nS127)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 54 15 ;)
      (local.set $_M0L6_2atmpS758)
      (i32.store
       (local.get $_M0L1nS127)
       (local.get $_M0L6_2atmpS758))
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 54 15 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 54 15 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 54 15 ;)
      (drop))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 55 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 56 4 ;)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 56 8 ;)
    (i32.add
     (local.tee $_M0L3valS764
      (i32.load
       (local.get $_M0L1aS128)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 56 13 ;)
    (local.set $_M0L6_2atmpS763)
    (i32.store
     (local.get $_M0L1aS128)
     (local.get $_M0L6_2atmpS763))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 56 13 ;)
    (drop)
    (br $loop:140))
   (else
    (call $moonbit.decref
     (local.get $_M0L1aS128)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 57 3 ;)
 (drop)
 (i32.load
  (local.get $_M0L1nS127))
 (call $moonbit.decref
  (local.get $_M0L1nS127))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 58 3 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 58 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae16topk__candidates (param $_M0L5pairsS123 i32) (param $_M0L1nS122 i32) (param $_M0L1kS116 i32) (param $_M0L3outS126 i32) (result i32)
 (local $_M0L2kkS115 i32)
 (local $_M0L4usedS117 i32)
 (local $_M0L6n__selS118 i32)
 (local $_M0L7best__iS119 i32)
 (local $_M0L7best__sS120 i32)
 (local $_M0L1iS121 i32)
 (local $_M0L3valS701 i32)
 (local $_M0L3valS702 i32)
 (local $_M0L6_2atmpS703 i32)
 (local $_M0L3valS704 i32)
 (local $_M0L6_2atmpS705 i32)
 (local $_M0L6_2atmpS706 i32)
 (local $_M0L3valS707 i32)
 (local $_M0L6_2atmpS708 i32)
 (local $_M0L3valS709 i32)
 (local $_M0L6_2atmpS710 i32)
 (local $_M0L6_2atmpS711 i32)
 (local $_M0L6_2atmpS712 i32)
 (local $_M0L3valS713 i32)
 (local $_M0L3valS714 i32)
 (local $_M0L6_2atmpS715 i32)
 (local $_M0L3valS716 i32)
 (local $_M0L3valS717 i32)
 (local $_M0L3valS718 i32)
 (local $_M0L3valS719 i32)
 (local $_M0L3valS720 i32)
 (local $_M0L6_2atmpS721 i32)
 (local $_M0L6_2atmpS722 i32)
 (local $_M0L3valS723 i32)
 (local $_M0L6_2atmpS724 i32)
 (local $_M0L3valS725 i32)
 (local $_M0L3ptrS1278 i32)
 (local $_M0L3ptrS1279 i32)
 (local $_M0L3ptrS1280 i32)
 (local $_M0L3ptrS1281 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 2 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 13 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 16 ;)
 (i32.gt_s
  (local.get $_M0L1kS116)
  (i32.const 6))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 21 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 24 ;)
   (i32.const 6)
   (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 25 ;))
  (else
   (local.get $_M0L1kS116)))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 38 ;)
 (local.set $_M0L2kkS115)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 12 2 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 12 26 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 64)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 12 44 ;)
 (local.set $_M0L4usedS117)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 13 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1281
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1281)
  (i32.const 0))
 (local.set $_M0L6n__selS118
  (local.get $_M0L3ptrS1281))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 14 2 ;)
 (block $break:125
  (loop $loop:125
   (; source_pos moonarc3/rhae/src/rhae topk.mbt 14 8 ;)
   (i32.lt_s
    (local.tee $_M0L3valS701
     (i32.load
      (local.get $_M0L6n__selS118)))
    (local.get $_M0L2kkS115))
   (; source_pos moonarc3/rhae/src/rhae topk.mbt 14 18 ;)
   (if
    (then
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 15 4 ;)
     (call $moonbit.store_object_meta
      (local.tee $_M0L3ptrS1280
       (call $moonbit.gc.malloc
        (i32.const 4)))
      (i32.const 524288))
     (i32.store
      (local.get $_M0L3ptrS1280)
      (i32.const -1))
     (local.set $_M0L7best__iS119
      (local.get $_M0L3ptrS1280))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 15 25 ;)
     (call $moonbit.store_object_meta
      (local.tee $_M0L3ptrS1279
       (call $moonbit.gc.malloc
        (i32.const 4)))
      (i32.const 524288))
     (i32.store
      (local.get $_M0L3ptrS1279)
      (i32.const -1))
     (local.set $_M0L7best__sS120
      (local.get $_M0L3ptrS1279))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 16 4 ;)
     (call $moonbit.store_object_meta
      (local.tee $_M0L3ptrS1278
       (call $moonbit.gc.malloc
        (i32.const 4)))
      (i32.const 524288))
     (i32.store
      (local.get $_M0L3ptrS1278)
      (i32.const 0))
     (local.set $_M0L1iS121
      (local.get $_M0L3ptrS1278))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 17 4 ;)
     (loop $loop:124
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 17 10 ;)
      (i32.lt_s
       (local.tee $_M0L3valS702
        (i32.load
         (local.get $_M0L1iS121)))
       (local.get $_M0L1nS122))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 17 15 ;)
      (if
       (then
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 6 ;)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 9 ;)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 9 ;)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 9 ;)
        (local.set $_M0L3valS709
         (i32.load
          (local.get $_M0L1iS121)))
        (call $_M0MPC15array5Array2atGiE
         (local.get $_M0L4usedS117)
         (local.get $_M0L3valS709))
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 16 ;)
        (local.tee $_M0L6_2atmpS708)
        (i32.const 0)
        (i32.eq)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 21 ;)
        (if (result i32)
         (then
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 25 ;)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 25 ;)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 31 ;)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 31 ;)
          (i32.mul
           (local.tee $_M0L3valS707
            (i32.load
             (local.get $_M0L1iS121)))
           (i32.const 2))
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 34 ;)
          (local.tee $_M0L6_2atmpS706)
          (i32.const 1)
          (i32.add)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 36 ;)
          (local.set $_M0L6_2atmpS705)
          (call $_M0MPC15array5Array2atGiE
           (local.get $_M0L5pairsS123)
           (local.get $_M0L6_2atmpS705))
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 37 ;)
          (local.set $_M0L6_2atmpS703)
          (local.set $_M0L3valS704
           (i32.load
            (local.get $_M0L7best__sS120)))
          (i32.gt_s
           (local.get $_M0L6_2atmpS703)
           (local.get $_M0L3valS704))
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 46 ;))
         (else
          (i32.const 0)))
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 46 ;)
        (if
         (then
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 8 ;)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 17 ;)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 23 ;)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 23 ;)
          (i32.mul
           (local.tee $_M0L3valS713
            (i32.load
             (local.get $_M0L1iS121)))
           (i32.const 2))
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 26 ;)
          (local.tee $_M0L6_2atmpS712)
          (i32.const 1)
          (i32.add)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 28 ;)
          (local.set $_M0L6_2atmpS711)
          (call $_M0MPC15array5Array2atGiE
           (local.get $_M0L5pairsS123)
           (local.get $_M0L6_2atmpS711))
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 29 ;)
          (local.set $_M0L6_2atmpS710)
          (i32.store
           (local.get $_M0L7best__sS120)
           (local.get $_M0L6_2atmpS710))
          (i32.const 0)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 29 ;)
          (drop)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 31 ;)
          (local.set $_M0L3valS714
           (i32.load
            (local.get $_M0L1iS121)))
          (i32.store
           (local.get $_M0L7best__iS119)
           (local.get $_M0L3valS714))
          (i32.const 0)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 41 ;)
          (drop))
         (else))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 20 7 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 21 6 ;)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 21 10 ;)
        (i32.add
         (local.tee $_M0L3valS716
          (i32.load
           (local.get $_M0L1iS121)))
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 21 15 ;)
        (local.set $_M0L6_2atmpS715)
        (i32.store
         (local.get $_M0L1iS121)
         (local.get $_M0L6_2atmpS715))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 21 15 ;)
        (drop)
        (br $loop:124))
       (else
        (call $moonbit.decref
         (local.get $_M0L1iS121)))))
     (i32.const 0)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 22 5 ;)
     (drop)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 4 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 7 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 7 ;)
     (i32.eq
      (local.tee $_M0L3valS718
       (i32.load
        (local.get $_M0L7best__iS119)))
      (i32.const -1))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 19 ;)
     (if (result i32)
      (then
       (call $moonbit.decref
        (local.get $_M0L7best__sS120))
       (i32.const 1))
      (else
       (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 23 ;)
       (i32.load
        (local.get $_M0L7best__sS120))
       (call $moonbit.decref
        (local.get $_M0L7best__sS120))
       (local.tee $_M0L3valS717)
       (i32.const 0)
       (i32.lt_s)
       (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 33 ;)))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 33 ;)
     (if
      (then
       (call $moonbit.decref
        (local.get $_M0L7best__iS119))
       (call $moonbit.decref
        (local.get $_M0L4usedS117))
       (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 36 ;)
       (br $break:125))
      (else))
     (i32.const 0)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 43 ;)
     (drop)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 24 4 ;)
     (local.set $_M0L3valS719
      (i32.load
       (local.get $_M0L7best__iS119)))
     (call $_M0MPC15array5Array3setGiE
      (local.get $_M0L4usedS117)
      (local.get $_M0L3valS719)
      (i32.const 1))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 24 20 ;)
     (drop)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 4 ;)
     (local.set $_M0L3valS720
      (i32.load
       (local.get $_M0L6n__selS118)))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 17 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 23 ;)
     (i32.load
      (local.get $_M0L7best__iS119))
     (call $moonbit.decref
      (local.get $_M0L7best__iS119))
     (local.tee $_M0L3valS723)
     (i32.const 2)
     (i32.mul)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 31 ;)
     (local.set $_M0L6_2atmpS722)
     (call $_M0MPC15array5Array2atGiE
      (local.get $_M0L5pairsS123)
      (local.get $_M0L6_2atmpS722))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 32 ;)
     (local.set $_M0L6_2atmpS721)
     (call $_M0MPC15array5Array3setGiE
      (local.get $_M0L3outS126)
      (local.get $_M0L3valS720)
      (local.get $_M0L6_2atmpS721))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 32 ;)
     (drop)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 4 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 12 ;)
     (i32.add
      (local.tee $_M0L3valS725
       (i32.load
        (local.get $_M0L6n__selS118)))
      (i32.const 1))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 21 ;)
     (local.set $_M0L6_2atmpS724)
     (i32.store
      (local.get $_M0L6n__selS118)
      (local.get $_M0L6_2atmpS724))
     (i32.const 0)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 21 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 21 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 21 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 21 ;)
     (drop)
     (br $loop:125))
    (else
     (call $moonbit.decref
      (local.get $_M0L4usedS117))))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 27 3 ;)
 (drop)
 (i32.load
  (local.get $_M0L6n__selS118))
 (call $moonbit.decref
  (local.get $_M0L6n__selS118))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 28 7 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 28 7 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 28 7 ;))
(func $_M0FP48moonarc34rhae3src4rhae15d4__hashes__all (param $_M0L4gridS103 i32) (param $_M0L1hS99 i32) (param $_M0L1wS101 i32) (result i32)
 (local $_M0L8seen__loS92 i32)
 (local $_M0L8seen__hiS93 i32)
 (local $_M0L6uniqueS94 i32)
 (local $_M0L1tS95 i32)
 (local $_M0L2loS96 i32)
 (local $_M0L2hiS97 i32)
 (local $_M0L1rS98 i32)
 (local $_M0L1cS100 i32)
 (local $_M0L5colorS102 i32)
 (local $_M0L2trS105 i32)
 (local $_M0L2tcS106 i32)
 (local $_M0L3idxS107 i32)
 (local $_M0L7_2abindS108 i32)
 (local $_M0L7is__newS111 i32)
 (local $_M0L1kS112 i32)
 (local $_M0L3valS632 i32)
 (local $_M0L3valS633 i32)
 (local $_M0L3valS634 i32)
 (local $_M0L6_2atmpS635 i32)
 (local $_M0L3valS636 i32)
 (local $_M0L6_2atmpS637 i32)
 (local $_M0L6_2atmpS638 i32)
 (local $_M0L3valS639 i32)
 (local $_M0L6_2atmpS640 i32)
 (local $_M0L6_2atmpS641 i32)
 (local $_M0L3valS642 i32)
 (local $_M0L3valS643 i32)
 (local $_M0L3valS644 i32)
 (local $_M0L3valS645 i32)
 (local $_M0L6_2atmpS646 i32)
 (local $_M0L6_2atmpS647 i32)
 (local $_M0L3valS648 i32)
 (local $_M0L6_2atmpS649 i32)
 (local $_M0L6_2atmpS650 i32)
 (local $_M0L6_2atmpS651 i32)
 (local $_M0L3valS652 i32)
 (local $_M0L6_2atmpS653 i32)
 (local $_M0L3valS654 i32)
 (local $_M0L6_2atmpS655 i32)
 (local $_M0L3valS656 i32)
 (local $_M0L6_2atmpS657 i32)
 (local $_M0L3valS658 i32)
 (local $_M0L3valS659 i32)
 (local $_M0L6_2atmpS660 i32)
 (local $_M0L6_2atmpS661 i32)
 (local $_M0L3valS662 i32)
 (local $_M0L6_2atmpS663 i32)
 (local $_M0L3valS664 i32)
 (local $_M0L6_2atmpS665 i32)
 (local $_M0L3valS666 i32)
 (local $_M0L3valS667 i32)
 (local $_M0L3valS668 i32)
 (local $_M0L6_2atmpS669 i32)
 (local $_M0L6_2atmpS670 i32)
 (local $_M0L6_2atmpS671 i32)
 (local $_M0L3valS672 i32)
 (local $_M0L6_2atmpS673 i32)
 (local $_M0L3valS674 i32)
 (local $_M0L3valS675 i32)
 (local $_M0L3valS676 i32)
 (local $_M0L6_2atmpS677 i32)
 (local $_M0L6_2atmpS678 i32)
 (local $_M0L3valS679 i32)
 (local $_M0L3valS680 i32)
 (local $_M0L6_2atmpS681 i32)
 (local $_M0L3valS682 i32)
 (local $_M0L3valS683 i32)
 (local $_M0L3valS684 i32)
 (local $_M0L6_2atmpS685 i32)
 (local $_M0L3valS686 i32)
 (local $_M0L3valS687 i32)
 (local $_M0L6_2atmpS688 i32)
 (local $_M0L3valS689 i32)
 (local $_M0L3valS690 i32)
 (local $_M0L6_2atmpS691 i32)
 (local $_M0L3valS692 i32)
 (local $_M0L3valS693 i32)
 (local $_M0L3valS694 i32)
 (local $_M0L3valS695 i32)
 (local $_M0L3valS696 i32)
 (local $_M0L6_2atmpS697 i32)
 (local $_M0L3valS698 i32)
 (local $_M0L6_2atmpS699 i32)
 (local $_M0L3valS700 i32)
 (local $_M0L3ptrS1282 i32)
 (local $_M0L3ptrS1283 i32)
 (local $_M0L3ptrS1295 i32)
 (local $_M0L3ptrS1296 i32)
 (local $_M0L3ptrS1297 i32)
 (local $_M0L3ptrS1298 i32)
 (local $_M0L3ptrS1299 i32)
 (local $_M0L3ptrS1300 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 155 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 155 16 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 156 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 156 29 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 8)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 156 46 ;)
 (local.set $_M0L8seen__loS92)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 157 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 157 29 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 8)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 157 46 ;)
 (local.set $_M0L8seen__hiS93)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 158 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1300
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1300)
  (i32.const 0))
 (local.set $_M0L6uniqueS94
  (local.get $_M0L3ptrS1300))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 159 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1299
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1299)
  (i32.const 0))
 (local.set $_M0L1tS95
  (local.get $_M0L3ptrS1299))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 160 2 ;)
 (loop $loop:114
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 160 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS632
    (i32.load
     (local.get $_M0L1tS95)))
   (i32.const 8))
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 160 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 161 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1298
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1298)
     (i32.const 0))
    (local.set $_M0L2loS96
     (local.get $_M0L3ptrS1298))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 161 20 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1297
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1297)
     (i32.const 0))
    (local.set $_M0L2hiS97
     (local.get $_M0L3ptrS1297))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 162 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1296
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1296)
     (i32.const 0))
    (local.set $_M0L1rS98
     (local.get $_M0L3ptrS1296))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 163 4 ;)
    (loop $loop:110
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 163 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS633
       (i32.load
        (local.get $_M0L1rS98)))
      (local.get $_M0L1hS99))
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 163 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 164 6 ;)
       (call $moonbit.store_object_meta
        (local.tee $_M0L3ptrS1295
         (call $moonbit.gc.malloc
          (i32.const 4)))
        (i32.const 524288))
       (i32.store
        (local.get $_M0L3ptrS1295)
        (i32.const 0))
       (local.set $_M0L1cS100
        (local.get $_M0L3ptrS1295))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 165 6 ;)
       (loop $loop:109
        (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 165 12 ;)
        (i32.lt_s
         (local.tee $_M0L3valS634
          (i32.load
           (local.get $_M0L1cS100)))
         (local.get $_M0L1wS101))
        (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 165 17 ;)
        (if
         (then
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 166 8 ;)
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 166 20 ;)
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 166 25 ;)
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 166 25 ;)
          (i32.mul
           (local.tee $_M0L3valS680
            (i32.load
             (local.get $_M0L1rS98)))
           (local.get $_M0L1wS101))
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 166 30 ;)
          (local.set $_M0L6_2atmpS678)
          (local.set $_M0L3valS679
           (i32.load
            (local.get $_M0L1cS100)))
          (i32.add
           (local.get $_M0L6_2atmpS678)
           (local.get $_M0L3valS679))
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 166 34 ;)
          (local.set $_M0L6_2atmpS677)
          (call $_M0MPC15array5Array2atGiE
           (local.get $_M0L4gridS103)
           (local.get $_M0L6_2atmpS677))
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 166 35 ;)
          (local.set $_M0L5colorS102)
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 167 8 ;)
          (block $outer/1284 (result i32)
           (block $join:104
            (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 167 23 ;)
            (local.set $_M0L7_2abindS108
             (i32.load
              (local.get $_M0L1tS95)))
            (block $switch_int/1285
             (block $switch_default/1286
              (block $switch_int_7/1294
               (block $switch_int_6/1293
                (block $switch_int_5/1292
                 (block $switch_int_4/1291
                  (block $switch_int_3/1290
                   (block $switch_int_2/1289
                    (block $switch_int_1/1288
                     (block $switch_int_0/1287
                      (local.get $_M0L7_2abindS108)
                      (br_table
                       $switch_int_0/1287
                       $switch_int_1/1288
                       $switch_int_2/1289
                       $switch_int_3/1290
                       $switch_int_4/1291
                       $switch_int_5/1292
                       $switch_int_6/1293
                       $switch_int_7/1294
                       $switch_default/1286
                       ))
                     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 168 15 ;)
                     (local.set $_M0L3valS643
                      (i32.load
                       (local.get $_M0L1rS98)))
                     (local.set $_M0L3valS644
                      (i32.load
                       (local.get $_M0L1cS100)))
                     (local.get $_M0L3valS643)
                     (local.set $_M0L2tcS106
                      (local.get $_M0L3valS644))
                     (local.set $_M0L2trS105)
                     (br $join:104))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 169 15 ;)
                    (local.set $_M0L3valS645
                     (i32.load
                      (local.get $_M0L1cS100)))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 169 23 ;)
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 169 23 ;)
                    (i32.sub
                     (local.get $_M0L1hS99)
                     (i32.const 1))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 169 26 ;)
                    (local.set $_M0L6_2atmpS647)
                    (local.set $_M0L3valS648
                     (i32.load
                      (local.get $_M0L1rS98)))
                    (i32.sub
                     (local.get $_M0L6_2atmpS647)
                     (local.get $_M0L3valS648))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 169 28 ;)
                    (local.set $_M0L6_2atmpS646)
                    (local.get $_M0L3valS645)
                    (local.set $_M0L2tcS106
                     (local.get $_M0L6_2atmpS646))
                    (local.set $_M0L2trS105)
                    (br $join:104))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 170 15 ;)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 170 16 ;)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 170 16 ;)
                   (i32.sub
                    (local.get $_M0L1hS99)
                    (i32.const 1))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 170 19 ;)
                   (local.set $_M0L6_2atmpS653)
                   (local.set $_M0L3valS654
                    (i32.load
                     (local.get $_M0L1rS98)))
                   (i32.sub
                    (local.get $_M0L6_2atmpS653)
                    (local.get $_M0L3valS654))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 170 21 ;)
                   (local.set $_M0L6_2atmpS649)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 170 23 ;)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 170 23 ;)
                   (i32.sub
                    (local.get $_M0L1wS101)
                    (i32.const 1))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 170 26 ;)
                   (local.set $_M0L6_2atmpS651)
                   (local.set $_M0L3valS652
                    (i32.load
                     (local.get $_M0L1cS100)))
                   (i32.sub
                    (local.get $_M0L6_2atmpS651)
                    (local.get $_M0L3valS652))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 170 28 ;)
                   (local.set $_M0L6_2atmpS650)
                   (local.get $_M0L6_2atmpS649)
                   (local.set $_M0L2tcS106
                    (local.get $_M0L6_2atmpS650))
                   (local.set $_M0L2trS105)
                   (br $join:104))
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 171 15 ;)
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 171 16 ;)
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 171 16 ;)
                  (i32.sub
                   (local.get $_M0L1wS101)
                   (i32.const 1))
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 171 19 ;)
                  (local.set $_M0L6_2atmpS657)
                  (local.set $_M0L3valS658
                   (i32.load
                    (local.get $_M0L1cS100)))
                  (i32.sub
                   (local.get $_M0L6_2atmpS657)
                   (local.get $_M0L3valS658))
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 171 21 ;)
                  (local.set $_M0L6_2atmpS655)
                  (local.set $_M0L3valS656
                   (i32.load
                    (local.get $_M0L1rS98)))
                  (local.get $_M0L6_2atmpS655)
                  (local.set $_M0L2tcS106
                   (local.get $_M0L3valS656))
                  (local.set $_M0L2trS105)
                  (br $join:104))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 172 15 ;)
                 (local.set $_M0L3valS659
                  (i32.load
                   (local.get $_M0L1rS98)))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 172 23 ;)
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 172 23 ;)
                 (i32.sub
                  (local.get $_M0L1wS101)
                  (i32.const 1))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 172 26 ;)
                 (local.set $_M0L6_2atmpS661)
                 (local.set $_M0L3valS662
                  (i32.load
                   (local.get $_M0L1cS100)))
                 (i32.sub
                  (local.get $_M0L6_2atmpS661)
                  (local.get $_M0L3valS662))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 172 28 ;)
                 (local.set $_M0L6_2atmpS660)
                 (local.get $_M0L3valS659)
                 (local.set $_M0L2tcS106
                  (local.get $_M0L6_2atmpS660))
                 (local.set $_M0L2trS105)
                 (br $join:104))
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 173 15 ;)
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 173 16 ;)
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 173 16 ;)
                (i32.sub
                 (local.get $_M0L1hS99)
                 (i32.const 1))
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 173 19 ;)
                (local.set $_M0L6_2atmpS665)
                (local.set $_M0L3valS666
                 (i32.load
                  (local.get $_M0L1rS98)))
                (i32.sub
                 (local.get $_M0L6_2atmpS665)
                 (local.get $_M0L3valS666))
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 173 21 ;)
                (local.set $_M0L6_2atmpS663)
                (local.set $_M0L3valS664
                 (i32.load
                  (local.get $_M0L1cS100)))
                (local.get $_M0L6_2atmpS663)
                (local.set $_M0L2tcS106
                 (local.get $_M0L3valS664))
                (local.set $_M0L2trS105)
                (br $join:104))
               (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 174 15 ;)
               (local.set $_M0L3valS667
                (i32.load
                 (local.get $_M0L1cS100)))
               (local.set $_M0L3valS668
                (i32.load
                 (local.get $_M0L1rS98)))
               (local.get $_M0L3valS667)
               (local.set $_M0L2tcS106
                (local.get $_M0L3valS668))
               (local.set $_M0L2trS105)
               (br $join:104))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 175 15 ;)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 175 16 ;)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 175 16 ;)
              (i32.sub
               (local.get $_M0L1wS101)
               (i32.const 1))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 175 19 ;)
              (local.set $_M0L6_2atmpS673)
              (local.set $_M0L3valS674
               (i32.load
                (local.get $_M0L1cS100)))
              (i32.sub
               (local.get $_M0L6_2atmpS673)
               (local.get $_M0L3valS674))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 175 21 ;)
              (local.set $_M0L6_2atmpS669)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 175 23 ;)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 175 23 ;)
              (i32.sub
               (local.get $_M0L1hS99)
               (i32.const 1))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 175 26 ;)
              (local.set $_M0L6_2atmpS671)
              (local.set $_M0L3valS672
               (i32.load
                (local.get $_M0L1rS98)))
              (i32.sub
               (local.get $_M0L6_2atmpS671)
               (local.get $_M0L3valS672))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 175 28 ;)
              (local.set $_M0L6_2atmpS670)
              (local.get $_M0L6_2atmpS669)
              (local.set $_M0L2tcS106
               (local.get $_M0L6_2atmpS670))
              (local.set $_M0L2trS105)
              (br $join:104))
             (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 176 15 ;)
             (local.set $_M0L3valS675
              (i32.load
               (local.get $_M0L1rS98)))
             (local.set $_M0L3valS676
              (i32.load
               (local.get $_M0L1cS100)))
             (local.get $_M0L3valS675)
             (local.set $_M0L2tcS106
              (local.get $_M0L3valS676))
             (local.set $_M0L2trS105)
             (br $join:104))
            (i32.const 0)
            (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 177 9 ;)
            (br $outer/1284))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 178 8 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 178 18 ;)
           (call $_M0FP48moonarc34rhae3src4rhae7zt__idx
            (local.get $_M0L2trS105)
            (local.get $_M0L2tcS106)
            (local.get $_M0L5colorS102))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 178 39 ;)
           (local.set $_M0L3idxS107)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 8 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 13 ;)
           (local.set $_M0L3valS636
            (i32.load
             (local.get $_M0L2loS96)))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 18 ;)
           (call $_M0MPC15array5Array2atGiE
            (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)
            (local.get $_M0L3idxS107))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 28 ;)
           (local.set $_M0L6_2atmpS637)
           (i32.xor
            (local.get $_M0L3valS636)
            (local.get $_M0L6_2atmpS637))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 28 ;)
           (local.set $_M0L6_2atmpS635)
           (i32.store
            (local.get $_M0L2loS96)
            (local.get $_M0L6_2atmpS635))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 28 ;)
           (drop)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 30 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 35 ;)
           (local.set $_M0L3valS639
            (i32.load
             (local.get $_M0L2hiS97)))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 40 ;)
           (call $_M0MPC15array5Array2atGiE
            (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)
            (local.get $_M0L3idxS107))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 50 ;)
           (local.set $_M0L6_2atmpS640)
           (i32.xor
            (local.get $_M0L3valS639)
            (local.get $_M0L6_2atmpS640))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 50 ;)
           (local.set $_M0L6_2atmpS638)
           (i32.store
            (local.get $_M0L2hiS97)
            (local.get $_M0L6_2atmpS638))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 179 50 ;)
           (drop)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 180 8 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 180 12 ;)
           (i32.add
            (local.tee $_M0L3valS642
             (i32.load
              (local.get $_M0L1cS100)))
            (i32.const 1))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 180 17 ;)
           (local.set $_M0L6_2atmpS641)
           (i32.store
            (local.get $_M0L1cS100)
            (local.get $_M0L6_2atmpS641))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 180 17 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 180 17 ;))
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 180 17 ;)
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 180 17 ;)
          (drop)
          (br $loop:109))
         (else
          (call $moonbit.decref
           (local.get $_M0L1cS100)))))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 181 7 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 182 6 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 182 10 ;)
       (i32.add
        (local.tee $_M0L3valS682
         (i32.load
          (local.get $_M0L1rS98)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 182 15 ;)
       (local.set $_M0L6_2atmpS681)
       (i32.store
        (local.get $_M0L1rS98)
        (local.get $_M0L6_2atmpS681))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 182 15 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 182 15 ;)
       (drop)
       (br $loop:110))
      (else
       (call $moonbit.decref
        (local.get $_M0L1rS98)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 183 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 184 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1283
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1283)
     (i32.const 1))
    (local.set $_M0L7is__newS111
     (local.get $_M0L3ptrS1283))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 185 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1282
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1282)
     (i32.const 0))
    (local.set $_M0L1kS112
     (local.get $_M0L3ptrS1282))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 186 4 ;)
    (loop $loop:113
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 186 10 ;)
     (local.set $_M0L3valS683
      (i32.load
       (local.get $_M0L1kS112)))
     (local.set $_M0L3valS684
      (i32.load
       (local.get $_M0L6uniqueS94)))
     (i32.lt_s
      (local.get $_M0L3valS683)
      (local.get $_M0L3valS684))
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 186 20 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 6 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 9 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 9 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 9 ;)
       (local.set $_M0L3valS690
        (i32.load
         (local.get $_M0L1kS112)))
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L8seen__loS92)
        (local.get $_M0L3valS690))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 19 ;)
       (local.set $_M0L6_2atmpS688)
       (local.set $_M0L3valS689
        (i32.load
         (local.get $_M0L2loS96)))
       (i32.eq
        (local.get $_M0L6_2atmpS688)
        (local.get $_M0L3valS689))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 25 ;)
       (if (result i32)
        (then
         (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 29 ;)
         (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 29 ;)
         (local.set $_M0L3valS687
          (i32.load
           (local.get $_M0L1kS112)))
         (call $_M0MPC15array5Array2atGiE
          (local.get $_M0L8seen__hiS93)
          (local.get $_M0L3valS687))
         (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 39 ;)
         (local.set $_M0L6_2atmpS685)
         (local.set $_M0L3valS686
          (i32.load
           (local.get $_M0L2hiS97)))
         (i32.eq
          (local.get $_M0L6_2atmpS685)
          (local.get $_M0L3valS686))
         (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 45 ;))
        (else
         (i32.const 0)))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 45 ;)
       (if
        (then
         (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 48 ;)
         (i32.store
          (local.get $_M0L7is__newS111)
          (i32.const 0))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 62 ;)
         (drop))
        (else))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 187 64 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 188 6 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 188 10 ;)
       (i32.add
        (local.tee $_M0L3valS692
         (i32.load
          (local.get $_M0L1kS112)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 188 15 ;)
       (local.set $_M0L6_2atmpS691)
       (i32.store
        (local.get $_M0L1kS112)
        (local.get $_M0L6_2atmpS691))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 188 15 ;)
       (drop)
       (br $loop:113))
      (else
       (call $moonbit.decref
        (local.get $_M0L1kS112)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 189 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 190 4 ;)
    (i32.load
     (local.get $_M0L7is__newS111))
    (call $moonbit.decref
     (local.get $_M0L7is__newS111))
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 191 6 ;)
      (local.set $_M0L3valS693
       (i32.load
        (local.get $_M0L6uniqueS94)))
      (i32.load
       (local.get $_M0L2loS96))
      (call $moonbit.decref
       (local.get $_M0L2loS96))
      (local.set $_M0L3valS694)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L8seen__loS92)
       (local.get $_M0L3valS693)
       (local.get $_M0L3valS694))
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 191 26 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 191 28 ;)
      (local.set $_M0L3valS695
       (i32.load
        (local.get $_M0L6uniqueS94)))
      (i32.load
       (local.get $_M0L2hiS97))
      (call $moonbit.decref
       (local.get $_M0L2hiS97))
      (local.set $_M0L3valS696)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L8seen__hiS93)
       (local.get $_M0L3valS695)
       (local.get $_M0L3valS696))
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 191 48 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 192 6 ;)
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 192 15 ;)
      (i32.add
       (local.tee $_M0L3valS698
        (i32.load
         (local.get $_M0L6uniqueS94)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 192 25 ;)
      (local.set $_M0L6_2atmpS697)
      (i32.store
       (local.get $_M0L6uniqueS94)
       (local.get $_M0L6_2atmpS697))
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 192 25 ;)
      (drop))
     (else
      (call $moonbit.decref
       (local.get $_M0L2hiS97))
      (call $moonbit.decref
       (local.get $_M0L2loS96))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 193 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 194 4 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 194 8 ;)
    (i32.add
     (local.tee $_M0L3valS700
      (i32.load
       (local.get $_M0L1tS95)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 194 13 ;)
    (local.set $_M0L6_2atmpS699)
    (i32.store
     (local.get $_M0L1tS95)
     (local.get $_M0L6_2atmpS699))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 194 13 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 194 13 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 194 13 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 194 13 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 194 13 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 194 13 ;)
    (drop)
    (br $loop:114))
   (else
    (call $moonbit.decref
     (local.get $_M0L1tS95))
    (call $moonbit.decref
     (local.get $_M0L8seen__hiS93))
    (call $moonbit.decref
     (local.get $_M0L8seen__loS92)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 195 3 ;)
 (drop)
 (i32.load
  (local.get $_M0L6uniqueS94))
 (call $moonbit.decref
  (local.get $_M0L6uniqueS94))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 196 8 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 196 8 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 196 8 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 196 8 ;))
(func $_M0FP48moonarc34rhae3src4rhae14visited__reset (result i32)
 (local $_M0L1iS90 i32)
 (local $_M0L3valS628 i32)
 (local $_M0L3valS629 i32)
 (local $_M0L6_2atmpS630 i32)
 (local $_M0L3valS631 i32)
 (local $_M0L3ptrS1301 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1301
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1301)
  (i32.const 0))
 (local.set $_M0L1iS90
  (local.get $_M0L3ptrS1301))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 17 ;)
 (loop $loop:91
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 23 ;)
  (i32.lt_s
   (local.tee $_M0L3valS628
    (i32.load
     (local.get $_M0L1iS90)))
   (i32.const 32))
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 29 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 32 ;)
    (local.set $_M0L3valS629
     (i32.load
      (local.get $_M0L1iS90)))
    (call $_M0MPC15array5Array3setGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)
     (local.get $_M0L3valS629)
     (i32.const 0))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 51 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 53 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 57 ;)
    (i32.add
     (local.tee $_M0L3valS631
      (i32.load
       (local.get $_M0L1iS90)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 62 ;)
    (local.set $_M0L6_2atmpS630)
    (i32.store
     (local.get $_M0L1iS90)
     (local.get $_M0L6_2atmpS630))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 62 ;)
    (drop)
    (br $loop:91))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS90)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 64 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 64 ;))
(func $_M0FP48moonarc34rhae3src4rhae13visited__mark (param $_M0L2loS88 i32) (param $_M0L2hiS89 i32) (result i32)
 (local $_M0L1sS87 i32)
 (local $_M0L6_2atmpS622 i32)
 (local $_M0L6_2atmpS623 i32)
 (local $_M0L6_2atmpS624 i32)
 (local $_M0L6_2atmpS625 i32)
 (local $_M0L6_2atmpS626 i32)
 (local $_M0L6_2atmpS627 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 144 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 144 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae8tt__slot
  (local.get $_M0L2loS88)
  (local.get $_M0L2hiS89))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 144 25 ;)
 (local.set $_M0L1sS87)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 15 ;)
 (i32.div_s
  (local.get $_M0L1sS87)
  (i32.const 32))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 21 ;)
 (local.set $_M0L6_2atmpS622)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 25 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 25 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 38 ;)
 (i32.div_s
  (local.get $_M0L1sS87)
  (i32.const 32))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 44 ;)
 (local.set $_M0L6_2atmpS627)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)
  (local.get $_M0L6_2atmpS627))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 45 ;)
 (local.set $_M0L6_2atmpS624)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 49 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 55 ;)
 (i32.rem_s
  (local.get $_M0L1sS87)
  (i32.const 32))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 61 ;)
 (local.set $_M0L6_2atmpS626)
 (i32.shl
  (i32.const 1)
  (local.get $_M0L6_2atmpS626))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 62 ;)
 (local.set $_M0L6_2atmpS625)
 (i32.or
  (local.get $_M0L6_2atmpS624)
  (local.get $_M0L6_2atmpS625))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 63 ;)
 (local.set $_M0L6_2atmpS623)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)
  (local.get $_M0L6_2atmpS622)
  (local.get $_M0L6_2atmpS623))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 63 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 63 ;))
(func $_M0FP48moonarc34rhae3src4rhae14visited__check (param $_M0L2loS85 i32) (param $_M0L2hiS86 i32) (result i32)
 (local $_M0L1sS84 i32)
 (local $_M0L6_2atmpS617 i32)
 (local $_M0L6_2atmpS618 i32)
 (local $_M0L6_2atmpS619 i32)
 (local $_M0L6_2atmpS620 i32)
 (local $_M0L6_2atmpS621 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 139 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 139 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae8tt__slot
  (local.get $_M0L2loS85)
  (local.get $_M0L2hiS86))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 139 25 ;)
 (local.set $_M0L1sS84)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 4 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 4 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 17 ;)
 (i32.div_s
  (local.get $_M0L1sS84)
  (i32.const 32))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 23 ;)
 (local.set $_M0L6_2atmpS621)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)
  (local.get $_M0L6_2atmpS621))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 24 ;)
 (local.set $_M0L6_2atmpS619)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 29 ;)
 (i32.rem_s
  (local.get $_M0L1sS84)
  (i32.const 32))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 35 ;)
 (local.set $_M0L6_2atmpS620)
 (i32.shr_s
  (local.get $_M0L6_2atmpS619)
  (local.get $_M0L6_2atmpS620))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 36 ;)
 (local.tee $_M0L6_2atmpS618)
 (i32.const 1)
 (i32.and)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 41 ;)
 (local.tee $_M0L6_2atmpS617)
 (i32.const 1)
 (i32.eq)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 47 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 47 ;))
(func $_M0FP48moonarc34rhae3src4rhae9tt__store (param $_M0L2loS79 i32) (param $_M0L2hiS80 i32) (param $_M0L12best__actionS82 i32) (param $_M0L5scoreS83 i32) (result i32)
 (local $_M0L1sS78 i32)
 (local $_M0L1bS81 i32)
 (local $_M0L6_2atmpS614 i32)
 (local $_M0L6_2atmpS615 i32)
 (local $_M0L6_2atmpS616 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 130 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 130 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae8tt__slot
  (local.get $_M0L2loS79)
  (local.get $_M0L2hiS80))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 130 25 ;)
 (local.set $_M0L1sS78)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 130 27 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 130 35 ;)
 (i32.mul
  (local.get $_M0L1sS78)
  (global.get $_M0FP48moonarc34rhae3src4rhae10tt__stride))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 130 48 ;)
 (local.set $_M0L1bS81)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 131 2 ;)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
  (local.get $_M0L1bS81)
  (local.get $_M0L2loS79))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 131 22 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 131 24 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 131 37 ;)
 (i32.add
  (local.get $_M0L1bS81)
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 131 40 ;)
 (local.set $_M0L6_2atmpS614)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
  (local.get $_M0L6_2atmpS614)
  (local.get $_M0L2hiS80))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 131 46 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 15 ;)
 (i32.add
  (local.get $_M0L1bS81)
  (i32.const 2))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 18 ;)
 (local.set $_M0L6_2atmpS615)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
  (local.get $_M0L6_2atmpS615)
  (local.get $_M0L12best__actionS82))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 33 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 35 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 48 ;)
 (i32.add
  (local.get $_M0L1bS81)
  (i32.const 3))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 51 ;)
 (local.set $_M0L6_2atmpS616)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
  (local.get $_M0L6_2atmpS616)
  (local.get $_M0L5scoreS83))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 60 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 60 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 60 ;))
(func $_M0FP48moonarc34rhae3src4rhae10tt__lookup (param $_M0L2loS75 i32) (param $_M0L2hiS76 i32) (result i32)
 (local $_M0L1sS74 i32)
 (local $_M0L1bS77 i32)
 (local $_M0L6_2atmpS607 i32)
 (local $_M0L6_2atmpS608 i32)
 (local $_M0L6_2atmpS609 i32)
 (local $_M0L6_2atmpS610 i32)
 (local $_M0L6_2atmpS611 i32)
 (local $_M0L6_2atmpS612 i32)
 (local $_M0L6_2atmpS613 i32)
 (local $_M0L3ptrS1302 i32)
 (local $_M0L3ptrS1303 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 121 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 121 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae8tt__slot
  (local.get $_M0L2loS75)
  (local.get $_M0L2hiS76))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 121 25 ;)
 (local.set $_M0L1sS74)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 121 27 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 121 35 ;)
 (i32.mul
  (local.get $_M0L1sS74)
  (global.get $_M0FP48moonarc34rhae3src4rhae10tt__stride))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 121 48 ;)
 (local.set $_M0L1bS77)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 5 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 5 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 5 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
  (local.get $_M0L1bS77))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 20 ;)
 (local.tee $_M0L6_2atmpS609)
 (local.get $_M0L2loS75)
 (i32.eq)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 26 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 30 ;)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 30 ;)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 43 ;)
   (i32.add
    (local.get $_M0L1bS77)
    (i32.const 1))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 46 ;)
   (local.set $_M0L6_2atmpS608)
   (call $_M0MPC15array5Array2atGiE
    (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
    (local.get $_M0L6_2atmpS608))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 47 ;)
   (local.tee $_M0L6_2atmpS607)
   (local.get $_M0L2hiS76)
   (i32.eq)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 53 ;))
  (else
   (i32.const 0)))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 53 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 4 ;)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 11 ;)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 24 ;)
   (i32.add
    (local.get $_M0L1bS77)
    (i32.const 2))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 27 ;)
   (local.set $_M0L6_2atmpS613)
   (call $_M0MPC15array5Array2atGiE
    (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
    (local.get $_M0L6_2atmpS613))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 28 ;)
   (local.set $_M0L6_2atmpS610)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 30 ;)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 43 ;)
   (i32.add
    (local.get $_M0L1bS77)
    (i32.const 3))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 46 ;)
   (local.set $_M0L6_2atmpS612)
   (call $_M0MPC15array5Array2atGiE
    (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
    (local.get $_M0L6_2atmpS612))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 47 ;)
   (local.set $_M0L6_2atmpS611)
   (call $moonbit.store_object_meta
    (local.tee $_M0L3ptrS1302
     (call $moonbit.gc.malloc
      (i32.const 12)))
    (i32.const 1572864))
   (i32.store offset=8
    (local.get $_M0L3ptrS1302)
    (local.get $_M0L6_2atmpS611))
   (i32.store offset=4
    (local.get $_M0L3ptrS1302)
    (local.get $_M0L6_2atmpS610))
   (i32.store
    (local.get $_M0L3ptrS1302)
    (i32.const 1))
   (local.get $_M0L3ptrS1302)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 48 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 125 4 ;)
   (call $moonbit.store_object_meta
    (local.tee $_M0L3ptrS1303
     (call $moonbit.gc.malloc
      (i32.const 12)))
    (i32.const 1572864))
   (i32.store offset=8
    (local.get $_M0L3ptrS1303)
    (i32.const 0))
   (i32.store offset=4
    (local.get $_M0L3ptrS1303)
    (i32.const 0))
   (i32.store
    (local.get $_M0L3ptrS1303)
    (i32.const 0))
   (local.get $_M0L3ptrS1303)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 125 17 ;)))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 126 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 126 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 126 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae8tt__slot (param $_M0L2loS72 i32) (param $_M0L2hiS73 i32) (result i32)
 (local $_M0L6_2atmpS605 i32)
 (local $_M0L6_2atmpS606 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 117 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 117 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 117 4 ;)
 (i32.xor
  (local.get $_M0L2loS72)
  (local.get $_M0L2hiS73))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 117 11 ;)
 (local.tee $_M0L6_2atmpS606)
 (i32.const -1640531527)
 (i32.mul)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 117 25 ;)
 (local.tee $_M0L6_2atmpS605)
 (global.get $_M0FP48moonarc34rhae3src4rhae8tt__mask)
 (i32.and)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 117 36 ;))
(func $_M0FP48moonarc34rhae3src4rhae15canonical__hash (param $_M0L4gridS63 i32) (param $_M0L1hS59 i32) (param $_M0L1wS61 i32) (result i32)
 (local $_M0L8best__loS53 i32)
 (local $_M0L8best__hiS54 i32)
 (local $_M0L1tS55 i32)
 (local $_M0L2loS56 i32)
 (local $_M0L2hiS57 i32)
 (local $_M0L1rS58 i32)
 (local $_M0L1cS60 i32)
 (local $_M0L5colorS62 i32)
 (local $_M0L2trS65 i32)
 (local $_M0L2tcS66 i32)
 (local $_M0L3idxS67 i32)
 (local $_M0L7_2abindS68 i32)
 (local $_M0L3valS542 i32)
 (local $_M0L3valS543 i32)
 (local $_M0L3valS544 i32)
 (local $_M0L6_2atmpS545 i32)
 (local $_M0L3valS546 i32)
 (local $_M0L6_2atmpS547 i32)
 (local $_M0L6_2atmpS548 i32)
 (local $_M0L3valS549 i32)
 (local $_M0L6_2atmpS550 i32)
 (local $_M0L6_2atmpS551 i32)
 (local $_M0L3valS552 i32)
 (local $_M0L3valS553 i32)
 (local $_M0L3valS554 i32)
 (local $_M0L3valS555 i32)
 (local $_M0L6_2atmpS556 i32)
 (local $_M0L6_2atmpS557 i32)
 (local $_M0L3valS558 i32)
 (local $_M0L6_2atmpS559 i32)
 (local $_M0L6_2atmpS560 i32)
 (local $_M0L6_2atmpS561 i32)
 (local $_M0L3valS562 i32)
 (local $_M0L6_2atmpS563 i32)
 (local $_M0L3valS564 i32)
 (local $_M0L6_2atmpS565 i32)
 (local $_M0L3valS566 i32)
 (local $_M0L6_2atmpS567 i32)
 (local $_M0L3valS568 i32)
 (local $_M0L3valS569 i32)
 (local $_M0L6_2atmpS570 i32)
 (local $_M0L6_2atmpS571 i32)
 (local $_M0L3valS572 i32)
 (local $_M0L6_2atmpS573 i32)
 (local $_M0L3valS574 i32)
 (local $_M0L6_2atmpS575 i32)
 (local $_M0L3valS576 i32)
 (local $_M0L3valS577 i32)
 (local $_M0L3valS578 i32)
 (local $_M0L6_2atmpS579 i32)
 (local $_M0L6_2atmpS580 i32)
 (local $_M0L6_2atmpS581 i32)
 (local $_M0L3valS582 i32)
 (local $_M0L6_2atmpS583 i32)
 (local $_M0L3valS584 i32)
 (local $_M0L3valS585 i32)
 (local $_M0L3valS586 i32)
 (local $_M0L6_2atmpS587 i32)
 (local $_M0L6_2atmpS588 i32)
 (local $_M0L3valS589 i32)
 (local $_M0L3valS590 i32)
 (local $_M0L6_2atmpS591 i32)
 (local $_M0L3valS592 i32)
 (local $_M0L3valS593 i32)
 (local $_M0L3valS594 i32)
 (local $_M0L3valS595 i32)
 (local $_M0L3valS596 i32)
 (local $_M0L3valS597 i32)
 (local $_M0L3valS598 i32)
 (local $_M0L3valS599 i32)
 (local $_M0L3valS600 i32)
 (local $_M0L6_2atmpS601 i32)
 (local $_M0L3valS602 i32)
 (local $_M0L3valS603 i32)
 (local $_M0L3valS604 i32)
 (local $_M0L3ptrS1304 i32)
 (local $_M0L3ptrS1316 i32)
 (local $_M0L3ptrS1317 i32)
 (local $_M0L3ptrS1318 i32)
 (local $_M0L3ptrS1319 i32)
 (local $_M0L3ptrS1320 i32)
 (local $_M0L3ptrS1321 i32)
 (local $_M0L3ptrS1322 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 75 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 75 16 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 76 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1322
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1322)
  (i32.const 2147483647))
 (local.set $_M0L8best__loS53
  (local.get $_M0L3ptrS1322))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 76 32 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1321
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1321)
  (i32.const 2147483647))
 (local.set $_M0L8best__hiS54
  (local.get $_M0L3ptrS1321))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 77 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1320
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1320)
  (i32.const 0))
 (local.set $_M0L1tS55
  (local.get $_M0L3ptrS1320))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 78 2 ;)
 (loop $loop:71
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 78 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS542
    (i32.load
     (local.get $_M0L1tS55)))
   (i32.const 8))
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 78 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 79 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1319
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1319)
     (i32.const 0))
    (local.set $_M0L2loS56
     (local.get $_M0L3ptrS1319))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 79 20 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1318
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1318)
     (i32.const 0))
    (local.set $_M0L2hiS57
     (local.get $_M0L3ptrS1318))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 80 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1317
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1317)
     (i32.const 0))
    (local.set $_M0L1rS58
     (local.get $_M0L3ptrS1317))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 81 4 ;)
    (loop $loop:70
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 81 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS543
       (i32.load
        (local.get $_M0L1rS58)))
      (local.get $_M0L1hS59))
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 81 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 82 6 ;)
       (call $moonbit.store_object_meta
        (local.tee $_M0L3ptrS1316
         (call $moonbit.gc.malloc
          (i32.const 4)))
        (i32.const 524288))
       (i32.store
        (local.get $_M0L3ptrS1316)
        (i32.const 0))
       (local.set $_M0L1cS60
        (local.get $_M0L3ptrS1316))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 83 6 ;)
       (loop $loop:69
        (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 83 12 ;)
        (i32.lt_s
         (local.tee $_M0L3valS544
          (i32.load
           (local.get $_M0L1cS60)))
         (local.get $_M0L1wS61))
        (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 83 17 ;)
        (if
         (then
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 84 8 ;)
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 84 20 ;)
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 84 25 ;)
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 84 25 ;)
          (i32.mul
           (local.tee $_M0L3valS590
            (i32.load
             (local.get $_M0L1rS58)))
           (local.get $_M0L1wS61))
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 84 30 ;)
          (local.set $_M0L6_2atmpS588)
          (local.set $_M0L3valS589
           (i32.load
            (local.get $_M0L1cS60)))
          (i32.add
           (local.get $_M0L6_2atmpS588)
           (local.get $_M0L3valS589))
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 84 34 ;)
          (local.set $_M0L6_2atmpS587)
          (call $_M0MPC15array5Array2atGiE
           (local.get $_M0L4gridS63)
           (local.get $_M0L6_2atmpS587))
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 84 35 ;)
          (local.set $_M0L5colorS62)
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 85 8 ;)
          (block $outer/1305 (result i32)
           (block $join:64
            (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 85 23 ;)
            (local.set $_M0L7_2abindS68
             (i32.load
              (local.get $_M0L1tS55)))
            (block $switch_int/1306
             (block $switch_default/1307
              (block $switch_int_7/1315
               (block $switch_int_6/1314
                (block $switch_int_5/1313
                 (block $switch_int_4/1312
                  (block $switch_int_3/1311
                   (block $switch_int_2/1310
                    (block $switch_int_1/1309
                     (block $switch_int_0/1308
                      (local.get $_M0L7_2abindS68)
                      (br_table
                       $switch_int_0/1308
                       $switch_int_1/1309
                       $switch_int_2/1310
                       $switch_int_3/1311
                       $switch_int_4/1312
                       $switch_int_5/1313
                       $switch_int_6/1314
                       $switch_int_7/1315
                       $switch_default/1307
                       ))
                     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 86 15 ;)
                     (local.set $_M0L3valS553
                      (i32.load
                       (local.get $_M0L1rS58)))
                     (local.set $_M0L3valS554
                      (i32.load
                       (local.get $_M0L1cS60)))
                     (local.get $_M0L3valS553)
                     (local.set $_M0L2tcS66
                      (local.get $_M0L3valS554))
                     (local.set $_M0L2trS65)
                     (br $join:64))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 87 15 ;)
                    (local.set $_M0L3valS555
                     (i32.load
                      (local.get $_M0L1cS60)))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 87 23 ;)
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 87 23 ;)
                    (i32.sub
                     (local.get $_M0L1hS59)
                     (i32.const 1))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 87 26 ;)
                    (local.set $_M0L6_2atmpS557)
                    (local.set $_M0L3valS558
                     (i32.load
                      (local.get $_M0L1rS58)))
                    (i32.sub
                     (local.get $_M0L6_2atmpS557)
                     (local.get $_M0L3valS558))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 87 28 ;)
                    (local.set $_M0L6_2atmpS556)
                    (local.get $_M0L3valS555)
                    (local.set $_M0L2tcS66
                     (local.get $_M0L6_2atmpS556))
                    (local.set $_M0L2trS65)
                    (br $join:64))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 15 ;)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 16 ;)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 16 ;)
                   (i32.sub
                    (local.get $_M0L1hS59)
                    (i32.const 1))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 19 ;)
                   (local.set $_M0L6_2atmpS563)
                   (local.set $_M0L3valS564
                    (i32.load
                     (local.get $_M0L1rS58)))
                   (i32.sub
                    (local.get $_M0L6_2atmpS563)
                    (local.get $_M0L3valS564))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 21 ;)
                   (local.set $_M0L6_2atmpS559)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 23 ;)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 23 ;)
                   (i32.sub
                    (local.get $_M0L1wS61)
                    (i32.const 1))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 26 ;)
                   (local.set $_M0L6_2atmpS561)
                   (local.set $_M0L3valS562
                    (i32.load
                     (local.get $_M0L1cS60)))
                   (i32.sub
                    (local.get $_M0L6_2atmpS561)
                    (local.get $_M0L3valS562))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 28 ;)
                   (local.set $_M0L6_2atmpS560)
                   (local.get $_M0L6_2atmpS559)
                   (local.set $_M0L2tcS66
                    (local.get $_M0L6_2atmpS560))
                   (local.set $_M0L2trS65)
                   (br $join:64))
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 89 15 ;)
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 89 16 ;)
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 89 16 ;)
                  (i32.sub
                   (local.get $_M0L1wS61)
                   (i32.const 1))
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 89 19 ;)
                  (local.set $_M0L6_2atmpS567)
                  (local.set $_M0L3valS568
                   (i32.load
                    (local.get $_M0L1cS60)))
                  (i32.sub
                   (local.get $_M0L6_2atmpS567)
                   (local.get $_M0L3valS568))
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 89 21 ;)
                  (local.set $_M0L6_2atmpS565)
                  (local.set $_M0L3valS566
                   (i32.load
                    (local.get $_M0L1rS58)))
                  (local.get $_M0L6_2atmpS565)
                  (local.set $_M0L2tcS66
                   (local.get $_M0L3valS566))
                  (local.set $_M0L2trS65)
                  (br $join:64))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 90 15 ;)
                 (local.set $_M0L3valS569
                  (i32.load
                   (local.get $_M0L1rS58)))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 90 23 ;)
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 90 23 ;)
                 (i32.sub
                  (local.get $_M0L1wS61)
                  (i32.const 1))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 90 26 ;)
                 (local.set $_M0L6_2atmpS571)
                 (local.set $_M0L3valS572
                  (i32.load
                   (local.get $_M0L1cS60)))
                 (i32.sub
                  (local.get $_M0L6_2atmpS571)
                  (local.get $_M0L3valS572))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 90 28 ;)
                 (local.set $_M0L6_2atmpS570)
                 (local.get $_M0L3valS569)
                 (local.set $_M0L2tcS66
                  (local.get $_M0L6_2atmpS570))
                 (local.set $_M0L2trS65)
                 (br $join:64))
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 91 15 ;)
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 91 16 ;)
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 91 16 ;)
                (i32.sub
                 (local.get $_M0L1hS59)
                 (i32.const 1))
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 91 19 ;)
                (local.set $_M0L6_2atmpS575)
                (local.set $_M0L3valS576
                 (i32.load
                  (local.get $_M0L1rS58)))
                (i32.sub
                 (local.get $_M0L6_2atmpS575)
                 (local.get $_M0L3valS576))
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 91 21 ;)
                (local.set $_M0L6_2atmpS573)
                (local.set $_M0L3valS574
                 (i32.load
                  (local.get $_M0L1cS60)))
                (local.get $_M0L6_2atmpS573)
                (local.set $_M0L2tcS66
                 (local.get $_M0L3valS574))
                (local.set $_M0L2trS65)
                (br $join:64))
               (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 92 15 ;)
               (local.set $_M0L3valS577
                (i32.load
                 (local.get $_M0L1cS60)))
               (local.set $_M0L3valS578
                (i32.load
                 (local.get $_M0L1rS58)))
               (local.get $_M0L3valS577)
               (local.set $_M0L2tcS66
                (local.get $_M0L3valS578))
               (local.set $_M0L2trS65)
               (br $join:64))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 15 ;)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 16 ;)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 16 ;)
              (i32.sub
               (local.get $_M0L1wS61)
               (i32.const 1))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 19 ;)
              (local.set $_M0L6_2atmpS583)
              (local.set $_M0L3valS584
               (i32.load
                (local.get $_M0L1cS60)))
              (i32.sub
               (local.get $_M0L6_2atmpS583)
               (local.get $_M0L3valS584))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 21 ;)
              (local.set $_M0L6_2atmpS579)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 23 ;)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 23 ;)
              (i32.sub
               (local.get $_M0L1hS59)
               (i32.const 1))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 26 ;)
              (local.set $_M0L6_2atmpS581)
              (local.set $_M0L3valS582
               (i32.load
                (local.get $_M0L1rS58)))
              (i32.sub
               (local.get $_M0L6_2atmpS581)
               (local.get $_M0L3valS582))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 28 ;)
              (local.set $_M0L6_2atmpS580)
              (local.get $_M0L6_2atmpS579)
              (local.set $_M0L2tcS66
               (local.get $_M0L6_2atmpS580))
              (local.set $_M0L2trS65)
              (br $join:64))
             (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 94 15 ;)
             (local.set $_M0L3valS585
              (i32.load
               (local.get $_M0L1rS58)))
             (local.set $_M0L3valS586
              (i32.load
               (local.get $_M0L1cS60)))
             (local.get $_M0L3valS585)
             (local.set $_M0L2tcS66
              (local.get $_M0L3valS586))
             (local.set $_M0L2trS65)
             (br $join:64))
            (i32.const 0)
            (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 95 9 ;)
            (br $outer/1305))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 96 8 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 96 18 ;)
           (call $_M0FP48moonarc34rhae3src4rhae7zt__idx
            (local.get $_M0L2trS65)
            (local.get $_M0L2tcS66)
            (local.get $_M0L5colorS62))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 96 39 ;)
           (local.set $_M0L3idxS67)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 8 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 13 ;)
           (local.set $_M0L3valS546
            (i32.load
             (local.get $_M0L2loS56)))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 18 ;)
           (call $_M0MPC15array5Array2atGiE
            (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)
            (local.get $_M0L3idxS67))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 28 ;)
           (local.set $_M0L6_2atmpS547)
           (i32.xor
            (local.get $_M0L3valS546)
            (local.get $_M0L6_2atmpS547))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 28 ;)
           (local.set $_M0L6_2atmpS545)
           (i32.store
            (local.get $_M0L2loS56)
            (local.get $_M0L6_2atmpS545))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 28 ;)
           (drop)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 30 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 35 ;)
           (local.set $_M0L3valS549
            (i32.load
             (local.get $_M0L2hiS57)))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 40 ;)
           (call $_M0MPC15array5Array2atGiE
            (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)
            (local.get $_M0L3idxS67))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 50 ;)
           (local.set $_M0L6_2atmpS550)
           (i32.xor
            (local.get $_M0L3valS549)
            (local.get $_M0L6_2atmpS550))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 50 ;)
           (local.set $_M0L6_2atmpS548)
           (i32.store
            (local.get $_M0L2hiS57)
            (local.get $_M0L6_2atmpS548))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 50 ;)
           (drop)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 98 8 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 98 12 ;)
           (i32.add
            (local.tee $_M0L3valS552
             (i32.load
              (local.get $_M0L1cS60)))
            (i32.const 1))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 98 17 ;)
           (local.set $_M0L6_2atmpS551)
           (i32.store
            (local.get $_M0L1cS60)
            (local.get $_M0L6_2atmpS551))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 98 17 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 98 17 ;))
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 98 17 ;)
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 98 17 ;)
          (drop)
          (br $loop:69))
         (else
          (call $moonbit.decref
           (local.get $_M0L1cS60)))))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 99 7 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 100 6 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 100 10 ;)
       (i32.add
        (local.tee $_M0L3valS592
         (i32.load
          (local.get $_M0L1rS58)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 100 15 ;)
       (local.set $_M0L6_2atmpS591)
       (i32.store
        (local.get $_M0L1rS58)
        (local.get $_M0L6_2atmpS591))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 100 15 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 100 15 ;)
       (drop)
       (br $loop:70))
      (else
       (call $moonbit.decref
        (local.get $_M0L1rS58)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 101 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 4 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 7 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 7 ;)
    (local.set $_M0L3valS597
     (i32.load
      (local.get $_M0L2loS56)))
    (local.set $_M0L3valS598
     (i32.load
      (local.get $_M0L8best__loS53)))
    (i32.lt_s
     (local.get $_M0L3valS597)
     (local.get $_M0L3valS598))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 19 ;)
    (if (result i32)
     (then
      (i32.const 1))
     (else
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 24 ;)
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 24 ;)
      (local.set $_M0L3valS595
       (i32.load
        (local.get $_M0L2loS56)))
      (local.set $_M0L3valS596
       (i32.load
        (local.get $_M0L8best__loS53)))
      (i32.eq
       (local.get $_M0L3valS595)
       (local.get $_M0L3valS596))
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 37 ;)
      (if (result i32)
       (then
        (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 41 ;)
        (local.set $_M0L3valS593
         (i32.load
          (local.get $_M0L2hiS57)))
        (local.set $_M0L3valS594
         (i32.load
          (local.get $_M0L8best__hiS54)))
        (i32.lt_s
         (local.get $_M0L3valS593)
         (local.get $_M0L3valS594))
        (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 53 ;))
       (else
        (i32.const 0)))
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 53 ;)))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 54 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 103 6 ;)
      (i32.load
       (local.get $_M0L2loS56))
      (call $moonbit.decref
       (local.get $_M0L2loS56))
      (local.set $_M0L3valS599)
      (i32.store
       (local.get $_M0L8best__loS53)
       (local.get $_M0L3valS599))
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 103 18 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 103 20 ;)
      (i32.load
       (local.get $_M0L2hiS57))
      (call $moonbit.decref
       (local.get $_M0L2hiS57))
      (local.set $_M0L3valS600)
      (i32.store
       (local.get $_M0L8best__hiS54)
       (local.get $_M0L3valS600))
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 103 32 ;)
      (drop))
     (else
      (call $moonbit.decref
       (local.get $_M0L2hiS57))
      (call $moonbit.decref
       (local.get $_M0L2loS56))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 104 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 105 4 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 105 8 ;)
    (i32.add
     (local.tee $_M0L3valS602
      (i32.load
       (local.get $_M0L1tS55)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 105 13 ;)
    (local.set $_M0L6_2atmpS601)
    (i32.store
     (local.get $_M0L1tS55)
     (local.get $_M0L6_2atmpS601))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 105 13 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 105 13 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 105 13 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 105 13 ;)
    (drop)
    (br $loop:71))
   (else
    (call $moonbit.decref
     (local.get $_M0L1tS55)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 106 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 107 2 ;)
 (i32.load
  (local.get $_M0L8best__loS53))
 (call $moonbit.decref
  (local.get $_M0L8best__loS53))
 (local.set $_M0L3valS603)
 (i32.load
  (local.get $_M0L8best__hiS54))
 (call $moonbit.decref
  (local.get $_M0L8best__hiS54))
 (local.set $_M0L3valS604)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1304
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1304)
  (local.get $_M0L3valS604))
 (i32.store
  (local.get $_M0L3ptrS1304)
  (local.get $_M0L3valS603))
 (local.get $_M0L3ptrS1304)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 107 20 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 107 20 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 107 20 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 107 20 ;))
(func $_M0FP48moonarc34rhae3src4rhae21zobrist__update__cell (param $_M0L6lo__inS51 i32) (param $_M0L6hi__inS52 i32) (param $_M0L3rowS46 i32) (param $_M0L3colS47 i32) (param $_M0L10old__colorS48 i32) (param $_M0L10new__colorS50 i32) (result i32)
 (local $_M0L6i__oldS45 i32)
 (local $_M0L6i__newS49 i32)
 (local $_M0L6_2atmpS534 i32)
 (local $_M0L6_2atmpS535 i32)
 (local $_M0L6_2atmpS536 i32)
 (local $_M0L6_2atmpS537 i32)
 (local $_M0L6_2atmpS538 i32)
 (local $_M0L6_2atmpS539 i32)
 (local $_M0L6_2atmpS540 i32)
 (local $_M0L6_2atmpS541 i32)
 (local $_M0L3ptrS1323 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 66 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 66 16 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 67 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 67 14 ;)
 (call $_M0FP48moonarc34rhae3src4rhae7zt__idx
  (local.get $_M0L3rowS46)
  (local.get $_M0L3colS47)
  (local.get $_M0L10old__colorS48))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 67 41 ;)
 (local.set $_M0L6i__oldS45)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 68 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 68 14 ;)
 (call $_M0FP48moonarc34rhae3src4rhae7zt__idx
  (local.get $_M0L3rowS46)
  (local.get $_M0L3colS47)
  (local.get $_M0L10new__colorS50))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 68 41 ;)
 (local.set $_M0L6i__newS49)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 11 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)
  (local.get $_M0L6i__oldS45))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 23 ;)
 (local.set $_M0L6_2atmpS541)
 (i32.xor
  (local.get $_M0L6lo__inS51)
  (local.get $_M0L6_2atmpS541))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 23 ;)
 (local.set $_M0L6_2atmpS539)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 26 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)
  (local.get $_M0L6i__newS49))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 38 ;)
 (local.set $_M0L6_2atmpS540)
 (i32.xor
  (local.get $_M0L6_2atmpS539)
  (local.get $_M0L6_2atmpS540))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 38 ;)
 (local.set $_M0L6_2atmpS534)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 11 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)
  (local.get $_M0L6i__oldS45))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 23 ;)
 (local.set $_M0L6_2atmpS538)
 (i32.xor
  (local.get $_M0L6hi__inS52)
  (local.get $_M0L6_2atmpS538))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 23 ;)
 (local.set $_M0L6_2atmpS536)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 26 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)
  (local.get $_M0L6i__newS49))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 38 ;)
 (local.set $_M0L6_2atmpS537)
 (i32.xor
  (local.get $_M0L6_2atmpS536)
  (local.get $_M0L6_2atmpS537))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 38 ;)
 (local.set $_M0L6_2atmpS535)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1323
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1323)
  (local.get $_M0L6_2atmpS535))
 (i32.store
  (local.get $_M0L3ptrS1323)
  (local.get $_M0L6_2atmpS534))
 (local.get $_M0L3ptrS1323)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 39 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 39 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 39 ;))
(func $_M0FP48moonarc34rhae3src4rhae19zobrist__hash__grid (param $_M0L4gridS42 i32) (param $_M0L1hS38 i32) (param $_M0L1wS40 i32) (result i32)
 (local $_M0L2loS35 i32)
 (local $_M0L2hiS36 i32)
 (local $_M0L1rS37 i32)
 (local $_M0L1cS39 i32)
 (local $_M0L3idxS41 i32)
 (local $_M0L3valS513 i32)
 (local $_M0L3valS514 i32)
 (local $_M0L6_2atmpS515 i32)
 (local $_M0L3valS516 i32)
 (local $_M0L6_2atmpS517 i32)
 (local $_M0L6_2atmpS518 i32)
 (local $_M0L3valS519 i32)
 (local $_M0L6_2atmpS520 i32)
 (local $_M0L6_2atmpS521 i32)
 (local $_M0L3valS522 i32)
 (local $_M0L3valS523 i32)
 (local $_M0L3valS524 i32)
 (local $_M0L6_2atmpS525 i32)
 (local $_M0L6_2atmpS526 i32)
 (local $_M0L6_2atmpS527 i32)
 (local $_M0L3valS528 i32)
 (local $_M0L3valS529 i32)
 (local $_M0L6_2atmpS530 i32)
 (local $_M0L3valS531 i32)
 (local $_M0L3valS532 i32)
 (local $_M0L3valS533 i32)
 (local $_M0L3ptrS1324 i32)
 (local $_M0L3ptrS1325 i32)
 (local $_M0L3ptrS1326 i32)
 (local $_M0L3ptrS1327 i32)
 (local $_M0L3ptrS1328 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 46 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 46 16 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 47 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1328
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1328)
  (i32.const 0))
 (local.set $_M0L2loS35
  (local.get $_M0L3ptrS1328))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 47 18 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1327
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1327)
  (i32.const 0))
 (local.set $_M0L2hiS36
  (local.get $_M0L3ptrS1327))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 48 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1326
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1326)
  (i32.const 0))
 (local.set $_M0L1rS37
  (local.get $_M0L3ptrS1326))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 49 2 ;)
 (loop $loop:44
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 49 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS513
    (i32.load
     (local.get $_M0L1rS37)))
   (local.get $_M0L1hS38))
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 49 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 50 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS1325
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS1325)
     (i32.const 0))
    (local.set $_M0L1cS39
     (local.get $_M0L3ptrS1325))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 51 4 ;)
    (loop $loop:43
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 51 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS514
       (i32.load
        (local.get $_M0L1cS39)))
      (local.get $_M0L1wS40))
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 51 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 6 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 16 ;)
       (local.set $_M0L3valS523
        (i32.load
         (local.get $_M0L1rS37)))
       (local.set $_M0L3valS524
        (i32.load
         (local.get $_M0L1cS39)))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 29 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 34 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 34 ;)
       (i32.mul
        (local.tee $_M0L3valS529
         (i32.load
          (local.get $_M0L1rS37)))
        (local.get $_M0L1wS40))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 39 ;)
       (local.set $_M0L6_2atmpS527)
       (local.set $_M0L3valS528
        (i32.load
         (local.get $_M0L1cS39)))
       (i32.add
        (local.get $_M0L6_2atmpS527)
        (local.get $_M0L3valS528))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 43 ;)
       (local.set $_M0L6_2atmpS526)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS42)
        (local.get $_M0L6_2atmpS526))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 44 ;)
       (local.set $_M0L6_2atmpS525)
       (call $_M0FP48moonarc34rhae3src4rhae7zt__idx
        (local.get $_M0L3valS523)
        (local.get $_M0L3valS524)
        (local.get $_M0L6_2atmpS525))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 45 ;)
       (local.set $_M0L3idxS41)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 6 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 11 ;)
       (local.set $_M0L3valS516
        (i32.load
         (local.get $_M0L2loS35)))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 16 ;)
       (call $_M0MPC15array5Array2atGiE
        (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)
        (local.get $_M0L3idxS41))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 26 ;)
       (local.set $_M0L6_2atmpS517)
       (i32.xor
        (local.get $_M0L3valS516)
        (local.get $_M0L6_2atmpS517))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 26 ;)
       (local.set $_M0L6_2atmpS515)
       (i32.store
        (local.get $_M0L2loS35)
        (local.get $_M0L6_2atmpS515))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 26 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 28 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 33 ;)
       (local.set $_M0L3valS519
        (i32.load
         (local.get $_M0L2hiS36)))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 38 ;)
       (call $_M0MPC15array5Array2atGiE
        (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)
        (local.get $_M0L3idxS41))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 48 ;)
       (local.set $_M0L6_2atmpS520)
       (i32.xor
        (local.get $_M0L3valS519)
        (local.get $_M0L6_2atmpS520))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 48 ;)
       (local.set $_M0L6_2atmpS518)
       (i32.store
        (local.get $_M0L2hiS36)
        (local.get $_M0L6_2atmpS518))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 48 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 54 6 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 54 10 ;)
       (i32.add
        (local.tee $_M0L3valS522
         (i32.load
          (local.get $_M0L1cS39)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 54 15 ;)
       (local.set $_M0L6_2atmpS521)
       (i32.store
        (local.get $_M0L1cS39)
        (local.get $_M0L6_2atmpS521))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 54 15 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 54 15 ;)
       (drop)
       (br $loop:43))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS39)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 55 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 56 4 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 56 8 ;)
    (i32.add
     (local.tee $_M0L3valS531
      (i32.load
       (local.get $_M0L1rS37)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 56 13 ;)
    (local.set $_M0L6_2atmpS530)
    (i32.store
     (local.get $_M0L1rS37)
     (local.get $_M0L6_2atmpS530))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 56 13 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 56 13 ;)
    (drop)
    (br $loop:44))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS37)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 57 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 58 2 ;)
 (i32.load
  (local.get $_M0L2loS35))
 (call $moonbit.decref
  (local.get $_M0L2loS35))
 (local.set $_M0L3valS532)
 (i32.load
  (local.get $_M0L2hiS36))
 (call $moonbit.decref
  (local.get $_M0L2hiS36))
 (local.set $_M0L3valS533)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1324
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS1324)
  (local.get $_M0L3valS533))
 (i32.store
  (local.get $_M0L3ptrS1324)
  (local.get $_M0L3valS532))
 (local.get $_M0L3ptrS1324)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 58 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 58 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 58 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 58 10 ;))
(func $_M0FP48moonarc34rhae3src4rhae7zt__idx (param $_M0L3rowS30 i32) (param $_M0L3colS32 i32) (param $_M0L5colorS34 i32) (result i32)
 (local $_M0L1rS29 i32)
 (local $_M0L1cS31 i32)
 (local $_M0L1kS33 i32)
 (local $_M0L6_2atmpS510 i32)
 (local $_M0L6_2atmpS511 i32)
 (local $_M0L6_2atmpS512 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 39 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 39 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 39 13 ;)
 (i32.lt_s
  (local.get $_M0L3rowS30)
  (global.get $_M0FP48moonarc34rhae3src4rhae8zb__rows))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 39 28 ;)
 (if (result i32)
  (then
   (local.get $_M0L3rowS30))
  (else
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 39 48 ;)
   (i32.sub
    (global.get $_M0FP48moonarc34rhae3src4rhae8zb__rows)
    (i32.const 1))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 39 61 ;)))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 39 63 ;)
 (local.set $_M0L1rS29)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 40 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 40 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 40 13 ;)
 (i32.lt_s
  (local.get $_M0L3colS32)
  (global.get $_M0FP48moonarc34rhae3src4rhae8zb__cols))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 40 28 ;)
 (if (result i32)
  (then
   (local.get $_M0L3colS32))
  (else
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 40 48 ;)
   (i32.sub
    (global.get $_M0FP48moonarc34rhae3src4rhae8zb__cols)
    (i32.const 1))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 40 61 ;)))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 40 63 ;)
 (local.set $_M0L1cS31)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 41 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 41 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 41 13 ;)
 (i32.lt_s
  (local.get $_M0L5colorS34)
  (global.get $_M0FP48moonarc34rhae3src4rhae10zb__colors))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 41 30 ;)
 (if (result i32)
  (then
   (local.get $_M0L5colorS34))
  (else
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 41 48 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 41 49 ;)))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 41 51 ;)
 (local.set $_M0L1kS33)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 3 ;)
 (i32.mul
  (local.get $_M0L1rS29)
  (global.get $_M0FP48moonarc34rhae3src4rhae8zb__cols))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 14 ;)
 (local.tee $_M0L6_2atmpS512)
 (local.get $_M0L1cS31)
 (i32.add)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 18 ;)
 (local.tee $_M0L6_2atmpS511)
 (global.get $_M0FP48moonarc34rhae3src4rhae10zb__colors)
 (i32.mul)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 31 ;)
 (local.tee $_M0L6_2atmpS510)
 (local.get $_M0L1kS33)
 (i32.add)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 35 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 35 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 35 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 35 ;))
(func $_M0FP48moonarc34rhae3src4rhae13zobrist__init (result i32)
 (local $_M0L1iS27 i32)
 (local $_M0L3valS497 i32)
 (local $_M0L3valS498 i32)
 (local $_M0L6_2atmpS499 i32)
 (local $_M0L6_2atmpS500 i32)
 (local $_M0L6_2atmpS501 i32)
 (local $_M0L3valS502 i32)
 (local $_M0L3valS503 i32)
 (local $_M0L6_2atmpS504 i32)
 (local $_M0L6_2atmpS505 i32)
 (local $_M0L6_2atmpS506 i32)
 (local $_M0L3valS507 i32)
 (local $_M0L6_2atmpS508 i32)
 (local $_M0L3valS509 i32)
 (local $_M0L3ptrS1329 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 28 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 28 5 ;)
 (i32.load
  (global.get $_M0FP48moonarc34rhae3src4rhae8zt__init))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 28 16 ;)
 (if
  (then
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 28 19 ;)
   (i32.const 0)
   (return))
  (else))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 28 27 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 29 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1329
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1329)
  (i32.const 0))
 (local.set $_M0L1iS27
  (local.get $_M0L3ptrS1329))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 30 2 ;)
 (loop $loop:28
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 30 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS497
    (i32.load
     (local.get $_M0L1iS27)))
   (global.get $_M0FP48moonarc34rhae3src4rhae8zb__size))
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 30 19 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 4 ;)
    (local.set $_M0L3valS498
     (i32.load
      (local.get $_M0L1iS27)))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 15 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 27 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 27 ;)
    (i32.mul
     (local.tee $_M0L3valS502
      (i32.load
       (local.get $_M0L1iS27)))
     (i32.const 1234567))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 38 ;)
    (local.tee $_M0L6_2atmpS501)
    (i32.const 42)
    (i32.add)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 43 ;)
    (local.tee $_M0L6_2atmpS500)
    (call $_M0FP48moonarc34rhae3src4rhae12splitmix__lo)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 44 ;)
    (local.set $_M0L6_2atmpS499)
    (call $_M0MPC15array5Array3setGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)
     (local.get $_M0L3valS498)
     (local.get $_M0L6_2atmpS499))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 44 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 4 ;)
    (local.set $_M0L3valS503
     (i32.load
      (local.get $_M0L1iS27)))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 15 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 27 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 27 ;)
    (i32.mul
     (local.tee $_M0L3valS507
      (i32.load
       (local.get $_M0L1iS27)))
     (i32.const 7654321))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 38 ;)
    (local.tee $_M0L6_2atmpS506)
    (i32.const 137)
    (i32.add)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 44 ;)
    (local.tee $_M0L6_2atmpS505)
    (call $_M0FP48moonarc34rhae3src4rhae12splitmix__hi)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 45 ;)
    (local.set $_M0L6_2atmpS504)
    (call $_M0MPC15array5Array3setGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)
     (local.get $_M0L3valS503)
     (local.get $_M0L6_2atmpS504))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 45 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 33 4 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 33 8 ;)
    (i32.add
     (local.tee $_M0L3valS509
      (i32.load
       (local.get $_M0L1iS27)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 33 13 ;)
    (local.set $_M0L6_2atmpS508)
    (i32.store
     (local.get $_M0L1iS27)
     (local.get $_M0L6_2atmpS508))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 33 13 ;)
    (drop)
    (br $loop:28))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS27)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 34 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 35 2 ;)
 (i32.store
  (global.get $_M0FP48moonarc34rhae3src4rhae8zt__init)
  (i32.const 1))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 35 20 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 35 20 ;))
(func $_M0FP48moonarc34rhae3src4rhae12splitmix__hi (param $_M0L1sS24 i32) (result i32)
 (local $_M0L1zS23 i32)
 (local $_M0L1zS25 i32)
 (local $_M0L1zS26 i32)
 (local $_M0L6_2atmpS492 i32)
 (local $_M0L6_2atmpS493 i32)
 (local $_M0L6_2atmpS494 i32)
 (local $_M0L6_2atmpS495 i32)
 (local $_M0L6_2atmpS496 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 21 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 21 10 ;)
 (i32.add
  (local.get $_M0L1sS24)
  (i32.const 1818371886))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 21 24 ;)
 (local.set $_M0L1zS23)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 22 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 22 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 22 11 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 22 16 ;)
 (i32.shr_s
  (local.get $_M0L1zS23)
  (i32.const 15))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 22 23 ;)
 (local.set $_M0L6_2atmpS496)
 (i32.xor
  (local.get $_M0L1zS23)
  (local.get $_M0L6_2atmpS496))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 22 24 ;)
 (local.tee $_M0L6_2atmpS495)
 (i32.const -1084733587)
 (i32.mul)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 22 38 ;)
 (local.set $_M0L1zS25)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 23 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 23 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 23 11 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 23 16 ;)
 (i32.shr_s
  (local.get $_M0L1zS25)
  (i32.const 13))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 23 23 ;)
 (local.set $_M0L6_2atmpS494)
 (i32.xor
  (local.get $_M0L1zS25)
  (local.get $_M0L6_2atmpS494))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 23 24 ;)
 (local.tee $_M0L6_2atmpS493)
 (i32.const -1798288965)
 (i32.mul)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 23 38 ;)
 (local.set $_M0L1zS26)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 24 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 24 7 ;)
 (i32.shr_s
  (local.get $_M0L1zS26)
  (i32.const 16))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 24 14 ;)
 (local.set $_M0L6_2atmpS492)
 (i32.xor
  (local.get $_M0L1zS26)
  (local.get $_M0L6_2atmpS492))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 24 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 24 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 24 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 24 15 ;))
(func $_M0FP48moonarc34rhae3src4rhae12splitmix__lo (param $_M0L1sS20 i32) (result i32)
 (local $_M0L1zS19 i32)
 (local $_M0L1zS21 i32)
 (local $_M0L1zS22 i32)
 (local $_M0L6_2atmpS487 i32)
 (local $_M0L6_2atmpS488 i32)
 (local $_M0L6_2atmpS489 i32)
 (local $_M0L6_2atmpS490 i32)
 (local $_M0L6_2atmpS491 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 15 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 15 10 ;)
 (i32.add
  (local.get $_M0L1sS20)
  (i32.const -1640531527))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 15 24 ;)
 (local.set $_M0L1zS19)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 16 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 16 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 16 11 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 16 16 ;)
 (i32.shr_s
  (local.get $_M0L1zS19)
  (i32.const 16))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 16 23 ;)
 (local.set $_M0L6_2atmpS491)
 (i32.xor
  (local.get $_M0L1zS19)
  (local.get $_M0L6_2atmpS491))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 16 24 ;)
 (local.tee $_M0L6_2atmpS490)
 (i32.const -2048144789)
 (i32.mul)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 16 38 ;)
 (local.set $_M0L1zS21)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 17 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 17 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 17 11 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 17 16 ;)
 (i32.shr_s
  (local.get $_M0L1zS21)
  (i32.const 13))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 17 23 ;)
 (local.set $_M0L6_2atmpS489)
 (i32.xor
  (local.get $_M0L1zS21)
  (local.get $_M0L6_2atmpS489))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 17 24 ;)
 (local.tee $_M0L6_2atmpS488)
 (i32.const -1028477387)
 (i32.mul)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 17 38 ;)
 (local.set $_M0L1zS22)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 18 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 18 7 ;)
 (i32.shr_s
  (local.get $_M0L1zS22)
  (i32.const 16))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 18 14 ;)
 (local.set $_M0L6_2atmpS487)
 (i32.xor
  (local.get $_M0L1zS22)
  (local.get $_M0L6_2atmpS487))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 18 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 18 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 18 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 18 15 ;))
(func $_M0MPC15array5Array2atGiE (param $_M0L4selfS14 i32) (param $_M0L5indexS15 i32) (result i32)
 (local $_M0L3lenS13 i32)
 (local $_M0L6_2atmpS485 i32)
 (local $_M0L6_2aarrS1330 i32)
 (local $_M0L6_2aidxS1331 i32)
 (; prologue_end ;)
 (; source_pos moonbitlang/core/builtin array.mbt 186 2 ;)
 (local.set $_M0L3lenS13
  (i32.load
   (local.get $_M0L4selfS14)))
 (; source_pos moonbitlang/core/builtin array.mbt 187 2 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 187 8 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 187 8 ;)
 (i32.ge_s
  (local.get $_M0L5indexS15)
  (i32.const 0))
 (; source_pos moonbitlang/core/builtin array.mbt 187 18 ;)
 (if (result i32)
  (then
   (; source_pos moonbitlang/core/builtin array.mbt 187 22 ;)
   (i32.lt_s
    (local.get $_M0L5indexS15)
    (local.get $_M0L3lenS13))
   (; source_pos moonbitlang/core/builtin array.mbt 187 33 ;))
  (else
   (i32.const 0)))
 (; source_pos moonbitlang/core/builtin array.mbt 187 33 ;)
 (if (result i32)
  (then
   (; source_pos moonbitlang/core/builtin array.mbt 188 2 ;)
   (; source_pos moonbitlang/core/builtin array.mbt 188 2 ;)
   (call $_M0MPC15array5Array6bufferGiE
    (local.get $_M0L4selfS14))
   (; source_pos moonbitlang/core/builtin array.mbt 188 15 ;)
   (local.tee $_M0L6_2atmpS485)
   (local.set $_M0L6_2aidxS1331
    (local.get $_M0L5indexS15))
   (local.set $_M0L6_2aarrS1330)
   (call $moonbit.check_range
    (local.get $_M0L6_2aidxS1331)
    (i32.const 0)
    (i32.sub
     (call $moonbit.array_length
      (local.get $_M0L6_2aarrS1330))
     (i32.const 1)))
   (i32.load
    (i32.add
     (local.get $_M0L6_2aarrS1330)
     (i32.shl
      (local.get $_M0L6_2aidxS1331)
      (i32.const 2))))
   (call $moonbit.decref
    (local.get $_M0L6_2atmpS485))
   (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;))
  (else
   (; source_pos moonbitlang/core/builtin array.mbt 187 2 ;)
   (unreachable)))
 (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;))
(func $_M0MPC15array5Array2atGUiiEE (param $_M0L4selfS17 i32) (param $_M0L5indexS18 i32) (result i32)
 (local $_M0L3lenS16 i32)
 (local $_M0L6_2atmpS486 i32)
 (local $_M0L6_2atmpS1170 i32)
 (local $_M0L6_2aarrS1332 i32)
 (local $_M0L6_2aidxS1333 i32)
 (; prologue_end ;)
 (; source_pos moonbitlang/core/builtin array.mbt 186 2 ;)
 (local.set $_M0L3lenS16
  (i32.load
   (local.get $_M0L4selfS17)))
 (; source_pos moonbitlang/core/builtin array.mbt 187 2 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 187 8 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 187 8 ;)
 (i32.ge_s
  (local.get $_M0L5indexS18)
  (i32.const 0))
 (; source_pos moonbitlang/core/builtin array.mbt 187 18 ;)
 (if (result i32)
  (then
   (; source_pos moonbitlang/core/builtin array.mbt 187 22 ;)
   (i32.lt_s
    (local.get $_M0L5indexS18)
    (local.get $_M0L3lenS16))
   (; source_pos moonbitlang/core/builtin array.mbt 187 33 ;))
  (else
   (i32.const 0)))
 (; source_pos moonbitlang/core/builtin array.mbt 187 33 ;)
 (if (result i32)
  (then
   (; source_pos moonbitlang/core/builtin array.mbt 188 2 ;)
   (; source_pos moonbitlang/core/builtin array.mbt 188 2 ;)
   (call $_M0MPC15array5Array6bufferGUiiEE
    (local.get $_M0L4selfS17))
   (; source_pos moonbitlang/core/builtin array.mbt 188 15 ;)
   (local.tee $_M0L6_2atmpS486)
   (local.set $_M0L6_2aidxS1333
    (local.get $_M0L5indexS18))
   (local.set $_M0L6_2aarrS1332)
   (call $moonbit.check_range
    (local.get $_M0L6_2aidxS1333)
    (i32.const 0)
    (i32.sub
     (call $moonbit.array_length
      (local.get $_M0L6_2aarrS1332))
     (i32.const 1)))
   (if
    (local.tee $_M0L6_2atmpS1170
     (i32.load
      (i32.add
       (local.get $_M0L6_2aarrS1332)
       (i32.shl
        (local.get $_M0L6_2aidxS1333)
        (i32.const 2)))))
    (then
     (call $moonbit.incref
      (local.get $_M0L6_2atmpS1170)))
    (else))
   (call $moonbit.decref
    (local.get $_M0L6_2atmpS486))
   (local.get $_M0L6_2atmpS1170)
   (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;))
  (else
   (; source_pos moonbitlang/core/builtin array.mbt 187 2 ;)
   (unreachable)))
 (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;))
(func $_M0MPC15array5Array3setGiE (param $_M0L4selfS10 i32) (param $_M0L5indexS11 i32) (param $_M0L5valueS12 i32) (result i32)
 (local $_M0L3lenS9 i32)
 (local $_M0L6_2atmpS484 i32)
 (local $_M0L6_2aarrS1334 i32)
 (local $_M0L6_2aidxS1335 i32)
 (; prologue_end ;)
 (; source_pos moonbitlang/core/builtin array.mbt 263 2 ;)
 (local.set $_M0L3lenS9
  (i32.load
   (local.get $_M0L4selfS10)))
 (; source_pos moonbitlang/core/builtin array.mbt 264 2 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 264 8 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 264 8 ;)
 (i32.ge_s
  (local.get $_M0L5indexS11)
  (i32.const 0))
 (; source_pos moonbitlang/core/builtin array.mbt 264 18 ;)
 (if (result i32)
  (then
   (; source_pos moonbitlang/core/builtin array.mbt 264 22 ;)
   (i32.lt_s
    (local.get $_M0L5indexS11)
    (local.get $_M0L3lenS9))
   (; source_pos moonbitlang/core/builtin array.mbt 264 33 ;))
  (else
   (i32.const 0)))
 (; source_pos moonbitlang/core/builtin array.mbt 264 33 ;)
 (if (result i32)
  (then
   (; source_pos moonbitlang/core/builtin array.mbt 265 2 ;)
   (; source_pos moonbitlang/core/builtin array.mbt 265 2 ;)
   (call $_M0MPC15array5Array6bufferGiE
    (local.get $_M0L4selfS10))
   (; source_pos moonbitlang/core/builtin array.mbt 265 15 ;)
   (local.tee $_M0L6_2atmpS484)
   (local.set $_M0L6_2aidxS1335
    (local.get $_M0L5indexS11))
   (local.set $_M0L6_2aarrS1334)
   (call $moonbit.check_range
    (local.get $_M0L6_2aidxS1335)
    (i32.const 0)
    (i32.sub
     (call $moonbit.array_length
      (local.get $_M0L6_2aarrS1334))
     (i32.const 1)))
   (i32.store
    (i32.add
     (local.get $_M0L6_2aarrS1334)
     (i32.shl
      (local.get $_M0L6_2aidxS1335)
      (i32.const 2)))
    (local.get $_M0L5valueS12))
   (call $moonbit.decref
    (local.get $_M0L6_2atmpS484))
   (i32.const 0)
   (; source_pos moonbitlang/core/builtin array.mbt 265 30 ;))
  (else
   (; source_pos moonbitlang/core/builtin array.mbt 264 2 ;)
   (unreachable)))
 (; source_pos moonbitlang/core/builtin array.mbt 265 30 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 265 30 ;))
(func $_M0MPC15array5Array4makeGiE (param $_M0L3lenS5 i32) (param $_M0L4elemS7 i32) (result i32)
 (local $_M0L3arrS4 i32)
 (local $_M0L1iS6 i32)
 (local $_M0L3bufS482 i32)
 (local $_M0L6_2atmpS483 i32)
 (; prologue_end ;)
 (; source_pos moonbitlang/core/builtin array.mbt 77 2 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 77 12 ;)
 (call $_M0MPC15array5Array12make__uninitGiE
  (local.get $_M0L3lenS5))
 (; source_pos moonbitlang/core/builtin array.mbt 77 35 ;)
 (local.set $_M0L3arrS4)
 (; source_pos moonbitlang/core/builtin array.mbt 78 2 ;)
 (i32.const 0)
 (loop $loop:8 (param i32)
  (local.tee $_M0L1iS6)
  (local.get $_M0L3lenS5)
  (i32.lt_s)
  (if
   (then
    (; source_pos moonbitlang/core/builtin array.mbt 79 4 ;)
    (i32.store
     (i32.add
      (local.tee $_M0L3bufS482
       (i32.load offset=4
        (local.get $_M0L3arrS4)))
      (i32.shl
       (local.get $_M0L1iS6)
       (i32.const 2)))
     (local.get $_M0L4elemS7))
    (local.tee $_M0L6_2atmpS483
     (i32.add
      (local.get $_M0L1iS6)
      (i32.const 1)))
    (br $loop:8))
   (else)))
 (i32.const 0)
 (; source_pos moonbitlang/core/builtin array.mbt 80 3 ;)
 (drop)
 (local.get $_M0L3arrS4)
 (; source_pos moonbitlang/core/builtin array.mbt 81 5 ;))
(func $_M0MPC15array5Array6bufferGiE (param $_M0L4selfS2 i32) (result i32)
 (local $_M0L8_2afieldS1172 i32)
 (; prologue_end ;)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 125 2 ;)
 (call $moonbit.incref
  (local.tee $_M0L8_2afieldS1172
   (i32.load offset=4
    (local.get $_M0L4selfS2))))
 (local.get $_M0L8_2afieldS1172)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 125 10 ;))
(func $_M0MPC15array5Array6bufferGUiiEE (param $_M0L4selfS3 i32) (result i32)
 (local $_M0L8_2afieldS1173 i32)
 (; prologue_end ;)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 125 2 ;)
 (call $moonbit.incref
  (local.tee $_M0L8_2afieldS1173
   (i32.load offset=4
    (local.get $_M0L4selfS3))))
 (local.get $_M0L8_2afieldS1173)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 125 10 ;))
(func $_M0MPC15array5Array12make__uninitGiE (param $_M0L3lenS1 i32) (result i32)
 (local $_M0L6_2atmpS481 i32)
 (local $_M0L3ptrS1336 i32)
 (; prologue_end ;)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 28 2 ;)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 28 9 ;)
 (call $moonbit.i32_array_make_raw
  (local.get $_M0L3lenS1))
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 28 38 ;)
 (local.set $_M0L6_2atmpS481)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1336
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 524544))
 (i32.store
  (local.get $_M0L3ptrS1336)
  (local.get $_M0L3lenS1))
 (i32.store offset=4
  (local.get $_M0L3ptrS1336)
  (local.get $_M0L6_2atmpS481))
 (local.get $_M0L3ptrS1336)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 28 45 ;))
(start $_M0FP017____moonbit__init)
(func $_M0FP017____moonbit__init
 (local $_M0L3ptrS1337 i32)
 (local $_M0L3ptrS1338 i32)
 (local $_M0L3ptrS1339 i32)
 (local $_M0L3ptrS1340 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 12 28 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1340
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1340)
  (i32.const 0))
 (local.get $_M0L3ptrS1340)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 12 42 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae8zt__init)
 (; source_pos moonarc3/rhae/src/rhae types.mbt 25 33 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1339
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1339)
  (i32.const 0))
 (local.get $_M0L3ptrS1339)
 (; source_pos moonarc3/rhae/src/rhae types.mbt 25 43 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae8hash__hi)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 6 25 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1338
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1338)
  (i32.const 0))
 (local.get $_M0L3ptrS1338)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 6 35 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae9__bulk__h)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 7 25 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS1337
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS1337)
  (i32.const 0))
 (local.get $_M0L3ptrS1337)
 (; source_pos moonarc3/rhae/src/rhae bulk_io.mbt 7 35 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae9__bulk__w)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 114 32 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 4096)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 114 52 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 11 28 ;)
 (call $_M0MPC15array5Array4makeGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8zb__size)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 11 51 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae6zt__hi)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 10 28 ;)
 (call $_M0MPC15array5Array4makeGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8zb__size)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 10 51 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae6zt__lo)
 (; source_pos moonarc3/rhae/src/rhae types.mbt 20 32 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 40)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae types.mbt 20 52 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae8inv__buf)
 (; source_pos moonarc3/rhae/src/rhae types.mbt 21 33 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 7)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae types.mbt 21 53 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae8vis__buf)
 (; source_pos moonarc3/rhae/src/rhae types.mbt 23 33 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 91)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae types.mbt 23 53 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae8mat__buf)
 (; source_pos moonarc3/rhae/src/rhae types.mbt 19 33 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 4096)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae types.mbt 19 53 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae9prev__buf)
 (; source_pos moonarc3/rhae/src/rhae types.mbt 18 33 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 4096)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae types.mbt 18 53 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae9grid__buf)
 (; source_pos moonarc3/rhae/src/rhae score.mbt 6 30 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 4096)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae score.mbt 6 50 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae11target__buf)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 136 32 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 32)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 136 50 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae13visited__bits)
 (; source_pos moonarc3/rhae/src/rhae types.mbt 22 33 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 7)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae types.mbt 22 53 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae9risk__buf)
 (; source_pos moonarc3/rhae/src/rhae types.mbt 24 33 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 6)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae types.mbt 24 53 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae9topk__buf))
(func $_M0FP017____moonbit__main
 (local $_M0L11dummy__gridS472 i32)
 (local $_M0L10dummy__outS473 i32)
 (local $_M0L10dummy__invS474 i32)
 (local $_M0L10dummy__visS475 i32)
 (local $_M0L10dummy__matS476 i32)
 (local $_M0L9dummy__tkS477 i32)
 (local $_M0L8dummy__pS478 i32)
 (local $_M0L6_2atmpS1174 i32)
 (local $_M0L6_2atmpS1175 i32)
 (local $_M0L6_2atmpS1176 i32)
 (local $_M0L6_2atmpS1177 i32)
 (local $_M0L6_2atmpS1178 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 65536 65535 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 2 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init)
 (; source_pos moonarc3/rhae/src/main main.mbt 2 22 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 3 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae15set__grid__cell
  (i32.const 0)
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/main main.mbt 3 27 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 4 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae15set__prev__cell
  (i32.const 0)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 4 27 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 5 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae12set__visited
  (i32.const 0)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 5 25 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 6 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae9set__risk
  (i32.const 0)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 6 22 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 7 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae8get__inv
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 7 26 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 8 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae8get__mat
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 8 26 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 9 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae9get__topk
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 9 27 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 10 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae16rhae__invariants
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 10 37 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 11 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae21rhae__canonical__hash
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 11 41 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 12 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae19rhae__get__hash__hi)
 (; source_pos moonarc3/rhae/src/main main.mbt 12 34 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 13 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae20rhae__visited__check
  (i32.const 0)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 13 40 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 14 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae19rhae__visited__mark
  (i32.const 0)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 14 31 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 15 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae20rhae__visited__reset)
 (; source_pos moonarc3/rhae/src/main main.mbt 15 28 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 16 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae18rhae__policy__gate
  (i32.const 127)
  (i32.const 8)
  (i32.const 8)
  (i32.const 7))
 (; source_pos moonarc3/rhae/src/main main.mbt 16 47 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 17 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae23rhae__build__candidates
  (i32.const 127)
  (i32.const 0)
  (i32.const 0)
  (i32.const 0)
  (i32.const 7))
 (; source_pos moonarc3/rhae/src/main main.mbt 17 55 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 18 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae10rhae__topk
  (i32.const 7)
  (i32.const 6))
 (; source_pos moonarc3/rhae/src/main main.mbt 18 31 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 19 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae16rhae__tt__lookup
  (i32.const 0)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 19 36 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 20 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae15rhae__tt__store
  (i32.const 0)
  (i32.const 0)
  (i32.const 1)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 20 33 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 21 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae22rhae__hash__and__check
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 21 41 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 22 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14encode__action
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/main main.mbt 22 32 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 23 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14decode__action
  (i32.const 3))
 (; source_pos moonarc3/rhae/src/main main.mbt 23 32 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 24 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 24 19 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 64)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 24 37 ;)
 (local.set $_M0L11dummy__gridS472)
 (; source_pos moonarc3/rhae/src/main main.mbt 25 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 25 19 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 64)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 25 37 ;)
 (local.set $_M0L10dummy__outS473)
 (; source_pos moonarc3/rhae/src/main main.mbt 26 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 26 19 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 40)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 26 37 ;)
 (local.set $_M0L10dummy__invS474)
 (; source_pos moonarc3/rhae/src/main main.mbt 27 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 27 19 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 7)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 27 37 ;)
 (local.set $_M0L10dummy__visS475)
 (; source_pos moonarc3/rhae/src/main main.mbt 28 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 28 19 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 91)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 28 37 ;)
 (local.set $_M0L10dummy__matS476)
 (; source_pos moonarc3/rhae/src/main main.mbt 29 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 29 19 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 6)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 29 37 ;)
 (local.set $_M0L9dummy__tkS477)
 (; source_pos moonarc3/rhae/src/main main.mbt 65536 65535 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 30 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae18canonicalize__grid
  (local.get $_M0L11dummy__gridS472)
  (i32.const 8)
  (i32.const 8)
  (local.get $_M0L10dummy__outS473))
 (; source_pos moonarc3/rhae/src/main main.mbt 30 62 ;)
 (local.tee $_M0L6_2atmpS1178)
 (call $moonbit.decref)
 (; source_pos moonarc3/rhae/src/main main.mbt 31 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae17normalize__colors
  (local.get $_M0L11dummy__gridS472)
  (i32.const 64)
  (local.get $_M0L10dummy__outS473))
 (call $moonbit.decref
  (local.get $_M0L10dummy__outS473))
 (; source_pos moonarc3/rhae/src/main main.mbt 31 59 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 32 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae19compute__invariants
  (local.get $_M0L11dummy__gridS472)
  (local.get $_M0L11dummy__gridS472)
  (i32.const 8)
  (i32.const 8)
  (local.get $_M0L10dummy__invS474))
 (; source_pos moonarc3/rhae/src/main main.mbt 32 67 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 33 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae19zobrist__hash__grid
  (local.get $_M0L11dummy__gridS472)
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 33 51 ;)
 (local.tee $_M0L6_2atmpS1177)
 (call $moonbit.decref)
 (; source_pos moonarc3/rhae/src/main main.mbt 34 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae21zobrist__update__cell
  (i32.const 0)
  (i32.const 0)
  (i32.const 0)
  (i32.const 0)
  (i32.const 0)
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/main main.mbt 34 53 ;)
 (local.tee $_M0L6_2atmpS1176)
 (call $moonbit.decref)
 (; source_pos moonarc3/rhae/src/main main.mbt 35 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae15canonical__hash
  (local.get $_M0L11dummy__gridS472)
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 35 48 ;)
 (local.tee $_M0L6_2atmpS1175)
 (call $moonbit.decref)
 (; source_pos moonarc3/rhae/src/main main.mbt 36 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14visited__check
  (i32.const 0)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 36 35 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 37 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13visited__mark
  (i32.const 0)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 37 26 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 38 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14visited__reset)
 (; source_pos moonarc3/rhae/src/main main.mbt 38 23 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 39 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae10tt__lookup
  (i32.const 0)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 39 31 ;)
 (local.tee $_M0L6_2atmpS1174)
 (call $moonbit.decref)
 (; source_pos moonarc3/rhae/src/main main.mbt 40 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae9tt__store
  (i32.const 0)
  (i32.const 0)
  (i32.const 1)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 40 28 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 41 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae12policy__gate
  (i32.const 127)
  (local.get $_M0L10dummy__invS474)
  (local.get $_M0L11dummy__gridS472)
  (i32.const 8)
  (i32.const 8)
  (local.get $_M0L10dummy__visS475)
  (i32.const 7))
 (call $moonbit.decref
  (local.get $_M0L11dummy__gridS472))
 (; source_pos moonarc3/rhae/src/main main.mbt 41 76 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 42 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae22build__candidate__rows
  (i32.const 127)
  (local.get $_M0L10dummy__invS474)
  (local.get $_M0L10dummy__visS475)
  (i32.const 0)
  (i32.const 0)
  (i32.const 0)
  (local.get $_M0L10dummy__matS476)
  (i32.const 7))
 (call $moonbit.decref
  (local.get $_M0L10dummy__invS474))
 (call $moonbit.decref
  (local.get $_M0L10dummy__visS475))
 (call $moonbit.decref
  (local.get $_M0L10dummy__matS476))
 (; source_pos moonarc3/rhae/src/main main.mbt 42 87 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 43 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 43 16 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 14)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 43 34 ;)
 (local.set $_M0L8dummy__pS478)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae16topk__candidates
  (local.get $_M0L8dummy__pS478)
  (i32.const 7)
  (i32.const 6)
  (local.get $_M0L9dummy__tkS477))
 (call $moonbit.decref
  (local.get $_M0L8dummy__pS478))
 (call $moonbit.decref
  (local.get $_M0L9dummy__tkS477))
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 47 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae15rhae__set__dims
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 47 27 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 48 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 48 11 ;)
 (call $_M0FP48moonarc34rhae3src4rhae18rhae__get__bulk__h)
 (; source_pos moonarc3/rhae/src/main main.mbt 48 34 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 49 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 49 11 ;)
 (call $_M0FP48moonarc34rhae3src4rhae18rhae__get__bulk__w)
 (; source_pos moonarc3/rhae/src/main main.mbt 49 34 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 65536 65535 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 50 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae16rhae__copy__prev
  (i32.const 64))
 (; source_pos moonarc3/rhae/src/main main.mbt 50 26 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 52 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae17set__target__cell
  (i32.const 0)
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/main main.mbt 52 29 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 53 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13rhae__hamming
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 53 34 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 54 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae17rhae__iou__scaled
  (i32.const 8)
  (i32.const 8)
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/main main.mbt 54 40 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 55 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae18rhae__score__batch
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 55 38 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 56 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae16rhae__is__solved
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 56 36 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 58 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae15rhae__has__hsym
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 58 35 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 59 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae15rhae__has__vsym
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 59 35 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 60 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae10rhae__bbox
  (i32.const 8)
  (i32.const 8)
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/main main.mbt 60 34 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 61 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae18rhae__count__color
  (i32.const 8)
  (i32.const 8)
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/main main.mbt 61 41 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 62 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae22rhae__color__histogram
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 62 34 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae21rhae__d4__hashes__all
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 2 ;)
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 64 40 ;)
 (drop))
(export "_start" (func $_M0FP017____moonbit__main))