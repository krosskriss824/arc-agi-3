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
 (i32.const 32)
)
(global $_M0FP48moonarc34rhae3src4rhae8zb__cols
 i32
 (i32.const 32)
)
(global $_M0FP48moonarc34rhae3src4rhae10zb__colors
 i32
 (i32.const 16)
)
(global $_M0FP48moonarc34rhae3src4rhae8zb__size
 i32
 (i32.const 16384)
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
(func $_M0FP48moonarc34rhae3src4rhae17normalize__colors (param $_M0L4gridS369 i32) (param $_M0L1nS367 i32) (param $_M0L3outS374 i32) (result i32)
 (local $_M0L5remapS364 i32)
 (local $_M0L7next__cS365 i32)
 (local $_M0L1iS366 i32)
 (local $_M0L1cS368 i32)
 (local $_M0L2mcS370 i32)
 (local $_M0L1vS372 i32)
 (local $_M0L7_2abindS373 i32)
 (local $_M0L3valS864 i32)
 (local $_M0L3valS865 i32)
 (local $_M0L6_2atmpS866 i32)
 (local $_M0L3valS867 i32)
 (local $_M0L3valS868 i32)
 (local $_M0L6_2atmpS869 i32)
 (local $_M0L3valS870 i32)
 (local $_M0L3valS871 i32)
 (local $_M0L3ptrS882 i32)
 (local $_M0L3ptrS883 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 105 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 105 27 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 16)
  (i32.const -1))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 105 46 ;)
 (local.set $_M0L5remapS364)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 106 2 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L5remapS364)
  (i32.const 0)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 106 14 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 107 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 107 26 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS883
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS883)
  (i32.const 1))
 (local.get $_M0L3ptrS883)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 107 36 ;)
 (local.set $_M0L7next__cS365)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 108 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS882
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS882)
  (i32.const 0))
 (local.set $_M0L1iS366
  (local.get $_M0L3ptrS882))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 109 2 ;)
 (loop $loop:375
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 109 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS864
    (i32.load
     (local.get $_M0L1iS366)))
   (local.get $_M0L1nS367))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 109 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 110 4 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 110 12 ;)
    (local.set $_M0L3valS871
     (i32.load
      (local.get $_M0L1iS366)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4gridS369)
     (local.get $_M0L3valS871))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 110 19 ;)
    (local.set $_M0L1cS368)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 111 4 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 111 13 ;)
    (block $outer/881 (result i32)
     (block $join:371
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 111 13 ;)
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 111 19 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L5remapS364)
       (local.get $_M0L1cS368))
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 111 27 ;)
      (local.tee $_M0L7_2abindS373)
      (i32.const -1)
      (i32.eq)
      (if (result i32)
       (then
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 14 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 25 ;)
        (i32.load
         (local.get $_M0L7next__cS365))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 35 ;)
        (local.set $_M0L3valS868)
        (call $_M0MPC15array5Array3setGiE
         (local.get $_M0L5remapS364)
         (local.get $_M0L1cS368)
         (local.get $_M0L3valS868))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 35 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 37 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 50 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 50 ;)
        (i32.load
         (local.get $_M0L7next__cS365))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 60 ;)
        (local.tee $_M0L3valS870)
        (i32.const 1)
        (i32.add)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 64 ;)
        (local.set $_M0L6_2atmpS869)
        (i32.store
         (local.get $_M0L7next__cS365)
         (local.get $_M0L6_2atmpS869))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 64 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 66 ;)
        (call $_M0MPC15array5Array2atGiE
         (local.get $_M0L5remapS364)
         (local.get $_M0L1cS368))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 112 74 ;))
       (else
        (local.set $_M0L1vS372
         (local.get $_M0L7_2abindS373))
        (br $join:371)))
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 114 5 ;)
      (br $outer/881))
     (local.get $_M0L1vS372))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 114 5 ;)
    (local.set $_M0L2mcS370)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 115 4 ;)
    (local.set $_M0L3valS865
     (i32.load
      (local.get $_M0L1iS366)))
    (call $_M0MPC15array5Array3setGiE
     (local.get $_M0L3outS374)
     (local.get $_M0L3valS865)
     (local.get $_M0L2mcS370))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 115 15 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 4 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 8 ;)
    (i32.add
     (local.tee $_M0L3valS867
      (i32.load
       (local.get $_M0L1iS366)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 13 ;)
    (local.set $_M0L6_2atmpS866)
    (i32.store
     (local.get $_M0L1iS366)
     (local.get $_M0L6_2atmpS866))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 13 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 13 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 116 13 ;)
    (drop)
    (br $loop:375))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS366))
    (call $moonbit.decref
     (local.get $_M0L5remapS364)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 117 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 118 2 ;)
 (i32.load
  (local.get $_M0L7next__cS365))
 (call $moonbit.decref
  (local.get $_M0L7next__cS365))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 118 12 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 118 12 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 118 12 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 118 12 ;))
(func $_M0FP48moonarc34rhae3src4rhae18canonicalize__grid (param $_M0L4gridS332 i32) (param $_M0L1hS317 i32) (param $_M0L1wS319 i32) (param $_M0L8out__bufS331 i32) (result i32)
 (local $_M0L7best__tS315 i32)
 (local $_M0L7best__hS316 i32)
 (local $_M0L7best__wS318 i32)
 (local $_M0L8write__tS320 i32)
 (local $_M0L10is__betterS341 i32)
 (local $_M0L1tS362 i32)
 (local $_M0L3valS857 i32)
 (local $_M0L3valS858 i32)
 (local $_M0L3valS859 i32)
 (local $_M0L6_2atmpS860 i32)
 (local $_M0L3valS861 i32)
 (local $_M0L3valS862 i32)
 (local $_M0L3valS863 i32)
 (local $_M0L3ptrS884 i32)
 (local $_M0L3ptrS885 i32)
 (local $_M0L3ptrS886 i32)
 (local $_M0L3ptrS887 i32)
 (local $_M0L3ptrS888 i32)
 (local $_M0L3ptrS889 i32)
 (local $_M0L3ptrS890 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 44 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 44 28 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS890
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS890)
  (i32.const 0))
 (local.get $_M0L3ptrS890)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 44 38 ;)
 (local.set $_M0L7best__tS315)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 45 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 45 28 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS889
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS889)
  (local.get $_M0L1hS317))
 (local.get $_M0L3ptrS889)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 45 38 ;)
 (local.set $_M0L7best__hS316)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 46 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 46 28 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS888
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS888)
  (local.get $_M0L1wS319))
 (local.get $_M0L3ptrS888)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 46 38 ;)
 (local.set $_M0L7best__wS318)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 49 2 ;)
 (call $moonbit.incref
  (local.get $_M0L4gridS332))
 (call $moonbit.incref
  (local.get $_M0L8out__bufS331))
 (call $moonbit.incref
  (local.get $_M0L7best__wS318))
 (call $moonbit.incref
  (local.get $_M0L7best__hS316))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS887
   (call $moonbit.gc.malloc
    (i32.const 28)))
  (i32.const 1049856))
 (i32.store offset=24
  (local.get $_M0L3ptrS887)
  (local.get $_M0L7best__tS315))
 (i32.store offset=20
  (local.get $_M0L3ptrS887)
  (local.get $_M0L7best__hS316))
 (i32.store offset=4
  (local.get $_M0L3ptrS887)
  (local.get $_M0L1hS317))
 (i32.store offset=16
  (local.get $_M0L3ptrS887)
  (local.get $_M0L7best__wS318))
 (i32.store
  (local.get $_M0L3ptrS887)
  (local.get $_M0L1wS319))
 (i32.store offset=12
  (local.get $_M0L3ptrS887)
  (local.get $_M0L8out__bufS331))
 (i32.store offset=8
  (local.get $_M0L3ptrS887)
  (local.get $_M0L4gridS332))
 (local.set $_M0L8write__tS320
  (local.get $_M0L3ptrS887))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 69 2 ;)
 (call $moonbit.incref
  (local.get $_M0L4gridS332))
 (call $moonbit.incref
  (local.get $_M0L8out__bufS331))
 (call $moonbit.incref
  (local.get $_M0L7best__wS318))
 (call $moonbit.incref
  (local.get $_M0L7best__hS316))
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS886
   (call $moonbit.gc.malloc
    (i32.const 24)))
  (i32.const 1049600))
 (i32.store offset=20
  (local.get $_M0L3ptrS886)
  (local.get $_M0L7best__hS316))
 (i32.store offset=4
  (local.get $_M0L3ptrS886)
  (local.get $_M0L1hS317))
 (i32.store offset=16
  (local.get $_M0L3ptrS886)
  (local.get $_M0L7best__wS318))
 (i32.store
  (local.get $_M0L3ptrS886)
  (local.get $_M0L1wS319))
 (i32.store offset=12
  (local.get $_M0L3ptrS886)
  (local.get $_M0L8out__bufS331))
 (i32.store offset=8
  (local.get $_M0L3ptrS886)
  (local.get $_M0L4gridS332))
 (local.set $_M0L10is__betterS341
  (local.get $_M0L3ptrS886))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 90 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN8write__tS320
  (local.get $_M0L8write__tS320)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 90 12 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 91 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS885
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS885)
  (i32.const 1))
 (local.set $_M0L1tS362
  (local.get $_M0L3ptrS885))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 92 2 ;)
 (loop $loop:363
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 92 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS857
    (i32.load
     (local.get $_M0L1tS362)))
   (i32.const 8))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 92 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 4 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 7 ;)
    (local.set $_M0L3valS858
     (i32.load
      (local.get $_M0L1tS362)))
    (call $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN10is__betterS341
     (local.get $_M0L10is__betterS341)
     (local.get $_M0L3valS858))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 19 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 22 ;)
      (local.set $_M0L3valS859
       (i32.load
        (local.get $_M0L1tS362)))
      (call $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN8write__tS320
       (local.get $_M0L8write__tS320)
       (local.get $_M0L3valS859))
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 32 ;)
      (drop))
     (else))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 93 34 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 94 4 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 94 8 ;)
    (i32.add
     (local.tee $_M0L3valS861
      (i32.load
       (local.get $_M0L1tS362)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 94 13 ;)
    (local.set $_M0L6_2atmpS860)
    (i32.store
     (local.get $_M0L1tS362)
     (local.get $_M0L6_2atmpS860))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 94 13 ;)
    (drop)
    (br $loop:363))
   (else
    (call $moonbit.decref
     (local.get $_M0L1tS362))
    (call $moonbit.decref
     (local.get $_M0L10is__betterS341))
    (call $moonbit.decref
     (local.get $_M0L8write__tS320)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 95 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 2 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 3 ;)
 (i32.load
  (local.get $_M0L7best__hS316))
 (call $moonbit.decref
  (local.get $_M0L7best__hS316))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 13 ;)
 (local.set $_M0L3valS862)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 15 ;)
 (i32.load
  (local.get $_M0L7best__wS318))
 (call $moonbit.decref
  (local.get $_M0L7best__wS318))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 25 ;)
 (local.set $_M0L3valS863)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS884
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS884)
  (local.get $_M0L3valS863))
 (i32.store
  (local.get $_M0L3ptrS884)
  (local.get $_M0L3valS862))
 (local.get $_M0L3ptrS884)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 96 26 ;))
(func $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN10is__betterS341 (param $_M0L6_2aenvS841 i32) (param $_M0L1tS342 i32) (result i32)
 (local $_M0L7best__hS316 i32)
 (local $_M0L1hS317 i32)
 (local $_M0L7best__wS318 i32)
 (local $_M0L1wS319 i32)
 (local $_M0L8out__bufS331 i32)
 (local $_M0L4gridS332 i32)
 (local $_M0L2ohS344 i32)
 (local $_M0L2owS345 i32)
 (local $_M0L1iS346 i32)
 (local $_M0L1rS347 i32)
 (local $_M0L1cS348 i32)
 (local $_M0L2srS350 i32)
 (local $_M0L2scS351 i32)
 (local $_M0L1vS352 i32)
 (local $_M0L3curS353 i32)
 (local $_M0L7_2abindS354 i32)
 (local $_M0L5_2asrS355 i32)
 (local $_M0L5_2ascS356 i32)
 (local $_M0L7_2abindS359 i32)
 (local $_M0L5_2aohS360 i32)
 (local $_M0L5_2aowS361 i32)
 (local $_M0L3valS842 i32)
 (local $_M0L3valS843 i32)
 (local $_M0L3valS844 i32)
 (local $_M0L3valS845 i32)
 (local $_M0L6_2atmpS846 i32)
 (local $_M0L3valS847 i32)
 (local $_M0L6_2atmpS848 i32)
 (local $_M0L3valS849 i32)
 (local $_M0L3valS850 i32)
 (local $_M0L6_2atmpS851 i32)
 (local $_M0L6_2atmpS852 i32)
 (local $_M0L3valS853 i32)
 (local $_M0L3valS854 i32)
 (local $_M0L6_2atmpS855 i32)
 (local $_M0L3valS856 i32)
 (local $_M0L3ptrS892 i32)
 (local $_M0L3ptrS893 i32)
 (local $_M0L3ptrS894 i32)
 (; prologue_end ;)
 (local.set $_M0L7best__hS316
  (i32.load offset=20
   (local.get $_M0L6_2aenvS841)))
 (local.set $_M0L1hS317
  (i32.load offset=4
   (local.get $_M0L6_2aenvS841)))
 (local.set $_M0L7best__wS318
  (i32.load offset=16
   (local.get $_M0L6_2aenvS841)))
 (local.set $_M0L1wS319
  (i32.load
   (local.get $_M0L6_2aenvS841)))
 (local.set $_M0L8out__bufS331
  (i32.load offset=12
   (local.get $_M0L6_2aenvS841)))
 (local.set $_M0L4gridS332
  (i32.load offset=8
   (local.get $_M0L6_2aenvS841)))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 70 4 ;)
 (block $join:343
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 70 4 ;)
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 70 19 ;)
  (call $_M0FP48moonarc34rhae3src4rhae13d4__out__dims
   (local.get $_M0L1hS317)
   (local.get $_M0L1wS319)
   (local.get $_M0L1tS342))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 70 39 ;)
  (local.tee $_M0L7_2abindS359)
  (i32.load)
  (local.set $_M0L5_2aohS360)
  (i32.load offset=4
   (local.get $_M0L7_2abindS359))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS359))
  (local.set $_M0L5_2aowS361)
  (local.get $_M0L5_2aohS360)
  (local.set $_M0L2owS345
   (local.get $_M0L5_2aowS361))
  (local.set $_M0L2ohS344)
  (br $join:343))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 4 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 7 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 7 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 13 ;)
 (i32.load
  (local.get $_M0L7best__hS316))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 23 ;)
 (local.set $_M0L3valS843)
 (local.get $_M0L2ohS344)
 (i32.ne
  (local.get $_M0L3valS843))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 23 ;)
 (if (result i32)
  (then
   (i32.const 1))
  (else
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 27 ;)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 33 ;)
   (i32.load
    (local.get $_M0L7best__wS318))
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 71 43 ;)
   (local.set $_M0L3valS842)
   (local.get $_M0L2owS345)
   (i32.ne
    (local.get $_M0L3valS842))
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
  (local.tee $_M0L3ptrS894
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS894)
  (i32.const 0))
 (local.set $_M0L1iS346
  (local.get $_M0L3ptrS894))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 73 4 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS893
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS893)
  (i32.const 0))
 (local.set $_M0L1rS347
  (local.get $_M0L3ptrS893))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 74 4 ;)
 (loop $loop:358
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 74 10 ;)
  (i32.lt_s
   (local.tee $_M0L3valS844
    (i32.load
     (local.get $_M0L1rS347)))
   (local.get $_M0L2ohS344))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 74 16 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 75 6 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS892
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS892)
     (i32.const 0))
    (local.set $_M0L1cS348
     (local.get $_M0L3ptrS892))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 76 6 ;)
    (loop $loop:357
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 76 12 ;)
     (i32.lt_s
      (local.tee $_M0L3valS845
       (i32.load
        (local.get $_M0L1cS348)))
      (local.get $_M0L2owS345))
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 76 18 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 77 8 ;)
       (block $outer/891 (result i32)
        (block $join:349
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 77 8 ;)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 77 23 ;)
         (local.set $_M0L3valS853
          (i32.load
           (local.get $_M0L1rS347)))
         (local.set $_M0L3valS854
          (i32.load
           (local.get $_M0L1cS348)))
         (call $_M0FP48moonarc34rhae3src4rhae7d4__src
          (local.get $_M0L3valS853)
          (local.get $_M0L3valS854)
          (local.get $_M0L1hS317)
          (local.get $_M0L1wS319)
          (local.get $_M0L1tS342))
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 77 44 ;)
         (local.tee $_M0L7_2abindS354)
         (i32.load)
         (local.set $_M0L5_2asrS355)
         (i32.load offset=4
          (local.get $_M0L7_2abindS354))
         (call $moonbit.decref
          (local.get $_M0L7_2abindS354))
         (local.set $_M0L5_2ascS356)
         (local.get $_M0L5_2asrS355)
         (local.set $_M0L2scS351
          (local.get $_M0L5_2ascS356))
         (local.set $_M0L2srS350)
         (br $join:349))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 16 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 21 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 21 ;)
        (i32.mul
         (local.get $_M0L2srS350)
         (local.get $_M0L1wS319))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 27 ;)
        (local.tee $_M0L6_2atmpS852)
        (local.get $_M0L2scS351)
        (i32.add)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 32 ;)
        (local.set $_M0L6_2atmpS851)
        (call $_M0MPC15array5Array2atGiE
         (local.get $_M0L4gridS332)
         (local.get $_M0L6_2atmpS851))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 78 33 ;)
        (local.set $_M0L1vS352)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 79 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 79 18 ;)
        (local.set $_M0L3valS850
         (i32.load
          (local.get $_M0L1iS346)))
        (call $_M0MPC15array5Array2atGiE
         (local.get $_M0L8out__bufS331)
         (local.get $_M0L3valS850))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 79 28 ;)
        (local.set $_M0L3curS353)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 80 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 80 11 ;)
        (i32.lt_s
         (local.get $_M0L1vS352)
         (local.get $_M0L3curS353))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 80 18 ;)
        (if
         (then
          (call $moonbit.decref
           (local.get $_M0L1cS348))
          (call $moonbit.decref
           (local.get $_M0L1rS347))
          (call $moonbit.decref
           (local.get $_M0L1iS346))
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
         (local.get $_M0L1vS352)
         (local.get $_M0L3curS353))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 81 18 ;)
        (if
         (then
          (call $moonbit.decref
           (local.get $_M0L1cS348))
          (call $moonbit.decref
           (local.get $_M0L1rS347))
          (call $moonbit.decref
           (local.get $_M0L1iS346))
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
         (local.tee $_M0L3valS847
          (i32.load
           (local.get $_M0L1iS346)))
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 82 17 ;)
        (local.set $_M0L6_2atmpS846)
        (i32.store
         (local.get $_M0L1iS346)
         (local.get $_M0L6_2atmpS846))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 82 17 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 12 ;)
        (i32.add
         (local.tee $_M0L3valS849
          (i32.load
           (local.get $_M0L1cS348)))
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 17 ;)
        (local.set $_M0L6_2atmpS848)
        (i32.store
         (local.get $_M0L1cS348)
         (local.get $_M0L6_2atmpS848))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 17 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 17 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 17 ;))
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 83 17 ;)
       (drop)
       (br $loop:357))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS348)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 84 7 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 85 6 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 85 10 ;)
    (i32.add
     (local.tee $_M0L3valS856
      (i32.load
       (local.get $_M0L1rS347)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 85 15 ;)
    (local.set $_M0L6_2atmpS855)
    (i32.store
     (local.get $_M0L1rS347)
     (local.get $_M0L6_2atmpS855))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 85 15 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 85 15 ;)
    (drop)
    (br $loop:358))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS347))
    (call $moonbit.decref
     (local.get $_M0L1iS346)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 86 5 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 87 4 ;)
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 87 9 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 87 9 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 87 9 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 87 9 ;))
(func $_M0FP48moonarc34rhae3src4rhae18canonicalize__gridN8write__tS320 (param $_M0L6_2aenvS826 i32) (param $_M0L1tS321 i32) (result i32)
 (local $_M0L7best__tS315 i32)
 (local $_M0L7best__hS316 i32)
 (local $_M0L1hS317 i32)
 (local $_M0L7best__wS318 i32)
 (local $_M0L1wS319 i32)
 (local $_M0L2ohS323 i32)
 (local $_M0L2owS324 i32)
 (local $_M0L1iS325 i32)
 (local $_M0L1rS326 i32)
 (local $_M0L1cS327 i32)
 (local $_M0L2srS329 i32)
 (local $_M0L2scS330 i32)
 (local $_M0L8out__bufS331 i32)
 (local $_M0L4gridS332 i32)
 (local $_M0L7_2abindS333 i32)
 (local $_M0L5_2asrS334 i32)
 (local $_M0L5_2ascS335 i32)
 (local $_M0L7_2abindS338 i32)
 (local $_M0L5_2aohS339 i32)
 (local $_M0L5_2aowS340 i32)
 (local $_M0L3valS827 i32)
 (local $_M0L3valS828 i32)
 (local $_M0L3valS829 i32)
 (local $_M0L6_2atmpS830 i32)
 (local $_M0L6_2atmpS831 i32)
 (local $_M0L6_2atmpS832 i32)
 (local $_M0L6_2atmpS833 i32)
 (local $_M0L3valS834 i32)
 (local $_M0L6_2atmpS835 i32)
 (local $_M0L3valS836 i32)
 (local $_M0L3valS837 i32)
 (local $_M0L3valS838 i32)
 (local $_M0L6_2atmpS839 i32)
 (local $_M0L3valS840 i32)
 (local $_M0L3ptrS896 i32)
 (local $_M0L3ptrS897 i32)
 (local $_M0L3ptrS898 i32)
 (; prologue_end ;)
 (local.set $_M0L7best__tS315
  (i32.load offset=24
   (local.get $_M0L6_2aenvS826)))
 (local.set $_M0L7best__hS316
  (i32.load offset=20
   (local.get $_M0L6_2aenvS826)))
 (local.set $_M0L1hS317
  (i32.load offset=4
   (local.get $_M0L6_2aenvS826)))
 (local.set $_M0L7best__wS318
  (i32.load offset=16
   (local.get $_M0L6_2aenvS826)))
 (local.set $_M0L1wS319
  (i32.load
   (local.get $_M0L6_2aenvS826)))
 (local.set $_M0L8out__bufS331
  (i32.load offset=12
   (local.get $_M0L6_2aenvS826)))
 (local.set $_M0L4gridS332
  (i32.load offset=8
   (local.get $_M0L6_2aenvS826)))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 50 4 ;)
 (block $join:322
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 50 4 ;)
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 50 19 ;)
  (call $_M0FP48moonarc34rhae3src4rhae13d4__out__dims
   (local.get $_M0L1hS317)
   (local.get $_M0L1wS319)
   (local.get $_M0L1tS321))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 50 39 ;)
  (local.tee $_M0L7_2abindS338)
  (i32.load)
  (local.set $_M0L5_2aohS339)
  (i32.load offset=4
   (local.get $_M0L7_2abindS338))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS338))
  (local.set $_M0L5_2aowS340)
  (local.get $_M0L5_2aohS339)
  (local.set $_M0L2owS324
   (local.get $_M0L5_2aowS340))
  (local.set $_M0L2ohS323)
  (br $join:322))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 51 4 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS898
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS898)
  (i32.const 0))
 (local.set $_M0L1iS325
  (local.get $_M0L3ptrS898))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 52 4 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS897
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS897)
  (i32.const 0))
 (local.set $_M0L1rS326
  (local.get $_M0L3ptrS897))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 53 4 ;)
 (loop $loop:337
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 53 10 ;)
  (i32.lt_s
   (local.tee $_M0L3valS827
    (i32.load
     (local.get $_M0L1rS326)))
   (local.get $_M0L2ohS323))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 53 16 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 54 6 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS896
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS896)
     (i32.const 0))
    (local.set $_M0L1cS327
     (local.get $_M0L3ptrS896))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 55 6 ;)
    (loop $loop:336
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 55 12 ;)
     (i32.lt_s
      (local.tee $_M0L3valS828
       (i32.load
        (local.get $_M0L1cS327)))
      (local.get $_M0L2owS324))
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 55 18 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 56 8 ;)
       (block $outer/895 (result i32)
        (block $join:328
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 56 8 ;)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 56 23 ;)
         (local.set $_M0L3valS837
          (i32.load
           (local.get $_M0L1rS326)))
         (local.set $_M0L3valS838
          (i32.load
           (local.get $_M0L1cS327)))
         (call $_M0FP48moonarc34rhae3src4rhae7d4__src
          (local.get $_M0L3valS837)
          (local.get $_M0L3valS838)
          (local.get $_M0L1hS317)
          (local.get $_M0L1wS319)
          (local.get $_M0L1tS321))
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 56 44 ;)
         (local.tee $_M0L7_2abindS333)
         (i32.load)
         (local.set $_M0L5_2asrS334)
         (i32.load offset=4
          (local.get $_M0L7_2abindS333))
         (call $moonbit.decref
          (local.get $_M0L7_2abindS333))
         (local.set $_M0L5_2ascS335)
         (local.get $_M0L5_2asrS334)
         (local.set $_M0L2scS330
          (local.get $_M0L5_2ascS335))
         (local.set $_M0L2srS329)
         (br $join:328))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 8 ;)
        (local.set $_M0L3valS829
         (i32.load
          (local.get $_M0L1iS325)))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 21 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 26 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 26 ;)
        (i32.mul
         (local.get $_M0L2srS329)
         (local.get $_M0L1wS319))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 32 ;)
        (local.tee $_M0L6_2atmpS832)
        (local.get $_M0L2scS330)
        (i32.add)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 37 ;)
        (local.set $_M0L6_2atmpS831)
        (call $_M0MPC15array5Array2atGiE
         (local.get $_M0L4gridS332)
         (local.get $_M0L6_2atmpS831))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 38 ;)
        (local.set $_M0L6_2atmpS830)
        (call $_M0MPC15array5Array3setGiE
         (local.get $_M0L8out__bufS331)
         (local.get $_M0L3valS829)
         (local.get $_M0L6_2atmpS830))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 57 38 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 58 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 58 12 ;)
        (i32.add
         (local.tee $_M0L3valS834
          (i32.load
           (local.get $_M0L1iS325)))
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 58 17 ;)
        (local.set $_M0L6_2atmpS833)
        (i32.store
         (local.get $_M0L1iS325)
         (local.get $_M0L6_2atmpS833))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 58 17 ;)
        (drop)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 59 8 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 59 12 ;)
        (i32.add
         (local.tee $_M0L3valS836
          (i32.load
           (local.get $_M0L1cS327)))
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 59 17 ;)
        (local.set $_M0L6_2atmpS835)
        (i32.store
         (local.get $_M0L1cS327)
         (local.get $_M0L6_2atmpS835))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 59 17 ;))
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 59 17 ;)
       (drop)
       (br $loop:336))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS327)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 60 7 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 61 6 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 61 10 ;)
    (i32.add
     (local.tee $_M0L3valS840
      (i32.load
       (local.get $_M0L1rS326)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 61 15 ;)
    (local.set $_M0L6_2atmpS839)
    (i32.store
     (local.get $_M0L1rS326)
     (local.get $_M0L6_2atmpS839))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 61 15 ;)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 61 15 ;)
    (drop)
    (br $loop:337))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS326))
    (call $moonbit.decref
     (local.get $_M0L1iS325)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 62 5 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 63 4 ;)
 (i32.store
  (local.get $_M0L7best__hS316)
  (local.get $_M0L2ohS323))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 63 19 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 64 4 ;)
 (i32.store
  (local.get $_M0L7best__wS318)
  (local.get $_M0L2owS324))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 64 19 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 65 4 ;)
 (i32.store
  (local.get $_M0L7best__tS315)
  (local.get $_M0L1tS321))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 65 18 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 65 18 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 65 18 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 65 18 ;))
