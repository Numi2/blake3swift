# World-Class BLAKE3 Swift Implementation Plan

This plan targets performance parity with the official BLAKE3 C/Rust
implementations while keeping a clean Swift API. The current upstream baseline is
BLAKE3 `1.8.4` (`b97a24f`, released 2026-03-30).

## Research Summary

Primary findings:

- BLAKE3 performance comes from both SIMD lane parallelism and tree-level
  parallelism. The algorithm is specifically designed to scale across SIMD lanes
  and CPU cores.
- The official Rust crate includes optimized backends for SSE2, SSE4.1, AVX2,
  AVX-512, NEON, and WASM SIMD, plus optional Rayon multithreading.
- The official C implementation includes SIMD dispatch, AArch64 NEON by
  default, optional oneTBB multithreading, and mmap examples for file hashing.
- Upstream notes that multithreading is often slower below roughly 128 KiB on
  x86_64, and that this threshold varies by CPU and workload.
- Existing Swift packages are mainly wrappers around upstream C. They are useful
  API references, but they are not enough as a performance architecture. Their
  simple C aggregation layer disables x86 SIMD backends unless the whole target
  is built with the corresponding CPU features.

Important upstream facts to preserve:

- `BLOCK_LEN = 64`, `CHUNK_LEN = 1024`, `OUT_LEN = 32`.
- SIMD degrees: portable = 1, SSE2/SSE4.1 = 4, NEON = 4, AVX2 = 8,
  AVX-512 = 16.
- Parent-node hashing is also vectorized upstream, not only leaf chunk hashing.
- The production implementation uses lazy merging to avoid compressing a node
  that may become the root.
- XOF output should batch full 64-byte output blocks where possible.

## Performance Goal

The top-level goal is not "fast for Swift"; it is "competitive with upstream
BLAKE3 on the same machine."

Targets:

- Large in-memory buffers: within 5-10% of upstream C/Rust on Apple Silicon and
  modern x86_64 after the native backend lands.
- Large files already in cache: match upstream mmap-plus-parallel behavior as
  closely as Swift platform APIs allow.
- Small inputs: minimize overhead. A C call boundary can dominate very small
  hashes, so the scalar Swift path remains valuable.
- Pure Swift fallback: correct, portable, and reasonably fast, but not the
  primary path for peak throughput.

Non-goals for the first peak-performance release:

- Beating upstream hand-tuned assembly.
- Making Metal the default backend.
- Supporting every possible embedded Swift target with the same performance
  envelope.

## Architecture

Use a tiered backend model.

```text
Public Swift API
  |
  +-- Hasher state and API ergonomics
  |
  +-- Backend dispatcher
        |
        +-- SwiftScalarBackend
        +-- CPortableBackend
        +-- CSimdBackend
        +-- ParallelTreeBackend
        +-- MetalBackend, experimental only
```

The backend abstraction should expose low-level operations, not only a one-shot
hash function:

```swift
protocol Blake3Backend {
    static var simdDegree: Int { get }
    static func compressInPlace(...)
    static func compressXOF(...)
    static func hashManyChunks(...)
    static func hashManyParents(...)
    static func xofMany(...)
}
```

This matters because world-class BLAKE3 needs vectorized chunk hashing,
vectorized parent hashing, and batched XOF generation.

## Public API Design

Keep the default API idiomatic and allocation-conscious:

```swift
public enum Blake3 {
    public static func hash(_ input: some ContiguousBytes) -> Blake3Digest
    public static func keyedHash(key: some ContiguousBytes, input: some ContiguousBytes) throws -> Blake3Digest
    public static func deriveKey(context: String, material: some ContiguousBytes) -> Blake3Digest
}

public struct Blake3Hasher: Sendable {
    public init()
    public init(key: some ContiguousBytes) throws
    public init(deriveKeyContext context: String)
    public mutating func update(_ input: some ContiguousBytes)
    public mutating func update(bufferPointer: UnsafeRawBufferPointer)
    public func finalize() -> Blake3Digest
    public func finalizeXOF() -> Blake3OutputReader
}
```

Add performance-specific APIs:

```swift
public enum Blake3FileHashing {
    public static func hashFile(at path: FilePath, strategy: FileHashStrategy) throws -> Blake3Digest
}

public enum FileHashStrategy {
    case automatic
    case read(bufferSize: Int)
    case memoryMapped
    case memoryMappedParallel
}
```

Digest representation should avoid heap allocation:

- Store 32 bytes inline, not as `[UInt8]`.
- Provide `withUnsafeBytes`.
- Provide lowercase hex without intermediate `Data`.
- Implement a separate `constantTimeEquals`; do not rely on `Equatable` for MAC
  verification.

