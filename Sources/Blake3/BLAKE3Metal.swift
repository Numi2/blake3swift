#if canImport(Metal)
import Darwin
import Foundation
import Metal

/// Metal-backed BLAKE3 hashing APIs.
///
/// Resident-buffer APIs expose hashing when data is already in an `MTLBuffer`.
/// Staging, private-buffer, async pipeline, and file APIs make ownership and transfer costs explicit
/// so benchmarks can keep resident, end-to-end, and repeated-call timing classes separate.
public enum BLAKE3Metal {
    /// Backend selection policy for Metal-capable hash calls.
    public enum ExecutionPolicy: Equatable, Sendable {
        /// Uses CPU below the context threshold and GPU for larger inputs.
        case automatic
        /// Forces the CPU fallback path through the same API surface.
        case cpu
        /// Forces Metal execution and throws if Metal work cannot be encoded or completed.
        case gpu
    }

    /// Default byte threshold for automatic GPU selection.
    public static let defaultMinimumGPUByteCount = 16 * 1024 * 1024

    /// Default number of pooled resources used by async Metal helpers.
    public static let defaultAsyncInflightCommandCount = 3

    /// Metal kernel source used by the runtime compiler fallback.
    ///
    /// Integrators can write this source to a `.metal` file and compile it into a `.metallib`, then pass
    /// that file through ``LibrarySource/metallib(_:)`` when creating a context.
    public static var kernelSource: String {
        BLAKE3MetalKernelSource.chunkCVs
    }
    private static let wideParentReductionThreshold = 512 * 1024
    private static let quadParentReductionThreshold = 32 * 1024
    private static let combinedPrivateStagedMaxBytes = 16 * 1024 * 1024
    private static let largeGridThreadThreshold = 1024 * 1024
    private static let smallGridSIMDGroupsPerThreadgroup = 8
    private static let largeGridSIMDGroupsPerThreadgroup = 4
    private static let writeCombinedOwnedSharedBufferMaxBytes = 128 * 1024 * 1024
    private static let ownedSharedUploadFusedTileMaxBytes = 128 * 1024 * 1024
    private static let fusedTileChunkCount = configuredFusedTileChunkCount()
    private static let fusedTileReductionStrategy = configuredFusedTileReductionStrategy()

    private static let defaultDevice = BLAKE3MetalDeviceReference(MTLCreateSystemDefaultDevice())
    private static let contextCache = BLAKE3MetalContextCache()

    fileprivate final class CrossThreadResourceLock: @unchecked Sendable {
        private let semaphore = DispatchSemaphore(value: 1)

        func lock() {
            semaphore.wait()
        }

        func unlock() {
            semaphore.signal()
        }
    }

    struct HashMode: Sendable {
        let key: BLAKE3Core.ChainingValue
        let flags: UInt32

        static let unkeyed = HashMode(key: BLAKE3Core.iv, flags: 0)

        var isUnkeyedDigestFastPathEligible: Bool {
            flags == 0 && key == BLAKE3Core.iv
        }

        var metalKey: BLAKE3MetalKeyWords {
            BLAKE3MetalKeyWords(key)
        }
    }

    enum HashCommandFamily: Equatable {
        case digestOnly
        case generic
    }

    /// Source for Metal kernel library creation.
    public enum LibrarySource: Equatable, Sendable {
        /// Compile the built-in Metal source string at runtime.
        case runtimeSource
        /// Load precompiled kernels from a `.metallib` file.
        case metallib(URL)
    }

    /// Whether a system default Metal device was available when the module initialized.
    public static var isAvailable: Bool {
        defaultDevice.device != nil
    }

    /// Name of the system default Metal device, if available.
    public static var deviceName: String? {
        defaultDevice.device?.name
    }

    /// Creates a reusable Metal context.
    ///
    /// The context owns pipeline state, a command queue, and reusable scratch resources. Pass a
    /// precompiled `.metallib` URL to avoid runtime `makeLibrary(source:)` startup cost in production.
    public static func makeContext(
        device: MTLDevice? = MTLCreateSystemDefaultDevice(),
        minimumGPUByteCount: Int = defaultMinimumGPUByteCount,
        librarySource: LibrarySource = .runtimeSource
    ) throws -> Context {
        guard let device else {
            throw BLAKE3Error.metalUnavailable
        }
        return try Context(
            device: device,
            minimumGPUByteCount: minimumGPUByteCount,
            librarySource: librarySource
        )
    }

    static func cachedContext(
        device: MTLDevice,
        minimumGPUByteCount: Int = defaultMinimumGPUByteCount,
        librarySource: LibrarySource = .runtimeSource
    ) throws -> Context {
        try contextCache.context(
            device: device,
            minimumGPUByteCount: minimumGPUByteCount,
            librarySource: librarySource
        )
    }

    /// Hashes a resident Metal buffer.
    ///
    /// The buffer must remain valid until the synchronous call returns. With `.gpu`, timing belongs to the
    /// resident class: no Swift input allocation or upload is included.
    public static func hash(
        buffer: MTLBuffer,
        length: Int,
        policy: ExecutionPolicy = .automatic
    ) throws -> BLAKE3.Digest {
        try hash(buffer: buffer, range: 0..<length, policy: policy)
    }

    /// Hashes a range of a resident Metal buffer.
    public static func hash(
        buffer: MTLBuffer,
        range: Range<Int>,
        policy: ExecutionPolicy = .automatic
    ) throws -> BLAKE3.Digest {
        try contextCache.context(device: buffer.device).hash(
            buffer: buffer,
            range: range,
            policy: policy
        )
    }

    /// Hashes many independent resident-buffer ranges that each fit in one BLAKE3 chunk.
    ///
    /// This batching path is optimized for object sets with many small inputs. Every range must be inside
    /// `buffer` and contain at most ``BLAKE3/chunkByteCount`` bytes.
    public static func hashOneChunkBatch(
        buffer: MTLBuffer,
        ranges: [Range<Int>]
    ) throws -> [BLAKE3.Digest] {
        try contextCache.context(device: buffer.device).hashOneChunkBatch(buffer: buffer, ranges: ranges)
    }

    /// Builds a reusable plan for hashing stable one-chunk ranges in a resident Metal buffer.
    public static func makeOneChunkBatchPlan(
        buffer: MTLBuffer,
        ranges: [Range<Int>]
    ) throws -> OneChunkBatchPlan {
        try contextCache.context(device: buffer.device).makeOneChunkBatchPlan(buffer: buffer, ranges: ranges)
    }

    /// Hashes all ranges in a reusable one-chunk resident-buffer batch plan.
    public static func hashOneChunkBatch(plan: OneChunkBatchPlan) throws -> [BLAKE3.Digest] {
        try contextCache.context(device: plan.buffer.device).hashOneChunkBatch(plan: plan)
    }

    /// Builds a benchmark-only command pipeline for repeated plan digest writes.
    @_spi(Benchmark)
    public static func makeOneChunkBatchWritePipeline(
        plan: OneChunkBatchPlan,
        outputBuffers: [MTLBuffer]
    ) throws -> OneChunkBatchWritePipeline {
        try contextCache.context(device: plan.buffer.device).makeOneChunkBatchWritePipeline(
            plan: plan,
            outputBuffers: outputBuffers
        )
    }

    /// Writes plan digests into all pipeline output buffers, committing all command buffers before waiting.
    @_spi(Benchmark)
    @discardableResult
    public static func writeOneChunkBatchDigests(
        pipeline: OneChunkBatchWritePipeline
    ) throws -> Int {
        try contextCache.context(device: pipeline.plan.buffer.device).writeOneChunkBatchDigests(
            pipeline: pipeline
        )
    }

    /// Builds a benchmark-only command pipeline for repeated plan writes plus output hashing.
    @_spi(Benchmark)
    public static func makeOneChunkBatchChainedPipeline(
        plan: OneChunkBatchPlan,
        outputBuffers: [MTLBuffer]
    ) throws -> OneChunkBatchChainedPipeline {
        try contextCache.context(device: plan.buffer.device).makeOneChunkBatchChainedPipeline(
            plan: plan,
            outputBuffers: outputBuffers
        )
    }

    /// Writes plan digests into all chained-pipeline output buffers and returns the last output digest.
    @_spi(Benchmark)
    public static func writeOneChunkBatchDigestsAndHashOutput(
        pipeline: OneChunkBatchChainedPipeline
    ) throws -> BLAKE3.Digest {
        try contextCache.context(device: pipeline.plan.buffer.device).writeOneChunkBatchDigestsAndHashOutput(
            pipeline: pipeline
        )
    }

    /// Writes one digest per independent one-chunk resident-buffer range into `outputBuffer`.
    ///
    /// `outputBuffer` must have capacity for `ranges.count * BLAKE3.digestByteCount` bytes.
    @discardableResult
    public static func writeOneChunkBatchDigests(
        buffer: MTLBuffer,
        ranges: [Range<Int>],
        into outputBuffer: MTLBuffer
    ) throws -> Int {
        try contextCache.context(device: buffer.device).writeOneChunkBatchDigests(
            buffer: buffer,
            ranges: ranges,
            into: outputBuffer
        )
    }

    /// Writes one digest per range in a reusable one-chunk batch plan into `outputBuffer`.
    @discardableResult
    public static func writeOneChunkBatchDigests(
        plan: OneChunkBatchPlan,
        into outputBuffer: MTLBuffer
    ) throws -> Int {
        try contextCache.context(device: plan.buffer.device).writeOneChunkBatchDigests(
            plan: plan,
            into: outputBuffer
        )
    }

    /// Writes one digest per independent one-chunk range and returns a digest of the produced digest bytes.
    public static func writeOneChunkBatchDigestsAndHashOutput(
        buffer: MTLBuffer,
        ranges: [Range<Int>],
        into outputBuffer: MTLBuffer
    ) throws -> BLAKE3.Digest {
        try contextCache.context(device: buffer.device).writeOneChunkBatchDigestsAndHashOutput(
            buffer: buffer,
            ranges: ranges,
            into: outputBuffer
        )
    }

    /// Writes plan digests and returns a digest of the produced digest bytes.
    public static func writeOneChunkBatchDigestsAndHashOutput(
        plan: OneChunkBatchPlan,
        into outputBuffer: MTLBuffer
    ) throws -> BLAKE3.Digest {
        try contextCache.context(device: plan.buffer.device).writeOneChunkBatchDigestsAndHashOutput(
            plan: plan,
            into: outputBuffer
        )
    }

    /// Returns a digest of the concatenated per-range digest bytes without materializing them on the CPU.
    public static func hashOneChunkBatchDigestBytes(
        buffer: MTLBuffer,
        ranges: [Range<Int>]
    ) throws -> BLAKE3.Digest {
        try contextCache.context(device: buffer.device).hashOneChunkBatchDigestBytes(
            buffer: buffer,
            ranges: ranges
        )
    }

    /// Returns a digest of the concatenated plan digest bytes without materializing them on the CPU.
    public static func hashOneChunkBatchDigestBytes(plan: OneChunkBatchPlan) throws -> BLAKE3.Digest {
        try contextCache.context(device: plan.buffer.device).hashOneChunkBatchDigestBytes(plan: plan)
    }

    /// Hashes a resident Metal buffer and returns `outputByteCount` bytes of BLAKE3 XOF output.
    public static func hash(
        buffer: MTLBuffer,
        length: Int,
        outputByteCount: Int,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic
    ) throws -> [UInt8] {
        try hash(
            buffer: buffer,
            range: 0..<length,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy
        )
    }

    /// Hashes a resident Metal buffer range and returns `outputByteCount` bytes of BLAKE3 XOF output.
    public static func hash(
        buffer: MTLBuffer,
        range: Range<Int>,
        outputByteCount: Int,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic
    ) throws -> [UInt8] {
        try contextCache.context(device: buffer.device).hash(
            buffer: buffer,
            range: range,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy
        )
    }

    /// Writes BLAKE3 XOF output for a resident Metal buffer into `outputBuffer`.
    ///
    /// `outputBuffer` must have capacity for `outputByteCount` bytes.
    @discardableResult
    public static func writeXOF(
        buffer: MTLBuffer,
        length: Int,
        outputByteCount: Int,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic,
        into outputBuffer: MTLBuffer
    ) throws -> Int {
        try writeXOF(
            buffer: buffer,
            range: 0..<length,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy,
            into: outputBuffer
        )
    }

    /// Writes BLAKE3 XOF output for a resident Metal buffer range into `outputBuffer`.
    @discardableResult
    public static func writeXOF(
        buffer: MTLBuffer,
        range: Range<Int>,
        outputByteCount: Int,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic,
        into outputBuffer: MTLBuffer
    ) throws -> Int {
        try contextCache.context(device: buffer.device).writeXOF(
            buffer: buffer,
            range: range,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy,
            into: outputBuffer
        )
    }

    /// Hashes Swift-owned contiguous input by temporarily wrapping it in a shared Metal buffer.
    ///
    /// The synchronous call waits for GPU completion before returning, so the wrapped pointer remains valid
    /// for the whole Metal command lifetime. Use staging or private-buffer APIs when work must outlive this call.
    public static func hash(
        input: some ContiguousBytes,
        policy: ExecutionPolicy = .automatic
    ) throws -> BLAKE3.Digest {
        try input.withUnsafeBytes { raw in
            try hash(input: raw, policy: policy)
        }
    }

    /// Hashes Swift-owned raw input by temporarily wrapping it in a shared Metal buffer.
    ///
    /// The synchronous call waits for GPU completion before returning, so the wrapped pointer remains valid
    /// for the whole Metal command lifetime.
    public static func hash(
        input: UnsafeRawBufferPointer,
        policy: ExecutionPolicy = .automatic
    ) throws -> BLAKE3.Digest {
        guard let device = defaultDevice.device else {
            throw BLAKE3Error.metalUnavailable
        }
        return try contextCache.context(device: device).hash(input: input, policy: policy)
    }

    /// Hashes Swift-owned contiguous input and returns `outputByteCount` bytes of BLAKE3 XOF output.
    public static func hash(
        input: some ContiguousBytes,
        outputByteCount: Int,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic
    ) throws -> [UInt8] {
        try input.withUnsafeBytes { raw in
            try hash(input: raw, outputByteCount: outputByteCount, seek: seek, policy: policy)
        }
    }

    /// Hashes Swift-owned raw input and returns `outputByteCount` bytes of BLAKE3 XOF output.
    public static func hash(
        input: UnsafeRawBufferPointer,
        outputByteCount: Int,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic
    ) throws -> [UInt8] {
        guard let device = defaultDevice.device else {
            throw BLAKE3Error.metalUnavailable
        }
        return try contextCache.context(device: device).hash(
            input: input,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy
        )
    }

