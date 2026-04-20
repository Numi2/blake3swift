import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

private final class BLAKE3HasherStorage: @unchecked Sendable {
    private static let chunkBlockCount = BLAKE3Core.chunkLen / BLAKE3Core.blockLen

    private var key: BLAKE3Core.ChainingValue
    let flags: UInt32
    private var cvStack: BLAKE3Core.CVStack
    private var currentCV: BLAKE3Core.ChainingValue
    private var bufferedBlockWords: BLAKE3Core.BlockWords
    private var bufferedBlockLength: Int
    private var compressedBlockCount: Int
    private var parallelChunkCVs: [BLAKE3Core.ChainingValue]

    init(key: BLAKE3Core.ChainingValue = BLAKE3Core.iv, flags: UInt32 = 0) {
        self.key = key
        self.flags = flags
        self.cvStack = BLAKE3Core.CVStack()
        self.currentCV = key
        self.bufferedBlockWords = BLAKE3Core.BlockWords(repeating: 0)
        self.bufferedBlockLength = 0
        self.compressedBlockCount = 0
        self.parallelChunkCVs = []
    }

    init(copying other: BLAKE3HasherStorage) {
        self.key = other.key
        self.flags = other.flags
        self.cvStack = other.cvStack
        self.currentCV = other.currentCV
        self.bufferedBlockWords = other.bufferedBlockWords
        self.bufferedBlockLength = other.bufferedBlockLength
        self.compressedBlockCount = other.compressedBlockCount
        self.parallelChunkCVs = other.parallelChunkCVs
    }

    func copy() -> BLAKE3HasherStorage {
        BLAKE3HasherStorage(copying: self)
    }

    deinit {
        reset(keepingCapacity: false, wiping: containsSecretState)
        if containsSecretState {
            BLAKE3Core.secureWipe(&key)
        }
    }

    func update(_ input: UnsafeRawBufferPointer) {
        guard input.count > 0,
              let baseAddress = input.baseAddress
        else {
            return
        }

        var offset = 0

        if currentChunkIsComplete {
            appendCurrentChunkCV()
        }

        if bufferedBlockLength == BLAKE3Core.blockLen {
            compressBufferedBlock()
        }

        if bufferedBlockLength > 0 {
            let byteCount = min(BLAKE3Core.blockLen - bufferedBlockLength, input.count)
            appendBytes(from: baseAddress.advanced(by: offset), count: byteCount)
            offset += byteCount

            if bufferedBlockLength == BLAKE3Core.blockLen, offset < input.count {
                if compressedBlockCount == Self.chunkBlockCount - 1 {
                    appendCurrentChunkCV()
                } else {
                    compressBufferedBlock()
                }
            } else {
                return
            }
        }

        while currentChunkIsEmpty, input.count - offset > BLAKE3Core.chunkLen {
            appendChunkCV(
                BLAKE3Core.blake3ProcessFullChunk(
                    baseAddress: baseAddress,
                    chunkByteOffset: offset,
                    chunkCounter: cvStack.finalizedChunkCount,
                    key: key,
                    flags: flags
                )
            )
            offset += BLAKE3Core.chunkLen
        }

        if currentChunkIsEmpty, input.count - offset > BLAKE3Core.blockLen {
            loadCurrentChunk(from: baseAddress.advanced(by: offset), count: input.count - offset)
            return
        }

        while offset < input.count {
            if currentChunkIsComplete {
                appendCurrentChunkCV()
            }

            let remaining = input.count - offset
            if bufferedBlockLength == 0, remaining > BLAKE3Core.blockLen {
                if compressedBlockCount == Self.chunkBlockCount - 1 {
                    appendCurrentChunkCV(
                        finalBlockBaseAddress: baseAddress.advanced(by: offset)
                    )
                } else {
                    compressFullBlock(
                        baseAddress: baseAddress.advanced(by: offset)
                    )
                }
                offset += BLAKE3Core.blockLen
                continue
            }

            let byteCount = min(BLAKE3Core.blockLen - bufferedBlockLength, remaining)
            appendBytes(from: baseAddress.advanced(by: offset), count: byteCount)
            offset += byteCount

            if bufferedBlockLength == BLAKE3Core.blockLen, offset < input.count {
                if compressedBlockCount == Self.chunkBlockCount - 1 {
                    appendCurrentChunkCV()
                } else {
                    compressBufferedBlock()
                }
            }
        }
    }

