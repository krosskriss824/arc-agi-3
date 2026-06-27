"""Patch rhae_stage1.wat for 64x64 Zobrist table."""
lines = open('rhae_stage1.wat', 'r').readlines()
changes = {
    7647: ('i32.const 32', 'i32.const 64'),
    7651: ('i32.const 31', 'i32.const 63'),
    7656: ('i32.const 32', 'i32.const 64'),
    7660: ('i32.const 31', 'i32.const 63'),
    7678: ('i32.const 32', 'i32.const 64'),
    7714: ('i32.const 16384', 'i32.const 65536'),
    7960: ('i32.const 16384', 'i32.const 65536'),
    7964: ('i32.const 16384', 'i32.const 65536'),
}
for ln, (old, new) in changes.items():
    idx = ln - 1
    if old not in lines[idx]:
        found = False
        for offset in range(-3, 4):
            check = idx + offset
            if 0 <= check < len(lines) and old in lines[check]:
                print('Line %d shifted %d: found at line %d' % (ln, offset, check + 1))
                idx = check
                found = True
                break
        if not found:
            print('MISS on L%d: expected "%s", got "%s"' % (ln, old, lines[idx].strip()))
            continue
    lines[idx] = lines[idx].replace(old, new, 1)
    print('L%d: OK %s -> %s' % (idx + 1, old, new))
open('rhae_stage1_64x64.wat', 'w').writelines(lines)
print('Written: rhae_stage1_64x64.wat')
