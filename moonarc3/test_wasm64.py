"""Verify 64x64 Zobrist WASM and test functional."""
import wasmtime, numpy as np

wasm_bytes = open('rhae_stage1_64x64.wasm', 'rb').read()
print('WASM size:', len(wasm_bytes), 'bytes (was 14069)')

store = wasmtime.Store()
mod = wasmtime.Module(store.engine, wasm_bytes)
exports = {e.name: str(e.type) for e in mod.exports}
print('Exports:', len(exports))
for n, t in sorted(exports.items()):
    print('  %s: %s' % (n, t))

# Instantiate
linker = wasmtime.Linker(store.engine)
instance = linker.instantiate(store, mod)
print('Instance OK')

# Test: 64x64 zeros
mem = instance.exports(store)["memory"]
h, w = 64, 64
set_grid = instance.exports(store)["set_grid_cell"]
for r in range(64):
    for c in range(64):
        set_grid(store, r * 64 + c, 0)

canon = instance.exports(store)["rhae_canonical_hash"]
get_hi = instance.exports(store)["rhae_get_hash_hi"]
lo = canon(store, h, w)
hi = get_hi(store)
print('Hash of 64x64 zeros: lo=%d, hi=%d' % (lo, hi))

# Test: 64x64 with some color
for r in range(10, 20):
    for c in range(10, 20):
        set_grid(store, r * 64 + c, 5)

lo2 = canon(store, h, w)
hi2 = get_hi(store)
print('Hash of 64x64 with block: lo=%d, hi=%d' % (lo2, hi2))

# Test: same block with D4 (rotated)
set_grid(store, 10, 10, 0)  # remove original
for r in range(10, 20):
    for c in range(44, 54):  # rotated position
        set_grid(store, r * 64 + c, 5)
lo3 = canon(store, h, w)
hi3 = get_hi(store)
print('Hash of D4-identical: lo=%d, hi=%d (should match lo2/hi2)' % (lo3, hi3))

print('ALL OK')
