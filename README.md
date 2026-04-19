# BLAKE3Swift

BLAKE3Swift is a dependency-free Swift implementation of BLAKE3 for Apple platforms. It includes a native Swift scalar core, SIMD4 CPU paths, bounded-memory streaming and file hashing, and a Metal backend for high-throughput hashing on Apple silicon.

The project is performance-focused, but correctness comes first: the Swift implementation is tested against the official BLAKE3 vectors, keyed hashing, key derivation, extended output, streaming updates, file hashing, and Metal/CPU parity.

## Latest Results

Local release benchmarks on Apple M4 are used to tune the Swift CPU and Metal backends and to keep correctness checks attached to every timing row. The buffer-throughput numbers are from `benchmarks/results/20260419T140713Z-readme-refresh`; the file-path reality rows below are from the isolated file harness under `/tmp/blake3swift-file-reality-final-code`. The prior publication artifacts were JSON validated, and the follow-up JSON was validated during tuning.

The official C row is a vendored in-process one-shot comparison point, not a claim about every upstream BLAKE3 configuration. CryptoKit SHA-256 is a cross-algorithm Apple platform baseline from the separate `cryptokit-comparison` artifact, not BLAKE3 parity. Metal timing classes are reported separately: staged rows include copying Swift bytes into a reused shared Metal buffer plus hashing, wrapped rows include no-copy Metal buffer wrapping plus hashing, and resident rows start after input is already in Metal-accessible storage.

This run used the current 128-chunk ping-pong fused tile default and runtime Metal source on Apple M4, macOS 26.5, Swift 6.3. The working tree was dirty with benchmark harness and documentation changes.

| Input | Official C BLAKE3 one-shot | CryptoKit SHA-256 | Swift CPU parallel | Default `BLAKE3.hash` | Metal staged GPU | Metal wrapped GPU | Metal resident GPU |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 256 MiB | 2.31 GiB/s | 2.93 GiB/s | 10.80 GiB/s | 41.79 GiB/s | 21.86 GiB/s | 42.93 GiB/s | 75.28 GiB/s |
| 512 MiB | 2.25 GiB/s | 2.90 GiB/s | 11.08 GiB/s | 37.00 GiB/s | 23.69 GiB/s | 48.94 GiB/s | 67.91 GiB/s |
| 1 GiB | 2.21 GiB/s | 2.86 GiB/s | 11.54 GiB/s | 46.94 GiB/s | 22.61 GiB/s | 40.65 GiB/s | 73.18 GiB/s |

The automatic path uses Swift CPU hashing below the Metal crossover and Metal for larger unkeyed inputs. The current default crossover is 16 MiB, which keeps small buffers on the CPU path while letting larger buffers use the GPU when that is beneficial for the selected timing class.

File rows are the reality check for allocation, copy, file-cache, mmap/page-in, and thermal behavior. The staged-read Metal file path reads bounded tiles directly into shared Metal buffers and avoids large final-tile CPU CV merges. The CPU read row now uses two bounded read buffers so file copy can overlap the previous tile's subtree reduction.

| File Input | CPU bounded read | CPU mmap parallel | Metal tiled mmap GPU | Metal staged read GPU |
| --- | ---: | ---: | ---: | ---: |
| 512 MiB | 7.50 GiB/s | 9.08 GiB/s | 6.79 GiB/s | 10.49 GiB/s |
| 1 GiB | 7.69 GiB/s | 9.57 GiB/s | 8.48 GiB/s | 10.30 GiB/s |

These rows run each file strategy in a separate benchmark process, with JSON validation and thermal snapshots around each mode. The staged-read row uses the new 32 MiB staged tile default and the final-prefix CV merge threshold; a staged-only two-repeat check at `/tmp/blake3swift-file-reality-final-cv-threshold32k` measured 11.37/10.99 and 11.24/10.76 GiB/s for 512 MiB/1 GiB. Full publication and file-path fixtures are kept under `benchmarks/results/`. File mmap timings are more page-in sensitive than resident-memory timings and are not used for staged/wrapped/resident overhead claims.

## Features

- Native Swift BLAKE3 library target; vendored official C code remains under its upstream license and is isolated to benchmark support.
- One-shot, keyed, derived-key, streaming, XOF, and reusable context APIs.
- Keyed and derive-key one-shot APIs use CPU tree parallelism for large inputs.
- Reusable CPU contexts with persistent parallel worker pools for repeated hashes.
- SIMD4 chunk and parent reduction paths for CPU throughput.
- CPU parallel hashing defaults to the active processor count, with explicit worker overrides for reproducible benchmarks.
- Default one-shot hashing uses CPU parallelism for CPU-visible work and no-copy Metal for large unkeyed inputs when available.
- Explicit `hashSerial`, `hashCPU`, and `hashParallel` APIs keep CPU-only benchmarking and backend selection reproducible.
- Bounded-memory CV stack for streaming and multi-GB file hashing.
- CPU file strategies for buffered reads and memory-mapped hashing.
- Metal resident-buffer, no-copy Swift input, staged-buffer, tuned private-staged, async pipeline, tiled mmap file, and staged-read file hashing APIs.
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

`BLAKE3.hash` is the default automatic path. It uses CPU parallel hashing below the Metal threshold and, on Metal-capable Apple Silicon, wraps large unkeyed inputs without copying. Use `BLAKE3.hashCPU(input)` or `BLAKE3.hashSerial(input)` when a CPU-only path is required.

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

The default tiled mmap Metal file tile is 64 MiB on this branch, while staged-read Metal now defaults to 32 MiB. `.metalTiledMemoryMapped()` remains available as the no-copy mmap path, but `.metalStagedRead()` is the preferred reality-check path when mmap page-in noise dominates. Staged-read Metal uses two bounded shared buffers by default so file reads can overlap the previous tile's GPU reduction. CPU mapped parallel hashing uses the direct one-shot parallel tree for files up to 2 GiB, then falls back to the smaller 16 MiB subtree-tiled path to avoid unbounded CV workspace growth. CPU regular-file reads use bounded 64 MiB read tiles, two read buffers by default, and CPU subtree reductions overlapped with the next file read.

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

### Timing Classes

Resident mode starts after the input is already in a Metal-accessible buffer and after reusable context setup. It measures the hashing engine and tree reduction path.

End-to-end mode starts from Swift-owned input and includes buffer creation, input transfer/setup, command submission, hashing, reduction, and digest extraction. It measures the application path.

File modes include the selected file access strategy. Memory-mapped modes include mapping and digest extraction. CPU `read` uses bounded read tiles with CPU subtree reductions for regular files. CPU `mmap-parallel` uses a direct parallel tree up to the mapped one-shot cap and a bounded subtree-tiled fallback above it. Tiled Metal mmap mode includes tile mapping, Metal dispatches, per-tile CV extraction, and final canonical tree reduction. Staged-read Metal mode includes file reads into bounded shared Metal buffers, tile dispatches, digest readback, and final canonical tree reduction. Set `BLAKE3_SWIFT_METAL_STAGED_READ_INFLIGHT=1` to force the older one-buffer staged-read timing shape.

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