    /// Computes keyed BLAKE3 hashes for many independent resident-buffer ranges that each fit in one chunk.
    public static func keyedHashOneChunkBatch(
        key: some ContiguousBytes,
        buffer: MTLBuffer,
        ranges: [Range<Int>]
    ) throws -> [BLAKE3.Digest] {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try contextCache.context(device: buffer.device).hashOneChunkBatch(
                buffer: buffer,
                ranges: ranges,
                mode: mode
            )
        }
    }

    /// Computes keyed BLAKE3 hashes for all ranges in a reusable one-chunk batch plan.
    public static func keyedHashOneChunkBatch(
        key: some ContiguousBytes,
        plan: OneChunkBatchPlan
    ) throws -> [BLAKE3.Digest] {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try contextCache.context(device: plan.buffer.device).hashOneChunkBatch(
                plan: plan,
                mode: mode
            )
        }
    }

    /// Writes keyed BLAKE3 digests for many independent one-chunk ranges into `outputBuffer`.
    @discardableResult
    public static func writeKeyedOneChunkBatchDigests(
        key: some ContiguousBytes,
        buffer: MTLBuffer,
        ranges: [Range<Int>],
        into outputBuffer: MTLBuffer
    ) throws -> Int {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try contextCache.context(device: buffer.device).writeOneChunkBatchDigests(
                buffer: buffer,
                ranges: ranges,
                into: outputBuffer,
                mode: mode
            )
        }
    }

    /// Writes keyed BLAKE3 digests for a reusable one-chunk batch plan into `outputBuffer`.
    @discardableResult
    public static func writeKeyedOneChunkBatchDigests(
        key: some ContiguousBytes,
        plan: OneChunkBatchPlan,
        into outputBuffer: MTLBuffer
    ) throws -> Int {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try contextCache.context(device: plan.buffer.device).writeOneChunkBatchDigests(
                plan: plan,
                into: outputBuffer,
                mode: mode
            )
        }
    }

    /// Writes keyed BLAKE3 digests for one-chunk ranges and returns a digest of the produced digest bytes.
    public static func writeKeyedOneChunkBatchDigestsAndHashOutput(
        key: some ContiguousBytes,
        buffer: MTLBuffer,
        ranges: [Range<Int>],
        into outputBuffer: MTLBuffer
    ) throws -> BLAKE3.Digest {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try contextCache.context(device: buffer.device).writeOneChunkBatchDigestsAndHashOutput(
                buffer: buffer,
                ranges: ranges,
                into: outputBuffer,
                mode: mode
            )
        }
    }

    /// Writes keyed plan digests and returns a digest of the produced digest bytes.
    public static func writeKeyedOneChunkBatchDigestsAndHashOutput(
        key: some ContiguousBytes,
        plan: OneChunkBatchPlan,
        into outputBuffer: MTLBuffer
    ) throws -> BLAKE3.Digest {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try contextCache.context(device: plan.buffer.device).writeOneChunkBatchDigestsAndHashOutput(
                plan: plan,
                into: outputBuffer,
                mode: mode
            )
        }
    }

    /// Returns a digest of the concatenated keyed per-range digest bytes without materializing them on the CPU.
    public static func hashKeyedOneChunkBatchDigestBytes(
        key: some ContiguousBytes,
        buffer: MTLBuffer,
        ranges: [Range<Int>]
    ) throws -> BLAKE3.Digest {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try contextCache.context(device: buffer.device).hashOneChunkBatchDigestBytes(
                buffer: buffer,
                ranges: ranges,
                mode: mode
            )
        }
    }

    /// Returns a digest of the concatenated keyed plan digest bytes without materializing them on the CPU.
    public static func hashKeyedOneChunkBatchDigestBytes(
        key: some ContiguousBytes,
        plan: OneChunkBatchPlan
    ) throws -> BLAKE3.Digest {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try contextCache.context(device: plan.buffer.device).hashOneChunkBatchDigestBytes(
                plan: plan,
                mode: mode
            )
        }
    }

    /// Computes a 32-byte keyed BLAKE3 hash for Swift-owned contiguous input.
    public static func keyedHash(
        key: some ContiguousBytes,
        input: some ContiguousBytes,
        policy: ExecutionPolicy = .automatic
    ) throws -> BLAKE3.Digest {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try input.withUnsafeBytes { inputBytes in
                try hash(input: inputBytes, policy: policy, mode: mode)
            }
        }
    }

    /// Computes a 32-byte keyed BLAKE3 hash for a resident Metal buffer.
    public static func keyedHash(
        key: some ContiguousBytes,
        buffer: MTLBuffer,
        length: Int,
        policy: ExecutionPolicy = .automatic
    ) throws -> BLAKE3.Digest {
        try keyedHash(key: key, buffer: buffer, range: 0..<length, policy: policy)
    }

    /// Computes a 32-byte keyed BLAKE3 hash for a resident Metal buffer range.
    public static func keyedHash(
        key: some ContiguousBytes,
        buffer: MTLBuffer,
        range: Range<Int>,
        policy: ExecutionPolicy = .automatic
    ) throws -> BLAKE3.Digest {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try contextCache.context(device: buffer.device).hash(
                buffer: buffer,
                range: range,
                policy: policy,
                mode: mode
            )
        }
    }

    /// Computes keyed BLAKE3 XOF output for Swift-owned contiguous input.
    public static func keyedHash(
        key: some ContiguousBytes,
        input: some ContiguousBytes,
        outputByteCount: Int,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic
    ) throws -> [UInt8] {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try input.withUnsafeBytes { inputBytes in
                try xof(
                    input: inputBytes,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    policy: policy,
                    mode: mode
                )
            }
        }
    }

    /// Computes keyed BLAKE3 XOF output for a resident Metal buffer.
    public static func keyedHash(
        key: some ContiguousBytes,
        buffer: MTLBuffer,
        length: Int,
        outputByteCount: Int,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic
    ) throws -> [UInt8] {
        try keyedHash(
            key: key,
            buffer: buffer,
            range: 0..<length,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy
        )
    }

    /// Computes keyed BLAKE3 XOF output for a resident Metal buffer range.
    public static func keyedHash(
        key: some ContiguousBytes,
        buffer: MTLBuffer,
        range: Range<Int>,
        outputByteCount: Int,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic
    ) throws -> [UInt8] {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try contextCache.context(device: buffer.device).hash(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: mode
            )
        }
    }

    /// Writes keyed BLAKE3 XOF output for a resident Metal buffer into `outputBuffer`.
    @discardableResult
    public static func writeKeyedXOF(
        key: some ContiguousBytes,
        buffer: MTLBuffer,
        length: Int,
        outputByteCount: Int,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic,
        into outputBuffer: MTLBuffer
    ) throws -> Int {
        try writeKeyedXOF(
            key: key,
            buffer: buffer,
            range: 0..<length,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy,
            into: outputBuffer
        )
    }

    /// Writes keyed BLAKE3 XOF output for a resident Metal buffer range into `outputBuffer`.
    @discardableResult
    public static func writeKeyedXOF(
        key: some ContiguousBytes,
        buffer: MTLBuffer,
        range: Range<Int>,
        outputByteCount: Int,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic,
        into outputBuffer: MTLBuffer
    ) throws -> Int {
        try key.withUnsafeBytes { keyBytes in
            let mode = try keyedHashMode(keyBytes)
            return try contextCache.context(device: buffer.device).writeXOF(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                into: outputBuffer,
                mode: mode
            )
        }
    }

    /// Derives BLAKE3 key material using Metal for the material hash when selected by `policy`.
    public static func deriveKey(
        context: String,
        material: some ContiguousBytes,
        outputByteCount: Int = BLAKE3.digestByteCount,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic
    ) throws -> [UInt8] {
        let mode = deriveKeyMaterialMode(context: context)
        return try material.withUnsafeBytes { materialBytes in
            try xof(
                input: materialBytes,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: mode
            )
        }
    }

    /// Derives BLAKE3 key material from raw Swift-owned material using Metal when selected by `policy`.
    public static func deriveKey(
        context: String,
        material: UnsafeRawBufferPointer,
        outputByteCount: Int = BLAKE3.digestByteCount,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic
    ) throws -> [UInt8] {
        let mode = deriveKeyMaterialMode(context: context)
        if outputByteCount == BLAKE3.digestByteCount, seek == 0 {
            return try hash(input: material, policy: policy, mode: mode).bytes
        }
        return try xof(
            input: material,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy,
            mode: mode
        )
    }

    /// Derives BLAKE3 key material from a resident Metal buffer.
    public static func deriveKey(
        context: String,
        buffer: MTLBuffer,
        length: Int,
        outputByteCount: Int = BLAKE3.digestByteCount,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic
    ) throws -> [UInt8] {
        try deriveKey(
            context: context,
            buffer: buffer,
            range: 0..<length,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy
        )
    }

    /// Derives BLAKE3 key material from a resident Metal buffer range.
    public static func deriveKey(
        context: String,
        buffer: MTLBuffer,
        range: Range<Int>,
        outputByteCount: Int = BLAKE3.digestByteCount,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic
    ) throws -> [UInt8] {
        let mode = deriveKeyMaterialMode(context: context)
        let metalContext = try contextCache.context(device: buffer.device)
        if outputByteCount == BLAKE3.digestByteCount, seek == 0 {
            return try metalContext.hash(
                buffer: buffer,
                range: range,
                policy: policy,
                mode: mode
            ).bytes
        }
        return try metalContext.hash(
            buffer: buffer,
            range: range,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy,
            mode: mode
        )
    }

    /// Writes derived BLAKE3 key material for a resident Metal buffer into `outputBuffer`.
    @discardableResult
    public static func writeDerivedKey(
        context: String,
        buffer: MTLBuffer,
        length: Int,
        outputByteCount: Int = BLAKE3.digestByteCount,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic,
        into outputBuffer: MTLBuffer
    ) throws -> Int {
        try writeDerivedKey(
            context: context,
            buffer: buffer,
            range: 0..<length,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy,
            into: outputBuffer
        )
    }

    /// Writes derived BLAKE3 key material for a resident Metal buffer range into `outputBuffer`.
    @discardableResult
    public static func writeDerivedKey(
        context: String,
        buffer: MTLBuffer,
        range: Range<Int>,
        outputByteCount: Int = BLAKE3.digestByteCount,
        seek: UInt64 = 0,
        policy: ExecutionPolicy = .automatic,
        into outputBuffer: MTLBuffer
    ) throws -> Int {
        let mode = deriveKeyMaterialMode(context: context)
        return try contextCache.context(device: buffer.device).writeXOF(
            buffer: buffer,
            range: range,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy,
            into: outputBuffer,
            mode: mode
        )
    }

    /// Asynchronously hashes a resident Metal buffer.
    ///
    /// The buffer must remain valid until the returned task completes.
    public static func hashAsync(
        buffer: MTLBuffer,
        length: Int,
        policy: ExecutionPolicy = .automatic
    ) async throws -> BLAKE3.Digest {
        try await hashAsync(buffer: buffer, range: 0..<length, policy: policy)
    }

    /// Asynchronously hashes a range of a resident Metal buffer.
    public static func hashAsync(
        buffer: MTLBuffer,
        range: Range<Int>,
        policy: ExecutionPolicy = .automatic
    ) async throws -> BLAKE3.Digest {
        try await contextCache.context(device: buffer.device).hashAsync(
            buffer: buffer,
            range: range,
            policy: policy
        )
    }

    /// Reusable plan for hashing stable one-chunk ranges in one resident Metal buffer.
    public final class OneChunkBatchPlan: @unchecked Sendable {
        /// Input buffer whose ranges this plan describes.
        public let buffer: MTLBuffer
        /// Number of per-range digests produced by this plan.
        public let digestCount: Int
        /// Number of bytes required for all plan digests.
        public var outputByteCount: Int {
            digestCount * BLAKE3.digestByteCount
        }

        fileprivate let entriesBuffer: MTLBuffer
        fileprivate let parameterBuffer: MTLBuffer
        fileprivate let canLoadWords: Bool
        fileprivate let contiguousSingleBlocks: Bool
        fileprivate let allSingleBlocks: Bool
        fileprivate let allFullChunks: Bool
        fileprivate let lock = NSLock()

        fileprivate init(
            buffer: MTLBuffer,
            digestCount: Int,
            entriesBuffer: MTLBuffer,
            parameterBuffer: MTLBuffer,
            canLoadWords: Bool,
            contiguousSingleBlocks: Bool,
            allSingleBlocks: Bool,
            allFullChunks: Bool
        ) {
            self.buffer = buffer
            self.digestCount = digestCount
            self.entriesBuffer = entriesBuffer
            self.parameterBuffer = parameterBuffer
            self.canLoadWords = canLoadWords
            self.contiguousSingleBlocks = contiguousSingleBlocks
            self.allSingleBlocks = allSingleBlocks
            self.allFullChunks = allFullChunks
        }
    }

    /// Benchmark-only command pipeline for repeated writes from one stable one-chunk plan.
    @_spi(Benchmark)
    public final class OneChunkBatchWritePipeline: @unchecked Sendable {
        /// Plan whose digest commands are encoded by this pipeline.
        public let plan: OneChunkBatchPlan
        /// Output buffers written by each in-flight command.
        public let outputBuffers: [MTLBuffer]
        /// Number of command buffers committed per pipeline call.
        public var inFlightCount: Int {
            outputBuffers.count
        }
        /// Number of digest bytes written into each output buffer.
        public var outputByteCount: Int {
            plan.outputByteCount
        }

        fileprivate let parameterBuffers: [MTLBuffer]
        fileprivate let lock = NSLock()

        fileprivate init(
            plan: OneChunkBatchPlan,
            outputBuffers: [MTLBuffer],
            parameterBuffers: [MTLBuffer]
        ) {
            self.plan = plan
            self.outputBuffers = outputBuffers
            self.parameterBuffers = parameterBuffers
        }
    }

    /// Benchmark-only command pipeline for repeated writes followed by hashing the produced digest bytes.
    @_spi(Benchmark)
    public final class OneChunkBatchChainedPipeline: @unchecked Sendable {
        /// Plan whose digest commands are encoded by this pipeline.
        public let plan: OneChunkBatchPlan
        /// Output buffers written by each in-flight command.
        public let outputBuffers: [MTLBuffer]
        /// Number of command buffers committed per pipeline call.
        public var inFlightCount: Int {
            outputBuffers.count
        }
        /// Number of digest bytes written into each output buffer.
        public var outputByteCount: Int {
            plan.outputByteCount
        }

        fileprivate let outputChunkCount: Int
        fileprivate let outputEntryBuffer: MTLBuffer?
        fileprivate let outputCanLoadWords: [Bool]
        fileprivate let batchParameterBuffers: [MTLBuffer]
        fileprivate let outputHashParameterBuffers: [MTLBuffer]
        fileprivate let chunkCVBuffers: [MTLBuffer]
        fileprivate let scratchBuffers: [MTLBuffer]
        fileprivate let digestBuffers: [MTLBuffer]
        fileprivate let lock = NSLock()

        fileprivate init(
            plan: OneChunkBatchPlan,
            outputBuffers: [MTLBuffer],
            outputChunkCount: Int,
            outputEntryBuffer: MTLBuffer?,
            outputCanLoadWords: [Bool],
            batchParameterBuffers: [MTLBuffer],
            outputHashParameterBuffers: [MTLBuffer],
            chunkCVBuffers: [MTLBuffer],
            scratchBuffers: [MTLBuffer],
            digestBuffers: [MTLBuffer]
        ) {
            self.plan = plan
            self.outputBuffers = outputBuffers
            self.outputChunkCount = outputChunkCount
            self.outputEntryBuffer = outputEntryBuffer
            self.outputCanLoadWords = outputCanLoadWords
            self.batchParameterBuffers = batchParameterBuffers
            self.outputHashParameterBuffers = outputHashParameterBuffers
            self.chunkCVBuffers = chunkCVBuffers
            self.scratchBuffers = scratchBuffers
            self.digestBuffers = digestBuffers
        }
    }

    /// Reusable Metal hashing context.
    ///
    /// A context owns pipeline state, one command queue, synchronous scratch buffers, and a default async
    /// workspace. It is safe to share across tasks: synchronous calls serialize scratch-buffer reuse, while
    /// async calls lease independent workspace resources. Caller-owned `MTLBuffer` values must remain valid
    /// until the corresponding sync call returns or async call completes.
    public final class Context: @unchecked Sendable {
        public let device: MTLDevice
        /// Minimum byte count where `.automatic` selects GPU work.
        public let minimumGPUByteCount: Int
        /// Metal kernel source used for pipeline creation.
        public let librarySource: LibrarySource

        private let pipelines: BLAKE3MetalPipelines
        private let commandQueue: MTLCommandQueue
        private let defaultAsyncWorkspace: AsyncWorkspace
        private let lock = NSLock()

        private var chunkCVBuffer: MTLBuffer?
        private var parentCVBuffer: MTLBuffer?
        private var digestBuffer: MTLBuffer?
        private var parameterBuffer: MTLBuffer?
        private var auxiliaryParameterBuffer: MTLBuffer?
        private var chunkCVCapacity = 0
        private var parentCVCapacity = 0
        private var parameterSlotCapacity = 0
        private var auxiliaryParameterSlotCapacity = 0

        /// Creates a Metal context for a device.
        ///
        /// `minimumGPUByteCount` controls the `.automatic` policy. `librarySource` can point at a
        /// precompiled `.metallib` so production startup avoids runtime Metal source compilation.
        public init(
            device: MTLDevice,
            minimumGPUByteCount: Int = BLAKE3Metal.defaultMinimumGPUByteCount,
            librarySource: LibrarySource = .runtimeSource
        ) throws {
            self.device = device
            self.minimumGPUByteCount = max(0, minimumGPUByteCount)
            self.librarySource = librarySource
            self.pipelines = try BLAKE3MetalPipelineCache.shared.pipelines(
                device: device,
                librarySource: librarySource
            )
            guard let commandQueue = device.makeCommandQueue() else {
                throw BLAKE3Error.metalCommandFailed("Unable to create command queue.")
            }
            self.commandQueue = commandQueue
            self.defaultAsyncWorkspace = try AsyncWorkspace(
                device: device,
                maxPooledResources: BLAKE3Metal.defaultAsyncInflightCommandCount
            )
        }

        /// Allocates a shared staging buffer for repeated end-to-end hashing or private-buffer uploads.
        public func makeStagingBuffer(capacity: Int) throws -> StagingBuffer {
            guard capacity >= 0 else {
                throw BLAKE3Error.metalCommandFailed("Staging buffer capacity must be non-negative.")
            }
            guard let buffer = device.makeBuffer(
                length: max(1, capacity),
                options: .storageModeShared
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate staging input buffer.")
            }
            return StagingBuffer(buffer: buffer, capacity: capacity)
        }

        /// Allocates a reusable async workspace for concurrent Metal hashing.
        ///
        /// Pass `preallocateForByteCount` when repeated calls have a known upper bound and allocation
        /// latency should be removed from the measured path.
        public func makeAsyncWorkspace(
            maxPooledResources: Int = BLAKE3Metal.defaultAsyncInflightCommandCount,
            preallocateForByteCount: Int? = nil
        ) throws -> AsyncWorkspace {
            try AsyncWorkspace(
                device: device,
                maxPooledResources: maxPooledResources,
                preallocateForByteCount: preallocateForByteCount
            )
        }

        /// Allocates a shared output buffer for chunk chaining values.
        ///
        /// Use this with ``writeChunkChainingValues(buffer:range:baseChunkCounter:into:)`` when a caller
        /// wants to compose a larger tree or tiled file pipeline explicitly.
        public func makeChunkChainingValueBuffer(chunkCapacity: Int) throws -> ChunkChainingValueBuffer {
            guard chunkCapacity >= 0 else {
                throw BLAKE3Error.metalCommandFailed("Chunk chaining value capacity must be non-negative.")
            }
            guard let buffer = device.makeBuffer(
                length: max(1, chunkCapacity * BLAKE3.digestByteCount),
                options: .storageModeShared
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate chunk chaining value buffer.")
            }
            return ChunkChainingValueBuffer(buffer: buffer, chunkCapacity: chunkCapacity)
        }

        /// Creates a bounded async hashing pipeline.
        ///
        /// The pipeline owns `inFlightCount` staging buffers and an async workspace. Set
        /// `usesPrivateBuffers` when uploads should land in private Metal memory before hashing.
        public func makeAsyncPipeline(
            inputCapacity: Int,
            inFlightCount: Int = BLAKE3Metal.defaultAsyncInflightCommandCount,
            policy: ExecutionPolicy = .automatic,
            usesPrivateBuffers: Bool = false
        ) throws -> AsyncPipeline {
            guard inputCapacity >= 0 else {
                throw BLAKE3Error.metalCommandFailed("Async pipeline input capacity must be non-negative.")
            }
            guard inFlightCount > 0 else {
                throw BLAKE3Error.metalCommandFailed("Async pipeline in-flight count must be positive.")
            }

            let asyncWorkspace = try makeAsyncWorkspace(
                maxPooledResources: inFlightCount,
                preallocateForByteCount: inputCapacity
            )
            let stagingBuffers = try (0..<inFlightCount).map { _ in
                try makeStagingBuffer(capacity: inputCapacity)
            }
            let privateBuffers: [PrivateBuffer]? = usesPrivateBuffers
                ? try (0..<inFlightCount).map { _ in try makePrivateBuffer(capacity: inputCapacity) }
                : nil

            return AsyncPipeline(
                context: self,
                inputCapacity: inputCapacity,
                inFlightCount: inFlightCount,
                policy: policy,
                usesPrivateBuffers: usesPrivateBuffers,
                workspace: asyncWorkspace,
                stagingBuffers: stagingBuffers,
                privateBuffers: privateBuffers
            )
        }

        /// Allocates a private Metal input buffer for repeated resident-style GPU hashes.
        public func makePrivateBuffer(capacity: Int) throws -> PrivateBuffer {
            guard capacity >= 0 else {
                throw BLAKE3Error.metalCommandFailed("Private buffer capacity must be non-negative.")
            }
            guard let buffer = device.makeBuffer(
                length: max(1, capacity),
                options: .storageModePrivate
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate private input buffer.")
            }
            return PrivateBuffer(buffer: buffer, capacity: capacity, length: 0)
        }

        /// Allocates a private Metal input buffer and synchronously uploads `input`.
        public func makePrivateBuffer(input: some ContiguousBytes) throws -> PrivateBuffer {
            try input.withUnsafeBytes { raw in
                let privateBuffer = try makePrivateBuffer(capacity: raw.count)
                try replaceContents(of: privateBuffer, with: raw)
                return privateBuffer
            }
        }

        /// Allocates a private Metal input buffer and uploads through a caller-provided staging buffer.
        public func makePrivateBuffer(
            input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer
        ) throws -> PrivateBuffer {
            try input.withUnsafeBytes { raw in
                let privateBuffer = try makePrivateBuffer(capacity: raw.count)
                try replaceContents(of: privateBuffer, with: raw, using: stagingBuffer)
                return privateBuffer
            }
        }

        /// Replaces private-buffer contents with a synchronous upload.
        public func replaceContents(
            of privateBuffer: PrivateBuffer,
            with input: some ContiguousBytes
        ) throws {
            try input.withUnsafeBytes { raw in
                try replaceContents(of: privateBuffer, with: raw)
            }
        }

        /// Replaces private-buffer contents with a synchronous upload.
        ///
        /// The input buffer only needs to remain valid for the duration of the call.
        public func replaceContents(
            of privateBuffer: PrivateBuffer,
            with input: UnsafeRawBufferPointer
        ) throws {
            guard privateBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Private buffer belongs to a different Metal device.")
            }
            guard input.count <= privateBuffer.capacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Input length \(input.count) exceeds private buffer capacity \(privateBuffer.capacity)."
                )
            }

            privateBuffer.lock.lock()
            defer {
                privateBuffer.lock.unlock()
            }

            guard input.count > 0 else {
                privateBuffer.length = 0
                return
            }
            let source = try makeOwnedSharedBuffer(copying: input)
            guard let commandBuffer = commandQueue.makeCommandBuffer(),
                  let blitEncoder = commandBuffer.makeBlitCommandEncoder()
            else {
                throw BLAKE3Error.metalCommandFailed("Unable to stage private buffer upload.")
            }

            blitEncoder.copy(
                from: source,
                sourceOffset: 0,
                to: privateBuffer.buffer,
                destinationOffset: 0,
                size: input.count
            )
            blitEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }
            privateBuffer.length = input.count
        }

        /// Replaces private-buffer contents using a reusable staging buffer.
        public func replaceContents(
            of privateBuffer: PrivateBuffer,
            with input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer
        ) throws {
            try input.withUnsafeBytes { raw in
                try replaceContents(of: privateBuffer, with: raw, using: stagingBuffer)
            }
        }

        /// Replaces private-buffer contents using a reusable staging buffer.
        ///
        /// The input buffer only needs to remain valid for the duration of the call.
        public func replaceContents(
            of privateBuffer: PrivateBuffer,
            with input: UnsafeRawBufferPointer,
            using stagingBuffer: StagingBuffer
        ) throws {
            guard privateBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Private buffer belongs to a different Metal device.")
            }
            guard stagingBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Staging buffer belongs to a different Metal device.")
            }
            guard input.count <= privateBuffer.capacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Input length \(input.count) exceeds private buffer capacity \(privateBuffer.capacity)."
                )
            }
            guard input.count <= stagingBuffer.capacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Input length \(input.count) exceeds staging buffer capacity \(stagingBuffer.capacity)."
                )
            }

            stagingBuffer.lock.lock()
            privateBuffer.lock.lock()
            defer {
                privateBuffer.lock.unlock()
                stagingBuffer.lock.unlock()
            }

            guard input.count > 0 else {
                privateBuffer.length = 0
                return
            }
            guard let baseAddress = input.baseAddress,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let blitEncoder = commandBuffer.makeBlitCommandEncoder()
            else {
                throw BLAKE3Error.metalCommandFailed("Unable to stage private buffer upload.")
            }

            stagingBuffer.buffer.contents().copyMemory(from: baseAddress, byteCount: input.count)
            blitEncoder.copy(
                from: stagingBuffer.buffer,
                sourceOffset: 0,
                to: privateBuffer.buffer,
                destinationOffset: 0,
                size: input.count
            )
            blitEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }
            privateBuffer.length = input.count
        }

        /// Copies raw input through a staging buffer into private storage, then hashes it.
        ///
        /// This repeated-call path uses a tuned synchronous flow: smaller inputs combine upload and hashing in
        /// one command buffer, while larger inputs keep the faster split upload-then-hash sequence.
        public func hash(
            input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer,
            privateBuffer: PrivateBuffer,
            policy: ExecutionPolicy = .gpu
        ) throws -> BLAKE3.Digest {
            try input.withUnsafeBytes { raw in
                try hash(input: raw, using: stagingBuffer, privateBuffer: privateBuffer, policy: policy)
            }
        }

        /// Copies raw input through a staging buffer into private storage, then hashes it.
        ///
        /// The input buffer only needs to remain valid for the duration of this synchronous call.
        public func hash(
            input: UnsafeRawBufferPointer,
            using stagingBuffer: StagingBuffer,
            privateBuffer: PrivateBuffer,
            policy: ExecutionPolicy = .gpu
        ) throws -> BLAKE3.Digest {
            guard policy != .cpu,
                  input.count > BLAKE3.chunkByteCount
            else {
                return BLAKE3.hash(input)
            }
            guard privateBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Private buffer belongs to a different Metal device.")
            }
            guard stagingBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Staging buffer belongs to a different Metal device.")
            }
            guard input.count <= privateBuffer.capacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Input length \(input.count) exceeds private buffer capacity \(privateBuffer.capacity)."
                )
            }
            guard input.count <= stagingBuffer.capacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Input length \(input.count) exceeds staging buffer capacity \(stagingBuffer.capacity)."
                )
            }
            guard let baseAddress = input.baseAddress else {
                throw BLAKE3Error.metalCommandFailed("Input bytes are unavailable.")
            }
            guard input.count <= BLAKE3Metal.combinedPrivateStagedMaxBytes else {
                try replaceContents(of: privateBuffer, with: input, using: stagingBuffer)
                return try hash(privateBuffer: privateBuffer, policy: policy)
            }

            stagingBuffer.lock.lock()
            privateBuffer.lock.lock()
            defer {
                privateBuffer.lock.unlock()
                stagingBuffer.lock.unlock()
            }

            stagingBuffer.buffer.contents().copyMemory(from: baseAddress, byteCount: input.count)
            let chunkCount = (input.count + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount
            return try withWorkspace(chunkCount: chunkCount) { cvBuffer, scratchBuffer, digestBuffer, parameterBuffer in
                guard let commandBuffer = commandQueue.makeCommandBufferWithUnretainedReferences(),
                      let blitEncoder = commandBuffer.makeBlitCommandEncoder()
                else {
                    throw BLAKE3Error.metalCommandFailed("Unable to create private staged hash command buffer.")
                }

                blitEncoder.copy(
                    from: stagingBuffer.buffer,
                    sourceOffset: 0,
                    to: privateBuffer.buffer,
                    destinationOffset: 0,
                    size: input.count
                )
                blitEncoder.endEncoding()

                guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
                    throw BLAKE3Error.metalCommandFailed("Unable to create private staged hash encoder.")
                }
                try BLAKE3Metal.encodeHashCommands(
                    buffer: privateBuffer.buffer,
                    range: 0..<input.count,
                    chunkCount: chunkCount,
                    pipelines: pipelines,
                    cvBuffer: cvBuffer,
                    scratchBuffer: scratchBuffer,
                    digestBuffer: digestBuffer,
                    parameterBuffer: parameterBuffer,
                    encoder: computeEncoder
                )

                commandBuffer.commit()
                commandBuffer.waitUntilCompleted()

                if let error = commandBuffer.error {
                    throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
                }

                privateBuffer.length = input.count
                return BLAKE3.Digest(
                    UnsafeRawBufferPointer(
                        start: digestBuffer.contents(),
                        count: BLAKE3.digestByteCount
                    )
                )
            }
        }

        /// Asynchronously uploads new private-buffer contents through a staging buffer.
        ///
        /// The staging and private buffers are locked until the blit command completes.
        public func replaceContentsAsync(
            of privateBuffer: PrivateBuffer,
            with input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer
        ) async throws {
            try Task.checkCancellation()

            stagingBuffer.lockForAsyncUse()
            privateBuffer.lockForAsyncUse()

            var inputLength = 0
            var commandBuffer: MTLCommandBuffer?

            do {
                guard privateBuffer.buffer.device.registryID == device.registryID else {
                    throw BLAKE3Error.metalCommandFailed("Private buffer belongs to a different Metal device.")
                }
                guard stagingBuffer.buffer.device.registryID == device.registryID else {
                    throw BLAKE3Error.metalCommandFailed("Staging buffer belongs to a different Metal device.")
                }

                inputLength = try copyInputToStaging(
                    input,
                    stagingBuffer: stagingBuffer,
                    maximumByteCount: privateBuffer.capacity,
                    maximumLabel: "private buffer"
                )

                guard inputLength > 0 else {
                    privateBuffer.length = 0
                    privateBuffer.unlockForAsyncUse()
                    stagingBuffer.unlockForAsyncUse()
                    return
                }

                guard let pendingCommandBuffer = commandQueue.makeCommandBuffer(),
                      let blitEncoder = pendingCommandBuffer.makeBlitCommandEncoder()
                else {
                    throw BLAKE3Error.metalCommandFailed("Unable to stage private buffer upload.")
                }
                blitEncoder.copy(
                    from: stagingBuffer.buffer,
                    sourceOffset: 0,
                    to: privateBuffer.buffer,
                    destinationOffset: 0,
                    size: inputLength
                )
                blitEncoder.endEncoding()
                commandBuffer = pendingCommandBuffer
            } catch {
                privateBuffer.unlockForAsyncUse()
                stagingBuffer.unlockForAsyncUse()
                throw error
            }

            guard let commandBuffer else {
                privateBuffer.unlockForAsyncUse()
                stagingBuffer.unlockForAsyncUse()
                throw BLAKE3Error.metalCommandFailed("Unable to stage private buffer upload.")
            }

            let committedInputLength = inputLength
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                commandBuffer.addCompletedHandler { completedBuffer in
                    defer {
                        privateBuffer.unlockForAsyncUse()
                        stagingBuffer.unlockForAsyncUse()
                    }
                    if let error = completedBuffer.error {
                        continuation.resume(throwing: BLAKE3Error.metalCommandFailed(error.localizedDescription))
                        return
                    }
                    privateBuffer.length = committedInputLength
                    continuation.resume()
                }
                commandBuffer.commit()
            }
            try Task.checkCancellation()
        }

        /// Hashes a resident Metal buffer through this context.
        public func hash(
            buffer: MTLBuffer,
            length: Int,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try hash(buffer: buffer, range: 0..<length, policy: policy)
        }

        /// Hashes a range of a resident Metal buffer through this context.
        public func hash(
            buffer: MTLBuffer,
            range: Range<Int>,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try hash(buffer: buffer, range: range, policy: policy, mode: .unkeyed)
        }

        @_spi(Benchmark)
        public func hashOwnedSharedUploadBuffer(
            buffer: MTLBuffer,
            length: Int,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try hashOwnedSharedUploadBuffer(buffer: buffer, range: 0..<length, policy: policy)
        }

        @_spi(Benchmark)
        public func hashOwnedSharedUploadBuffer(
            buffer: MTLBuffer,
            range: Range<Int>,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try BLAKE3Metal.hash(
                buffer: buffer,
                range: range,
                policy: policy,
                mode: .unkeyed,
                minimumGPUByteCount: minimumGPUByteCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: self,
                allowsFusedTile: range.count <= BLAKE3Metal.ownedSharedUploadFusedTileMaxBytes
            )
        }

        /// Hashes many independent resident-buffer ranges that each fit in one BLAKE3 chunk.
        ///
        /// This path submits the whole batch as one Metal dispatch and returns one digest per range.
        public func hashOneChunkBatch(
            buffer: MTLBuffer,
            ranges: [Range<Int>]
        ) throws -> [BLAKE3.Digest] {
            try hashOneChunkBatch(buffer: buffer, ranges: ranges, mode: .unkeyed)
        }

        /// Builds a reusable plan for hashing stable one-chunk ranges in a resident Metal buffer.
        public func makeOneChunkBatchPlan(
            buffer: MTLBuffer,
            ranges: [Range<Int>]
        ) throws -> OneChunkBatchPlan {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.buildOneChunkBatchPlan(buffer: buffer, ranges: ranges)
        }

        /// Hashes all ranges in a reusable one-chunk resident-buffer batch plan.
        public func hashOneChunkBatch(plan: OneChunkBatchPlan) throws -> [BLAKE3.Digest] {
            try hashOneChunkBatch(plan: plan, mode: .unkeyed)
        }

        /// Builds a benchmark-only command pipeline for repeated plan digest writes.
        @_spi(Benchmark)
        public func makeOneChunkBatchWritePipeline(
            plan: OneChunkBatchPlan,
            outputBuffers: [MTLBuffer]
        ) throws -> OneChunkBatchWritePipeline {
            guard plan.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Batch plan belongs to a different Metal device.")
            }
            return try BLAKE3Metal.buildOneChunkBatchWritePipeline(
                plan: plan,
                outputBuffers: outputBuffers
            )
        }

        /// Writes plan digests into all pipeline output buffers, committing all command buffers before waiting.
        @_spi(Benchmark)
        @discardableResult
        public func writeOneChunkBatchDigests(
            pipeline: OneChunkBatchWritePipeline
        ) throws -> Int {
            try writeOneChunkBatchDigests(pipeline: pipeline, mode: .unkeyed)
        }

        /// Builds a benchmark-only command pipeline for repeated plan writes plus output hashing.
        @_spi(Benchmark)
        public func makeOneChunkBatchChainedPipeline(
            plan: OneChunkBatchPlan,
            outputBuffers: [MTLBuffer]
        ) throws -> OneChunkBatchChainedPipeline {
            guard plan.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Batch plan belongs to a different Metal device.")
            }
            return try BLAKE3Metal.buildOneChunkBatchChainedPipeline(
                plan: plan,
                outputBuffers: outputBuffers
            )
        }

        /// Writes plan digests into all chained-pipeline output buffers and returns the last output digest.
        @_spi(Benchmark)
        public func writeOneChunkBatchDigestsAndHashOutput(
            pipeline: OneChunkBatchChainedPipeline
        ) throws -> BLAKE3.Digest {
            try writeOneChunkBatchDigestsAndHashOutput(pipeline: pipeline, mode: .unkeyed)
        }

        /// Computes keyed BLAKE3 hashes for many independent resident-buffer ranges that each fit in one chunk.
        public func keyedHashOneChunkBatch(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            ranges: [Range<Int>]
        ) throws -> [BLAKE3.Digest] {
            try key.withUnsafeBytes { keyBytes in
                try hashOneChunkBatch(
                    buffer: buffer,
                    ranges: ranges,
                    mode: BLAKE3Metal.keyedHashMode(keyBytes)
                )
            }
        }

        /// Computes keyed BLAKE3 hashes for all ranges in a reusable one-chunk batch plan.
        public func keyedHashOneChunkBatch(
            key: some ContiguousBytes,
            plan: OneChunkBatchPlan
        ) throws -> [BLAKE3.Digest] {
            try key.withUnsafeBytes { keyBytes in
                try hashOneChunkBatch(
                    plan: plan,
                    mode: BLAKE3Metal.keyedHashMode(keyBytes)
                )
            }
        }

        /// Writes one digest per independent one-chunk resident-buffer range into `outputBuffer`.
        @discardableResult
        public func writeOneChunkBatchDigests(
            buffer: MTLBuffer,
            ranges: [Range<Int>],
            into outputBuffer: MTLBuffer
        ) throws -> Int {
            try writeOneChunkBatchDigests(
                buffer: buffer,
                ranges: ranges,
                into: outputBuffer,
                mode: .unkeyed
            )
        }

        /// Writes one digest per range in a reusable one-chunk batch plan into `outputBuffer`.
        @discardableResult
        public func writeOneChunkBatchDigests(
            plan: OneChunkBatchPlan,
            into outputBuffer: MTLBuffer
        ) throws -> Int {
            try writeOneChunkBatchDigests(
                plan: plan,
                into: outputBuffer,
                mode: .unkeyed
            )
        }

        /// Writes one digest per independent one-chunk range and returns a digest of the produced digest bytes.
        public func writeOneChunkBatchDigestsAndHashOutput(
            buffer: MTLBuffer,
            ranges: [Range<Int>],
            into outputBuffer: MTLBuffer
        ) throws -> BLAKE3.Digest {
            try writeOneChunkBatchDigestsAndHashOutput(
                buffer: buffer,
                ranges: ranges,
                into: outputBuffer,
                mode: .unkeyed
            )
        }

        /// Writes plan digests and returns a digest of the produced digest bytes.
        public func writeOneChunkBatchDigestsAndHashOutput(
            plan: OneChunkBatchPlan,
            into outputBuffer: MTLBuffer
        ) throws -> BLAKE3.Digest {
            try writeOneChunkBatchDigestsAndHashOutput(
                plan: plan,
                into: outputBuffer,
                mode: .unkeyed
            )
        }

        /// Returns a digest of the concatenated per-range digest bytes without materializing them on the CPU.
        public func hashOneChunkBatchDigestBytes(
            buffer: MTLBuffer,
            ranges: [Range<Int>]
        ) throws -> BLAKE3.Digest {
            try hashOneChunkBatchDigestBytes(
                buffer: buffer,
                ranges: ranges,
                mode: .unkeyed
            )
        }

        /// Returns a digest of the concatenated plan digest bytes without materializing them on the CPU.
        public func hashOneChunkBatchDigestBytes(plan: OneChunkBatchPlan) throws -> BLAKE3.Digest {
            try hashOneChunkBatchDigestBytes(plan: plan, mode: .unkeyed)
        }

        /// Writes keyed BLAKE3 digests for many independent one-chunk resident-buffer ranges.
        @discardableResult
        public func writeKeyedOneChunkBatchDigests(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            ranges: [Range<Int>],
            into outputBuffer: MTLBuffer
        ) throws -> Int {
            try key.withUnsafeBytes { keyBytes in
                try writeOneChunkBatchDigests(
                    buffer: buffer,
                    ranges: ranges,
                    into: outputBuffer,
                    mode: BLAKE3Metal.keyedHashMode(keyBytes)
                )
            }
        }

        /// Writes keyed BLAKE3 digests for a reusable one-chunk batch plan into `outputBuffer`.
        @discardableResult
        public func writeKeyedOneChunkBatchDigests(
            key: some ContiguousBytes,
            plan: OneChunkBatchPlan,
            into outputBuffer: MTLBuffer
        ) throws -> Int {
            try key.withUnsafeBytes { keyBytes in
                try writeOneChunkBatchDigests(
                    plan: plan,
                    into: outputBuffer,
                    mode: BLAKE3Metal.keyedHashMode(keyBytes)
                )
            }
        }

        /// Writes keyed BLAKE3 digests for one-chunk ranges and returns a digest of the produced digest bytes.
        public func writeKeyedOneChunkBatchDigestsAndHashOutput(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            ranges: [Range<Int>],
            into outputBuffer: MTLBuffer
        ) throws -> BLAKE3.Digest {
            try key.withUnsafeBytes { keyBytes in
                try writeOneChunkBatchDigestsAndHashOutput(
                    buffer: buffer,
                    ranges: ranges,
                    into: outputBuffer,
                    mode: BLAKE3Metal.keyedHashMode(keyBytes)
                )
            }
        }

        /// Writes keyed plan digests and returns a digest of the produced digest bytes.
        public func writeKeyedOneChunkBatchDigestsAndHashOutput(
            key: some ContiguousBytes,
            plan: OneChunkBatchPlan,
            into outputBuffer: MTLBuffer
        ) throws -> BLAKE3.Digest {
            try key.withUnsafeBytes { keyBytes in
                try writeOneChunkBatchDigestsAndHashOutput(
                    plan: plan,
                    into: outputBuffer,
                    mode: BLAKE3Metal.keyedHashMode(keyBytes)
                )
            }
        }

        /// Returns a digest of the concatenated keyed per-range digest bytes without materializing them on the CPU.
        public func hashKeyedOneChunkBatchDigestBytes(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            ranges: [Range<Int>]
        ) throws -> BLAKE3.Digest {
            try key.withUnsafeBytes { keyBytes in
                try hashOneChunkBatchDigestBytes(
                    buffer: buffer,
                    ranges: ranges,
                    mode: BLAKE3Metal.keyedHashMode(keyBytes)
                )
            }
        }

        /// Returns a digest of the concatenated keyed plan digest bytes without materializing them on the CPU.
        public func hashKeyedOneChunkBatchDigestBytes(
            key: some ContiguousBytes,
            plan: OneChunkBatchPlan
        ) throws -> BLAKE3.Digest {
            try key.withUnsafeBytes { keyBytes in
                try hashOneChunkBatchDigestBytes(
                    plan: plan,
                    mode: BLAKE3Metal.keyedHashMode(keyBytes)
                )
            }
        }

        func hashOneChunkBatch(
            buffer: MTLBuffer,
            ranges: [Range<Int>],
            mode: HashMode
        ) throws -> [BLAKE3.Digest] {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.hashOneChunkBatch(
                buffer: buffer,
                ranges: ranges,
                mode: mode,
                pipelines: pipelines,
                commandQueue: commandQueue
            )
        }

        func hashOneChunkBatch(
            plan: OneChunkBatchPlan,
            mode: HashMode
        ) throws -> [BLAKE3.Digest] {
            guard plan.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Batch plan belongs to a different Metal device.")
            }
            return try BLAKE3Metal.hashOneChunkBatch(
                plan: plan,
                mode: mode,
                pipelines: pipelines,
                commandQueue: commandQueue
            )
        }

        @discardableResult
        func writeOneChunkBatchDigests(
            pipeline: OneChunkBatchWritePipeline,
            mode: HashMode
        ) throws -> Int {
            guard pipeline.plan.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Batch pipeline belongs to a different Metal device.")
            }
            return try BLAKE3Metal.writeOneChunkBatchDigests(
                pipeline: pipeline,
                mode: mode,
                pipelines: pipelines,
                commandQueue: commandQueue
            )
        }

        func writeOneChunkBatchDigestsAndHashOutput(
            pipeline: OneChunkBatchChainedPipeline,
            mode: HashMode
        ) throws -> BLAKE3.Digest {
            guard pipeline.plan.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Batch pipeline belongs to a different Metal device.")
            }
            return try BLAKE3Metal.writeOneChunkBatchDigestsAndHashOutput(
                pipeline: pipeline,
                mode: mode,
                pipelines: pipelines,
                commandQueue: commandQueue
            )
        }

        @discardableResult
        func writeOneChunkBatchDigests(
            buffer: MTLBuffer,
            ranges: [Range<Int>],
            into outputBuffer: MTLBuffer,
            mode: HashMode
        ) throws -> Int {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            guard outputBuffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.writeOneChunkBatchDigests(
                buffer: buffer,
                ranges: ranges,
                mode: mode,
                pipelines: pipelines,
                commandQueue: commandQueue,
                outputBuffer: outputBuffer
            )
        }

        @discardableResult
        func writeOneChunkBatchDigests(
            plan: OneChunkBatchPlan,
            into outputBuffer: MTLBuffer,
            mode: HashMode
        ) throws -> Int {
            guard plan.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Batch plan belongs to a different Metal device.")
            }
            guard outputBuffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.writeOneChunkBatchDigests(
                plan: plan,
                mode: mode,
                pipelines: pipelines,
                commandQueue: commandQueue,
                outputBuffer: outputBuffer
            )
        }

        func writeOneChunkBatchDigestsAndHashOutput(
            buffer: MTLBuffer,
            ranges: [Range<Int>],
            into outputBuffer: MTLBuffer,
            mode: HashMode
        ) throws -> BLAKE3.Digest {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            guard outputBuffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.writeOneChunkBatchDigestsAndHashOutput(
                buffer: buffer,
                ranges: ranges,
                mode: mode,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: self,
                outputBuffer: outputBuffer
            )
        }

        func writeOneChunkBatchDigestsAndHashOutput(
            plan: OneChunkBatchPlan,
            into outputBuffer: MTLBuffer,
            mode: HashMode
        ) throws -> BLAKE3.Digest {
            guard plan.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Batch plan belongs to a different Metal device.")
            }
            guard outputBuffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.writeOneChunkBatchDigestsAndHashOutput(
                plan: plan,
                mode: mode,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: self,
                outputBuffer: outputBuffer
            )
        }

        func hashOneChunkBatchDigestBytes(
            buffer: MTLBuffer,
            ranges: [Range<Int>],
            mode: HashMode
        ) throws -> BLAKE3.Digest {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.hashOneChunkBatchDigestBytes(
                buffer: buffer,
                ranges: ranges,
                mode: mode,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: self
            )
        }

        func hashOneChunkBatchDigestBytes(
            plan: OneChunkBatchPlan,
            mode: HashMode
        ) throws -> BLAKE3.Digest {
            guard plan.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Batch plan belongs to a different Metal device.")
            }
            return try BLAKE3Metal.hashOneChunkBatchDigestBytes(
                plan: plan,
                mode: mode,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: self
            )
        }

        func hash(
            buffer: MTLBuffer,
            range: Range<Int>,
            policy: ExecutionPolicy,
            mode: HashMode
        ) throws -> BLAKE3.Digest {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.hash(
                buffer: buffer,
                range: range,
                policy: policy,
                mode: mode,
                minimumGPUByteCount: minimumGPUByteCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: self
            )
        }

        /// Hashes a resident Metal buffer through this context and returns BLAKE3 XOF output.
        public func hash(
            buffer: MTLBuffer,
            length: Int,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic
        ) throws -> [UInt8] {
            try hash(
                buffer: buffer,
                range: 0..<length,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy
            )
        }

        /// Hashes a resident Metal buffer range through this context and returns BLAKE3 XOF output.
        public func hash(
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic
        ) throws -> [UInt8] {
            try hash(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: .unkeyed
            )
        }

        /// Writes BLAKE3 XOF output for a resident Metal buffer through this context.
        @discardableResult
        public func writeXOF(
            buffer: MTLBuffer,
            length: Int,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> Int {
            try writeXOF(
                buffer: buffer,
                range: 0..<length,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                into: outputBuffer
            )
        }

        /// Writes BLAKE3 XOF output for a resident Metal buffer range through this context.
        @discardableResult
        public func writeXOF(
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> Int {
            try writeXOF(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                into: outputBuffer,
                mode: .unkeyed
            )
        }

        /// Writes BLAKE3 XOF output and returns a BLAKE3 digest of the produced output bytes.
        ///
        /// For GPU-sized inputs and outputs, this encodes the XOF generation and output digest into one
        /// Metal command buffer so the output can remain private to the GPU.
        public func writeXOFAndHashOutput(
            buffer: MTLBuffer,
            length: Int,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> BLAKE3.Digest {
            try writeXOFAndHashOutput(
                buffer: buffer,
                range: 0..<length,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                into: outputBuffer
            )
        }

        /// Writes BLAKE3 XOF output for a range and returns a BLAKE3 digest of the produced output bytes.
        public func writeXOFAndHashOutput(
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> BLAKE3.Digest {
            try writeXOFAndHashOutput(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                into: outputBuffer,
                mode: .unkeyed
            )
        }

        func hash(
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int,
            seek: UInt64,
            policy: ExecutionPolicy,
            mode: HashMode
        ) throws -> [UInt8] {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.xof(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: mode,
                minimumGPUByteCount: minimumGPUByteCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: self
            )
        }

        @discardableResult
        func writeXOF(
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int,
            seek: UInt64,
            policy: ExecutionPolicy,
            into outputBuffer: MTLBuffer,
            mode: HashMode
        ) throws -> Int {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            guard outputBuffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.writeXOF(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: mode,
                minimumGPUByteCount: minimumGPUByteCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: self,
                outputBuffer: outputBuffer
            )
        }

        func writeXOFAndHashOutput(
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int,
            seek: UInt64,
            policy: ExecutionPolicy,
            into outputBuffer: MTLBuffer,
            mode: HashMode
        ) throws -> BLAKE3.Digest {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            guard outputBuffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.writeXOFAndHashOutput(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: mode,
                minimumGPUByteCount: minimumGPUByteCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: self,
                outputBuffer: outputBuffer
            )
        }

        /// Hashes Swift-owned contiguous input by temporarily wrapping it in a shared Metal buffer.
        ///
        /// This is a synchronous no-copy path for unified-memory systems. The input buffer only needs to
        /// remain valid for this call because the method waits for Metal completion before returning.
        public func hash(
            input: some ContiguousBytes,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try input.withUnsafeBytes { raw in
                try hash(input: raw, policy: policy)
            }
        }

        /// Hashes raw Swift-owned input by temporarily wrapping it in a shared Metal buffer.
        ///
        /// The buffer only needs to remain valid for this synchronous call.
        public func hash(
            input: UnsafeRawBufferPointer,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try hash(input: input, policy: policy, mode: .unkeyed)
        }

        fileprivate func hash(
            input: UnsafeRawBufferPointer,
            policy: ExecutionPolicy,
            mode: HashMode
        ) throws -> BLAKE3.Digest {
            guard input.count > 0 else {
                return BLAKE3Metal.hashOnCPU(input: input, mode: mode)
            }
            guard let baseAddress = input.baseAddress,
                  let buffer = device.makeBuffer(
                    bytesNoCopy: UnsafeMutableRawPointer(mutating: baseAddress),
                    length: input.count,
                    options: .storageModeShared,
                    deallocator: nil
                  )
            else {
                throw BLAKE3Error.metalCommandFailed("Unable to wrap Swift input in a Metal buffer.")
            }
            return try hash(buffer: buffer, range: 0..<input.count, policy: policy, mode: mode)
        }

        /// Hashes Swift-owned contiguous input through this context and returns BLAKE3 XOF output.
        public func hash(
            input: some ContiguousBytes,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic
        ) throws -> [UInt8] {
            try input.withUnsafeBytes { raw in
                try hash(input: raw, outputByteCount: outputByteCount, seek: seek, policy: policy)
            }
        }

        /// Hashes raw Swift-owned input through this context and returns BLAKE3 XOF output.
        public func hash(
            input: UnsafeRawBufferPointer,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic
        ) throws -> [UInt8] {
            try xof(
                input: input,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: .unkeyed
            )
        }

        fileprivate func xof(
            input: UnsafeRawBufferPointer,
            outputByteCount: Int,
            seek: UInt64,
            policy: ExecutionPolicy,
            mode: HashMode
        ) throws -> [UInt8] {
            try BLAKE3Metal.validateOutputByteCount(outputByteCount)
            guard outputByteCount > 0 else {
                return []
            }
            guard UInt64.max - seek >= UInt64(outputByteCount) else {
                throw BLAKE3Error.metalCommandFailed("BLAKE3 XOF output range overflows UInt64.")
            }
            guard input.count > 0 else {
                return BLAKE3Metal.xofOnCPU(
                    input: input,
                    mode: mode,
                    outputByteCount: outputByteCount,
                    seek: seek
                )
            }
            guard let baseAddress = input.baseAddress,
                  let buffer = device.makeBuffer(
                    bytesNoCopy: UnsafeMutableRawPointer(mutating: baseAddress),
                    length: input.count,
                    options: .storageModeShared,
                    deallocator: nil
                  )
            else {
                throw BLAKE3Error.metalCommandFailed("Unable to wrap Swift input in a Metal buffer.")
            }
            return try hash(
                buffer: buffer,
                range: 0..<input.count,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: mode
            )
        }

        /// Computes a 32-byte keyed BLAKE3 hash through this context.
        public func keyedHash(
            key: some ContiguousBytes,
            input: some ContiguousBytes,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try key.withUnsafeBytes { keyBytes in
                let mode = try BLAKE3Metal.keyedHashMode(keyBytes)
                return try input.withUnsafeBytes { inputBytes in
                    try hash(input: inputBytes, policy: policy, mode: mode)
                }
            }
        }

        /// Computes a 32-byte keyed BLAKE3 hash for a resident Metal buffer through this context.
        public func keyedHash(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            length: Int,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try keyedHash(key: key, buffer: buffer, range: 0..<length, policy: policy)
        }

        /// Computes a 32-byte keyed BLAKE3 hash for a resident Metal buffer range through this context.
        public func keyedHash(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            range: Range<Int>,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try key.withUnsafeBytes { keyBytes in
                let mode = try BLAKE3Metal.keyedHashMode(keyBytes)
                return try hash(buffer: buffer, range: range, policy: policy, mode: mode)
            }
        }

        /// Computes keyed BLAKE3 XOF output through this context.
        public func keyedHash(
            key: some ContiguousBytes,
            input: some ContiguousBytes,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic
        ) throws -> [UInt8] {
            try key.withUnsafeBytes { keyBytes in
                let mode = try BLAKE3Metal.keyedHashMode(keyBytes)
                return try input.withUnsafeBytes { inputBytes in
                    try xof(
                        input: inputBytes,
                        outputByteCount: outputByteCount,
                        seek: seek,
                        policy: policy,
                        mode: mode
                    )
                }
            }
        }

        /// Computes keyed BLAKE3 XOF output for a resident Metal buffer through this context.
        public func keyedHash(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            length: Int,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic
        ) throws -> [UInt8] {
            try keyedHash(
                key: key,
                buffer: buffer,
                range: 0..<length,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy
            )
        }

        /// Computes keyed BLAKE3 XOF output for a resident Metal buffer range through this context.
        public func keyedHash(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic
        ) throws -> [UInt8] {
            try key.withUnsafeBytes { keyBytes in
                let mode = try BLAKE3Metal.keyedHashMode(keyBytes)
                return try hash(
                    buffer: buffer,
                    range: range,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    policy: policy,
                    mode: mode
                )
            }
        }

        /// Writes keyed BLAKE3 XOF output for a resident Metal buffer through this context.
        @discardableResult
        public func writeKeyedXOF(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            length: Int,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> Int {
            try writeKeyedXOF(
                key: key,
                buffer: buffer,
                range: 0..<length,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                into: outputBuffer
            )
        }

        /// Writes keyed BLAKE3 XOF output for a resident Metal buffer range through this context.
        @discardableResult
        public func writeKeyedXOF(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> Int {
            try key.withUnsafeBytes { keyBytes in
                let mode = try BLAKE3Metal.keyedHashMode(keyBytes)
                return try writeXOF(
                    buffer: buffer,
                    range: range,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    policy: policy,
                    into: outputBuffer,
                    mode: mode
                )
            }
        }

        /// Writes keyed BLAKE3 XOF output and returns a digest of the produced output bytes.
        public func writeKeyedXOFAndHashOutput(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            length: Int,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> BLAKE3.Digest {
            try writeKeyedXOFAndHashOutput(
                key: key,
                buffer: buffer,
                range: 0..<length,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                into: outputBuffer
            )
        }

        /// Writes keyed BLAKE3 XOF output for a range and returns a digest of the produced output bytes.
        public func writeKeyedXOFAndHashOutput(
            key: some ContiguousBytes,
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> BLAKE3.Digest {
            try key.withUnsafeBytes { keyBytes in
                let mode = try BLAKE3Metal.keyedHashMode(keyBytes)
                return try writeXOFAndHashOutput(
                    buffer: buffer,
                    range: range,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    policy: policy,
                    into: outputBuffer,
                    mode: mode
                )
            }
        }

        /// Derives BLAKE3 key material through this context.
        public func deriveKey(
            context: String,
            material: some ContiguousBytes,
            outputByteCount: Int = BLAKE3.digestByteCount,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic
        ) throws -> [UInt8] {
            let mode = BLAKE3Metal.deriveKeyMaterialMode(context: context)
            return try material.withUnsafeBytes { materialBytes in
                try xof(
                    input: materialBytes,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    policy: policy,
                    mode: mode
                )
            }
        }

        /// Derives BLAKE3 key material from raw Swift-owned material through this context.
        public func deriveKey(
            context: String,
            material: UnsafeRawBufferPointer,
            outputByteCount: Int = BLAKE3.digestByteCount,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic
        ) throws -> [UInt8] {
            let mode = BLAKE3Metal.deriveKeyMaterialMode(context: context)
            if outputByteCount == BLAKE3.digestByteCount, seek == 0 {
                return try hash(input: material, policy: policy, mode: mode).bytes
            }
            return try xof(
                input: material,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: mode
            )
        }

        /// Derives BLAKE3 key material from a resident Metal buffer through this context.
        public func deriveKey(
            context: String,
            buffer: MTLBuffer,
            length: Int,
            outputByteCount: Int = BLAKE3.digestByteCount,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic
        ) throws -> [UInt8] {
            try deriveKey(
                context: context,
                buffer: buffer,
                range: 0..<length,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy
            )
        }

        /// Derives BLAKE3 key material from a resident Metal buffer range through this context.
        public func deriveKey(
            context: String,
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int = BLAKE3.digestByteCount,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic
        ) throws -> [UInt8] {
            let mode = BLAKE3Metal.deriveKeyMaterialMode(context: context)
            if outputByteCount == BLAKE3.digestByteCount, seek == 0 {
                return try hash(buffer: buffer, range: range, policy: policy, mode: mode).bytes
            }
            return try hash(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: mode
            )
        }

        /// Writes derived BLAKE3 key material for a resident Metal buffer through this context.
        @discardableResult
        public func writeDerivedKey(
            context: String,
            buffer: MTLBuffer,
            length: Int,
            outputByteCount: Int = BLAKE3.digestByteCount,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> Int {
            try writeDerivedKey(
                context: context,
                buffer: buffer,
                range: 0..<length,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                into: outputBuffer
            )
        }

        /// Writes derived BLAKE3 key material for a resident Metal buffer range through this context.
        @discardableResult
        public func writeDerivedKey(
            context: String,
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int = BLAKE3.digestByteCount,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> Int {
            let mode = BLAKE3Metal.deriveKeyMaterialMode(context: context)
            return try writeXOF(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                into: outputBuffer,
                mode: mode
            )
        }

        /// Writes derived key material and returns a digest of the produced output bytes.
        public func writeDerivedKeyAndHashOutput(
            context: String,
            buffer: MTLBuffer,
            length: Int,
            outputByteCount: Int = BLAKE3.digestByteCount,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> BLAKE3.Digest {
            try writeDerivedKeyAndHashOutput(
                context: context,
                buffer: buffer,
                range: 0..<length,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                into: outputBuffer
            )
        }

        /// Writes derived key material for a range and returns a digest of the produced output bytes.
        public func writeDerivedKeyAndHashOutput(
            context: String,
            buffer: MTLBuffer,
            range: Range<Int>,
            outputByteCount: Int = BLAKE3.digestByteCount,
            seek: UInt64 = 0,
            policy: ExecutionPolicy = .automatic,
            into outputBuffer: MTLBuffer
        ) throws -> BLAKE3.Digest {
            let mode = BLAKE3Metal.deriveKeyMaterialMode(context: context)
            return try writeXOFAndHashOutput(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                into: outputBuffer,
                mode: mode
            )
        }

        /// Writes chaining values for complete BLAKE3 chunks in a resident buffer.
        ///
        /// `range` must contain whole 1024-byte chunks. The returned value is the number of chunk chaining
        /// values written into `outputBuffer`.
        @discardableResult
        public func writeChunkChainingValues(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            into outputBuffer: ChunkChainingValueBuffer
        ) throws -> Int {
            try writeChunkChainingValues(
                buffer: buffer,
                range: range,
                baseChunkCounter: baseChunkCounter,
                into: outputBuffer,
                mode: .unkeyed
            )
        }

        @discardableResult
        func writeChunkChainingValues(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            into outputBuffer: ChunkChainingValueBuffer,
            mode: HashMode
        ) throws -> Int {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            guard outputBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Chunk chaining value buffer belongs to a different Metal device.")
            }
            guard range.lowerBound >= 0,
                  range.upperBound <= buffer.length,
                  range.lowerBound <= range.upperBound
            else {
                throw BLAKE3Error.invalidBufferRange
            }
            guard range.count.isMultiple(of: BLAKE3.chunkByteCount) else {
                throw BLAKE3Error.metalCommandFailed("Chunk chaining value ranges must contain only complete BLAKE3 chunks.")
            }

            let chunkCount = range.count / BLAKE3.chunkByteCount
            guard chunkCount <= outputBuffer.chunkCapacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Chunk chaining value output capacity \(outputBuffer.chunkCapacity) is smaller than required chunk count \(chunkCount)."
                )
            }
            guard chunkCount > 0 else {
                outputBuffer.setWrittenChunkCount(0)
                return 0
            }

            outputBuffer.lock.lock()
            defer {
                outputBuffer.lock.unlock()
            }

            return try withWorkspace(chunkCount: chunkCount) { _, _, _, parameterBuffer in
                let commandBuffer = try BLAKE3Metal.makeChunkChainingValuesCommandBuffer(
                    buffer: buffer,
                    range: range,
                    chunkCount: chunkCount,
                    baseChunkCounter: baseChunkCounter,
                    pipelines: pipelines,
                    mode: mode,
                    commandQueue: commandQueue,
                    retainsReferences: false,
                    outputBuffer: outputBuffer.buffer,
                    parameterBuffer: parameterBuffer
                )
                commandBuffer.commit()
                commandBuffer.waitUntilCompleted()

                if let error = commandBuffer.error {
                    throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
                }

                outputBuffer.writtenChunkCount = chunkCount
                return chunkCount
            }
        }

        func chunkSubtreeChainingValue(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            mode: HashMode = .unkeyed
        ) throws -> BLAKE3Core.ChainingValue {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            guard range.lowerBound >= 0,
                  range.upperBound <= buffer.length,
                  range.lowerBound <= range.upperBound
            else {
                throw BLAKE3Error.invalidBufferRange
            }
            guard range.count.isMultiple(of: BLAKE3.chunkByteCount) else {
                throw BLAKE3Error.metalCommandFailed("Subtree chaining value ranges must contain only complete BLAKE3 chunks.")
            }

            let chunkCount = range.count / BLAKE3.chunkByteCount
            guard chunkCount > 0, chunkCount.nonzeroBitCount == 1 else {
                throw BLAKE3Error.metalCommandFailed("Subtree chaining value ranges must contain a power-of-two chunk count.")
            }

            return try withWorkspace(chunkCount: chunkCount) { cvBuffer, scratchBuffer, digestBuffer, parameterBuffer in
                let commandBuffer = try BLAKE3Metal.makeSubtreeChainingValueCommandBuffer(
                    buffer: buffer,
                    range: range,
                    chunkCount: chunkCount,
                    baseChunkCounter: baseChunkCounter,
                    pipelines: pipelines,
                    mode: mode,
                    commandQueue: commandQueue,
                    retainsReferences: false,
                    cvBuffer: cvBuffer,
                    scratchBuffer: scratchBuffer,
                    digestBuffer: digestBuffer,
                    parameterBuffer: parameterBuffer
                )
                commandBuffer.commit()
                commandBuffer.waitUntilCompleted()

                if let error = commandBuffer.error {
                    throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
                }

                return BLAKE3Core.chainingValue(
                    from: UnsafeRawBufferPointer(
                        start: digestBuffer.contents(),
                        count: BLAKE3.digestByteCount
                    )
                )
            }
        }

        /// Async-compatible subtree-CV entry point.
        ///
        /// This currently uses the stable synchronous chunk-CV command path after checking cancellation.
        func chunkSubtreeChainingValueAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            mode: HashMode = .unkeyed
        ) async throws -> BLAKE3Core.ChainingValue {
            try Task.checkCancellation()
            return try chunkSubtreeChainingValue(
                buffer: buffer,
                range: range,
                baseChunkCounter: baseChunkCounter,
                mode: mode
            )
        }

        func chunkSubtreeChainingValueAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            mode: HashMode = .unkeyed,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3Core.ChainingValue {
            _ = asyncWorkspace
            try Task.checkCancellation()
            return try chunkSubtreeChainingValue(
                buffer: buffer,
                range: range,
                baseChunkCounter: baseChunkCounter,
                mode: mode
            )
        }

        /// Async-compatible chaining-value write using the context's default async workspace.
        ///
        /// This currently uses the stable synchronous chunk-CV command path after checking cancellation.
        @discardableResult
        public func writeChunkChainingValuesAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            into outputBuffer: ChunkChainingValueBuffer
        ) async throws -> Int {
            try Task.checkCancellation()
            return try writeChunkChainingValues(
                buffer: buffer,
                range: range,
                baseChunkCounter: baseChunkCounter,
                into: outputBuffer,
                mode: .unkeyed
            )
        }

        @discardableResult
        func writeChunkChainingValuesAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            into outputBuffer: ChunkChainingValueBuffer,
            mode: HashMode
        ) async throws -> Int {
            try Task.checkCancellation()
            return try writeChunkChainingValues(
                buffer: buffer,
                range: range,
                baseChunkCounter: baseChunkCounter,
                into: outputBuffer,
                mode: mode
            )
        }

        /// Async-compatible chaining-value write using a caller-provided async workspace.
        ///
        /// This currently uses the stable synchronous chunk-CV command path after checking cancellation.
        @discardableResult
        public func writeChunkChainingValuesAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            into outputBuffer: ChunkChainingValueBuffer,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> Int {
            _ = asyncWorkspace
            try Task.checkCancellation()
            return try writeChunkChainingValues(
                buffer: buffer,
                range: range,
                baseChunkCounter: baseChunkCounter,
                into: outputBuffer,
                mode: .unkeyed
            )
        }

        @discardableResult
        func writeChunkChainingValuesAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            into outputBuffer: ChunkChainingValueBuffer,
            workspace asyncWorkspace: AsyncWorkspace,
            mode: HashMode
        ) async throws -> Int {
            _ = asyncWorkspace
            try Task.checkCancellation()
            return try writeChunkChainingValues(
                buffer: buffer,
                range: range,
                baseChunkCounter: baseChunkCounter,
                into: outputBuffer,
                mode: mode
            )
        }

        /// Asynchronously hashes a resident Metal buffer through this context.
        public func hashAsync(
            buffer: MTLBuffer,
            length: Int,
            policy: ExecutionPolicy = .automatic
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(buffer: buffer, range: 0..<length, policy: policy, workspace: defaultAsyncWorkspace)
        }

        /// Asynchronously hashes a resident Metal buffer range through this context.
        public func hashAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            policy: ExecutionPolicy = .automatic
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(buffer: buffer, range: range, policy: policy, workspace: defaultAsyncWorkspace)
        }

        /// Asynchronously hashes a resident Metal buffer using a caller-provided workspace.
        public func hashAsync(
            buffer: MTLBuffer,
            length: Int,
            policy: ExecutionPolicy = .automatic,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(buffer: buffer, range: 0..<length, policy: policy, workspace: asyncWorkspace)
        }

        /// Asynchronously hashes a resident Metal buffer range using a caller-provided workspace.
        public func hashAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            policy: ExecutionPolicy = .automatic,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            guard asyncWorkspace.deviceRegistryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Async workspace belongs to a different Metal device.")
            }
            return try await BLAKE3Metal.hashAsync(
                buffer: buffer,
                range: range,
                policy: policy,
                minimumGPUByteCount: minimumGPUByteCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                asyncWorkspace: asyncWorkspace
            )
        }

        /// Hashes all committed bytes in a private input buffer.
        public func hash(
            privateBuffer: PrivateBuffer,
            policy: ExecutionPolicy = .gpu
        ) throws -> BLAKE3.Digest {
            privateBuffer.lock.lock()
            defer {
                privateBuffer.lock.unlock()
            }
            return try hashLocked(privateBuffer: privateBuffer, length: privateBuffer.length, policy: policy)
        }

        /// Hashes a prefix of committed bytes in a private input buffer.
        public func hash(
            privateBuffer: PrivateBuffer,
            length: Int,
            policy: ExecutionPolicy = .gpu
        ) throws -> BLAKE3.Digest {
            privateBuffer.lock.lock()
            defer {
                privateBuffer.lock.unlock()
            }
            return try hashLocked(privateBuffer: privateBuffer, length: length, policy: policy)
        }

        private func hashLocked(
            privateBuffer: PrivateBuffer,
            length: Int,
            policy: ExecutionPolicy
        ) throws -> BLAKE3.Digest {
            guard length >= 0, length <= privateBuffer.length else {
                throw BLAKE3Error.invalidBufferRange
            }
            guard length > 0 else {
                return BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
            }
            if length <= BLAKE3.chunkByteCount, policy != .cpu {
                return try BLAKE3Metal.hashOneChunkBatch(
                    buffer: privateBuffer.buffer,
                    ranges: [0..<length],
                    mode: .unkeyed,
                    pipelines: pipelines,
                    commandQueue: commandQueue
                ).first ?? BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
            }
            return try hash(buffer: privateBuffer.buffer, length: length, policy: policy)
        }

        /// Asynchronously hashes all committed bytes in a private input buffer.
        public func hashAsync(
            privateBuffer: PrivateBuffer,
            policy: ExecutionPolicy = .gpu
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(
                privateBuffer: privateBuffer,
                policy: policy,
                workspace: defaultAsyncWorkspace
            )
        }

        /// Asynchronously hashes a prefix of committed bytes in a private input buffer.
        public func hashAsync(
            privateBuffer: PrivateBuffer,
            length: Int,
            policy: ExecutionPolicy = .gpu
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(
                privateBuffer: privateBuffer,
                length: length,
                policy: policy,
                workspace: defaultAsyncWorkspace
            )
        }

        /// Asynchronously hashes all committed private-buffer bytes using a caller-provided workspace.
        public func hashAsync(
            privateBuffer: PrivateBuffer,
            policy: ExecutionPolicy = .gpu,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            privateBuffer.lockForAsyncUse()
            defer {
                privateBuffer.unlockForAsyncUse()
            }
            return try await hashLockedAsync(
                privateBuffer: privateBuffer,
                length: privateBuffer.length,
                policy: policy,
                workspace: asyncWorkspace
            )
        }

        /// Asynchronously hashes committed private-buffer bytes using a caller-provided workspace.
        public func hashAsync(
            privateBuffer: PrivateBuffer,
            length: Int,
            policy: ExecutionPolicy = .gpu,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            privateBuffer.lockForAsyncUse()
            defer {
                privateBuffer.unlockForAsyncUse()
            }
            return try await hashLockedAsync(
                privateBuffer: privateBuffer,
                length: length,
                policy: policy,
                workspace: asyncWorkspace
            )
        }

        private func hashLockedAsync(
            privateBuffer: PrivateBuffer,
            length: Int,
            policy: ExecutionPolicy,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            guard asyncWorkspace.deviceRegistryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Async workspace belongs to a different Metal device.")
            }
            guard length >= 0, length <= privateBuffer.length else {
                throw BLAKE3Error.invalidBufferRange
            }
            guard length > 0 else {
                return BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
            }
            return try await hashAsync(buffer: privateBuffer.buffer, length: length, policy: policy, workspace: asyncWorkspace)
        }

        /// Copies contiguous input into a staging buffer, then hashes that resident shared buffer.
        public func hash(
            input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try input.withUnsafeBytes { raw in
                try hash(input: raw, using: stagingBuffer, policy: policy)
            }
        }

        /// Copies raw input into a staging buffer, then hashes that resident shared buffer.
        ///
        /// This is an end-to-end timing path because CPU copy/upload work is included.
        public func hash(
            input: UnsafeRawBufferPointer,
            using stagingBuffer: StagingBuffer,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            guard stagingBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Staging buffer belongs to a different Metal device.")
            }
            guard input.count <= stagingBuffer.capacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Input length \(input.count) exceeds staging buffer capacity \(stagingBuffer.capacity)."
                )
            }
            stagingBuffer.lock.lock()
            defer {
                stagingBuffer.lock.unlock()
            }
            if input.count > 0 {
                guard let baseAddress = input.baseAddress else {
                    throw BLAKE3Error.metalCommandFailed("Input bytes are unavailable.")
                }
                stagingBuffer.buffer.contents().copyMemory(
                    from: baseAddress,
                    byteCount: input.count
                )
            }
            return try hash(buffer: stagingBuffer.buffer, length: input.count, policy: policy)
        }

        @_spi(Benchmark)
        public func makeOwnedSharedBuffer(copying input: some ContiguousBytes) throws -> MTLBuffer {
            try input.withUnsafeBytes { raw in
                try makeOwnedSharedBuffer(copying: raw)
            }
        }

        func makeOwnedSharedBuffer(copying input: UnsafeRawBufferPointer) throws -> MTLBuffer {
            guard input.count > 0 else {
                guard let buffer = device.makeBuffer(length: 1, options: .storageModeShared) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate shared Metal buffer.")
                }
                return buffer
            }
            guard let baseAddress = input.baseAddress else {
                throw BLAKE3Error.metalCommandFailed("Input bytes are unavailable.")
            }

            let pageSize = max(Int(getpagesize()), MemoryLayout<UnsafeMutableRawPointer>.alignment)
            let allocationLength = ((input.count - 1) / pageSize + 1) * pageSize
            var allocation: UnsafeMutableRawPointer?
            let status = posix_memalign(&allocation, pageSize, allocationLength)
            guard status == 0, let allocation else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate page-aligned shared Metal buffer.")
            }
            allocation.copyMemory(from: baseAddress, byteCount: input.count)

            let resourceOptions: MTLResourceOptions = if input.count <= BLAKE3Metal.writeCombinedOwnedSharedBufferMaxBytes {
                [.storageModeShared, .cpuCacheModeWriteCombined]
            } else {
                .storageModeShared
            }

            guard let buffer = device.makeBuffer(
                bytesNoCopy: allocation,
                length: allocationLength,
                options: resourceOptions,
                deallocator: { pointer, _ in
                    free(pointer)
                }
            ) else {
                free(allocation)
                throw BLAKE3Error.metalCommandFailed("Unable to allocate shared Metal buffer.")
            }
            return buffer
        }

        /// Asynchronously hashes contiguous input through a staging buffer.
        public func hashAsync(
            input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer,
            policy: ExecutionPolicy = .automatic
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(
                input: input,
                using: stagingBuffer,
                policy: policy,
                workspace: defaultAsyncWorkspace
            )
        }

        /// Asynchronously hashes contiguous input through a staging buffer and caller-provided workspace.
        public func hashAsync(
            input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer,
            policy: ExecutionPolicy = .automatic,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            stagingBuffer.lockForAsyncUse()
            do {
                guard stagingBuffer.buffer.device.registryID == device.registryID else {
                    throw BLAKE3Error.metalCommandFailed("Staging buffer belongs to a different Metal device.")
                }
                guard asyncWorkspace.deviceRegistryID == device.registryID else {
                    throw BLAKE3Error.metalCommandFailed("Async workspace belongs to a different Metal device.")
                }
                let inputLength = try copyInputToStaging(input, stagingBuffer: stagingBuffer)
                let digest = try await hashAsync(
                    buffer: stagingBuffer.buffer,
                    length: inputLength,
                    policy: policy,
                    workspace: asyncWorkspace
                )
                stagingBuffer.unlockForAsyncUse()
                return digest
            } catch {
                stagingBuffer.unlockForAsyncUse()
                throw error
            }
        }

        private func copyInputToStaging(
            _ input: some ContiguousBytes,
            stagingBuffer: StagingBuffer,
            maximumByteCount: Int? = nil,
            maximumLabel: String = "input"
        ) throws -> Int {
            try input.withUnsafeBytes { raw in
                if let maximumByteCount, raw.count > maximumByteCount {
                    throw BLAKE3Error.metalCommandFailed(
                        "Input length \(raw.count) exceeds \(maximumLabel) capacity \(maximumByteCount)."
                    )
                }
                guard raw.count <= stagingBuffer.capacity else {
                    throw BLAKE3Error.metalCommandFailed(
                        "Input length \(raw.count) exceeds staging buffer capacity \(stagingBuffer.capacity)."
                    )
                }
                if raw.count > 0 {
                    guard let baseAddress = raw.baseAddress else {
                        throw BLAKE3Error.metalCommandFailed("Input bytes are unavailable.")
                    }
                    stagingBuffer.buffer.contents().copyMemory(
                        from: baseAddress,
                        byteCount: raw.count
                    )
                }
                return raw.count
            }
        }

        fileprivate func withWorkspace<R>(
            chunkCount: Int,
            _ body: (MTLBuffer, MTLBuffer, MTLBuffer, MTLBuffer) throws -> R
        ) throws -> R {
            lock.lock()
            defer {
                lock.unlock()
            }

            try ensureBuffers(chunkCount: chunkCount)
            guard let chunkCVBuffer,
                  let parentCVBuffer,
                  let digestBuffer,
                  let parameterBuffer
            else {
                throw BLAKE3Error.metalCommandFailed("Metal workspace buffers are unavailable.")
            }
            return try body(chunkCVBuffer, parentCVBuffer, digestBuffer, parameterBuffer)
        }

        fileprivate func withDualParameterWorkspace<R>(
            chunkCount: Int,
            _ body: (MTLBuffer, MTLBuffer, MTLBuffer, MTLBuffer, MTLBuffer) throws -> R
        ) throws -> R {
            lock.lock()
            defer {
                lock.unlock()
            }

            try ensureBuffers(chunkCount: chunkCount)
            let parameterSlotCount = 1 + Self.parentReductionStepCount(for: chunkCount)
            if auxiliaryParameterSlotCapacity < parameterSlotCount {
                guard let buffer = device.makeBuffer(
                    length: parameterSlotCount * Self.parameterSlotStride,
                    options: .storageModeShared
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate auxiliary Metal parameter buffer.")
                }
                auxiliaryParameterBuffer = buffer
                auxiliaryParameterSlotCapacity = parameterSlotCount
            }

            guard let chunkCVBuffer,
                  let parentCVBuffer,
                  let digestBuffer,
                  let parameterBuffer,
                  let auxiliaryParameterBuffer
            else {
                throw BLAKE3Error.metalCommandFailed("Metal workspace buffers are unavailable.")
            }
            return try body(
                chunkCVBuffer,
                parentCVBuffer,
                digestBuffer,
                parameterBuffer,
                auxiliaryParameterBuffer
            )
        }

        private func ensureBuffers(chunkCount: Int) throws {
            let chunkCVByteCount = chunkCount * BLAKE3.digestByteCount
            let parentCVByteCount = ((chunkCount + 1) / 2) * BLAKE3.digestByteCount

            if chunkCVCapacity < chunkCVByteCount {
                let capacity = Self.roundedCapacity(for: chunkCVByteCount)
                guard let buffer = device.makeBuffer(
                    length: capacity,
                    options: .storageModePrivate
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate chunk chaining value buffer.")
                }
                chunkCVBuffer = buffer
                chunkCVCapacity = capacity
            }
            if parentCVCapacity < parentCVByteCount {
                let capacity = Self.roundedCapacity(for: parentCVByteCount)
                guard let buffer = device.makeBuffer(
                    length: capacity,
                    options: .storageModePrivate
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate parent chaining value buffer.")
                }
                parentCVBuffer = buffer
                parentCVCapacity = capacity
            }
            if digestBuffer == nil {
                guard let buffer = device.makeBuffer(
                    length: BLAKE3.digestByteCount,
                    options: .storageModeShared
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate digest buffer.")
                }
                digestBuffer = buffer
            }
            let parameterSlotCount = 1 + Self.parentReductionStepCount(for: chunkCount)
            if parameterSlotCapacity < parameterSlotCount {
                guard let buffer = device.makeBuffer(
                    length: parameterSlotCount * Self.parameterSlotStride,
                    options: .storageModeShared
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate reusable Metal parameter buffer.")
                }
                parameterBuffer = buffer
                parameterSlotCapacity = parameterSlotCount
            }

            guard chunkCVBuffer != nil,
                  parentCVBuffer != nil,
                  digestBuffer != nil,
                  parameterBuffer != nil
            else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate reusable Metal workspace buffers.")
            }
        }

        fileprivate static func roundedCapacity(for byteCount: Int) -> Int {
            var capacity = 4 * 1024
            while capacity < byteCount {
                capacity <<= 1
            }
            return capacity
        }

        fileprivate static let parameterSlotStride = 256

        fileprivate static func parentReductionStepCount(for chunkCount: Int) -> Int {
            var count = chunkCount
            var steps = 0
            while count > 1 {
                if count >= BLAKE3Metal.wideParentReductionThreshold {
                    count = (count + 15) / 16
                } else if count >= BLAKE3Metal.quadParentReductionThreshold {
                    count = (count + 3) / 4
                } else {
                    count = (count + 1) / 2
                }
                steps += 1
            }
            return steps
        }
    }

    /// Pool of reusable Metal buffers for async hashing.
    ///
    /// A workspace can be shared by async calls from the same ``Context``. Calls lease one resource set for
    /// the duration of their command buffer and release it after completion.
    public final class AsyncWorkspace: @unchecked Sendable {
        /// Maximum number of concurrent resource sets retained by the pool.
        public let maxPooledResources: Int
        /// Optional byte count used for eager buffer allocation.
        public let preallocatedByteCount: Int?

        fileprivate let deviceRegistryID: UInt64
        private let pool: AsyncHashResourcePool

        fileprivate init(
            device: MTLDevice,
            maxPooledResources: Int,
            preallocateForByteCount: Int? = nil
        ) throws {
            guard maxPooledResources > 0 else {
                throw BLAKE3Error.metalCommandFailed("Async workspace pool size must be positive.")
            }
            if let preallocateForByteCount, preallocateForByteCount < 0 {
                throw BLAKE3Error.metalCommandFailed("Async workspace preallocation size must be non-negative.")
            }

            self.maxPooledResources = maxPooledResources
            self.preallocatedByteCount = preallocateForByteCount
            self.deviceRegistryID = device.registryID
            self.pool = try AsyncHashResourcePool(
                device: device,
                maxPooledResources: maxPooledResources,
                preallocateForByteCount: preallocateForByteCount
            )
        }

        fileprivate func lease(chunkCount: Int) throws -> AsyncHashResourceLease {
            try pool.lease(chunkCount: chunkCount)
        }

        fileprivate func release(_ lease: AsyncHashResourceLease) {
            pool.release(lease)
        }
    }

    /// Shared Metal buffer containing chunk chaining values.
    ///
    /// The readable byte range is limited to values produced by the last write call. Accessors lock the
    /// object so it can be passed across tasks without exposing partially-written state.
    public final class ChunkChainingValueBuffer: @unchecked Sendable {
        /// Maximum number of chunk chaining values this buffer can hold.
        public let chunkCapacity: Int

        fileprivate let buffer: MTLBuffer
        fileprivate let lock = CrossThreadResourceLock()
        fileprivate var writtenChunkCount = 0

        /// Underlying shared Metal buffer.
        public var metalBuffer: MTLBuffer {
            buffer
        }

        /// Number of chunk chaining values written by the last successful write.
        public var chunkCount: Int {
            lock.lock()
            defer {
                lock.unlock()
            }
            return writtenChunkCount
        }

        /// Number of readable bytes in ``metalBuffer``.
        public var byteCount: Int {
            chunkCount * BLAKE3.digestByteCount
        }

        /// Provides read-only access to written chaining-value bytes for the duration of `body`.
        public func withUnsafeBytes<R>(
            _ body: (UnsafeRawBufferPointer) throws -> R
        ) rethrows -> R {
            lock.lock()
            defer {
                lock.unlock()
            }
            return try body(
                UnsafeRawBufferPointer(
                    start: buffer.contents(),
                    count: writtenChunkCount * BLAKE3.digestByteCount
                )
            )
        }

        fileprivate func setWrittenChunkCount(_ count: Int) {
            lock.lock()
            writtenChunkCount = count
            lock.unlock()
        }

        fileprivate func lockForAsyncUse() {
            lock.lock()
        }

        fileprivate func unlockForAsyncUse() {
            lock.unlock()
        }

        fileprivate init(buffer: MTLBuffer, chunkCapacity: Int) {
            self.buffer = buffer
            self.chunkCapacity = chunkCapacity
        }
    }

    /// Bounded async hashing pipeline with reusable staging resources.
    ///
    /// Calls may be made concurrently. The pipeline limits concurrent work to ``inFlightCount`` slots and
    /// reuses each slot's buffers after the previous command completes.
    public final class AsyncPipeline: @unchecked Sendable {
        /// Maximum accepted byte count for staged input.
        public let inputCapacity: Int
        /// Maximum number of concurrent hashes.
        public let inFlightCount: Int
        /// Execution policy applied to each hash.
        public let policy: ExecutionPolicy
        /// Whether input is uploaded into private Metal buffers before hashing.
        public let usesPrivateBuffers: Bool

        private let context: Context
        private let workspace: AsyncWorkspace
        private let stagingBuffers: [StagingBuffer]
        private let privateBuffers: [PrivateBuffer]?
        private let slots: AsyncPipelineSlotPool

        fileprivate init(
            context: Context,
            inputCapacity: Int,
            inFlightCount: Int,
            policy: ExecutionPolicy,
            usesPrivateBuffers: Bool,
            workspace: AsyncWorkspace,
            stagingBuffers: [StagingBuffer],
            privateBuffers: [PrivateBuffer]?
        ) {
            self.context = context
            self.inputCapacity = inputCapacity
            self.inFlightCount = inFlightCount
            self.policy = policy
            self.usesPrivateBuffers = usesPrivateBuffers
            self.workspace = workspace
            self.stagingBuffers = stagingBuffers
            self.privateBuffers = privateBuffers
            self.slots = AsyncPipelineSlotPool(slotCount: inFlightCount)
        }

        /// Hashes contiguous input using one pipeline slot.
        public func hash(input: some ContiguousBytes) async throws -> BLAKE3.Digest {
            let slot = try slots.acquire()
            defer {
                slots.release(slot)
            }

            if let privateBuffers {
                if let smallInputDigest = input.withUnsafeBytes({ raw -> BLAKE3.Digest? in
                    guard raw.count <= BLAKE3.chunkByteCount else {
                        return nil
                    }
                    return BLAKE3.hash(raw)
                }) {
                    try Task.checkCancellation()
                    return smallInputDigest
                }

                try await context.replaceContentsAsync(
                    of: privateBuffers[slot],
                    with: input,
                    using: stagingBuffers[slot]
                )
                try Task.checkCancellation()
                let digest = try await context.hashAsync(
                    privateBuffer: privateBuffers[slot],
                    policy: policy,
                    workspace: workspace
                )
                try Task.checkCancellation()
                return digest
            }

            let digest = try await context.hashAsync(
                input: input,
                using: stagingBuffers[slot],
                policy: policy,
                workspace: workspace
            )
            try Task.checkCancellation()
            return digest
        }

        /// Hashes a resident Metal buffer using one pipeline slot.
        public func hash(buffer: MTLBuffer, length: Int) async throws -> BLAKE3.Digest {
            let slot = try slots.acquire()
            defer {
                slots.release(slot)
            }
            let digest = try await context.hashAsync(
                buffer: buffer,
                length: length,
                policy: policy,
                workspace: workspace
            )
            try Task.checkCancellation()
            return digest
        }

        /// Hashes a resident Metal buffer range using one pipeline slot.
        public func hash(buffer: MTLBuffer, range: Range<Int>) async throws -> BLAKE3.Digest {
            let slot = try slots.acquire()
            defer {
                slots.release(slot)
            }
            let digest = try await context.hashAsync(
                buffer: buffer,
                range: range,
                policy: policy,
                workspace: workspace
            )
            try Task.checkCancellation()
            return digest
        }

        /// Hashes all committed bytes in a private buffer using one pipeline slot.
        public func hash(privateBuffer: PrivateBuffer) async throws -> BLAKE3.Digest {
            let slot = try slots.acquire()
            defer {
                slots.release(slot)
            }
            let digest = try await context.hashAsync(
                privateBuffer: privateBuffer,
                policy: policy,
                workspace: workspace
            )
            try Task.checkCancellation()
            return digest
        }

        /// Hashes a prefix of committed private-buffer bytes using one pipeline slot.
        public func hash(privateBuffer: PrivateBuffer, length: Int) async throws -> BLAKE3.Digest {
            let slot = try slots.acquire()
            defer {
                slots.release(slot)
            }
            let digest = try await context.hashAsync(
                privateBuffer: privateBuffer,
                length: length,
                policy: policy,
                workspace: workspace
            )
            try Task.checkCancellation()
            return digest
        }
    }

    /// Shared Metal buffer used for CPU-to-GPU staging.
    ///
    /// Hash and upload helpers lock the staging buffer while copying into it and while dependent async GPU
    /// work is pending.
    public final class StagingBuffer: @unchecked Sendable {
        /// Maximum number of input bytes accepted by helpers using this buffer.
        public let capacity: Int
        fileprivate let buffer: MTLBuffer
        fileprivate let lock = CrossThreadResourceLock()

        /// Underlying shared Metal buffer.
        public var metalBuffer: MTLBuffer {
            buffer
        }

        fileprivate func lockForAsyncUse() {
            lock.lock()
        }

        fileprivate func unlockForAsyncUse() {
            lock.unlock()
        }

        fileprivate init(buffer: MTLBuffer, capacity: Int) {
            self.buffer = buffer
            self.capacity = capacity
        }
    }

    /// Private Metal input buffer plus committed byte length.
    ///
    /// The capacity is fixed. Upload helpers update the committed length after successful blits, and hash
    /// helpers lock the object while reading that length.
    public final class PrivateBuffer: @unchecked Sendable {
        /// Maximum number of bytes this private buffer can hold.
        public let capacity: Int
        fileprivate let buffer: MTLBuffer
        fileprivate let lock = CrossThreadResourceLock()
        fileprivate var length: Int

        /// Underlying private Metal buffer.
        public var metalBuffer: MTLBuffer {
            buffer
        }

        /// Number of bytes committed by the most recent successful upload.
        public var byteCount: Int {
            lock.lock()
            defer {
                lock.unlock()
            }
            return length
        }

        fileprivate func lockForAsyncUse() {
            lock.lock()
        }

        fileprivate func unlockForAsyncUse() {
            lock.unlock()
        }

        fileprivate init(buffer: MTLBuffer, capacity: Int, length: Int) {
            self.buffer = buffer
            self.capacity = capacity
            self.length = length
        }
    }

    private final class AsyncPipelineSlotPool: @unchecked Sendable {
        private let semaphore: DispatchSemaphore
        private let lock = NSLock()
        private var availableSlots: [Int]

        init(slotCount: Int) {
            self.semaphore = DispatchSemaphore(value: slotCount)
            self.availableSlots = Array((0..<slotCount).reversed())
        }

        func acquire() throws -> Int {
            try Task.checkCancellation()
            semaphore.wait()
            if Task.isCancelled {
                semaphore.signal()
                throw CancellationError()
            }

            lock.lock()
            guard let slot = availableSlots.popLast() else {
                lock.unlock()
                semaphore.signal()
                throw BLAKE3Error.metalCommandFailed("Async pipeline slot accounting failed.")
            }
            lock.unlock()
            return slot
        }

        func release(_ slot: Int) {
            lock.lock()
            availableSlots.append(slot)
            lock.unlock()
            semaphore.signal()
        }
    }

    fileprivate struct AsyncHashResourceLease: Sendable {
        let resources: AsyncHashResources
        let isPooled: Bool
    }

    fileprivate final class AsyncHashResourcePool: @unchecked Sendable {
        private let device: MTLDevice
        private let maxPooledResources: Int
        private let lock = NSLock()
        private var pooledResourceCount = 0
        private var idleResources: [AsyncHashResources] = []

        init(
            device: MTLDevice,
            maxPooledResources: Int,
            preallocateForByteCount: Int?
        ) throws {
            self.device = device
            self.maxPooledResources = maxPooledResources

            guard let preallocateForByteCount else {
                return
            }

            let chunkCount = max(
                1,
                (preallocateForByteCount + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount
            )
            for _ in 0..<maxPooledResources {
                let resources = AsyncHashResources(device: device)
                try resources.ensureBuffers(chunkCount: chunkCount)
                idleResources.append(resources)
                pooledResourceCount += 1
            }
        }

        func lease(chunkCount: Int) throws -> AsyncHashResourceLease {
            lock.lock()
            if let resources = idleResources.popLast() {
                lock.unlock()
                do {
                    try resources.ensureBuffers(chunkCount: chunkCount)
                    return AsyncHashResourceLease(resources: resources, isPooled: true)
                } catch {
                    lock.lock()
                    pooledResourceCount -= 1
                    lock.unlock()
                    throw error
                }
            }
            if pooledResourceCount < maxPooledResources {
                pooledResourceCount += 1
                lock.unlock()
                do {
                    let resources = AsyncHashResources(device: device)
                    try resources.ensureBuffers(chunkCount: chunkCount)
                    return AsyncHashResourceLease(resources: resources, isPooled: true)
                } catch {
                    lock.lock()
                    pooledResourceCount -= 1
                    lock.unlock()
                    throw error
                }
            }
            lock.unlock()

            let resources = AsyncHashResources(device: device)
            try resources.ensureBuffers(chunkCount: chunkCount)
            return AsyncHashResourceLease(resources: resources, isPooled: false)
        }

        func release(_ lease: AsyncHashResourceLease) {
            guard lease.isPooled else {
                return
            }
            lock.lock()
            idleResources.append(lease.resources)
            lock.unlock()
        }
    }

    fileprivate struct AsyncHashBuffers: @unchecked Sendable {
        let chunkCVBuffer: MTLBuffer
        let parentCVBuffer: MTLBuffer
        let digestBuffer: MTLBuffer
        let parameterBuffer: MTLBuffer
    }

    fileprivate final class AsyncHashResources: @unchecked Sendable {
        private let device: MTLDevice
        private var chunkCVBuffer: MTLBuffer?
        private var parentCVBuffer: MTLBuffer?
        private var digestBuffer: MTLBuffer?
        private var parameterBuffer: MTLBuffer?
        private var chunkCVCapacity = 0
        private var parentCVCapacity = 0
        private var parameterSlotCapacity = 0

        init(device: MTLDevice) {
            self.device = device
        }

        func ensureBuffers(chunkCount: Int) throws {
            let chunkCVByteCount = chunkCount * BLAKE3.digestByteCount
            let parentCVByteCount = ((chunkCount + 1) / 2) * BLAKE3.digestByteCount

            if chunkCVCapacity < chunkCVByteCount {
                let capacity = Context.roundedCapacity(for: chunkCVByteCount)
                guard let buffer = device.makeBuffer(
                    length: capacity,
                    options: .storageModePrivate
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate async chunk chaining value buffer.")
                }
                chunkCVBuffer = buffer
                chunkCVCapacity = capacity
            }
            if parentCVCapacity < parentCVByteCount {
                let capacity = Context.roundedCapacity(for: parentCVByteCount)
                guard let buffer = device.makeBuffer(
                    length: capacity,
                    options: .storageModePrivate
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate async parent chaining value buffer.")
                }
                parentCVBuffer = buffer
                parentCVCapacity = capacity
            }
            if digestBuffer == nil {
                guard let buffer = device.makeBuffer(
                    length: BLAKE3.digestByteCount,
                    options: .storageModeShared
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate async digest buffer.")
                }
                digestBuffer = buffer
            }
            let parameterSlotCount = 1 + Context.parentReductionStepCount(for: chunkCount)
            if parameterSlotCapacity < parameterSlotCount {
                guard let buffer = device.makeBuffer(
                    length: parameterSlotCount * Context.parameterSlotStride,
                    options: .storageModeShared
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate async parameter buffer.")
                }
                parameterBuffer = buffer
                parameterSlotCapacity = parameterSlotCount
            }
        }

        func buffers() throws -> AsyncHashBuffers {
            guard let chunkCVBuffer,
                  let parentCVBuffer,
                  let digestBuffer,
                  let parameterBuffer
            else {
                throw BLAKE3Error.metalCommandFailed("Async Metal workspace buffers are unavailable.")
            }
            return AsyncHashBuffers(
                chunkCVBuffer: chunkCVBuffer,
                parentCVBuffer: parentCVBuffer,
                digestBuffer: digestBuffer,
                parameterBuffer: parameterBuffer
            )
        }
    }

    private static func hash(
        buffer: MTLBuffer,
        range: Range<Int>,
        policy: ExecutionPolicy,
        mode: HashMode = .unkeyed,
        minimumGPUByteCount: Int,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        workspace: Context,
        allowsFusedTile: Bool = true
    ) throws -> BLAKE3.Digest {
        guard range.lowerBound >= 0,
              range.upperBound <= buffer.length,
              range.lowerBound <= range.upperBound
        else {
            throw BLAKE3Error.invalidBufferRange
        }

        switch policy {
        case .cpu:
            return try hashOnCPU(buffer: buffer, range: range, mode: mode)
        case .automatic:
            guard range.count >= minimumGPUByteCount || buffer.storageMode == .private else {
                return try hashOnCPU(buffer: buffer, range: range, mode: mode)
            }
        case .gpu:
            break
        }

        guard range.count > BLAKE3.chunkByteCount else {
            return try hashOnCPU(buffer: buffer, range: range, mode: mode)
        }

        let chunkCount = (range.count + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount

        return try workspace.withWorkspace(chunkCount: chunkCount) { cvBuffer, scratchBuffer, digestBuffer, parameterBuffer in
            let commandBuffer = try makeHashCommandBuffer(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                retainsReferences: false,
                mode: mode,
                allowsFusedTile: allowsFusedTile,
                cvBuffer: cvBuffer,
                scratchBuffer: scratchBuffer,
                digestBuffer: digestBuffer,
                parameterBuffer: parameterBuffer
            )
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }

            return BLAKE3.Digest(
                UnsafeRawBufferPointer(
                    start: digestBuffer.contents(),
                    count: BLAKE3.digestByteCount
                )
            )
        }
    }

    private static func hashAsync(
        buffer: MTLBuffer,
        range: Range<Int>,
        policy: ExecutionPolicy,
        mode: HashMode = .unkeyed,
        minimumGPUByteCount: Int,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        asyncWorkspace: AsyncWorkspace
    ) async throws -> BLAKE3.Digest {
        guard range.lowerBound >= 0,
              range.upperBound <= buffer.length,
              range.lowerBound <= range.upperBound
        else {
            throw BLAKE3Error.invalidBufferRange
        }
        guard asyncWorkspace.deviceRegistryID == buffer.device.registryID else {
            throw BLAKE3Error.metalCommandFailed("Async workspace belongs to a different Metal device.")
        }

        switch policy {
        case .cpu:
            return try hashOnCPU(buffer: buffer, range: range, mode: mode)
        case .automatic:
            guard range.count >= minimumGPUByteCount || buffer.storageMode == .private else {
                return try hashOnCPU(buffer: buffer, range: range, mode: mode)
            }
        case .gpu:
            break
        }

        guard range.count > BLAKE3.chunkByteCount else {
            return try hashOnCPU(buffer: buffer, range: range, mode: mode)
        }

        let chunkCount = (range.count + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount
        let lease = try asyncWorkspace.lease(chunkCount: chunkCount)
        let resources = lease.resources
        let buffers: AsyncHashBuffers
        do {
            buffers = try resources.buffers()
        } catch {
            asyncWorkspace.release(lease)
            throw error
        }
        let commandBuffer: MTLCommandBuffer
        do {
            commandBuffer = try makeHashCommandBuffer(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                retainsReferences: true,
                mode: mode,
                cvBuffer: buffers.chunkCVBuffer,
                scratchBuffer: buffers.parentCVBuffer,
                digestBuffer: buffers.digestBuffer,
                parameterBuffer: buffers.parameterBuffer
            )
        } catch {
            asyncWorkspace.release(lease)
            throw error
        }

        return try await withCheckedThrowingContinuation { continuation in
            commandBuffer.addCompletedHandler { completedBuffer in
                if let error = completedBuffer.error {
                    asyncWorkspace.release(lease)
                    continuation.resume(throwing: BLAKE3Error.metalCommandFailed(error.localizedDescription))
                    return
                }
                let digest = BLAKE3.Digest(
                    UnsafeRawBufferPointer(
                        start: buffers.digestBuffer.contents(),
                        count: BLAKE3.digestByteCount
                    )
                )
                asyncWorkspace.release(lease)
                continuation.resume(returning: digest)
            }
            commandBuffer.commit()
        }
    }

    private static func xof(
        buffer: MTLBuffer,
        range: Range<Int>,
        outputByteCount: Int,
        seek: UInt64,
        policy: ExecutionPolicy,
        mode: HashMode = .unkeyed,
        minimumGPUByteCount: Int,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        workspace: Context
    ) throws -> [UInt8] {
        try validateOutputByteCount(outputByteCount)
        guard outputByteCount > 0 else {
            return []
        }

        var output = [UInt8](repeating: 0, count: outputByteCount)
        try output.withUnsafeMutableBytes { rawOutput in
            guard let baseAddress = rawOutput.baseAddress,
                  let outputBuffer = buffer.device.makeBuffer(
                    bytesNoCopy: baseAddress,
                    length: outputByteCount,
                    options: .storageModeShared,
                    deallocator: nil
                  )
            else {
                throw BLAKE3Error.metalCommandFailed("Unable to wrap BLAKE3 XOF output in a Metal buffer.")
            }

            try writeXOF(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: mode,
                minimumGPUByteCount: minimumGPUByteCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: workspace,
                outputBuffer: outputBuffer
            )
        }
        return output
    }

    @discardableResult
    private static func writeXOF(
        buffer: MTLBuffer,
        range: Range<Int>,
        outputByteCount: Int,
        seek: UInt64,
        policy: ExecutionPolicy,
        mode: HashMode,
        minimumGPUByteCount: Int,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        workspace: Context,
        outputBuffer: MTLBuffer
    ) throws -> Int {
        guard buffer.device.registryID == outputBuffer.device.registryID else {
            throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
        }
        guard range.lowerBound >= 0,
              range.upperBound <= buffer.length,
              range.lowerBound <= range.upperBound
        else {
            throw BLAKE3Error.invalidBufferRange
        }
        try validateOutputByteCount(outputByteCount)
        guard outputBuffer.length >= outputByteCount else {
            throw BLAKE3Error.metalCommandFailed(
                "BLAKE3 XOF output buffer must hold \(outputByteCount) bytes."
            )
        }
        guard outputByteCount > 0 else {
            return 0
        }
        let outputByteCount64 = UInt64(outputByteCount)
        guard UInt64.max - seek >= outputByteCount64 else {
            throw BLAKE3Error.metalCommandFailed("BLAKE3 XOF output range overflows UInt64.")
        }

        switch policy {
        case .cpu:
            return try writeXOFOnCPU(
                buffer: buffer,
                range: range,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                outputBuffer: outputBuffer
            )
        case .automatic:
            let canUseCPUFallback = buffer.storageMode != .private && outputBuffer.storageMode != .private
            guard range.count >= minimumGPUByteCount || buffer.storageMode == .private || !canUseCPUFallback else {
                return try writeXOFOnCPU(
                    buffer: buffer,
                    range: range,
                    mode: mode,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    outputBuffer: outputBuffer
                )
            }
        case .gpu:
            break
        }

        guard range.count > BLAKE3.chunkByteCount else {
            return try writeXOFOnCPU(
                buffer: buffer,
                range: range,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                outputBuffer: outputBuffer
            )
        }

        let chunkCount = (range.count + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount
        try workspace.withWorkspace(chunkCount: chunkCount) { cvBuffer, scratchBuffer, _, parameterBuffer in
            let commandBuffer = try makeXOFCommandBuffer(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                outputByteCount: outputByteCount,
                seek: seek,
                pipelines: pipelines,
                commandQueue: commandQueue,
                retainsReferences: false,
                mode: mode,
                cvBuffer: cvBuffer,
                scratchBuffer: scratchBuffer,
                outputBuffer: outputBuffer,
                parameterBuffer: parameterBuffer
            )
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }
        }
        return outputByteCount
    }

    private static func writeXOFAndHashOutput(
        buffer: MTLBuffer,
        range: Range<Int>,
        outputByteCount: Int,
        seek: UInt64,
        policy: ExecutionPolicy,
        mode: HashMode,
        minimumGPUByteCount: Int,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        workspace: Context,
        outputBuffer: MTLBuffer
    ) throws -> BLAKE3.Digest {
        guard buffer.device.registryID == outputBuffer.device.registryID else {
            throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
        }
        guard range.lowerBound >= 0,
              range.upperBound <= buffer.length,
              range.lowerBound <= range.upperBound
        else {
            throw BLAKE3Error.invalidBufferRange
        }
        try validateOutputByteCount(outputByteCount)
        guard outputBuffer.length >= outputByteCount else {
            throw BLAKE3Error.metalCommandFailed(
                "BLAKE3 XOF output buffer must hold \(outputByteCount) bytes."
            )
        }
        guard outputByteCount > 0 else {
            return BLAKE3.hashCPU([UInt8]())
        }
        let outputByteCount64 = UInt64(outputByteCount)
        guard UInt64.max - seek >= outputByteCount64 else {
            throw BLAKE3Error.metalCommandFailed("BLAKE3 XOF output range overflows UInt64.")
        }

        switch policy {
        case .cpu:
            try writeXOF(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: mode,
                minimumGPUByteCount: minimumGPUByteCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: workspace,
                outputBuffer: outputBuffer
            )
            return try hashOnCPU(buffer: outputBuffer, range: 0..<outputByteCount, mode: .unkeyed)
        case .automatic:
            let canUseCPUFallback = buffer.storageMode != .private && outputBuffer.storageMode != .private
            if range.count < minimumGPUByteCount && canUseCPUFallback {
                try writeXOF(
                    buffer: buffer,
                    range: range,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    policy: policy,
                    mode: mode,
                    minimumGPUByteCount: minimumGPUByteCount,
                    pipelines: pipelines,
                    commandQueue: commandQueue,
                    workspace: workspace,
                    outputBuffer: outputBuffer
                )
                return try hashOnCPU(buffer: outputBuffer, range: 0..<outputByteCount, mode: .unkeyed)
            }
        case .gpu:
            break
        }

        guard range.count > BLAKE3.chunkByteCount else {
            try writeXOF(
                buffer: buffer,
                range: range,
                outputByteCount: outputByteCount,
                seek: seek,
                policy: policy,
                mode: mode,
                minimumGPUByteCount: minimumGPUByteCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: workspace,
                outputBuffer: outputBuffer
            )
            if outputByteCount <= BLAKE3.chunkByteCount {
                return try hashOneChunkBatch(
                    buffer: outputBuffer,
                    ranges: [0..<outputByteCount],
                    mode: .unkeyed,
                    pipelines: pipelines,
                    commandQueue: commandQueue
                ).first!
            }
            return try hash(
                buffer: outputBuffer,
                range: 0..<outputByteCount,
                policy: .gpu,
                mode: .unkeyed,
                minimumGPUByteCount: 0,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: workspace
            )
        }

        let inputChunkCount = (range.count + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount
        let outputChunkCount = (outputByteCount + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount
        let workspaceChunkCount = max(inputChunkCount, outputChunkCount)

        return try workspace.withDualParameterWorkspace(chunkCount: workspaceChunkCount) {
            cvBuffer,
            scratchBuffer,
            digestBuffer,
            xofParameterBuffer,
            outputHashParameterBuffer in
            let commandBuffer = commandQueue.makeCommandBuffer()
            guard let commandBuffer,
                  let xofEncoder = commandBuffer.makeComputeCommandEncoder()
            else {
                throw BLAKE3Error.metalCommandFailed(
                    "Unable to create BLAKE3 chained XOF command buffer or encoder."
                )
            }

            try encodeXOFCommands(
                buffer: buffer,
                range: range,
                chunkCount: inputChunkCount,
                outputByteCount: outputByteCount,
                seek: seek,
                pipelines: pipelines,
                mode: mode,
                cvBuffer: cvBuffer,
                scratchBuffer: scratchBuffer,
                outputBuffer: outputBuffer,
                parameterBuffer: xofParameterBuffer,
                encoder: xofEncoder
            )

            guard let outputHashEncoder = commandBuffer.makeComputeCommandEncoder() else {
                throw BLAKE3Error.metalCommandFailed("Unable to create BLAKE3 output digest encoder.")
            }
            if outputByteCount <= BLAKE3.chunkByteCount {
                var entry = BLAKE3MetalBatchEntry(
                    inputOffset: 0,
                    inputLength: UInt32(outputByteCount)
                )
                guard let entriesBuffer = withUnsafeBytes(of: &entry, { raw in
                    buffer.device.makeBuffer(
                        bytes: raw.baseAddress!,
                        length: raw.count,
                        options: .storageModeShared
                    )
                }) else {
                    outputHashEncoder.endEncoding()
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 output digest entry buffer.")
                }
                let params = BLAKE3MetalBatchParams(
                    entryCount: 1,
                    canLoadWords: canLoadWords(buffer: outputBuffer, range: 0..<outputByteCount) ? 1 : 0,
                    key: HashMode.unkeyed.metalKey,
                    flags: HashMode.unkeyed.flags
                )
                copyParameter(params, into: outputHashParameterBuffer, slot: 0)
                let pipeline = pipelines.batchOneChunkDigest
                outputHashEncoder.setComputePipelineState(pipeline)
                outputHashEncoder.setBuffer(outputBuffer, offset: 0, index: 0)
                outputHashEncoder.setBuffer(entriesBuffer, offset: 0, index: 1)
                outputHashEncoder.setBuffer(digestBuffer, offset: 0, index: 2)
                outputHashEncoder.setBuffer(outputHashParameterBuffer, offset: 0, index: 3)
                dispatchThreads(count: 1, pipeline: pipeline, encoder: outputHashEncoder)
                outputHashEncoder.endEncoding()
            } else {
                try encodeHashCommands(
                    buffer: outputBuffer,
                    range: 0..<outputByteCount,
                    chunkCount: outputChunkCount,
                    pipelines: pipelines,
                    mode: .unkeyed,
                    cvBuffer: cvBuffer,
                    scratchBuffer: scratchBuffer,
                    digestBuffer: digestBuffer,
                    parameterBuffer: outputHashParameterBuffer,
                    encoder: outputHashEncoder
                )
            }

            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }

            return BLAKE3.Digest(
                UnsafeRawBufferPointer(
                    start: digestBuffer.contents(),
                    count: BLAKE3.digestByteCount
                )
            )
        }
    }

    private static func hashOneChunkBatch(
        buffer: MTLBuffer,
        ranges: [Range<Int>],
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue
    ) throws -> [BLAKE3.Digest] {
        let plan = try buildOneChunkBatchPlan(buffer: buffer, ranges: ranges)
        return try hashOneChunkBatch(
            plan: plan,
            mode: mode,
            pipelines: pipelines,
            commandQueue: commandQueue
        )
    }

    private static func hashOneChunkBatch(
        plan: OneChunkBatchPlan,
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue
    ) throws -> [BLAKE3.Digest] {
        guard plan.digestCount > 0 else {
            return []
        }

        guard let digestBuffer = plan.buffer.device.makeBuffer(
            length: plan.outputByteCount,
            options: .storageModeShared
        ) else {
            throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 batch digest buffer.")
        }

        try writeOneChunkBatchDigests(
            plan: plan,
            mode: mode,
            pipelines: pipelines,
            commandQueue: commandQueue,
            outputBuffer: digestBuffer
        )

        return readBatchDigests(from: digestBuffer, count: plan.digestCount)
    }

    private struct OneChunkBatchDescriptor {
        var entries: [BLAKE3MetalBatchEntry]
        var canLoadWords: Bool
        var contiguousSingleBlocks: Bool
        var allSingleBlocks: Bool
        var allFullChunks: Bool
    }

    private static func makeOneChunkBatchDescriptor(
        buffer: MTLBuffer,
        ranges: [Range<Int>]
    ) throws -> OneChunkBatchDescriptor {
        guard ranges.count <= Int(UInt32.max) else {
            throw BLAKE3Error.metalCommandFailed("BLAKE3 batch entry count exceeds UInt32 capacity.")
        }

        var entries = [BLAKE3MetalBatchEntry]()
        entries.reserveCapacity(ranges.count)
        var canLoadEveryRange = true
        var contiguousSingleBlocks = true
        var allSingleBlocks = true
        var allFullChunks = true
        let firstLowerBound = ranges.first?.lowerBound ?? 0
        for range in ranges {
            let entryIndex = entries.count
            guard range.lowerBound >= 0,
                  range.upperBound <= buffer.length,
                  range.lowerBound <= range.upperBound
            else {
                throw BLAKE3Error.invalidBufferRange
            }
            guard range.count <= BLAKE3.chunkByteCount else {
                throw BLAKE3Error.metalCommandFailed(
                    "BLAKE3 one-chunk batch ranges must be at most \(BLAKE3.chunkByteCount) bytes."
                )
            }
            entries.append(
                BLAKE3MetalBatchEntry(
                    inputOffset: UInt64(range.lowerBound),
                    inputLength: UInt32(range.count)
                )
            )
            canLoadEveryRange = canLoadEveryRange && canLoadWords(buffer: buffer, range: range)
            let expectedSingleBlockLowerBound = firstLowerBound + entryIndex * BLAKE3.blockByteCount
            contiguousSingleBlocks = contiguousSingleBlocks
                && range.count == BLAKE3.blockByteCount
                && range.lowerBound == expectedSingleBlockLowerBound
            allSingleBlocks = allSingleBlocks && range.count == BLAKE3.blockByteCount
            allFullChunks = allFullChunks && range.count == BLAKE3.chunkByteCount
        }

        return OneChunkBatchDescriptor(
            entries: entries,
            canLoadWords: canLoadEveryRange,
            contiguousSingleBlocks: contiguousSingleBlocks,
            allSingleBlocks: allSingleBlocks,
            allFullChunks: allFullChunks
        )
    }

    private static func buildOneChunkBatchPlan(
        buffer: MTLBuffer,
        ranges: [Range<Int>]
    ) throws -> OneChunkBatchPlan {
        let descriptor = try makeOneChunkBatchDescriptor(buffer: buffer, ranges: ranges)
        let entriesBuffer: MTLBuffer?
        if descriptor.entries.isEmpty {
            entriesBuffer = buffer.device.makeBuffer(length: 1, options: .storageModeShared)
        } else {
            entriesBuffer = descriptor.entries.withUnsafeBytes { raw in
                buffer.device.makeBuffer(
                    bytes: raw.baseAddress!,
                    length: raw.count,
                    options: .storageModeShared
                )
            }
        }
        guard let entriesBuffer else {
            throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 batch entry buffer.")
        }
        guard let parameterBuffer = buffer.device.makeBuffer(
            length: Context.parameterSlotStride,
            options: .storageModeShared
        ) else {
            throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 batch parameter buffer.")
        }

        return OneChunkBatchPlan(
            buffer: buffer,
            digestCount: descriptor.entries.count,
            entriesBuffer: entriesBuffer,
            parameterBuffer: parameterBuffer,
            canLoadWords: descriptor.canLoadWords,
            contiguousSingleBlocks: descriptor.contiguousSingleBlocks,
            allSingleBlocks: descriptor.allSingleBlocks,
            allFullChunks: descriptor.allFullChunks
        )
    }

    private static func oneChunkBatchDigestPipeline(
        for plan: OneChunkBatchPlan,
        pipelines: BLAKE3MetalPipelines
    ) -> MTLComputePipelineState {
        if plan.contiguousSingleBlocks {
            return pipelines.batchOneContiguousBlockDigest
        }
        if plan.allSingleBlocks {
            return pipelines.batchOneBlockDigest
        }
        if plan.allFullChunks {
            return pipelines.batchOneFullChunkDigest
        }
        return pipelines.batchOneChunkDigest
    }

    private static func oneChunkBatchOutputChunkCVPipeline(
        for plan: OneChunkBatchPlan,
        pipelines: BLAKE3MetalPipelines
    ) -> MTLComputePipelineState {
        if plan.contiguousSingleBlocks {
            return pipelines.batchOneContiguousBlockOutputChunkCVs
        }
        if plan.allSingleBlocks {
            return pipelines.batchOneBlockOutputChunkCVs
        }
        if plan.allFullChunks {
            return pipelines.batchOneFullChunkOutputChunkCVs
        }
        return pipelines.batchOneChunkOutputChunkCVs
    }

    private static func buildOneChunkBatchWritePipeline(
        plan: OneChunkBatchPlan,
        outputBuffers: [MTLBuffer]
    ) throws -> OneChunkBatchWritePipeline {
        guard !outputBuffers.isEmpty else {
            throw BLAKE3Error.metalCommandFailed("BLAKE3 batch write pipeline requires at least one output buffer.")
        }
        let requiredOutputByteCount = plan.outputByteCount
        for outputBuffer in outputBuffers {
            guard outputBuffer.device.registryID == plan.buffer.device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
            }
            guard outputBuffer.length >= requiredOutputByteCount else {
                throw BLAKE3Error.metalCommandFailed(
                    "BLAKE3 batch output buffer must hold \(requiredOutputByteCount) bytes."
                )
            }
        }

        var parameterBuffers = [MTLBuffer]()
        parameterBuffers.reserveCapacity(outputBuffers.count)
        for _ in outputBuffers {
            guard let parameterBuffer = plan.buffer.device.makeBuffer(
                length: Context.parameterSlotStride,
                options: .storageModeShared
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 batch pipeline parameter buffer.")
            }
            parameterBuffers.append(parameterBuffer)
        }

        return OneChunkBatchWritePipeline(
            plan: plan,
            outputBuffers: outputBuffers,
            parameterBuffers: parameterBuffers
        )
    }

    private static func buildOneChunkBatchChainedPipeline(
        plan: OneChunkBatchPlan,
        outputBuffers: [MTLBuffer]
    ) throws -> OneChunkBatchChainedPipeline {
        guard !outputBuffers.isEmpty else {
            throw BLAKE3Error.metalCommandFailed("BLAKE3 chained batch pipeline requires at least one output buffer.")
        }
        let requiredOutputByteCount = plan.outputByteCount
        for outputBuffer in outputBuffers {
            guard outputBuffer.device.registryID == plan.buffer.device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
            }
            guard outputBuffer.length >= requiredOutputByteCount else {
                throw BLAKE3Error.metalCommandFailed(
                    "BLAKE3 batch output buffer must hold \(requiredOutputByteCount) bytes."
                )
            }
        }

        let outputChunkCount = max(
            1,
            (requiredOutputByteCount + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount
        )
        let chunkCVByteCount = Context.roundedCapacity(
            for: outputChunkCount * BLAKE3.digestByteCount
        )
        let scratchByteCount = Context.roundedCapacity(
            for: ((outputChunkCount + 1) / 2) * BLAKE3.digestByteCount
        )
        let outputHashParameterSlotCount = 1 + Context.parentReductionStepCount(for: outputChunkCount)
        let outputHashParameterByteCount = outputHashParameterSlotCount * Context.parameterSlotStride

        let outputEntryBuffer: MTLBuffer?
        if requiredOutputByteCount <= BLAKE3.chunkByteCount {
            var outputEntry = BLAKE3MetalBatchEntry(
                inputOffset: 0,
                inputLength: UInt32(requiredOutputByteCount)
            )
            outputEntryBuffer = withUnsafeBytes(of: &outputEntry) { raw in
                plan.buffer.device.makeBuffer(
                    bytes: raw.baseAddress!,
                    length: raw.count,
                    options: .storageModeShared
                )
            }
            guard outputEntryBuffer != nil else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 batch output digest entry buffer.")
            }
        } else {
            outputEntryBuffer = nil
        }

        var outputCanLoadWords = [Bool]()
        var batchParameterBuffers = [MTLBuffer]()
        var outputHashParameterBuffers = [MTLBuffer]()
        var chunkCVBuffers = [MTLBuffer]()
        var scratchBuffers = [MTLBuffer]()
        var digestBuffers = [MTLBuffer]()
        outputCanLoadWords.reserveCapacity(outputBuffers.count)
        batchParameterBuffers.reserveCapacity(outputBuffers.count)
        outputHashParameterBuffers.reserveCapacity(outputBuffers.count)
        chunkCVBuffers.reserveCapacity(outputBuffers.count)
        scratchBuffers.reserveCapacity(outputBuffers.count)
        digestBuffers.reserveCapacity(outputBuffers.count)

        for outputBuffer in outputBuffers {
            outputCanLoadWords.append(canLoadWords(buffer: outputBuffer, range: 0..<requiredOutputByteCount))
            guard let batchParameterBuffer = plan.buffer.device.makeBuffer(
                length: Context.parameterSlotStride,
                options: .storageModeShared
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 chained batch parameter buffer.")
            }
            guard let outputHashParameterBuffer = plan.buffer.device.makeBuffer(
                length: outputHashParameterByteCount,
                options: .storageModeShared
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 chained output parameter buffer.")
            }
            guard let chunkCVBuffer = plan.buffer.device.makeBuffer(
                length: chunkCVByteCount,
                options: .storageModePrivate
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 chained chunk CV buffer.")
            }
            guard let scratchBuffer = plan.buffer.device.makeBuffer(
                length: scratchByteCount,
                options: .storageModePrivate
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 chained scratch buffer.")
            }
            guard let digestBuffer = plan.buffer.device.makeBuffer(
                length: BLAKE3.digestByteCount,
                options: .storageModeShared
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 chained digest buffer.")
            }
            batchParameterBuffers.append(batchParameterBuffer)
            outputHashParameterBuffers.append(outputHashParameterBuffer)
            chunkCVBuffers.append(chunkCVBuffer)
            scratchBuffers.append(scratchBuffer)
            digestBuffers.append(digestBuffer)
        }

        return OneChunkBatchChainedPipeline(
            plan: plan,
            outputBuffers: outputBuffers,
            outputChunkCount: outputChunkCount,
            outputEntryBuffer: outputEntryBuffer,
            outputCanLoadWords: outputCanLoadWords,
            batchParameterBuffers: batchParameterBuffers,
            outputHashParameterBuffers: outputHashParameterBuffers,
            chunkCVBuffers: chunkCVBuffers,
            scratchBuffers: scratchBuffers,
            digestBuffers: digestBuffers
        )
    }

    @discardableResult
    private static func writeOneChunkBatchDigests(
        buffer: MTLBuffer,
        ranges: [Range<Int>],
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        outputBuffer: MTLBuffer
    ) throws -> Int {
        let plan = try buildOneChunkBatchPlan(buffer: buffer, ranges: ranges)
        return try writeOneChunkBatchDigests(
            plan: plan,
            mode: mode,
            pipelines: pipelines,
            commandQueue: commandQueue,
            outputBuffer: outputBuffer
        )
    }

    @discardableResult
    private static func writeOneChunkBatchDigests(
        plan: OneChunkBatchPlan,
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        outputBuffer: MTLBuffer
    ) throws -> Int {
        guard plan.digestCount > 0 else {
            return 0
        }
        let requiredOutputByteCount = plan.outputByteCount
        guard outputBuffer.length >= requiredOutputByteCount else {
            throw BLAKE3Error.metalCommandFailed(
                "BLAKE3 batch output buffer must hold \(requiredOutputByteCount) bytes."
            )
        }

        plan.lock.lock()
        defer {
            plan.lock.unlock()
        }

        let params = BLAKE3MetalBatchParams(
            entryCount: UInt32(plan.digestCount),
            canLoadWords: plan.canLoadWords ? 1 : 0,
            key: mode.metalKey,
            flags: mode.flags
        )
        copyParameter(params, into: plan.parameterBuffer, slot: 0)

        guard let commandBuffer = commandQueue.makeCommandBufferWithUnretainedReferences(),
              let encoder = commandBuffer.makeComputeCommandEncoder()
        else {
            throw BLAKE3Error.metalCommandFailed("Unable to create BLAKE3 batch command buffer.")
        }

        let pipeline = oneChunkBatchDigestPipeline(for: plan, pipelines: pipelines)
        encoder.setComputePipelineState(pipeline)
        encoder.setBuffer(plan.buffer, offset: 0, index: 0)
        encoder.setBuffer(plan.entriesBuffer, offset: 0, index: 1)
        encoder.setBuffer(outputBuffer, offset: 0, index: 2)
        encoder.setBuffer(plan.parameterBuffer, offset: 0, index: 3)
        dispatchThreads(count: plan.digestCount, pipeline: pipeline, encoder: encoder)
        encoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        if let error = commandBuffer.error {
            throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
        }

        return plan.digestCount
    }

    @discardableResult
    private static func writeOneChunkBatchDigests(
        pipeline: OneChunkBatchWritePipeline,
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue
    ) throws -> Int {
        let plan = pipeline.plan
        guard pipeline.outputBuffers.count == pipeline.parameterBuffers.count else {
            throw BLAKE3Error.metalCommandFailed("BLAKE3 batch pipeline resource count mismatch.")
        }
        guard !pipeline.outputBuffers.isEmpty else {
            throw BLAKE3Error.metalCommandFailed("BLAKE3 batch write pipeline has no output buffers.")
        }
        guard plan.digestCount > 0 else {
            return 0
        }

        let requiredOutputByteCount = plan.outputByteCount
        for outputBuffer in pipeline.outputBuffers {
            guard outputBuffer.device.registryID == plan.buffer.device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
            }
            guard outputBuffer.length >= requiredOutputByteCount else {
                throw BLAKE3Error.metalCommandFailed(
                    "BLAKE3 batch output buffer must hold \(requiredOutputByteCount) bytes."
                )
            }
        }

        pipeline.lock.lock()
        defer {
            pipeline.lock.unlock()
        }

        let params = BLAKE3MetalBatchParams(
            entryCount: UInt32(plan.digestCount),
            canLoadWords: plan.canLoadWords ? 1 : 0,
            key: mode.metalKey,
            flags: mode.flags
        )
        for parameterBuffer in pipeline.parameterBuffers {
            copyParameter(params, into: parameterBuffer, slot: 0)
        }

        let batchPipeline = oneChunkBatchDigestPipeline(for: plan, pipelines: pipelines)
        var commandBuffers = [MTLCommandBuffer]()
        commandBuffers.reserveCapacity(pipeline.outputBuffers.count)

        for index in pipeline.outputBuffers.indices {
            guard let commandBuffer = commandQueue.makeCommandBufferWithUnretainedReferences(),
                  let encoder = commandBuffer.makeComputeCommandEncoder()
            else {
                throw BLAKE3Error.metalCommandFailed("Unable to create BLAKE3 batch pipeline command buffer.")
            }

            encoder.setComputePipelineState(batchPipeline)
            encoder.setBuffer(plan.buffer, offset: 0, index: 0)
            encoder.setBuffer(plan.entriesBuffer, offset: 0, index: 1)
            encoder.setBuffer(pipeline.outputBuffers[index], offset: 0, index: 2)
            encoder.setBuffer(pipeline.parameterBuffers[index], offset: 0, index: 3)
            dispatchThreads(count: plan.digestCount, pipeline: batchPipeline, encoder: encoder)
            encoder.endEncoding()
            commandBuffers.append(commandBuffer)
        }

        for commandBuffer in commandBuffers {
            commandBuffer.commit()
        }
        for commandBuffer in commandBuffers {
            commandBuffer.waitUntilCompleted()
            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }
        }

        return plan.digestCount * pipeline.outputBuffers.count
    }

    private static func encodeOneChunkBatchChainedCommands(
        plan: OneChunkBatchPlan,
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        outputBuffer: MTLBuffer,
        requiredOutputByteCount: Int,
        outputChunkCount: Int,
        outputEntryBuffer: MTLBuffer?,
        outputCanLoadWords: Bool,
        cvBuffer: MTLBuffer,
        scratchBuffer: MTLBuffer,
        digestBuffer: MTLBuffer,
        batchParameterBuffer: MTLBuffer,
        outputHashParameterBuffer: MTLBuffer,
        commandBuffer: MTLCommandBuffer
    ) throws {
        guard let batchEncoder = commandBuffer.makeComputeCommandEncoder() else {
            throw BLAKE3Error.metalCommandFailed("Unable to create BLAKE3 chained batch encoder.")
        }

        let batchParams = BLAKE3MetalBatchParams(
            entryCount: UInt32(plan.digestCount),
            canLoadWords: plan.canLoadWords ? 1 : 0,
            key: mode.metalKey,
            flags: mode.flags
        )
        copyParameter(batchParams, into: batchParameterBuffer, slot: 0)
        let batchPipeline = oneChunkBatchDigestPipeline(for: plan, pipelines: pipelines)
        batchEncoder.setComputePipelineState(batchPipeline)
        batchEncoder.setBuffer(plan.buffer, offset: 0, index: 0)
        batchEncoder.setBuffer(plan.entriesBuffer, offset: 0, index: 1)
        batchEncoder.setBuffer(outputBuffer, offset: 0, index: 2)
        batchEncoder.setBuffer(batchParameterBuffer, offset: 0, index: 3)
        dispatchThreads(count: plan.digestCount, pipeline: batchPipeline, encoder: batchEncoder)
        batchEncoder.endEncoding()

        guard let outputHashEncoder = commandBuffer.makeComputeCommandEncoder() else {
            throw BLAKE3Error.metalCommandFailed("Unable to create BLAKE3 batch output digest encoder.")
        }
        if requiredOutputByteCount <= BLAKE3.chunkByteCount {
            guard let outputEntryBuffer else {
                outputHashEncoder.endEncoding()
                throw BLAKE3Error.metalCommandFailed("BLAKE3 chained output entry buffer is unavailable.")
            }
            let outputParams = BLAKE3MetalBatchParams(
                entryCount: 1,
                canLoadWords: outputCanLoadWords ? 1 : 0,
                key: HashMode.unkeyed.metalKey,
                flags: HashMode.unkeyed.flags
            )
            copyParameter(outputParams, into: outputHashParameterBuffer, slot: 0)
            let outputHashPipeline = pipelines.batchOneChunkDigest
            outputHashEncoder.setComputePipelineState(outputHashPipeline)
            outputHashEncoder.setBuffer(outputBuffer, offset: 0, index: 0)
            outputHashEncoder.setBuffer(outputEntryBuffer, offset: 0, index: 1)
            outputHashEncoder.setBuffer(digestBuffer, offset: 0, index: 2)
            outputHashEncoder.setBuffer(outputHashParameterBuffer, offset: 0, index: 3)
            dispatchThreads(count: 1, pipeline: outputHashPipeline, encoder: outputHashEncoder)
            outputHashEncoder.endEncoding()
        } else {
            try encodeHashCommands(
                buffer: outputBuffer,
                range: 0..<requiredOutputByteCount,
                chunkCount: outputChunkCount,
                pipelines: pipelines,
                mode: .unkeyed,
                cvBuffer: cvBuffer,
                scratchBuffer: scratchBuffer,
                digestBuffer: digestBuffer,
                parameterBuffer: outputHashParameterBuffer,
                encoder: outputHashEncoder
            )
        }
    }

    private static func writeOneChunkBatchDigestsAndHashOutput(
        pipeline: OneChunkBatchChainedPipeline,
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue
    ) throws -> BLAKE3.Digest {
        let plan = pipeline.plan
        guard !pipeline.outputBuffers.isEmpty else {
            throw BLAKE3Error.metalCommandFailed("BLAKE3 chained batch pipeline has no output buffers.")
        }
        let resourceCount = pipeline.outputBuffers.count
        guard pipeline.outputCanLoadWords.count == resourceCount,
              pipeline.batchParameterBuffers.count == resourceCount,
              pipeline.outputHashParameterBuffers.count == resourceCount,
              pipeline.chunkCVBuffers.count == resourceCount,
              pipeline.scratchBuffers.count == resourceCount,
              pipeline.digestBuffers.count == resourceCount
        else {
            throw BLAKE3Error.metalCommandFailed("BLAKE3 chained batch pipeline resource count mismatch.")
        }
        guard plan.digestCount > 0 else {
            return BLAKE3.hashCPU([UInt8]())
        }
        let requiredOutputByteCount = plan.outputByteCount
        for outputBuffer in pipeline.outputBuffers {
            guard outputBuffer.device.registryID == plan.buffer.device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
            }
            guard outputBuffer.length >= requiredOutputByteCount else {
                throw BLAKE3Error.metalCommandFailed(
                    "BLAKE3 batch output buffer must hold \(requiredOutputByteCount) bytes."
                )
            }
        }

        pipeline.lock.lock()
        defer {
            pipeline.lock.unlock()
        }

        var commandBuffers = [MTLCommandBuffer]()
        commandBuffers.reserveCapacity(resourceCount)
        for index in pipeline.outputBuffers.indices {
            guard let commandBuffer = commandQueue.makeCommandBufferWithUnretainedReferences() else {
                throw BLAKE3Error.metalCommandFailed("Unable to create BLAKE3 chained batch command buffer.")
            }
            try encodeOneChunkBatchChainedCommands(
                plan: plan,
                mode: mode,
                pipelines: pipelines,
                outputBuffer: pipeline.outputBuffers[index],
                requiredOutputByteCount: requiredOutputByteCount,
                outputChunkCount: pipeline.outputChunkCount,
                outputEntryBuffer: pipeline.outputEntryBuffer,
                outputCanLoadWords: pipeline.outputCanLoadWords[index],
                cvBuffer: pipeline.chunkCVBuffers[index],
                scratchBuffer: pipeline.scratchBuffers[index],
                digestBuffer: pipeline.digestBuffers[index],
                batchParameterBuffer: pipeline.batchParameterBuffers[index],
                outputHashParameterBuffer: pipeline.outputHashParameterBuffers[index],
                commandBuffer: commandBuffer
            )
            commandBuffers.append(commandBuffer)
        }

        for commandBuffer in commandBuffers {
            commandBuffer.commit()
        }
        for commandBuffer in commandBuffers {
            commandBuffer.waitUntilCompleted()
            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }
        }

        guard let digestBuffer = pipeline.digestBuffers.last else {
            throw BLAKE3Error.metalCommandFailed("BLAKE3 chained batch digest buffer is unavailable.")
        }
        return BLAKE3.Digest(
            UnsafeRawBufferPointer(
                start: digestBuffer.contents(),
                count: BLAKE3.digestByteCount
            )
        )
    }

    private static func writeOneChunkBatchDigestsAndHashOutput(
        buffer: MTLBuffer,
        ranges: [Range<Int>],
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        workspace: Context,
        outputBuffer: MTLBuffer
    ) throws -> BLAKE3.Digest {
        let plan = try buildOneChunkBatchPlan(buffer: buffer, ranges: ranges)
        return try writeOneChunkBatchDigestsAndHashOutput(
            plan: plan,
            mode: mode,
            pipelines: pipelines,
            commandQueue: commandQueue,
            workspace: workspace,
            outputBuffer: outputBuffer
        )
    }

    private static func writeOneChunkBatchDigestsAndHashOutput(
        plan: OneChunkBatchPlan,
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        workspace: Context,
        outputBuffer: MTLBuffer
    ) throws -> BLAKE3.Digest {
        guard plan.buffer.device.registryID == outputBuffer.device.registryID else {
            throw BLAKE3Error.metalCommandFailed("Output buffer belongs to a different Metal device.")
        }
        guard plan.digestCount > 0 else {
            return BLAKE3.hashCPU([UInt8]())
        }
        let requiredOutputByteCount = plan.outputByteCount
        guard outputBuffer.length >= requiredOutputByteCount else {
            throw BLAKE3Error.metalCommandFailed(
                "BLAKE3 batch output buffer must hold \(requiredOutputByteCount) bytes."
            )
        }

        let outputChunkCount = (requiredOutputByteCount + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount
        let workspaceChunkCount = max(1, outputChunkCount)

        return try workspace.withDualParameterWorkspace(chunkCount: workspaceChunkCount) {
            cvBuffer,
            scratchBuffer,
            digestBuffer,
            batchParameterBuffer,
            outputHashParameterBuffer in
            let commandBuffer = commandQueue.makeCommandBuffer()
            guard let commandBuffer,
                  let batchEncoder = commandBuffer.makeComputeCommandEncoder()
            else {
                throw BLAKE3Error.metalCommandFailed(
                    "Unable to create BLAKE3 chained batch command buffer or encoder."
                )
            }

            let batchParams = BLAKE3MetalBatchParams(
                entryCount: UInt32(plan.digestCount),
                canLoadWords: plan.canLoadWords ? 1 : 0,
                key: mode.metalKey,
                flags: mode.flags
            )
            copyParameter(batchParams, into: batchParameterBuffer, slot: 0)
            let batchPipeline = oneChunkBatchDigestPipeline(for: plan, pipelines: pipelines)
            batchEncoder.setComputePipelineState(batchPipeline)
            batchEncoder.setBuffer(plan.buffer, offset: 0, index: 0)
            batchEncoder.setBuffer(plan.entriesBuffer, offset: 0, index: 1)
            batchEncoder.setBuffer(outputBuffer, offset: 0, index: 2)
            batchEncoder.setBuffer(batchParameterBuffer, offset: 0, index: 3)
            dispatchThreads(count: plan.digestCount, pipeline: batchPipeline, encoder: batchEncoder)
            batchEncoder.endEncoding()

            guard let outputHashEncoder = commandBuffer.makeComputeCommandEncoder() else {
                throw BLAKE3Error.metalCommandFailed("Unable to create BLAKE3 batch output digest encoder.")
            }
            if requiredOutputByteCount <= BLAKE3.chunkByteCount {
                var outputEntry = BLAKE3MetalBatchEntry(
                    inputOffset: 0,
                    inputLength: UInt32(requiredOutputByteCount)
                )
                guard let outputEntryBuffer = withUnsafeBytes(of: &outputEntry, { raw in
                    plan.buffer.device.makeBuffer(
                        bytes: raw.baseAddress!,
                        length: raw.count,
                        options: .storageModeShared
                    )
                }) else {
                    outputHashEncoder.endEncoding()
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 batch output digest entry buffer.")
                }
                let outputParams = BLAKE3MetalBatchParams(
                    entryCount: 1,
                    canLoadWords: canLoadWords(buffer: outputBuffer, range: 0..<requiredOutputByteCount) ? 1 : 0,
                    key: HashMode.unkeyed.metalKey,
                    flags: HashMode.unkeyed.flags
                )
                copyParameter(outputParams, into: outputHashParameterBuffer, slot: 0)
                let outputHashPipeline = pipelines.batchOneChunkDigest
                outputHashEncoder.setComputePipelineState(outputHashPipeline)
                outputHashEncoder.setBuffer(outputBuffer, offset: 0, index: 0)
                outputHashEncoder.setBuffer(outputEntryBuffer, offset: 0, index: 1)
                outputHashEncoder.setBuffer(digestBuffer, offset: 0, index: 2)
                outputHashEncoder.setBuffer(outputHashParameterBuffer, offset: 0, index: 3)
                dispatchThreads(count: 1, pipeline: outputHashPipeline, encoder: outputHashEncoder)
                outputHashEncoder.endEncoding()
            } else {
                try encodeHashCommands(
                    buffer: outputBuffer,
                    range: 0..<requiredOutputByteCount,
                    chunkCount: outputChunkCount,
                    pipelines: pipelines,
                    mode: .unkeyed,
                    cvBuffer: cvBuffer,
                    scratchBuffer: scratchBuffer,
                    digestBuffer: digestBuffer,
                    parameterBuffer: outputHashParameterBuffer,
                    encoder: outputHashEncoder
                )
            }

            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }

            return BLAKE3.Digest(
                UnsafeRawBufferPointer(
                    start: digestBuffer.contents(),
                    count: BLAKE3.digestByteCount
                )
            )
        }
    }

    private static func hashOneChunkBatchDigestBytes(
        buffer: MTLBuffer,
        ranges: [Range<Int>],
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        workspace: Context
    ) throws -> BLAKE3.Digest {
        let plan = try buildOneChunkBatchPlan(buffer: buffer, ranges: ranges)
        return try hashOneChunkBatchDigestBytes(
            plan: plan,
            mode: mode,
            pipelines: pipelines,
            commandQueue: commandQueue,
            workspace: workspace
        )
    }

    private static func hashOneChunkBatchDigestBytes(
        plan: OneChunkBatchPlan,
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        workspace: Context
    ) throws -> BLAKE3.Digest {
        guard plan.digestCount > 0 else {
            return BLAKE3.hashCPU([UInt8]())
        }
        let requiredOutputByteCount = plan.outputByteCount

        if requiredOutputByteCount <= BLAKE3.chunkByteCount {
            guard let outputBuffer = plan.buffer.device.makeBuffer(
                length: requiredOutputByteCount,
                options: .storageModePrivate
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate BLAKE3 batch digest output buffer.")
            }
            return try writeOneChunkBatchDigestsAndHashOutput(
                plan: plan,
                mode: mode,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: workspace,
                outputBuffer: outputBuffer
            )
        }

        let outputChunkCount = (requiredOutputByteCount + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount

        return try workspace.withWorkspace(chunkCount: outputChunkCount) {
            cvBuffer,
            scratchBuffer,
            digestBuffer,
            parameterBuffer in
            let commandBuffer = commandQueue.makeCommandBuffer()
            guard let commandBuffer,
                  let encoder = commandBuffer.makeComputeCommandEncoder()
            else {
                throw BLAKE3Error.metalCommandFailed(
                    "Unable to create BLAKE3 fused batch aggregate command buffer or encoder."
                )
            }

            let batchParams = BLAKE3MetalBatchParams(
                entryCount: UInt32(plan.digestCount),
                canLoadWords: plan.canLoadWords ? 1 : 0,
                key: mode.metalKey,
                flags: mode.flags
            )
            copyParameter(batchParams, into: parameterBuffer, slot: 0)
            let pipeline = oneChunkBatchOutputChunkCVPipeline(for: plan, pipelines: pipelines)
            encoder.setComputePipelineState(pipeline)
            encoder.setBuffer(plan.buffer, offset: 0, index: 0)
            encoder.setBuffer(plan.entriesBuffer, offset: 0, index: 1)
            encoder.setBuffer(cvBuffer, offset: 0, index: 2)
            encoder.setBuffer(parameterBuffer, offset: 0, index: 3)
            encoder.setThreadgroupMemoryLength(
                32 * 8 * MemoryLayout<UInt32>.stride,
                index: 0
            )
            encoder.dispatchThreadgroups(
                MTLSize(width: outputChunkCount, height: 1, depth: 1),
                threadsPerThreadgroup: MTLSize(width: 32, height: 1, depth: 1)
            )

            try encodeGenericCVReductionCommands(
                currentBuffer: cvBuffer,
                nextBuffer: scratchBuffer,
                currentCount: outputChunkCount,
                mode: .unkeyed,
                pipelines: pipelines,
                digestBuffer: digestBuffer,
                parameterBuffer: parameterBuffer,
                startingParameterSlot: 1,
                encoder: encoder
            )

            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }

            return BLAKE3.Digest(
                UnsafeRawBufferPointer(
                    start: digestBuffer.contents(),
                    count: BLAKE3.digestByteCount
                )
            )
        }
    }

    private static func readBatchDigests(from digestBuffer: MTLBuffer, count: Int) -> [BLAKE3.Digest] {
        let rawDigests = UnsafeRawBufferPointer(
            start: digestBuffer.contents(),
            count: count * BLAKE3.digestByteCount
        )
        let digestBase = rawDigests.baseAddress!
        var digests = [BLAKE3.Digest]()
        digests.reserveCapacity(count)
        for index in 0..<count {
            let offset = index * BLAKE3.digestByteCount
            digests.append(
                BLAKE3.Digest(
                    UnsafeRawBufferPointer(
                        start: digestBase.advanced(by: offset),
                        count: BLAKE3.digestByteCount
                    )
                )
            )
        }
        return digests
    }

    private static func makeHashCommandBuffer(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        retainsReferences: Bool,
        mode: HashMode = .unkeyed,
        allowsFusedTile: Bool = true,
        cvBuffer: MTLBuffer,
        scratchBuffer: MTLBuffer,
        digestBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer
    ) throws -> MTLCommandBuffer {
        let commandBuffer = retainsReferences
            ? commandQueue.makeCommandBuffer()
            : commandQueue.makeCommandBufferWithUnretainedReferences()
        guard let commandBuffer,
              let encoder = commandBuffer.makeComputeCommandEncoder()
        else {
            throw BLAKE3Error.metalCommandFailed("Unable to create command buffer or encoder.")
        }

        try encodeHashCommands(
            buffer: buffer,
            range: range,
            chunkCount: chunkCount,
            pipelines: pipelines,
            mode: mode,
            allowsFusedTile: allowsFusedTile,
            cvBuffer: cvBuffer,
            scratchBuffer: scratchBuffer,
            digestBuffer: digestBuffer,
            parameterBuffer: parameterBuffer,
            encoder: encoder
        )

        return commandBuffer
    }

    private static func makeXOFCommandBuffer(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        outputByteCount: Int,
        seek: UInt64,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        retainsReferences: Bool,
        mode: HashMode,
        cvBuffer: MTLBuffer,
        scratchBuffer: MTLBuffer,
        outputBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer
    ) throws -> MTLCommandBuffer {
        let commandBuffer = retainsReferences
            ? commandQueue.makeCommandBuffer()
            : commandQueue.makeCommandBufferWithUnretainedReferences()
        guard let commandBuffer,
              let encoder = commandBuffer.makeComputeCommandEncoder()
        else {
            throw BLAKE3Error.metalCommandFailed("Unable to create BLAKE3 XOF command buffer or encoder.")
        }

        try encodeXOFCommands(
            buffer: buffer,
            range: range,
            chunkCount: chunkCount,
            outputByteCount: outputByteCount,
            seek: seek,
            pipelines: pipelines,
            mode: mode,
            cvBuffer: cvBuffer,
            scratchBuffer: scratchBuffer,
            outputBuffer: outputBuffer,
            parameterBuffer: parameterBuffer,
            encoder: encoder
        )

        return commandBuffer
    }

    private static func hashCommandFamily(for mode: HashMode) -> HashCommandFamily {
        mode.isUnkeyedDigestFastPathEligible ? .digestOnly : .generic
    }

    static func _debugHashCommandFamilyForUnkeyedDigest() -> HashCommandFamily {
        hashCommandFamily(for: .unkeyed)
    }

    static func _debugHashCommandFamilyForKeyedDigest(key: some ContiguousBytes) throws -> HashCommandFamily {
        try key.withUnsafeBytes { raw in
            try hashCommandFamily(for: keyedHashMode(raw))
        }
    }

    static func _debugHashCommandFamilyForDerivedMaterial(context: String) -> HashCommandFamily {
        hashCommandFamily(for: deriveKeyMaterialMode(context: context))
    }

    static func _debugXOFCommandFamily() -> HashCommandFamily {
        .generic
    }

    private static func encodeHashCommands(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        pipelines: BLAKE3MetalPipelines,
        mode: HashMode = .unkeyed,
        allowsFusedTile: Bool = true,
        cvBuffer: MTLBuffer,
        scratchBuffer: MTLBuffer,
        digestBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        switch hashCommandFamily(for: mode) {
        case .digestOnly:
            try encodeDigestHashCommands(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                pipelines: pipelines.digest,
                allowsFusedTile: allowsFusedTile,
                cvBuffer: cvBuffer,
                scratchBuffer: scratchBuffer,
                digestBuffer: digestBuffer,
                parameterBuffer: parameterBuffer,
                encoder: encoder
            )
        case .generic:
            try encodeGenericHashCommands(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                pipelines: pipelines,
                mode: mode,
                allowsFusedTile: allowsFusedTile,
                cvBuffer: cvBuffer,
                scratchBuffer: scratchBuffer,
                digestBuffer: digestBuffer,
                parameterBuffer: parameterBuffer,
                encoder: encoder
            )
        }
    }

    private static func encodeDigestHashCommands(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        pipelines: BLAKE3MetalDigestPipelines,
        allowsFusedTile: Bool = true,
        cvBuffer: MTLBuffer,
        scratchBuffer: MTLBuffer,
        digestBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        let canLoadWords = canLoadWords(buffer: buffer, range: range)
        let params = BLAKE3MetalDigestChunkParams(
            inputOffset: UInt64(range.lowerBound),
            inputLength: UInt64(range.count),
            baseChunkCounter: 0,
            chunkCount: UInt32(chunkCount),
            canLoadWords: canLoadWords ? 1 : 0
        )
        copyParameter(params, into: parameterBuffer, slot: 0)
        let tilePlan = fusedTilePlan(
            buffer: buffer,
            range: range,
            chunkCount: chunkCount,
            canLoadWords: canLoadWords,
            allowsFusedTile: allowsFusedTile,
            pipelines: pipelines
        )

        let currentBuffer = cvBuffer
        let nextBuffer = scratchBuffer
        let currentCount: Int
        let parameterSlot = 1

        if let tilePlan {
            encoder.setComputePipelineState(tilePlan.pipeline)
            encoder.setBuffer(buffer, offset: 0, index: 0)
            encoder.setBuffer(cvBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: 0, index: 2)
            encoder.setThreadgroupMemoryLength(tilePlan.threadgroupMemoryByteCount, index: 0)
            encoder.dispatchThreadgroups(
                MTLSize(width: chunkCount / tilePlan.chunkCount, height: 1, depth: 1),
                threadsPerThreadgroup: MTLSize(width: tilePlan.chunkCount, height: 1, depth: 1)
            )
            currentCount = chunkCount / tilePlan.chunkCount
        } else {
            let chunkPipeline = if range.count.isMultiple(of: BLAKE3.chunkByteCount) {
                canUseAlignedFullChunkKernel(buffer: buffer, range: range)
                    ? pipelines.chunkFullAlignedCVs
                    : pipelines.chunkFullCVs
            } else {
                pipelines.chunkCVs
            }

            encoder.setComputePipelineState(chunkPipeline)
            encoder.setBuffer(buffer, offset: 0, index: 0)
            encoder.setBuffer(cvBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: 0, index: 2)
            dispatchThreads(
                count: chunkCount,
                pipeline: chunkPipeline,
                encoder: encoder
            )
            currentCount = chunkCount
        }

        try encodeDigestCVReductionCommands(
            currentBuffer: currentBuffer,
            nextBuffer: nextBuffer,
            currentCount: currentCount,
            pipelines: pipelines,
            digestBuffer: digestBuffer,
            parameterBuffer: parameterBuffer,
            startingParameterSlot: parameterSlot,
            encoder: encoder
        )
    }

    private static func encodeDigestCVReductionCommands(
        currentBuffer initialCurrentBuffer: MTLBuffer,
        nextBuffer initialNextBuffer: MTLBuffer,
        currentCount initialCurrentCount: Int,
        pipelines: BLAKE3MetalDigestPipelines,
        digestBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer,
        startingParameterSlot: Int,
        encoder: MTLComputeCommandEncoder
    ) throws {
        var currentBuffer = initialCurrentBuffer
        var nextBuffer = initialNextBuffer
        var currentCount = initialCurrentCount
        var parameterSlot = startingParameterSlot

        while currentCount > 4 {
            let parentParams = BLAKE3MetalDigestParentParams(inputCount: UInt32(currentCount))
            copyParameter(parentParams, into: parameterBuffer, slot: parameterSlot)
            let useWideReduction = currentCount >= wideParentReductionThreshold
            let useQuadReduction = !useWideReduction
                && currentCount >= quadParentReductionThreshold
            let pipeline = if useWideReduction {
                currentCount.isMultiple(of: 16)
                    ? pipelines.parent16CVs
                    : pipelines.parent16TailCVs
            } else if useQuadReduction {
                currentCount.isMultiple(of: 4)
                    ? pipelines.parent4ExactCVs
                    : pipelines.parent4CVs
            } else {
                pipelines.parentCVs
            }
            let nextCount = if useWideReduction {
                (currentCount + 15) / 16
            } else if useQuadReduction {
                (currentCount + 3) / 4
            } else {
                (currentCount + 1) / 2
            }
            encoder.setComputePipelineState(pipeline)
            encoder.setBuffer(currentBuffer, offset: 0, index: 0)
            encoder.setBuffer(nextBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: parameterOffset(for: parameterSlot), index: 2)
            dispatchThreads(
                count: nextCount,
                pipeline: pipeline,
                encoder: encoder
            )

            swap(&currentBuffer, &nextBuffer)
            currentCount = nextCount
            parameterSlot += 1
        }

        let rootPipeline: MTLComputePipelineState? = switch currentCount {
        case 2:
            pipelines.rootDigest
        case 3:
            pipelines.root3Digest
        case 4:
            pipelines.root4Digest
        default:
            nil
        }
        guard let rootPipeline else {
            encoder.endEncoding()
            throw BLAKE3Error.metalCommandFailed("Unable to create digest-only root encoder.")
        }
        encoder.setComputePipelineState(rootPipeline)
        encoder.setBuffer(currentBuffer, offset: 0, index: 0)
        encoder.setBuffer(digestBuffer, offset: 0, index: 1)
        dispatchThreads(
            count: 1,
            pipeline: rootPipeline,
            encoder: encoder
        )
        encoder.endEncoding()
    }

    private static func encodeGenericHashCommands(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        pipelines: BLAKE3MetalPipelines,
        mode: HashMode = .unkeyed,
        allowsFusedTile: Bool = true,
        cvBuffer: MTLBuffer,
        scratchBuffer: MTLBuffer,
        digestBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        let canLoadWords = canLoadWords(buffer: buffer, range: range)
        let params = BLAKE3MetalChunkParams(
            inputOffset: UInt64(range.lowerBound),
            inputLength: UInt64(range.count),
            baseChunkCounter: 0,
            chunkCount: UInt32(chunkCount),
            canLoadWords: canLoadWords ? 1 : 0,
            key: mode.metalKey,
            flags: mode.flags
        )
        copyParameter(params, into: parameterBuffer, slot: 0)
        let tilePlan = fusedTilePlan(
            buffer: buffer,
            range: range,
            chunkCount: chunkCount,
            canLoadWords: canLoadWords,
            allowsFusedTile: allowsFusedTile,
            pipelines: pipelines
        )

        let currentBuffer = cvBuffer
        let nextBuffer = scratchBuffer
        let currentCount: Int
        let parameterSlot = 1

        if let tilePlan {
            encoder.setComputePipelineState(tilePlan.pipeline)
            encoder.setBuffer(buffer, offset: 0, index: 0)
            encoder.setBuffer(cvBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: 0, index: 2)
            encoder.setThreadgroupMemoryLength(tilePlan.threadgroupMemoryByteCount, index: 0)
            encoder.dispatchThreadgroups(
                MTLSize(width: chunkCount / tilePlan.chunkCount, height: 1, depth: 1),
                threadsPerThreadgroup: MTLSize(width: tilePlan.chunkCount, height: 1, depth: 1)
            )
            currentCount = chunkCount / tilePlan.chunkCount
        } else {
            let chunkPipeline = if range.count.isMultiple(of: BLAKE3.chunkByteCount) {
                canUseAlignedFullChunkKernel(buffer: buffer, range: range)
                    ? pipelines.chunkFullAlignedCVs
                    : pipelines.chunkFullCVs
            } else {
                pipelines.chunkCVs
            }

            encoder.setComputePipelineState(chunkPipeline)
            encoder.setBuffer(buffer, offset: 0, index: 0)
            encoder.setBuffer(cvBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: 0, index: 2)

            dispatchThreads(
                count: chunkCount,
                pipeline: chunkPipeline,
                encoder: encoder
            )
            currentCount = chunkCount
        }

        try encodeGenericCVReductionCommands(
            currentBuffer: currentBuffer,
            nextBuffer: nextBuffer,
            currentCount: currentCount,
            mode: mode,
            pipelines: pipelines,
            digestBuffer: digestBuffer,
            parameterBuffer: parameterBuffer,
            startingParameterSlot: parameterSlot,
            encoder: encoder
        )
    }

    private static func encodeGenericCVReductionCommands(
        currentBuffer initialCurrentBuffer: MTLBuffer,
        nextBuffer initialNextBuffer: MTLBuffer,
        currentCount initialCurrentCount: Int,
        mode: HashMode,
        pipelines: BLAKE3MetalPipelines,
        digestBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer,
        startingParameterSlot: Int,
        encoder: MTLComputeCommandEncoder
    ) throws {
        var currentBuffer = initialCurrentBuffer
        var nextBuffer = initialNextBuffer
        var currentCount = initialCurrentCount
        var parameterSlot = startingParameterSlot

        while currentCount > 4 {
            let parentParams = BLAKE3MetalParentParams(
                inputCount: UInt32(currentCount),
                key: mode.metalKey,
                flags: mode.flags
            )
            copyParameter(parentParams, into: parameterBuffer, slot: parameterSlot)
            let useWideReduction = currentCount >= wideParentReductionThreshold
            let useQuadReduction = !useWideReduction
                && currentCount >= quadParentReductionThreshold
            let pipeline = if useWideReduction {
                currentCount.isMultiple(of: 16)
                    ? pipelines.parent16CVs
                    : pipelines.parent16TailCVs
            } else if useQuadReduction {
                currentCount.isMultiple(of: 4)
                    ? pipelines.parent4ExactCVs
                    : pipelines.parent4CVs
            } else {
                pipelines.parentCVs
            }
            let nextCount = if useWideReduction {
                (currentCount + 15) / 16
            } else if useQuadReduction {
                (currentCount + 3) / 4
            } else {
                (currentCount + 1) / 2
            }
            encoder.setComputePipelineState(pipeline)
            encoder.setBuffer(currentBuffer, offset: 0, index: 0)
            encoder.setBuffer(nextBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: parameterOffset(for: parameterSlot), index: 2)
            dispatchThreads(
                count: nextCount,
                pipeline: pipeline,
                encoder: encoder
            )

            swap(&currentBuffer, &nextBuffer)
            currentCount = nextCount
            parameterSlot += 1
        }

        let rootPipeline: MTLComputePipelineState? = switch currentCount {
        case 2:
            pipelines.rootDigest
        case 3:
            pipelines.root3Digest
        case 4:
            pipelines.root4Digest
        default:
            nil
        }
        guard let rootPipeline else {
            encoder.endEncoding()
            throw BLAKE3Error.metalCommandFailed("Unable to create root digest encoder.")
        }
        let rootParams = BLAKE3MetalParentParams(
            inputCount: UInt32(currentCount),
            key: mode.metalKey,
            flags: mode.flags
        )
        copyParameter(rootParams, into: parameterBuffer, slot: parameterSlot)
        encoder.setComputePipelineState(rootPipeline)
        encoder.setBuffer(currentBuffer, offset: 0, index: 0)
        encoder.setBuffer(digestBuffer, offset: 0, index: 1)
        encoder.setBuffer(parameterBuffer, offset: parameterOffset(for: parameterSlot), index: 2)
        dispatchThreads(
            count: 1,
            pipeline: rootPipeline,
            encoder: encoder
        )
        encoder.endEncoding()
    }

    private static func encodeXOFCommands(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        outputByteCount: Int,
        seek: UInt64,
        pipelines: BLAKE3MetalPipelines,
        mode: HashMode,
        cvBuffer: MTLBuffer,
        scratchBuffer: MTLBuffer,
        outputBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws {
        let canLoadWords = canLoadWords(buffer: buffer, range: range)
        let params = BLAKE3MetalChunkParams(
            inputOffset: UInt64(range.lowerBound),
            inputLength: UInt64(range.count),
            baseChunkCounter: 0,
            chunkCount: UInt32(chunkCount),
            canLoadWords: canLoadWords ? 1 : 0,
            key: mode.metalKey,
            flags: mode.flags
        )
        copyParameter(params, into: parameterBuffer, slot: 0)
        let tilePlan = fusedTilePlan(
            buffer: buffer,
            range: range,
            chunkCount: chunkCount,
            canLoadWords: canLoadWords,
            pipelines: pipelines
        )

        var currentBuffer = cvBuffer
        var nextBuffer = scratchBuffer
        var currentCount: Int
        var parameterSlot = 1

        if let tilePlan {
            encoder.setComputePipelineState(tilePlan.pipeline)
            encoder.setBuffer(buffer, offset: 0, index: 0)
            encoder.setBuffer(cvBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: 0, index: 2)
            encoder.setThreadgroupMemoryLength(tilePlan.threadgroupMemoryByteCount, index: 0)
            encoder.dispatchThreadgroups(
                MTLSize(width: chunkCount / tilePlan.chunkCount, height: 1, depth: 1),
                threadsPerThreadgroup: MTLSize(width: tilePlan.chunkCount, height: 1, depth: 1)
            )
            currentCount = chunkCount / tilePlan.chunkCount
        } else {
            let chunkPipeline = if range.count.isMultiple(of: BLAKE3.chunkByteCount) {
                canUseAlignedFullChunkKernel(buffer: buffer, range: range)
                    ? pipelines.chunkFullAlignedCVs
                    : pipelines.chunkFullCVs
            } else {
                pipelines.chunkCVs
            }

            encoder.setComputePipelineState(chunkPipeline)
            encoder.setBuffer(buffer, offset: 0, index: 0)
            encoder.setBuffer(cvBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: 0, index: 2)

            dispatchThreads(
                count: chunkCount,
                pipeline: chunkPipeline,
                encoder: encoder
            )
            currentCount = chunkCount
        }

        while currentCount > 2 {
            let parentParams = BLAKE3MetalParentParams(
                inputCount: UInt32(currentCount),
                key: mode.metalKey,
                flags: mode.flags
            )
            copyParameter(parentParams, into: parameterBuffer, slot: parameterSlot)
            let useWideReduction = currentCount >= wideParentReductionThreshold
            let useQuadReduction = !useWideReduction
                && currentCount >= quadParentReductionThreshold
            let pipeline = if useWideReduction {
                currentCount.isMultiple(of: 16)
                    ? pipelines.parent16CVs
                    : pipelines.parent16TailCVs
            } else if useQuadReduction {
                currentCount.isMultiple(of: 4)
                    ? pipelines.parent4ExactCVs
                    : pipelines.parent4CVs
            } else {
                pipelines.parentCVs
            }
            let nextCount = if useWideReduction {
                (currentCount + 15) / 16
            } else if useQuadReduction {
                (currentCount + 3) / 4
            } else {
                (currentCount + 1) / 2
            }
            encoder.setComputePipelineState(pipeline)
            encoder.setBuffer(currentBuffer, offset: 0, index: 0)
            encoder.setBuffer(nextBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: parameterOffset(for: parameterSlot), index: 2)
            dispatchThreads(
                count: nextCount,
                pipeline: pipeline,
                encoder: encoder
            )

            swap(&currentBuffer, &nextBuffer)
            currentCount = nextCount
            parameterSlot += 1
        }

        guard currentCount == 2 else {
            encoder.endEncoding()
            throw BLAKE3Error.metalCommandFailed("Unable to create BLAKE3 XOF root encoder.")
        }

        let xofParams = BLAKE3MetalXOFParams(
            outputByteCount: UInt64(outputByteCount),
            seek: seek,
            key: mode.metalKey,
            flags: mode.flags
        )
        copyParameter(xofParams, into: parameterBuffer, slot: parameterSlot)

        let firstBlockOffset = seek % UInt64(BLAKE3Core.blockLen)
        let outputBlockCount64 = (firstBlockOffset + UInt64(outputByteCount) + UInt64(BLAKE3Core.blockLen - 1))
            / UInt64(BLAKE3Core.blockLen)
        guard outputBlockCount64 <= UInt64(Int.max) else {
            encoder.endEncoding()
            throw BLAKE3Error.metalCommandFailed("BLAKE3 XOF output requires too many Metal threads.")
        }
        let outputBlockCount = Int(outputBlockCount64)
        encoder.setComputePipelineState(pipelines.rootXOF)
        encoder.setBuffer(currentBuffer, offset: 0, index: 0)
        encoder.setBuffer(outputBuffer, offset: 0, index: 1)
        encoder.setBuffer(parameterBuffer, offset: parameterOffset(for: parameterSlot), index: 2)
        dispatchThreads(
            count: outputBlockCount,
            pipeline: pipelines.rootXOF,
            encoder: encoder
        )
        encoder.endEncoding()
    }

    private static func makeChunkChainingValuesCommandBuffer(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        baseChunkCounter: UInt64,
        pipelines: BLAKE3MetalPipelines,
        mode: HashMode,
        commandQueue: MTLCommandQueue,
        retainsReferences: Bool,
        outputBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer
    ) throws -> MTLCommandBuffer {
        let commandBuffer = retainsReferences
            ? commandQueue.makeCommandBuffer()
            : commandQueue.makeCommandBufferWithUnretainedReferences()
        guard let commandBuffer,
              let encoder = commandBuffer.makeComputeCommandEncoder()
        else {
            throw BLAKE3Error.metalCommandFailed("Unable to create chunk chaining value command buffer.")
        }

        let params = BLAKE3MetalChunkParams(
            inputOffset: UInt64(range.lowerBound),
            inputLength: UInt64(range.count),
            baseChunkCounter: baseChunkCounter,
            chunkCount: UInt32(chunkCount),
            canLoadWords: canLoadWords(buffer: buffer, range: range) ? 1 : 0,
            key: mode.metalKey,
            flags: mode.flags
        )
        copyParameter(params, into: parameterBuffer, slot: 0)
        let pipeline = canUseAlignedFullChunkKernel(buffer: buffer, range: range)
            ? pipelines.chunkFullAlignedCVs
            : pipelines.chunkFullCVs

        encoder.setComputePipelineState(pipeline)
        encoder.setBuffer(buffer, offset: 0, index: 0)
        encoder.setBuffer(outputBuffer, offset: 0, index: 1)
        encoder.setBuffer(parameterBuffer, offset: 0, index: 2)
        dispatchThreads(
            count: chunkCount,
            pipeline: pipeline,
            encoder: encoder
        )
        encoder.endEncoding()

        return commandBuffer
    }

    private static func makeSubtreeChainingValueCommandBuffer(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        baseChunkCounter: UInt64,
        pipelines: BLAKE3MetalPipelines,
        mode: HashMode,
        commandQueue: MTLCommandQueue,
        retainsReferences: Bool,
        cvBuffer: MTLBuffer,
        scratchBuffer: MTLBuffer,
        digestBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer
    ) throws -> MTLCommandBuffer {
        let commandBuffer = retainsReferences
            ? commandQueue.makeCommandBuffer()
            : commandQueue.makeCommandBufferWithUnretainedReferences()
        guard let commandBuffer,
              let encoder = commandBuffer.makeComputeCommandEncoder()
        else {
            throw BLAKE3Error.metalCommandFailed("Unable to create subtree chaining value command buffer.")
        }

        let finalBuffer = try encodeSubtreeChainingValueCommands(
            buffer: buffer,
            range: range,
            chunkCount: chunkCount,
            baseChunkCounter: baseChunkCounter,
            pipelines: pipelines,
            mode: mode,
            cvBuffer: cvBuffer,
            scratchBuffer: scratchBuffer,
            parameterBuffer: parameterBuffer,
            encoder: encoder
        )

        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            throw BLAKE3Error.metalCommandFailed("Unable to create subtree chaining value readback encoder.")
        }
        blitEncoder.copy(
            from: finalBuffer,
            sourceOffset: 0,
            to: digestBuffer,
            destinationOffset: 0,
            size: BLAKE3.digestByteCount
        )
        blitEncoder.endEncoding()

        return commandBuffer
    }

    private static func encodeSubtreeChainingValueCommands(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        baseChunkCounter: UInt64,
        pipelines: BLAKE3MetalPipelines,
        mode: HashMode,
        cvBuffer: MTLBuffer,
        scratchBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer,
        encoder: MTLComputeCommandEncoder
    ) throws -> MTLBuffer {
        let canLoadWords = canLoadWords(buffer: buffer, range: range)
        let params = BLAKE3MetalChunkParams(
            inputOffset: UInt64(range.lowerBound),
            inputLength: UInt64(range.count),
            baseChunkCounter: baseChunkCounter,
            chunkCount: UInt32(chunkCount),
            canLoadWords: canLoadWords ? 1 : 0,
            key: mode.metalKey,
            flags: mode.flags
        )
        copyParameter(params, into: parameterBuffer, slot: 0)

        var currentBuffer = cvBuffer
        var nextBuffer = scratchBuffer
        var currentCount: Int
        var parameterSlot = 1

        let tilePlan = fusedTilePlan(
            buffer: buffer,
            range: range,
            chunkCount: chunkCount,
            canLoadWords: canLoadWords,
            pipelines: pipelines
        )

        if let tilePlan {
            encoder.setComputePipelineState(tilePlan.pipeline)
            encoder.setBuffer(buffer, offset: 0, index: 0)
            encoder.setBuffer(cvBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: 0, index: 2)
            encoder.setThreadgroupMemoryLength(tilePlan.threadgroupMemoryByteCount, index: 0)
            encoder.dispatchThreadgroups(
                MTLSize(width: chunkCount / tilePlan.chunkCount, height: 1, depth: 1),
                threadsPerThreadgroup: MTLSize(width: tilePlan.chunkCount, height: 1, depth: 1)
            )
            currentCount = chunkCount / tilePlan.chunkCount
        } else {
            let chunkPipeline = canUseAlignedFullChunkKernel(buffer: buffer, range: range)
                ? pipelines.chunkFullAlignedCVs
                : pipelines.chunkFullCVs

            encoder.setComputePipelineState(chunkPipeline)
            encoder.setBuffer(buffer, offset: 0, index: 0)
            encoder.setBuffer(cvBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: 0, index: 2)
            dispatchThreads(
                count: chunkCount,
                pipeline: chunkPipeline,
                encoder: encoder
            )
            currentCount = chunkCount
        }

        while currentCount > 1 {
            let parentParams = BLAKE3MetalParentParams(
                inputCount: UInt32(currentCount),
                key: mode.metalKey,
                flags: mode.flags
            )
            copyParameter(parentParams, into: parameterBuffer, slot: parameterSlot)
            let useWideReduction = currentCount >= wideParentReductionThreshold
            let useQuadReduction = !useWideReduction
                && currentCount >= quadParentReductionThreshold
            let pipeline = if useWideReduction {
                currentCount.isMultiple(of: 16)
                    ? pipelines.parent16CVs
                    : pipelines.parent16TailCVs
            } else if useQuadReduction {
                currentCount.isMultiple(of: 4)
                    ? pipelines.parent4ExactCVs
                    : pipelines.parent4CVs
            } else {
                pipelines.parentCVs
            }
            let nextCount = if useWideReduction {
                (currentCount + 15) / 16
            } else if useQuadReduction {
                (currentCount + 3) / 4
            } else {
                (currentCount + 1) / 2
            }
            encoder.setComputePipelineState(pipeline)
            encoder.setBuffer(currentBuffer, offset: 0, index: 0)
            encoder.setBuffer(nextBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: parameterOffset(for: parameterSlot), index: 2)
            dispatchThreads(
                count: nextCount,
                pipeline: pipeline,
                encoder: encoder
            )

            swap(&currentBuffer, &nextBuffer)
            currentCount = nextCount
            parameterSlot += 1
        }

        encoder.endEncoding()
        return currentBuffer
    }

    private static func parameterOffset(for slot: Int) -> Int {
        slot * Context.parameterSlotStride
    }

    private struct FusedTilePlan {
        let chunkCount: Int
        let pipeline: MTLComputePipelineState
        let threadgroupMemoryByteCount: Int
    }

    private enum FusedTileReductionStrategy {
        case inPlace
        case simdGroup
        case pingPong

        func threadgroupMemoryByteCount(tileChunkCount: Int) -> Int {
            switch self {
            case .inPlace:
                return tileChunkCount * BLAKE3.digestByteCount
            case .simdGroup:
                return max(1, tileChunkCount / 32) * BLAKE3.digestByteCount
            case .pingPong:
                return tileChunkCount * BLAKE3.digestByteCount * 2
            }
        }
    }

    private static func fusedTilePlan(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        canLoadWords: Bool,
        allowsFusedTile: Bool = true,
        pipelines: BLAKE3MetalPipelines
    ) -> FusedTilePlan? {
        guard allowsFusedTile else {
            return nil
        }
        switch fusedTileReductionStrategy {
        case .simdGroup:
            if let plan = fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .simdGroup,
                pipelines: pipelines
            ) {
                return plan
            }
            if let plan = fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .pingPong,
                pipelines: pipelines
            ) {
                return plan
            }
            return fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .inPlace,
                pipelines: pipelines
            )
        case .pingPong:
            if let plan = fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .pingPong,
                pipelines: pipelines
            ) {
                return plan
            }
            return fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .inPlace,
                pipelines: pipelines
            )
        case .inPlace:
            return fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .inPlace,
                pipelines: pipelines
            )
        }
    }

    private static func fusedTilePlan(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        canLoadWords: Bool,
        reductionStrategy: FusedTileReductionStrategy,
        pipelines: BLAKE3MetalPipelines
    ) -> FusedTilePlan? {
        let tileChunkCount = fusedTileChunkCount
        guard tileChunkCount > 0 else {
            return nil
        }
        let tileByteCount = tileChunkCount * BLAKE3.chunkByteCount
        let threadgroupMemoryByteCount = reductionStrategy.threadgroupMemoryByteCount(
            tileChunkCount: tileChunkCount
        )
        guard tileByteCount > 0,
              buffer.storageMode != .private,
              range.count.isMultiple(of: tileByteCount),
              canLoadWords,
              chunkCount >= tileChunkCount * 2,
              threadgroupMemoryByteCount <= buffer.device.maxThreadgroupMemoryLength,
              let tilePipeline = fusedTilePipeline(
                tileChunkCount: tileChunkCount,
                reductionStrategy: reductionStrategy,
                pipelines: pipelines
              )
        else {
            return nil
        }
        let executionWidth = max(1, tilePipeline.threadExecutionWidth)
        guard tileChunkCount <= tilePipeline.maxTotalThreadsPerThreadgroup,
              tileChunkCount.isMultiple(of: executionWidth),
              reductionStrategy != .simdGroup || (tileChunkCount == 128 && executionWidth == 32)
        else {
            return nil
        }
        return FusedTilePlan(
            chunkCount: tileChunkCount,
            pipeline: tilePipeline,
            threadgroupMemoryByteCount: threadgroupMemoryByteCount
        )
    }

    private static func fusedTilePlan(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        canLoadWords: Bool,
        allowsFusedTile: Bool = true,
        pipelines: BLAKE3MetalDigestPipelines
    ) -> FusedTilePlan? {
        guard allowsFusedTile else {
            return nil
        }
        switch fusedTileReductionStrategy {
        case .simdGroup:
            if let plan = fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .simdGroup,
                pipelines: pipelines
            ) {
                return plan
            }
            if let plan = fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .pingPong,
                pipelines: pipelines
            ) {
                return plan
            }
            return fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .inPlace,
                pipelines: pipelines
            )
        case .pingPong:
            if let plan = fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .pingPong,
                pipelines: pipelines
            ) {
                return plan
            }
            return fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .inPlace,
                pipelines: pipelines
            )
        case .inPlace:
            return fusedTilePlan(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                canLoadWords: canLoadWords,
                reductionStrategy: .inPlace,
                pipelines: pipelines
            )
        }
    }

    private static func fusedTilePlan(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        canLoadWords: Bool,
        reductionStrategy: FusedTileReductionStrategy,
        pipelines: BLAKE3MetalDigestPipelines
    ) -> FusedTilePlan? {
        let tileChunkCount = fusedTileChunkCount
        guard tileChunkCount > 0 else {
            return nil
        }
        let tileByteCount = tileChunkCount * BLAKE3.chunkByteCount
        let threadgroupMemoryByteCount = reductionStrategy.threadgroupMemoryByteCount(
            tileChunkCount: tileChunkCount
        )
        guard tileByteCount > 0,
              buffer.storageMode != .private,
              range.count.isMultiple(of: tileByteCount),
              canLoadWords,
              chunkCount >= tileChunkCount * 2,
              threadgroupMemoryByteCount <= buffer.device.maxThreadgroupMemoryLength,
              let tilePipeline = fusedTilePipeline(
                tileChunkCount: tileChunkCount,
                reductionStrategy: reductionStrategy,
                pipelines: pipelines
              )
        else {
            return nil
        }
        let executionWidth = max(1, tilePipeline.threadExecutionWidth)
        guard tileChunkCount <= tilePipeline.maxTotalThreadsPerThreadgroup,
              tileChunkCount.isMultiple(of: executionWidth),
              reductionStrategy != .simdGroup || (tileChunkCount == 128 && executionWidth == 32)
        else {
            return nil
        }
        return FusedTilePlan(
            chunkCount: tileChunkCount,
            pipeline: tilePipeline,
            threadgroupMemoryByteCount: threadgroupMemoryByteCount
        )
    }

    private static func canUseAlignedFullChunkKernel(buffer: MTLBuffer, range: Range<Int>) -> Bool {
        canLoadWords(buffer: buffer, range: range)
    }

    private static func canLoadWords(buffer: MTLBuffer, range: Range<Int>) -> Bool {
        let wordAlignment = MemoryLayout<UInt32>.stride
        if buffer.storageMode == .private {
            return range.lowerBound.isMultiple(of: wordAlignment)
        }
        let address = Int(bitPattern: buffer.contents()) + range.lowerBound
        return address.isMultiple(of: wordAlignment)
    }

    private static func copyParameter<T>(_ value: T, into buffer: MTLBuffer, slot: Int) {
        var value = value
        withUnsafeBytes(of: &value) { raw in
            buffer.contents()
                .advanced(by: parameterOffset(for: slot))
                .copyMemory(from: raw.baseAddress!, byteCount: raw.count)
        }
    }

    private static func fusedTilePipeline(
        tileChunkCount: Int,
        reductionStrategy: FusedTileReductionStrategy,
        pipelines: BLAKE3MetalPipelines
    ) -> MTLComputePipelineState? {
        switch (tileChunkCount, reductionStrategy) {
        case (128, .inPlace):
            return pipelines.chunkTile128CVs
        case (256, .inPlace):
            return pipelines.chunkTile256CVs
        case (512, .inPlace):
            return pipelines.chunkTile512CVs
        case (1024, .inPlace):
            return pipelines.chunkTile1024CVs
        case (128, .simdGroup):
            return pipelines.chunkTile128SIMDGroupCVs
        case (128, .pingPong):
            return pipelines.chunkTile128PingPongCVs
        case (256, .pingPong):
            return pipelines.chunkTile256PingPongCVs
        case (512, .pingPong):
            return pipelines.chunkTile512PingPongCVs
        case (1024, .pingPong):
            return pipelines.chunkTile1024PingPongCVs
        default:
            return nil
        }
    }

    private static func fusedTilePipeline(
        tileChunkCount: Int,
        reductionStrategy: FusedTileReductionStrategy,
        pipelines: BLAKE3MetalDigestPipelines
    ) -> MTLComputePipelineState? {
        switch (tileChunkCount, reductionStrategy) {
        case (128, .inPlace):
            return pipelines.chunkTile128CVs
        case (256, .inPlace):
            return pipelines.chunkTile256CVs
        case (512, .inPlace):
            return pipelines.chunkTile512CVs
        case (1024, .inPlace):
            return pipelines.chunkTile1024CVs
        case (128, .simdGroup):
            return pipelines.chunkTile128SIMDGroupCVs
        case (128, .pingPong):
            return pipelines.chunkTile128PingPongCVs
        case (256, .pingPong):
            return pipelines.chunkTile256PingPongCVs
        case (512, .pingPong):
            return pipelines.chunkTile512PingPongCVs
        case (1024, .pingPong):
            return pipelines.chunkTile1024PingPongCVs
        default:
            return nil
        }
    }

    private static func configuredFusedTileChunkCount() -> Int {
        guard let rawValue = ProcessInfo.processInfo.environment["BLAKE3_SWIFT_METAL_FUSED_TILE_CHUNKS"] else {
            return 128
        }

        switch rawValue.lowercased() {
        case "0", "off", "false", "disabled", "none":
            return 0
        case "128":
            return 128
        case "256":
            return 256
        case "512":
            return 512
        case "1024":
            return 1024
        default:
            return 0
        }
    }

    private static func configuredFusedTileReductionStrategy() -> FusedTileReductionStrategy {
        guard let rawValue = ProcessInfo.processInfo
            .environment["BLAKE3_SWIFT_METAL_FUSED_TILE_REDUCTION"]
        else {
            return .pingPong
        }

        switch rawValue.lowercased() {
        case "simdgroup", "simd-group", "warp", "lane":
            return .simdGroup
        case "pingpong", "ping-pong", "double", "double-buffered":
            return .pingPong
        default:
            return .inPlace
        }
    }

    private static func dispatchThreads(
        count: Int,
        pipeline: MTLComputePipelineState,
        encoder: MTLComputeCommandEncoder
    ) {
        let executionWidth = max(1, pipeline.threadExecutionWidth)
        let targetSIMDGroups = count >= largeGridThreadThreshold
            ? largeGridSIMDGroupsPerThreadgroup
            : smallGridSIMDGroupsPerThreadgroup
        let threadgroupCount = max(1, min(targetSIMDGroups, pipeline.maxTotalThreadsPerThreadgroup / executionWidth))
        let threadgroupWidth = threadgroupCount * executionWidth
        let threadsPerThreadgroup = MTLSize(width: threadgroupWidth, height: 1, depth: 1)
        let threads = MTLSize(width: count, height: 1, depth: 1)
        encoder.dispatchThreads(threads, threadsPerThreadgroup: threadsPerThreadgroup)
    }

    @inline(__always)
    private static func validateOutputByteCount(_ outputByteCount: Int) throws {
        guard outputByteCount >= 0 else {
            throw BLAKE3Error.invalidOutputLength(outputByteCount)
        }
    }

    private static func keyedHashMode(_ keyBytes: UnsafeRawBufferPointer) throws -> HashMode {
        guard keyBytes.count == BLAKE3.keyByteCount else {
            throw BLAKE3Error.invalidKeyLength(
                expected: BLAKE3.keyByteCount,
                actual: keyBytes.count
            )
        }
        return HashMode(
            key: BLAKE3Core.keyedWords(keyBytes),
            flags: BLAKE3Core.keyedHash
        )
    }

    private static func deriveKeyMaterialMode(context: String) -> HashMode {
        let contextBytes = Array(context.utf8)
        return contextBytes.withUnsafeBytes { contextRaw in
            HashMode(
                key: BLAKE3Core.deriveKeyContextKey(contextRaw),
                flags: BLAKE3Core.deriveKeyMaterial
            )
        }
    }

    private static func hash(
        input: UnsafeRawBufferPointer,
        policy: ExecutionPolicy,
        mode: HashMode
    ) throws -> BLAKE3.Digest {
        guard let device = defaultDevice.device else {
            throw BLAKE3Error.metalUnavailable
        }
        return try contextCache.context(device: device).hash(input: input, policy: policy, mode: mode)
    }

    private static func xof(
        input: UnsafeRawBufferPointer,
        outputByteCount: Int,
        seek: UInt64,
        policy: ExecutionPolicy,
        mode: HashMode
    ) throws -> [UInt8] {
        guard let device = defaultDevice.device else {
            throw BLAKE3Error.metalUnavailable
        }
        return try contextCache.context(device: device).xof(
            input: input,
            outputByteCount: outputByteCount,
            seek: seek,
            policy: policy,
            mode: mode
        )
    }

    private static func hashOnCPU(buffer: MTLBuffer, range: Range<Int>, mode: HashMode) throws -> BLAKE3.Digest {
        guard buffer.storageMode != .private else {
            throw BLAKE3Error.metalCommandFailed("CPU fallback requires a CPU-visible Metal buffer.")
        }
        let start = buffer.contents().advanced(by: range.lowerBound)
        return hashOnCPU(
            input: UnsafeRawBufferPointer(start: start, count: range.count),
            mode: mode
        )
    }

    private static func xofOnCPU(
        buffer: MTLBuffer,
        range: Range<Int>,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64
    ) throws -> [UInt8] {
        guard buffer.storageMode != .private else {
            throw BLAKE3Error.metalCommandFailed("CPU fallback requires a CPU-visible Metal buffer.")
        }
        let start = buffer.contents().advanced(by: range.lowerBound)
        return xofOnCPU(
            input: UnsafeRawBufferPointer(start: start, count: range.count),
            mode: mode,
            outputByteCount: outputByteCount,
            seek: seek
        )
    }

    @discardableResult
    private static func writeXOFOnCPU(
        buffer: MTLBuffer,
        range: Range<Int>,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64,
        outputBuffer: MTLBuffer
    ) throws -> Int {
        guard outputBuffer.storageMode != .private else {
            throw BLAKE3Error.metalCommandFailed("CPU fallback requires a CPU-visible Metal output buffer.")
        }
        let output = try xofOnCPU(
            buffer: buffer,
            range: range,
            mode: mode,
            outputByteCount: outputByteCount,
            seek: seek
        )
        output.withUnsafeBytes { rawOutput in
            if let baseAddress = rawOutput.baseAddress {
                outputBuffer.contents().copyMemory(from: baseAddress, byteCount: rawOutput.count)
            }
        }
        if outputBuffer.storageMode == .managed {
            outputBuffer.didModifyRange(0..<outputByteCount)
        }
        return outputByteCount
    }

    private static func hashOnCPU(input: UnsafeRawBufferPointer, mode: HashMode) -> BLAKE3.Digest {
        var workspace = BLAKE3Core.Workspace()
        let scheduler = BLAKE3Core.defaultScheduler(forByteCount: input.count, maxWorkers: nil)
        return BLAKE3.Digest(output: BLAKE3Core.rootOutputParallel(
            input,
            key: mode.key,
            flags: mode.flags,
            maxWorkers: nil,
            scheduler: scheduler,
            workspace: &workspace
        ))
    }

    private static func xofOnCPU(
        input: UnsafeRawBufferPointer,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64
    ) -> [UInt8] {
        guard outputByteCount > 0 else {
            return []
        }
        var workspace = BLAKE3Core.Workspace()
        let scheduler = BLAKE3Core.defaultScheduler(forByteCount: input.count, maxWorkers: nil)
        return BLAKE3Core.rootOutputParallel(
            input,
            key: mode.key,
            flags: mode.flags,
            maxWorkers: nil,
            scheduler: scheduler,
            workspace: &workspace
        )
        .rootBytes(byteCount: outputByteCount, seek: seek)
    }
}

