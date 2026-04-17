import Foundation

public extension BLAKE3 {
    /// CPU hashing mode for ``Context``.
    enum CPUHashMode: Equatable, Sendable {
        /// Selects the library default for the input size.
        case automatic
        /// Uses the scalar compression path.
        case scalar
        /// Uses the serial SIMD-enabled CPU path where available.
        case serial
        /// Uses CPU parallelism, optionally pinned to a worker count for reproducible runs.
        case parallel(maxWorkers: Int?)
    }

    /// Reusable CPU hashing context.
    ///
    /// `Context` owns reusable scratch buffers and serializes calls with an internal lock. This makes it
    /// safe to share across tasks, but concurrent callers execute one hash at a time. Use separate contexts
    /// when independent callers should hash in parallel. Repeated parallel hashes reuse a dedicated
    /// scheduler and chaining-value workspace.
    final class Context: @unchecked Sendable {
        public let maxWorkers: Int

        private let key: BLAKE3Core.ChainingValue
        private let flags: UInt32
        private let lock = NSLock()
        private let scheduler: BLAKE3Core.ParallelScheduler
        private var workspace = BLAKE3Core.Workspace()

        /// Creates an unkeyed reusable context.
        ///
        /// Pass `maxWorkers` to pin repeated parallel hashes for benchmark reproducibility.
        public init(maxWorkers: Int? = nil) {
            self.maxWorkers = BLAKE3Core.normalizedParallelWorkerCount(maxWorkers)
            self.key = BLAKE3Core.iv
            self.flags = 0
            self.scheduler = BLAKE3Core.ParallelScheduler(workerCount: self.maxWorkers)
        }

        /// Creates a keyed reusable context.
        ///
        /// `key` must be exactly ``BLAKE3/keyByteCount`` bytes and is copied into the context as key words.
        public init(key: some ContiguousBytes, maxWorkers: Int? = nil) throws {
            self.maxWorkers = BLAKE3Core.normalizedParallelWorkerCount(maxWorkers)
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
            self.scheduler = BLAKE3Core.ParallelScheduler(workerCount: self.maxWorkers)
        }

        /// Creates a key-derivation context.
        ///
        /// `context` is encoded as UTF-8 exactly and retained only through the derived context key.
        public init(deriveKeyContext context: String, maxWorkers: Int? = nil) {
            self.maxWorkers = BLAKE3Core.normalizedParallelWorkerCount(maxWorkers)
            let contextBytes = Array(context.utf8)
            self.key = contextBytes.withUnsafeBytes { raw in
                BLAKE3Core.deriveKeyContextKey(raw)
            }
            self.flags = BLAKE3Core.deriveKeyMaterial
            self.scheduler = BLAKE3Core.ParallelScheduler(workerCount: self.maxWorkers)
        }

        /// Hashes contiguous input using this context's reusable workspace.
        public func hash(
            _ input: some ContiguousBytes,
            mode: CPUHashMode = .automatic
        ) -> Digest {
            input.withUnsafeBytes { raw in
                hash(raw, mode: mode)
            }
        }

        /// Hashes raw input using this context's reusable workspace.
        ///
        /// The buffer only needs to remain valid for the duration of this call.
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
                    scheduler: scheduler,
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
                    scheduler: scheduler,
                    workspace: &workspace
                ).rootBytes(byteCount: BLAKE3.digestByteCount))
            }
        }

        /// Clears reusable workspace storage.
        ///
        /// Keep capacity between benchmark iterations to avoid measuring allocation churn; drop capacity
        /// when the context should release memory after unusually large inputs.
        public func resetWorkspace(keepingCapacity: Bool = true) {
            lock.lock()
            workspace.reset(keepingCapacity: keepingCapacity)
            lock.unlock()
        }
    }
}
