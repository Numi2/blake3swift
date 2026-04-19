# Complete Roadmap for a Best-in-Class Swift BLAKE3

Historical note: this roadmap is retained as engineering context. The current
package state is reflected first by `README.md`, `docs/benchmark-methodology.md`,
and the latest `benchmarks/results/*` artifacts. In particular, the public
`Blake3` library product is native Swift, while the repository now vendors the
official C implementation only inside the isolated `CBLAKE3` benchmark-support
target.

This is the execution plan for building a world-class Swift BLAKE3 package.
The baseline upstream is BLAKE3 `1.8.4`, released 2026-03-30. The goal is not
to be fast "for Swift"; the goal is to be competitive with the official C and
Rust implementations on the same hardware while exposing an idiomatic Swift API.

## Decisions

The implementation now uses an owned-backend strategy:

1. The default CPU backend is native Swift, not a wrapper around vendored C.
2. The Swift scalar core is the source of truth for compression, tree reduction,
   keyed hashing, key derivation, streaming, and XOF output. Serial and
   streaming tree construction use a bounded CV stack instead of retaining one
   chaining value per input chunk.
3. Swift owns the public API, copy-on-write hasher ergonomics, file APIs,
   benchmarking harness, validation harness, and parallel orchestration.
4. Metal remains the high-throughput resident-buffer engine for large inputs
   that are already in Metal-accessible storage.
5. Metal exposes synchronous benchmark paths and async application paths with
   bounded reusable async workspaces; timing claims must keep resident, staged,
   private, private-staged, and end-to-end modes separate.
6. Peak CPU work uses Swift SIMD4 chunk and parent-reduction backends plus
   reusable CPU workspaces; future CPU work should widen/tune those owned Swift
   paths rather than reintroducing a C vendor dependency.

The first owned-stack release should ship with the Swift scalar/parallel backend,
the existing Metal resident/staged/private paths, mmap-backed file hashing, and
a benchmark suite that compares against upstream `b3sum` as an external tool
rather than as linked vendored code.

## Implementation Survey

### Official Rust and C

Use these as the source of truth for behavior, test vectors, and performance
shape. The official repository includes Rust and C implementations with SSE2,
SSE4.1, AVX2, AVX-512, NEON, and WASM SIMD in Rust; C includes all except WASM.
The Rust crate exposes `update_rayon`, `update_mmap`, and
`update_mmap_rayon`; the C implementation exposes optional oneTBB parallelism.

Lessons to adopt:

- Match the production lazy merge algorithm, not just the reference eager merge
  algorithm, before claiming performance quality.
- Preserve the `compress_subtree_wide` design. It returns multiple chaining
  values so parent nodes can be batched and the root is not compressed too soon.
- Parent node hashing must be vectorized too. Optimizing only leaf chunks is
  incomplete.
- Multithreading has a real break-even point. Upstream documents roughly
  128 KiB on x86_64 as a rule of thumb, but the threshold varies and must be
  benchmarked per platform.
- File hashing should prefer mmap for large regular files when safe, because
  reading a large file serially can dominate hashing time.

### LLVM Vendored BLAKE3

LLVM vendors the official C implementation in compiler infrastructure. This is
useful as a behavior and maintenance reference, but this package no longer uses
vendored C as a backend. The Swift implementation should treat upstream as an
external oracle and benchmark comparator, not as source linked into the package.

Lessons to adopt:

- Swift derive-key contexts should be encoded as explicit UTF-8 bytes, not
  passed through null-terminated string conventions.
- Treat hasher state as copy-on-write storage. The native Swift hasher owns less
  state than upstream C, but accidental value copying still matters in hot code.
- Upstream assembly remains a useful external performance comparator, but it
  should not be linked into this package.
- Streaming file examples use 64 KiB buffers, which is a sensible floor for our
  read-buffer strategy.

### Go `zeebo/blake3`

This is a pure Go implementation with generated AVX2 and SSE4.1 assembly. It
does not do multithreading, so it makes different tradeoffs from upstream Rust.

