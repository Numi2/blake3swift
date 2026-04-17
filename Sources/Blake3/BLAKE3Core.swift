import Dispatch
#if canImport(Darwin)
import Darwin
#endif
import Foundation

enum BLAKE3Core {
    typealias ChainingValue = SIMD8<UInt32>
    typealias BlockWords = SIMD16<UInt32>

    static let outLen = 32
    static let keyLen = 32
    static let blockLen = 64
    static let chunkLen = 1_024
    static let simdMinBytes = 16 * 1_024
    static let parallelMinBytes = 256 * 1_024
    static let defaultParallelWorkerCount = detectedDefaultParallelWorkerCount()

    static let chunkStart: UInt32 = 1 << 0
    static let chunkEnd: UInt32 = 1 << 1
    static let parent: UInt32 = 1 << 2
    static let root: UInt32 = 1 << 3
    static let keyedHash: UInt32 = 1 << 4
    static let deriveKeyContext: UInt32 = 1 << 5
    static let deriveKeyMaterial: UInt32 = 1 << 6

    private static let messageSchedule: [UInt8] = [
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
        2, 6, 3, 10, 7, 0, 4, 13, 1, 11, 12, 5, 9, 14, 15, 8,
        3, 4, 10, 12, 13, 2, 7, 14, 6, 5, 9, 0, 11, 15, 8, 1,
        10, 7, 12, 9, 14, 3, 13, 15, 4, 0, 11, 2, 5, 8, 1, 6,
        12, 13, 9, 11, 15, 10, 14, 8, 7, 2, 5, 3, 0, 1, 6, 4,
        9, 14, 11, 5, 8, 12, 15, 1, 13, 3, 0, 10, 2, 6, 4, 7,
        11, 15, 5, 0, 1, 9, 8, 6, 14, 10, 2, 12, 3, 4, 7, 13
    ]

    static let iv = ChainingValue(
        0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A,
        0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19
    )

    struct SendableRawBuffer: @unchecked Sendable {
        let baseAddress: UnsafeRawPointer
        let count: Int

        func slice(offset: Int, count: Int) -> UnsafeRawBufferPointer {
            UnsafeRawBufferPointer(start: baseAddress.advanced(by: offset), count: count)
        }
    }

    struct SendableCVStorage: @unchecked Sendable {
        let baseAddress: UnsafeMutablePointer<ChainingValue>
        var indexOffset: Int = 0

        func store(_ value: ChainingValue, at index: Int) {
            baseAddress[index - indexOffset] = value
        }
    }

    struct SendableCVInput: @unchecked Sendable {
        let baseAddress: UnsafePointer<ChainingValue>

        subscript(index: Int) -> ChainingValue {
            baseAddress[index]
        }
    }

    struct SendableMessageSchedule: @unchecked Sendable {
        let baseAddress: UnsafePointer<UInt8>
    }

    @inline(__always)
    static func withMessageSchedule<R>(_ body: (SendableMessageSchedule) -> R) -> R {
        messageSchedule.withUnsafeBufferPointer { schedule in
            body(SendableMessageSchedule(baseAddress: schedule.baseAddress!))
        }
    }

    struct Workspace {
        var chunkCVs: [ChainingValue] = []
        var scratchCVs: [ChainingValue] = []

        mutating func reset(keepingCapacity: Bool = true) {
            chunkCVs.removeAll(keepingCapacity: keepingCapacity)
            scratchCVs.removeAll(keepingCapacity: keepingCapacity)
        }
    }

    private final class ParallelSchedulerState: @unchecked Sendable {
        let workerCount: Int
        let startSemaphore = DispatchSemaphore(value: 0)
        let doneSemaphore = DispatchSemaphore(value: 0)
        let stateLock = NSLock()
        let performLock = NSLock()
        var iterations = 0
        var nextIndex = 0
        var body: (@Sendable (Int) -> Void)?
        var shutdown = false

        init(workerCount: Int) {
            self.workerCount = workerCount
        }
    }

    final class ParallelScheduler: @unchecked Sendable {
        let workerCount: Int
        private let state: ParallelSchedulerState
        private var workers: [Thread] = []

        init(workerCount: Int) {
            self.workerCount = max(1, workerCount)
            self.state = ParallelSchedulerState(workerCount: self.workerCount)
            if self.workerCount > 1 {
                self.workers = (0..<self.workerCount).map { workerIndex in
                    let thread = Thread { [state] in
                        Self.workerLoop(state: state, workerIndex: workerIndex)
                    }
                    thread.name = "com.blake3swift.cpu-parallel.\(self.workerCount).\(workerIndex)"
                    thread.qualityOfService = .userInitiated
                    thread.start()
                    return thread
                }
            }
        }

        deinit {
            state.performLock.lock()
            state.stateLock.lock()
            state.shutdown = true
            state.body = nil
            state.iterations = 0
            state.nextIndex = 0
            state.stateLock.unlock()
            for _ in workers {
                state.startSemaphore.signal()
            }
            state.performLock.unlock()
        }

