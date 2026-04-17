import Foundation

private final class BLAKE3HasherStorage {
    let key: BLAKE3Core.ChainingValue
    let flags: UInt32
    private var cvStack: BLAKE3Core.CVStack
    private var chunkBuffer: [UInt8]
    private var parallelChunkCVs: [BLAKE3Core.ChainingValue]

    init(key: BLAKE3Core.ChainingValue = BLAKE3Core.iv, flags: UInt32 = 0) {
        self.key = key
        self.flags = flags
        self.cvStack = BLAKE3Core.CVStack()
        self.chunkBuffer = []
        self.parallelChunkCVs = []
        self.chunkBuffer.reserveCapacity(BLAKE3Core.chunkLen)
    }

    init(copying other: BLAKE3HasherStorage) {
        self.key = other.key
        self.flags = other.flags
        self.cvStack = other.cvStack
        self.chunkBuffer = other.chunkBuffer
        self.parallelChunkCVs = other.parallelChunkCVs
    }

    func copy() -> BLAKE3HasherStorage {
        BLAKE3HasherStorage(copying: self)
    }

    func update(_ input: UnsafeRawBufferPointer) {
        guard input.count > 0,
              let baseAddress = input.baseAddress
        else {
            return
        }

        var offset = 0

        if chunkBuffer.count == BLAKE3Core.chunkLen {
            appendCurrentChunkCV()
        }

        if !chunkBuffer.isEmpty {
            let byteCount = min(BLAKE3Core.chunkLen - chunkBuffer.count, input.count)
            appendBytes(from: baseAddress.advanced(by: offset), count: byteCount)
            offset += byteCount

            if chunkBuffer.count == BLAKE3Core.chunkLen, offset < input.count {
                appendCurrentChunkCV()
            } else {
                return
            }
        }

        if input.count - offset > BLAKE3Core.chunkLen {
            BLAKE3Core.withMessageSchedule { schedule in
                while input.count - offset > BLAKE3Core.chunkLen {
                    appendChunkCV(
                        BLAKE3Core.blake3ProcessFullChunk(
                            baseAddress: baseAddress,
                            chunkByteOffset: offset,
                            chunkCounter: cvStack.finalizedChunkCount,
                            key: key,
                            flags: flags,
                            schedule: schedule
                        )
                    )
                    offset += BLAKE3Core.chunkLen
                }
            }
        }

        let remaining = input.count - offset
        if remaining > 0 {
            appendBytes(from: baseAddress.advanced(by: offset), count: remaining)
        }
    }

    func updateParallel(
        _ input: UnsafeRawBufferPointer,
        maxWorkers: Int? = nil,
        leavesTrailingChunk: Bool = true
    ) {
        if chunkBuffer.count == BLAKE3Core.chunkLen {
            appendCurrentChunkCV()
        }

        guard chunkBuffer.isEmpty,
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
            appendBytes(from: baseAddress.advanced(by: parallelLength), count: remaining)
        }
    }

    func reset() {
        cvStack.reset(keepingCapacity: true)
        chunkBuffer.removeAll(keepingCapacity: true)
        parallelChunkCVs.removeAll(keepingCapacity: true)
    }

    var retainedTreeNodeCount: Int {
        cvStack.retainedTreeNodeCount(hasCurrentChunk: !chunkBuffer.isEmpty)
    }

    func rootOutput() -> BLAKE3Core.Output {
        let currentChunkOutput = chunkBuffer.withUnsafeBytes { raw in
            BLAKE3Core.chunkOutput(
                raw,
                chunkCounter: cvStack.finalizedChunkCount,
                key: key,
                flags: flags
            )
        }

        return cvStack.rootOutput(currentChunkOutput: currentChunkOutput, key: key, flags: flags)
    }

    private func appendCurrentChunkCV() {
        precondition(chunkBuffer.count == BLAKE3Core.chunkLen)
        let cv = chunkBuffer.withUnsafeBytes { raw in
            BLAKE3Core.withMessageSchedule { schedule in
                BLAKE3Core.blake3ProcessFullChunk(
                    baseAddress: raw.baseAddress!,
                    chunkByteOffset: 0,
                    chunkCounter: cvStack.finalizedChunkCount,
                    key: key,
                    flags: flags,
                    schedule: schedule
                )
            }
        }
        appendChunkCV(cv)
        chunkBuffer.removeAll(keepingCapacity: true)
    }

    private func appendChunkCV(_ cv: BLAKE3Core.ChainingValue) {
        cvStack.pushChunkCV(cv, key: key, flags: flags)
    }

    private func appendBytes(from pointer: UnsafeRawPointer, count: Int) {
        guard count > 0 else {
            return
        }
        let bytes = UnsafeRawBufferPointer(start: pointer, count: count).bindMemory(to: UInt8.self)
        chunkBuffer.append(contentsOf: bytes)
    }
}

