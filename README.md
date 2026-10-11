# BLAKE3Swift

BLAKE3Swift is a Swift package for hashing data and files with BLAKE3. Its library target is implemented in Swift and has no external package dependencies. CPU hashing works without Metal; optional Metal APIs accelerate selected workloads on supported Apple devices.

This is an independent implementation, not the upstream BLAKE3 project. The package also contains a benchmark executable and a separate examples package.

## Capabilities

- One-shot and streaming BLAKE3 hashing
- Keyed hashing, context-based key derivation, and extendable output (XOF)
- Reusable CPU contexts and explicit CPU backend selection
- Regular-file hashing with bounded-memory CPU strategies
- Optional Metal hashing for resident buffers, batches of small inputs, XOF output, and file workloads
- Release benchmark executable, reproducible benchmark scripts, and machine-readable reports

## Requirements

- macOS 13 or later
- Swift 6.0 or later
- Metal-capable Apple hardware for GPU APIs; the CPU APIs do not require Metal

## Add the package

There are no tagged releases yet. For evaluation, add the current main branch to your app's `Package.swift`:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(
            url: "https://github.com/Numi2/blake3swift.git",
            branch: "main"
        )
    ],
    targets: [
        .executableTarget(
            name: "YourTarget",
            dependencies: [
                .product(name: "Blake3", package: "blake3swift")
            ]
        )
    ]
)
```

Pin a revision in production until versioned releases are available.

## Quick start

```swift
import Foundation
import Blake3

let input = Data("hello".utf8)
let digest = BLAKE3.hash(input)
print(digest)
```

The default `BLAKE3.hash` API selects a CPU or Metal path according to the host, input size, and backend configuration, and falls back to CPU if a selected Metal call fails. Choose an explicit CPU API when backend behavior must be fixed:

```swift
let digest = BLAKE3.hashCPU(input)       // CPU parallel path
let serialDigest = BLAKE3.hashSerial(input)
```

## Common operations

### Streaming

```swift
import Foundation

var hasher = BLAKE3.Hasher()
hasher.update(Data("hello ".utf8))
hasher.update(Data("world".utf8))

let digest = hasher.finalize()
```

Finalize does not consume the hasher. For longer output, use `finalizeXOF()`:

```swift
import Foundation

var hasher = BLAKE3.Hasher()
hasher.update(Data("material".utf8))

var reader = hasher.finalizeXOF()
var output = [UInt8](repeating: 0, count: 64)
output.withUnsafeMutableBytes { bytes in
    reader.read(into: bytes)
}
```

### Keyed hashing and key derivation

```swift
import Foundation

let key = Data(repeating: 7, count: BLAKE3.keyByteCount)
let message = Data("message".utf8)

let keyedDigest = try BLAKE3.keyedHash(key: key, input: message)
let derivedBytes = try BLAKE3.deriveKey(
    context: "com.example.file-key.v1",
    material: message,
    outputByteCount: 64
)
```

A keyed hash key must be exactly `BLAKE3.keyByteCount` bytes. Key derivation uses the context string's UTF-8 bytes.

### Files

Hash a regular file with the automatic strategy, or select a CPU or Metal strategy explicitly:

```swift
let digest = try BLAKE3File.hash(
    path: "/path/to/file",
    strategy: .automatic
)

let cpuDigest = try BLAKE3File.hash(
    path: "/path/to/file",
    strategy: .memoryMappedParallel()
)
```

`BLAKE3File.hashAsync` supports Swift task cancellation. Available file strategies include bounded reads, memory-mapped CPU hashing, and—when Metal is available—mapped, tiled-mapped, and staged-read Metal paths. Metal file modes retain CPU fallback by default. See the [file API](Sources/Blake3/BLAKE3File.swift) and [benchmark methodology](docs/benchmark-methodology.md) for strategy behavior and timing boundaries.

## Metal APIs

Use `BLAKE3Metal.Context` when input already resides in a Metal buffer or when you want to reuse Metal resources:

```swift
import Foundation
import Metal
import Blake3

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("Metal is unavailable")
}

let context = try BLAKE3Metal.makeContext(device: device)
let input = Data(repeating: 0x42, count: 64 * 1024 * 1024)
let buffer = input.withUnsafeBytes { bytes in
    device.makeBuffer(
        bytes: bytes.baseAddress!,
        length: bytes.count,
        options: .storageModeShared
    )!
}

