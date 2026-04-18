import Foundation

/// Namespace for BLAKE3 hashing, keyed hashing, key derivation, streaming, and CPU backend selection.
///
/// The default one-shot path uses the fastest enabled Swift CPU implementation for the current input size.
/// Use ``Context`` when hashing many inputs and you want to reuse CPU work buffers across calls.
public enum BLAKE3 {
    /// Default backend policy used by ``hash(_:)``.
    public enum BackendPolicy: String, Sendable {
        /// Chooses the fastest built-in path for the input and host.
        case automatic
        /// Uses CPU implementations only.
        case cpu
        /// Uses Metal for large inputs when available, with CPU fallback on failure.
        case metal
    }

    /// Number of bytes in a standard BLAKE3 digest.
    public static let digestByteCount = BLAKE3Core.outLen

    /// Required byte length for keyed hashing keys.
    public static let keyByteCount = BLAKE3Core.keyLen

    /// Number of bytes in one BLAKE3 compression block.
    public static let blockByteCount = BLAKE3Core.blockLen

    /// Number of bytes in one BLAKE3 tree chunk.
    public static let chunkByteCount = BLAKE3Core.chunkLen

    /// The CPU backend selected by the default one-shot API.
    public static var activeBackend: BackendKind {
        .swiftSIMD4
    }

    /// Backend policy used by the default one-shot API.
    ///
    /// Override with `BLAKE3_SWIFT_BACKEND=cpu|metal|auto` before process start.
    public static var defaultBackendPolicy: BackendPolicy {
        defaultHashConfiguration.backendPolicy
    }

    /// Minimum input size where the default one-shot API may use Metal.
    ///
    /// Override with `BLAKE3_SWIFT_METAL_MIN_BYTES=<byte-count>` before process start.
    public static var defaultMetalMinimumByteCount: Int {
        defaultHashConfiguration.metalMinimumByteCount
    }

    /// SIMD degree used by the current Swift SIMD implementation.
    public static var simdDegree: Int {
        4
    }

    /// SIMD degree used inside the CPU parallel implementation.
    public static var parallelSIMDDegree: Int {
        4
    }

    /// Default worker count used by CPU parallel hashing when callers do not pass an override.
    ///
    /// Defaults to `ProcessInfo.processInfo.activeProcessorCount` so large hashes can use all available
    /// CPU cores. Pass `maxWorkers` to public parallel APIs when reproducible benchmark pinning matters.
    public static var defaultParallelWorkerCount: Int {
        BLAKE3Core.defaultParallelWorkerCount
    }

    /// Native Swift storage footprint of ``Hasher``.
    public static var nativeHasherByteCount: Int {
        MemoryLayout<Hasher>.stride
    }

    /// Hashes contiguous input and returns a 32-byte BLAKE3 digest.
    public static func hash(_ input: some ContiguousBytes) -> Digest {
        input.withUnsafeBytes { raw in
            hash(raw)
        }
    }

    /// Hashes raw input and returns a 32-byte BLAKE3 digest.
    ///
    /// The buffer only needs to remain valid for the duration of this call.
    public static func hash(_ input: UnsafeRawBufferPointer) -> Digest {
        switch defaultHashConfiguration.backendPolicy {
        case .cpu:
            return hashCPU(input)
        case .automatic, .metal:
            #if canImport(Metal)
            if shouldUseMetalForDefaultHash(byteCount: input.count) {
                do {
                    return try BLAKE3Metal.hash(input: input, policy: .gpu)
                } catch {
                    return hashCPU(input)
                }
            }
            #endif
            return hashCPU(input)
        }
    }

    /// Hashes contiguous input and returns `outputByteCount` BLAKE3 output bytes.
    ///
    /// Use this for BLAKE3's extendable-output mode when more than the standard 32-byte digest is needed.
    public static func hash(
        _ input: some ContiguousBytes,
        outputByteCount: Int
    ) throws -> [UInt8] {
        try input.withUnsafeBytes { raw in
            try hash(raw, outputByteCount: outputByteCount)
        }
    }

    /// Hashes raw input and returns `outputByteCount` BLAKE3 output bytes.
    ///
    /// The 32-byte case uses the default backend policy. Longer output is expanded through the CPU
    /// root-output path because Metal kernels produce the standard digest.
    public static func hash(
        _ input: UnsafeRawBufferPointer,
        outputByteCount: Int
    ) throws -> [UInt8] {
        try validateOutputByteCount(outputByteCount)
        if outputByteCount == 0 {
            return []
        }
        if outputByteCount == digestByteCount {
            return hash(input).bytes
        }

        return rootBytes(
            input,
            key: BLAKE3Core.iv,
            flags: 0,
            mode: .parallel(maxWorkers: nil),
            outputByteCount: outputByteCount,
            wipingWorkspace: false
        )
    }