(func $_M0FP48moonarc34rhae3src4rhae13d4__out__dims (param $_M0L1hS313 i32) (param $_M0L1wS312 i32) (param $_M0L1tS314 i32) (result i32)
 (local $_M0L3ptrS899 i32)
 (local $_M0L3ptrS900 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 30 2 ;)
 (block $join:311
  (if (result i32)
   (i32.eq
    (local.get $_M0L1tS314)
    (i32.const 1))
   (then
    (br $join:311))
   (else
    (if (result i32)
     (i32.eq
      (local.get $_M0L1tS314)
      (i32.const 3))
     (then
      (br $join:311))
     (else
      (if (result i32)
       (i32.eq
        (local.get $_M0L1tS314)
        (i32.const 6))
       (then
        (br $join:311))
       (else
        (if (result i32)
         (i32.eq
          (local.get $_M0L1tS314)
          (i32.const 7))
         (then
          (br $join:311))
         (else
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 32 9 ;)
          (call $moonbit.store_object_meta
           (local.tee $_M0L3ptrS899
            (call $moonbit.gc.malloc
             (i32.const 8)))
           (i32.const 1048576))
          (i32.store offset=4
           (local.get $_M0L3ptrS899)
           (local.get $_M0L1wS312))
          (i32.store
           (local.get $_M0L3ptrS899)
           (local.get $_M0L1hS313))
          (local.get $_M0L3ptrS899)
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 32 15 ;)))))))))
  (return))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 31 21 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS900
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS900)
  (local.get $_M0L1hS313))
 (i32.store
  (local.get $_M0L3ptrS900)
  (local.get $_M0L1wS312))
 (local.get $_M0L3ptrS900)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 31 27 ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 33 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae7d4__src (param $_M0L6out__rS307 i32) (param $_M0L6out__cS308 i32) (param $_M0L1hS309 i32) (param $_M0L1wS310 i32) (param $_M0L1tS306 i32) (result i32)
 (local $_M0L6_2atmpS810 i32)
 (local $_M0L6_2atmpS811 i32)
 (local $_M0L6_2atmpS812 i32)
 (local $_M0L6_2atmpS813 i32)
 (local $_M0L6_2atmpS814 i32)
 (local $_M0L6_2atmpS815 i32)
 (local $_M0L6_2atmpS816 i32)
 (local $_M0L6_2atmpS817 i32)
 (local $_M0L6_2atmpS818 i32)
 (local $_M0L6_2atmpS819 i32)
 (local $_M0L6_2atmpS820 i32)
 (local $_M0L6_2atmpS821 i32)
 (local $_M0L6_2atmpS822 i32)
 (local $_M0L6_2atmpS823 i32)
 (local $_M0L6_2atmpS824 i32)
 (local $_M0L6_2atmpS825 i32)
 (local $_M0L3ptrS901 i32)
 (local $_M0L3ptrS902 i32)
 (local $_M0L3ptrS903 i32)
 (local $_M0L3ptrS904 i32)
 (local $_M0L3ptrS905 i32)
 (local $_M0L3ptrS906 i32)
 (local $_M0L3ptrS907 i32)
 (local $_M0L3ptrS908 i32)
 (local $_M0L3ptrS909 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 16 2 ;)
 (block $switch_int/910 (result i32)
  (block $switch_default/911
   (block $switch_int_7/919
    (block $switch_int_6/918
     (block $switch_int_5/917
      (block $switch_int_4/916
       (block $switch_int_3/915
        (block $switch_int_2/914
         (block $switch_int_1/913
          (block $switch_int_0/912
           (local.get $_M0L1tS306)
           (br_table
            $switch_int_0/912
            $switch_int_1/913
            $switch_int_2/914
            $switch_int_3/915
            $switch_int_4/916
            $switch_int_5/917
            $switch_int_6/918
            $switch_int_7/919
            $switch_default/911
            ))
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 17 9 ;)
          (call $moonbit.store_object_meta
           (local.tee $_M0L3ptrS902
            (call $moonbit.gc.malloc
             (i32.const 8)))
           (i32.const 1048576))
          (i32.store offset=4
           (local.get $_M0L3ptrS902)
           (local.get $_M0L6out__cS308))
          (i32.store
           (local.get $_M0L3ptrS902)
           (local.get $_M0L6out__rS307))
          (local.get $_M0L3ptrS902)
          (; source_pos moonarc3/rhae/src/rhae canon.mbt 17 35 ;)
          (br $switch_int/910))
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 9 ;)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 10 ;)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 10 ;)
         (i32.sub
          (local.get $_M0L1hS309)
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 13 ;)
         (local.tee $_M0L6_2atmpS811)
         (local.get $_M0L6out__cS308)
         (i32.sub)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 19 ;)
         (local.set $_M0L6_2atmpS810)
         (call $moonbit.store_object_meta
          (local.tee $_M0L3ptrS903
           (call $moonbit.gc.malloc
            (i32.const 8)))
          (i32.const 1048576))
         (i32.store offset=4
          (local.get $_M0L3ptrS903)
          (local.get $_M0L6out__rS307))
         (i32.store
          (local.get $_M0L3ptrS903)
          (local.get $_M0L6_2atmpS810))
         (local.get $_M0L3ptrS903)
         (; source_pos moonarc3/rhae/src/rhae canon.mbt 18 35 ;)
         (br $switch_int/910))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 9 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 10 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 10 ;)
        (i32.sub
         (local.get $_M0L1hS309)
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 13 ;)
        (local.tee $_M0L6_2atmpS815)
        (local.get $_M0L6out__rS307)
        (i32.sub)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 19 ;)
        (local.set $_M0L6_2atmpS812)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 23 ;)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 23 ;)
        (i32.sub
         (local.get $_M0L1wS310)
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 26 ;)
        (local.tee $_M0L6_2atmpS814)
        (local.get $_M0L6out__cS308)
        (i32.sub)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 32 ;)
        (local.set $_M0L6_2atmpS813)
        (call $moonbit.store_object_meta
         (local.tee $_M0L3ptrS904
          (call $moonbit.gc.malloc
           (i32.const 8)))
         (i32.const 1048576))
        (i32.store offset=4
         (local.get $_M0L3ptrS904)
         (local.get $_M0L6_2atmpS813))
        (i32.store
         (local.get $_M0L3ptrS904)
         (local.get $_M0L6_2atmpS812))
        (local.get $_M0L3ptrS904)
        (; source_pos moonarc3/rhae/src/rhae canon.mbt 19 35 ;)
        (br $switch_int/910))
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 9 ;)
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 23 ;)
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 23 ;)
       (i32.sub
        (local.get $_M0L1wS310)
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 26 ;)
       (local.tee $_M0L6_2atmpS817)
       (local.get $_M0L6out__rS307)
       (i32.sub)
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 32 ;)
       (local.set $_M0L6_2atmpS816)
       (call $moonbit.store_object_meta
        (local.tee $_M0L3ptrS905
         (call $moonbit.gc.malloc
          (i32.const 8)))
        (i32.const 1048576))
       (i32.store offset=4
        (local.get $_M0L3ptrS905)
        (local.get $_M0L6_2atmpS816))
       (i32.store
        (local.get $_M0L3ptrS905)
        (local.get $_M0L6out__cS308))
       (local.get $_M0L3ptrS905)
       (; source_pos moonarc3/rhae/src/rhae canon.mbt 20 35 ;)
       (br $switch_int/910))
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 9 ;)
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 23 ;)
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 23 ;)
      (i32.sub
       (local.get $_M0L1wS310)
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 26 ;)
      (local.tee $_M0L6_2atmpS819)
      (local.get $_M0L6out__cS308)
      (i32.sub)
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 32 ;)
      (local.set $_M0L6_2atmpS818)
      (call $moonbit.store_object_meta
       (local.tee $_M0L3ptrS906
        (call $moonbit.gc.malloc
         (i32.const 8)))
       (i32.const 1048576))
      (i32.store offset=4
       (local.get $_M0L3ptrS906)
       (local.get $_M0L6_2atmpS818))
      (i32.store
       (local.get $_M0L3ptrS906)
       (local.get $_M0L6out__rS307))
      (local.get $_M0L3ptrS906)
      (; source_pos moonarc3/rhae/src/rhae canon.mbt 21 35 ;)
      (br $switch_int/910))
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 9 ;)
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 10 ;)
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 10 ;)
     (i32.sub
      (local.get $_M0L1hS309)
      (i32.const 1))
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 13 ;)
     (local.tee $_M0L6_2atmpS821)
     (local.get $_M0L6out__rS307)
     (i32.sub)
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 19 ;)
     (local.set $_M0L6_2atmpS820)
     (call $moonbit.store_object_meta
      (local.tee $_M0L3ptrS907
       (call $moonbit.gc.malloc
        (i32.const 8)))
      (i32.const 1048576))
     (i32.store offset=4
      (local.get $_M0L3ptrS907)
      (local.get $_M0L6out__cS308))
     (i32.store
      (local.get $_M0L3ptrS907)
      (local.get $_M0L6_2atmpS820))
     (local.get $_M0L3ptrS907)
     (; source_pos moonarc3/rhae/src/rhae canon.mbt 22 35 ;)
     (br $switch_int/910))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 23 9 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS908
      (call $moonbit.gc.malloc
       (i32.const 8)))
     (i32.const 1048576))
    (i32.store offset=4
     (local.get $_M0L3ptrS908)
     (local.get $_M0L6out__rS307))
    (i32.store
     (local.get $_M0L3ptrS908)
     (local.get $_M0L6out__cS308))
    (local.get $_M0L3ptrS908)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 23 35 ;)
    (br $switch_int/910))
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 9 ;)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 10 ;)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 10 ;)
   (i32.sub
    (local.get $_M0L1wS310)
    (i32.const 1))
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 13 ;)
   (local.tee $_M0L6_2atmpS825)
   (local.get $_M0L6out__cS308)
   (i32.sub)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 19 ;)
   (local.set $_M0L6_2atmpS822)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 23 ;)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 23 ;)
   (i32.sub
    (local.get $_M0L1hS309)
    (i32.const 1))
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 26 ;)
   (local.tee $_M0L6_2atmpS824)
   (local.get $_M0L6out__rS307)
   (i32.sub)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 32 ;)
   (local.set $_M0L6_2atmpS823)
   (call $moonbit.store_object_meta
    (local.tee $_M0L3ptrS909
     (call $moonbit.gc.malloc
      (i32.const 8)))
    (i32.const 1048576))
   (i32.store offset=4
    (local.get $_M0L3ptrS909)
    (local.get $_M0L6_2atmpS823))
   (i32.store
    (local.get $_M0L3ptrS909)
    (local.get $_M0L6_2atmpS822))
   (local.get $_M0L3ptrS909)
   (; source_pos moonarc3/rhae/src/rhae canon.mbt 24 35 ;)
   (br $switch_int/910))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 25 9 ;)
  (call $moonbit.store_object_meta
   (local.tee $_M0L3ptrS901
    (call $moonbit.gc.malloc
     (i32.const 8)))
   (i32.const 1048576))
  (i32.store offset=4
   (local.get $_M0L3ptrS901)
   (local.get $_M0L6out__cS308))
  (i32.store
   (local.get $_M0L3ptrS901)
   (local.get $_M0L6out__rS307))
  (local.get $_M0L3ptrS901)
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 25 35 ;)
  (br $switch_int/910))
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 26 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae14decode__action (param $_M0L3rawS305 i32) (result i32)
 (local $_M0L1rS304 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 8 2 ;)
 (block $join:303
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 9 ;)
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 9 ;)
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 9 ;)
  (i32.ge_s
   (local.get $_M0L3rawS305)
   (i32.const 1))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 15 ;)
  (if (result i32)
   (then
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 19 ;)
    (i32.le_s
     (local.get $_M0L3rawS305)
     (i32.const 7))
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 25 ;))
   (else
    (i32.const 0)))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 25 ;)
  (if (result i32)
   (then
    (local.set $_M0L1rS304
     (local.get $_M0L3rawS305))
    (br $join:303))
   (else
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 10 9 ;)
    (i32.const 1)
    (; source_pos moonarc3/rhae/src/rhae canon.mbt 10 10 ;)))
  (; source_pos moonarc3/rhae/src/rhae canon.mbt 9 25 ;)
  (return))
 (local.get $_M0L1rS304)
 (; source_pos moonarc3/rhae/src/rhae canon.mbt 11 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae14encode__action (param $_M0L1aS302 i32) (result i32)
 (; prologue_end ;)
 (local.get $_M0L1aS302))
(func $_M0FP48moonarc34rhae3src4rhae22rhae__hash__and__check (param $_M0L1hS295 i32) (param $_M0L1wS296 i32) (result i32)
 (local $_M0L2loS294 i32)
 (local $_M0L2hiS297 i32)
 (local $_M0L3visS298 i32)
 (local $_M0L3tthS299 i32)
 (local $_M0L7_2abindS300 i32)
 (local $_M0L4_2axS301 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 68 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 68 11 ;)
 (call $_M0FP48moonarc34rhae3src4rhae21rhae__canonical__hash
  (local.get $_M0L1hS295)
  (local.get $_M0L1wS296))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 68 36 ;)
 (local.set $_M0L2loS294)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 69 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 69 11 ;)
 (i32.load
  (global.get $_M0FP48moonarc34rhae3src4rhae8hash__hi))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 69 22 ;)
 (local.set $_M0L2hiS297)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 12 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 70 15 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14visited__check
  (local.get $_M0L2loS294)
  (local.get $_M0L2hiS297))
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
 (local.set $_M0L3visS298)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 12 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 18 ;)
 (call $_M0FP48moonarc34rhae3src4rhae10tt__lookup
  (local.get $_M0L2loS294)
  (local.get $_M0L2hiS297))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 71 35 ;)
 (local.tee $_M0L7_2abindS300)
 (i32.load)
 (call $moonbit.decref
  (local.get $_M0L7_2abindS300))
 (local.tee $_M0L4_2axS301)
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
 (local.set $_M0L3tthS299)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 2 ;)
 (i32.or
  (local.get $_M0L3visS298)
  (local.get $_M0L3tthS299))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 11 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 11 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 11 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 11 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 72 11 ;))
(func $_M0FP48moonarc34rhae3src4rhae15rhae__tt__store (param $_M0L2loS290 i32) (param $_M0L2hiS291 i32) (param $_M0L6actionS292 i32) (param $_M0L5scoreS293 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 64 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae9tt__store
  (local.get $_M0L2loS290)
  (local.get $_M0L2hiS291)
  (local.get $_M0L6actionS292)
  (local.get $_M0L5scoreS293))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 64 33 ;))
(func $_M0FP48moonarc34rhae3src4rhae16rhae__tt__lookup (param $_M0L2loS286 i32) (param $_M0L2hiS287 i32) (result i32)
 (local $_M0L6actionS283 i32)
 (local $_M0L5foundS284 i32)
 (local $_M0L7_2abindS285 i32)
 (local $_M0L8_2afoundS288 i32)
 (local $_M0L9_2aactionS289 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 59 2 ;)
 (block $join:282
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 59 2 ;)
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 59 27 ;)
  (call $_M0FP48moonarc34rhae3src4rhae10tt__lookup
   (local.get $_M0L2loS286)
   (local.get $_M0L2hiS287))
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 59 44 ;)
  (local.tee $_M0L7_2abindS285)
  (i32.load)
  (local.set $_M0L8_2afoundS288)
  (i32.load offset=4
   (local.get $_M0L7_2abindS285))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS285))
  (local.tee $_M0L9_2aactionS289)
  (local.set $_M0L5foundS284
   (local.get $_M0L8_2afoundS288))
  (local.set $_M0L6actionS283)
  (br $join:282))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 60 2 ;)
 (if (result i32)
  (local.get $_M0L5foundS284)
  (then
   (local.get $_M0L6actionS283))
  (else
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 60 29 ;)
   (i32.const -1)
   (; source_pos moonarc3/rhae/src/rhae exports.mbt 60 31 ;)))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 60 33 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 60 33 ;))
(func $_M0FP48moonarc34rhae3src4rhae10rhae__topk (param $_M0L7n__candS278 i32) (param $_M0L1kS281 i32) (result i32)
 (local $_M0L5pairsS276 i32)
 (local $_M0L1iS277 i32)
 (local $_M0L1bS279 i32)
 (local $_M0L3valS792 i32)
 (local $_M0L6_2atmpS793 i32)
 (local $_M0L6_2atmpS794 i32)
 (local $_M0L3valS795 i32)
 (local $_M0L6_2atmpS796 i32)
 (local $_M0L6_2atmpS797 i32)
 (local $_M0L6_2atmpS798 i32)
 (local $_M0L6_2atmpS799 i32)
 (local $_M0L6_2atmpS800 i32)
 (local $_M0L6_2atmpS801 i32)
 (local $_M0L6_2atmpS802 i32)
 (local $_M0L6_2atmpS803 i32)
 (local $_M0L6_2atmpS804 i32)
 (local $_M0L6_2atmpS805 i32)
 (local $_M0L3valS806 i32)
 (local $_M0L6_2atmpS807 i32)
 (local $_M0L3valS808 i32)
 (local $_M0L3valS809 i32)
 (local $_M0L3ptrS920 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 47 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 47 27 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 14)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 47 45 ;)
 (local.set $_M0L5pairsS276)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 48 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS920
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS920)
  (i32.const 0))
 (local.set $_M0L1iS277
  (local.get $_M0L3ptrS920))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 49 2 ;)
 (loop $loop:280
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 49 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS792
    (i32.load
     (local.get $_M0L1iS277)))
   (local.get $_M0L7n__candS278))
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 49 18 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 50 4 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 50 12 ;)
    (i32.mul
     (local.tee $_M0L3valS809
      (i32.load
       (local.get $_M0L1iS277)))
     (i32.const 13))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 50 18 ;)
    (local.set $_M0L1bS279)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 4 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 10 ;)
    (i32.mul
     (local.tee $_M0L3valS795
      (i32.load
       (local.get $_M0L1iS277)))
     (i32.const 2))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 13 ;)
    (local.set $_M0L6_2atmpS793)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 19 ;)
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
     (local.get $_M0L1bS279))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 29 ;)
    (local.set $_M0L6_2atmpS794)
    (call $_M0MPC15array5Array3setGiE
     (local.get $_M0L5pairsS276)
     (local.get $_M0L6_2atmpS793)
     (local.get $_M0L6_2atmpS794))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 51 29 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 4 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 10 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 10 ;)
    (i32.mul
     (local.tee $_M0L3valS806
      (i32.load
       (local.get $_M0L1iS277)))
     (i32.const 2))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 13 ;)
    (local.tee $_M0L6_2atmpS805)
    (i32.const 1)
    (i32.add)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 15 ;)
    (local.set $_M0L6_2atmpS796)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 19 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 19 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 19 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 27 ;)
    (i32.add
     (local.get $_M0L1bS279)
     (i32.const 5))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 30 ;)
    (local.set $_M0L6_2atmpS804)
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
     (local.get $_M0L6_2atmpS804))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 31 ;)
    (local.set $_M0L6_2atmpS801)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 34 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 42 ;)
    (i32.add
     (local.get $_M0L1bS279)
     (i32.const 6))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 45 ;)
    (local.set $_M0L6_2atmpS803)
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
     (local.get $_M0L6_2atmpS803))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 46 ;)
    (local.set $_M0L6_2atmpS802)
    (i32.add
     (local.get $_M0L6_2atmpS801)
     (local.get $_M0L6_2atmpS802))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 46 ;)
    (local.set $_M0L6_2atmpS798)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 49 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 57 ;)
    (i32.add
     (local.get $_M0L1bS279)
     (i32.const 4))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 60 ;)
    (local.set $_M0L6_2atmpS800)
    (call $_M0MPC15array5Array2atGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
     (local.get $_M0L6_2atmpS800))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 61 ;)
    (local.set $_M0L6_2atmpS799)
    (i32.sub
     (local.get $_M0L6_2atmpS798)
     (local.get $_M0L6_2atmpS799))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 61 ;)
    (local.set $_M0L6_2atmpS797)
    (call $_M0MPC15array5Array3setGiE
     (local.get $_M0L5pairsS276)
     (local.get $_M0L6_2atmpS796)
     (local.get $_M0L6_2atmpS797))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 52 61 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 53 4 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 53 8 ;)
    (i32.add
     (local.tee $_M0L3valS808
      (i32.load
       (local.get $_M0L1iS277)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 53 13 ;)
    (local.set $_M0L6_2atmpS807)
    (i32.store
     (local.get $_M0L1iS277)
     (local.get $_M0L6_2atmpS807))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 53 13 ;)
    (; source_pos moonarc3/rhae/src/rhae exports.mbt 53 13 ;)
    (drop)
    (br $loop:280))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS277)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 54 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 55 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae16topk__candidates
  (local.get $_M0L5pairsS276)
  (local.get $_M0L7n__candS278)
  (local.get $_M0L1kS281)
  (global.get $_M0FP48moonarc34rhae3src4rhae9topk__buf))
 (call $moonbit.decref
  (local.get $_M0L5pairsS276))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 55 45 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 55 45 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 55 45 ;))