public extension BLAKE3 {
    struct Hasher {
        private var storage: BLAKE3HasherStorage

        public init() {
            self.storage = BLAKE3HasherStorage()
        }

        public init(key: some ContiguousBytes) throws {
            self.storage = try key.withUnsafeBytes { keyBytes in
                guard keyBytes.count == BLAKE3.keyByteCount else {
                    throw BLAKE3Error.invalidKeyLength(
                        expected: BLAKE3.keyByteCount,
                        actual: keyBytes.count
                    )
                }
                return BLAKE3HasherStorage(
                    key: BLAKE3Core.keyedWords(keyBytes),
                    flags: BLAKE3Core.keyedHash
                )
            }
        }

        public init(deriveKeyContext context: String) {
            let contextBytes = Array(context.utf8)
            let contextKey = contextBytes.withUnsafeBytes { raw in
                BLAKE3Core.deriveKeyContextKey(raw)
            }
            self.storage = BLAKE3HasherStorage(
                key: contextKey,
                flags: BLAKE3Core.deriveKeyMaterial
            )
        }

        private mutating func ensureUniqueStorage() {
            if !isKnownUniquelyReferenced(&storage) {
                storage = storage.copy()
            }
        }

        public mutating func update(_ input: some ContiguousBytes) {
            input.withUnsafeBytes { raw in
                update(raw)
            }
        }

        public mutating func update(_ input: UnsafeRawBufferPointer) {
            ensureUniqueStorage()
            storage.update(input)
        }

        public mutating func updateParallel(_ input: some ContiguousBytes, maxWorkers: Int? = nil) {
            input.withUnsafeBytes { raw in
                updateParallel(raw, maxWorkers: maxWorkers)
            }
        }

        public mutating func updateParallel(_ input: UnsafeRawBufferPointer, maxWorkers: Int? = nil) {
            ensureUniqueStorage()
            storage.updateParallel(input, maxWorkers: maxWorkers)
        }

        mutating func _updateParallelNonFinal(_ input: UnsafeRawBufferPointer, maxWorkers: Int? = nil) {
            ensureUniqueStorage()
            storage.updateParallel(input, maxWorkers: maxWorkers, leavesTrailingChunk: false)
        }

        public mutating func reset() {
            ensureUniqueStorage()
            storage.reset()
        }

        var _debugRetainedTreeNodeCount: Int {
            storage.retainedTreeNodeCount
        }

        public func finalize() -> Digest {
            var output = [UInt8](repeating: 0, count: BLAKE3.digestByteCount)
            output.withUnsafeMutableBytes { raw in
                finalize(into: raw)
            }
            return Digest(output)
        }

        public func finalize(into output: UnsafeMutableRawBufferPointer) {
            storage.rootOutput().writeRootBytes(into: output)
        }

        public func finalizeXOF() -> OutputReader {
            OutputReader(output: storage.rootOutput())
        }
    }

    struct OutputReader {
        private let output: BLAKE3Core.Output
        public private(set) var position: UInt64

        fileprivate init(output: BLAKE3Core.Output, position: UInt64 = 0) {
            self.output = output
            self.position = position
        }

        public mutating func seek(to position: UInt64) {
            self.position = position
        }

        public mutating func read(into output: UnsafeMutableRawBufferPointer) {
            self.output.writeRootBytes(into: output, seek: position)
            position &+= UInt64(output.count)
        }
    }
}
