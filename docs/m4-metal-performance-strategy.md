# M4 and Metal Performance Strategy

This document is the M4-first addendum to the general BLAKE3 roadmap. The goal
is to build the fastest BLAKE3 implementation usable from Swift on this
MacBook M4, not merely a clean Swift port.

The target machine observed locally:

- Model: MacBook Air, Apple M4.
- CPU: 10 cores, 4 performance and 6 efficiency.
- GPU: Apple M4, 10 cores.
- Memory: 24 GB unified memory.
- Metal: Metal 4.
- Metal device reports unified memory.
- A trivial compute pipeline reports `threadExecutionWidth = 32` and
  `maxTotalThreadsPerThreadgroup = 1024`.
- Apple documents base M4 MacBook Pro memory bandwidth at 120 GB/s. This
  MacBook Air is the same base M4 class, so this is the relevant bandwidth
  order of magnitude, not the 273 GB/s M4 Pro or 546 GB/s M4 Max class.

## Local Baseline

I built upstream BLAKE3 `1.8.4` locally and ran a quick, non-rigorous baseline
against a 512 MiB file:

```text
upstream b3sum, default mmap + parallel, warm cache:
  real 0.05s, user 0.35s
  approximate wall throughput: about 10 GiB/s

upstream b3sum --num-threads 1:
  real 0.30s
  approximate wall throughput: about 1.7 GiB/s

upstream b3sum --no-mmap:
  real 0.28s
  approximate wall throughput: about 1.8 GiB/s
```

These are not release-grade numbers, because `/usr/bin/time` resolution and
thermal state are not enough. They are still useful for strategy: the Metal
backend must beat a roughly 10 GiB/s CPU-parallel warm-cache baseline on this
machine before it can be the default for ordinary large buffers or files.

## Research Conclusions

### BLAKE3 Shape

BLAKE3 is a good GPU candidate only for large enough inputs. Its 1024-byte
chunks can be compressed independently, and then the chunk chaining values are
reduced with a binary Merkle tree. The leaf phase is embarrassingly parallel.
The parent phase is also parallel per tree level, but it shrinks by half each
level and can become dispatch-overhead dominated.

The core operation is ARX over `UInt32`: wrapping add, XOR, and rotate. That
maps to CPU NEON and GPU integer ALUs. It does not map to the Neural Engine,
MPS matrix paths, or AMX-style matrix acceleration.

### Apple M4 Constraint

Base M4 has excellent CPU cores and a 10-core GPU, but it is not an M4 Max.
Because the CPU-parallel upstream baseline already reaches around 10 GiB/s
wall-clock on cached data, a naive Metal kernel that only beats one CPU core is
not enough.

The GPU path has to win by:

- avoiding host-device copies through unified `.shared` memory;
- keeping command-buffer count low;
- fusing leaf and lower tree reductions where possible;
- avoiding branch divergence inside SIMD groups;
- avoiding register spilling in the compression kernel;
- autotuning threadgroup size and kernel variants on this exact M4.

### Metal Constraint

Metal organizes compute threads into threadgroups and SIMD groups. The pipeline
reports `threadExecutionWidth`; on this M4 it is 32 for a trivial compute
kernel. Threadgroups should be a multiple of that width. This favors 128, 256,
512, and maybe 1024 threads per group as candidates.

The BLAKE3 kernels should be one-dimensional. The data structure is a linear
array of 1024-byte chunks and then linear arrays of 32-byte chaining values.
There is no value in a 2D dispatch shape.

### GPU BLAKE3 Prior Art

SYCL/GPU BLAKE3 experiments show two important things:

- accelerator launch and transfer overhead make small inputs unattractive;
- compressing multiple chunks per work item can increase register pressure and
  spill, especially at 4, 8, and 16 chunks per work item.

On Apple Silicon, unified memory removes the discrete PCIe transfer penalty,
but it does not remove command latency or register pressure. The first Metal
kernel should therefore be one chunk per thread, with two-chunk-per-thread as a
measured experiment, not the starting assumption.

Older CUDA BLAKE3 repos are useful for algorithm sketches, but their reported
throughput is far below the upstream CPU baseline on this M4. They should not
be treated as performance targets.

## Architecture Decision

The fastest implementation will be a hybrid:

```text
Swift public API
  |
  +-- M4 dispatcher and autotuner
        |
        +-- CPU upstream C NEON backend
        +-- CPU Dispatch-parallel tree backend
        +-- Metal large-buffer backend
        +-- Metal MTLBuffer backend
        +-- Metal mmap-file backend
```

