public extension BLAKE3 {
    /// Fixed-size 32-byte BLAKE3 digest.
    ///
    /// `Digest` is value-typed, `Sendable`, and compares using a constant-time byte comparison.
    struct Digest: Sendable, Hashable, CustomStringConvertible {
        /// Number of bytes in a standard BLAKE3 digest.
        public static let byteCount = 32

        private typealias Storage = (
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
        )

        private let storage: Storage

        init(_ bytes: [UInt8]) {
            precondition(bytes.count == Self.byteCount)
            self.storage = (
                bytes[0], bytes[1], bytes[2], bytes[3],
                bytes[4], bytes[5], bytes[6], bytes[7],
                bytes[8], bytes[9], bytes[10], bytes[11],
                bytes[12], bytes[13], bytes[14], bytes[15],
                bytes[16], bytes[17], bytes[18], bytes[19],
                bytes[20], bytes[21], bytes[22], bytes[23],
                bytes[24], bytes[25], bytes[26], bytes[27],
                bytes[28], bytes[29], bytes[30], bytes[31]
            )
        }

        init(_ bytes: UnsafeRawBufferPointer) {
            precondition(bytes.count == Self.byteCount)
            let bound = bytes.bindMemory(to: UInt8.self)
            self.storage = (
                bound[0], bound[1], bound[2], bound[3],
                bound[4], bound[5], bound[6], bound[7],
                bound[8], bound[9], bound[10], bound[11],
                bound[12], bound[13], bound[14], bound[15],
                bound[16], bound[17], bound[18], bound[19],
                bound[20], bound[21], bound[22], bound[23],
                bound[24], bound[25], bound[26], bound[27],
                bound[28], bound[29], bound[30], bound[31]
            )
        }

        /// Provides temporary raw access to the digest bytes.
        ///
        /// The pointer passed to `body` is only valid for the duration of the closure.
        public func withUnsafeBytes<R>(
            _ body: (UnsafeRawBufferPointer) throws -> R
        ) rethrows -> R {
            var copy = storage
            return try Swift.withUnsafeBytes(of: &copy) { raw in
                try body(raw)
            }
        }

        /// Digest bytes in canonical order.
        public var bytes: [UInt8] {
            withUnsafeBytes { raw in
                Array(raw.bindMemory(to: UInt8.self))
            }
        }

        /// Compares two digests without data-dependent early exit.
        public func constantTimeEquals(_ other: Digest) -> Bool {
            var difference: UInt8 = 0
            withUnsafeBytes { lhs in
                other.withUnsafeBytes { rhs in
                    let left = lhs.bindMemory(to: UInt8.self)
                    let right = rhs.bindMemory(to: UInt8.self)
                    for index in 0..<Self.byteCount {
                        difference |= left[index] ^ right[index]
                    }
                }
            }
            return difference == 0
        }

        public static func == (lhs: Digest, rhs: Digest) -> Bool {
            lhs.constantTimeEquals(rhs)
        }

        public func hash(into hasher: inout Swift.Hasher) {
            withUnsafeBytes { raw in
                for byte in raw.bindMemory(to: UInt8.self) {
                    hasher.combine(byte)
                }
            }
        }

        /// Lowercase hexadecimal digest string.
        public var description: String {
            let table = Array("0123456789abcdef".utf8)
            var output = [UInt8]()
            output.reserveCapacity(Self.byteCount * 2)
            withUnsafeBytes { raw in
                for byte in raw.bindMemory(to: UInt8.self) {
                    output.append(table[Int(byte >> 4)])
                    output.append(table[Int(byte & 0x0f)])
                }
            }
            return String(decoding: output, as: UTF8.self)
        }
    }
}