        func perform(iterations: Int, _ body: @escaping @Sendable (Int) -> Void) {
            guard iterations > 0 else {
                return
            }
            guard iterations > 1, !workers.isEmpty else {
                for index in 0..<iterations {
                    body(index)
                }
                return
            }

            let activeWorkers = min(iterations, workerCount)
            state.performLock.lock()

            state.stateLock.lock()
            state.iterations = iterations
            state.nextIndex = 0
            state.body = body
            state.stateLock.unlock()

            for _ in 0..<activeWorkers {
                state.startSemaphore.signal()
            }
            for _ in 0..<activeWorkers {
                state.doneSemaphore.wait()
            }

            state.stateLock.lock()
            state.body = nil
            state.iterations = 0
            state.nextIndex = 0
            state.stateLock.unlock()

            state.performLock.unlock()
        }

        private static func workerLoop(state: ParallelSchedulerState, workerIndex _: Int) {
            while true {
                state.startSemaphore.wait()

                while true {
                    state.stateLock.lock()
                    if state.shutdown {
                        state.stateLock.unlock()
                        return
                    }
                    guard let body = state.body, state.nextIndex < state.iterations else {
                        state.stateLock.unlock()
                        break
                    }
                    let index = state.nextIndex
                    state.nextIndex += 1
                    state.stateLock.unlock()

                    body(index)
                }

                state.doneSemaphore.signal()
            }
        }
    }

    struct CVStack {
        private struct Entry {
            var cv: ChainingValue
            var chunkCount: UInt64
        }

        private var entries: [Entry] = []
        private(set) var finalizedChunkCount: UInt64 = 0

        init() {
            entries.reserveCapacity(UInt64.bitWidth)
        }

        mutating func reset(keepingCapacity: Bool = true) {
            entries.removeAll(keepingCapacity: keepingCapacity)
            finalizedChunkCount = 0
        }

        mutating func pushChunkCV(_ cv: ChainingValue, key: ChainingValue, flags: UInt32) {
            var entry = Entry(cv: cv, chunkCount: 1)
            while let last = entries.last, last.chunkCount == entry.chunkCount {
                entries.removeLast()
                entry = Entry(
                    cv: BLAKE3Core.parentCV(left: last.cv, right: entry.cv, key: key, flags: flags),
                    chunkCount: last.chunkCount + entry.chunkCount
                )
            }
            entries.append(entry)
            finalizedChunkCount &+= 1
        }

        func rootOutput(
            currentChunkOutput: Output,
            key: ChainingValue,
            flags: UInt32
        ) -> Output {
            guard !entries.isEmpty else {
                return currentChunkOutput
            }

            var output = currentChunkOutput
            for entry in entries.reversed() {
                output = BLAKE3Core.parentOutput(
                    left: entry.cv,
                    right: output.chainingValue(),
                    key: key,
                    flags: flags
                )
            }
            return output
        }

        func retainedTreeNodeCount(hasCurrentChunk: Bool) -> Int {
            entries.count + (hasCurrentChunk ? 1 : 0)
        }
    }

    struct Output {
        let inputCV: ChainingValue
        let blockWords: BlockWords
        let blockLength: UInt32
        let counter: UInt64
        let flags: UInt32

        func chainingValue() -> ChainingValue {
            BLAKE3Core.compressChainingValue(
                cv: inputCV,
                blockWords: blockWords,
                blockLength: blockLength,
                counter: counter,
                flags: flags
            )
        }

        func rootBytes(byteCount: Int, seek: UInt64 = 0) -> [UInt8] {
            var output = [UInt8](repeating: 0, count: byteCount)
            output.withUnsafeMutableBytes { raw in
                writeRootBytes(into: raw, seek: seek)
            }
            return output
        }

        func writeRootBytes(into output: UnsafeMutableRawBufferPointer, seek: UInt64 = 0) {
            guard output.count > 0 else {
                return
            }
            guard let outputBase = output.baseAddress else {
                return
            }

            var written = 0
            var outputBlockCounter = seek / UInt64(BLAKE3Core.blockLen)
            var blockOffset = Int(seek % UInt64(BLAKE3Core.blockLen))

            while written < output.count {
                let words = BLAKE3Core.compressXOF(
                    cv: inputCV,
                    blockWords: blockWords,
                    blockLength: blockLength,
                    counter: outputBlockCounter,
                    flags: flags | BLAKE3Core.root
                )

                let available = BLAKE3Core.blockLen - blockOffset
                let byteCount = min(available, output.count - written)
                BLAKE3Core.copyWordBytes(
                    words,
                    sourceByteOffset: blockOffset,
                    into: outputBase.advanced(by: written),
                    byteCount: byteCount
                )

                written += byteCount
                outputBlockCounter &+= 1
                blockOffset = 0
            }
        }
    }

    static func hash(
        _ input: UnsafeRawBufferPointer,
        key: ChainingValue = iv,
        flags: UInt32 = 0,
        outputByteCount: Int = outLen
    ) -> [UInt8] {
        guard input.count >= simdMinBytes else {
            return hashScalar(input, key: key, flags: flags, outputByteCount: outputByteCount)
        }
        return rootOutputStacked(
            input,
            key: key,
            flags: flags,
            useSIMD4: true
        )
        .rootBytes(byteCount: outputByteCount)
    }

    static func hashScalar(
        _ input: UnsafeRawBufferPointer,
        key: ChainingValue = iv,
        flags: UInt32 = 0,
        outputByteCount: Int = outLen
    ) -> [UInt8] {
        rootOutputStacked(input, key: key, flags: flags, useSIMD4: false)
            .rootBytes(byteCount: outputByteCount)
    }