Lessons to adopt:

- Internal buffering matters. Go buffers to 8 KiB so callers do not have to
  supply SIMD-sized update chunks manually.
- The useful low-level API shape is `HashF` for leaf chunks, `HashP` for parent
  nodes, and `Compress` for scalar blocks. Swift should mirror this internally.
- `Reset` is important for workloads that hash many small messages, because
  initialization overhead can dominate.
- Internal buffering can hurt tiny one-shot hashes, so Swift one-shot APIs must
  bypass the streaming staging buffer.

### Blake3.NET

Blake3.NET is a managed wrapper around the Rust SIMD implementation, with a
`Span`-friendly API, a stream wrapper, XOF seek support, and an explicit
`UpdateWithJoin` parallel path.

Lessons to adopt:

- Swift APIs should be borrowed-buffer first: `ContiguousBytes`,
  `UnsafeRawBufferPointer`, and `UnsafeMutableRawBufferPointer` fast paths.
- Parallel hashing should be explicit or strategy-driven, not hidden inside
  every `update` call.
- One-shot native shims are valuable for reducing interop overhead.
- Blake3.NET's Rust bridge converts derive-key context bytes through
  `String::from_utf8_lossy`; Swift must not do this. Invalid or arbitrary bytes
  must not be silently changed.

### Apache Commons Codec Java

Apache Commons Codec has a pure Java BLAKE3 implementation with clear state
objects, official test vectors, keyed mode, KDF mode, and XOF finalization.

Lessons to adopt:

- It is a useful readability reference for the scalar state machine:
  `ChunkState`, `EngineState`, `Output`, chaining-value stack, and XOF loop.
- It reinforces the fixed stack bound: 54 subtree chaining values cover
  `2^64` bytes.
- It is not a performance model for Swift.

### Existing Swift Wrappers

The existing Swift packages are mainly wrappers around upstream C. They are
useful as API and packaging references, not as the final architecture.

Lessons to adopt:

- A CoW reference box around hasher state is the right shape for a Swift value
  type.
- Optional SwiftCrypto `HashFunction` conformance is useful but should live in a
  separate target so the core package does not force that dependency.
- Avoid the naive C aggregation pattern that disables x86 SIMD unless the whole
  target is compiled with AVX/SSE features. The package must prove at runtime
  that the expected backend is actually active.

### Crypto++ Modern

Crypto++ Modern documents provider introspection and practical buffer-size
guidance: SSE4.1 needs 4 KiB to fill four chunks, AVX2 needs 8 KiB, and AVX-512
needs 16 KiB.

Lessons to adopt:

- Expose `BLAKE3.activeBackend` or similar introspection for tests and
  diagnostics.
- Use at least 16 KiB for the streaming staging buffer and at least 64 KiB for
  file reads.
- Public docs should clearly explain that small inputs remain correct and fast,
  but large buffers are required for maximum SIMD throughput.

### WASM, JavaScript, Python, and Other Bindings

These are mostly packaging and distribution references. They are useful for API
ergonomics and prebuilt artifact strategy, but they do not change the native
Swift performance plan.

## Package Layout

Use this layout:

```text
Package.swift
Sources/
  Blake3/
    BLAKE3.swift
    BLAKE3Digest.swift
    BLAKE3Hasher.swift
    BLAKE3OutputReader.swift
    Backend/
      BackendKind.swift
      BackendDispatch.swift
  Blake3Core/
    Constants.swift
    Compression.swift
    ChunkState.swift
    Output.swift
    ScalarHasher.swift
    Tree.swift
  Blake3File/
    FileHashing.swift
    MMap.swift
    ReadBuffer.swift
  Blake3Crypto/
    BLAKE3+HashFunction.swift
Benchmarks/
  Blake3Benchmarks/
Tests/
  Blake3Tests/
  Blake3VectorTests/
  Blake3BackendTests/
Scripts/
  update-upstream-blake3.sh
  compare-upstream.sh
```

