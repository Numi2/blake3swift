# BLAKE3Swift

BLAKE3Swift is an independent BLAKE3 implementation for Apple platforms. The library target is pure Swift and dependency-free, and the repository also includes streaming and file APIs, benchmark support, and an optional Metal backend for large unkeyed workloads on Apple silicon.

The goal is straightforward: a Swift-first BLAKE3 implementation with explicit execution paths, reproducible measurements, and conservative correctness checks. This is not the upstream BLAKE3 project. The implementation is tested against the official BLAKE3 vectors, keyed hashing, key derivation, extended output, streaming behavior, file hashing, and Metal/CPU parity, and its CPU baselines are benchmarked against vendored official C code.

## Performance Snapshot

Unless noted otherwise, the numbers below are medians from local release runs on Apple M4 with 10 active CPUs, macOS 26.5, and Swift 6.3. All promoted rows come from validated JSON artifacts under `benchmarks/results`. Parallel CPU, default dispatch, and Metal rows are reported separately because they are different execution models and timing classes. The strict in-process SIMD4 versus vendored official C CPU comparison is kept below the higher-level tables.

### Detailed Engineering Results

The table below keeps the current promoted higher-level and accelerator rows. The `CPU parallel` values now come from the focused validated CPU artifact `benchmarks/results/20260421T-cpu-parallel-parent-cutoff-2048-focused`, which confirms the lowered parent-reduction cutoff on the larger publication sizes. The `Swift BLAKE3.hash(input)` values remain from `benchmarks/results/20260421T-cpu-parallel-task-partition`, which is still the cleaner automatic-dispatch reference across the displayed sizes. The Metal `resident`, `private`, `wrapped`, and `staged` values still come from `benchmarks/results/20260419T-readme-flatkernels-current`, and the `end-to-end` row comes from the focused artifact `benchmarks/results/20260421T-e2e-record`.

| Input | Swift CPU parallel | Swift `BLAKE3.hash(input)` | Metal end-to-end GPU | Metal resident GPU | Metal private GPU | Metal wrapped GPU | Metal staged GPU |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 64 MiB | 11.77 | 22.01 | 17.69 | 33.38 | 40.52 | 30.31 | 13.95 |
| 256 MiB | 12.10 | 41.18 | 15.48 | 51.90 | 57.43 | 45.50 | 19.91 |
| 1 GiB | 12.34 | 47.13 | 18.56 | 63.15 | 59.21 | 34.00 | 23.95 |

Timing-class notes:

- `CPU parallel` is the 10-worker CPU tree path on this machine.
- `Swift BLAKE3.hash(input)` is the default synchronous one-shot API exposed by this library. On this machine and branch, it uses CPU parallel hashing below the 16 MiB Metal threshold and, for larger unkeyed digest inputs on Metal-capable Apple silicon, it can switch to the automatic Metal path.
- `Metal end-to-end` includes shared buffer allocation, copy/setup, hashing, and digest extraction.
- `Metal resident`, `private`, `wrapped`, and `staged` are explicit engineering timing classes with different ownership and transfer costs; they should not be compared directly against the CPU one-shot baseline above.

### Original Publication Layout

The following tables keep the broader publication-style layout while mixing promoted artifacts by timing class: the apples-to-apples serial CPU rows now come from `benchmarks/results/20260421T-cpu-parallel-parent-cutoff-2048`, the `16 MiB` CPU-parallel/context row also comes from that broad artifact, the `64 MiB` to `1 GiB` CPU-parallel/context rows come from `benchmarks/results/20260421T-cpu-parallel-parent-cutoff-2048-focused`, the Swift automatic public row remains from `benchmarks/results/20260421T-cpu-parallel-task-partition`, and the Metal timing-class rows remain from `benchmarks/results/20260419T-readme-flatkernels-current`.

CPU buffer hashing:

| Input | Official C one-shot | Swift scalar | Swift SIMD4 | Swift CPU parallel | CPU context-auto |
| --- | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 2.27 | 1.17 | 1.84 | 10.39 | 10.04 |
| 64 MiB | 2.24 | 1.17 | 1.80 | 11.77 | 11.71 |
| 256 MiB | 2.21 | 1.17 | 1.80 | 12.10 | 12.27 |
| 512 MiB | 2.20 | 1.17 | 1.79 | 12.27 | 12.29 |
| 1 GiB | 2.20 | 1.17 | 1.79 | 12.34 | 12.27 |