The default should not be "always GPU." The default should be fastest measured
path for the input:

- tiny and small inputs: CPU;
- medium inputs: CPU NEON or CPU parallel, depending on threshold;
- large `Data` or raw buffer: autotuned CPU-vs-Metal decision;
- file hashing: mmap, then CPU parallel or Metal depending on autotuned size;
- existing `MTLBuffer`: Metal-first, because the data is already GPU-visible.

Implementation note, April 18, 2026: `BLAKE3.hash` now uses an automatic unkeyed one-shot dispatcher. It chooses CPU-only hashing below `BLAKE3_SWIFT_METAL_MIN_BYTES` and uses the synchronous no-copy Metal wrapper above that threshold when Metal is available, falling back to CPU on failure. `BLAKE3_SWIFT_BACKEND=cpu|metal|auto` controls the default policy at process start.

## Metal API Surface

Add an explicit Metal product rather than hiding it:

```swift
public enum BLAKE3Metal {
    public static var isAvailable: Bool { get }
    public static func hash(buffer: MTLBuffer, length: Int) throws -> BLAKE3.Digest
    public static func hash(buffer: MTLBuffer, range: Range<Int>) throws -> BLAKE3.Digest
    public static func hashFileMapped(path: String) throws -> BLAKE3.Digest
}
```

The default `BLAKE3.hash` can call Metal only after autotuning proves it wins
for normal CPU-originating buffers. Keeping `BLAKE3Metal` explicit makes it
possible to optimize GPU-resident workflows without slowing ordinary callers.

## Metal Kernels

### Kernel 1: Leaf Chunk Compression

```text
kernel blake3_leaf_1chunk(
  input bytes,
  input length,
  chunk counter base,
  key words,
  flags,
  output CVs
)
```

One Metal thread hashes one full 1024-byte chunk and writes one 32-byte chaining
value. Tail handling is not in this first kernel. The CPU handles final partial
chunks until the full GPU path is proven.

Reasons:

- minimal inter-thread communication;
- no tree-shape complexity in the first kernel;
- no root flag risk;
- easiest to validate against upstream C for each chunk.

Candidate threadgroup sizes:

```text
128, 256, 512, 1024
```

Autotune all four.

### Kernel 2: Leaf Chunk Compression, Two Chunks Per Thread

```text
kernel blake3_leaf_2chunk(...)
```

One Metal thread hashes two adjacent chunks with `uint2` state lanes. This may
increase instruction-level work per thread but may also increase register
pressure. Based on GPU prior art, do not implement 4, 8, or 16 chunks per
thread until the one- and two-chunk versions are profiled.

Acceptance rule:

- Keep the two-chunk kernel only if it beats one-chunk across 64 MiB, 256 MiB,
  and 1 GiB on the local M4 without register-spill symptoms.

### Kernel 3: Parent Compression

```text
kernel blake3_parent_level(
  input CVs,
  cv count,
  key words,
  flags,
  output CVs
)
```

One thread hashes one parent node, consuming two 32-byte child chaining values
and writing one 32-byte parent chaining value.

This is correct and simple, but doing one command buffer per tree level creates
too much overhead for medium inputs. It is a reference Metal parent path, not
the final fastest path.

### Kernel 4: Fused Threadgroup Reduction

```text
kernel blake3_leaf_reduce_tile(
  input bytes,
  full chunk count,
  key words,
  flags,
  output tile CVs
)
```

Each threadgroup:

1. hashes one chunk per thread;
2. stores CVs in threadgroup memory;
3. reduces CVs inside the threadgroup while possible;
4. writes one or a small fixed number of CVs per tile to global memory.

This is the first kernel with a realistic chance to beat upstream CPU parallel
for large buffers on base M4. It reduces global CV traffic and collapses many
parent levels without returning to the CPU.

Initial tile candidates:

```text
128 chunks -> 128 KiB input, 4 KiB CV scratch
256 chunks -> 256 KiB input, 8 KiB CV scratch
512 chunks -> 512 KiB input, 16 KiB CV scratch
1024 chunks -> 1 MiB input, 32 KiB CV scratch
```

Autotune tile size. Do not assume 1024 is fastest. It may reduce dispatch count
but hurt occupancy.