    static func hashParallel(
        _ input: UnsafeRawBufferPointer,
        key: ChainingValue = iv,
        flags: UInt32 = 0,
        outputByteCount: Int = outLen,
        maxWorkers: Int? = nil
    ) -> [UInt8] {
        if input.count < parallelMinBytes || input.count <= chunkLen || maxWorkers == 1 {
            return hash(input, key: key, flags: flags, outputByteCount: outputByteCount)
        }
        var workspace = Workspace()
        return rootOutput(
            input,
            key: key,
            flags: flags,
            maxWorkers: maxWorkers,
            workspace: &workspace
        )
            .rootBytes(byteCount: outputByteCount)
    }

    static func keyedWords(_ key: UnsafeRawBufferPointer) -> ChainingValue {
        precondition(key.count == keyLen)
        return ChainingValue(
            load32(key, at: 0),
            load32(key, at: 4),
            load32(key, at: 8),
            load32(key, at: 12),
            load32(key, at: 16),
            load32(key, at: 20),
            load32(key, at: 24),
            load32(key, at: 28)
        )
    }

    static func chainingValue(
        from input: UnsafeRawBufferPointer,
        atByteOffset offset: Int = 0
    ) -> ChainingValue {
        ChainingValue(
            load32(input, at: offset),
            load32(input, at: offset + 4),
            load32(input, at: offset + 8),
            load32(input, at: offset + 12),
            load32(input, at: offset + 16),
            load32(input, at: offset + 20),
            load32(input, at: offset + 24),
            load32(input, at: offset + 28)
        )
    }

    static func deriveKeyContextKey(_ context: UnsafeRawBufferPointer) -> ChainingValue {
        let contextKeyBytes = hash(
            context,
            key: iv,
            flags: deriveKeyContext,
            outputByteCount: keyLen
        )
        return contextKeyBytes.withUnsafeBytes { raw in
            keyedWords(raw)
        }
    }

    static func digestFromChunkChainingValues(
        _ chunkCVs: UnsafeRawBufferPointer,
        chunkCount: Int
    ) -> BLAKE3.Digest? {
        guard chunkCount >= 2,
              chunkCVs.count >= chunkCount * outLen
        else {
            return nil
        }

        var cvs = [ChainingValue]()
        cvs.reserveCapacity(chunkCount)
        for chunkIndex in 0..<chunkCount {
            let offset = chunkIndex * outLen
            cvs.append(
                ChainingValue(
                    load32(chunkCVs, at: offset),
                    load32(chunkCVs, at: offset + 4),
                    load32(chunkCVs, at: offset + 8),
                    load32(chunkCVs, at: offset + 12),
                    load32(chunkCVs, at: offset + 16),
                    load32(chunkCVs, at: offset + 20),
                    load32(chunkCVs, at: offset + 24),
                    load32(chunkCVs, at: offset + 28)
                )
            )
        }

        let bytes = rootOutput(fromChunkCVs: cvs, key: iv, flags: 0).rootBytes(byteCount: outLen)
        return BLAKE3.Digest(bytes)
    }

    static func rootOutput(
        _ input: UnsafeRawBufferPointer,
        key: ChainingValue,
        flags: UInt32
    ) -> Output {
        if input.count <= chunkLen {
            return chunkOutput(input, chunkCounter: 0, key: key, flags: flags)
        }
        guard let baseAddress = input.baseAddress else {
            return chunkOutput(input, chunkCounter: 0, key: key, flags: flags)
        }

        let chunkCount = (input.count + chunkLen - 1) / chunkLen
        var cvs = [ChainingValue]()
        cvs.reserveCapacity(chunkCount)
        withMessageSchedule { schedule in
            for chunkIndex in 0..<chunkCount {
                let offset = chunkIndex * chunkLen
                let length = min(chunkLen, input.count - offset)
                if length == chunkLen {
                    cvs.append(
                        blake3ProcessFullChunk(
                            baseAddress: baseAddress,
                            chunkByteOffset: offset,
                            chunkCounter: UInt64(chunkIndex),
                            key: key,
                            flags: flags,
                            schedule: schedule
                        )
                    )
                } else {
                    let chunk = UnsafeRawBufferPointer(start: baseAddress.advanced(by: offset), count: length)
                    cvs.append(
                        chunkOutput(chunk, chunkCounter: UInt64(chunkIndex), key: key, flags: flags)
                            .chainingValue()
                    )
                }
            }
        }
        return rootOutput(fromChunkCVs: cvs, key: key, flags: flags)
    }

    static func rootOutput(
        _ input: UnsafeRawBufferPointer,
        key: ChainingValue,
        flags: UInt32,
        maxWorkers: Int?,
        scheduler: ParallelScheduler? = nil,
        workspace: inout Workspace
    ) -> Output {
        if input.count <= chunkLen {
            return rootOutput(input, key: key, flags: flags)
        }

        writeChunkChainingValues(
            input,
            key: key,
            flags: flags,
            maxWorkers: maxWorkers,
            scheduler: scheduler,
            into: &workspace.chunkCVs
        )
        var currentCount = workspace.chunkCVs.count
        var currentIsChunkCVs = true

        while currentCount > 2 {
            if currentIsChunkCVs {
                currentCount = reduceParentLevel(
                    workspace.chunkCVs,
                    count: currentCount,
                    key: key,
                    flags: flags,
                    into: &workspace.scratchCVs,
                    maxWorkers: maxWorkers,
                    scheduler: scheduler
                )
            } else {
                currentCount = reduceParentLevel(
                    workspace.scratchCVs,
                    count: currentCount,
                    key: key,
                    flags: flags,
                    into: &workspace.chunkCVs,
                    maxWorkers: maxWorkers,
                    scheduler: scheduler
                )
            }
            currentIsChunkCVs.toggle()
        }

        let current = currentIsChunkCVs ? workspace.chunkCVs : workspace.scratchCVs
        return parentOutput(left: current[0], right: current[1], key: key, flags: flags)
    }