    /// Hashes contiguous input using the fastest CPU-only one-shot path.
    ///
    /// This bypasses the default Metal dispatcher and is useful for benchmark baselines and hosts where
    /// callers want CPU scheduling to be explicit.
    public static func hashCPU(_ input: some ContiguousBytes) -> Digest {
        input.withUnsafeBytes { raw in
            hashCPU(raw)
        }
    }

    /// Hashes raw input using the fastest CPU-only one-shot path.
    ///
    /// The buffer only needs to remain valid for the duration of this call.
    public static func hashCPU(_ input: UnsafeRawBufferPointer) -> Digest {
        var workspace = BLAKE3Core.Workspace()
        return Digest(output: BLAKE3Core.rootOutputParallel(
            input,
            key: BLAKE3Core.iv,
            flags: 0,
            maxWorkers: nil,
            workspace: &workspace
        ))
    }

    /// Hashes contiguous input using the serial CPU implementation with SIMD where available.
    public static func hashSerial(_ input: some ContiguousBytes) -> Digest {
        input.withUnsafeBytes { raw in
            hashSerial(raw)
        }
    }

    /// Hashes raw input using the serial CPU implementation with SIMD where available.
    ///
    /// The buffer only needs to remain valid for the duration of this call.
    public static func hashSerial(_ input: UnsafeRawBufferPointer) -> Digest {
        var workspace = BLAKE3Core.Workspace()
        return Digest(output: BLAKE3Core.rootOutputSerial(
            input,
            key: BLAKE3Core.iv,
            flags: 0,
            workspace: &workspace
        ))
    }

    /// Hashes contiguous input with the scalar CPU implementation.
    public static func hashScalar(_ input: some ContiguousBytes) -> Digest {
        input.withUnsafeBytes { raw in
            hashScalar(raw)
        }
    }

    /// Hashes raw input with the scalar CPU implementation.
    public static func hashScalar(_ input: UnsafeRawBufferPointer) -> Digest {
        Digest(output: BLAKE3Core.rootOutputScalar(input))
    }

    /// Hashes contiguous input with CPU parallelism.
    ///
    /// Pass `maxWorkers` to pin the worker count for reproducible benchmark runs.
    public static func hashParallel(
        _ input: some ContiguousBytes,
        maxWorkers: Int? = nil
    ) -> Digest {
        input.withUnsafeBytes { raw in
            hashParallel(raw, maxWorkers: maxWorkers)
        }
    }

    /// Hashes raw input with CPU parallelism.
    ///
    /// The buffer only needs to remain valid for the duration of this call.
    public static func hashParallel(
        _ input: UnsafeRawBufferPointer,
        maxWorkers: Int? = nil
    ) -> Digest {
        var workspace = BLAKE3Core.Workspace()
        return Digest(output: BLAKE3Core.rootOutputParallel(
            input,
            key: BLAKE3Core.iv,
            flags: 0,
            maxWorkers: maxWorkers,
            workspace: &workspace
        ))
    }

    /// Computes a 32-byte BLAKE3 keyed hash.
    ///
    /// `key` must be exactly ``keyByteCount`` bytes. Key bytes are read during the call and are not retained.
    public static func keyedHash(
        key: some ContiguousBytes,
        input: some ContiguousBytes
    ) throws -> Digest {
        try key.withUnsafeBytes { keyBytes in
            try withValidatedKeyWords(keyBytes) { keyWords in
                input.withUnsafeBytes { inputBytes in
                    rootDigest(
                        inputBytes,
                        key: keyWords,
                        flags: BLAKE3Core.keyedHash,
                        mode: .serial,
                        wipingWorkspace: true
                    )
                }
            }
        }
    }

    /// Computes `outputByteCount` bytes of BLAKE3 keyed-hash output.
    ///
    /// `key` must be exactly ``keyByteCount`` bytes. Use the 32-byte ``keyedHash(key:input:)`` overload
    /// when a fixed-size digest is required.
    public static func keyedHash(
        key: some ContiguousBytes,
        input: some ContiguousBytes,
        outputByteCount: Int
    ) throws -> [UInt8] {
        try validateOutputByteCount(outputByteCount)
        return try key.withUnsafeBytes { keyBytes in
            try withValidatedKeyWords(keyBytes) { keyWords in
                input.withUnsafeBytes { inputBytes in
                    rootBytes(
                        inputBytes,
                        key: keyWords,
                        flags: BLAKE3Core.keyedHash,
                        mode: .serial,
                        outputByteCount: outputByteCount,
                        wipingWorkspace: true
                    )
                }
            }
        }
    }

