import CBLAKE3
@_spi(Benchmark) import Blake3
import Foundation

public enum OfficialCBLAKE3 {
    public static func hash(_ input: UnsafeRawBufferPointer) -> BLAKE3.Digest {
        var output = [UInt8](repeating: 0, count: BLAKE3.digestByteCount)
        output.withUnsafeMutableBytes { rawOutput in
            cblake3_hash(
                input.baseAddress,
                input.count,
                rawOutput.bindMemory(to: UInt8.self).baseAddress
            )
        }
        return BLAKE3.Digest(benchmarkBytes: output)
    }

    public static func hash(
        _ input: UnsafeRawBufferPointer,
        outputByteCount: Int,
        seek: UInt64 = 0
    ) -> [UInt8] {
        precondition(outputByteCount >= 0)
        guard outputByteCount > 0 else {
            return []
        }
        var output = [UInt8](repeating: 0, count: outputByteCount)
        output.withUnsafeMutableBytes { rawOutput in
            cblake3_hash_xof(
                input.baseAddress,
                input.count,
                seek,
                rawOutput.bindMemory(to: UInt8.self).baseAddress,
                rawOutput.count
            )
        }
        return output
    }

    public static func keyedHash(
        key: UnsafeRawBufferPointer,
        input: UnsafeRawBufferPointer
    ) -> BLAKE3.Digest {
        precondition(key.count == BLAKE3.keyByteCount)
        var output = [UInt8](repeating: 0, count: BLAKE3.digestByteCount)
        output.withUnsafeMutableBytes { rawOutput in
            cblake3_keyed_hash(
                key.bindMemory(to: UInt8.self).baseAddress,
                input.baseAddress,
                input.count,
                rawOutput.bindMemory(to: UInt8.self).baseAddress
            )
        }
        return BLAKE3.Digest(benchmarkBytes: output)
    }

    public static func keyedHash(
        key: UnsafeRawBufferPointer,
        input: UnsafeRawBufferPointer,
        outputByteCount: Int,
        seek: UInt64 = 0
    ) -> [UInt8] {
        precondition(key.count == BLAKE3.keyByteCount)
        precondition(outputByteCount >= 0)
        guard outputByteCount > 0 else {
            return []
        }
        var output = [UInt8](repeating: 0, count: outputByteCount)
        output.withUnsafeMutableBytes { rawOutput in
            cblake3_keyed_hash_xof(
                key.bindMemory(to: UInt8.self).baseAddress,
                input.baseAddress,
                input.count,
                seek,
                rawOutput.bindMemory(to: UInt8.self).baseAddress,
                rawOutput.count
            )
        }
        return output
    }

    public static func deriveKey(
        context: UnsafeRawBufferPointer,
        material: UnsafeRawBufferPointer,
        outputByteCount: Int,
        seek: UInt64 = 0
    ) -> [UInt8] {
        precondition(outputByteCount >= 0)
        guard outputByteCount > 0 else {
            return []
        }
        var output = [UInt8](repeating: 0, count: outputByteCount)
        output.withUnsafeMutableBytes { rawOutput in
            cblake3_derive_key_raw(
                context.baseAddress,
                context.count,
                material.baseAddress,
                material.count,
                seek,
                rawOutput.bindMemory(to: UInt8.self).baseAddress,
                rawOutput.count
            )
        }
        return output
    }

    public static var version: String {
        String(cString: cblake3_version())
    }
}