    static func rootOutput(
        fromChunkCVs chunkCVs: [ChainingValue],
        key: ChainingValue,
        flags: UInt32,
        maxWorkers: Int? = nil
    ) -> Output {
        precondition(chunkCVs.count >= 2)
        var current = chunkCVs
        while current.count > 2 {
            current = reduceParentLevel(current, key: key, flags: flags, maxWorkers: maxWorkers)
        }
        return parentOutput(left: current[0], right: current[1], key: key, flags: flags)
    }

    static func rootOutputStacked(
        _ input: UnsafeRawBufferPointer,
        key: ChainingValue,
        flags: UInt32,
        useSIMD4: Bool
    ) -> Output {
        if input.count <= chunkLen {
            return chunkOutput(input, chunkCounter: 0, key: key, flags: flags)
        }
        guard let baseAddress = input.baseAddress else {
            return chunkOutput(input, chunkCounter: 0, key: key, flags: flags)
        }

        let chunksToFinalize = (input.count - 1) / chunkLen
        var stack = CVStack()
        var chunkIndex = 0
        let inputBytes = SendableRawBuffer(baseAddress: baseAddress, count: input.count)
        var simdCVs = [ChainingValue](repeating: ChainingValue(repeating: 0), count: 4)

        while useSIMD4, chunkIndex + 4 <= chunksToFinalize {
            simdCVs.withUnsafeMutableBufferPointer { outputBuffer in
                BLAKE3SIMD4.hashFourFullChunks(
                    input: inputBytes,
                    firstChunkIndex: chunkIndex,
                    firstChunkCounter: chunkIndex,
                    key: key,
                    flags: flags,
                    output: SendableCVStorage(baseAddress: outputBuffer.baseAddress!, indexOffset: chunkIndex)
                )
            }
            stack.pushChunkCV(simdCVs[0], key: key, flags: flags)
            stack.pushChunkCV(simdCVs[1], key: key, flags: flags)
            stack.pushChunkCV(simdCVs[2], key: key, flags: flags)
            stack.pushChunkCV(simdCVs[3], key: key, flags: flags)
            chunkIndex += 4
        }

        if chunkIndex < chunksToFinalize {
            withMessageSchedule { schedule in
                while chunkIndex < chunksToFinalize {
                    stack.pushChunkCV(
                        blake3ProcessFullChunk(
                            baseAddress: baseAddress,
                            chunkByteOffset: chunkIndex * chunkLen,
                            chunkCounter: UInt64(chunkIndex),
                            key: key,
                            flags: flags,
                            schedule: schedule
                        ),
                        key: key,
                        flags: flags
                    )
                    chunkIndex += 1
                }
            }
        }

        let currentOffset = chunksToFinalize * chunkLen
        let currentChunk = UnsafeRawBufferPointer(
            start: baseAddress.advanced(by: currentOffset),
            count: input.count - currentOffset
        )
        let currentChunkOutput = chunkOutput(
            currentChunk,
            chunkCounter: stack.finalizedChunkCount,
            key: key,
            flags: flags
        )
        return stack.rootOutput(currentChunkOutput: currentChunkOutput, key: key, flags: flags)
    }

    static func chunkOutput(
        _ input: UnsafeRawBufferPointer,
        chunkCounter: UInt64,
        key: ChainingValue,
        flags: UInt32
    ) -> Output {
        precondition(input.count <= chunkLen)
        var cv = key
        let blockCount = max(1, (input.count + blockLen - 1) / blockLen)

        if blockCount > 1 {
            for blockIndex in 0..<(blockCount - 1) {
                let blockOffset = blockIndex * blockLen
                let blockWords = loadFullBlockWords(input, offset: blockOffset)
                let blockFlags = flags | (blockIndex == 0 ? chunkStart : 0)
                compressInPlace(
                    cv: &cv,
                    blockWords: blockWords,
                    blockLength: UInt32(blockLen),
                    counter: chunkCounter,
                    flags: blockFlags
                )
            }
        }

        let lastBlockIndex = blockCount - 1
        let lastBlockOffset = lastBlockIndex * blockLen
        let lastBlockLength = input.count == 0 ? 0 : input.count - lastBlockOffset
        let outputFlags = flags
            | (lastBlockIndex == 0 ? chunkStart : 0)
            | chunkEnd

        return Output(
            inputCV: cv,
            blockWords: loadBlockWords(input, offset: lastBlockOffset),
            blockLength: UInt32(lastBlockLength),
            counter: chunkCounter,
            flags: outputFlags
        )
    }

    @inline(__always)
    static func blake3ProcessFullChunk(
        baseAddress: UnsafeRawPointer,
        chunkByteOffset: Int,
        chunkCounter: UInt64,
        key: ChainingValue,
        flags: UInt32,
        schedule: SendableMessageSchedule
    ) -> ChainingValue {
        var cv = key
        var blockIndex = 0
        while blockIndex < 16 {
            var blockFlags = flags
            if blockIndex == 0 {
                blockFlags |= chunkStart
            }
            if blockIndex == 15 {
                blockFlags |= chunkEnd
            }

            cv = blake3CompressWithPerm(
                cv: cv,
                blockBaseAddress: baseAddress.advanced(by: chunkByteOffset + blockIndex * blockLen),
                blockLength: UInt32(blockLen),
                counter: chunkCounter,
                flags: blockFlags,
                schedule: schedule
            )
            blockIndex += 1
        }
        return cv
    }