    /// Computes a 32-byte BLAKE3 keyed hash with CPU parallelism.
    ///
    /// `key` must be exactly ``keyByteCount`` bytes. Key bytes are read during the call and are not retained.
    public static func keyedHashParallel(
        key: some ContiguousBytes,
        input: some ContiguousBytes
    ) throws -> Digest {
        try key.withUnsafeBytes { keyBytes in
            try withValidatedKeyWords(keyBytes) { keyWords in
                input.withUnsafeBytes { inputBytes in
                    rootDigest(
                        inputBytes,
                        key: keyWords,
                        flags: BLAKE3Core.keyedHash,
                        mode: .parallel(maxWorkers: nil),
                        wipingWorkspace: true
                    )
                }
            }
        }
    }

    /// Computes `outputByteCount` bytes of BLAKE3 keyed-hash output with CPU parallelism.
    ///
    /// `key` must be exactly ``keyByteCount`` bytes.
    public static func keyedHashParallel(
        key: some ContiguousBytes,
        input: some ContiguousBytes,
        outputByteCount: Int
    ) throws -> [UInt8] {
        try validateOutputByteCount(outputByteCount)
        return try key.withUnsafeBytes { keyBytes in
            try withValidatedKeyWords(keyBytes) { keyWords in
                input.withUnsafeBytes { inputBytes in
                    rootBytes(
                        inputBytes,
                        key: keyWords,
                        flags: BLAKE3Core.keyedHash,
                        mode: .parallel(maxWorkers: nil),
                        outputByteCount: outputByteCount,
                        wipingWorkspace: true
                    )
                }
            }
        }
    }

    /// Derives key material using BLAKE3 key derivation.
    ///
    /// `context` is encoded as UTF-8 exactly. Increase `outputByteCount` for XOF-style derived material.
    public static func deriveKey(
        context: String,
        material: some ContiguousBytes,
        outputByteCount: Int = BLAKE3.digestByteCount
    ) throws -> [UInt8] {
        try validateOutputByteCount(outputByteCount)
        if outputByteCount == 0 {
            return []
        }

        let contextBytes = Array(context.utf8)
        return contextBytes.withUnsafeBytes { contextRaw in
            var contextKey = BLAKE3Core.deriveKeyContextKey(contextRaw)
            defer {
                BLAKE3Core.secureWipe(&contextKey)
            }
            return material.withUnsafeBytes { materialRaw in
                rootBytes(
                    materialRaw,
                    key: contextKey,
                    flags: BLAKE3Core.deriveKeyMaterial,
                    mode: .serial,
                    outputByteCount: outputByteCount,
                    wipingWorkspace: true
                )
            }
        }
    }

    /// Derives key material using BLAKE3 key derivation and CPU parallelism for the material hash.
    ///
    /// `context` is encoded as UTF-8 exactly. Increase `outputByteCount` for XOF-style derived material.
    public static func deriveKeyParallel(
        context: String,
        material: some ContiguousBytes,
        outputByteCount: Int = BLAKE3.digestByteCount
    ) throws -> [UInt8] {
        try validateOutputByteCount(outputByteCount)
        if outputByteCount == 0 {
            return []
        }

        let contextBytes = Array(context.utf8)
        return contextBytes.withUnsafeBytes { contextRaw in
            var contextKey = BLAKE3Core.deriveKeyContextKey(contextRaw)
            defer {
                BLAKE3Core.secureWipe(&contextKey)
            }
            return material.withUnsafeBytes { materialRaw in
                rootBytes(
                    materialRaw,
                    key: contextKey,
                    flags: BLAKE3Core.deriveKeyMaterial,
                    mode: .parallel(maxWorkers: nil),
                    outputByteCount: outputByteCount,
                    wipingWorkspace: true
                )
            }
        }
    }

    static func hashFromChunkChainingValues(
        _ chunkCVs: UnsafeRawBufferPointer,
        chunkCount: Int
    ) -> Digest? {
        BLAKE3Core.digestFromChunkChainingValues(chunkCVs, chunkCount: chunkCount)
    }

    /// CPU and accelerator backend names used in diagnostics and benchmark output.
    public enum BackendKind: String, Sendable {
        case swiftScalar = "swift-scalar"
        case swiftSIMD4 = "swift-simd4"
        case swiftParallel = "swift-parallel"
        case metal = "metal"
    }
}