Target boundaries:

- `Blake3` is the public package product.
- `Blake3Core` is pure Swift and internal by default.
- `Blake3File` is optional higher-level file hashing.
- `Blake3Crypto` is optional SwiftCrypto compatibility.

## Public API

Use a CryptoKit-like namespace:

```swift
public enum BLAKE3 {
    public static let digestByteCount = 32

    public static func hash(_ input: some ContiguousBytes) -> Digest
    public static func hash(_ input: UnsafeRawBufferPointer) -> Digest

    public static func keyedHash(
        key: some ContiguousBytes,
        input: some ContiguousBytes
    ) throws -> Digest

    public static func deriveKey(
        context: String,
        material: some ContiguousBytes,
        outputByteCount: Int = 32
    ) throws -> [UInt8]

    public static var activeBackend: BackendKind { get }
}
```

Digest:

```swift
extension BLAKE3 {
    public struct Digest: Sendable, Hashable, CustomStringConvertible {
        public static let byteCount = 32
        public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
        public func constantTimeEquals(_ other: Digest) -> Bool
        public var description: String { get } // lowercase hex
    }
}
```

Hasher:

```swift
extension BLAKE3 {
    public struct Hasher {
        public init()
        public init(key: some ContiguousBytes) throws
        public init(deriveKeyContext context: String)

        public mutating func update(_ input: some ContiguousBytes)
        public mutating func update(_ input: UnsafeRawBufferPointer)
        public mutating func reset()
        public func finalize() -> Digest
        public func finalize(into output: UnsafeMutableRawBufferPointer)
        public func finalizeXOF() -> OutputReader
    }
}
```

Output reader:

```swift
extension BLAKE3 {
    public struct OutputReader {
        public var position: UInt64
        public mutating func seek(to position: UInt64)
        public mutating func read(into output: UnsafeMutableRawBufferPointer)
    }
}
```

File API:

```swift
public enum BLAKE3File {
    public static func hash(
        path: String,
        strategy: Strategy = .automatic
    ) throws -> BLAKE3.Digest

    public enum Strategy {
        case automatic
        case read(bufferSize: Int = 64 * 1024)
        case memoryMapped
        case memoryMappedParallel(maxThreads: Int? = nil)
    }
}
```

API rules:

- `Digest` stores 32 bytes inline. It must not store `[UInt8]`.
- `Equatable` and `Hashable` are for normal Swift collection behavior.
  Authentication code should use `constantTimeEquals`.
- `Hasher` is a value type with CoW storage. It should not be documented as
  thread-safe.
- `finalize` is idempotent and does not consume the hasher.
- `deriveKey(context:)` encodes Swift `String` as UTF-8 and calls the raw
  derive-key path. A lower-level `deriveKey(contextBytes:)` can be added if
  needed, without lossy conversion.

## Backend Design

The internal backend protocol should model the real BLAKE3 hot paths:

```swift
protocol BLAKE3Backend {
    static var kind: BLAKE3.BackendKind { get }
    static var simdDegree: Int { get }

    static func compress(
        cv: UnsafePointer<UInt32>,
        block: UnsafeRawBufferPointer,
        blockLength: UInt8,
        counter: UInt64,
        flags: UInt8,
        output: UnsafeMutablePointer<UInt32>
    )

    static func hashManyChunks(...)
    static func hashManyParents(...)
    static func xofMany(...)
}
```

Backend kinds:

```swift
extension BLAKE3 {
    public enum BackendKind: String, Sendable {
        case swiftScalar
        case cPortable
        case swiftScalar
        case swiftParallel
        case metal
    }
}
```

The public backend dispatch should prefer owned Swift implementations. Tests
must be able to force each backend through environment variables or test-only
SPI:

```text
BLAKE3_SWIFT_BACKEND=swift-scalar
BLAKE3_SWIFT_BACKEND=swift-parallel
BLAKE3_SWIFT_BACKEND=metal
BLAKE3_SWIFT_DISABLE_PARALLEL=1
```