    static func parentCV(
        left: ChainingValue,
        right: ChainingValue,
        key: ChainingValue,
        flags: UInt32
    ) -> ChainingValue {
        parentOutput(left: left, right: right, key: key, flags: flags).chainingValue()
    }

    static func parentOutput(
        left: ChainingValue,
        right: ChainingValue,
        key: ChainingValue,
        flags: UInt32
    ) -> Output {
        let blockWords = BlockWords(
            left[0], left[1], left[2], left[3],
            left[4], left[5], left[6], left[7],
            right[0], right[1], right[2], right[3],
            right[4], right[5], right[6], right[7]
        )
        return Output(
            inputCV: key,
            blockWords: blockWords,
            blockLength: UInt32(blockLen),
            counter: 0,
            flags: flags | parent
        )
    }

    static func writeChunkChainingValues(
        _ input: UnsafeRawBufferPointer,
        key: ChainingValue,
        flags: UInt32,
        baseChunkCounter: Int = 0,
        maxWorkers: Int?,
        scheduler: ParallelScheduler? = nil,
        into output: inout [ChainingValue]
    ) {
        let chunkCount = (input.count + chunkLen - 1) / chunkLen
        output.removeAll(keepingCapacity: true)
        guard chunkCount > 0,
              let baseAddress = input.baseAddress
        else {
            return
        }

        output.reserveCapacity(chunkCount)
        output.append(contentsOf: repeatElement(ChainingValue(repeating: 0), count: chunkCount))

        let workerCount = clampedWorkerCount(
            requested: maxWorkers ?? scheduler?.workerCount,
            workItems: chunkCount
        )
        let chunksPerWorker = (chunkCount + workerCount - 1) / workerCount
        let fullChunkCount = input.count / chunkLen
        let inputBytes = SendableRawBuffer(baseAddress: baseAddress, count: input.count)

        withMessageSchedule { schedule in
            output.withUnsafeMutableBufferPointer { outputBuffer in
                let outputStorage = SendableCVStorage(baseAddress: outputBuffer.baseAddress!)
                if workerCount == 1 {
                    writeChunkChainingValueRange(
                        start: 0,
                        end: chunkCount,
                        fullChunkCount: fullChunkCount,
                        baseChunkCounter: baseChunkCounter,
                        inputBytes: inputBytes,
                        key: key,
                        flags: flags,
                        schedule: schedule,
                        output: outputStorage
                    )
                } else {
                    parallelPerform(iterations: workerCount, scheduler: scheduler) { workerIndex in
                        let start = workerIndex * chunksPerWorker
                        let end = min(chunkCount, start + chunksPerWorker)
                        guard start < end else {
                            return
                        }
                        writeChunkChainingValueRange(
                            start: start,
                            end: end,
                            fullChunkCount: fullChunkCount,
                            baseChunkCounter: baseChunkCounter,
                            inputBytes: inputBytes,
                            key: key,
                            flags: flags,
                            schedule: schedule,
                            output: outputStorage
                        )
                    }
                }
            }
        }
    }

    private static func writeChunkChainingValueRange(
        start: Int,
        end: Int,
        fullChunkCount: Int,
        baseChunkCounter: Int,
        inputBytes: SendableRawBuffer,
        key: ChainingValue,
        flags: UInt32,
        schedule: SendableMessageSchedule,
        output: SendableCVStorage
    ) {
        var chunkIndex = start
        while chunkIndex < end {
            if chunkIndex + 4 <= end, chunkIndex + 4 <= fullChunkCount {
                BLAKE3SIMD4.hashFourFullChunks(
                    input: inputBytes,
                    firstChunkIndex: chunkIndex,
                    firstChunkCounter: baseChunkCounter + chunkIndex,
                    key: key,
                    flags: flags,
                    output: output
                )
                chunkIndex += 4
            } else {
                let offset = chunkIndex * chunkLen
                let length = min(chunkLen, inputBytes.count - offset)
                if length == chunkLen {
                    output.store(
                        blake3ProcessFullChunk(
                            baseAddress: inputBytes.baseAddress,
                            chunkByteOffset: offset,
                            chunkCounter: UInt64(baseChunkCounter + chunkIndex),
                            key: key,
                            flags: flags,
                            schedule: schedule
                        ),
                        at: chunkIndex
                    )
                } else {
                    let chunk = inputBytes.slice(offset: offset, count: length)
                    output.store(
                        chunkOutput(
                            chunk,
                            chunkCounter: UInt64(baseChunkCounter + chunkIndex),
                            key: key,
                            flags: flags
                        ).chainingValue(),
                        at: chunkIndex
                    )
                }
                chunkIndex += 1
            }
        }
    }

    private static func reduceParentLevel(
        _ current: [ChainingValue],
        key: ChainingValue,
        flags: UInt32,
        maxWorkers: Int?
    ) -> [ChainingValue] {
        var next = [ChainingValue]()
        _ = reduceParentLevel(
            current,
            count: current.count,
            key: key,
            flags: flags,
            into: &next,
            maxWorkers: maxWorkers
        )
        return next
    }