    func updateParallel(
        _ input: UnsafeRawBufferPointer,
        maxWorkers: Int? = nil,
        leavesTrailingChunk: Bool = true
    ) {
        if currentChunkIsComplete {
            appendCurrentChunkCV()
        }

        guard currentChunkIsEmpty,
              input.count >= BLAKE3Core.parallelMinBytes,
              maxWorkers != 1
        else {
            update(input)
            return
        }

        if input.count <= BLAKE3Core.chunkLen {
            update(input)
            return
        }

        guard let baseAddress = input.baseAddress else {
            return
        }

        let chunksToFinalize = leavesTrailingChunk
            ? (input.count - 1) / BLAKE3Core.chunkLen
            : input.count / BLAKE3Core.chunkLen
        if chunksToFinalize == 0 {
            update(input)
            return
        }

        let baseChunkCounter = cvStack.finalizedChunkCount
        let parallelLength = chunksToFinalize * BLAKE3Core.chunkLen
        let prefix = UnsafeRawBufferPointer(start: baseAddress, count: parallelLength)
        guard baseChunkCounter <= UInt64(Int.max) else {
            update(input)
            return
        }

        BLAKE3Core.writeChunkChainingValues(
            prefix,
            key: key,
            flags: flags,
            baseChunkCounter: Int(baseChunkCounter),
            maxWorkers: maxWorkers,
            into: &parallelChunkCVs
        )
        for index in parallelChunkCVs.indices {
            appendChunkCV(parallelChunkCVs[index])
        }

        let remaining = input.count - parallelLength
        if remaining > 0 {
            update(
                UnsafeRawBufferPointer(
                    start: baseAddress.advanced(by: parallelLength),
                    count: remaining
                )
            )
        }
    }

    func reset(keepingCapacity: Bool = true, wiping: Bool? = nil) {
        let shouldWipe = wiping ?? containsSecretState
        cvStack.reset(keepingCapacity: keepingCapacity, wiping: shouldWipe)
        if shouldWipe {
            BLAKE3Core.secureWipe(&currentCV)
            withUnsafeMutableBytes(of: &bufferedBlockWords) { raw in
                BLAKE3Core.secureWipe(raw)
            }
            BLAKE3Core.secureWipeChainingValues(&parallelChunkCVs)
        }
        resetCurrentChunk()
        parallelChunkCVs.removeAll(keepingCapacity: keepingCapacity)
    }

    var retainedTreeNodeCount: Int {
        cvStack.retainedTreeNodeCount(hasCurrentChunk: !currentChunkIsEmpty)
    }

    private var containsSecretState: Bool {
        flags != 0
    }

    private var currentChunkIsEmpty: Bool {
        compressedBlockCount == 0 && bufferedBlockLength == 0
    }

    private var currentChunkIsComplete: Bool {
        compressedBlockCount == Self.chunkBlockCount - 1
            && bufferedBlockLength == BLAKE3Core.blockLen
    }

    func rootOutput() -> BLAKE3Core.Output {
        let outputFlags = flags
            | (compressedBlockCount == 0 ? BLAKE3Core.chunkStart : 0)
            | BLAKE3Core.chunkEnd
        let currentChunkOutput = BLAKE3Core.Output(
            inputCV: currentCV,
            blockWords: currentBlockWords(),
            blockLength: UInt32(bufferedBlockLength),
            counter: cvStack.finalizedChunkCount,
            flags: outputFlags
        )

        return cvStack.rootOutput(currentChunkOutput: currentChunkOutput, key: key, flags: flags)
    }

    private func appendCurrentChunkCV() {
        precondition(currentChunkIsComplete)
        let cv = BLAKE3Core.compressChainingValue(
            cv: currentCV,
            blockWords: currentBlockWords(),
            blockLength: UInt32(BLAKE3Core.blockLen),
            counter: cvStack.finalizedChunkCount,
            flags: flags | BLAKE3Core.chunkEnd
        )
        appendChunkCV(cv)
        resetCurrentChunk()
    }

    private func appendCurrentChunkCV(finalBlockBaseAddress: UnsafeRawPointer) {
        precondition(compressedBlockCount == Self.chunkBlockCount - 1)
        precondition(bufferedBlockLength == 0)
        let cv = BLAKE3Core.blake3CompressWithPerm(
            cv: currentCV,
            blockBaseAddress: finalBlockBaseAddress,
            blockLength: UInt32(BLAKE3Core.blockLen),
            counter: cvStack.finalizedChunkCount,
            flags: flags | BLAKE3Core.chunkEnd
        )
        appendChunkCV(cv)
        resetCurrentChunk()
    }

