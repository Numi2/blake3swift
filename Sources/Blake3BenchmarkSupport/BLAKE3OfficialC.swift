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

    public static var version: String {
        String(cString: cblake3_version())
    }
}