(func $_M0FP48moonarc34rhae3src4rhae23rhae__build__candidates (param $_M0L5legalS271 i32) (param $_M0L10path__costS272 i32) (param $_M0L8hash__loS273 i32) (param $_M0L10hash__hi__S274 i32) (param $_M0L6max__cS275 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 43 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae22build__candidate__rows
  (local.get $_M0L5legalS271)
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (global.get $_M0FP48moonarc34rhae3src4rhae8vis__buf)
  (local.get $_M0L10path__costS272)
  (local.get $_M0L8hash__loS273)
  (local.get $_M0L10hash__hi__S274)
  (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
  (local.get $_M0L6max__cS275))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 43 93 ;))
(func $_M0FP48moonarc34rhae3src4rhae18rhae__policy__gate (param $_M0L5legalS267 i32) (param $_M0L1hS268 i32) (param $_M0L1wS269 i32) (param $_M0L10n__actionsS270 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 36 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae12policy__gate
  (local.get $_M0L5legalS267)
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
  (local.get $_M0L1hS268)
  (local.get $_M0L1wS269)
  (global.get $_M0FP48moonarc34rhae3src4rhae9risk__buf)
  (local.get $_M0L10n__actionsS270))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 36 66 ;))
(func $_M0FP48moonarc34rhae3src4rhae20rhae__visited__reset (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 33 38 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14visited__reset)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 33 53 ;))
(func $_M0FP48moonarc34rhae3src4rhae19rhae__visited__mark (param $_M0L2loS265 i32) (param $_M0L2hiS266 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 32 55 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13visited__mark
  (local.get $_M0L2loS265)
  (local.get $_M0L2hiS266))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 32 75 ;))
(func $_M0FP48moonarc34rhae3src4rhae20rhae__visited__check (param $_M0L2loS263 i32) (param $_M0L2hiS264 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 29 2 ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 29 5 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14visited__check
  (local.get $_M0L2loS263)
  (local.get $_M0L2hiS264))
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
(func $_M0FP48moonarc34rhae3src4rhae21rhae__canonical__hash (param $_M0L1hS259 i32) (param $_M0L1wS260 i32) (result i32)
 (local $_M0L2loS256 i32)
 (local $_M0L2hiS257 i32)
 (local $_M0L7_2abindS258 i32)
 (local $_M0L5_2aloS261 i32)
 (local $_M0L5_2ahiS262 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 20 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 20 16 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 21 2 ;)
 (block $join:255
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 21 2 ;)
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 21 17 ;)
  (call $_M0FP48moonarc34rhae3src4rhae15canonical__hash
   (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
   (local.get $_M0L1hS259)
   (local.get $_M0L1wS260))
  (; source_pos moonarc3/rhae/src/rhae exports.mbt 21 47 ;)
  (local.tee $_M0L7_2abindS258)
  (i32.load)
  (local.set $_M0L5_2aloS261)
  (i32.load offset=4
   (local.get $_M0L7_2abindS258))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS258))
  (local.set $_M0L5_2ahiS262)
  (local.get $_M0L5_2aloS261)
  (local.set $_M0L2hiS257
   (local.get $_M0L5_2ahiS262))
  (local.set $_M0L2loS256)
  (br $join:255))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 22 2 ;)
 (i32.store
  (global.get $_M0FP48moonarc34rhae3src4rhae8hash__hi)
  (local.get $_M0L2hiS257))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 22 18 ;)
 (drop)
 (local.get $_M0L2loS256)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 23 4 ;))
(func $_M0FP48moonarc34rhae3src4rhae16rhae__invariants (param $_M0L1hS253 i32) (param $_M0L1wS254 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 15 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae19compute__invariants
  (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
  (global.get $_M0FP48moonarc34rhae3src4rhae9prev__buf)
  (local.get $_M0L1hS253)
  (local.get $_M0L1wS254)
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 15 55 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 16 2 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 16 12 ;))
(func $_M0FP48moonarc34rhae3src4rhae9get__topk (param $_M0L1iS252 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 12 34 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae9topk__buf)
  (local.get $_M0L1iS252))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 12 45 ;))
(func $_M0FP48moonarc34rhae3src4rhae8get__mat (param $_M0L1iS251 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 11 34 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8mat__buf)
  (local.get $_M0L1iS251))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 11 44 ;))
(func $_M0FP48moonarc34rhae3src4rhae8get__inv (param $_M0L1iS250 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 10 34 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8inv__buf)
  (local.get $_M0L1iS250))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 10 44 ;))
(func $_M0FP48moonarc34rhae3src4rhae9set__risk (param $_M0L2aiS248 i32) (param $_M0L3valS249 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 9 47 ;)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae9risk__buf)
  (local.get $_M0L2aiS248)
  (local.get $_M0L3valS249))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 9 65 ;))
(func $_M0FP48moonarc34rhae3src4rhae12set__visited (param $_M0L2aiS246 i32) (param $_M0L3valS247 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 8 50 ;)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae8vis__buf)
  (local.get $_M0L2aiS246)
  (local.get $_M0L3valS247))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 8 67 ;))
(func $_M0FP48moonarc34rhae3src4rhae15set__prev__cell (param $_M0L3idxS244 i32) (param $_M0L3valS245 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 7 53 ;)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae9prev__buf)
  (local.get $_M0L3idxS244)
  (local.get $_M0L3valS245))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 7 72 ;))
(func $_M0FP48moonarc34rhae3src4rhae15set__grid__cell (param $_M0L3idxS242 i32) (param $_M0L3valS243 i32) (result i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 6 53 ;)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae9grid__buf)
  (local.get $_M0L3idxS242)
  (local.get $_M0L3valS243))
 (; source_pos moonarc3/rhae/src/rhae exports.mbt 6 72 ;))
(func $_M0FP48moonarc34rhae3src4rhae19compute__invariants (param $_M0L4gridS212 i32) (param $_M0L4prevS227 i32) (param $_M0L1hS208 i32) (param $_M0L1wS209 i32) (param $_M0L3outS233 i32) (result i32)
 (local $_M0L1nS207 i32)
 (local $_M0L3visS210 i32)
 (local $_M0L7n__compS211 i32)
 (local $_M0L5eulerS214 i32)
 (local $_M0L8n__holesS215 i32)
 (local $_M0L9n__colorsS216 i32)
 (local $_M0L2c0S218 i32)
 (local $_M0L2r0S219 i32)
 (local $_M0L2r1S220 i32)
 (local $_M0L2c1S221 i32)
 (local $_M0L2bhS222 i32)
 (local $_M0L2bwS223 i32)
 (local $_M0L3symS224 i32)
 (local $_M0L5deltaS225 i32)
 (local $_M0L1jS226 i32)
 (local $_M0L2nzS229 i32)
 (local $_M0L1kS230 i32)
 (local $_M0L4goalS232 i32)
 (local $_M0L7_2abindS234 i32)
 (local $_M0L5_2ar0S235 i32)
 (local $_M0L5_2ar1S236 i32)
 (local $_M0L5_2ac0S237 i32)
 (local $_M0L5_2ac1S238 i32)
 (local $_M0L7_2abindS239 i32)
 (local $_M0L8_2aeulerS240 i32)
 (local $_M0L11_2an__holesS241 i32)
 (local $_M0L3valS771 i32)
 (local $_M0L6_2atmpS772 i32)
 (local $_M0L6_2atmpS773 i32)
 (local $_M0L3valS774 i32)
 (local $_M0L3valS775 i32)
 (local $_M0L6_2atmpS776 i32)
 (local $_M0L3valS777 i32)
 (local $_M0L6_2atmpS778 i32)
 (local $_M0L3valS779 i32)
 (local $_M0L3valS780 i32)
 (local $_M0L6_2atmpS781 i32)
 (local $_M0L3valS782 i32)
 (local $_M0L6_2atmpS783 i32)
 (local $_M0L3valS784 i32)
 (local $_M0L6_2atmpS785 i32)
 (local $_M0L3valS786 i32)
 (local $_M0L3valS787 i32)
 (local $_M0L6_2atmpS788 i32)
 (local $_M0L3valS789 i32)
 (local $_M0L6_2atmpS790 i32)
 (local $_M0L6_2atmpS791 i32)
 (local $_M0L3ptrS921 i32)
 (local $_M0L3ptrS922 i32)
 (local $_M0L3ptrS923 i32)
 (local $_M0L3ptrS924 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 106 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 106 10 ;)
 (i32.mul
  (local.get $_M0L1hS208)
  (local.get $_M0L1wS209))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 106 15 ;)
 (local.set $_M0L1nS207)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 107 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 107 25 ;)
 (call $_M0MPC15array5Array4makeGiE
  (local.get $_M0L1nS207)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 107 42 ;)
 (local.set $_M0L3visS210)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 108 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 108 17 ;)
 (call $_M0FP48moonarc34rhae3src4rhae17count__components
  (local.get $_M0L4gridS212)
  (local.get $_M0L1hS208)
  (local.get $_M0L1wS209)
  (local.get $_M0L3visS210))
 (call $moonbit.decref
  (local.get $_M0L3visS210))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 108 50 ;)
 (local.set $_M0L7n__compS211)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 109 2 ;)
 (block $join:213
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 109 2 ;)
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 109 25 ;)
  (call $_M0FP48moonarc34rhae3src4rhae12euler__proxy
   (local.get $_M0L4gridS212)
   (local.get $_M0L1hS208)
   (local.get $_M0L1wS209))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 109 48 ;)
  (local.tee $_M0L7_2abindS239)
  (i32.load)
  (local.set $_M0L8_2aeulerS240)
  (i32.load offset=4
   (local.get $_M0L7_2abindS239))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS239))
  (local.set $_M0L11_2an__holesS241)
  (local.get $_M0L8_2aeulerS240)
  (local.set $_M0L8n__holesS215
   (local.get $_M0L11_2an__holesS241))
  (local.set $_M0L5eulerS214)
  (br $join:213))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 110 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 110 17 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13count__colors
  (local.get $_M0L4gridS212)
  (local.get $_M0L1nS207))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 110 38 ;)
 (local.set $_M0L9n__colorsS216)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 111 2 ;)
 (block $join:217
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 111 2 ;)
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 111 25 ;)
  (call $_M0FP48moonarc34rhae3src4rhae4bbox
   (local.get $_M0L4gridS212)
   (local.get $_M0L1hS208)
   (local.get $_M0L1wS209))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 111 41 ;)
  (local.tee $_M0L7_2abindS234)
  (i32.load)
  (local.set $_M0L5_2ar0S235)
  (local.set $_M0L5_2ar1S236
   (i32.load offset=4
    (local.get $_M0L7_2abindS234)))
  (local.set $_M0L5_2ac0S237
   (i32.load offset=8
    (local.get $_M0L7_2abindS234)))
  (i32.load offset=12
   (local.get $_M0L7_2abindS234))
  (call $moonbit.decref
   (local.get $_M0L7_2abindS234))
  (local.set $_M0L5_2ac1S238)
  (local.get $_M0L5_2ac0S237)
  (local.get $_M0L5_2ar0S235)
  (local.get $_M0L5_2ar1S236)
  (local.set $_M0L2c1S221
   (local.get $_M0L5_2ac1S238))
  (local.set $_M0L2r1S220)
  (local.set $_M0L2r0S219)
  (local.set $_M0L2c0S218)
  (br $join:217))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 11 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 14 ;)
 (i32.ge_s
  (local.get $_M0L2r1S220)
  (local.get $_M0L2r0S219))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 22 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 25 ;)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 25 ;)
   (i32.sub
    (local.get $_M0L2r1S220)
    (local.get $_M0L2r0S219))
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 30 ;)
   (local.tee $_M0L6_2atmpS791)
   (i32.const 1)
   (i32.add)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 32 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 42 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 43 ;)))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 112 45 ;)
 (local.set $_M0L2bhS222)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 11 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 14 ;)
 (i32.ge_s
  (local.get $_M0L2c1S221)
  (local.get $_M0L2c0S218))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 22 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 25 ;)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 25 ;)
   (i32.sub
    (local.get $_M0L2c1S221)
    (local.get $_M0L2c0S218))
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 30 ;)
   (local.tee $_M0L6_2atmpS790)
   (i32.const 1)
   (i32.add)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 32 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 42 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 43 ;)))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 113 45 ;)
 (local.set $_M0L2bwS223)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 14 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 114 17 ;)
 (call $_M0FP48moonarc34rhae3src4rhae10is__sym__h
  (local.get $_M0L4gridS212)
  (local.get $_M0L1hS208)
  (local.get $_M0L1wS209))
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
 (local.set $_M0L3symS224)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 115 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS924
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS924)
  (i32.const 0))
 (local.set $_M0L5deltaS225
  (local.get $_M0L3ptrS924))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 115 21 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS923
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS923)
  (i32.const 0))
 (local.set $_M0L1jS226
  (local.get $_M0L3ptrS923))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 2 ;)
 (loop $loop:228
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS771
    (i32.load
     (local.get $_M0L1jS226)))
   (local.get $_M0L1nS207))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 16 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 19 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 19 ;)
    (local.set $_M0L3valS775
     (i32.load
      (local.get $_M0L1jS226)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4gridS212)
     (local.get $_M0L3valS775))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 26 ;)
    (local.set $_M0L6_2atmpS772)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 30 ;)
    (local.set $_M0L3valS774
     (i32.load
      (local.get $_M0L1jS226)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4prevS227)
     (local.get $_M0L3valS774))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 37 ;)
    (local.set $_M0L6_2atmpS773)
    (local.get $_M0L6_2atmpS772)
    (i32.ne
     (local.get $_M0L6_2atmpS773))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 37 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 40 ;)
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 48 ;)
      (i32.add
       (local.tee $_M0L3valS777
        (i32.load
         (local.get $_M0L5deltaS225)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 55 ;)
      (local.set $_M0L6_2atmpS776)
      (i32.store
       (local.get $_M0L5deltaS225)
       (local.get $_M0L6_2atmpS776))
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
     (local.tee $_M0L3valS779
      (i32.load
       (local.get $_M0L1jS226)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 66 ;)
    (local.set $_M0L6_2atmpS778)
    (i32.store
     (local.get $_M0L1jS226)
     (local.get $_M0L6_2atmpS778))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 66 ;)
    (drop)
    (br $loop:228))
   (else
    (call $moonbit.decref
     (local.get $_M0L1jS226)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 116 68 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 117 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS922
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS922)
  (i32.const 0))
 (local.set $_M0L2nzS229
  (local.get $_M0L3ptrS922))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 117 18 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS921
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS921)
  (i32.const 0))
 (local.set $_M0L1kS230
  (local.get $_M0L3ptrS921))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 2 ;)
 (loop $loop:231
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS780
    (i32.load
     (local.get $_M0L1kS230)))
   (local.get $_M0L1nS207))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 16 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 19 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 19 ;)
    (local.set $_M0L3valS782
     (i32.load
      (local.get $_M0L1kS230)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4gridS212)
     (local.get $_M0L3valS782))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 26 ;)
    (local.tee $_M0L6_2atmpS781)
    (i32.const 0)
    (i32.gt_s)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 30 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 33 ;)
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 38 ;)
      (i32.add
       (local.tee $_M0L3valS784
        (i32.load
         (local.get $_M0L2nzS229)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 42 ;)
      (local.set $_M0L6_2atmpS783)
      (i32.store
       (local.get $_M0L2nzS229)
       (local.get $_M0L6_2atmpS783))
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
     (local.tee $_M0L3valS786
      (i32.load
       (local.get $_M0L1kS230)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 53 ;)
    (local.set $_M0L6_2atmpS785)
    (i32.store
     (local.get $_M0L1kS230)
     (local.get $_M0L6_2atmpS785))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 53 ;)
    (drop)
    (br $loop:231))
   (else
    (call $moonbit.decref
     (local.get $_M0L1kS230)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 118 55 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 13 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 16 ;)
 (i32.gt_s
  (local.get $_M0L1nS207)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 21 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 24 ;)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 24 ;)
   (i32.load
    (local.get $_M0L2nzS229))
   (call $moonbit.decref
    (local.get $_M0L2nzS229))
   (local.tee $_M0L3valS789)
   (i32.const 100)
   (i32.mul)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 30 ;)
   (local.tee $_M0L6_2atmpS788)
   (local.get $_M0L1nS207)
   (i32.div_s)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 32 ;))
  (else
   (call $moonbit.decref
    (local.get $_M0L2nzS229))
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 42 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 43 ;)))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 119 45 ;)
 (local.set $_M0L4goalS232)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 2 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS233)
  (i32.const 0)
  (local.get $_M0L7n__compS211))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 15 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 17 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS233)
  (i32.const 1)
  (local.get $_M0L9n__colorsS216))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 32 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 34 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS233)
  (i32.const 2)
  (local.get $_M0L7n__compS211))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 120 47 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 2 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS233)
  (i32.const 3)
  (local.get $_M0L2bhS222))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 11 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 17 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS233)
  (i32.const 4)
  (local.get $_M0L2bwS223))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 26 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 34 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS233)
  (i32.const 5)
  (local.get $_M0L3symS224))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 121 44 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 2 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS233)
  (i32.const 6)
  (local.get $_M0L5eulerS214))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 14 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 17 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS233)
  (i32.const 7)
  (local.get $_M0L8n__holesS215))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 31 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 34 ;)
 (i32.load
  (local.get $_M0L5deltaS225))
 (call $moonbit.decref
  (local.get $_M0L5deltaS225))
 (local.set $_M0L3valS787)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS233)
  (i32.const 8)
  (local.get $_M0L3valS787))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 46 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 122 48 ;)
 (call $_M0MPC15array5Array3setGiE
  (local.get $_M0L3outS233)
  (i32.const 9)
  (local.get $_M0L4goalS232))
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
(func $_M0FP48moonarc34rhae3src4rhae13count__colors (param $_M0L4gridS202 i32) (param $_M0L1nS200 i32) (result i32)
 (local $_M0L4seenS198 i32)
 (local $_M0L1iS199 i32)
 (local $_M0L1cS201 i32)
 (local $_M0L3cntS204 i32)
 (local $_M0L1kS205 i32)
 (local $_M0L3valS760 i32)
 (local $_M0L6_2atmpS761 i32)
 (local $_M0L3valS762 i32)
 (local $_M0L3valS763 i32)
 (local $_M0L3valS764 i32)
 (local $_M0L6_2atmpS765 i32)
 (local $_M0L3valS766 i32)
 (local $_M0L6_2atmpS767 i32)
 (local $_M0L3valS768 i32)
 (local $_M0L6_2atmpS769 i32)
 (local $_M0L3valS770 i32)
 (local $_M0L3ptrS925 i32)
 (local $_M0L3ptrS926 i32)
 (local $_M0L3ptrS927 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 94 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 94 26 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 16)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 94 44 ;)
 (local.set $_M0L4seenS198)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 95 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS927
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS927)
  (i32.const 0))
 (local.set $_M0L1iS199
  (local.get $_M0L3ptrS927))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 2 ;)
 (loop $loop:203
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS760
    (i32.load
     (local.get $_M0L1iS199)))
   (local.get $_M0L1nS200))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 16 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 24 ;)
    (local.set $_M0L3valS763
     (i32.load
      (local.get $_M0L1iS199)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4gridS202)
     (local.get $_M0L3valS763))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 31 ;)
    (local.set $_M0L1cS201)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 33 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 36 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 36 ;)
    (i32.gt_s
     (local.get $_M0L1cS201)
     (i32.const 0))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 41 ;)
    (if (result i32)
     (then
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 45 ;)
      (i32.lt_s
       (local.get $_M0L1cS201)
       (i32.const 16))
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 51 ;))
     (else
      (i32.const 0)))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 51 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 54 ;)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L4seenS198)
       (local.get $_M0L1cS201)
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
     (local.tee $_M0L3valS762
      (i32.load
       (local.get $_M0L1iS199)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 76 ;)
    (local.set $_M0L6_2atmpS761)
    (i32.store
     (local.get $_M0L1iS199)
     (local.get $_M0L6_2atmpS761))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 76 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 76 ;)
    (drop)
    (br $loop:203))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS199)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 96 78 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 97 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS926
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS926)
  (i32.const 0))
 (local.set $_M0L3cntS204
  (local.get $_M0L3ptrS926))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 97 19 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS925
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS925)
  (i32.const 0))
 (local.set $_M0L1kS205
  (local.get $_M0L3ptrS925))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 2 ;)
 (loop $loop:206
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS764
    (i32.load
     (local.get $_M0L1kS205)))
   (i32.const 16))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 14 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 17 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 23 ;)
    (local.set $_M0L3valS766
     (i32.load
      (local.get $_M0L3cntS204)))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 29 ;)
    (local.set $_M0L3valS768
     (i32.load
      (local.get $_M0L1kS205)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L4seenS198)
     (local.get $_M0L3valS768))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 36 ;)
    (local.set $_M0L6_2atmpS767)
    (i32.add
     (local.get $_M0L3valS766)
     (local.get $_M0L6_2atmpS767))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 36 ;)
    (local.set $_M0L6_2atmpS765)
    (i32.store
     (local.get $_M0L3cntS204)
     (local.get $_M0L6_2atmpS765))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 36 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 38 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 42 ;)
    (i32.add
     (local.tee $_M0L3valS770
      (i32.load
       (local.get $_M0L1kS205)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 45 ;)
    (local.set $_M0L6_2atmpS769)
    (i32.store
     (local.get $_M0L1kS205)
     (local.get $_M0L6_2atmpS769))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 45 ;)
    (drop)
    (br $loop:206))
   (else
    (call $moonbit.decref
     (local.get $_M0L1kS205))
    (call $moonbit.decref
     (local.get $_M0L4seenS198)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 98 47 ;)
 (drop)
 (i32.load
  (local.get $_M0L3cntS204))
 (call $moonbit.decref
  (local.get $_M0L3cntS204))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 99 5 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 99 5 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 99 5 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 99 5 ;))
(func $_M0FP48moonarc34rhae3src4rhae10is__sym__h (param $_M0L4gridS195 i32) (param $_M0L1hS192 i32) (param $_M0L1wS194 i32) (result i32)
 (local $_M0L1rS191 i32)
 (local $_M0L1cS193 i32)
 (local $_M0L3valS741 i32)
 (local $_M0L6_2atmpS742 i32)
 (local $_M0L3valS743 i32)
 (local $_M0L6_2atmpS744 i32)
 (local $_M0L6_2atmpS745 i32)
 (local $_M0L6_2atmpS746 i32)
 (local $_M0L6_2atmpS747 i32)
 (local $_M0L3valS748 i32)
 (local $_M0L6_2atmpS749 i32)
 (local $_M0L6_2atmpS750 i32)
 (local $_M0L3valS751 i32)
 (local $_M0L6_2atmpS752 i32)
 (local $_M0L6_2atmpS753 i32)
 (local $_M0L3valS754 i32)
 (local $_M0L3valS755 i32)
 (local $_M0L6_2atmpS756 i32)
 (local $_M0L3valS757 i32)
 (local $_M0L6_2atmpS758 i32)
 (local $_M0L3valS759 i32)
 (local $_M0L3ptrS928 i32)
 (local $_M0L3ptrS929 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 81 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS929
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS929)
  (i32.const 0))
 (local.set $_M0L1rS191
  (local.get $_M0L3ptrS929))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 82 2 ;)
 (loop $loop:197
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 82 8 ;)
  (local.set $_M0L3valS741
   (i32.load
    (local.get $_M0L1rS191)))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 82 12 ;)
  (i32.div_s
   (local.get $_M0L1hS192)
   (i32.const 2))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 82 17 ;)
  (local.set $_M0L6_2atmpS742)
  (i32.lt_s
   (local.get $_M0L3valS741)
   (local.get $_M0L6_2atmpS742))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 82 17 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 83 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS928
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS928)
     (i32.const 0))
    (local.set $_M0L1cS193
     (local.get $_M0L3ptrS928))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 84 4 ;)
    (loop $loop:196
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 84 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS743
       (i32.load
        (local.get $_M0L1cS193)))
      (local.get $_M0L1wS194))
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 84 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 14 ;)
       (i32.mul
        (local.tee $_M0L3valS755
         (i32.load
          (local.get $_M0L1rS191)))
        (local.get $_M0L1wS194))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 17 ;)
       (local.set $_M0L6_2atmpS753)
       (local.set $_M0L3valS754
        (i32.load
         (local.get $_M0L1cS193)))
       (i32.add
        (local.get $_M0L6_2atmpS753)
        (local.get $_M0L3valS754))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 19 ;)
       (local.set $_M0L6_2atmpS752)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS195)
        (local.get $_M0L6_2atmpS752))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 20 ;)
       (local.set $_M0L6_2atmpS744)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 24 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 29 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 29 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 30 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 30 ;)
       (i32.sub
        (local.get $_M0L1hS192)
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 33 ;)
       (local.set $_M0L6_2atmpS750)
       (local.set $_M0L3valS751
        (i32.load
         (local.get $_M0L1rS191)))
       (i32.sub
        (local.get $_M0L6_2atmpS750)
        (local.get $_M0L3valS751))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 35 ;)
       (local.tee $_M0L6_2atmpS749)
       (local.get $_M0L1wS194)
       (i32.mul)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 38 ;)
       (local.set $_M0L6_2atmpS747)
       (local.set $_M0L3valS748
        (i32.load
         (local.get $_M0L1cS193)))
       (i32.add
        (local.get $_M0L6_2atmpS747)
        (local.get $_M0L3valS748))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 40 ;)
       (local.set $_M0L6_2atmpS746)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS195)
        (local.get $_M0L6_2atmpS746))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 41 ;)
       (local.set $_M0L6_2atmpS745)
       (local.get $_M0L6_2atmpS744)
       (i32.ne
        (local.get $_M0L6_2atmpS745))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 85 41 ;)
       (if
        (then
         (call $moonbit.decref
          (local.get $_M0L1cS193))
         (call $moonbit.decref
          (local.get $_M0L1rS191))
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
        (local.tee $_M0L3valS757
         (i32.load
          (local.get $_M0L1cS193)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 86 15 ;)
       (local.set $_M0L6_2atmpS756)
       (i32.store
        (local.get $_M0L1cS193)
        (local.get $_M0L6_2atmpS756))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 86 15 ;)
       (drop)
       (br $loop:196))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS193)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 87 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 88 4 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 88 8 ;)
    (i32.add
     (local.tee $_M0L3valS759
      (i32.load
       (local.get $_M0L1rS191)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 88 13 ;)
    (local.set $_M0L6_2atmpS758)
    (i32.store
     (local.get $_M0L1rS191)
     (local.get $_M0L6_2atmpS758))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 88 13 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 88 13 ;)
    (drop)
    (br $loop:197))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS191)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 89 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 90 2 ;)
 (i32.const 1)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 90 6 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 90 6 ;))