    private func appendChunkCV(_ cv: BLAKE3Core.ChainingValue) {
        cvStack.pushChunkCV(cv, key: key, flags: flags)
    }

    private func compressBufferedBlock() {
        precondition(bufferedBlockLength == BLAKE3Core.blockLen)
        precondition(compressedBlockCount < Self.chunkBlockCount - 1)
        let blockFlags = flags | (compressedBlockCount == 0 ? BLAKE3Core.chunkStart : 0)
        currentCV = BLAKE3Core.compressChainingValue(
            cv: currentCV,
            blockWords: currentBlockWords(),
            blockLength: UInt32(BLAKE3Core.blockLen),
            counter: cvStack.finalizedChunkCount,
            flags: blockFlags
        )
        compressedBlockCount += 1
        resetBufferedBlock()
    }

    private func compressFullBlock(baseAddress: UnsafeRawPointer) {
        precondition(bufferedBlockLength == 0)
        precondition(compressedBlockCount < Self.chunkBlockCount - 1)
        let blockFlags = flags | (compressedBlockCount == 0 ? BLAKE3Core.chunkStart : 0)
        currentCV = BLAKE3Core.blake3CompressWithPerm(
            cv: currentCV,
            blockBaseAddress: baseAddress,
            blockLength: UInt32(BLAKE3Core.blockLen),
            counter: cvStack.finalizedChunkCount,
            flags: blockFlags
        )
        compressedBlockCount += 1
    }

    private func currentBlockWords() -> BLAKE3Core.BlockWords {
        var words = bufferedBlockWords
        BLAKE3Core.canonicalLittleEndianWords(&words)
        return words
    }

    private func resetCurrentChunk() {
        currentCV = key
        compressedBlockCount = 0
        resetBufferedBlock()
    }

    private func resetBufferedBlock() {
        bufferedBlockWords = BLAKE3Core.BlockWords(repeating: 0)
        bufferedBlockLength = 0
    }

    private func loadCurrentChunk(from pointer: UnsafeRawPointer, count: Int) {
        precondition(currentChunkIsEmpty)
        precondition(count > BLAKE3Core.blockLen && count <= BLAKE3Core.chunkLen)
        let output = BLAKE3Core.chunkOutput(
            UnsafeRawBufferPointer(start: pointer, count: count),
            chunkCounter: cvStack.finalizedChunkCount,
            key: key,
            flags: flags
        )
        currentCV = output.inputCV
        bufferedBlockWords = output.blockWords
        bufferedBlockLength = Int(output.blockLength)
        compressedBlockCount = (count + BLAKE3Core.blockLen - 1) / BLAKE3Core.blockLen - 1
    }

    private func appendBytes(from pointer: UnsafeRawPointer, count: Int) {
        guard count > 0 else {
            return
        }
        precondition(bufferedBlockLength + count <= BLAKE3Core.blockLen)
        withUnsafeMutableBytes(of: &bufferedBlockWords) { destination in
            destination.baseAddress!
                .advanced(by: bufferedBlockLength)
                .copyMemory(from: pointer, byteCount: count)
        }
        bufferedBlockLength += count
    }
}

public extension BLAKE3 {
    /// Incremental BLAKE3 hasher with copy-on-write value semantics.
    ///
    /// `Hasher` is intended to be mutated by one task at a time. Copying a hasher is cheap until either
    /// copy is mutated, at which point the internal chaining-value stack and current block state are copied.
    struct Hasher {
        private var storage: BLAKE3HasherStorage

        /// Creates an unkeyed streaming hasher.
        public init() {
            self.storage = BLAKE3HasherStorage()
        }

        /// Creates a keyed streaming hasher.
        ///
        /// `key` must be exactly ``BLAKE3/keyByteCount`` bytes and is not retained after initialization.
        public init(key: some ContiguousBytes) throws {
            self.storage = try key.withUnsafeBytes { keyBytes in
                guard keyBytes.count == BLAKE3.keyByteCount else {
                    throw BLAKE3Error.invalidKeyLength(
                        expected: BLAKE3.keyByteCount,
                        actual: keyBytes.count
                    )
                }
                var keyWords = BLAKE3Core.keyedWords(keyBytes)
                defer {
                    BLAKE3Core.secureWipe(&keyWords)
                }
                return BLAKE3HasherStorage(
                    key: keyWords,
                    flags: BLAKE3Core.keyedHash
                )
            }
        }