Swift public API and cross-algorithm baseline:

| Input | Swift `BLAKE3.hash(input)` | CryptoKit SHA-256 |
| --- | ---: | ---: |
| 16 MiB | 9.23 | 2.78 |
| 64 MiB | 22.01 | 2.90 |
| 256 MiB | 41.18 | 2.94 |
| 512 MiB | 47.84 | 2.92 |
| 1 GiB | 47.13 | 2.87 |

Metal timing classes:

| Input | Resident GPU | Private GPU | Staged GPU | Wrapped GPU | End-to-end GPU |
| --- | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 8.97 | 10.13 | 10.20 | 11.22 | 5.48 |
| 64 MiB | 33.38 | 40.52 | 13.95 | 30.31 | 9.31 |
| 256 MiB | 51.90 | 57.43 | 19.91 | 45.50 | 11.03 |
| 512 MiB | 60.80 | 64.90 | 23.05 | 51.01 | 6.31 |
| 1 GiB | 63.15 | 59.21 | 23.95 | 34.00 | 2.22 |

### Isolated Overhead Harness Records

The integrated isolated overhead harness is kept as a separate acceptance record rather than overwriting the publication-style table above. These rows come from `benchmarks/results/20260421T-full-suite-isolated-overhead`, produced by `benchmarks/run-isolated-overhead.sh` after the harness was hardened to record active tuning env vars, support repeats, capture thermal snapshots, and validate every JSON artifact. They are useful for small/mid-size Metal tuning, but they remain a different measurement shape from the mixed publication sweep.

| Input | Harness resident GPU | Harness private GPU | Harness staged GPU | Harness wrapped GPU |
| --- | ---: | ---: | ---: | ---: |
| 16 MiB | 12.55 | 9.29 | 8.73 | 9.56 |
| 64 MiB | 42.99 | 35.90 | 15.12 | 29.84 |
| 256 MiB | 63.67 | 57.21 | 18.13 | 29.22 |

These harness rows are inserted for traceability, not as blind replacements for the curated publication rows. In this rerun, the clearest harness improvement was `resident-gpu` at `64 MiB`, while `private`, `staged`, and `wrapped` were mixed enough that the earlier curated references remain the cleaner headline table.

### File Reality Check

The current promoted file-path tuning records come from the local isolated artifacts `benchmarks/results/20260421T-local-file-threshold-max`, `benchmarks/results/20260421T-local-file-tiled-64m`, `benchmarks/results/20260421T-local-file-tiled-128m`, `benchmarks/results/20260421T-local-file-tiled-default128`, `benchmarks/results/20260422T-metal-mapped-inflight`, and `benchmarks/results/20260422T-metal-mapped-subtree-collapse`. The earlier April 21 pass moved tiled Metal mmap onto the chunk-CV write plus CPU merge path and promoted a `128 MiB` default mapped tile. The April 22 follow-up kept the mapped-tile pipeline wider and, more importantly, stopped pushing every returned chunk CV individually by collapsing each raw chunk-CV batch into power-of-two subtree entries before the CPU stack merge.

| File input | Metal tiled mmap GPU, old 64 MiB isolated A/B | Metal tiled mmap GPU, promoted 128 MiB isolated A/B | Metal tiled mmap GPU, default 128 MiB confirm | Metal tiled mmap GPU, 4-slot inflight control | Metal tiled mmap GPU, subtree-collapsed current default |
| --- | ---: | ---: | ---: | ---: | ---: |
| 256 MiB | 4.78 | 5.28 | 5.14 | 5.79 | 5.94 |
| 1 GiB | 4.31 | 5.87 | 6.11 | 6.44 | 6.73 |

These are still reality-check file rows, not resident-buffer claims. `metal-staged-read` remains the stronger bounded file strategy on this machine, but the mapped no-copy path is now materially better than the earlier `64 MiB` tile baseline and modestly ahead of the immediate pre-collapse control as well.

