import Foundation

/// Namespace for BLAKE3 hashing, keyed hashing, key derivation, streaming, and CPU backend selection.
///
/// The default one-shot path uses the fastest enabled Swift CPU implementation for the current input size.
/// Use ``Context`` when hashing many inputs and you want to reuse CPU work buffers across calls.
public enum BLAKE3 {
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
        Digest(output: BLAKE3Core.rootOutputDefault(input))
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
            guard keyBytes.count == keyByteCount else {
                throw BLAKE3Error.invalidKeyLength(
                    expected: keyByteCount,
                    actual: keyBytes.count
                )
            }
            let keyWords = BLAKE3Core.keyedWords(keyBytes)
            return input.withUnsafeBytes { inputBytes in
                Digest(output: BLAKE3Core.rootOutputDefault(
                    inputBytes,
                    key: keyWords,
                    flags: BLAKE3Core.keyedHash
                ))
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
            guard keyBytes.count == keyByteCount else {
                throw BLAKE3Error.invalidKeyLength(
                    expected: keyByteCount,
                    actual: keyBytes.count
                )
            }
            let keyWords = BLAKE3Core.keyedWords(keyBytes)
            return input.withUnsafeBytes { inputBytes in
                var workspace = BLAKE3Core.Workspace()
                return Digest(output: BLAKE3Core.rootOutputParallel(
                    inputBytes,
                    key: keyWords,
                    flags: BLAKE3Core.keyedHash,
                    maxWorkers: nil,
                    workspace: &workspace
                ))
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
        guard outputByteCount >= 0 else {
            throw BLAKE3Error.invalidOutputLength(outputByteCount)
        }

        let contextBytes = Array(context.utf8)
        return contextBytes.withUnsafeBytes { contextRaw in
            let contextKey = BLAKE3Core.deriveKeyContextKey(contextRaw)
            return material.withUnsafeBytes { materialRaw in
                BLAKE3Core.hash(
                    materialRaw,
                    key: contextKey,
                    flags: BLAKE3Core.deriveKeyMaterial,
                    outputByteCount: outputByteCount
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
        guard outputByteCount >= 0 else {
            throw BLAKE3Error.invalidOutputLength(outputByteCount)
        }

        let contextBytes = Array(context.utf8)
        return contextBytes.withUnsafeBytes { contextRaw in
            let contextKey = BLAKE3Core.deriveKeyContextKey(contextRaw)
            return material.withUnsafeBytes { materialRaw in
                BLAKE3Core.hashParallel(
                    materialRaw,
                    key: contextKey,
                    flags: BLAKE3Core.deriveKeyMaterial,
                    outputByteCount: outputByteCount
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