    private static func reduceParentLevel(
        _ current: [ChainingValue],
        count: Int,
        key: ChainingValue,
        flags: UInt32,
        into next: inout [ChainingValue],
        maxWorkers: Int?,
        scheduler: ParallelScheduler? = nil
    ) -> Int {
        precondition(count >= 2)
        precondition(count <= current.count)

        let parentCount = count / 2
        let nextCount = parentCount + (count & 1)
        next.removeAll(keepingCapacity: true)
        next.reserveCapacity(nextCount)
        next.append(contentsOf: repeatElement(ChainingValue(repeating: 0), count: nextCount))

        if parentCount < 4_096 || maxWorkers == 1 {
            current.withUnsafeBufferPointer { currentBuffer in
                next.withUnsafeMutableBufferPointer { nextBuffer in
                    reduceParentRange(
                        start: 0,
                        end: parentCount,
                        current: SendableCVInput(baseAddress: currentBuffer.baseAddress!),
                        key: key,
                        flags: flags,
                        output: SendableCVStorage(baseAddress: nextBuffer.baseAddress!)
                    )
                }
            }
            if !count.isMultiple(of: 2) {
                next[nextCount - 1] = current[count - 1]
            }
            return nextCount
        }

        let workerCount = clampedWorkerCount(
            requested: maxWorkers ?? scheduler?.workerCount,
            workItems: parentCount
        )
        let parentsPerWorker = (parentCount + workerCount - 1) / workerCount
        current.withUnsafeBufferPointer { currentBuffer in
            next.withUnsafeMutableBufferPointer { nextBuffer in
                let currentInput = SendableCVInput(baseAddress: currentBuffer.baseAddress!)
                let nextStorage = SendableCVStorage(baseAddress: nextBuffer.baseAddress!)
                parallelPerform(iterations: workerCount, scheduler: scheduler) { workerIndex in
                    let start = workerIndex * parentsPerWorker
                    let end = min(parentCount, start + parentsPerWorker)
                    guard start < end else {
                        return
                    }
                    reduceParentRange(
                        start: start,
                        end: end,
                        current: currentInput,
                        key: key,
                        flags: flags,
                        output: nextStorage
                    )
                }
            }
        }

        if !count.isMultiple(of: 2) {
            next[nextCount - 1] = current[count - 1]
        }
        return nextCount
    }

    private static func parallelPerform(
        iterations: Int,
        scheduler: ParallelScheduler?,
        _ body: @escaping @Sendable (Int) -> Void
    ) {
        if let scheduler {
            scheduler.perform(iterations: iterations, body)
        } else {
            DispatchQueue.concurrentPerform(iterations: iterations, execute: body)
        }
    }

    private static func reduceParentRange(
        start: Int,
        end: Int,
        current: SendableCVInput,
        key: ChainingValue,
        flags: UInt32,
        output: SendableCVStorage
    ) {
        var parentIndex = start
        while parentIndex + 4 <= end {
            BLAKE3SIMD4.hashFourParents(
                input: current,
                firstParentIndex: parentIndex,
                key: key,
                flags: flags,
                output: output
            )
            parentIndex += 4
        }
        while parentIndex < end {
            output.store(
                parentCV(
                    left: current[parentIndex * 2],
                    right: current[parentIndex * 2 + 1],
                    key: key,
                    flags: flags
                ),
                at: parentIndex
            )
            parentIndex += 1
        }
    }

    private static func clampedWorkerCount(requested: Int?, workItems: Int) -> Int {
        let workers = normalizedParallelWorkerCount(requested)
        return max(1, min(workers, workItems))
    }

    static func normalizedParallelWorkerCount(_ requested: Int?) -> Int {
        max(1, requested ?? defaultParallelWorkerCount)
    }

    private static func detectedDefaultParallelWorkerCount() -> Int {
        #if canImport(Darwin)
        if let performanceCores = sysctlInteger(named: "hw.perflevel0.physicalcpu"), performanceCores > 0 {
            return performanceCores
        }
        if let performanceThreads = sysctlInteger(named: "hw.perflevel0.logicalcpu"), performanceThreads > 0 {
            return performanceThreads
        }
        #endif
        return max(1, ProcessInfo.processInfo.activeProcessorCount)
    }

    #if canImport(Darwin)
    private static func sysctlInteger(named name: String) -> Int? {
        var value: Int32 = 0
        var size = MemoryLayout<Int32>.size
        guard sysctlbyname(name, &value, &size, nil, 0) == 0 else {
            return nil
        }
        return Int(value)
    }
    #endif

    @inline(__always)
    private static func loadBlockWords(_ input: UnsafeRawBufferPointer, offset: Int) -> BlockWords {
        guard offset < input.count else {
            return BlockWords(repeating: 0)
        }
        if offset + blockLen <= input.count {
            return loadFullBlockWords(input, offset: offset)
        }
        return loadPartialBlockWords(
            baseAddress: input.baseAddress!.advanced(by: offset),
            byteCount: input.count - offset
        )
    }

    @inline(__always)
    private static func loadFullBlockWords(_ input: UnsafeRawBufferPointer, offset: Int) -> BlockWords {
        loadFullBlockWords(baseAddress: input.baseAddress!.advanced(by: offset))
    }