### SIMD4 CPU One-Shot Baseline

| Input | Official C one-shot | Swift scalar | Swift SIMD4 | Swift SIMD4 as % of C |
| --- | ---: | ---: | ---: | ---: |
| 16 MiB | 2.27 | 1.17 | 1.84 | 81% |
| 64 MiB | 2.24 | 1.17 | 1.80 | 80% |
| 256 MiB | 2.21 | 1.17 | 1.80 | 81% |
| 512 MiB | 2.20 | 1.17 | 1.79 | 81% |
| 1 GiB | 2.20 | 1.17 | 1.79 | 81% |

On this machine, the fastest pure Swift one-shot CPU path in the promoted artifact is the SIMD4 implementation at `1.79` to `1.84 GiB/s`, which is about `80%` to `81%` of the vendored official C one-shot. That is the fairest benchmark in this README for judging the core implementation itself. It is not a claim about threaded upstream C, other compilers, or other hardware.

The full experiment log, including focused `e2e` follow-ups, small/mid-size digest-only Metal recovery, file-path results, one-chunk batch results, and rejected tuning experiments, is tracked in [docs/performance-results.md](docs/performance-results.md).

## Features

- Native Swift BLAKE3 library target; vendored official C code remains under its upstream license and is isolated to benchmark support.
- One-shot, keyed, derived-key, streaming, XOF, and reusable context APIs.
- Keyed one-shot APIs use CPU tree parallelism for large inputs; derive-key one-shot APIs can use Metal for large material hashes, and `BLAKE3Metal` exposes forced-GPU keyed, derive-key, and XOF hashing for resident and no-copy inputs.
- Reusable CPU contexts with persistent parallel worker pools for repeated hashes.
- SIMD4 chunk and parent reduction paths for CPU throughput.
- CPU parallel hashing defaults to the active processor count, with explicit worker overrides for reproducible benchmarks.
- Default one-shot hashing uses CPU parallelism for CPU-visible work and no-copy Metal for large unkeyed digest, XOF, and derive-key material inputs when available.
- Explicit `hashSerial`, `hashCPU`, and `hashParallel` APIs keep CPU-only benchmarking and backend selection reproducible.
- Bounded-memory CV stack for streaming and multi-GB file hashing; the `flatkernels` streaming state keeps only the current undecided 64-byte block.
- CPU file strategies for buffered reads and memory-mapped hashing.
- File APIs cover unkeyed digest/XOF, keyed digest/XOF, and derive-key material output across CPU and Metal strategies.
- Metal resident-buffer, no-copy Swift input, one-chunk batch hashing, keyed hashing, derive-key material hashing, XOF, staged-buffer, tuned private-staged, async pipeline, tiled mmap file, and staged-read file hashing APIs.
- Dedicated digest-only Metal kernels for plain unkeyed 32-byte digests, with the generalized Metal kernel family retained for keyed hashing, derive-key material, XOF, and batch APIs.
- Fused Metal tile reduction for aligned full-chunk shared-memory inputs.
- Metal file hashing can use no-copy mmap pages or staged reads into bounded shared buffers; large complete prefixes reduce to GPU subtree chaining values before CPU stack merge.
- Runtime Metal compilation fallback plus precompiled `.metallib` loading for production startup control.
- Benchmark harness with separate resident, end-to-end, CPU, file, and sustained-run modes.

## Requirements

- macOS 13 or newer.
- Swift Package Manager with Swift 6.0 or newer.
- Apple Metal support for GPU paths. CPU hashing works without Metal.

## Installation

Add the package to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Numi2/blake3swift.git", branch: "main") // Evaluation only.
]
```

Use a tagged release instead of `main` once public release tags are available.

Then add the library product to a target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Blake3", package: "blake3swift")
    ]
)
```

## Quick Start

```swift
import Foundation
import Blake3

let input = Data("hello".utf8)
let digest = BLAKE3.hash(input)
print(digest)
```

`BLAKE3.hash` is the default automatic path. It uses CPU parallel hashing below the Metal threshold and, on Metal-capable Apple Silicon, wraps large unkeyed digest and XOF inputs without copying. Use `BLAKE3.hashCPU(input)` or `BLAKE3.hashSerial(input)` when a CPU-only path is required.

