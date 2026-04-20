# BLAKE3Swift

BLAKE3Swift is a dependency-free Swift implementation of BLAKE3 for Apple platforms. It includes a native Swift scalar core, SIMD4 CPU paths, bounded-memory streaming and file hashing, and a Metal backend for high-throughput hashing on Apple silicon.

The project is performance-focused, but correctness comes first: the Swift implementation is tested against the official BLAKE3 vectors, keyed hashing, key derivation, extended output, streaming updates, file hashing, and Metal/CPU parity.

## Latest Results

Local release benchmarks on Apple M4 are used to tune the Swift CPU and Metal backends and to keep correctness checks attached to every timing row. All numbers below are current `flatkernels` results from `benchmarks/results/20260419T-readme-flatkernels-current`, generated April 19, 2026 on macOS 26.5 with Swift 6.3, runtime Metal source, the 16 MiB Metal crossover, 64 MiB mmap Metal tiles, 32 MiB staged-read Metal tiles, and 4 benchmark iterations. The generated CPU/Metal, file, and CryptoKit JSON reports were validated.

All tables report median GiB/s. The official C row is the vendored in-process BLAKE3 one-shot comparison point, not a claim about every upstream BLAKE3 configuration. CryptoKit SHA-256 is a cross-algorithm Apple platform baseline from the companion `cryptokit-comparison` run, not BLAKE3 parity.

CPU buffer hashing:

| Input | Official C one-shot | Swift scalar | Swift SIMD4 | Swift CPU parallel | CPU context-auto |
| --- | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 2.23 | 1.15 | 1.79 | 8.72 | 9.15 |
| 64 MiB | 2.19 | 1.15 | 1.77 | 9.91 | 9.92 |
| 256 MiB | 2.20 | 1.16 | 1.80 | 10.78 | 10.61 |
| 512 MiB | 2.19 | 1.16 | 1.79 | 11.12 | 11.00 |
| 1 GiB | 2.19 | 1.16 | 1.80 | 11.52 | 11.58 |

Default API and platform baseline:

| Input | Default `BLAKE3.hash` | CryptoKit SHA-256 |
| --- | ---: | ---: |
| 16 MiB | 9.65 | 2.78 |
| 64 MiB | 17.86 | 2.90 |
| 256 MiB | 33.21 | 2.94 |
| 512 MiB | 35.22 | 2.92 |
| 1 GiB | 41.87 | 2.87 |

Metal timing classes are separated by ownership and transfer cost. Resident mode starts after input is already in a shared Metal buffer. Private mode hashes a pre-created private buffer and excludes setup copy. Staged mode includes copying Swift bytes into a reused shared Metal buffer. Wrapped mode includes no-copy Metal buffer wrapping over existing Swift bytes. End-to-end mode includes shared buffer allocation/copy from Swift bytes plus hashing.

| Input | Resident GPU | Private GPU | Staged GPU | Wrapped GPU | End-to-end GPU |
| --- | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 8.97 | 10.13 | 10.20 | 11.22 | 5.48 |
| 64 MiB | 33.38 | 40.52 | 13.95 | 30.31 | 9.31 |
| 256 MiB | 51.90 | 57.43 | 19.91 | 45.50 | 11.03 |
| 512 MiB | 60.80 | 64.90 | 23.05 | 51.01 | 6.31 |
| 1 GiB | 63.15 | 59.21 | 23.95 | 34.00 | 2.22 |

File rows include timed file open/stat, the selected access strategy, hashing, finalization, and close; benchmark file creation is excluded. File mmap, tiled mmap, and staged-read rows are page-in and thermal sensitive, so the table reports this current run directly.

| File input | CPU read | CPU mmap | CPU mmap parallel | Metal mmap GPU | Metal tiled mmap GPU | Metal staged read GPU |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 4.31 | 1.10 | 7.79 | 6.07 | 1.68 | 2.76 |
| 64 MiB | 5.00 | 1.11 | 8.34 | 5.91 | 2.67 | 3.76 |
| 256 MiB | 7.00 | 1.11 | 9.26 | 9.08 | 6.42 | 9.63 |
| 512 MiB | 7.53 | 1.10 | 9.63 | 9.25 | 5.77 | 10.09 |
| 1 GiB | 7.69 | 1.11 | 10.05 | 3.03 | 4.12 | 2.25 |

The current `flatkernels` branch includes the block-state streaming hasher, local SIMD4 four-chunk subtree collapse, uninitialized CV workspace arrays in hot leaf/parent staging, scalar full-chunk unrolling, and size-aware CPU read inflight buffering. The fresh publication build completed in 125.60 seconds; the scalar unroll remains a compile-time versus runtime tradeoff.

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

The default tiled mmap Metal file tile is 64 MiB on this branch, while staged-read Metal now defaults to 32 MiB. `.metalTiledMemoryMapped()` remains available as the no-copy mmap path, but `.metalStagedRead()` is the preferred reality-check path when mmap page-in noise dominates. Metal file strategies accelerate complete chunk/subtree chaining-value work on the GPU; the final canonical CV-stack merge and any final partial chunk remain on the CPU. Staged-read Metal uses four bounded shared buffers and separate per-slot CV buffers by default so file reads can overlap pending GPU tile work without sharing scratch or CV output buffers. CPU mapped parallel hashing uses the direct one-shot parallel tree for files up to 2 GiB, then falls back to the smaller 16 MiB subtree-tiled path to avoid unbounded CV workspace growth. CPU regular-file reads use bounded 64 MiB read tiles, two read buffers below 128 MiB, four read buffers at and above 128 MiB, and CPU subtree reductions overlapped with the next file read. Set `BLAKE3_SWIFT_READ_INFLIGHT` to `1`, `2`, `3`, or `4` to override that default for local sweeps.

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

Build and test first:

```bash
swift build -c release
swift test
```

Run a CPU and Metal throughput sweep:

```bash
swift run -c release blake3-bench \
  --sizes 16m,64m,256m,512m,1g \
  --iterations 5 \
  --metal-modes resident,staged,private
```

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

The examples cover one-shot hashing, streaming, keyed hash, XOF, CPU file hashing, Metal resident hashing, async pipeline hashing, and tiled file hashing.

## Development

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

## License

This repository is **not open source**. It is proprietary source-available software for evaluation, audit, verification, and benchmark review only. Production, commercial, hosted, redistributed, or revenue-connected use requires a separate commercial license. See [LICENSE.md](LICENSE.md).

Vendored upstream BLAKE3 materials remain under their upstream license terms. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