private struct BLAKE3DefaultHashConfiguration: Sendable {
    let backendPolicy: BLAKE3.BackendPolicy
    let metalMinimumByteCount: Int

    static func fromEnvironment() -> Self {
        let environment = ProcessInfo.processInfo.environment
        let backendPolicy = parseBackendPolicy(environment["BLAKE3_SWIFT_BACKEND"])
        let metalMinimumByteCount = environment["BLAKE3_SWIFT_METAL_MIN_BYTES"]
            .flatMap { Int($0) }
            .map { max(0, $0) }
            ?? (16 * 1024 * 1024)

        return Self(
            backendPolicy: backendPolicy,
            metalMinimumByteCount: metalMinimumByteCount
        )
    }

    private static func parseBackendPolicy(_ rawValue: String?) -> BLAKE3.BackendPolicy {
        switch rawValue?.lowercased() {
        case "cpu", "swift":
            return .cpu
        case "metal", "gpu":
            return .metal
        case "auto", "automatic", nil:
            return .automatic
        default:
            return .automatic
        }
    }
}

private enum BLAKE3RootOutputMode {
    case serial
    case parallel(maxWorkers: Int?)
}

private extension BLAKE3 {
    static let defaultHashConfiguration = BLAKE3DefaultHashConfiguration.fromEnvironment()

    @inline(__always)
    static func validateOutputByteCount(_ outputByteCount: Int) throws {
        guard outputByteCount >= 0 else {
            throw BLAKE3Error.invalidOutputLength(outputByteCount)
        }
    }

    @inline(__always)
    static func withValidatedKeyWords<R>(
        _ keyBytes: UnsafeRawBufferPointer,
        _ body: (BLAKE3Core.ChainingValue) throws -> R
    ) throws -> R {
        guard keyBytes.count == keyByteCount else {
            throw BLAKE3Error.invalidKeyLength(
                expected: keyByteCount,
                actual: keyBytes.count
            )
        }

        var keyWords = BLAKE3Core.keyedWords(keyBytes)
        defer {
            BLAKE3Core.secureWipe(&keyWords)
        }
        return try body(keyWords)
    }

    @inline(__always)
    static func rootDigest(
        _ input: UnsafeRawBufferPointer,
        key: BLAKE3Core.ChainingValue,
        flags: UInt32,
        mode: BLAKE3RootOutputMode,
        wipingWorkspace: Bool
    ) -> Digest {
        var workspace = BLAKE3Core.Workspace()
        defer {
            workspace.reset(keepingCapacity: false, wiping: wipingWorkspace)
        }
        return Digest(output: rootOutput(input, key: key, flags: flags, mode: mode, workspace: &workspace))
    }

    @inline(__always)
    static func rootBytes(
        _ input: UnsafeRawBufferPointer,
        key: BLAKE3Core.ChainingValue,
        flags: UInt32,
        mode: BLAKE3RootOutputMode,
        outputByteCount: Int,
        wipingWorkspace: Bool
    ) -> [UInt8] {
        guard outputByteCount > 0 else {
            return []
        }

        var workspace = BLAKE3Core.Workspace()
        defer {
            workspace.reset(keepingCapacity: false, wiping: wipingWorkspace)
        }
        let output = rootOutput(input, key: key, flags: flags, mode: mode, workspace: &workspace)
        if outputByteCount == digestByteCount {
            return Digest(output: output).bytes
        }
        return output.rootBytes(byteCount: outputByteCount)
    }

    @inline(__always)
    static func rootOutput(
        _ input: UnsafeRawBufferPointer,
        key: BLAKE3Core.ChainingValue,
        flags: UInt32,
        mode: BLAKE3RootOutputMode,
        workspace: inout BLAKE3Core.Workspace
    ) -> BLAKE3Core.Output {
        switch mode {
        case .serial:
            return BLAKE3Core.rootOutputSerial(
                input,
                key: key,
                flags: flags,
                workspace: &workspace
            )
        case let .parallel(maxWorkers):
            return BLAKE3Core.rootOutputParallel(
                input,
                key: key,
                flags: flags,
                maxWorkers: maxWorkers,
                workspace: &workspace
            )
        }
    }

    static func shouldUseMetalForDefaultHash(byteCount: Int) -> Bool {
        #if canImport(Metal)
        guard BLAKE3Metal.isAvailable,
              byteCount >= defaultHashConfiguration.metalMinimumByteCount
        else {
            return false
        }

        switch defaultHashConfiguration.backendPolicy {
        case .cpu:
            return false
        case .automatic, .metal:
            return true
        }
        #else
        false
        #endif
    }
}