Streaming:

```swift
import Foundation
import Blake3

var hasher = BLAKE3.Hasher()
hasher.update(Data("hello ".utf8))
hasher.update(Data("world".utf8))

let digest = hasher.finalize()
print(digest)
```

Keyed hashing:

```swift
import Foundation
import Blake3

let key = Data(repeating: 7, count: BLAKE3.keyByteCount)
let input = Data("message".utf8)

let digest = try BLAKE3.keyedHash(key: key, input: input)
print(digest)
```

Extended output:

```swift
import Foundation
import Blake3

var hasher = BLAKE3.Hasher()
hasher.update(Data("material".utf8))

var reader = hasher.finalizeXOF()
var output = [UInt8](repeating: 0, count: 64)
output.withUnsafeMutableBytes { bytes in
    reader.read(into: bytes)
}
```

## File Hashing

```swift
import Blake3

let digest = try BLAKE3File.hash(
    path: "/path/to/file",
    strategy: .memoryMappedParallel()
)
print(digest)
```

File XOF, keyed hashing, and derive-key material use the same strategy selection:

```swift
import Foundation
import Blake3

let key = Data(repeating: 7, count: BLAKE3.keyByteCount)

let xof = try BLAKE3File.hash(
    path: "/path/to/file",
    strategy: .metalStagedRead(),
    outputByteCount: 1024
)

let keyedDigest = try BLAKE3File.keyedHash(
    key: key,
    path: "/path/to/file",
    strategy: .metalMemoryMapped()
)

let derived = try BLAKE3File.deriveKey(
    context: "com.example.file-key.v1",
    path: "/path/to/file",
    strategy: .memoryMappedParallel(),
    outputByteCount: 64
)
```

Async file hashing supports cancellation through Swift tasks:

```swift
import Blake3

let digest = try await BLAKE3File.hashAsync(
    path: "/path/to/file",
    strategy: .automatic
)
print(digest)
```

On Metal-capable systems, staged read hashing keeps large-file memory bounded while avoiding GPU-side page faults on mapped file pages:

```swift
import Blake3

let digest = try await BLAKE3File.hashAsync(
    path: "/path/to/file",
    strategy: .metalStagedRead()
)
print(digest)
```

The default tiled mmap Metal file tile is 128 MiB on this branch, while staged-read Metal now defaults to 32 MiB. `.metalTiledMemoryMapped()` remains available as the no-copy mmap path, but `.metalStagedRead()` is the preferred reality-check path when mmap page-in noise dominates. Metal file strategies accelerate complete chunk/subtree chaining-value work on the GPU; the final canonical CV-stack merge and any final partial chunk remain on the CPU. Tiled mmap Metal now prefers writing chunk CVs and merging them on the CPU over the older subtree-heavy mapped path, which improved the local isolated `256 MiB` and `1 GiB` file rows enough to justify the larger default tile. Staged-read Metal uses four bounded shared buffers and separate per-slot CV buffers by default so file reads can overlap pending GPU tile work without sharing scratch or CV output buffers. CPU mapped parallel hashing uses the direct one-shot parallel tree for files up to 2 GiB, then falls back to the smaller 16 MiB subtree-tiled path to avoid unbounded CV workspace growth. CPU regular-file reads use bounded 64 MiB read tiles, two read buffers below 128 MiB, four read buffers at and above 128 MiB, and CPU subtree reductions overlapped with the next file read. Set `BLAKE3_SWIFT_READ_INFLIGHT` to `1`, `2`, `3`, or `4` to override that default for local sweeps.

## Metal Resident Hashing

Use `BLAKE3Metal.Context` when input already lives in a Metal-accessible buffer or when repeated hashes can reuse staging/private buffers. Resident mode reports hashing-engine throughput and intentionally excludes Swift-side allocation and upload costs once buffers are prepared.