## Native Swift Backend

The public library product must not use upstream C as a backend. The current
repository vendors upstream C only in the isolated `CBLAKE3` benchmark-support
target; upstream C/Rust should remain correctness and benchmark comparators.

Owned Swift backend layers:

- scalar compression and XOF output
- Swift tree reduction and CV-stack handling
- Swift parallel chunk and parent reduction
- Swift SIMD4 full-chunk and parent-reduction backends, with future wider lane
  backends for Apple Silicon and x86_64

Acceptance tests:

- `BLAKE3.activeBackend` reports an owned Swift backend by default.
- Official vectors pass without linking upstream C.
- A release benchmark compares against upstream `b3sum` as an external tool
  before making performance claims.

## Pure Swift Scalar Backend

The Swift scalar backend is implemented in two steps:

1. Port the reference state machine for clarity and correctness.
2. Move to production lazy merging and backend hooks after all vectors pass.

Implementation rules:

- Use `UInt32` and wrapping `&+`.
- Use little-endian loads and stores exactly.
- Avoid heap allocation in `compress`.
- Keep `G`, `round`, `compress`, and little-endian helpers internal and small.
- Add `@inline(__always)` only after measurement shows a benefit.
- Use `withUnsafeTemporaryAllocation` for temporary word and byte buffers where
  it improves allocation behavior.

The Swift scalar backend must pass the official vectors and differential tests
against external upstream tools. It is the fallback and the audit reference; the
Swift SIMD backend is the CPU large-buffer performance target.

## Streaming Buffering

Adopt internal staging in the Swift hasher wrapper:

- Default staging buffer: 16 KiB.
- File read buffer: 64 KiB.
- One-shot hash bypasses staging entirely.
- If the staging buffer is empty and the incoming update is at least 16 KiB,
  pass it directly to the backend.
- If the caller sends many small updates, accumulate until 16 KiB and then
  update the native hasher.
- On `finalize`, flush staged bytes first without consuming the public hasher.

Rationale:

- 16 KiB is enough to fill AVX-512's 16-way chunk processing.
- It also fills AVX2, SSE4.1, and NEON.
- This avoids making callers manually tune update sizes.
- It preserves fast one-shot performance by avoiding unnecessary buffering.

## Parallel Hashing

Parallelism is a separate strategy, not the default behavior of every update.

Use Dispatch rather than Swift structured concurrency for the first
performance implementation. This is CPU-bound work where lower scheduling
overhead and explicit thread caps matter.

Implement:

```swift
public enum BLAKE3Parallelism {
    case disabled
    case automatic
    case maxThreads(Int)
}
```

Parallel design:

- Split only at chunk boundaries.
- Mirror upstream `left_subtree_len`.
- Each worker hashes a whole subtree using the C SIMD subtree shims.
- Combine returned chaining values using batched parent hashing.
- Keep root handling lazy. Never compress the root until final XOF output.
- Limit parallelism to a configurable max thread count.

Threshold decisions:

- `hash(_:)` remains single-threaded by default below the measured parallel gate.
- Add `BLAKE3.hashParallel(_:parallelism:)` for in-memory data.
- `BLAKE3File.Strategy.automatic` may select mmap parallel for large regular
  files.
- Current in-memory serial SIMD array threshold: 16 KiB after Apple Silicon measurements.
- Current in-memory parallel threshold: 96 KiB after Apple Silicon measurements.
- Initial mmap-parallel file threshold: 8 MiB.
- Revisit both thresholds after benchmarks on Apple Silicon, Intel AVX2,
  Intel AVX-512, and Linux arm64.

Why not default to parallel everywhere:

- Upstream documents that parallel hashing can be slower below about 128 KiB on
  x86_64.
- Busy systems can get slower when hashing consumes all cores.
- Parallel mmap can be harmful on spinning disks due to random read patterns.

## File Hashing

File hashing must be a first-class API because it is where users most often
leave performance on the table.

Automatic strategy:

1. Non-regular files, pipes, and mapping failures: streaming read.
2. Small files below 16 KiB: read and one-shot hash.
3. Medium files: streaming read with a 64 KiB buffer.
4. Large regular files: mmap.
5. Large regular files that are likely cached or on SSD: mmap plus parallel
   tree hashing.
6. GPU-oriented applications can opt into zero-copy mapped-file hashing through
   `BLAKE3File.Strategy.metalMemoryMapped`, which wraps mapped pages in a shared
   Metal buffer and keeps that timing separate from resident-buffer claims.

Implementation details:

- Use POSIX `mmap`/`munmap` behind a safe wrapper on Apple platforms and Linux.
- Open files internally for mmap APIs rather than accepting an existing file
  descriptor whose seek position semantics would be ambiguous.
- Fall back to streaming reads on mapping failure.
- CPU mmap strategies process mapped pages in bounded tiles and feed the
  streaming CV stack, so file hashing does not retain one chunk chaining value
  per chunk for the whole file.
- Parallel CPU streaming reuses a per-hasher chunk-CV workspace and lets
  non-final mapped tiles finalize every complete chunk, avoiding the serial
  fallback that would otherwise happen after exact chunk-aligned tile
  boundaries.
- `BLAKE3File.hashAsync` keeps CPU file strategies off the caller task, checks
  cancellation around file IO and tile processing, and keeps mapped pages alive
  until async Metal hashing completes.
- `BLAKE3Metal.Context.makeAsyncPipeline` is the repeated-job Metal API. It
  preallocates bounded in-flight staging slots, a matching async workspace pool,
  and optionally a private input buffer per slot for explicit upload-to-private
  hashing.
- The Metal tile tree contract is chunk-CV based, not digest based. Metal
  chunk kernels accept a base chunk counter, tiled file hashing emits complete
  chunk CVs into a bounded shared buffer, and Swift's CV stack performs the
  canonical cross-tile reduction while preserving the final chunk as the BLAKE3
  root current chunk.
- Async tiled Metal file hashing uses the same contract with async chunk-CV
  dispatches, keeping mapped pages and the shared CV buffer alive until each
  tile command completes.
- Record strategy, file size, and backend in benchmark output.

## Metal Backend

Metal is not in the critical path for v1.0.

Only pursue Metal after CPU SIMD plus CPU parallelism meets release gates.
Prototype only these workloads:

- Very large buffers already resident in `MTLBuffer`.
- Batch hashing many independent buffers.
- GPU pipelines where the digest feeds another GPU stage.

Metal acceptance gate:

- It must beat CPU SIMD plus parallelism end-to-end for a documented workload.
- Kernel-only throughput does not count.
- It must have independent correctness tests against the CPU backend.

## Validation Plan

Correctness gates:

- Official `test_vectors.json` for hash, keyed hash, derive-key, and XOF.
- All vectors run through every backend.
- Differential tests against upstream C for deterministic random inputs.
- Differential tests across backends for the same inputs.
- Incremental update split fuzzing: byte-at-a-time, powers of two, random
  splits, and pathological splits around 64, 1024, and powers of two chunks.
- XOF tests for 0 bytes, 1 byte, 31, 32, 33, 63, 64, 65, multi-block output,
  and seek offsets.
- Keyed mode rejects non-32-byte keys.
- `deriveKey(context:)` uses UTF-8 bytes and never lossy conversion.
- Empty input and zero-length update behavior.
- Finalize idempotence.
- CoW tests: copying a hasher and updating one copy must not affect the other.

Safety gates:

- Address Sanitizer for native C backend tests.
- Thread Sanitizer for parallel Swift orchestration tests where practical.
- No out-of-bounds reads in mmap and XOF code.
- Secret-bearing state is zeroized on storage deinit through a C zeroize shim.

## Benchmark Plan

Use a dedicated benchmark executable. XCTest performance tests are not enough.

Benchmarks compare:

- `BLAKE3.hash`, default backend.
- `BLAKE3.hash`, Swift scalar forced.
- `BLAKE3.hashParallel`.
- `BLAKE3File.hash`, streaming.
- `BLAKE3File.hash`, mmap.
- `BLAKE3File.hash`, mmap parallel.
- `BLAKE3File.hash`, Metal mmap.
- Upstream `b3sum` as an external comparison, not as a package dependency.
- CryptoKit SHA-256 on Apple platforms as a familiar baseline.

Input sizes:

```text
0, 1, 8, 31, 32, 33,
63, 64, 65,
1023, 1024, 1025,
4 KiB, 8 KiB, 16 KiB, 64 KiB,
128 KiB, 256 KiB, 1 MiB,
16 MiB, 256 MiB, 1 GiB
```

Measure:

- ns/hash for small inputs.
- GiB/s for large buffers.
- allocations per operation.
- update throughput for tiny repeated writes.
- finalize and XOF throughput separately.
- cold file read, warm file read, mmap, mmap parallel, and Metal mmap separately.
- active backend and SIMD degree.
- CPU model, OS, Swift version, Clang version, optimization flags, and thermal
  state.

Benchmark rules:

- Release builds only.
- Use `-O` and whole-module optimization for Swift benchmark runs.
- Warm up before timing.
- Use deterministic non-zero data.
- Report medians and p95, not best run.
- Store machine-readable JSON results for performance regression tracking.

## Release Gates

Correctness:

- 100 percent official vector pass rate on every backend.
- 100,000 deterministic random differential cases pass against C.
- All incremental split fuzzing passes.
- Sanitizers pass on supported local configurations.

Performance:

- Default one-shot hash for inputs >= 1 MiB is within 5 percent of the direct
  upstream C shim on the same machine.
- Streaming update with 64 KiB chunks is within 10 percent of direct upstream C.
- Streaming update with 1-byte chunks is at least 3x faster with staging than
  without staging.
- Large warm-file hashing is within 10 percent of upstream `b3sum` when using
  mmap parallel on comparable settings.
- No heap allocation in one-shot digest creation beyond unavoidable caller
  bridging.
- No per-update allocation after hasher staging storage is initialized.

Packaging:

- macOS arm64 passes with NEON.
- macOS x86_64 passes with x86 SIMD where available.
- Linux x86_64 passes with x86 SIMD where available.
- Linux arm64 passes with NEON where available.
- Portable fallback passes with SIMD disabled.
- Package includes upstream licenses and pinned revision.

## Roadmap

### Phase 0: Package, Vendor, and Harness

Deliverables:

- SwiftPM package skeleton.
- Vendored upstream C `1.8.4` with license files and `UPSTREAM.md`.
- C shim for one-shot hash, keyed hash, derive-key raw, backend name, SIMD
  degree, and zeroize.
- Official test vectors imported as test resources.
- Benchmark executable and upstream comparison script.

Exit criteria:

- `swift test` passes against C portable.
- Benchmarks run and produce JSON.
- Direct upstream C comparison is automated.

### Phase 1: Correct Pure Swift Scalar

Deliverables:

- Pure Swift compression function.
- Reference-style `ChunkState`, `Output`, `OutputReader`, and scalar hasher.
- All official vectors pass.
- Differential tests compare Swift scalar to C backend.

Exit criteria:

- Scalar Swift is correct for all modes and XOF.
- No heap allocation inside scalar `compress`.

### Phase 2: Public API and CoW State

Deliverables:

- `BLAKE3`, `BLAKE3.Digest`, `BLAKE3.Hasher`, and `BLAKE3.OutputReader`.
- Inline digest storage.
- Constant-time comparison.
- Lowercase hex formatting.
- CoW hasher state box.
- Reset support.

Exit criteria:

- API tests cover copying, reset, finalize idempotence, and XOF seek.
- Existing C backend and Swift scalar backend are selectable in tests.

### Phase 3: Native SIMD Packaging

Deliverables:

- NEON enabled on AArch64.
- x86_64 Unix assembly integrated for SSE2, SSE4.1, AVX2, and AVX-512.
- `activeBackend` and `simdDegree` verified in tests.
- Portable-only forced test mode.

Exit criteria:

- Apple Silicon reports NEON.
- x86_64 capable machines report their best available backend.
- 1 MiB hash performance is within 5 percent of direct upstream C.

### Phase 4: Production Tree Internals

Deliverables:

- Swift scalar moves from reference eager merging to production lazy merging.
- Internal backend hooks for `hashManyChunks`, `hashManyParents`, and
  `xofMany`.
- C shims for subtree-wide and parent batching.

Exit criteria:

- Tree-shape differential tests pass.
- Parent batching is visible in benchmarks.

### Phase 5: Streaming Staging Buffer

Deliverables:

- 16 KiB staging in `BLAKE3.Hasher`.
- Direct pass-through for large updates.
- One-shot hash bypasses staging.
- Allocation tests for repeated updates.

Exit criteria:

- Small repeated updates improve materially.
- Large one-shot hashes do not regress.
- No per-update allocation after initialization.

### Phase 6: Parallel In-Memory Hashing

Deliverables:

- `BLAKE3.hashParallel`.
- Dispatch-backed worker orchestration.
- Configurable max thread count.
- Benchmarked initial threshold.

Exit criteria:

- Large in-memory hashing approaches upstream `update_rayon` or C TBB
  performance without adding TBB as a default dependency.
- Parallelism is never selected below the benchmarked threshold.

### Phase 7: File Hashing

Deliverables:

- `BLAKE3File.hash`.
- Streaming, mmap, and mmap-parallel strategies.
- Automatic strategy.
- Safe mmap wrapper.

Exit criteria:

- Warm large-file performance is within 10 percent of `b3sum` in comparable
  settings.
- Mapping failure falls back correctly.
- Non-regular files use streaming reads.

### Phase 8: SwiftCrypto Compatibility

Deliverables:

- Separate `Blake3Crypto` target.
- `HashFunction` conformance where dependency is available.
- Interop tests with SwiftCrypto-style usage.

Exit criteria:

- Core package stays dependency-light.
- Compatibility target works without changing core API behavior.

### Phase 9: Platform Expansion

Deliverables:

- Linux arm64 CI.
- Windows build plan and implementation.
- Swift Package Index compatibility review.
- Documentation for supported backend matrix.

Exit criteria:

- Supported platforms are explicit.
- Unsupported optimized paths fall back to portable code, not build failure.

### Phase 10: Metal Experiment

Deliverables:

- Experimental `BLAKE3Metal` target if benchmarks justify it.
- `MTLBuffer` batch hashing prototype.
- End-to-end CPU comparison.

Exit criteria:

- Keep Metal only if it wins a documented real workload.

## Documentation

The package documentation must include:

- BLAKE3 is not a password hashing algorithm.
- Keyed mode requires a uniformly random 32-byte key.
- KDF context strings should be hardcoded, globally unique, and
  application-specific.
- Output lengths shorter than 32 bytes reduce security.
- Longer XOF outputs do not increase collision or preimage security beyond the
  default security level.
- Parallel hashing can be slower for small inputs or busy systems.
- Mmap parallel hashing can be bad for spinning disks.
- `activeBackend` is diagnostic, not a stable security boundary.

## Source Links

- Official BLAKE3 repository: https://github.com/BLAKE3-team/BLAKE3
- BLAKE3 Rust docs: https://docs.rs/blake3/
- LLVM vendored BLAKE3 README: https://llvm.org/doxygen/md_lib_Support_BLAKE3_README.html
- Go implementation: https://github.com/zeebo/blake3
- Blake3.NET: https://github.com/xoofx/Blake3.NET
- Apache Commons Codec Blake3: https://commons.apache.org/proper/commons-codec/apidocs/org/apache/commons/codec/digest/Blake3.html
- Crypto++ Modern BLAKE3 notes: https://cryptopp-modern.com/docs/algorithms/blake3/