(func $_M0FP48moonarc34rhae3src4rhae12euler__proxy (param $_M0L4gridS184 i32) (param $_M0L1hS180 i32) (param $_M0L1wS182 i32) (result i32)
 (local $_M0L2q1S177 i32)
 (local $_M0L2q3S178 i32)
 (local $_M0L1rS179 i32)
 (local $_M0L1cS181 i32)
 (local $_M0L1aS183 i32)
 (local $_M0L1bS185 i32)
 (local $_M0L1dS186 i32)
 (local $_M0L1eS187 i32)
 (local $_M0L1sS188 i32)
 (local $_M0L3valS693 i32)
 (local $_M0L6_2atmpS694 i32)
 (local $_M0L3valS695 i32)
 (local $_M0L6_2atmpS696 i32)
 (local $_M0L6_2atmpS697 i32)
 (local $_M0L3valS698 i32)
 (local $_M0L6_2atmpS699 i32)
 (local $_M0L3valS700 i32)
 (local $_M0L6_2atmpS701 i32)
 (local $_M0L3valS702 i32)
 (local $_M0L6_2atmpS703 i32)
 (local $_M0L6_2atmpS704 i32)
 (local $_M0L6_2atmpS705 i32)
 (local $_M0L6_2atmpS706 i32)
 (local $_M0L6_2atmpS707 i32)
 (local $_M0L6_2atmpS708 i32)
 (local $_M0L3valS709 i32)
 (local $_M0L6_2atmpS710 i32)
 (local $_M0L3valS711 i32)
 (local $_M0L6_2atmpS712 i32)
 (local $_M0L6_2atmpS713 i32)
 (local $_M0L6_2atmpS714 i32)
 (local $_M0L3valS715 i32)
 (local $_M0L6_2atmpS716 i32)
 (local $_M0L3valS717 i32)
 (local $_M0L6_2atmpS718 i32)
 (local $_M0L6_2atmpS719 i32)
 (local $_M0L6_2atmpS720 i32)
 (local $_M0L6_2atmpS721 i32)
 (local $_M0L3valS722 i32)
 (local $_M0L3valS723 i32)
 (local $_M0L6_2atmpS724 i32)
 (local $_M0L6_2atmpS725 i32)
 (local $_M0L6_2atmpS726 i32)
 (local $_M0L3valS727 i32)
 (local $_M0L3valS728 i32)
 (local $_M0L6_2atmpS729 i32)
 (local $_M0L3valS730 i32)
 (local $_M0L6_2atmpS731 i32)
 (local $_M0L6_2atmpS732 i32)
 (local $_M0L3valS733 i32)
 (local $_M0L3valS734 i32)
 (local $_M0L6_2atmpS735 i32)
 (local $_M0L3valS736 i32)
 (local $_M0L3valS737 i32)
 (local $_M0L6_2atmpS738 i32)
 (local $_M0L3valS739 i32)
 (local $_M0L3valS740 i32)
 (local $_M0L3ptrS930 i32)
 (local $_M0L3ptrS931 i32)
 (local $_M0L3ptrS932 i32)
 (local $_M0L3ptrS933 i32)
 (local $_M0L3ptrS934 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 62 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS934
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS934)
  (i32.const 0))
 (local.set $_M0L2q1S177
  (local.get $_M0L3ptrS934))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 62 18 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS933
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS933)
  (i32.const 0))
 (local.set $_M0L2q3S178
  (local.get $_M0L3ptrS933))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 63 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS932
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS932)
  (i32.const 0))
 (local.set $_M0L1rS179
  (local.get $_M0L3ptrS932))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 64 2 ;)
 (loop $loop:190
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 64 8 ;)
  (local.set $_M0L3valS693
   (i32.load
    (local.get $_M0L1rS179)))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 64 12 ;)
  (i32.sub
   (local.get $_M0L1hS180)
   (i32.const 1))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 64 17 ;)
  (local.set $_M0L6_2atmpS694)
  (i32.lt_s
   (local.get $_M0L3valS693)
   (local.get $_M0L6_2atmpS694))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 64 17 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 65 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS931
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS931)
     (i32.const 0))
    (local.set $_M0L1cS181
     (local.get $_M0L3ptrS931))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 66 4 ;)
    (loop $loop:189
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 66 10 ;)
     (local.set $_M0L3valS695
      (i32.load
       (local.get $_M0L1cS181)))
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 66 14 ;)
     (i32.sub
      (local.get $_M0L1wS182)
      (i32.const 1))
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 66 19 ;)
     (local.set $_M0L6_2atmpS696)
     (i32.lt_s
      (local.get $_M0L3valS695)
      (local.get $_M0L6_2atmpS696))
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
        (local.tee $_M0L3valS728
         (i32.load
          (local.get $_M0L1rS179)))
        (local.get $_M0L1wS182))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 25 ;)
       (local.set $_M0L6_2atmpS726)
       (local.set $_M0L3valS727
        (i32.load
         (local.get $_M0L1cS181)))
       (i32.add
        (local.get $_M0L6_2atmpS726)
        (local.get $_M0L3valS727))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 27 ;)
       (local.set $_M0L6_2atmpS725)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS184)
        (local.get $_M0L6_2atmpS725))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 67 28 ;)
       (local.tee $_M0L6_2atmpS724)
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
       (local.set $_M0L1aS183)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 22 ;)
       (i32.mul
        (local.tee $_M0L3valS723
         (i32.load
          (local.get $_M0L1rS179)))
        (local.get $_M0L1wS182))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 25 ;)
       (local.set $_M0L6_2atmpS721)
       (local.set $_M0L3valS722
        (i32.load
         (local.get $_M0L1cS181)))
       (i32.add
        (local.get $_M0L6_2atmpS721)
        (local.get $_M0L3valS722))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 27 ;)
       (local.tee $_M0L6_2atmpS720)
       (i32.const 1)
       (i32.add)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 29 ;)
       (local.set $_M0L6_2atmpS719)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS184)
        (local.get $_M0L6_2atmpS719))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 68 30 ;)
       (local.tee $_M0L6_2atmpS718)
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
       (local.set $_M0L1bS185)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 23 ;)
       (i32.add
        (local.tee $_M0L3valS717
         (i32.load
          (local.get $_M0L1rS179)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 26 ;)
       (local.tee $_M0L6_2atmpS716)
       (local.get $_M0L1wS182)
       (i32.mul)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 29 ;)
       (local.set $_M0L6_2atmpS714)
       (local.set $_M0L3valS715
        (i32.load
         (local.get $_M0L1cS181)))
       (i32.add
        (local.get $_M0L6_2atmpS714)
        (local.get $_M0L3valS715))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 31 ;)
       (local.set $_M0L6_2atmpS713)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS184)
        (local.get $_M0L6_2atmpS713))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 69 32 ;)
       (local.tee $_M0L6_2atmpS712)
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
       (local.set $_M0L1dS186)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 17 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 22 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 23 ;)
       (i32.add
        (local.tee $_M0L3valS711
         (i32.load
          (local.get $_M0L1rS179)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 26 ;)
       (local.tee $_M0L6_2atmpS710)
       (local.get $_M0L1wS182)
       (i32.mul)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 29 ;)
       (local.set $_M0L6_2atmpS708)
       (local.set $_M0L3valS709
        (i32.load
         (local.get $_M0L1cS181)))
       (i32.add
        (local.get $_M0L6_2atmpS708)
        (local.get $_M0L3valS709))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 31 ;)
       (local.tee $_M0L6_2atmpS707)
       (i32.const 1)
       (i32.add)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 33 ;)
       (local.set $_M0L6_2atmpS706)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS184)
        (local.get $_M0L6_2atmpS706))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 70 34 ;)
       (local.tee $_M0L6_2atmpS705)
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
       (local.set $_M0L1eS187)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 14 ;)
       (i32.add
        (local.get $_M0L1aS183)
        (local.get $_M0L1bS185))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 19 ;)
       (local.tee $_M0L6_2atmpS704)
       (local.get $_M0L1dS186)
       (i32.add)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 23 ;)
       (local.tee $_M0L6_2atmpS703)
       (local.get $_M0L1eS187)
       (i32.add)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 71 27 ;)
       (local.set $_M0L1sS188)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 6 ;)
       (if
        (i32.eq
         (local.get $_M0L1sS188)
         (i32.const 1))
        (then
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 21 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 26 ;)
         (i32.add
          (local.tee $_M0L3valS698
           (i32.load
            (local.get $_M0L2q1S177)))
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 30 ;)
         (local.set $_M0L6_2atmpS697)
         (i32.store
          (local.get $_M0L2q1S177)
          (local.get $_M0L6_2atmpS697))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 30 ;)
         (drop))
        (else
         (if
          (i32.eq
           (local.get $_M0L1sS188)
           (i32.const 3))
          (then
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 37 ;)
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 42 ;)
           (i32.add
            (local.tee $_M0L3valS700
             (i32.load
              (local.get $_M0L2q3S178)))
            (i32.const 1))
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 72 46 ;)
           (local.set $_M0L6_2atmpS699)
           (i32.store
            (local.get $_M0L2q3S178)
            (local.get $_M0L6_2atmpS699))
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
        (local.tee $_M0L3valS702
         (i32.load
          (local.get $_M0L1cS181)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (local.set $_M0L6_2atmpS701)
       (i32.store
        (local.get $_M0L1cS181)
        (local.get $_M0L6_2atmpS701))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 73 15 ;)
       (drop)
       (br $loop:189))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS181)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 74 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 75 4 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 75 8 ;)
    (i32.add
     (local.tee $_M0L3valS730
      (i32.load
       (local.get $_M0L1rS179)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 75 13 ;)
    (local.set $_M0L6_2atmpS729)
    (i32.store
     (local.get $_M0L1rS179)
     (local.get $_M0L6_2atmpS729))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 75 13 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 75 13 ;)
    (drop)
    (br $loop:190))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS179)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 76 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 3 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 4 ;)
 (local.set $_M0L3valS739
  (i32.load
   (local.get $_M0L2q1S177)))
 (local.set $_M0L3valS740
  (i32.load
   (local.get $_M0L2q3S178)))
 (i32.sub
  (local.get $_M0L3valS739)
  (local.get $_M0L3valS740))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 11 ;)
 (local.tee $_M0L6_2atmpS738)
 (i32.const 4)
 (i32.div_s)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 16 ;)
 (local.set $_M0L6_2atmpS731)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 21 ;)
 (local.set $_M0L3valS733
  (i32.load
   (local.get $_M0L2q3S178)))
 (local.set $_M0L3valS734
  (i32.load
   (local.get $_M0L2q1S177)))
 (i32.gt_s
  (local.get $_M0L3valS733)
  (local.get $_M0L3valS734))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 28 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 31 ;)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 32 ;)
   (i32.load
    (local.get $_M0L2q3S178))
   (call $moonbit.decref
    (local.get $_M0L2q3S178))
   (local.set $_M0L3valS736)
   (i32.load
    (local.get $_M0L2q1S177))
   (call $moonbit.decref
    (local.get $_M0L2q1S177))
   (local.set $_M0L3valS737)
   (i32.sub
    (local.get $_M0L3valS736)
    (local.get $_M0L3valS737))
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 37 ;)
   (local.tee $_M0L6_2atmpS735)
   (i32.const 4)
   (i32.div_s)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 40 ;))
  (else
   (call $moonbit.decref
    (local.get $_M0L2q3S178))
   (call $moonbit.decref
    (local.get $_M0L2q1S177))
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 50 ;)
   (i32.const 0)
   (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 51 ;)))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 53 ;)
 (local.set $_M0L6_2atmpS732)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS930
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS930)
  (local.get $_M0L6_2atmpS732))
 (i32.store
  (local.get $_M0L3ptrS930)
  (local.get $_M0L6_2atmpS731))
 (local.get $_M0L3ptrS930)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 54 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 54 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 54 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 77 54 ;))
(func $_M0FP48moonarc34rhae3src4rhae17count__components (param $_M0L4gridS159 i32) (param $_M0L1hS153 i32) (param $_M0L1wS154 i32) (param $_M0L3visS160 i32) (result i32)
 (local $_M0L5stackS152 i32)
 (local $_M0L5countS155 i32)
 (local $_M0L1rS156 i32)
 (local $_M0L1cS157 i32)
 (local $_M0L3idxS158 i32)
 (local $_M0L2spS161 i32)
 (local $_M0L2ccS162 i32)
 (local $_M0L2rrS163 i32)
 (local $_M0L2nbS164 i32)
 (local $_M0L1dS165 i32)
 (local $_M0L2nrS167 i32)
 (local $_M0L2ncS168 i32)
 (local $_M0L2niS169 i32)
 (local $_M0L7_2abindS170 i32)
 (local $_M0L5_2anrS171 i32)
 (local $_M0L5_2ancS172 i32)
 (local $_M0L3valS640 i32)
 (local $_M0L3valS641 i32)
 (local $_M0L6_2atmpS642 i32)
 (local $_M0L6_2atmpS643 i32)
 (local $_M0L6_2atmpS644 i32)
 (local $_M0L3valS645 i32)
 (local $_M0L3valS646 i32)
 (local $_M0L3valS647 i32)
 (local $_M0L6_2atmpS648 i32)
 (local $_M0L3valS649 i32)
 (local $_M0L3valS650 i32)
 (local $_M0L3valS651 i32)
 (local $_M0L6_2atmpS652 i32)
 (local $_M0L3valS653 i32)
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
 (local $_M0L3valS665 i32)
 (local $_M0L6_2atmpS666 i32)
 (local $_M0L3valS667 i32)
 (local $_M0L6_2atmpS668 i32)
 (local $_M0L6_2atmpS669 i32)
 (local $_M0L3valS670 i32)
 (local $_M0L3valS671 i32)
 (local $_M0L6_2atmpS672 i32)
 (local $_M0L8_2atupleS673 i32)
 (local $_M0L8_2atupleS674 i32)
 (local $_M0L8_2atupleS675 i32)
 (local $_M0L8_2atupleS676 i32)
 (local $_M0L6_2atmpS677 i32)
 (local $_M0L6_2atmpS678 i32)
 (local $_M0L6_2atmpS679 i32)
 (local $_M0L6_2atmpS680 i32)
 (local $_M0L3valS681 i32)
 (local $_M0L3valS682 i32)
 (local $_M0L6_2atmpS683 i32)
 (local $_M0L3valS684 i32)
 (local $_M0L6_2atmpS685 i32)
 (local $_M0L3valS686 i32)
 (local $_M0L3valS687 i32)
 (local $_M0L6_2atmpS688 i32)
 (local $_M0L3valS689 i32)
 (local $_M0L6_2atmpS690 i32)
 (local $_M0L6_2atmpS691 i32)
 (local $_M0L6_2atmpS692 i32)
 (local $_M0L3ptrS936 i32)
 (local $_M0L3ptrS937 i32)
 (local $_M0L6_2aptrS938 i32)
 (local $_M0L3ptrS939 i32)
 (local $_M0L3ptrS940 i32)
 (local $_M0L3ptrS941 i32)
 (local $_M0L3ptrS942 i32)
 (local $_M0L3ptrS943 i32)
 (local $_M0L3ptrS944 i32)
 (local $_M0L3ptrS945 i32)
 (local $_M0L3ptrS946 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 2 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 27 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 39 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 39 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 39 ;)
 (i32.mul
  (local.get $_M0L1hS153)
  (local.get $_M0L1wS154))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 44 ;)
 (local.tee $_M0L6_2atmpS692)
 (i32.const 2)
 (i32.mul)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 48 ;)
 (local.tee $_M0L6_2atmpS691)
 (i32.const 2)
 (i32.add)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 52 ;)
 (local.tee $_M0L6_2atmpS690)
 (i32.const 0)
 (call $_M0MPC15array5Array4makeGiE)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 24 56 ;)
 (local.set $_M0L5stackS152)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 25 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS946
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS946)
  (i32.const 0))
 (local.set $_M0L5countS155
  (local.get $_M0L3ptrS946))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 26 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS945
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS945)
  (i32.const 0))
 (local.set $_M0L1rS156
  (local.get $_M0L3ptrS945))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 27 2 ;)
 (loop $loop:176
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 27 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS640
    (i32.load
     (local.get $_M0L1rS156)))
   (local.get $_M0L1hS153))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 27 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 28 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS944
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS944)
     (i32.const 0))
    (local.set $_M0L1cS157
     (local.get $_M0L3ptrS944))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 29 4 ;)
    (loop $loop:175
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 29 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS641
       (i32.load
        (local.get $_M0L1cS157)))
      (local.get $_M0L1wS154))
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 29 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 30 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 30 16 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 30 16 ;)
       (i32.mul
        (local.tee $_M0L3valS687
         (i32.load
          (local.get $_M0L1rS156)))
        (local.get $_M0L1wS154))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 30 21 ;)
       (local.set $_M0L6_2atmpS685)
       (local.set $_M0L3valS686
        (i32.load
         (local.get $_M0L1cS157)))
       (i32.add
        (local.get $_M0L6_2atmpS685)
        (local.get $_M0L3valS686))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 30 25 ;)
       (local.set $_M0L3idxS158)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 9 ;)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS159)
        (local.get $_M0L3idxS158))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 18 ;)
       (local.tee $_M0L6_2atmpS643)
       (i32.const 0)
       (i32.gt_s)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 22 ;)
       (if (result i32)
        (then
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 26 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 26 ;)
         (call $_M0MPC15array5Array2atGiE
          (local.get $_M0L3visS160)
          (local.get $_M0L3idxS158))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 31 34 ;)
         (local.tee $_M0L6_2atmpS642)
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
          (local.tee $_M0L3valS645
           (i32.load
            (local.get $_M0L5countS155)))
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 32 25 ;)
         (local.set $_M0L6_2atmpS644)
         (i32.store
          (local.get $_M0L5countS155)
          (local.get $_M0L6_2atmpS644))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 32 25 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 32 27 ;)
         (call $_M0MPC15array5Array3setGiE
          (local.get $_M0L3visS160)
          (local.get $_M0L3idxS158)
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 32 39 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 33 8 ;)
         (call $moonbit.store_object_meta
          (local.tee $_M0L3ptrS943
           (call $moonbit.gc.malloc
            (i32.const 4)))
          (i32.const 524288))
         (i32.store
          (local.get $_M0L3ptrS943)
          (i32.const 0))
         (local.set $_M0L2spS161
          (local.get $_M0L3ptrS943))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 8 ;)
         (local.set $_M0L3valS646
          (i32.load
           (local.get $_M0L2spS161)))
         (local.set $_M0L3valS647
          (i32.load
           (local.get $_M0L1rS156)))
         (call $_M0MPC15array5Array3setGiE
          (local.get $_M0L5stackS152)
          (local.get $_M0L3valS646)
          (local.get $_M0L3valS647))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 21 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 23 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 28 ;)
         (i32.add
          (local.tee $_M0L3valS649
           (i32.load
            (local.get $_M0L2spS161)))
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 34 ;)
         (local.set $_M0L6_2atmpS648)
         (i32.store
          (local.get $_M0L2spS161)
          (local.get $_M0L6_2atmpS648))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 34 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 36 ;)
         (local.set $_M0L3valS650
          (i32.load
           (local.get $_M0L2spS161)))
         (local.set $_M0L3valS651
          (i32.load
           (local.get $_M0L1cS157)))
         (call $_M0MPC15array5Array3setGiE
          (local.get $_M0L5stackS152)
          (local.get $_M0L3valS650)
          (local.get $_M0L3valS651))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 49 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 51 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 56 ;)
         (i32.add
          (local.tee $_M0L3valS653
           (i32.load
            (local.get $_M0L2spS161)))
          (i32.const 1))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 62 ;)
         (local.set $_M0L6_2atmpS652)
         (i32.store
          (local.get $_M0L2spS161)
          (local.get $_M0L6_2atmpS652))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 34 62 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 35 8 ;)
         (loop $loop:174
          (; source_pos moonarc3/rhae/src/rhae invariants.mbt 35 14 ;)
          (i32.gt_s
           (local.tee $_M0L3valS654
            (i32.load
             (local.get $_M0L2spS161)))
           (i32.const 0))
          (; source_pos moonarc3/rhae/src/rhae invariants.mbt 35 20 ;)
          (if
           (then
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 10 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 15 ;)
            (i32.sub
             (local.tee $_M0L3valS656
              (i32.load
               (local.get $_M0L2spS161)))
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 21 ;)
            (local.set $_M0L6_2atmpS655)
            (i32.store
             (local.get $_M0L2spS161)
             (local.get $_M0L6_2atmpS655))
            (i32.const 0)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 21 ;)
            (drop)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 23 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 32 ;)
            (local.set $_M0L3valS682
             (i32.load
              (local.get $_M0L2spS161)))
            (call $_M0MPC15array5Array2atGiE
             (local.get $_M0L5stackS152)
             (local.get $_M0L3valS682))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 36 41 ;)
            (local.set $_M0L2ccS162)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 10 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 15 ;)
            (i32.sub
             (local.tee $_M0L3valS658
              (i32.load
               (local.get $_M0L2spS161)))
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 21 ;)
            (local.set $_M0L6_2atmpS657)
            (i32.store
             (local.get $_M0L2spS161)
             (local.get $_M0L6_2atmpS657))
            (i32.const 0)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 21 ;)
            (drop)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 23 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 32 ;)
            (local.set $_M0L3valS681
             (i32.load
              (local.get $_M0L2spS161)))
            (call $_M0MPC15array5Array2atGiE
             (local.get $_M0L5stackS152)
             (local.get $_M0L3valS681))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 37 41 ;)
            (local.set $_M0L2rrS163)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 10 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 38 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 39 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 40 ;)
            (i32.sub
             (local.get $_M0L2rrS163)
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 44 ;)
            (local.set $_M0L6_2atmpS680)
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS942
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS942)
             (local.get $_M0L2ccS162))
            (i32.store
             (local.get $_M0L3ptrS942)
             (local.get $_M0L6_2atmpS680))
            (local.get $_M0L3ptrS942)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 48 ;)
            (local.set $_M0L8_2atupleS673)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 49 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 50 ;)
            (i32.add
             (local.get $_M0L2rrS163)
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 54 ;)
            (local.set $_M0L6_2atmpS679)
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS941
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS941)
             (local.get $_M0L2ccS162))
            (i32.store
             (local.get $_M0L3ptrS941)
             (local.get $_M0L6_2atmpS679))
            (local.get $_M0L3ptrS941)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 58 ;)
            (local.set $_M0L8_2atupleS674)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 59 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 63 ;)
            (i32.sub
             (local.get $_M0L2ccS162)
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 67 ;)
            (local.set $_M0L6_2atmpS678)
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS940
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS940)
             (local.get $_M0L6_2atmpS678))
            (i32.store
             (local.get $_M0L3ptrS940)
             (local.get $_M0L2rrS163))
            (local.get $_M0L3ptrS940)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 68 ;)
            (local.set $_M0L8_2atupleS675)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 69 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 73 ;)
            (i32.add
             (local.get $_M0L2ccS162)
             (i32.const 1))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 77 ;)
            (local.set $_M0L6_2atmpS677)
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS939
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 1048576))
            (i32.store offset=4
             (local.get $_M0L3ptrS939)
             (local.get $_M0L6_2atmpS677))
            (i32.store
             (local.get $_M0L3ptrS939)
             (local.get $_M0L2rrS163))
            (local.get $_M0L3ptrS939)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 78 ;)
            (local.set $_M0L8_2atupleS676)
            (i32.store
             (local.tee $_M0L6_2aptrS938
              (call $moonbit.ref_array_make_raw
               (i32.const 4)))
             (local.get $_M0L8_2atupleS673))
            (i32.store offset=4
             (local.get $_M0L6_2aptrS938)
             (local.get $_M0L8_2atupleS674))
            (i32.store offset=8
             (local.get $_M0L6_2aptrS938)
             (local.get $_M0L8_2atupleS675))
            (i32.store offset=12
             (local.get $_M0L6_2aptrS938)
             (local.get $_M0L8_2atupleS676))
            (local.set $_M0L6_2atmpS672
             (local.get $_M0L6_2aptrS938))
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS937
              (call $moonbit.gc.malloc
               (i32.const 8)))
             (i32.const 524544))
            (i32.store
             (local.get $_M0L3ptrS937)
             (i32.const 4))
            (i32.store offset=4
             (local.get $_M0L3ptrS937)
             (local.get $_M0L6_2atmpS672))
            (local.get $_M0L3ptrS937)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 39 79 ;)
            (local.set $_M0L2nbS164)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 40 10 ;)
            (call $moonbit.store_object_meta
             (local.tee $_M0L3ptrS936
              (call $moonbit.gc.malloc
               (i32.const 4)))
             (i32.const 524288))
            (i32.store
             (local.get $_M0L3ptrS936)
             (i32.const 0))
            (local.set $_M0L1dS165
             (local.get $_M0L3ptrS936))
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 41 10 ;)
            (loop $loop:173
             (; source_pos moonarc3/rhae/src/rhae invariants.mbt 41 16 ;)
             (i32.lt_s
              (local.tee $_M0L3valS659
               (i32.load
                (local.get $_M0L1dS165)))
              (i32.const 4))
             (; source_pos moonarc3/rhae/src/rhae invariants.mbt 41 21 ;)
             (if
              (then
               (; source_pos moonarc3/rhae/src/rhae invariants.mbt 42 12 ;)
               (block $outer/935 (result i32)
                (block $join:166
                 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 42 12 ;)
                 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 42 27 ;)
                 (local.set $_M0L3valS671
                  (i32.load
                   (local.get $_M0L1dS165)))
                 (call $_M0MPC15array5Array2atGUiiEE
                  (local.get $_M0L2nbS164)
                  (local.get $_M0L3valS671))
                 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 42 32 ;)
                 (local.tee $_M0L7_2abindS170)
                 (i32.load)
                 (local.set $_M0L5_2anrS171)
                 (i32.load offset=4
                  (local.get $_M0L7_2abindS170))
                 (call $moonbit.decref
                  (local.get $_M0L7_2abindS170))
                 (local.set $_M0L5_2ancS172)
                 (local.get $_M0L5_2anrS171)
                 (local.set $_M0L2ncS168
                  (local.get $_M0L5_2ancS172))
                 (local.set $_M0L2nrS167)
                 (br $join:166))
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 12 ;)
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 15 ;)
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 15 ;)
                (i32.ge_s
                 (local.get $_M0L2nrS167)
                 (i32.const 0))
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 22 ;)
                (if (result i32)
                 (then
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 26 ;)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 26 ;)
                  (i32.lt_s
                   (local.get $_M0L2nrS167)
                   (local.get $_M0L1hS153))
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 32 ;)
                  (if (result i32)
                   (then
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 36 ;)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 36 ;)
                    (i32.ge_s
                     (local.get $_M0L2ncS168)
                     (i32.const 0))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 43 ;)
                    (if (result i32)
                     (then
                      (; source_pos moonarc3/rhae/src/rhae invariants.mbt 43 47 ;)
                      (i32.lt_s
                       (local.get $_M0L2ncS168)
                       (local.get $_M0L1wS154))
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
                   (local.get $_M0L2nrS167)
                   (local.get $_M0L1wS154))
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 44 29 ;)
                  (local.tee $_M0L6_2atmpS668)
                  (local.get $_M0L2ncS168)
                  (i32.add)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 44 34 ;)
                  (local.set $_M0L2niS169)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 14 ;)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 17 ;)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 17 ;)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 17 ;)
                  (call $_M0MPC15array5Array2atGiE
                   (local.get $_M0L4gridS159)
                   (local.get $_M0L2niS169))
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 25 ;)
                  (local.tee $_M0L6_2atmpS661)
                  (i32.const 0)
                  (i32.gt_s)
                  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 29 ;)
                  (if (result i32)
                   (then
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 33 ;)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 33 ;)
                    (call $_M0MPC15array5Array2atGiE
                     (local.get $_M0L3visS160)
                     (local.get $_M0L2niS169))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 45 40 ;)
                    (local.tee $_M0L6_2atmpS660)
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
                     (local.get $_M0L3visS160)
                     (local.get $_M0L2niS169)
                     (i32.const 1))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 46 27 ;)
                    (drop)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 16 ;)
                    (local.set $_M0L3valS662
                     (i32.load
                      (local.get $_M0L2spS161)))
                    (call $_M0MPC15array5Array3setGiE
                     (local.get $_M0L5stackS152)
                     (local.get $_M0L3valS662)
                     (local.get $_M0L2nrS167))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 30 ;)
                    (drop)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 32 ;)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 37 ;)
                    (i32.add
                     (local.tee $_M0L3valS664
                      (i32.load
                       (local.get $_M0L2spS161)))
                     (i32.const 1))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 43 ;)
                    (local.set $_M0L6_2atmpS663)
                    (i32.store
                     (local.get $_M0L2spS161)
                     (local.get $_M0L6_2atmpS663))
                    (i32.const 0)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 43 ;)
                    (drop)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 45 ;)
                    (local.set $_M0L3valS665
                     (i32.load
                      (local.get $_M0L2spS161)))
                    (call $_M0MPC15array5Array3setGiE
                     (local.get $_M0L5stackS152)
                     (local.get $_M0L3valS665)
                     (local.get $_M0L2ncS168))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 59 ;)
                    (drop)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 61 ;)
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 66 ;)
                    (i32.add
                     (local.tee $_M0L3valS667
                      (i32.load
                       (local.get $_M0L2spS161)))
                     (i32.const 1))
                    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 47 72 ;)
                    (local.set $_M0L6_2atmpS666)
                    (i32.store
                     (local.get $_M0L2spS161)
                     (local.get $_M0L6_2atmpS666))
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
                 (local.tee $_M0L3valS670
                  (i32.load
                   (local.get $_M0L1dS165)))
                 (i32.const 1))
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 50 21 ;)
                (local.set $_M0L6_2atmpS669)
                (i32.store
                 (local.get $_M0L1dS165)
                 (local.get $_M0L6_2atmpS669))
                (i32.const 0)
                (; source_pos moonarc3/rhae/src/rhae invariants.mbt 50 21 ;))
               (; source_pos moonarc3/rhae/src/rhae invariants.mbt 50 21 ;)
               (drop)
               (br $loop:173))
              (else
               (call $moonbit.decref
                (local.get $_M0L1dS165))
               (call $moonbit.decref
                (local.get $_M0L2nbS164)))))
            (i32.const 0)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 51 11 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 51 11 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 51 11 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 51 11 ;)
            (; source_pos moonarc3/rhae/src/rhae invariants.mbt 51 11 ;)
            (drop)
            (br $loop:174))
           (else
            (call $moonbit.decref
             (local.get $_M0L2spS161)))))
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
        (local.tee $_M0L3valS684
         (i32.load
          (local.get $_M0L1cS157)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 54 15 ;)
       (local.set $_M0L6_2atmpS683)
       (i32.store
        (local.get $_M0L1cS157)
        (local.get $_M0L6_2atmpS683))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 54 15 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 54 15 ;)
       (drop)
       (br $loop:175))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS157)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 55 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 56 4 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 56 8 ;)
    (i32.add
     (local.tee $_M0L3valS689
      (i32.load
       (local.get $_M0L1rS156)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 56 13 ;)
    (local.set $_M0L6_2atmpS688)
    (i32.store
     (local.get $_M0L1rS156)
     (local.get $_M0L6_2atmpS688))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 56 13 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 56 13 ;)
    (drop)
    (br $loop:176))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS156))
    (call $moonbit.decref
     (local.get $_M0L5stackS152)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 57 3 ;)
 (drop)
 (i32.load
  (local.get $_M0L5countS155))
 (call $moonbit.decref
  (local.get $_M0L5countS155))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 58 7 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 58 7 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 58 7 ;))
