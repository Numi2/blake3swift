# M6 mapped-file Metal probe

## Result

The end-to-end Metal mapped-file route was substantially slower than hashing the same 1 GiB input from memory on the M6. Six iterations measured a **1.94 GiB/s median** for `metal-file | metal-mmap-gpu` (minimum 0.88, maximum/P95 6.67 GiB/s); the M6 in-memory parallel CPU path measured 17.25 GiB/s in the same benchmark invocation. All rows, including the mapped-file digest, matched the reference.

This is a negative result, not a performance improvement. The measurement includes file open/stat, `mmap`, the no-copy Metal buffer wrapper, GPU hashing and wait, digest read, `munmap`, and close. It excludes creation of the benchmark file. The wide spread suggests this file-backed route is sensitive to effects outside the hash kernel; it should not be treated as a stable kernel-throughput measurement.

No thermal or performance warning was recorded before or after the run. The benchmark command was:

```sh
swift build -c release --product blake3-bench
./.build/release/blake3-bench --sizes 1g --iterations 6 \
  --metal-modes none --file-modes metal-mmap --file-operation-modes none \
  --cryptokit-modes none --json-output /tmp/m6-file-mmap.json
```

## Source and raw evidence

The benchmark ran on Apple M6, with these source SHA-256 hashes:

| File | SHA-256 |
| --- | --- |
| `Sources/Blake3/BLAKE3Metal.swift` | `a12df53d7e9701f97d626877816e9993da41717926fcb73b6d433240fc8c2915` |
| `Sources/Blake3/BLAKE3File.swift` | `56c9bd588f0ccfb10ebc3b307251788f13b0b155491fb41a18f07fd90797cba9` |
| `Sources/Blake3Benchmark/main.swift` | `47f760adb5caa53883271639377c6381970fe12c6e415f068d8e3f0f1ca78e` |

The raw Markdown report, JSON rows, and before/after system snapshots are preserved alongside this note as `m6-file-mmap.md`, `m6-file-mmap.json`, `m6-file-mmap-before.txt`, and `m6-file-mmap-after.txt`.

## Apple API constraint

Apple documents that a `bytesNoCopy` input must be page-aligned, cover a page-aligned length, and lie within one virtual-memory region. This file mapping uses the supported file-backed allocation, but its end-to-end result shows that eliminating the user-space copy alone does not improve the complete hash operation on this setup. See [Metal's no-copy buffer initializer](https://developer.apple.com/documentation/metal/mtldevice/makebuffer%28bytesnocopy%3Alength%3Aoptions%3Adeallocator%3A%29).