Implementation note, April 19, 2026: 128-, 256-, 512-, and 1024-chunk fused tile kernels exist. The default is now `BLAKE3_SWIFT_METAL_FUSED_TILE_CHUNKS=256` for exact full-chunk shared-memory inputs, after fixing an in-place threadgroup reduction race. Set the value to `0` to disable fused tiling, `128` to test the smaller tile, or `512`/`1024` to test larger tiles. Private buffers intentionally keep the prior global-CV reduction path on this M4 because the measured private-resident path was faster without fused tiles.

April 19 follow-up sweep: 128 and 256 chunks were effectively tied for 1 GiB staged/wrapped throughput on the local M4, while 512 and 1024 were weaker in the no-copy wrapped path. Keep 256 as the conservative default because it emits half as many tile roots as 128 without losing measured throughput.

### Kernel 5: Final CV Reduction

```text
kernel blake3_reduce_cvs(...)
```

After tile reduction, reduce the smaller global CV array in repeated passes.
For small final CV counts, CPU reduction may be faster than another Metal
dispatch. The dispatcher should choose:

```text
if remaining CV bytes <= autotuned CPU-finalize threshold:
    copy/read CVs and finalize on CPU
else:
    keep reducing on GPU
```

### Kernel 6: Root XOF

For normal 32-byte digest output, root output can stay on CPU until Metal is
winning everywhere else. For very long XOF output, implement a Metal XOF kernel
that writes many 64-byte output blocks in parallel.

## Correctness Strategy

Do not start by writing a full arbitrary-length GPU hasher. Start with smaller
correct pieces:

1. GPU full-chunk leaf CVs only.
2. CPU compares each GPU leaf CV against upstream C chunk CVs.
3. GPU parent level for power-of-two CV counts.
4. GPU tile reduction for power-of-two chunk counts.
5. CPU tail and root integration.
6. Arbitrary-length GPU path.
7. GPU XOF.

This avoids the highest-risk BLAKE3 mistakes:

- compressing the root too early;
- setting `ROOT` on non-root nodes;
- setting `CHUNK_START` or `CHUNK_END` on parent nodes;
- mishandling final partial chunks;
- mishandling non-power-of-two subtree shapes.

## Unified Memory and Files

For fastest file hashing on M4:

1. `mmap` the file.
2. Wrap the mapped pages in a shared `MTLBuffer` with `makeBuffer(bytesNoCopy:)`
   when Metal permits the pointer and length.
3. If no-copy wrapping is unavailable, use a pooled `.storageModeShared` staging
   buffer and copy in large slabs.
4. Dispatch Metal tile reduction per slab.
5. Merge slab roots with the CPU or a final Metal reduction.

The no-copy path is essential. If file data is copied into a new GPU buffer,
Metal will likely lose to CPU parallel hashing for many file sizes.

## Autotuning

Build an autotuner that runs only in benchmark mode at first. Later, optionally
cache results per machine and OS version.

Parameters:

- CPU single-thread threshold.
- CPU parallel threshold.
- Metal threshold for CPU-originating memory.
- Metal threshold for mmap no-copy memory.
- Metal threshold for existing `MTLBuffer`.
- leaf kernel variant: one chunk or two chunks per thread.
- threadgroup size: 128, 256, 512, 1024.
- fused tile size: 128, 256, 512, 1024 chunks.
- CPU-vs-GPU final reduction threshold.

Cache key:

```text
chip name
GPU name
Metal family support
threadExecutionWidth
maxTotalThreadsPerThreadgroup
macOS build
Swift version
package version
```

The default package should ship conservative thresholds, but the benchmark tool
should produce a tuned config for this exact MacBook M4.

## Benchmark Design

The benchmark suite must report end-to-end time, not just kernel time.

Backends:

- upstream `b3sum`, default;
- upstream `b3sum --num-threads 1`;
- Swift CPU C NEON;
- Swift CPU Dispatch parallel;
- Swift Metal leaf-only plus CPU reduction;
- Swift Metal parent-level reduction;
- Swift Metal fused tile reduction;
- Swift Metal no-copy mmap file path;
- Swift Metal existing `MTLBuffer` path.

Sizes:

```text
0, 1, 64, 1024, 16 KiB, 64 KiB,
1 MiB, 8 MiB, 16 MiB, 64 MiB,
256 MiB, 512 MiB, 1 GiB, 4 GiB
```

Metrics:

- wall time;
- CPU user time;
- GPU elapsed time from command-buffer timestamps where available;
- GiB/s;
- command-buffer count;
- kernel dispatch count;
- allocations;
- peak RSS;
- thermals or repeated-run degradation;
- selected backend.

Profiling tools:

- Xcode GPU capture for correctness and occupancy symptoms.
- Metal System Trace for command-buffer gaps and CPU/GPU overlap.
- Metal counters where available.
- Instruments allocation and time profiler for Swift overhead.

## Performance Targets

Targets for this M4 machine:

1. CPU C NEON backend matches upstream single-thread within 5 percent.
2. CPU parallel backend matches upstream `b3sum` default within 10 percent.
3. Metal existing-`MTLBuffer` path beats upstream `b3sum` default by at least
   25 percent for 256 MiB and larger.
4. Metal mmap no-copy path beats upstream `b3sum` default for warm files at
   512 MiB and larger.
5. Metal CPU-originating `Data` path is only selected by default if it beats CPU
   parallel end-to-end after input staging costs.

If target 3 fails, Metal is still useful for GPU-resident workloads, but it
must not become the default for normal Swift buffers.

## Implementation Phases

### Phase M0: Measurement Harness

- Add benchmark package before optimization.
- Record local M4 hardware and Metal pipeline facts.
- Add upstream `b3sum` comparison.
- Add JSON benchmark output.

### Phase M1: CPU Baseline

- Vendor upstream C.
- Enable AArch64 NEON.
- Add Dispatch-parallel tree hashing.
- Match `b3sum` baseline before writing Metal kernels.

### Phase M2: Metal Bring-Up

- Add `BLAKE3Metal` target.
- Compile `.metal` kernels in SwiftPM.
- Create command queue, pipeline cache, and shared buffer pool.
- Add a no-op kernel and bandwidth copy benchmark.

### Phase M3: Leaf CV Kernel

- Implement one-chunk-per-thread leaf compression.
- Validate per-chunk CVs against upstream C.
- Benchmark 128, 256, 512, and 1024 threads per group.

### Phase M4: Parent and Tile Reduction

- Implement parent-level reduction.
- Implement fused tile reduction.
- Autotune tile size.
- Validate full power-of-two chunk inputs.

### Phase M5: Arbitrary Length

- Support non-power-of-two chunk counts.
- Support final partial chunks.
- Keep root semantics identical to upstream.
- Pass all official vectors through Metal for lengths large enough to trigger
  Metal.

### Phase M6: File and MTLBuffer Fast Paths

- Implement mmap no-copy wrapping where possible.
- Add `MTLBuffer` public hashing API.
- Add fallback pooled shared-buffer slabs.

### Phase M7: Autotuned Default Dispatch

- Integrate autotuned thresholds.
- Make default dispatch choose CPU or Metal by size and data location.
- Add environment overrides:

```text
BLAKE3_SWIFT_BACKEND=cpu
BLAKE3_SWIFT_BACKEND=metal
BLAKE3_SWIFT_METAL_VARIANT=leaf1|leaf2|tile
BLAKE3_SWIFT_AUTOTUNE=1
```

## Key Bet

The path to "fastest in Swift on M4" is not pure Swift scalar code and not a
blind GPU port. It is:

1. match upstream CPU performance from Swift;
2. build a Metal backend that avoids copies and fuses reductions;
3. autotune on this M4;
4. default to Metal only when it beats CPU parallel end-to-end;
5. expose `MTLBuffer` hashing so GPU-resident data avoids CPU round trips.

That is the only credible way to beat upstream `b3sum` on this MacBook M4
instead of merely wrapping it.

## Sources

- Apple MacBook Pro M4 announcement and memory bandwidth:
  https://www.apple.com/mz/newsroom/2024/10/new-macbook-pro-features-m4-family-of-chips-and-apple-intelligence/
- Apple 16-inch MacBook Pro M4 Pro/Max tech specs:
  https://support.apple.com/en-us/121554
- Apple Metal threads and threadgroups:
  https://developer.apple.com/documentation/metal/creating-threads-and-threadgroups
- Apple `threadExecutionWidth` guidance:
  https://developer.apple.com/documentation/Metal/MTLComputePipelineState/threadExecutionWidth
- BLAKE3 official repository:
  https://github.com/BLAKE3-team/BLAKE3
- BLAKE3 Rust docs:
  https://docs.rs/blake3/
- SYCL BLAKE3 GPGPU notes:
  https://itzmeanjan.in/pages/blake3-on-gpgpu.html
- SYCL accelerated BLAKE3 implementation:
  https://github.com/itzmeanjan/blake3
- CUDA BLAKE3-gpu experiment:
  https://github.com/Blaze-3/BLAKE3-gpu
