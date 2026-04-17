import Foundation

public extension BLAKE3 {
    enum CPUHashMode: Equatable, Sendable {
        case automatic
        case scalar
        case serial
        case parallel(maxWorkers: Int?)
    }

    final class Context: @unchecked Sendable {
        private let key: BLAKE3Core.ChainingValue
        private let flags: UInt32
        private let lock = NSLock()
        private var workspace = BLAKE3Core.Workspace()

        public init() {
            self.key = BLAKE3Core.iv
            self.flags = 0
        }

        public init(key: some ContiguousBytes) throws {
            self.key = try key.withUnsafeBytes { keyBytes in
                guard keyBytes.count == BLAKE3.keyByteCount else {
                    throw BLAKE3Error.invalidKeyLength(
                        expected: BLAKE3.keyByteCount,
                        actual: keyBytes.count
                    )
                }
                return BLAKE3Core.keyedWords(keyBytes)
            }
            self.flags = BLAKE3Core.keyedHash
        }

        public init(deriveKeyContext context: String) {
            let contextBytes = Array(context.utf8)
            self.key = contextBytes.withUnsafeBytes { raw in
                BLAKE3Core.deriveKeyContextKey(raw)
            }
            self.flags = BLAKE3Core.deriveKeyMaterial
        }

        public func hash(
            _ input: some ContiguousBytes,
            mode: CPUHashMode = .automatic
        ) -> Digest {
            input.withUnsafeBytes { raw in
                hash(raw, mode: mode)
            }
        }

        public func hash(
            _ input: UnsafeRawBufferPointer,
            mode: CPUHashMode = .automatic
        ) -> Digest {
            lock.lock()
            defer {
                lock.unlock()
            }

            switch mode {
            case .scalar:
                return Digest(BLAKE3Core.hashScalar(input, key: key, flags: flags))
            case .serial:
                return Digest(BLAKE3Core.hash(input, key: key, flags: flags))
            case .automatic:
                if input.count < BLAKE3Core.parallelMinBytes || input.count <= BLAKE3Core.chunkLen {
                    return Digest(BLAKE3Core.hash(input, key: key, flags: flags))
                }
                return Digest(BLAKE3Core.rootOutput(
                    input,
                    key: key,
                    flags: flags,
                    maxWorkers: nil,
                    workspace: &workspace
                ).rootBytes(byteCount: BLAKE3.digestByteCount))
            case let .parallel(maxWorkers):
                if maxWorkers == 1 {
                    return Digest(BLAKE3Core.hash(input, key: key, flags: flags))
                }
                return Digest(BLAKE3Core.rootOutput(
                    input,
                    key: key,
                    flags: flags,
                    maxWorkers: maxWorkers,
                    workspace: &workspace
                ).rootBytes(byteCount: BLAKE3.digestByteCount))
            }
        }

        public func resetWorkspace(keepingCapacity: Bool = true) {
            lock.lock()
            workspace.reset(keepingCapacity: keepingCapacity)
            lock.unlock()
        }
    }
}
