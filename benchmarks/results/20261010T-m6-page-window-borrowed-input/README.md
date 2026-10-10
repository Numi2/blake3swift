# Borrowed Swift input page-window attempt

This experiment was intended to expose an aligned page window around the existing Swift array, then use `MTLDevice.makeBuffer(bytesNoCopy:length:options:deallocator:)` without copying the entire input.

Apple documents three requirements for this API: the pointer must be page-aligned, the length must produce a page-aligned region, and the existing allocation must lie within one virtual-memory region. On this M6, tested Swift byte-array pointers were 32 bytes past a 16 KiB page boundary. For the 1 GiB array, the `vm_region_64` query at the rounded-down page began a region of 128 MiB, which did not cover the input span. The benchmark's guard therefore stopped before hashing:

```text
Fatal error: Unable to wrap the page-aligned input VM span in a Metal buffer.
```

`page-window/metal-wrapped-r1.md` is a failed feasibility attempt, not a throughput measurement. `normal/metal-wrapped-r1.md` records 67.25 GiB/s for the old direct wrapper and correct digests, but that path used an unaligned Swift pointer and did not satisfy Apple's documented contract. Treat it as preserved legacy evidence only; it is not a valid optimization baseline.

The safe alternative and current accepted results are recorded in [the M6 safe-input-path report](../20261010T-m6-safe-input-paths/README.md).