        /// Creates a streaming hasher for BLAKE3 key derivation.
        ///
        /// `context` is encoded as UTF-8 exactly.
        public init(deriveKeyContext context: String) {
            let contextBytes = Array(context.utf8)
            var contextKey = contextBytes.withUnsafeBytes { raw in
                BLAKE3Core.deriveKeyContextKey(raw)
            }
            defer {
                BLAKE3Core.secureWipe(&contextKey)
            }
            self.storage = BLAKE3HasherStorage(
                key: contextKey,
                flags: BLAKE3Core.deriveKeyMaterial
            )
        }

        init(key: BLAKE3Core.ChainingValue, flags: UInt32) {
            self.storage = BLAKE3HasherStorage(key: key, flags: flags)
        }

        private mutating func ensureUniqueStorage() {
            if !isKnownUniquelyReferenced(&storage) {
                storage = storage.copy()
            }
        }

        /// Adds contiguous input to the stream.
        public mutating func update(_ input: some ContiguousBytes) {
            input.withUnsafeBytes { raw in
                update(raw)
            }
        }

        /// Adds raw input to the stream.
        ///
        /// The buffer only needs to remain valid for the duration of this call.
        public mutating func update(_ input: UnsafeRawBufferPointer) {
            ensureUniqueStorage()
            storage.update(input)
        }

        /// Adds contiguous input using CPU parallelism when the input is large enough.
        ///
        /// Pass `maxWorkers` to pin the worker count for benchmark reproducibility.
        public mutating func updateParallel(_ input: some ContiguousBytes, maxWorkers: Int? = nil) {
            input.withUnsafeBytes { raw in
                updateParallel(raw, maxWorkers: maxWorkers)
            }
        }

        /// Adds raw input using CPU parallelism when the input is large enough.
        public mutating func updateParallel(_ input: UnsafeRawBufferPointer, maxWorkers: Int? = nil) {
            ensureUniqueStorage()
            storage.updateParallel(input, maxWorkers: maxWorkers)
        }

        mutating func _updateParallelNonFinal(_ input: UnsafeRawBufferPointer, maxWorkers: Int? = nil) {
            ensureUniqueStorage()
            storage.updateParallel(input, maxWorkers: maxWorkers, leavesTrailingChunk: false)
        }

        /// Resets the stream while keeping internal capacity for reuse.
        public mutating func reset() {
            ensureUniqueStorage()
            storage.reset()
        }

        var _debugRetainedTreeNodeCount: Int {
            storage.retainedTreeNodeCount
        }

        /// Finalizes the stream into a 32-byte digest without consuming the hasher.
        public func finalize() -> Digest {
            var output = [UInt8](repeating: 0, count: BLAKE3.digestByteCount)
            output.withUnsafeMutableBytes { raw in
                finalize(into: raw)
            }
            return Digest(output)
        }

        /// Writes root output bytes without consuming the hasher.
        ///
        /// Passing a buffer larger than 32 bytes uses BLAKE3's extendable-output mode.
        public func finalize(into output: UnsafeMutableRawBufferPointer) {
            storage.rootOutput().writeRootBytes(into: output)
        }

        /// Creates an extendable-output reader without consuming the hasher.
        public func finalizeXOF() -> OutputReader {
            OutputReader(output: storage.rootOutput())
        }
    }

    /// Reader for BLAKE3 extendable output.
    struct OutputReader {
        private let output: BLAKE3Core.Output
        /// Current byte position in the output stream.
        public private(set) var position: UInt64

        fileprivate init(output: BLAKE3Core.Output, position: UInt64 = 0) {
            self.output = output
            self.position = position
        }

        /// Sets the next byte offset that ``read(into:)`` will read from.
        public mutating func seek(to position: UInt64) {
            self.position = position
        }

        /// Reads bytes into `output` and advances ``position`` by the number of bytes written.
        public mutating func read(into output: UnsafeMutableRawBufferPointer) {
            self.output.writeRootBytes(into: output, seek: position)
            position &+= UInt64(output.count)
        }
    }
}

#if canImport(CryptoKit)
extension BLAKE3.Hasher: CryptoKit.HashFunction {
    public static var blockByteCount: Int {
        BLAKE3.blockByteCount
    }

    public static var byteCount: Int {
        BLAKE3.digestByteCount
    }

    public mutating func update(bufferPointer: UnsafeRawBufferPointer) {
        update(bufferPointer)
    }
}
#endif