Hasher state should use copy-on-write if exposed as a value type, because the C
hasher is around 1.9 KiB and accidental struct copies are expensive.

## Backend Strategy

### 1. Swift Scalar Backend

Purpose:

- Correctness oracle inside this package.
- Portable fallback.
- Potentially lowest-latency path for tiny inputs if benchmarks prove C call
  overhead dominates.

Implementation notes:

- Port the reference implementation first, then migrate to the production
  algorithm's lazy merging.
- Use `UInt32` and wrapping `&+`.
- Use fixed-size storage or stack allocation for hot arrays.
- Avoid `[UInt8]` allocations in compression.
- Mark hot internal functions `@inlinable` or `@usableFromInline` only after
  measuring; do not spray attributes blindly.

Expected limit:

- This path will not be world-class for large buffers unless Swift's optimizer
  emits code close to the C portable path. Treat it as a baseline and fallback.

### 2. Official C Backend

Purpose:

- Primary path for peak single-threaded SIMD performance.
- Also gives a known-good benchmark target while Swift internals are evolving.

Packaging requirements:

- Vendor the official C sources at a pinned upstream revision.
- Keep license files and upstream revision recorded.
- Build AArch64 with NEON enabled.
- Build x86_64 SIMD variants without requiring the entire Swift package to be
  compiled for AVX2 or AVX-512.

The last point needs a packaging spike. The naive SwiftPM pattern of including
`blake3_avx2.c` in the same C target does not by itself compile that file with
`-mavx2`. A world-class package needs one of these:

- Separate C targets per ISA with target-specific unsafe flags.
- Assembly source integration for macOS/Linux x86_64 where SwiftPM can build it
  reliably.
- A small CMake-backed build helper if SwiftPM cannot express the file-level
  flags cleanly.
- Clang target attributes or pragmas around included upstream files, if proven
  reliable across supported compilers.

Acceptance rule:

- Runtime dispatch must report and actually use NEON on arm64, SSE4.1/AVX2 on
  x86_64 where available, and AVX-512 where available and beneficial.

### 3. Swift Parallel Tree Backend

Purpose:

- Match Rust `update_rayon` and C oneTBB behavior without forcing C++/TBB into
  the Swift package.

Design:

- Use the production tree algorithm: `compressSubtreeWide`,
  `compressSubtreeToParentNode`, lazy stack merging, and batched parent hashing.
- Use Swift concurrency or Dispatch for large in-memory inputs.
- Keep the splitting function deterministic and byte-for-byte equivalent to
  upstream.
- Use C SIMD `hash_many` for leaf and parent batches from Swift, or a native
  backend if it reaches parity.

Thresholds:

- Do not parallelize small buffers. Start with a conservative automatic
  threshold of 256 KiB or 1 MiB, then tune.
- Benchmark against upstream's 128 KiB rule of thumb and choose per-platform
  defaults from data.

### 4. File Hashing Backend

Large-file performance is often IO-bound before it is hash-bound. The package
should expose a deliberate file API rather than forcing callers to choose poorly.

Automatic strategy:

- Small files: read into a stack or heap buffer and hash serially.
- Medium files: read with a wide reusable buffer, probably 64 KiB or larger.
- Large regular files: memory map where available.
- Large mapped files on SSD/cache: parallel tree hashing.
- Spinning disks or unknown slow storage: avoid random-read parallelism unless
  explicitly requested.

Implementation detail:

- On Apple platforms, use `mmap`/`munmap` behind a safe wrapper for regular
  files.
- On Linux, same API with POSIX `mmap`.
- Fall back to streaming reads for virtual files, pipes, and mapping failures.

### 5. Metal Backend

Metal is not the first route to world-class BLAKE3 on normal files or byte
buffers. CPU SIMD has no device-transfer overhead and BLAKE3 is already designed
for CPU vector lanes.

Treat Metal as experimental and only pursue it for:

- Very large buffers already resident in `MTLBuffer`.
- Batch hashing many independent large inputs.
- Pipelines where the digest feeds another GPU stage.

Metal acceptance rule:

- It must beat the CPU SIMD-plus-parallel backend end-to-end, including command
  encoding, synchronization, and buffer movement. Kernel-only wins do not count.

## Benchmark Plan

Create a dedicated benchmark executable, not only XCTest performance tests.

Compare:

- This package, Swift scalar.
- This package, C portable.
- This package, C SIMD.
- This package, parallel.
- Upstream `b3sum`.
- Upstream C example.
- Existing Swift C wrapper packages as reference points.
- CryptoKit SHA-256 as a familiar baseline on Apple platforms.