(func $_M0FP48moonarc34rhae3src4rhae4bbox (param $_M0L4gridS149 i32) (param $_M0L1hS142 i32) (param $_M0L1wS145 i32) (result i32)
 (local $_M0L2r0S141 i32)
 (local $_M0L2r1S143 i32)
 (local $_M0L2c0S144 i32)
 (local $_M0L2c1S146 i32)
 (local $_M0L1rS147 i32)
 (local $_M0L1cS148 i32)
 (local $_M0L3valS613 i32)
 (local $_M0L3valS614 i32)
 (local $_M0L6_2atmpS615 i32)
 (local $_M0L6_2atmpS616 i32)
 (local $_M0L6_2atmpS617 i32)
 (local $_M0L3valS618 i32)
 (local $_M0L3valS619 i32)
 (local $_M0L3valS620 i32)
 (local $_M0L3valS621 i32)
 (local $_M0L3valS622 i32)
 (local $_M0L3valS623 i32)
 (local $_M0L3valS624 i32)
 (local $_M0L3valS625 i32)
 (local $_M0L3valS626 i32)
 (local $_M0L3valS627 i32)
 (local $_M0L3valS628 i32)
 (local $_M0L3valS629 i32)
 (local $_M0L3valS630 i32)
 (local $_M0L3valS631 i32)
 (local $_M0L6_2atmpS632 i32)
 (local $_M0L3valS633 i32)
 (local $_M0L6_2atmpS634 i32)
 (local $_M0L3valS635 i32)
 (local $_M0L3valS636 i32)
 (local $_M0L3valS637 i32)
 (local $_M0L3valS638 i32)
 (local $_M0L3valS639 i32)
 (local $_M0L3ptrS947 i32)
 (local $_M0L3ptrS948 i32)
 (local $_M0L3ptrS949 i32)
 (local $_M0L3ptrS950 i32)
 (local $_M0L3ptrS951 i32)
 (local $_M0L3ptrS952 i32)
 (local $_M0L3ptrS953 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 7 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS953
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS953)
  (local.get $_M0L1hS142))
 (local.set $_M0L2r0S141
  (local.get $_M0L3ptrS953))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 7 18 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS952
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS952)
  (i32.const 0))
 (local.set $_M0L2r1S143
  (local.get $_M0L3ptrS952))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 7 34 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS951
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS951)
  (local.get $_M0L1wS145))
 (local.set $_M0L2c0S144
  (local.get $_M0L3ptrS951))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 7 50 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS950
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS950)
  (i32.const 0))
 (local.set $_M0L2c1S146
  (local.get $_M0L3ptrS950))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 8 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS949
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS949)
  (i32.const 0))
 (local.set $_M0L1rS147
  (local.get $_M0L3ptrS949))
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 9 2 ;)
 (loop $loop:151
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 9 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS613
    (i32.load
     (local.get $_M0L1rS147)))
   (local.get $_M0L1hS142))
  (; source_pos moonarc3/rhae/src/rhae invariants.mbt 9 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 10 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS948
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS948)
     (i32.const 0))
    (local.set $_M0L1cS148
     (local.get $_M0L3ptrS948))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 11 4 ;)
    (loop $loop:150
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 11 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS614
       (i32.load
        (local.get $_M0L1cS148)))
      (local.get $_M0L1wS145))
     (; source_pos moonarc3/rhae/src/rhae invariants.mbt 11 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 6 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 9 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 14 ;)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 14 ;)
       (i32.mul
        (local.tee $_M0L3valS619
         (i32.load
          (local.get $_M0L1rS147)))
        (local.get $_M0L1wS145))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 19 ;)
       (local.set $_M0L6_2atmpS617)
       (local.set $_M0L3valS618
        (i32.load
         (local.get $_M0L1cS148)))
       (i32.add
        (local.get $_M0L6_2atmpS617)
        (local.get $_M0L3valS618))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 23 ;)
       (local.set $_M0L6_2atmpS616)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS149)
        (local.get $_M0L6_2atmpS616))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 24 ;)
       (local.tee $_M0L6_2atmpS615)
       (i32.const 0)
       (i32.gt_s)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 12 28 ;)
       (if
        (then
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 8 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 11 ;)
         (local.set $_M0L3valS620
          (i32.load
           (local.get $_M0L1rS147)))
         (local.set $_M0L3valS621
          (i32.load
           (local.get $_M0L2r0S141)))
         (i32.lt_s
          (local.get $_M0L3valS620)
          (local.get $_M0L3valS621))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 17 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 20 ;)
           (local.set $_M0L3valS622
            (i32.load
             (local.get $_M0L1rS147)))
           (i32.store
            (local.get $_M0L2r0S141)
            (local.get $_M0L3valS622))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 26 ;)
           (drop))
          (else))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 28 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 30 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 33 ;)
         (local.set $_M0L3valS623
          (i32.load
           (local.get $_M0L1rS147)))
         (local.set $_M0L3valS624
          (i32.load
           (local.get $_M0L2r1S143)))
         (i32.gt_s
          (local.get $_M0L3valS623)
          (local.get $_M0L3valS624))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 39 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 42 ;)
           (local.set $_M0L3valS625
            (i32.load
             (local.get $_M0L1rS147)))
           (i32.store
            (local.get $_M0L2r1S143)
            (local.get $_M0L3valS625))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 48 ;)
           (drop))
          (else))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 13 50 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 8 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 11 ;)
         (local.set $_M0L3valS626
          (i32.load
           (local.get $_M0L1cS148)))
         (local.set $_M0L3valS627
          (i32.load
           (local.get $_M0L2c0S144)))
         (i32.lt_s
          (local.get $_M0L3valS626)
          (local.get $_M0L3valS627))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 17 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 20 ;)
           (local.set $_M0L3valS628
            (i32.load
             (local.get $_M0L1cS148)))
           (i32.store
            (local.get $_M0L2c0S144)
            (local.get $_M0L3valS628))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 26 ;)
           (drop))
          (else))
         (i32.const 0)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 28 ;)
         (drop)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 30 ;)
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 33 ;)
         (local.set $_M0L3valS629
          (i32.load
           (local.get $_M0L1cS148)))
         (local.set $_M0L3valS630
          (i32.load
           (local.get $_M0L2c1S146)))
         (i32.gt_s
          (local.get $_M0L3valS629)
          (local.get $_M0L3valS630))
         (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 39 ;)
         (if
          (then
           (; source_pos moonarc3/rhae/src/rhae invariants.mbt 14 42 ;)
           (local.set $_M0L3valS631
            (i32.load
             (local.get $_M0L1cS148)))
           (i32.store
            (local.get $_M0L2c1S146)
            (local.get $_M0L3valS631))
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
        (local.tee $_M0L3valS633
         (i32.load
          (local.get $_M0L1cS148)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 16 15 ;)
       (local.set $_M0L6_2atmpS632)
       (i32.store
        (local.get $_M0L1cS148)
        (local.get $_M0L6_2atmpS632))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae invariants.mbt 16 15 ;)
       (drop)
       (br $loop:150))
      (else
       (call $moonbit.decref
        (local.get $_M0L1cS148)))))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 17 5 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 18 4 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 18 8 ;)
    (i32.add
     (local.tee $_M0L3valS635
      (i32.load
       (local.get $_M0L1rS147)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 18 13 ;)
    (local.set $_M0L6_2atmpS634)
    (i32.store
     (local.get $_M0L1rS147)
     (local.get $_M0L6_2atmpS634))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 18 13 ;)
    (; source_pos moonarc3/rhae/src/rhae invariants.mbt 18 13 ;)
    (drop)
    (br $loop:151))
   (else
    (call $moonbit.decref
     (local.get $_M0L1rS147)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 19 3 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 2 ;)
 (i32.load
  (local.get $_M0L2r0S141))
 (call $moonbit.decref
  (local.get $_M0L2r0S141))
 (local.set $_M0L3valS636)
 (i32.load
  (local.get $_M0L2r1S143))
 (call $moonbit.decref
  (local.get $_M0L2r1S143))
 (local.set $_M0L3valS637)
 (i32.load
  (local.get $_M0L2c0S144))
 (call $moonbit.decref
  (local.get $_M0L2c0S144))
 (local.set $_M0L3valS638)
 (i32.load
  (local.get $_M0L2c1S146))
 (call $moonbit.decref
  (local.get $_M0L2c1S146))
 (local.set $_M0L3valS639)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS947
   (call $moonbit.gc.malloc
    (i32.const 16)))
  (i32.const 2097152))
 (i32.store offset=12
  (local.get $_M0L3ptrS947)
  (local.get $_M0L3valS639))
 (i32.store offset=8
  (local.get $_M0L3ptrS947)
  (local.get $_M0L3valS638))
 (i32.store offset=4
  (local.get $_M0L3ptrS947)
  (local.get $_M0L3valS637))
 (i32.store
  (local.get $_M0L3ptrS947)
  (local.get $_M0L3valS636))
 (local.get $_M0L3ptrS947)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;)
 (; source_pos moonarc3/rhae/src/rhae invariants.mbt 20 18 ;))
(func $_M0FP48moonarc34rhae3src4rhae12policy__gate (param $_M0L5legalS133 i32) (param $_M0L3invS129 i32) (param $_M0L6__gridS138 i32) (param $_M0L3__hS139 i32) (param $_M0L3__wS140 i32) (param $_M0L5risksS130 i32) (param $_M0L10n__actionsS131 i32) (result i32)
 (local $_M0L7blockedS128 i32)
 (local $_M0L8filteredS132 i32)
 (local $_M0L1vS135 i32)
 (local $_M0L1vS137 i32)
 (local $_M0L6_2atmpS608 i32)
 (local $_M0L6_2atmpS609 i32)
 (local $_M0L6_2atmpS610 i32)
 (local $_M0L6_2atmpS611 i32)
 (local $_M0L6_2atmpS612 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 2 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 16 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 16 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 16 ;)
 (call $_M0FP48moonarc34rhae3src4rhae11block__noop
  (local.get $_M0L3invS129))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 31 ;)
 (local.set $_M0L6_2atmpS611)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 34 ;)
 (call $_M0FP48moonarc34rhae3src4rhae14block__revisit
  (local.get $_M0L5risksS130)
  (local.get $_M0L10n__actionsS131))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 65 ;)
 (local.set $_M0L6_2atmpS612)
 (i32.or
  (local.get $_M0L6_2atmpS611)
  (local.get $_M0L6_2atmpS612))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 65 ;)
 (local.set $_M0L6_2atmpS609)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 68 ;)
 (call $_M0FP48moonarc34rhae3src4rhae12block__empty
  (local.get $_M0L3invS129))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 84 ;)
 (local.set $_M0L6_2atmpS610)
 (i32.or
  (local.get $_M0L6_2atmpS609)
  (local.get $_M0L6_2atmpS610))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 31 84 ;)
 (local.set $_M0L7blockedS128)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 32 2 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 32 17 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 32 26 ;)
 (i32.xor
  (local.get $_M0L7blockedS128)
  (i32.const -1))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 32 40 ;)
 (local.set $_M0L6_2atmpS608)
 (i32.and
  (local.get $_M0L5legalS133)
  (local.get $_M0L6_2atmpS608))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 32 41 ;)
 (local.set $_M0L8filteredS132)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 2 ;)
 (block $join:134
  (if (result i32)
   (i32.eq
    (local.get $_M0L8filteredS132)
    (i32.const 0))
   (then
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 24 ;)
    (block $join:136
     (if (result i32)
      (i32.eq
       (local.get $_M0L5legalS133)
       (i32.const 0))
      (then
       (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 43 ;)
       (i32.const 64)
       (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 52 ;))
      (else
       (local.set $_M0L1vS137
        (local.get $_M0L5legalS133))
       (br $join:136)))
     (return))
    (local.get $_M0L1vS137)
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 62 ;))
   (else
    (local.set $_M0L1vS135
     (local.get $_M0L8filteredS132))
    (br $join:134)))
  (return))
 (local.get $_M0L1vS135)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 72 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 72 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 33 72 ;))
(func $_M0FP48moonarc34rhae3src4rhae12block__empty (param $_M0L3invS127 i32) (result i32)
 (local $_M0L7_2abindS126 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 23 2 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 23 8 ;)
 (call $_M0MPC15array5Array2atGiE
  (local.get $_M0L3invS127)
  (i32.const 1))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 23 14 ;)
 (local.tee $_M0L7_2abindS126)
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
(func $_M0FP48moonarc34rhae3src4rhae14block__revisit (param $_M0L5risksS124 i32) (param $_M0L1nS123 i32) (result i32)
 (local $_M0L7blockedS121 i32)
 (local $_M0L1iS122 i32)
 (local $_M0L3valS598 i32)
 (local $_M0L3valS599 i32)
 (local $_M0L6_2atmpS600 i32)
 (local $_M0L3valS601 i32)
 (local $_M0L6_2atmpS602 i32)
 (local $_M0L3valS603 i32)
 (local $_M0L6_2atmpS604 i32)
 (local $_M0L3valS605 i32)
 (local $_M0L6_2atmpS606 i32)
 (local $_M0L3valS607 i32)
 (local $_M0L3ptrS954 i32)
 (local $_M0L3ptrS955 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 14 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS955
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS955)
  (i32.const 0))
 (local.set $_M0L7blockedS121
  (local.get $_M0L3ptrS955))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 14 23 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS954
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS954)
  (i32.const 0))
 (local.set $_M0L1iS122
  (local.get $_M0L3ptrS954))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 2 ;)
 (loop $loop:125
  (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 8 ;)
  (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS599
    (i32.load
     (local.get $_M0L1iS122)))
   (local.get $_M0L1nS123))
  (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 13 ;)
  (if (result i32)
   (then
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 15 17 ;)
    (i32.lt_s
     (local.tee $_M0L3valS598
      (i32.load
       (local.get $_M0L1iS122)))
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
    (local.set $_M0L3valS601
     (i32.load
      (local.get $_M0L1iS122)))
    (call $_M0MPC15array5Array2atGiE
     (local.get $_M0L5risksS124)
     (local.get $_M0L3valS601))
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 15 ;)
    (local.tee $_M0L6_2atmpS600)
    (i32.const 95)
    (i32.ge_s)
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 21 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 24 ;)
      (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 34 ;)
      (local.set $_M0L3valS603
       (i32.load
        (local.get $_M0L7blockedS121)))
      (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 45 ;)
      (local.set $_M0L3valS605
       (i32.load
        (local.get $_M0L1iS122)))
      (i32.shl
       (i32.const 1)
       (local.get $_M0L3valS605))
      (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 51 ;)
      (local.set $_M0L6_2atmpS604)
      (i32.or
       (local.get $_M0L3valS603)
       (local.get $_M0L6_2atmpS604))
      (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 16 52 ;)
      (local.set $_M0L6_2atmpS602)
      (i32.store
       (local.get $_M0L7blockedS121)
       (local.get $_M0L6_2atmpS602))
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
     (local.tee $_M0L3valS607
      (i32.load
       (local.get $_M0L1iS122)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 17 13 ;)
    (local.set $_M0L6_2atmpS606)
    (i32.store
     (local.get $_M0L1iS122)
     (local.get $_M0L6_2atmpS606))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 17 13 ;)
    (drop)
    (br $loop:125))
   (else
    (call $moonbit.decref
     (local.get $_M0L1iS122)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 18 3 ;)
 (drop)
 (i32.load
  (local.get $_M0L7blockedS121))
 (call $moonbit.decref
  (local.get $_M0L7blockedS121))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 19 9 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 19 9 ;))
