import Foundation

public enum BLAKE3 {
    public static let digestByteCount = BLAKE3Core.outLen
    public static let keyByteCount = BLAKE3Core.keyLen
    public static let blockByteCount = BLAKE3Core.blockLen
    public static let chunkByteCount = BLAKE3Core.chunkLen

    public static var activeBackend: BackendKind {
        .swiftSIMD4
    }

    public static var simdDegree: Int {
        4
    }

    public static var parallelSIMDDegree: Int {
        4
    }

    public static var nativeHasherByteCount: Int {
        MemoryLayout<Hasher>.stride
    }

    public static func hash(_ input: some ContiguousBytes) -> Digest {
        input.withUnsafeBytes { raw in
            hash(raw)
        }
    }

    public static func hash(_ input: UnsafeRawBufferPointer) -> Digest {
        Digest(BLAKE3Core.hash(input))
    }

    public static func hashScalar(_ input: some ContiguousBytes) -> Digest {
        input.withUnsafeBytes { raw in
            hashScalar(raw)
        }
    }

    public static func hashScalar(_ input: UnsafeRawBufferPointer) -> Digest {
        Digest(BLAKE3Core.hashScalar(input))
    }

    public static func hashParallel(
        _ input: some ContiguousBytes,
        maxWorkers: Int? = nil
    ) -> Digest {
        input.withUnsafeBytes { raw in
            hashParallel(raw, maxWorkers: maxWorkers)
        }
    }

    public static func hashParallel(
        _ input: UnsafeRawBufferPointer,
        maxWorkers: Int? = nil
    ) -> Digest {
        if let maxWorkers, maxWorkers <= 1 {
            return hash(input)
        }
        return Digest(BLAKE3Core.hashParallel(input, maxWorkers: maxWorkers))
    }

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
                Digest(BLAKE3Core.hash(
                    inputBytes,
                    key: keyWords,
                    flags: BLAKE3Core.keyedHash
                ))
            }
        }
    }

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
                Digest(BLAKE3Core.hashParallel(
                    inputBytes,
                    key: keyWords,
                    flags: BLAKE3Core.keyedHash
                ))
            }
        }
    }

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

    public enum BackendKind: String, Sendable {
        case swiftScalar = "swift-scalar"
        case swiftSIMD4 = "swift-simd4"
        case swiftParallel = "swift-parallel"
        case metal = "metal"
    }
}