Input sizes:

```text
0, 1, 8, 63, 64, 65,
1023, 1024, 1025,
4 KiB, 16 KiB, 64 KiB, 128 KiB, 256 KiB,
1 MiB, 16 MiB, 256 MiB, 1 GiB
```

Measure:

- ns/hash for tiny inputs.
- GB/s for buffers.
- bytes/cycle where CPU counters are available.
- allocations per hash.
- peak RSS for file hashing.
- thread count and CPU utilization.
- cold file read, warm file read, mmap, and mmap-parallel separately.

Benchmark rules:

- Release builds only.
- Warm up before timing.
- Pin or record CPU model, OS, compiler, optimization flags, and thermal state.
- Use random-looking deterministic data, not all zeros only.
- Report medians and tail latency, not just best run.

## Validation Plan

Correctness must be backend-independent:

- Official test vectors for `hash`, `keyed_hash`, and `derive_key`.
- XOF vectors beyond 32 bytes.
- Differential tests against upstream C for random lengths and random update
  splits.
- Differential tests across every backend.
- Fuzz update chunking: one-shot, byte-at-a-time, powers of two, random splits.
- Test all tree boundaries: 64, 65, 1024, 1025, powers of two chunks, and
  non-power-of-two chunk counts.
- Test XOF seek/offset behavior.
- Test zero-length update and zero-length XOF fill.

CI should run:

- macOS arm64.
- macOS x86_64 if available.
- Linux x86_64.
- Linux arm64 if available.
- Debug and release correctness tests.
- Release benchmark smoke tests with performance regression thresholds.

## Implementation Phases

### Phase 0: Baseline Harness

- Add SwiftPM package skeleton.
- Add upstream C backend in the simplest portable form.
- Add official vectors.
- Add benchmark executable.
- Capture baseline numbers from upstream `b3sum` and upstream C.

Deliverable:

- A table showing where we stand before custom optimization.

### Phase 1: Correct Pure Swift Scalar

- Implement reference-style Swift scalar BLAKE3.
- Pass all vectors and differential tests.
- Keep the scalar backend simple and auditable.

Deliverable:

- Correct pure Swift implementation with known performance gap.

### Phase 2: Production Tree Algorithm

- Replace eager reference stack merging with production lazy merging.
- Implement `compressSubtreeWide` and `compressSubtreeToParentNode`.
- Add `hashManyChunks`, `hashManyParents`, and `xofMany` hooks.

Deliverable:

- Same tree shape as upstream production code.

### Phase 3: SIMD C Backend Done Properly

- Solve SwiftPM packaging for per-ISA C/assembly.
- Enable NEON on Apple Silicon and arm64 Linux.
- Enable SSE2/SSE4.1/AVX2/AVX-512 runtime dispatch on x86_64.
- Verify selected backend at runtime in tests.

Deliverable:

- Single-threaded throughput close to upstream C.

### Phase 4: Parallel Hashing

- Add large-buffer parallel hashing with Swift concurrency or Dispatch.
- Tune thresholds per platform.
- Avoid parallelism for small buffers and busy systems.

Deliverable:

- Large-buffer throughput close to `b3sum`/Rust Rayon.

### Phase 5: File API

- Add read-buffer, mmap, and mmap-parallel strategies.
- Implement automatic strategy.
- Benchmark warm/cold files and storage types.

Deliverable:

- File hashing that is hard for application users to misuse.

### Phase 6: API Polish and Crypto Ergonomics

- Add `SwiftCrypto.HashFunction` conformance as an optional target or feature.
- Add constant-time digest comparison.
- Add hex parsing/formatting.
- Add Sendable and COW behavior tests.
- Document keyed-hash and derive-key constraints.

Deliverable:

- A production-grade Swift package API.

### Phase 7: Metal Experiment

- Build only after CPU backend is measured.
- Start with one-shot large `MTLBuffer` hashing.
- Compare end-to-end against CPU, not kernel-only.

Deliverable:

- Keep only if it wins in real workflows.

## Design Decisions

- The owned Swift backend is the primary CPU path. Upstream C/Rust remain
  external comparators, not vendored package dependencies.
- Swift SIMD is required for CPU peak throughput, portability, auditability, and
  low-overhead experimentation.
- Runtime dispatch and parallel thresholds must be benchmark-driven.
- Metal is an optional specialized backend, not the default performance plan.
- The public API must hide backend complexity while still exposing explicit file
  and parallel strategies for advanced users.