(func $_M0FP48moonarc34rhae3src4rhae11block__noop (param $_M0L3invS119 i32) (result i32)
 (local $_M0L7_2abindS118 i32)
 (local $_M0L7_2abindS120 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 2 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 9 ;)
 (call $_M0MPC15array5Array2atGiE
  (local.get $_M0L3invS119)
  (i32.const 5))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 15 ;)
 (local.set $_M0L7_2abindS118)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 17 ;)
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 17 ;)
 (call $_M0MPC15array5Array2atGiE
  (local.get $_M0L3invS119)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/rhae policy_gate.mbt 7 23 ;)
 (local.set $_M0L7_2abindS120)
 (if (result i32)
  (i32.eq
   (local.get $_M0L7_2abindS118)
   (i32.const 1))
  (then
   (if (result i32)
    (i32.eq
     (local.get $_M0L7_2abindS120)
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
(func $_M0FP48moonarc34rhae3src4rhae22build__candidate__rows (param $_M0L5legalS107 i32) (param $_M0L3invS116 i32) (param $_M0L3visS111 i32) (param $_M0L10path__costS115 i32) (param $_M0L8hash__loS113 i32) (param $_M0L8hash__hiS114 i32) (param $_M0L3matS112 i32) (param $_M0L6max__cS106 i32) (result i32)
 (local $_M0L1nS104 i32)
 (local $_M0L1aS105 i32)
 (local $_M0L1bS108 i32)
 (local $_M0L3novS109 i32)
 (local $_M0L7_2abindS110 i32)
 (local $_M0L3valS559 i32)
 (local $_M0L3valS560 i32)
 (local $_M0L6_2atmpS561 i32)
 (local $_M0L6_2atmpS562 i32)
 (local $_M0L6_2atmpS563 i32)
 (local $_M0L3valS564 i32)
 (local $_M0L3valS565 i32)
 (local $_M0L6_2atmpS566 i32)
 (local $_M0L6_2atmpS567 i32)
 (local $_M0L6_2atmpS568 i32)
 (local $_M0L6_2atmpS569 i32)
 (local $_M0L6_2atmpS570 i32)
 (local $_M0L6_2atmpS571 i32)
 (local $_M0L6_2atmpS572 i32)
 (local $_M0L3valS573 i32)
 (local $_M0L6_2atmpS574 i32)
 (local $_M0L6_2atmpS575 i32)
 (local $_M0L6_2atmpS576 i32)
 (local $_M0L6_2atmpS577 i32)
 (local $_M0L6_2atmpS578 i32)
 (local $_M0L6_2atmpS579 i32)
 (local $_M0L6_2atmpS580 i32)
 (local $_M0L6_2atmpS581 i32)
 (local $_M0L6_2atmpS582 i32)
 (local $_M0L6_2atmpS583 i32)
 (local $_M0L6_2atmpS584 i32)
 (local $_M0L6_2atmpS585 i32)
 (local $_M0L6_2atmpS586 i32)
 (local $_M0L6_2atmpS587 i32)
 (local $_M0L6_2atmpS588 i32)
 (local $_M0L6_2atmpS589 i32)
 (local $_M0L6_2atmpS590 i32)
 (local $_M0L6_2atmpS591 i32)
 (local $_M0L3valS592 i32)
 (local $_M0L6_2atmpS593 i32)
 (local $_M0L3valS594 i32)
 (local $_M0L3valS595 i32)
 (local $_M0L6_2atmpS596 i32)
 (local $_M0L3valS597 i32)
 (local $_M0L3ptrS956 i32)
 (local $_M0L3ptrS957 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 41 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS957
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS957)
  (i32.const 0))
 (local.set $_M0L1nS104
  (local.get $_M0L3ptrS957))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 42 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS956
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS956)
  (i32.const 1))
 (local.set $_M0L1aS105
  (local.get $_M0L3ptrS956))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 2 ;)
 (loop $loop:117
  (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 8 ;)
  (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 8 ;)
  (i32.le_s
   (local.tee $_M0L3valS560
    (i32.load
     (local.get $_M0L1aS105)))
   (i32.const 7))
  (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 14 ;)
  (if (result i32)
   (then
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 43 18 ;)
    (i32.lt_s
     (local.tee $_M0L3valS559
      (i32.load
       (local.get $_M0L1nS104)))
     (local.get $_M0L6max__cS106))
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
     (local.tee $_M0L3valS564
      (i32.load
       (local.get $_M0L1aS105)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 22 ;)
    (local.set $_M0L6_2atmpS563)
    (i32.shr_s
     (local.get $_M0L5legalS107)
     (local.get $_M0L6_2atmpS563))
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 23 ;)
    (local.tee $_M0L6_2atmpS562)
    (i32.const 1)
    (i32.and)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 28 ;)
    (local.tee $_M0L6_2atmpS561)
    (i32.const 1)
    (i32.eq)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 44 34 ;)
    (if
     (then
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 45 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 45 16 ;)
      (i32.mul
       (local.tee $_M0L3valS595
        (i32.load
         (local.get $_M0L1nS104)))
       (i32.const 13))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 45 22 ;)
      (local.set $_M0L1bS108)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 16 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 22 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 26 ;)
      (i32.sub
       (local.tee $_M0L3valS594
        (i32.load
         (local.get $_M0L1aS105)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 29 ;)
      (local.set $_M0L6_2atmpS593)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3visS111)
       (local.get $_M0L6_2atmpS593))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 46 30 ;)
      (local.tee $_M0L7_2abindS110)
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
      (local.set $_M0L3novS109)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 6 ;)
      (local.set $_M0L3valS565
       (i32.load
        (local.get $_M0L1aS105)))
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L1bS108)
       (local.get $_M0L3valS565))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 19 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 38 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 41 ;)
      (local.set $_M0L6_2atmpS566)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS566)
       (local.get $_M0L8hash__loS113))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 47 53 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 10 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 2))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 13 ;)
      (local.set $_M0L6_2atmpS567)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS567)
       (local.get $_M0L8hash__hiS114))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 25 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 38 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 3))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 41 ;)
      (local.set $_M0L6_2atmpS568)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS568)
       (local.get $_M0L10path__costS115))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 48 55 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 10 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 4))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 13 ;)
      (local.set $_M0L6_2atmpS569)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 18 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 18 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 22 ;)
      (i32.sub
       (local.tee $_M0L3valS573
        (i32.load
         (local.get $_M0L1aS105)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 25 ;)
      (local.set $_M0L6_2atmpS572)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3visS111)
       (local.get $_M0L6_2atmpS572))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 26 ;)
      (local.tee $_M0L6_2atmpS571)
      (i32.const 100)
      (i32.mul)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 30 ;)
      (local.set $_M0L6_2atmpS570)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS569)
       (local.get $_M0L6_2atmpS570))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 30 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 38 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 5))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 41 ;)
      (local.set $_M0L6_2atmpS574)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS574)
       (local.get $_M0L3novS109))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 49 49 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 10 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 6))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 13 ;)
      (local.set $_M0L6_2atmpS575)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 18 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS116)
       (i32.const 8))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 24 ;)
      (local.set $_M0L6_2atmpS576)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS575)
       (local.get $_M0L6_2atmpS576))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 24 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 38 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 7))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 41 ;)
      (local.set $_M0L6_2atmpS577)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 46 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS116)
       (i32.const 0))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 52 ;)
      (local.set $_M0L6_2atmpS578)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS577)
       (local.get $_M0L6_2atmpS578))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 50 52 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 10 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 8))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 13 ;)
      (local.set $_M0L6_2atmpS579)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 18 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS116)
       (i32.const 7))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 24 ;)
      (local.set $_M0L6_2atmpS580)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS579)
       (local.get $_M0L6_2atmpS580))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 24 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 38 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 9))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 41 ;)
      (local.set $_M0L6_2atmpS581)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 46 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 46 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS116)
       (i32.const 3))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 52 ;)
      (local.set $_M0L6_2atmpS583)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 53 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS116)
       (i32.const 4))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 59 ;)
      (local.set $_M0L6_2atmpS584)
      (i32.mul
       (local.get $_M0L6_2atmpS583)
       (local.get $_M0L6_2atmpS584))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 59 ;)
      (local.set $_M0L6_2atmpS582)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS581)
       (local.get $_M0L6_2atmpS582))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 51 59 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 10 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 10))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 14 ;)
      (local.set $_M0L6_2atmpS585)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 18 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS116)
       (i32.const 5))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 24 ;)
      (local.set $_M0L6_2atmpS586)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS585)
       (local.get $_M0L6_2atmpS586))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 24 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 34 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 38 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 11))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 42 ;)
      (local.set $_M0L6_2atmpS587)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 46 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS116)
       (i32.const 8))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 52 ;)
      (local.set $_M0L6_2atmpS588)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS587)
       (local.get $_M0L6_2atmpS588))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 52 52 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 10 ;)
      (i32.add
       (local.get $_M0L1bS108)
       (i32.const 12))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 14 ;)
      (local.set $_M0L6_2atmpS589)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 18 ;)
      (call $_M0MPC15array5Array2atGiE
       (local.get $_M0L3invS116)
       (i32.const 9))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 24 ;)
      (local.set $_M0L6_2atmpS590)
      (call $_M0MPC15array5Array3setGiE
       (local.get $_M0L3matS112)
       (local.get $_M0L6_2atmpS589)
       (local.get $_M0L6_2atmpS590))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 53 24 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 54 6 ;)
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 54 10 ;)
      (i32.add
       (local.tee $_M0L3valS592
        (i32.load
         (local.get $_M0L1nS104)))
       (i32.const 1))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 54 15 ;)
      (local.set $_M0L6_2atmpS591)
      (i32.store
       (local.get $_M0L1nS104)
       (local.get $_M0L6_2atmpS591))
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
     (local.tee $_M0L3valS597
      (i32.load
       (local.get $_M0L1aS105)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 56 13 ;)
    (local.set $_M0L6_2atmpS596)
    (i32.store
     (local.get $_M0L1aS105)
     (local.get $_M0L6_2atmpS596))
    (i32.const 0)
    (; source_pos moonarc3/rhae/src/rhae topk.mbt 56 13 ;)
    (drop)
    (br $loop:117))
   (else
    (call $moonbit.decref
     (local.get $_M0L1aS105)))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 57 3 ;)
 (drop)
 (i32.load
  (local.get $_M0L1nS104))
 (call $moonbit.decref
  (local.get $_M0L1nS104))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 58 3 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 58 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae16topk__candidates (param $_M0L5pairsS100 i32) (param $_M0L1nS99 i32) (param $_M0L1kS93 i32) (param $_M0L3outS103 i32) (result i32)
 (local $_M0L2kkS92 i32)
 (local $_M0L4usedS94 i32)
 (local $_M0L6n__selS95 i32)
 (local $_M0L7best__iS96 i32)
 (local $_M0L7best__sS97 i32)
 (local $_M0L1iS98 i32)
 (local $_M0L3valS534 i32)
 (local $_M0L3valS535 i32)
 (local $_M0L6_2atmpS536 i32)
 (local $_M0L3valS537 i32)
 (local $_M0L6_2atmpS538 i32)
 (local $_M0L6_2atmpS539 i32)
 (local $_M0L3valS540 i32)
 (local $_M0L6_2atmpS541 i32)
 (local $_M0L3valS542 i32)
 (local $_M0L6_2atmpS543 i32)
 (local $_M0L6_2atmpS544 i32)
 (local $_M0L6_2atmpS545 i32)
 (local $_M0L3valS546 i32)
 (local $_M0L3valS547 i32)
 (local $_M0L6_2atmpS548 i32)
 (local $_M0L3valS549 i32)
 (local $_M0L3valS550 i32)
 (local $_M0L3valS551 i32)
 (local $_M0L3valS552 i32)
 (local $_M0L3valS553 i32)
 (local $_M0L6_2atmpS554 i32)
 (local $_M0L6_2atmpS555 i32)
 (local $_M0L3valS556 i32)
 (local $_M0L6_2atmpS557 i32)
 (local $_M0L3valS558 i32)
 (local $_M0L3ptrS958 i32)
 (local $_M0L3ptrS959 i32)
 (local $_M0L3ptrS960 i32)
 (local $_M0L3ptrS961 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 2 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 13 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 16 ;)
 (i32.gt_s
  (local.get $_M0L1kS93)
  (i32.const 6))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 21 ;)
 (if (result i32)
  (then
   (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 24 ;)
   (i32.const 6)
   (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 25 ;))
  (else
   (local.get $_M0L1kS93)))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 11 38 ;)
 (local.set $_M0L2kkS92)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 12 2 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 12 26 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 64)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 12 44 ;)
 (local.set $_M0L4usedS94)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 13 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS961
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS961)
  (i32.const 0))
 (local.set $_M0L6n__selS95
  (local.get $_M0L3ptrS961))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 14 2 ;)
 (block $break:102
  (loop $loop:102
   (; source_pos moonarc3/rhae/src/rhae topk.mbt 14 8 ;)
   (i32.lt_s
    (local.tee $_M0L3valS534
     (i32.load
      (local.get $_M0L6n__selS95)))
    (local.get $_M0L2kkS92))
   (; source_pos moonarc3/rhae/src/rhae topk.mbt 14 18 ;)
   (if
    (then
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 15 4 ;)
     (call $moonbit.store_object_meta
      (local.tee $_M0L3ptrS960
       (call $moonbit.gc.malloc
        (i32.const 4)))
      (i32.const 524288))
     (i32.store
      (local.get $_M0L3ptrS960)
      (i32.const -1))
     (local.set $_M0L7best__iS96
      (local.get $_M0L3ptrS960))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 15 25 ;)
     (call $moonbit.store_object_meta
      (local.tee $_M0L3ptrS959
       (call $moonbit.gc.malloc
        (i32.const 4)))
      (i32.const 524288))
     (i32.store
      (local.get $_M0L3ptrS959)
      (i32.const -1))
     (local.set $_M0L7best__sS97
      (local.get $_M0L3ptrS959))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 16 4 ;)
     (call $moonbit.store_object_meta
      (local.tee $_M0L3ptrS958
       (call $moonbit.gc.malloc
        (i32.const 4)))
      (i32.const 524288))
     (i32.store
      (local.get $_M0L3ptrS958)
      (i32.const 0))
     (local.set $_M0L1iS98
      (local.get $_M0L3ptrS958))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 17 4 ;)
     (loop $loop:101
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 17 10 ;)
      (i32.lt_s
       (local.tee $_M0L3valS535
        (i32.load
         (local.get $_M0L1iS98)))
       (local.get $_M0L1nS99))
      (; source_pos moonarc3/rhae/src/rhae topk.mbt 17 15 ;)
      (if
       (then
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 6 ;)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 9 ;)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 9 ;)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 9 ;)
        (local.set $_M0L3valS542
         (i32.load
          (local.get $_M0L1iS98)))
        (call $_M0MPC15array5Array2atGiE
         (local.get $_M0L4usedS94)
         (local.get $_M0L3valS542))
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 16 ;)
        (local.tee $_M0L6_2atmpS541)
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
           (local.tee $_M0L3valS540
            (i32.load
             (local.get $_M0L1iS98)))
           (i32.const 2))
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 34 ;)
          (local.tee $_M0L6_2atmpS539)
          (i32.const 1)
          (i32.add)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 36 ;)
          (local.set $_M0L6_2atmpS538)
          (call $_M0MPC15array5Array2atGiE
           (local.get $_M0L5pairsS100)
           (local.get $_M0L6_2atmpS538))
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 18 37 ;)
          (local.set $_M0L6_2atmpS536)
          (local.set $_M0L3valS537
           (i32.load
            (local.get $_M0L7best__sS97)))
          (i32.gt_s
           (local.get $_M0L6_2atmpS536)
           (local.get $_M0L3valS537))
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
           (local.tee $_M0L3valS546
            (i32.load
             (local.get $_M0L1iS98)))
           (i32.const 2))
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 26 ;)
          (local.tee $_M0L6_2atmpS545)
          (i32.const 1)
          (i32.add)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 28 ;)
          (local.set $_M0L6_2atmpS544)
          (call $_M0MPC15array5Array2atGiE
           (local.get $_M0L5pairsS100)
           (local.get $_M0L6_2atmpS544))
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 29 ;)
          (local.set $_M0L6_2atmpS543)
          (i32.store
           (local.get $_M0L7best__sS97)
           (local.get $_M0L6_2atmpS543))
          (i32.const 0)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 29 ;)
          (drop)
          (; source_pos moonarc3/rhae/src/rhae topk.mbt 19 31 ;)
          (local.set $_M0L3valS547
           (i32.load
            (local.get $_M0L1iS98)))
          (i32.store
           (local.get $_M0L7best__iS96)
           (local.get $_M0L3valS547))
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
         (local.tee $_M0L3valS549
          (i32.load
           (local.get $_M0L1iS98)))
         (i32.const 1))
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 21 15 ;)
        (local.set $_M0L6_2atmpS548)
        (i32.store
         (local.get $_M0L1iS98)
         (local.get $_M0L6_2atmpS548))
        (i32.const 0)
        (; source_pos moonarc3/rhae/src/rhae topk.mbt 21 15 ;)
        (drop)
        (br $loop:101))
       (else
        (call $moonbit.decref
         (local.get $_M0L1iS98)))))
     (i32.const 0)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 22 5 ;)
     (drop)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 4 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 7 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 7 ;)
     (i32.eq
      (local.tee $_M0L3valS551
       (i32.load
        (local.get $_M0L7best__iS96)))
      (i32.const -1))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 19 ;)
     (if (result i32)
      (then
       (call $moonbit.decref
        (local.get $_M0L7best__sS97))
       (i32.const 1))
      (else
       (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 23 ;)
       (i32.load
        (local.get $_M0L7best__sS97))
       (call $moonbit.decref
        (local.get $_M0L7best__sS97))
       (local.tee $_M0L3valS550)
       (i32.const 0)
       (i32.lt_s)
       (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 33 ;)))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 33 ;)
     (if
      (then
       (call $moonbit.decref
        (local.get $_M0L7best__iS96))
       (call $moonbit.decref
        (local.get $_M0L4usedS94))
       (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 36 ;)
       (br $break:102))
      (else))
     (i32.const 0)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 23 43 ;)
     (drop)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 24 4 ;)
     (local.set $_M0L3valS552
      (i32.load
       (local.get $_M0L7best__iS96)))
     (call $_M0MPC15array5Array3setGiE
      (local.get $_M0L4usedS94)
      (local.get $_M0L3valS552)
      (i32.const 1))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 24 20 ;)
     (drop)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 4 ;)
     (local.set $_M0L3valS553
      (i32.load
       (local.get $_M0L6n__selS95)))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 17 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 23 ;)
     (i32.load
      (local.get $_M0L7best__iS96))
     (call $moonbit.decref
      (local.get $_M0L7best__iS96))
     (local.tee $_M0L3valS556)
     (i32.const 2)
     (i32.mul)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 31 ;)
     (local.set $_M0L6_2atmpS555)
     (call $_M0MPC15array5Array2atGiE
      (local.get $_M0L5pairsS100)
      (local.get $_M0L6_2atmpS555))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 32 ;)
     (local.set $_M0L6_2atmpS554)
     (call $_M0MPC15array5Array3setGiE
      (local.get $_M0L3outS103)
      (local.get $_M0L3valS553)
      (local.get $_M0L6_2atmpS554))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 25 32 ;)
     (drop)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 4 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 12 ;)
     (i32.add
      (local.tee $_M0L3valS558
       (i32.load
        (local.get $_M0L6n__selS95)))
      (i32.const 1))
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 21 ;)
     (local.set $_M0L6_2atmpS557)
     (i32.store
      (local.get $_M0L6n__selS95)
      (local.get $_M0L6_2atmpS557))
     (i32.const 0)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 21 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 21 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 21 ;)
     (; source_pos moonarc3/rhae/src/rhae topk.mbt 26 21 ;)
     (drop)
     (br $loop:102))
    (else
     (call $moonbit.decref
      (local.get $_M0L4usedS94))))))
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 27 3 ;)
 (drop)
 (i32.load
  (local.get $_M0L6n__selS95))
 (call $moonbit.decref
  (local.get $_M0L6n__selS95))
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 28 7 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 28 7 ;)
 (; source_pos moonarc3/rhae/src/rhae topk.mbt 28 7 ;))
(func $_M0FP48moonarc34rhae3src4rhae14visited__reset (result i32)
 (local $_M0L1iS90 i32)
 (local $_M0L3valS530 i32)
 (local $_M0L3valS531 i32)
 (local $_M0L6_2atmpS532 i32)
 (local $_M0L3valS533 i32)
 (local $_M0L3ptrS962 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS962
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS962)
  (i32.const 0))
 (local.set $_M0L1iS90
  (local.get $_M0L3ptrS962))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 17 ;)
 (loop $loop:91
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 23 ;)
  (i32.lt_s
   (local.tee $_M0L3valS530
    (i32.load
     (local.get $_M0L1iS90)))
   (i32.const 32))
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 29 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 32 ;)
    (local.set $_M0L3valS531
     (i32.load
      (local.get $_M0L1iS90)))
    (call $_M0MPC15array5Array3setGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)
     (local.get $_M0L3valS531)
     (i32.const 0))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 51 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 53 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 57 ;)
    (i32.add
     (local.tee $_M0L3valS533
      (i32.load
       (local.get $_M0L1iS90)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 149 62 ;)
    (local.set $_M0L6_2atmpS532)
    (i32.store
     (local.get $_M0L1iS90)
     (local.get $_M0L6_2atmpS532))
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
 (local $_M0L6_2atmpS524 i32)
 (local $_M0L6_2atmpS525 i32)
 (local $_M0L6_2atmpS526 i32)
 (local $_M0L6_2atmpS527 i32)
 (local $_M0L6_2atmpS528 i32)
 (local $_M0L6_2atmpS529 i32)
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
 (local.set $_M0L6_2atmpS524)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 25 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 25 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 38 ;)
 (i32.div_s
  (local.get $_M0L1sS87)
  (i32.const 32))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 44 ;)
 (local.set $_M0L6_2atmpS529)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)
  (local.get $_M0L6_2atmpS529))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 45 ;)
 (local.set $_M0L6_2atmpS526)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 49 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 55 ;)
 (i32.rem_s
  (local.get $_M0L1sS87)
  (i32.const 32))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 61 ;)
 (local.set $_M0L6_2atmpS528)
 (i32.shl
  (i32.const 1)
  (local.get $_M0L6_2atmpS528))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 62 ;)
 (local.set $_M0L6_2atmpS527)
 (i32.or
  (local.get $_M0L6_2atmpS526)
  (local.get $_M0L6_2atmpS527))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 63 ;)
 (local.set $_M0L6_2atmpS525)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)
  (local.get $_M0L6_2atmpS524)
  (local.get $_M0L6_2atmpS525))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 63 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 145 63 ;))
(func $_M0FP48moonarc34rhae3src4rhae14visited__check (param $_M0L2loS85 i32) (param $_M0L2hiS86 i32) (result i32)
 (local $_M0L1sS84 i32)
 (local $_M0L6_2atmpS519 i32)
 (local $_M0L6_2atmpS520 i32)
 (local $_M0L6_2atmpS521 i32)
 (local $_M0L6_2atmpS522 i32)
 (local $_M0L6_2atmpS523 i32)
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
 (local.set $_M0L6_2atmpS523)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae13visited__bits)
  (local.get $_M0L6_2atmpS523))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 24 ;)
 (local.set $_M0L6_2atmpS521)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 29 ;)
 (i32.rem_s
  (local.get $_M0L1sS84)
  (i32.const 32))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 35 ;)
 (local.set $_M0L6_2atmpS522)
 (i32.shr_s
  (local.get $_M0L6_2atmpS521)
  (local.get $_M0L6_2atmpS522))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 36 ;)
 (local.tee $_M0L6_2atmpS520)
 (i32.const 1)
 (i32.and)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 41 ;)
 (local.tee $_M0L6_2atmpS519)
 (i32.const 1)
 (i32.eq)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 47 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 140 47 ;))