```swift
import Foundation
import Metal
import Blake3

let device = MTLCreateSystemDefaultDevice()!
let context = try BLAKE3Metal.makeContext(device: device)
let input = Data(repeating: 0x42, count: 64 * 1024 * 1024)
let buffer = input.withUnsafeBytes { raw in
    device.makeBuffer(
        bytes: raw.baseAddress!,
        length: raw.count,
        options: .storageModeShared
    )!
}

let digest = try context.hash(
    buffer: buffer,
    length: input.count,
    policy: .gpu
)
print(digest)
```

For synchronous Swift-owned input on Apple Silicon unified memory, use the no-copy wrapper path:

```swift
let digest = try context.hash(input: input, policy: .gpu)
```

For XOF output that another GPU pass will consume, write directly into a caller-owned output buffer:

```swift
let xofOutputBuffer = device.makeBuffer(
    length: 4096,
    options: .storageModePrivate
)!

try context.writeXOF(
    buffer: buffer,
    length: input.count,
    outputByteCount: 4096,
    policy: .gpu,
    into: xofOutputBuffer
)
```

The same pattern is available for keyed XOF and derive-key material with `writeKeyedXOF` and
`writeDerivedKey`.

Private output buffers can be consumed by later Metal passes without CPU readback. When a compact CPU-visible
check is needed, hash the private output buffer with Metal and read only the final 32-byte digest.

When the output digest is needed immediately, `writeXOFAndHashOutput`, `writeKeyedXOFAndHashOutput`, and
`writeDerivedKeyAndHashOutput` chain the writer and output digest in one Metal submission.

For many independent small objects already packed into one resident buffer, use the one-chunk batch path. Each range must be at most `BLAKE3.chunkByteCount` bytes and produces one digest:

```swift
let ranges = [
    0..<1024,
    1024..<1536,
    1536..<2048
]

let digests = try context.hashOneChunkBatch(
    buffer: buffer,
    ranges: ranges
)
print(digests)
```

When another GPU pass consumes the digests, write directly into a caller-owned Metal buffer and skip the
Swift `[Digest]` materialization:

```swift
let outputBuffer = device.makeBuffer(
    length: ranges.count * BLAKE3.digestByteCount,
    options: .storageModePrivate
)!

try context.writeOneChunkBatchDigests(
    buffer: buffer,
    ranges: ranges,
    into: outputBuffer
)
```

Use `.storageModeShared` instead when the CPU needs to inspect the digest bytes.

For repeated Swift-owned uploads into reusable private GPU storage:

```swift
let privateBuffer = try context.makePrivateBuffer(capacity: input.count)
let stagingBuffer = try context.makeStagingBuffer(capacity: input.count)
let digest = try context.hash(
    input: input,
    using: stagingBuffer,
    privateBuffer: privateBuffer,
    policy: .gpu
)
```

Production integrations can avoid runtime Metal compilation by precompiling the bundled kernel source and loading a `.metallib`:

```swift
let context = try BLAKE3Metal.makeContext(
    device: device,
    librarySource: .metallib(URL(fileURLWithPath: "/path/to/BLAKE3Metal.metallib"))
)
```

The built-in source is available as `BLAKE3Metal.kernelSource`. The benchmark executable can print that source for packaging:

```bash
swift run -c release blake3-bench --print-metal-source > BLAKE3Metal.metal
xcrun -sdk macosx metal -c BLAKE3Metal.metal -o BLAKE3Metal.air
xcrun -sdk macosx metallib BLAKE3Metal.air -o BLAKE3Metal.metallib
```

For repeated async jobs, use an async pipeline so staging and command resources are reused:

```swift
import Foundation
import Metal
import Blake3

let device = MTLCreateSystemDefaultDevice()!
let context = try BLAKE3Metal.makeContext(device: device)
let pipeline = try context.makeAsyncPipeline(
    inputCapacity: 64 * 1024 * 1024,
    inFlightCount: 3,
    policy: .gpu,
    usesPrivateBuffers: true
)

let input = Data(repeating: 0x42, count: 64 * 1024 * 1024)
let digest = try await pipeline.hash(input: input)
print(digest)
```

## Benchmarking

The repository exposes three main command surfaces:

- `swift test` runs the `Blake3Tests` suite for correctness, vector coverage, file hashing, streaming, and CPU/Metal parity checks.
- `swift run -c release blake3-bench ...` runs the benchmark CLI for ad hoc measurements and JSON artifact generation.
- `benchmarks/*.sh` are reproducible wrapper scripts around `blake3-bench` for smoke checks, publication sweeps, sustained runs, autotuning, and isolated-overhead collection.

For publication-quality numbers, keep three questions separate:

- How does the core Swift implementation compare with the vendored official C one-shot baseline?
- How fast is the user-visible application path, such as `BLAKE3.hash` or Metal end-to-end hashing?
- How fast is a steady-state accelerator path when setup and ownership costs are intentionally held fixed?

Build the package and run the correctness suite first:

```bash
swift build -c release
swift test
```

Start with the apples-to-apples CPU one-shot baseline:

```bash
swift run -c release blake3-bench \
  --sizes 16m,64m,256m,512m,1g \
  --iterations 5 \
  --metal-modes none \
  --file-modes none \
  --cryptokit-modes none
```

Then run the broader CPU and Metal engineering sweep:

```bash
swift run -c release blake3-bench \
  --sizes 16m,64m,256m,512m,1g \
  --iterations 5 \
  --metal-modes resident,staged,private
```

For small/mid-size Metal overhead work, use isolated per-mode processes instead of the mixed publication sweep:

```bash
benchmarks/run-isolated-overhead.sh
```

This harness now records the active tuning env vars, supports repeats, captures thermal snapshots, and validates every JSON artifact. Do not compare `resident`, `private`, `wrapped`, or `staged` rows directly against the CPU one-shot baseline. They intentionally exclude different parts of the application path.

Add keyed hash, derive-key, and XOF rows to the same table:

```bash
swift run -c release blake3-bench \
  --sizes 64m,256m \
  --iterations 4 \
  --metal-modes resident,wrapped \
  --operation-modes keyed,xof,keyed-xof,derive-key \
  --xof-output-bytes 1024 \
  --file-modes none \
  --cryptokit-modes none
```

Resident Metal XOF rows also include `resident-write-gpu` variants for caller-owned shared output buffers and
`resident-write-private-gpu` variants that write to private output buffers and reduce them with Metal. The
`resident-write-private-chained-gpu` rows encode the private write and output digest in one command buffer.

Measure independent one-chunk batch hashing:

```bash
swift run -c release blake3-bench \
  --sizes 16m,64m \
  --iterations 5 \
  --metal-modes resident \
  --operation-modes batch-one-chunk \
  --batch-item-bytes 1024 \
  --file-modes none \
  --cryptokit-modes none
```

The benchmark emits the array-returning row, a `resident-write-gpu` row that writes digests into a reused
shared `MTLBuffer`, and a `resident-write-private-gpu` row that writes digest bytes into private GPU storage
and reduces them with Metal. The `resident-write-private-chained-gpu` row writes digest bytes into private GPU
storage and reduces them in the same command buffer. The `resident-fused-aggregate-gpu` row hashes the
concatenated digest bytes without materializing that intermediate output.

Use `--batch-pipeline-widths` to emit several pipelined rows into one JSON artifact while keeping the existing
single-width `--batch-pipeline-width` flag available:

```bash
swift run -c release blake3-bench \
  --sizes 64m \
  --iterations 5 \
  --metal-modes resident \
  --operation-modes batch-one-chunk \
  --batch-item-bytes 64 \
  --batch-pipeline-widths 18,22,26,28 \
  --file-modes none \
  --cryptokit-modes none \
  --json-output /tmp/blake3-batch-width-matrix.json
```

Multi-width sweeps run in an interleaved ping-pong order so each width is measured across roughly the same
thermal position instead of finishing one candidate family before starting the next. These sweeps also emit a
stability summary in the CLI output and a `batch_pipeline_sweep_rows` JSON section. The stability-adjusted
throughput is `min(full median, first-half median, last-half median)`, which is a better filter for widths
that actually survive focused confirmation.