private struct BLAKE3MetalDeviceReference: @unchecked Sendable {
    let device: MTLDevice?

    init(_ device: MTLDevice?) {
        self.device = device
    }
}

private final class BLAKE3MetalContextCache: @unchecked Sendable {
    private struct CacheKey: Hashable {
        let deviceRegistryID: UInt64
        let minimumGPUByteCount: Int
        let libraryIdentifier: String
    }

    private let lock = NSLock()
    private var contexts: [CacheKey: BLAKE3Metal.Context] = [:]

    func context(
        device: MTLDevice,
        minimumGPUByteCount: Int = BLAKE3Metal.defaultMinimumGPUByteCount,
        librarySource: BLAKE3Metal.LibrarySource = .runtimeSource
    ) throws -> BLAKE3Metal.Context {
        let key = CacheKey(
            deviceRegistryID: device.registryID,
            minimumGPUByteCount: max(0, minimumGPUByteCount),
            libraryIdentifier: librarySource.contextCacheIdentifier
        )
        lock.lock()
        if let context = contexts[key] {
            lock.unlock()
            return context
        }
        lock.unlock()

        let context = try BLAKE3Metal.Context(
            device: device,
            minimumGPUByteCount: minimumGPUByteCount,
            librarySource: librarySource
        )

        lock.lock()
        defer {
            lock.unlock()
        }
        if let existing = contexts[key] {
            return existing
        }
        contexts[key] = context
        return context
    }
}

private extension BLAKE3Metal.LibrarySource {
    var contextCacheIdentifier: String {
        switch self {
        case .runtimeSource:
            return "runtime-source"
        case let .metallib(url):
            return "metallib:\(url.standardizedFileURL.path)"
        }
    }
}
#endif