(func $_M0FP48moonarc34rhae3src4rhae9tt__store (param $_M0L2loS79 i32) (param $_M0L2hiS80 i32) (param $_M0L12best__actionS82 i32) (param $_M0L5scoreS83 i32) (result i32)
 (local $_M0L1sS78 i32)
 (local $_M0L1bS81 i32)
 (local $_M0L6_2atmpS516 i32)
 (local $_M0L6_2atmpS517 i32)
 (local $_M0L6_2atmpS518 i32)
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
 (local.set $_M0L6_2atmpS516)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
  (local.get $_M0L6_2atmpS516)
  (local.get $_M0L2hiS80))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 131 46 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 15 ;)
 (i32.add
  (local.get $_M0L1bS81)
  (i32.const 2))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 18 ;)
 (local.set $_M0L6_2atmpS517)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
  (local.get $_M0L6_2atmpS517)
  (local.get $_M0L12best__actionS82))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 33 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 35 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 48 ;)
 (i32.add
  (local.get $_M0L1bS81)
  (i32.const 3))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 51 ;)
 (local.set $_M0L6_2atmpS518)
 (call $_M0MPC15array5Array3setGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
  (local.get $_M0L6_2atmpS518)
  (local.get $_M0L5scoreS83))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 60 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 60 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 132 60 ;))
(func $_M0FP48moonarc34rhae3src4rhae10tt__lookup (param $_M0L2loS75 i32) (param $_M0L2hiS76 i32) (result i32)
 (local $_M0L1sS74 i32)
 (local $_M0L1bS77 i32)
 (local $_M0L6_2atmpS509 i32)
 (local $_M0L6_2atmpS510 i32)
 (local $_M0L6_2atmpS511 i32)
 (local $_M0L6_2atmpS512 i32)
 (local $_M0L6_2atmpS513 i32)
 (local $_M0L6_2atmpS514 i32)
 (local $_M0L6_2atmpS515 i32)
 (local $_M0L3ptrS963 i32)
 (local $_M0L3ptrS964 i32)
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
 (local.tee $_M0L6_2atmpS511)
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
   (local.set $_M0L6_2atmpS510)
   (call $_M0MPC15array5Array2atGiE
    (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
    (local.get $_M0L6_2atmpS510))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 122 47 ;)
   (local.tee $_M0L6_2atmpS509)
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
   (local.set $_M0L6_2atmpS515)
   (call $_M0MPC15array5Array2atGiE
    (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
    (local.get $_M0L6_2atmpS515))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 28 ;)
   (local.set $_M0L6_2atmpS512)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 30 ;)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 43 ;)
   (i32.add
    (local.get $_M0L1bS77)
    (i32.const 3))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 46 ;)
   (local.set $_M0L6_2atmpS514)
   (call $_M0MPC15array5Array2atGiE
    (global.get $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
    (local.get $_M0L6_2atmpS514))
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 47 ;)
   (local.set $_M0L6_2atmpS513)
   (call $moonbit.store_object_meta
    (local.tee $_M0L3ptrS963
     (call $moonbit.gc.malloc
      (i32.const 12)))
    (i32.const 1572864))
   (i32.store offset=8
    (local.get $_M0L3ptrS963)
    (local.get $_M0L6_2atmpS513))
   (i32.store offset=4
    (local.get $_M0L3ptrS963)
    (local.get $_M0L6_2atmpS512))
   (i32.store
    (local.get $_M0L3ptrS963)
    (i32.const 1))
   (local.get $_M0L3ptrS963)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 123 48 ;))
  (else
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 125 4 ;)
   (call $moonbit.store_object_meta
    (local.tee $_M0L3ptrS964
     (call $moonbit.gc.malloc
      (i32.const 12)))
    (i32.const 1572864))
   (i32.store offset=8
    (local.get $_M0L3ptrS964)
    (i32.const 0))
   (i32.store offset=4
    (local.get $_M0L3ptrS964)
    (i32.const 0))
   (i32.store
    (local.get $_M0L3ptrS964)
    (i32.const 0))
   (local.get $_M0L3ptrS964)
   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 125 17 ;)))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 126 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 126 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 126 3 ;))
(func $_M0FP48moonarc34rhae3src4rhae8tt__slot (param $_M0L2loS72 i32) (param $_M0L2hiS73 i32) (result i32)
 (local $_M0L6_2atmpS507 i32)
 (local $_M0L6_2atmpS508 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 117 2 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 117 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 117 4 ;)
 (i32.xor
  (local.get $_M0L2loS72)
  (local.get $_M0L2hiS73))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 117 11 ;)
 (local.tee $_M0L6_2atmpS508)
 (i32.const -1640531527)
 (i32.mul)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 117 25 ;)
 (local.tee $_M0L6_2atmpS507)
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
 (local $_M0L3valS444 i32)
 (local $_M0L3valS445 i32)
 (local $_M0L3valS446 i32)
 (local $_M0L6_2atmpS447 i32)
 (local $_M0L3valS448 i32)
 (local $_M0L6_2atmpS449 i32)
 (local $_M0L6_2atmpS450 i32)
 (local $_M0L3valS451 i32)
 (local $_M0L6_2atmpS452 i32)
 (local $_M0L6_2atmpS453 i32)
 (local $_M0L3valS454 i32)
 (local $_M0L3valS455 i32)
 (local $_M0L3valS456 i32)
 (local $_M0L3valS457 i32)
 (local $_M0L6_2atmpS458 i32)
 (local $_M0L6_2atmpS459 i32)
 (local $_M0L3valS460 i32)
 (local $_M0L6_2atmpS461 i32)
 (local $_M0L6_2atmpS462 i32)
 (local $_M0L6_2atmpS463 i32)
 (local $_M0L3valS464 i32)
 (local $_M0L6_2atmpS465 i32)
 (local $_M0L3valS466 i32)
 (local $_M0L6_2atmpS467 i32)
 (local $_M0L3valS468 i32)
 (local $_M0L6_2atmpS469 i32)
 (local $_M0L3valS470 i32)
 (local $_M0L3valS471 i32)
 (local $_M0L6_2atmpS472 i32)
 (local $_M0L6_2atmpS473 i32)
 (local $_M0L3valS474 i32)
 (local $_M0L6_2atmpS475 i32)
 (local $_M0L3valS476 i32)
 (local $_M0L6_2atmpS477 i32)
 (local $_M0L3valS478 i32)
 (local $_M0L3valS479 i32)
 (local $_M0L3valS480 i32)
 (local $_M0L6_2atmpS481 i32)
 (local $_M0L6_2atmpS482 i32)
 (local $_M0L6_2atmpS483 i32)
 (local $_M0L3valS484 i32)
 (local $_M0L6_2atmpS485 i32)
 (local $_M0L3valS486 i32)
 (local $_M0L3valS487 i32)
 (local $_M0L3valS488 i32)
 (local $_M0L6_2atmpS489 i32)
 (local $_M0L6_2atmpS490 i32)
 (local $_M0L3valS491 i32)
 (local $_M0L3valS492 i32)
 (local $_M0L6_2atmpS493 i32)
 (local $_M0L3valS494 i32)
 (local $_M0L3valS495 i32)
 (local $_M0L3valS496 i32)
 (local $_M0L3valS497 i32)
 (local $_M0L3valS498 i32)
 (local $_M0L3valS499 i32)
 (local $_M0L3valS500 i32)
 (local $_M0L3valS501 i32)
 (local $_M0L3valS502 i32)
 (local $_M0L6_2atmpS503 i32)
 (local $_M0L3valS504 i32)
 (local $_M0L3valS505 i32)
 (local $_M0L3valS506 i32)
 (local $_M0L3ptrS965 i32)
 (local $_M0L3ptrS977 i32)
 (local $_M0L3ptrS978 i32)
 (local $_M0L3ptrS979 i32)
 (local $_M0L3ptrS980 i32)
 (local $_M0L3ptrS981 i32)
 (local $_M0L3ptrS982 i32)
 (local $_M0L3ptrS983 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 75 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 75 16 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 76 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS983
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS983)
  (i32.const 2147483647))
 (local.set $_M0L8best__loS53
  (local.get $_M0L3ptrS983))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 76 32 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS982
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS982)
  (i32.const 2147483647))
 (local.set $_M0L8best__hiS54
  (local.get $_M0L3ptrS982))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 77 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS981
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS981)
  (i32.const 0))
 (local.set $_M0L1tS55
  (local.get $_M0L3ptrS981))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 78 2 ;)
 (loop $loop:71
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 78 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS444
    (i32.load
     (local.get $_M0L1tS55)))
   (i32.const 8))
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 78 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 79 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS980
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS980)
     (i32.const 0))
    (local.set $_M0L2loS56
     (local.get $_M0L3ptrS980))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 79 20 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS979
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS979)
     (i32.const 0))
    (local.set $_M0L2hiS57
     (local.get $_M0L3ptrS979))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 80 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS978
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS978)
     (i32.const 0))
    (local.set $_M0L1rS58
     (local.get $_M0L3ptrS978))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 81 4 ;)
    (loop $loop:70
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 81 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS445
       (i32.load
        (local.get $_M0L1rS58)))
      (local.get $_M0L1hS59))
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 81 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 82 6 ;)
       (call $moonbit.store_object_meta
        (local.tee $_M0L3ptrS977
         (call $moonbit.gc.malloc
          (i32.const 4)))
        (i32.const 524288))
       (i32.store
        (local.get $_M0L3ptrS977)
        (i32.const 0))
       (local.set $_M0L1cS60
        (local.get $_M0L3ptrS977))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 83 6 ;)
       (loop $loop:69
        (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 83 12 ;)
        (i32.lt_s
         (local.tee $_M0L3valS446
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
           (local.tee $_M0L3valS492
            (i32.load
             (local.get $_M0L1rS58)))
           (local.get $_M0L1wS61))
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 84 30 ;)
          (local.set $_M0L6_2atmpS490)
          (local.set $_M0L3valS491
           (i32.load
            (local.get $_M0L1cS60)))
          (i32.add
           (local.get $_M0L6_2atmpS490)
           (local.get $_M0L3valS491))
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 84 34 ;)
          (local.set $_M0L6_2atmpS489)
          (call $_M0MPC15array5Array2atGiE
           (local.get $_M0L4gridS63)
           (local.get $_M0L6_2atmpS489))
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 84 35 ;)
          (local.set $_M0L5colorS62)
          (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 85 8 ;)
          (block $outer/966 (result i32)
           (block $join:64
            (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 85 23 ;)
            (local.set $_M0L7_2abindS68
             (i32.load
              (local.get $_M0L1tS55)))
            (block $switch_int/967
             (block $switch_default/968
              (block $switch_int_7/976
               (block $switch_int_6/975
                (block $switch_int_5/974
                 (block $switch_int_4/973
                  (block $switch_int_3/972
                   (block $switch_int_2/971
                    (block $switch_int_1/970
                     (block $switch_int_0/969
                      (local.get $_M0L7_2abindS68)
                      (br_table
                       $switch_int_0/969
                       $switch_int_1/970
                       $switch_int_2/971
                       $switch_int_3/972
                       $switch_int_4/973
                       $switch_int_5/974
                       $switch_int_6/975
                       $switch_int_7/976
                       $switch_default/968
                       ))
                     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 86 15 ;)
                     (local.set $_M0L3valS455
                      (i32.load
                       (local.get $_M0L1rS58)))
                     (local.set $_M0L3valS456
                      (i32.load
                       (local.get $_M0L1cS60)))
                     (local.get $_M0L3valS455)
                     (local.set $_M0L2tcS66
                      (local.get $_M0L3valS456))
                     (local.set $_M0L2trS65)
                     (br $join:64))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 87 15 ;)
                    (local.set $_M0L3valS457
                     (i32.load
                      (local.get $_M0L1cS60)))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 87 23 ;)
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 87 23 ;)
                    (i32.sub
                     (local.get $_M0L1hS59)
                     (i32.const 1))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 87 26 ;)
                    (local.set $_M0L6_2atmpS459)
                    (local.set $_M0L3valS460
                     (i32.load
                      (local.get $_M0L1rS58)))
                    (i32.sub
                     (local.get $_M0L6_2atmpS459)
                     (local.get $_M0L3valS460))
                    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 87 28 ;)
                    (local.set $_M0L6_2atmpS458)
                    (local.get $_M0L3valS457)
                    (local.set $_M0L2tcS66
                     (local.get $_M0L6_2atmpS458))
                    (local.set $_M0L2trS65)
                    (br $join:64))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 15 ;)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 16 ;)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 16 ;)
                   (i32.sub
                    (local.get $_M0L1hS59)
                    (i32.const 1))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 19 ;)
                   (local.set $_M0L6_2atmpS465)
                   (local.set $_M0L3valS466
                    (i32.load
                     (local.get $_M0L1rS58)))
                   (i32.sub
                    (local.get $_M0L6_2atmpS465)
                    (local.get $_M0L3valS466))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 21 ;)
                   (local.set $_M0L6_2atmpS461)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 23 ;)
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 23 ;)
                   (i32.sub
                    (local.get $_M0L1wS61)
                    (i32.const 1))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 26 ;)
                   (local.set $_M0L6_2atmpS463)
                   (local.set $_M0L3valS464
                    (i32.load
                     (local.get $_M0L1cS60)))
                   (i32.sub
                    (local.get $_M0L6_2atmpS463)
                    (local.get $_M0L3valS464))
                   (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 88 28 ;)
                   (local.set $_M0L6_2atmpS462)
                   (local.get $_M0L6_2atmpS461)
                   (local.set $_M0L2tcS66
                    (local.get $_M0L6_2atmpS462))
                   (local.set $_M0L2trS65)
                   (br $join:64))
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 89 15 ;)
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 89 16 ;)
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 89 16 ;)
                  (i32.sub
                   (local.get $_M0L1wS61)
                   (i32.const 1))
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 89 19 ;)
                  (local.set $_M0L6_2atmpS469)
                  (local.set $_M0L3valS470
                   (i32.load
                    (local.get $_M0L1cS60)))
                  (i32.sub
                   (local.get $_M0L6_2atmpS469)
                   (local.get $_M0L3valS470))
                  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 89 21 ;)
                  (local.set $_M0L6_2atmpS467)
                  (local.set $_M0L3valS468
                   (i32.load
                    (local.get $_M0L1rS58)))
                  (local.get $_M0L6_2atmpS467)
                  (local.set $_M0L2tcS66
                   (local.get $_M0L3valS468))
                  (local.set $_M0L2trS65)
                  (br $join:64))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 90 15 ;)
                 (local.set $_M0L3valS471
                  (i32.load
                   (local.get $_M0L1rS58)))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 90 23 ;)
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 90 23 ;)
                 (i32.sub
                  (local.get $_M0L1wS61)
                  (i32.const 1))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 90 26 ;)
                 (local.set $_M0L6_2atmpS473)
                 (local.set $_M0L3valS474
                  (i32.load
                   (local.get $_M0L1cS60)))
                 (i32.sub
                  (local.get $_M0L6_2atmpS473)
                  (local.get $_M0L3valS474))
                 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 90 28 ;)
                 (local.set $_M0L6_2atmpS472)
                 (local.get $_M0L3valS471)
                 (local.set $_M0L2tcS66
                  (local.get $_M0L6_2atmpS472))
                 (local.set $_M0L2trS65)
                 (br $join:64))
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 91 15 ;)
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 91 16 ;)
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 91 16 ;)
                (i32.sub
                 (local.get $_M0L1hS59)
                 (i32.const 1))
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 91 19 ;)
                (local.set $_M0L6_2atmpS477)
                (local.set $_M0L3valS478
                 (i32.load
                  (local.get $_M0L1rS58)))
                (i32.sub
                 (local.get $_M0L6_2atmpS477)
                 (local.get $_M0L3valS478))
                (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 91 21 ;)
                (local.set $_M0L6_2atmpS475)
                (local.set $_M0L3valS476
                 (i32.load
                  (local.get $_M0L1cS60)))
                (local.get $_M0L6_2atmpS475)
                (local.set $_M0L2tcS66
                 (local.get $_M0L3valS476))
                (local.set $_M0L2trS65)
                (br $join:64))
               (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 92 15 ;)
               (local.set $_M0L3valS479
                (i32.load
                 (local.get $_M0L1cS60)))
               (local.set $_M0L3valS480
                (i32.load
                 (local.get $_M0L1rS58)))
               (local.get $_M0L3valS479)
               (local.set $_M0L2tcS66
                (local.get $_M0L3valS480))
               (local.set $_M0L2trS65)
               (br $join:64))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 15 ;)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 16 ;)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 16 ;)
              (i32.sub
               (local.get $_M0L1wS61)
               (i32.const 1))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 19 ;)
              (local.set $_M0L6_2atmpS485)
              (local.set $_M0L3valS486
               (i32.load
                (local.get $_M0L1cS60)))
              (i32.sub
               (local.get $_M0L6_2atmpS485)
               (local.get $_M0L3valS486))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 21 ;)
              (local.set $_M0L6_2atmpS481)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 23 ;)
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 23 ;)
              (i32.sub
               (local.get $_M0L1hS59)
               (i32.const 1))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 26 ;)
              (local.set $_M0L6_2atmpS483)
              (local.set $_M0L3valS484
               (i32.load
                (local.get $_M0L1rS58)))
              (i32.sub
               (local.get $_M0L6_2atmpS483)
               (local.get $_M0L3valS484))
              (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 93 28 ;)
              (local.set $_M0L6_2atmpS482)
              (local.get $_M0L6_2atmpS481)
              (local.set $_M0L2tcS66
               (local.get $_M0L6_2atmpS482))
              (local.set $_M0L2trS65)
              (br $join:64))
             (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 94 15 ;)
             (local.set $_M0L3valS487
              (i32.load
               (local.get $_M0L1rS58)))
             (local.set $_M0L3valS488
              (i32.load
               (local.get $_M0L1cS60)))
             (local.get $_M0L3valS487)
             (local.set $_M0L2tcS66
              (local.get $_M0L3valS488))
             (local.set $_M0L2trS65)
             (br $join:64))
            (i32.const 0)
            (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 95 9 ;)
            (br $outer/966))
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
           (local.set $_M0L3valS448
            (i32.load
             (local.get $_M0L2loS56)))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 18 ;)
           (call $_M0MPC15array5Array2atGiE
            (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)
            (local.get $_M0L3idxS67))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 28 ;)
           (local.set $_M0L6_2atmpS449)
           (i32.xor
            (local.get $_M0L3valS448)
            (local.get $_M0L6_2atmpS449))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 28 ;)
           (local.set $_M0L6_2atmpS447)
           (i32.store
            (local.get $_M0L2loS56)
            (local.get $_M0L6_2atmpS447))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 28 ;)
           (drop)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 30 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 35 ;)
           (local.set $_M0L3valS451
            (i32.load
             (local.get $_M0L2hiS57)))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 40 ;)
           (call $_M0MPC15array5Array2atGiE
            (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)
            (local.get $_M0L3idxS67))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 50 ;)
           (local.set $_M0L6_2atmpS452)
           (i32.xor
            (local.get $_M0L3valS451)
            (local.get $_M0L6_2atmpS452))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 50 ;)
           (local.set $_M0L6_2atmpS450)
           (i32.store
            (local.get $_M0L2hiS57)
            (local.get $_M0L6_2atmpS450))
           (i32.const 0)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 97 50 ;)
           (drop)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 98 8 ;)
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 98 12 ;)
           (i32.add
            (local.tee $_M0L3valS454
             (i32.load
              (local.get $_M0L1cS60)))
            (i32.const 1))
           (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 98 17 ;)
           (local.set $_M0L6_2atmpS453)
           (i32.store
            (local.get $_M0L1cS60)
            (local.get $_M0L6_2atmpS453))
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
        (local.tee $_M0L3valS494
         (i32.load
          (local.get $_M0L1rS58)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 100 15 ;)
       (local.set $_M0L6_2atmpS493)
       (i32.store
        (local.get $_M0L1rS58)
        (local.get $_M0L6_2atmpS493))
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
    (local.set $_M0L3valS499
     (i32.load
      (local.get $_M0L2loS56)))
    (local.set $_M0L3valS500
     (i32.load
      (local.get $_M0L8best__loS53)))
    (i32.lt_s
     (local.get $_M0L3valS499)
     (local.get $_M0L3valS500))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 19 ;)
    (if (result i32)
     (then
      (i32.const 1))
     (else
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 24 ;)
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 24 ;)
      (local.set $_M0L3valS497
       (i32.load
        (local.get $_M0L2loS56)))
      (local.set $_M0L3valS498
       (i32.load
        (local.get $_M0L8best__loS53)))
      (i32.eq
       (local.get $_M0L3valS497)
       (local.get $_M0L3valS498))
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 37 ;)
      (if (result i32)
       (then
        (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 102 41 ;)
        (local.set $_M0L3valS495
         (i32.load
          (local.get $_M0L2hiS57)))
        (local.set $_M0L3valS496
         (i32.load
          (local.get $_M0L8best__hiS54)))
        (i32.lt_s
         (local.get $_M0L3valS495)
         (local.get $_M0L3valS496))
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
      (local.set $_M0L3valS501)
      (i32.store
       (local.get $_M0L8best__loS53)
       (local.get $_M0L3valS501))
      (i32.const 0)
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 103 18 ;)
      (drop)
      (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 103 20 ;)
      (i32.load
       (local.get $_M0L2hiS57))
      (call $moonbit.decref
       (local.get $_M0L2hiS57))
      (local.set $_M0L3valS502)
      (i32.store
       (local.get $_M0L8best__hiS54)
       (local.get $_M0L3valS502))
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
     (local.tee $_M0L3valS504
      (i32.load
       (local.get $_M0L1tS55)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 105 13 ;)
    (local.set $_M0L6_2atmpS503)
    (i32.store
     (local.get $_M0L1tS55)
     (local.get $_M0L6_2atmpS503))
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
 (local.set $_M0L3valS505)
 (i32.load
  (local.get $_M0L8best__hiS54))
 (call $moonbit.decref
  (local.get $_M0L8best__hiS54))
 (local.set $_M0L3valS506)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS965
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS965)
  (local.get $_M0L3valS506))
 (i32.store
  (local.get $_M0L3ptrS965)
  (local.get $_M0L3valS505))
 (local.get $_M0L3ptrS965)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 107 20 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 107 20 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 107 20 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 107 20 ;))
(func $_M0FP48moonarc34rhae3src4rhae21zobrist__update__cell (param $_M0L6lo__inS51 i32) (param $_M0L6hi__inS52 i32) (param $_M0L3rowS46 i32) (param $_M0L3colS47 i32) (param $_M0L10old__colorS48 i32) (param $_M0L10new__colorS50 i32) (result i32)
 (local $_M0L6i__oldS45 i32)
 (local $_M0L6i__newS49 i32)
 (local $_M0L6_2atmpS436 i32)
 (local $_M0L6_2atmpS437 i32)
 (local $_M0L6_2atmpS438 i32)
 (local $_M0L6_2atmpS439 i32)
 (local $_M0L6_2atmpS440 i32)
 (local $_M0L6_2atmpS441 i32)
 (local $_M0L6_2atmpS442 i32)
 (local $_M0L6_2atmpS443 i32)
 (local $_M0L3ptrS984 i32)
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
 (local.set $_M0L6_2atmpS443)
 (i32.xor
  (local.get $_M0L6lo__inS51)
  (local.get $_M0L6_2atmpS443))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 23 ;)
 (local.set $_M0L6_2atmpS441)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 26 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)
  (local.get $_M0L6i__newS49))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 38 ;)
 (local.set $_M0L6_2atmpS442)
 (i32.xor
  (local.get $_M0L6_2atmpS441)
  (local.get $_M0L6_2atmpS442))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 69 38 ;)
 (local.set $_M0L6_2atmpS436)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 3 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 11 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)
  (local.get $_M0L6i__oldS45))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 23 ;)
 (local.set $_M0L6_2atmpS440)
 (i32.xor
  (local.get $_M0L6hi__inS52)
  (local.get $_M0L6_2atmpS440))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 23 ;)
 (local.set $_M0L6_2atmpS438)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 26 ;)
 (call $_M0MPC15array5Array2atGiE
  (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)
  (local.get $_M0L6i__newS49))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 38 ;)
 (local.set $_M0L6_2atmpS439)
 (i32.xor
  (local.get $_M0L6_2atmpS438)
  (local.get $_M0L6_2atmpS439))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 38 ;)
 (local.set $_M0L6_2atmpS437)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS984
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS984)
  (local.get $_M0L6_2atmpS437))
 (i32.store
  (local.get $_M0L3ptrS984)
  (local.get $_M0L6_2atmpS436))
 (local.get $_M0L3ptrS984)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 39 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 39 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 70 39 ;))
