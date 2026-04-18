# BLAKE3Swift

BLAKE3Swift is a dependency-free Swift implementation of BLAKE3 for Apple platforms. It includes a native Swift scalar core, SIMD4 CPU paths, bounded-memory streaming and file hashing, and a Metal backend for high-throughput hashing on Apple silicon.

The project is performance-focused, but correctness comes first: the Swift implementation is tested against the official BLAKE3 vectors, keyed hashing, key derivation, extended output, streaming updates, file hashing, and Metal/CPU parity.

## License

This repository is **not open source**. It is proprietary source-available software for evaluation, audit, verification, and benchmark review only. Production, commercial, hosted, redistributed, or revenue-connected use requires a separate commercial license. See [LICENSE.md](LICENSE.md).

## Features

- Native Swift BLAKE3 core with no vendored C target.
- One-shot, keyed, derived-key, streaming, XOF, and reusable context APIs.
- Reusable CPU contexts with persistent parallel worker pools for repeated hashes.
- SIMD4 chunk and parent reduction paths for CPU throughput.
- CPU parallel hashing defaults to the active processor count, with explicit worker overrides for reproducible benchmarks.
- Default one-shot hashing uses CPU parallelism for CPU-visible work and no-copy Metal for large unkeyed inputs when available.
- Explicit `hashSerial`, `hashCPU`, and `hashParallel` APIs keep CPU-only benchmarking and backend selection reproducible.
- Bounded-memory CV stack for streaming and multi-GB file hashing.
- CPU file strategies for buffered reads and memory-mapped hashing.
- Metal resident-buffer, no-copy Swift input, staged-buffer, tuned private-staged, async pipeline, and tiled file hashing APIs.
- Fused Metal tile reduction for aligned full-chunk shared-memory inputs.
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

On Metal-capable systems, tiled mapped file hashing keeps large-file memory bounded while using the GPU for tile work:

```swift
import Blake3

let digest = try await BLAKE3File.hashAsync(
    path: "/path/to/file",
    strategy: .metalTiledMemoryMapped()
)
print(digest)
```

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

Run file-path measurements:

```bash
swift run -c release blake3-bench \
  --sizes 512m,1g \
  --iterations 3 \
  --metal-modes none \
  --file-modes mmap-parallel,metal-mmap,metal-tiled-mmap
```

### Timing Classes

Resident mode starts after the input is already in a Metal-accessible buffer and after reusable context setup. It measures the hashing engine and tree reduction path.

End-to-end mode starts from Swift-owned input and includes buffer creation, input transfer/setup, command submission, hashing, reduction, and digest extraction. It measures the application path.

File modes include the selected file access strategy. Memory-mapped modes include mapping and digest extraction. Tiled Metal file mode includes tile mapping, Metal dispatches, per-tile CV extraction, and final canonical tree reduction.

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
BLAKE3_SWIFT_METAL_MIN_BYTES=33554432
BLAKE3_SWIFT_METAL_FUSED_TILE_CHUNKS=0|256|512
```

`BLAKE3_SWIFT_METAL_FUSED_TILE_CHUNKS=512` is the default on this branch. It is used for exact full-chunk shared-memory inputs and skipped for private buffers, where the previous reduction path is faster on the local M4 measurements.

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

## Status

This repository is an active performance engineering project. The Swift and Metal APIs are intended to be explicit about ownership, buffering, timing, and concurrency, but APIs may evolve as benchmarks and hardware tuning improve. See [docs/api-stability.md](docs/api-stability.md) before pinning an integration.