    @inline(__always)
    private static func loadFullBlockWords(baseAddress: UnsafeRawPointer) -> BlockWords {
        var words = baseAddress.loadUnaligned(as: BlockWords.self)
        canonicalLittleEndianWords(&words)
        return words
    }

    @inline(__always)
    private static func loadPartialBlockWords(baseAddress: UnsafeRawPointer, byteCount: Int) -> BlockWords {
        var words = BlockWords(repeating: 0)
        withUnsafeMutableBytes(of: &words) { destination in
            destination.copyMemory(
                from: UnsafeRawBufferPointer(start: baseAddress, count: byteCount)
            )
        }
        canonicalLittleEndianWords(&words)
        return words
    }

    @inline(__always)
    private static func canonicalLittleEndianWords(_ words: inout BlockWords) {
        #if _endian(big)
        for index in 0..<16 {
            words[index] = UInt32(littleEndian: words[index])
        }
        #endif
    }

    @inline(__always)
    private static func load32(_ input: UnsafeRawBufferPointer, at offset: Int) -> UInt32 {
        UInt32(littleEndian: input.baseAddress!.advanced(by: offset).loadUnaligned(as: UInt32.self))
    }

    private static func copyWordBytes(
        _ words: BlockWords,
        sourceByteOffset: Int,
        into output: UnsafeMutableRawPointer,
        byteCount: Int
    ) {
        var littleEndianWords = words
        #if _endian(big)
        for index in 0..<16 {
            littleEndianWords[index] = littleEndianWords[index].littleEndian
        }
        #endif
        withUnsafeBytes(of: &littleEndianWords) { source in
            output.copyMemory(
                from: source.baseAddress!.advanced(by: sourceByteOffset),
                byteCount: byteCount
            )
        }
    }

    @inline(__always)
    private static func compressInPlace(
        cv: inout ChainingValue,
        blockWords: BlockWords,
        blockLength: UInt32,
        counter: UInt64,
        flags: UInt32
    ) {
        cv = compressChainingValue(
            cv: cv,
            blockWords: blockWords,
            blockLength: blockLength,
            counter: counter,
            flags: flags
        )
    }

    @inline(__always)
    private static func compressChainingValue(
        cv: ChainingValue,
        blockWords: BlockWords,
        blockLength: UInt32,
        counter: UInt64,
        flags: UInt32
    ) -> ChainingValue {
        let state = compressedState(
            cv: cv,
            blockWords: blockWords,
            blockLength: blockLength,
            counter: counter,
            flags: flags
        )
        return ChainingValue(
            state[0] ^ state[8],
            state[1] ^ state[9],
            state[2] ^ state[10],
            state[3] ^ state[11],
            state[4] ^ state[12],
            state[5] ^ state[13],
            state[6] ^ state[14],
            state[7] ^ state[15]
        )
    }

    @inline(__always)
    private static func blake3CompressWithPerm(
        cv: ChainingValue,
        blockBaseAddress: UnsafeRawPointer,
        blockLength: UInt32,
        counter: UInt64,
        flags: UInt32,
        schedule: SendableMessageSchedule
    ) -> ChainingValue {
        // Pointer-indexed scheduling benchmarks slower in Swift; keep the hoisted handle without giving up unrolled rounds.
        _ = schedule
        let state = compressedState(
            cv: cv,
            blockWords: loadFullBlockWords(baseAddress: blockBaseAddress),
            blockLength: blockLength,
            counter: counter,
            flags: flags
        )
        return ChainingValue(
            state[0] ^ state[8],
            state[1] ^ state[9],
            state[2] ^ state[10],
            state[3] ^ state[11],
            state[4] ^ state[12],
            state[5] ^ state[13],
            state[6] ^ state[14],
            state[7] ^ state[15]
        )
    }

    private static func compressXOF(
        cv: ChainingValue,
        blockWords: BlockWords,
        blockLength: UInt32,
        counter: UInt64,
        flags: UInt32
    ) -> BlockWords {
        let state = compressedState(
            cv: cv,
            blockWords: blockWords,
            blockLength: blockLength,
            counter: counter,
            flags: flags
        )
        return BlockWords(
            state[0] ^ state[8],
            state[1] ^ state[9],
            state[2] ^ state[10],
            state[3] ^ state[11],
            state[4] ^ state[12],
            state[5] ^ state[13],
            state[6] ^ state[14],
            state[7] ^ state[15],
            state[8] ^ cv[0],
            state[9] ^ cv[1],
            state[10] ^ cv[2],
            state[11] ^ cv[3],
            state[12] ^ cv[4],
            state[13] ^ cv[5],
            state[14] ^ cv[6],
            state[15] ^ cv[7]
        )
    }