By default, `blake3-bench` also includes a `cryptokit sha256` row as a familiar Apple platform baseline. CryptoKit does not provide BLAKE3, so this is a cross-algorithm comparison against Apple's built-in SHA-256 implementation, not a BLAKE3 parity row. CryptoKit rows are emitted after BLAKE3 CPU/Metal rows to avoid perturbing Metal timings. Use `--cryptokit-modes none` when tuning only BLAKE3 backends.

Focused CryptoKit comparison command:

```bash
swift run -c release blake3-bench \
  --sizes 16m,64m,256m \
  --iterations 4 \
  --metal-modes resident,staged,wrapped,e2e \
  --file-modes none \
  --cryptokit-modes sha256
```

Only promote CryptoKit comparison numbers from a rested run where CPU and Metal baselines match the current publication artifact range. `benchmarks/run-publication.sh` writes CryptoKit comparison output as a separate post-baseline artifact so the canonical CPU/Metal and file tables stay comparable. Background CPU/GPU load can make short focused runs look like Metal regressions.

Run file-path measurements:

```bash
swift run -c release blake3-bench \
  --sizes 512m,1g \
  --iterations 3 \
  --metal-modes none \
  --file-modes mmap-parallel,metal-mmap,metal-tiled-mmap,metal-staged-read
```

Add file keyed, derive-key, and XOF rows to the file strategy table:

```bash
swift run -c release blake3-bench \
  --sizes 64m,256m \
  --iterations 3 \
  --metal-modes none \
  --cryptokit-modes none \
  --file-modes read,mmap-parallel,metal-mmap,metal-tiled-mmap,metal-staged-read \
  --file-operation-modes keyed,derive-key,xof,keyed-xof \
  --xof-output-bytes 1024
```

### Timing Classes

Resident mode starts after the input is already in a Metal-accessible buffer and after reusable context setup. It measures the hashing engine and tree reduction path.

End-to-end mode starts from Swift-owned input and includes buffer creation, input transfer/setup, command submission, hashing, reduction, and digest extraction. It measures the application path.

File modes include the selected file access strategy. Memory-mapped modes include mapping and digest extraction. CPU `read` uses bounded read tiles with CPU subtree reductions for regular files and a size-aware read-inflight default. CPU `mmap-parallel` uses a direct parallel tree up to the mapped one-shot cap and a bounded subtree-tiled fallback above it. Tiled Metal mmap mode includes tile mapping, Metal dispatches, per-tile CV extraction, and final canonical tree reduction. Staged-read Metal mode includes file reads into bounded shared Metal buffers, async tile dispatches, digest readback, and final canonical tree reduction. Set `BLAKE3_SWIFT_READ_INFLIGHT=1`, `2`, `3`, or `4` to sweep CPU read buffering. Set `BLAKE3_SWIFT_METAL_STAGED_READ_INFLIGHT=1` to force the older one-buffer staged-read timing shape; the Metal staged-read default is four bounded read/GPU slots.

Warmup runs should be kept separate from reported measurements. Pipeline compilation, first allocation, and first dispatch are excluded from resident headline numbers unless a benchmark mode explicitly states otherwise.

For sustained claims, use repeated large runs and report median plus min/max or p95. Peak sweep numbers and sustained thermal behavior should be documented separately.

See [docs/benchmark-methodology.md](docs/benchmark-methodology.md) for the full benchmark contract.

Reproducible benchmark wrappers live under [benchmarks](benchmarks):

```bash
benchmarks/run-smoke.sh
benchmarks/run-publication.sh
benchmarks/run-sustained.sh
benchmarks/run-autotune.sh
```

What each wrapper is for:

- `benchmarks/run-smoke.sh` is the fast sanity check for local changes before deeper measurement work.
- `benchmarks/run-publication.sh` runs the curated publication sweep and writes the benchmark artifacts used for README/docs promotion.
- `benchmarks/run-sustained.sh` measures longer-running stability and thermal behavior instead of short peak numbers.
- `benchmarks/run-autotune.sh` searches Metal gate and mode candidates and emits validated recommendation JSON.
- `benchmarks/run-isolated-overhead.sh` is the separate small/mid-size Metal overhead harness mentioned above; use it when you want per-mode process isolation rather than the mixed publication sweep.

Publication runs should keep the generated `environment.txt`, raw markdown output, exact commit, power mode, and thermal notes with the release artifacts.