let digest = try context.hash(
    buffer: buffer,
    length: input.count,
    policy: .gpu
)
```

For synchronous Swift-owned input on Apple silicon, `context.hash(input:policy:)` offers a no-copy wrapper path. For repeated asynchronous calls, use a reusable async pipeline. GPU execution policies, output-buffer APIs, keyed/XOF variants, and precompiled Metal library loading are documented in [BLAKE3Metal.swift](Sources/Blake3/BLAKE3Metal.swift).

### Batch independent messages

The one-chunk batch API hashes many independent messages from a resident buffer. Each range must fit in one BLAKE3 chunk. For adjacent 64-byte messages, the contiguous overload avoids constructing a range array:

```swift
let aggregateDigest = try context.hashOneChunkBatchDigestBytes(
    buffer: buffer,
    startingAt: 0,
    blockCount: input.count / BLAKE3.blockByteCount
)
```

This operation hashes the concatenated per-message digest bytes. It is useful when a GPU workload already stores many fixed-size messages together; it is not a replacement for hashing one large input with `BLAKE3.hash`.

## Performance

Throughput depends on hardware, input, backend, and timing class. The table shows the latest focused result for resident aggregation of independent 64-byte messages on an Apple M6 Mac mini. It reports 15 timed samples per row, with correct digests and validated JSON reports.

| Aggregate input | M6 median | M6 minimum | Earlier M6 range-array API median | Same-device gain |
| ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 44.36 GiB/s | 40.45 GiB/s | 4.10 GiB/s | 10.8× |
| 64 MiB | 54.53 GiB/s | 51.68 GiB/s | 4.34 GiB/s | 12.6× |

This gain is for the contiguous batch API versus the previous range-array API on the same M6 and workload. The input and reusable output storage were resident; these are steady-state measurements, not upload or first-call latency. No matching M4 batch result exists, so this does not establish a 10× improvement for general BLAKE3 hashing or across hardware. The archived best-M4 versus initial M6 1 GiB baseline comparison shows 1.19×–1.52× across comparable timing classes; it is not a same-build cross-device A/B. Full results, provenance, and limitations are in [performance results](docs/performance-results.md) and the [M6 batch experiment](benchmarks/results/20261011T-m6-contiguous-batch-api/README.md).

For Metal tuning, Apple recommends choosing threadgroup sizes using each pipeline's threadExecutionWidth and maximum supported size, then correlating GPU timeline, occupancy, and memory-bandwidth measurements before attributing a bottleneck ([threadgroup sizing](https://developer.apple.com/documentation/metal/calculating-threadgroup-and-grid-sizes), [GPU occupancy](https://developer.apple.com/documentation/xcode/finding-your-metal-apps-gpu-occupancy), [GPU memory bandwidth](https://developer.apple.com/documentation/xcode/measuring-the-gpus-use-of-memory-bandwidth)). The M6 measurements do not identify a hardware limiter; see the experiment report for the available profiling evidence.

## Benchmarking

Build and run the benchmark executable in release mode:

```sh
swift run -c release blake3-bench \
  --sizes 16m,64m,256m,512m,1g \
  --iterations 5 \
  --metal-modes resident,staged,e2e \
  --file-modes none \
  --cryptokit-modes none \
  --json-output /tmp/blake3-report.json
```

Use the wrappers under benchmarks/ for repeatable workflows:

```sh
benchmarks/run-smoke.sh
benchmarks/run-publication.sh
benchmarks/run-sustained.sh
benchmarks/run-file-reality.sh
benchmarks/run-isolated-overhead.sh
```

Keep public API, CPU, Metal resident, Metal end-to-end, file, and sustained results in their own timing classes. Record the tested device, OS, Swift version, source revision, Metal library mode, power/thermal conditions, sample count, and correctness. Do not treat a peak sample or a resident-GPU number as application-path throughput. See [benchmark fixtures](benchmarks/README.md) and the [measurement contract](docs/benchmark-methodology.md).

## Examples

Runnable integration examples are isolated in their own package:

```sh
swift run --package-path Examples Blake3Examples help
swift run --package-path Examples Blake3Examples all
```

The examples cover one-shot, streaming, keyed, derive-key, XOF, CPU file, resident Metal, async pipeline, and tiled-file APIs. See [Examples/README.md](Examples/README.md) for individual commands.

## Development

```sh
swift build -c release
swift test
swift run -c release blake3-bench --help
```

The package is pre-1.0.0; see [API stability](docs/api-stability.md) before relying on experimental context, file, Metal, or benchmark surfaces.

## Project documentation

- [Performance results and experiment history](docs/performance-results.md)
- [Benchmark methodology](docs/benchmark-methodology.md)
- [API stability and ownership](docs/api-stability.md)
- [Metal library packaging](docs/metal-library-packaging.md)
- [BLAKE3 research notes](docs/blake3-research.md)
- [Implementation roadmap](docs/complete-implementation-roadmap.md)
- [Release process](docs/release-process.md)
- [License](LICENSE.md) and [third-party notices](THIRD_PARTY_NOTICES.md)