    @inline(__always)
    private static func compressedState(
        cv: ChainingValue,
        blockWords: BlockWords,
        blockLength: UInt32,
        counter: UInt64,
        flags: UInt32
    ) -> BlockWords {
        let m0 = blockWords[0]
        let m1 = blockWords[1]
        let m2 = blockWords[2]
        let m3 = blockWords[3]
        let m4 = blockWords[4]
        let m5 = blockWords[5]
        let m6 = blockWords[6]
        let m7 = blockWords[7]
        let m8 = blockWords[8]
        let m9 = blockWords[9]
        let m10 = blockWords[10]
        let m11 = blockWords[11]
        let m12 = blockWords[12]
        let m13 = blockWords[13]
        let m14 = blockWords[14]
        let m15 = blockWords[15]

        var s0 = cv[0]
        var s1 = cv[1]
        var s2 = cv[2]
        var s3 = cv[3]
        var s4 = cv[4]
        var s5 = cv[5]
        var s6 = cv[6]
        var s7 = cv[7]
        var s8 = iv[0]
        var s9 = iv[1]
        var s10 = iv[2]
        var s11 = iv[3]
        var s12 = UInt32(truncatingIfNeeded: counter)
        var s13 = UInt32(truncatingIfNeeded: counter >> 32)
        var s14 = blockLength
        var s15 = flags

        roundWords(
            &s0, &s1, &s2, &s3, &s4, &s5, &s6, &s7,
            &s8, &s9, &s10, &s11, &s12, &s13, &s14, &s15,
            m0, m1, m2, m3, m4, m5, m6, m7,
            m8, m9, m10, m11, m12, m13, m14, m15
        )
        roundWords(
            &s0, &s1, &s2, &s3, &s4, &s5, &s6, &s7,
            &s8, &s9, &s10, &s11, &s12, &s13, &s14, &s15,
            m2, m6, m3, m10, m7, m0, m4, m13,
            m1, m11, m12, m5, m9, m14, m15, m8
        )
        roundWords(
            &s0, &s1, &s2, &s3, &s4, &s5, &s6, &s7,
            &s8, &s9, &s10, &s11, &s12, &s13, &s14, &s15,
            m3, m4, m10, m12, m13, m2, m7, m14,
            m6, m5, m9, m0, m11, m15, m8, m1
        )
        roundWords(
            &s0, &s1, &s2, &s3, &s4, &s5, &s6, &s7,
            &s8, &s9, &s10, &s11, &s12, &s13, &s14, &s15,
            m10, m7, m12, m9, m14, m3, m13, m15,
            m4, m0, m11, m2, m5, m8, m1, m6
        )
        roundWords(
            &s0, &s1, &s2, &s3, &s4, &s5, &s6, &s7,
            &s8, &s9, &s10, &s11, &s12, &s13, &s14, &s15,
            m12, m13, m9, m11, m15, m10, m14, m8,
            m7, m2, m5, m3, m0, m1, m6, m4
        )
        roundWords(
            &s0, &s1, &s2, &s3, &s4, &s5, &s6, &s7,
            &s8, &s9, &s10, &s11, &s12, &s13, &s14, &s15,
            m9, m14, m11, m5, m8, m12, m15, m1,
            m13, m3, m0, m10, m2, m6, m4, m7
        )
        roundWords(
            &s0, &s1, &s2, &s3, &s4, &s5, &s6, &s7,
            &s8, &s9, &s10, &s11, &s12, &s13, &s14, &s15,
            m11, m15, m5, m0, m1, m9, m8, m6,
            m14, m10, m2, m12, m3, m4, m7, m13
        )

        return BlockWords(
            s0, s1, s2, s3,
            s4, s5, s6, s7,
            s8, s9, s10, s11,
            s12, s13, s14, s15
        )
    }

    @inline(__always)
    private static func roundWords(
        _ s0: inout UInt32,
        _ s1: inout UInt32,
        _ s2: inout UInt32,
        _ s3: inout UInt32,
        _ s4: inout UInt32,
        _ s5: inout UInt32,
        _ s6: inout UInt32,
        _ s7: inout UInt32,
        _ s8: inout UInt32,
        _ s9: inout UInt32,
        _ s10: inout UInt32,
        _ s11: inout UInt32,
        _ s12: inout UInt32,
        _ s13: inout UInt32,
        _ s14: inout UInt32,
        _ s15: inout UInt32,
        _ m0: UInt32,
        _ m1: UInt32,
        _ m2: UInt32,
        _ m3: UInt32,
        _ m4: UInt32,
        _ m5: UInt32,
        _ m6: UInt32,
        _ m7: UInt32,
        _ m8: UInt32,
        _ m9: UInt32,
        _ m10: UInt32,
        _ m11: UInt32,
        _ m12: UInt32,
        _ m13: UInt32,
        _ m14: UInt32,
        _ m15: UInt32
    ) {
        gWords(&s0, &s4, &s8, &s12, m0, m1)
        gWords(&s1, &s5, &s9, &s13, m2, m3)
        gWords(&s2, &s6, &s10, &s14, m4, m5)
        gWords(&s3, &s7, &s11, &s15, m6, m7)
        gWords(&s0, &s5, &s10, &s15, m8, m9)
        gWords(&s1, &s6, &s11, &s12, m10, m11)
        gWords(&s2, &s7, &s8, &s13, m12, m13)
        gWords(&s3, &s4, &s9, &s14, m14, m15)
    }

    @inline(__always)
    private static func gWords(
        _ a: inout UInt32,
        _ b: inout UInt32,
        _ c: inout UInt32,
        _ d: inout UInt32,
        _ x: UInt32,
        _ y: UInt32
    ) {
        a = a &+ b &+ x
        d = rotateRight(d ^ a, by: 16)
        c = c &+ d
        b = rotateRight(b ^ c, by: 12)
        a = a &+ b &+ y
        d = rotateRight(d ^ a, by: 8)
        c = c &+ d
        b = rotateRight(b ^ c, by: 7)
    }

    @inline(__always)
    private static func rotateRight(_ word: UInt32, by count: UInt32) -> UInt32 {
        (word >> count) | (word << (32 - count))
    }
}