Set `MEMORY_STATS=1` on the fixture scripts, or pass `--memory-stats` to `blake3-bench`, to include process RSS plus allocator bytes/block snapshots beside timing rows.

Set `METAL_LIBRARY=/path/to/BLAKE3Metal.metallib` on the fixture scripts, or pass `--metal-library /path/to/BLAKE3Metal.metallib`, to benchmark precompiled Metal library loading instead of runtime source compilation.

Set `MINIMUM_GPU_BYTES=32m` to tune the `.automatic` Metal CPU/GPU gate, and `METAL_TILE_SIZE=64m` to tune tiled Metal file benchmarking. The emitted JSON records both values.

Run `benchmarks/run-autotune.sh` to measure Metal gate and mode candidates and emit validated recommendation JSON. Set `AUTOTUNE_FILE_TILES=1` when tiled file tile-size recommendations are needed.

Publication and tuning fixtures write and validate machine-readable JSON reports next to their Markdown tables. For ad hoc runs, pass `--json-output /path/to/report.json` to preserve per-sample timings and environment metadata, then `--validate-json /path/to/report.json` before publishing.

Runtime backend overrides:

```bash
BLAKE3_SWIFT_BACKEND=cpu             # force default BLAKE3.hash to CPU
BLAKE3_SWIFT_BACKEND=metal           # prefer Metal above the threshold, with CPU fallback
BLAKE3_SWIFT_METAL_MIN_BYTES=16m
BLAKE3_SWIFT_METAL_FUSED_TILE_CHUNKS=0|128|256|512|1024
BLAKE3_SWIFT_METAL_FUSED_TILE_REDUCTION=inplace|pingpong|simdgroup
```

`BLAKE3_SWIFT_METAL_FUSED_TILE_CHUNKS=128` and `BLAKE3_SWIFT_METAL_FUSED_TILE_REDUCTION=pingpong` are the defaults on this branch for exact full-chunk shared-memory inputs. Set chunks to `0` to disable fused tiling, `256`/`512`/`1024` to test larger tiles, reduction to `inplace` to force the older single-scratch reduction, or reduction to `simdgroup` to try the 128-chunk lane-shuffle reducer on 32-lane Apple GPU targets. The fused path is skipped for private buffers, where the previous reduction path is faster on the local M4 measurements.

## Examples

Runnable examples are isolated in a separate package so the root library product stays small:

```bash
swift run --package-path Examples Blake3Examples all
swift run --package-path Examples Blake3Examples metal-resident
swift run --package-path Examples Blake3Examples tiled-file
```

What each example command does:

- `swift run --package-path Examples Blake3Examples all` runs the full example set.
- `swift run --package-path Examples Blake3Examples metal-resident` runs the focused Metal resident hashing example.
- `swift run --package-path Examples Blake3Examples tiled-file` runs the tiled file hashing example.

The examples cover one-shot hashing, streaming, keyed hash, XOF, CPU file hashing, Metal resident hashing, async pipeline hashing, and tiled file hashing.

## Development

Common local commands:

- `swift build -c release` builds the library and benchmark executable in release mode.
- `swift test` runs the full automated test suite.
- `swift run -c release blake3-bench --help` prints the benchmark CLI options and mode list.

```bash
swift build -c release
swift test
```

Useful docs:

- [BLAKE3 research notes](docs/blake3-research.md)
- [World-class performance plan](docs/world-class-performance-plan.md)
- [M4 Metal performance strategy](docs/m4-metal-performance-strategy.md)
- [Complete implementation roadmap](docs/complete-implementation-roadmap.md)
- [Performance results](docs/performance-results.md)
- [Metal library packaging](docs/metal-library-packaging.md)
- [API stability notes](docs/api-stability.md)
- [Release process](docs/release-process.md)
- [Security review notes](docs/security-review.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md)

## Status

This repository is an active performance engineering project. The Swift and Metal APIs are intended to be explicit about ownership, buffering, timing, and concurrency, but APIs may evolve as benchmarks and hardware tuning improve. See [docs/api-stability.md](docs/api-stability.md) before pinning an integration.