(func $_M0FP48moonarc34rhae3src4rhae19zobrist__hash__grid (param $_M0L4gridS42 i32) (param $_M0L1hS38 i32) (param $_M0L1wS40 i32) (result i32)
 (local $_M0L2loS35 i32)
 (local $_M0L2hiS36 i32)
 (local $_M0L1rS37 i32)
 (local $_M0L1cS39 i32)
 (local $_M0L3idxS41 i32)
 (local $_M0L3valS415 i32)
 (local $_M0L3valS416 i32)
 (local $_M0L6_2atmpS417 i32)
 (local $_M0L3valS418 i32)
 (local $_M0L6_2atmpS419 i32)
 (local $_M0L6_2atmpS420 i32)
 (local $_M0L3valS421 i32)
 (local $_M0L6_2atmpS422 i32)
 (local $_M0L6_2atmpS423 i32)
 (local $_M0L3valS424 i32)
 (local $_M0L3valS425 i32)
 (local $_M0L3valS426 i32)
 (local $_M0L6_2atmpS427 i32)
 (local $_M0L6_2atmpS428 i32)
 (local $_M0L6_2atmpS429 i32)
 (local $_M0L3valS430 i32)
 (local $_M0L3valS431 i32)
 (local $_M0L6_2atmpS432 i32)
 (local $_M0L3valS433 i32)
 (local $_M0L3valS434 i32)
 (local $_M0L3valS435 i32)
 (local $_M0L3ptrS985 i32)
 (local $_M0L3ptrS986 i32)
 (local $_M0L3ptrS987 i32)
 (local $_M0L3ptrS988 i32)
 (local $_M0L3ptrS989 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 46 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae13zobrist__init)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 46 16 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 47 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS989
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS989)
  (i32.const 0))
 (local.set $_M0L2loS35
  (local.get $_M0L3ptrS989))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 47 18 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS988
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS988)
  (i32.const 0))
 (local.set $_M0L2hiS36
  (local.get $_M0L3ptrS988))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 48 2 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS987
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS987)
  (i32.const 0))
 (local.set $_M0L1rS37
  (local.get $_M0L3ptrS987))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 49 2 ;)
 (loop $loop:44
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 49 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS415
    (i32.load
     (local.get $_M0L1rS37)))
   (local.get $_M0L1hS38))
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 49 13 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 50 4 ;)
    (call $moonbit.store_object_meta
     (local.tee $_M0L3ptrS986
      (call $moonbit.gc.malloc
       (i32.const 4)))
     (i32.const 524288))
    (i32.store
     (local.get $_M0L3ptrS986)
     (i32.const 0))
    (local.set $_M0L1cS39
     (local.get $_M0L3ptrS986))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 51 4 ;)
    (loop $loop:43
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 51 10 ;)
     (i32.lt_s
      (local.tee $_M0L3valS416
       (i32.load
        (local.get $_M0L1cS39)))
      (local.get $_M0L1wS40))
     (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 51 15 ;)
     (if
      (then
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 6 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 16 ;)
       (local.set $_M0L3valS425
        (i32.load
         (local.get $_M0L1rS37)))
       (local.set $_M0L3valS426
        (i32.load
         (local.get $_M0L1cS39)))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 29 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 34 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 34 ;)
       (i32.mul
        (local.tee $_M0L3valS431
         (i32.load
          (local.get $_M0L1rS37)))
        (local.get $_M0L1wS40))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 39 ;)
       (local.set $_M0L6_2atmpS429)
       (local.set $_M0L3valS430
        (i32.load
         (local.get $_M0L1cS39)))
       (i32.add
        (local.get $_M0L6_2atmpS429)
        (local.get $_M0L3valS430))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 43 ;)
       (local.set $_M0L6_2atmpS428)
       (call $_M0MPC15array5Array2atGiE
        (local.get $_M0L4gridS42)
        (local.get $_M0L6_2atmpS428))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 44 ;)
       (local.set $_M0L6_2atmpS427)
       (call $_M0FP48moonarc34rhae3src4rhae7zt__idx
        (local.get $_M0L3valS425)
        (local.get $_M0L3valS426)
        (local.get $_M0L6_2atmpS427))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 52 45 ;)
       (local.set $_M0L3idxS41)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 6 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 11 ;)
       (local.set $_M0L3valS418
        (i32.load
         (local.get $_M0L2loS35)))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 16 ;)
       (call $_M0MPC15array5Array2atGiE
        (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)
        (local.get $_M0L3idxS41))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 26 ;)
       (local.set $_M0L6_2atmpS419)
       (i32.xor
        (local.get $_M0L3valS418)
        (local.get $_M0L6_2atmpS419))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 26 ;)
       (local.set $_M0L6_2atmpS417)
       (i32.store
        (local.get $_M0L2loS35)
        (local.get $_M0L6_2atmpS417))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 26 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 28 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 33 ;)
       (local.set $_M0L3valS421
        (i32.load
         (local.get $_M0L2hiS36)))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 38 ;)
       (call $_M0MPC15array5Array2atGiE
        (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)
        (local.get $_M0L3idxS41))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 48 ;)
       (local.set $_M0L6_2atmpS422)
       (i32.xor
        (local.get $_M0L3valS421)
        (local.get $_M0L6_2atmpS422))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 48 ;)
       (local.set $_M0L6_2atmpS420)
       (i32.store
        (local.get $_M0L2hiS36)
        (local.get $_M0L6_2atmpS420))
       (i32.const 0)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 53 48 ;)
       (drop)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 54 6 ;)
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 54 10 ;)
       (i32.add
        (local.tee $_M0L3valS424
         (i32.load
          (local.get $_M0L1cS39)))
        (i32.const 1))
       (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 54 15 ;)
       (local.set $_M0L6_2atmpS423)
       (i32.store
        (local.get $_M0L1cS39)
        (local.get $_M0L6_2atmpS423))
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
     (local.tee $_M0L3valS433
      (i32.load
       (local.get $_M0L1rS37)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 56 13 ;)
    (local.set $_M0L6_2atmpS432)
    (i32.store
     (local.get $_M0L1rS37)
     (local.get $_M0L6_2atmpS432))
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
 (local.set $_M0L3valS434)
 (i32.load
  (local.get $_M0L2hiS36))
 (call $moonbit.decref
  (local.get $_M0L2hiS36))
 (local.set $_M0L3valS435)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS985
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 1048576))
 (i32.store offset=4
  (local.get $_M0L3ptrS985)
  (local.get $_M0L3valS435))
 (i32.store
  (local.get $_M0L3ptrS985)
  (local.get $_M0L3valS434))
 (local.get $_M0L3ptrS985)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 58 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 58 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 58 10 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 58 10 ;))
(func $_M0FP48moonarc34rhae3src4rhae7zt__idx (param $_M0L3rowS30 i32) (param $_M0L3colS32 i32) (param $_M0L5colorS34 i32) (result i32)
 (local $_M0L1rS29 i32)
 (local $_M0L1cS31 i32)
 (local $_M0L1kS33 i32)
 (local $_M0L6_2atmpS412 i32)
 (local $_M0L6_2atmpS413 i32)
 (local $_M0L6_2atmpS414 i32)
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
 (local.tee $_M0L6_2atmpS414)
 (local.get $_M0L1cS31)
 (i32.add)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 18 ;)
 (local.tee $_M0L6_2atmpS413)
 (global.get $_M0FP48moonarc34rhae3src4rhae10zb__colors)
 (i32.mul)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 31 ;)
 (local.tee $_M0L6_2atmpS412)
 (local.get $_M0L1kS33)
 (i32.add)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 35 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 35 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 35 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 42 35 ;))
(func $_M0FP48moonarc34rhae3src4rhae13zobrist__init (result i32)
 (local $_M0L1iS27 i32)
 (local $_M0L3valS399 i32)
 (local $_M0L3valS400 i32)
 (local $_M0L6_2atmpS401 i32)
 (local $_M0L6_2atmpS402 i32)
 (local $_M0L6_2atmpS403 i32)
 (local $_M0L3valS404 i32)
 (local $_M0L3valS405 i32)
 (local $_M0L6_2atmpS406 i32)
 (local $_M0L6_2atmpS407 i32)
 (local $_M0L6_2atmpS408 i32)
 (local $_M0L3valS409 i32)
 (local $_M0L6_2atmpS410 i32)
 (local $_M0L3valS411 i32)
 (local $_M0L3ptrS990 i32)
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
  (local.tee $_M0L3ptrS990
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS990)
  (i32.const 0))
 (local.set $_M0L1iS27
  (local.get $_M0L3ptrS990))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 30 2 ;)
 (loop $loop:28
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 30 8 ;)
  (i32.lt_s
   (local.tee $_M0L3valS399
    (i32.load
     (local.get $_M0L1iS27)))
   (global.get $_M0FP48moonarc34rhae3src4rhae8zb__size))
  (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 30 19 ;)
  (if
   (then
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 4 ;)
    (local.set $_M0L3valS400
     (i32.load
      (local.get $_M0L1iS27)))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 15 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 27 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 27 ;)
    (i32.mul
     (local.tee $_M0L3valS404
      (i32.load
       (local.get $_M0L1iS27)))
     (i32.const 1234567))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 38 ;)
    (local.tee $_M0L6_2atmpS403)
    (i32.const 42)
    (i32.add)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 43 ;)
    (local.tee $_M0L6_2atmpS402)
    (call $_M0FP48moonarc34rhae3src4rhae12splitmix__lo)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 44 ;)
    (local.set $_M0L6_2atmpS401)
    (call $_M0MPC15array5Array3setGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae6zt__lo)
     (local.get $_M0L3valS400)
     (local.get $_M0L6_2atmpS401))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 31 44 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 4 ;)
    (local.set $_M0L3valS405
     (i32.load
      (local.get $_M0L1iS27)))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 15 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 27 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 27 ;)
    (i32.mul
     (local.tee $_M0L3valS409
      (i32.load
       (local.get $_M0L1iS27)))
     (i32.const 7654321))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 38 ;)
    (local.tee $_M0L6_2atmpS408)
    (i32.const 137)
    (i32.add)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 44 ;)
    (local.tee $_M0L6_2atmpS407)
    (call $_M0FP48moonarc34rhae3src4rhae12splitmix__hi)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 45 ;)
    (local.set $_M0L6_2atmpS406)
    (call $_M0MPC15array5Array3setGiE
     (global.get $_M0FP48moonarc34rhae3src4rhae6zt__hi)
     (local.get $_M0L3valS405)
     (local.get $_M0L6_2atmpS406))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 32 45 ;)
    (drop)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 33 4 ;)
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 33 8 ;)
    (i32.add
     (local.tee $_M0L3valS411
      (i32.load
       (local.get $_M0L1iS27)))
     (i32.const 1))
    (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 33 13 ;)
    (local.set $_M0L6_2atmpS410)
    (i32.store
     (local.get $_M0L1iS27)
     (local.get $_M0L6_2atmpS410))
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
 (local $_M0L6_2atmpS394 i32)
 (local $_M0L6_2atmpS395 i32)
 (local $_M0L6_2atmpS396 i32)
 (local $_M0L6_2atmpS397 i32)
 (local $_M0L6_2atmpS398 i32)
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
 (local.set $_M0L6_2atmpS398)
 (i32.xor
  (local.get $_M0L1zS23)
  (local.get $_M0L6_2atmpS398))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 22 24 ;)
 (local.tee $_M0L6_2atmpS397)
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
 (local.set $_M0L6_2atmpS396)
 (i32.xor
  (local.get $_M0L1zS25)
  (local.get $_M0L6_2atmpS396))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 23 24 ;)
 (local.tee $_M0L6_2atmpS395)
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
 (local.set $_M0L6_2atmpS394)
 (i32.xor
  (local.get $_M0L1zS26)
  (local.get $_M0L6_2atmpS394))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 24 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 24 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 24 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 24 15 ;))
(func $_M0FP48moonarc34rhae3src4rhae12splitmix__lo (param $_M0L1sS20 i32) (result i32)
 (local $_M0L1zS19 i32)
 (local $_M0L1zS21 i32)
 (local $_M0L1zS22 i32)
 (local $_M0L6_2atmpS389 i32)
 (local $_M0L6_2atmpS390 i32)
 (local $_M0L6_2atmpS391 i32)
 (local $_M0L6_2atmpS392 i32)
 (local $_M0L6_2atmpS393 i32)
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
 (local.set $_M0L6_2atmpS393)
 (i32.xor
  (local.get $_M0L1zS19)
  (local.get $_M0L6_2atmpS393))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 16 24 ;)
 (local.tee $_M0L6_2atmpS392)
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
 (local.set $_M0L6_2atmpS391)
 (i32.xor
  (local.get $_M0L1zS21)
  (local.get $_M0L6_2atmpS391))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 17 24 ;)
 (local.tee $_M0L6_2atmpS390)
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
 (local.set $_M0L6_2atmpS389)
 (i32.xor
  (local.get $_M0L1zS22)
  (local.get $_M0L6_2atmpS389))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 18 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 18 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 18 15 ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 18 15 ;))
(func $_M0MPC15array5Array2atGiE (param $_M0L4selfS14 i32) (param $_M0L5indexS15 i32) (result i32)
 (local $_M0L3lenS13 i32)
 (local $_M0L6_2atmpS387 i32)
 (local $_M0L6_2aarrS991 i32)
 (local $_M0L6_2aidxS992 i32)
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
   (local.tee $_M0L6_2atmpS387)
   (local.set $_M0L6_2aidxS992
    (local.get $_M0L5indexS15))
   (local.set $_M0L6_2aarrS991)
   (call $moonbit.check_range
    (local.get $_M0L6_2aidxS992)
    (i32.const 0)
    (i32.sub
     (call $moonbit.array_length
      (local.get $_M0L6_2aarrS991))
     (i32.const 1)))
   (i32.load
    (i32.add
     (local.get $_M0L6_2aarrS991)
     (i32.shl
      (local.get $_M0L6_2aidxS992)
      (i32.const 2))))
   (call $moonbit.decref
    (local.get $_M0L6_2atmpS387))
   (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;))
  (else
   (; source_pos moonbitlang/core/builtin array.mbt 187 2 ;)
   (unreachable)))
 (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;))
(func $_M0MPC15array5Array2atGUiiEE (param $_M0L4selfS17 i32) (param $_M0L5indexS18 i32) (result i32)
 (local $_M0L3lenS16 i32)
 (local $_M0L6_2atmpS388 i32)
 (local $_M0L6_2atmpS872 i32)
 (local $_M0L6_2aarrS993 i32)
 (local $_M0L6_2aidxS994 i32)
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
   (local.tee $_M0L6_2atmpS388)
   (local.set $_M0L6_2aidxS994
    (local.get $_M0L5indexS18))
   (local.set $_M0L6_2aarrS993)
   (call $moonbit.check_range
    (local.get $_M0L6_2aidxS994)
    (i32.const 0)
    (i32.sub
     (call $moonbit.array_length
      (local.get $_M0L6_2aarrS993))
     (i32.const 1)))
   (if
    (local.tee $_M0L6_2atmpS872
     (i32.load
      (i32.add
       (local.get $_M0L6_2aarrS993)
       (i32.shl
        (local.get $_M0L6_2aidxS994)
        (i32.const 2)))))
    (then
     (call $moonbit.incref
      (local.get $_M0L6_2atmpS872)))
    (else))
   (call $moonbit.decref
    (local.get $_M0L6_2atmpS388))
   (local.get $_M0L6_2atmpS872)
   (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;))
  (else
   (; source_pos moonbitlang/core/builtin array.mbt 187 2 ;)
   (unreachable)))
 (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;)
 (; source_pos moonbitlang/core/builtin array.mbt 188 22 ;))
(func $_M0MPC15array5Array3setGiE (param $_M0L4selfS10 i32) (param $_M0L5indexS11 i32) (param $_M0L5valueS12 i32) (result i32)
 (local $_M0L3lenS9 i32)
 (local $_M0L6_2atmpS386 i32)
 (local $_M0L6_2aarrS995 i32)
 (local $_M0L6_2aidxS996 i32)
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
   (local.tee $_M0L6_2atmpS386)
   (local.set $_M0L6_2aidxS996
    (local.get $_M0L5indexS11))
   (local.set $_M0L6_2aarrS995)
   (call $moonbit.check_range
    (local.get $_M0L6_2aidxS996)
    (i32.const 0)
    (i32.sub
     (call $moonbit.array_length
      (local.get $_M0L6_2aarrS995))
     (i32.const 1)))
   (i32.store
    (i32.add
     (local.get $_M0L6_2aarrS995)
     (i32.shl
      (local.get $_M0L6_2aidxS996)
      (i32.const 2)))
    (local.get $_M0L5valueS12))
   (call $moonbit.decref
    (local.get $_M0L6_2atmpS386))
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
 (local $_M0L3bufS384 i32)
 (local $_M0L6_2atmpS385 i32)
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
      (local.tee $_M0L3bufS384
       (i32.load offset=4
        (local.get $_M0L3arrS4)))
      (i32.shl
       (local.get $_M0L1iS6)
       (i32.const 2)))
     (local.get $_M0L4elemS7))
    (local.tee $_M0L6_2atmpS385
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
 (local $_M0L8_2afieldS874 i32)
 (; prologue_end ;)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 125 2 ;)
 (call $moonbit.incref
  (local.tee $_M0L8_2afieldS874
   (i32.load offset=4
    (local.get $_M0L4selfS2))))
 (local.get $_M0L8_2afieldS874)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 125 10 ;))
(func $_M0MPC15array5Array6bufferGUiiEE (param $_M0L4selfS3 i32) (result i32)
 (local $_M0L8_2afieldS875 i32)
 (; prologue_end ;)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 125 2 ;)
 (call $moonbit.incref
  (local.tee $_M0L8_2afieldS875
   (i32.load offset=4
    (local.get $_M0L4selfS3))))
 (local.get $_M0L8_2afieldS875)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 125 10 ;))
(func $_M0MPC15array5Array12make__uninitGiE (param $_M0L3lenS1 i32) (result i32)
 (local $_M0L6_2atmpS383 i32)
 (local $_M0L3ptrS997 i32)
 (; prologue_end ;)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 28 2 ;)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 28 9 ;)
 (call $moonbit.i32_array_make_raw
  (local.get $_M0L3lenS1))
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 28 38 ;)
 (local.set $_M0L6_2atmpS383)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS997
   (call $moonbit.gc.malloc
    (i32.const 8)))
  (i32.const 524544))
 (i32.store
  (local.get $_M0L3ptrS997)
  (local.get $_M0L3lenS1))
 (i32.store offset=4
  (local.get $_M0L3ptrS997)
  (local.get $_M0L6_2atmpS383))
 (local.get $_M0L3ptrS997)
 (; source_pos moonbitlang/core/builtin arraycore_nonjs.mbt 28 45 ;))
(start $_M0FP017____moonbit__init)
(func $_M0FP017____moonbit__init
 (local $_M0L3ptrS998 i32)
 (local $_M0L3ptrS999 i32)
 (; prologue_end ;)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 12 28 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS999
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS999)
  (i32.const 0))
 (local.get $_M0L3ptrS999)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 12 42 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae8zt__init)
 (; source_pos moonarc3/rhae/src/rhae types.mbt 25 33 ;)
 (call $moonbit.store_object_meta
  (local.tee $_M0L3ptrS998
   (call $moonbit.gc.malloc
    (i32.const 4)))
  (i32.const 524288))
 (i32.store
  (local.get $_M0L3ptrS998)
  (i32.const 0))
 (local.get $_M0L3ptrS998)
 (; source_pos moonarc3/rhae/src/rhae types.mbt 25 43 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae8hash__hi)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 114 32 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 4096)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 114 52 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae14tt__store__arr)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 11 28 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 16384)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 11 49 ;)
 (global.set $_M0FP48moonarc34rhae3src4rhae6zt__hi)
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 10 28 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 16384)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/rhae zobrist.mbt 10 49 ;)
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
 (local $_M0L11dummy__gridS376 i32)
 (local $_M0L10dummy__outS377 i32)
 (local $_M0L10dummy__invS378 i32)
 (local $_M0L10dummy__visS379 i32)
 (local $_M0L10dummy__matS380 i32)
 (local $_M0L9dummy__tkS381 i32)
 (local $_M0L8dummy__pS382 i32)
 (local $_M0L6_2atmpS876 i32)
 (local $_M0L6_2atmpS877 i32)
 (local $_M0L6_2atmpS878 i32)
 (local $_M0L6_2atmpS879 i32)
 (local $_M0L6_2atmpS880 i32)
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
 (local.set $_M0L11dummy__gridS376)
 (; source_pos moonarc3/rhae/src/main main.mbt 25 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 25 19 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 64)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 25 37 ;)
 (local.set $_M0L10dummy__outS377)
 (; source_pos moonarc3/rhae/src/main main.mbt 26 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 26 19 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 10)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 26 37 ;)
 (local.set $_M0L10dummy__invS378)
 (; source_pos moonarc3/rhae/src/main main.mbt 27 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 27 19 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 7)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 27 37 ;)
 (local.set $_M0L10dummy__visS379)
 (; source_pos moonarc3/rhae/src/main main.mbt 28 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 28 19 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 91)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 28 37 ;)
 (local.set $_M0L10dummy__matS380)
 (; source_pos moonarc3/rhae/src/main main.mbt 29 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 29 19 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 6)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 29 37 ;)
 (local.set $_M0L9dummy__tkS381)
 (; source_pos moonarc3/rhae/src/main main.mbt 65536 65535 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 30 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae18canonicalize__grid
  (local.get $_M0L11dummy__gridS376)
  (i32.const 8)
  (i32.const 8)
  (local.get $_M0L10dummy__outS377))
 (; source_pos moonarc3/rhae/src/main main.mbt 30 62 ;)
 (local.tee $_M0L6_2atmpS880)
 (call $moonbit.decref)
 (; source_pos moonarc3/rhae/src/main main.mbt 31 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae17normalize__colors
  (local.get $_M0L11dummy__gridS376)
  (i32.const 64)
  (local.get $_M0L10dummy__outS377))
 (call $moonbit.decref
  (local.get $_M0L10dummy__outS377))
 (; source_pos moonarc3/rhae/src/main main.mbt 31 59 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 32 2 ;)
 (call $_M0FP48moonarc34rhae3src4rhae19compute__invariants
  (local.get $_M0L11dummy__gridS376)
  (local.get $_M0L11dummy__gridS376)
  (i32.const 8)
  (i32.const 8)
  (local.get $_M0L10dummy__invS378))
 (; source_pos moonarc3/rhae/src/main main.mbt 32 67 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 33 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae19zobrist__hash__grid
  (local.get $_M0L11dummy__gridS376)
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 33 51 ;)
 (local.tee $_M0L6_2atmpS879)
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
 (local.tee $_M0L6_2atmpS878)
 (call $moonbit.decref)
 (; source_pos moonarc3/rhae/src/main main.mbt 35 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae15canonical__hash
  (local.get $_M0L11dummy__gridS376)
  (i32.const 8)
  (i32.const 8))
 (; source_pos moonarc3/rhae/src/main main.mbt 35 48 ;)
 (local.tee $_M0L6_2atmpS877)
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
 (local.tee $_M0L6_2atmpS876)
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
  (local.get $_M0L10dummy__invS378)
  (local.get $_M0L11dummy__gridS376)
  (i32.const 8)
  (i32.const 8)
  (local.get $_M0L10dummy__visS379)
  (i32.const 7))
 (call $moonbit.decref
  (local.get $_M0L11dummy__gridS376))
 (; source_pos moonarc3/rhae/src/main main.mbt 41 76 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 42 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae22build__candidate__rows
  (i32.const 127)
  (local.get $_M0L10dummy__invS378)
  (local.get $_M0L10dummy__visS379)
  (i32.const 0)
  (i32.const 0)
  (i32.const 0)
  (local.get $_M0L10dummy__matS380)
  (i32.const 7))
 (call $moonbit.decref
  (local.get $_M0L10dummy__invS378))
 (call $moonbit.decref
  (local.get $_M0L10dummy__visS379))
 (call $moonbit.decref
  (local.get $_M0L10dummy__matS380))
 (; source_pos moonarc3/rhae/src/main main.mbt 42 87 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 43 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 43 16 ;)
 (call $_M0MPC15array5Array4makeGiE
  (i32.const 14)
  (i32.const 0))
 (; source_pos moonarc3/rhae/src/main main.mbt 43 34 ;)
 (local.set $_M0L8dummy__pS382)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 2 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 10 ;)
 (call $_M0FP48moonarc34rhae3src4rhae16topk__candidates
  (local.get $_M0L8dummy__pS382)
  (i32.const 7)
  (i32.const 6)
  (local.get $_M0L9dummy__tkS381))
 (call $moonbit.decref
  (local.get $_M0L8dummy__pS382))
 (call $moonbit.decref
  (local.get $_M0L9dummy__tkS381))
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (drop)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 2 ;)
 (i32.const 0)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (; source_pos moonarc3/rhae/src/main main.mbt 44 56 ;)
 (drop))
(export "_start" (func $_M0FP017____moonbit__main))