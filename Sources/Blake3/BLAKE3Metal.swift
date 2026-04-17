#if canImport(Metal)
import Foundation
import Metal

public enum BLAKE3Metal {
    public enum ExecutionPolicy: Equatable, Sendable {
        case automatic
        case cpu
        case gpu
    }

    public static let defaultMinimumGPUByteCount = 16 * 1024 * 1024
    public static let defaultAsyncInflightCommandCount = 3
    private static let wideParentReductionThreshold = 512 * 1024
    private static let quadParentReductionThreshold = 32 * 1024
    private static let largeGridThreadThreshold = 1024 * 1024
    private static let smallGridSIMDGroupsPerThreadgroup = 8
    private static let largeGridSIMDGroupsPerThreadgroup = 4

    private static let defaultDevice = MTLCreateSystemDefaultDevice()
    private static let contextCache = BLAKE3MetalContextCache()

    public static var isAvailable: Bool {
        defaultDevice != nil
    }

    public static var deviceName: String? {
        defaultDevice?.name
    }

    public static func makeContext(
        device: MTLDevice? = MTLCreateSystemDefaultDevice(),
        minimumGPUByteCount: Int = defaultMinimumGPUByteCount
    ) throws -> Context {
        guard let device else {
            throw BLAKE3Error.metalUnavailable
        }
        return try Context(device: device, minimumGPUByteCount: minimumGPUByteCount)
    }

    public static func hash(
        buffer: MTLBuffer,
        length: Int,
        policy: ExecutionPolicy = .automatic
    ) throws -> BLAKE3.Digest {
        try hash(buffer: buffer, range: 0..<length, policy: policy)
    }

    public static func hash(
        buffer: MTLBuffer,
        range: Range<Int>,
        policy: ExecutionPolicy = .automatic
    ) throws -> BLAKE3.Digest {
        try contextCache.context(device: buffer.device).hash(
            buffer: buffer,
            range: range,
            policy: policy
        )
    }

    public static func hashAsync(
        buffer: MTLBuffer,
        length: Int,
        policy: ExecutionPolicy = .automatic
    ) async throws -> BLAKE3.Digest {
        try await hashAsync(buffer: buffer, range: 0..<length, policy: policy)
    }

    public static func hashAsync(
        buffer: MTLBuffer,
        range: Range<Int>,
        policy: ExecutionPolicy = .automatic
    ) async throws -> BLAKE3.Digest {
        try await contextCache.context(device: buffer.device).hashAsync(
            buffer: buffer,
            range: range,
            policy: policy
        )
    }

    public final class Context: @unchecked Sendable {
        public let device: MTLDevice
        public let minimumGPUByteCount: Int

        private let pipelines: BLAKE3MetalPipelines
        private let commandQueue: MTLCommandQueue
        private let defaultAsyncWorkspace: AsyncWorkspace
        private let lock = NSLock()

        private var chunkCVBuffer: MTLBuffer?
        private var parentCVBuffer: MTLBuffer?
        private var digestBuffer: MTLBuffer?
        private var parameterBuffer: MTLBuffer?
        private var chunkCVCapacity = 0
        private var parentCVCapacity = 0
        private var parameterSlotCapacity = 0

        public init(
            device: MTLDevice,
            minimumGPUByteCount: Int = BLAKE3Metal.defaultMinimumGPUByteCount
        ) throws {
            self.device = device
            self.minimumGPUByteCount = max(0, minimumGPUByteCount)
            self.pipelines = try BLAKE3MetalPipelineCache.shared.pipelines(device: device)
            guard let commandQueue = device.makeCommandQueue() else {
                throw BLAKE3Error.metalCommandFailed("Unable to create command queue.")
            }
            self.commandQueue = commandQueue
            self.defaultAsyncWorkspace = try AsyncWorkspace(
                device: device,
                maxPooledResources: BLAKE3Metal.defaultAsyncInflightCommandCount
            )
        }

        public func makeStagingBuffer(capacity: Int) throws -> StagingBuffer {
            guard capacity >= 0 else {
                throw BLAKE3Error.metalCommandFailed("Staging buffer capacity must be non-negative.")
            }
            guard let buffer = device.makeBuffer(
                length: max(1, capacity),
                options: .storageModeShared
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate staging input buffer.")
            }
            return StagingBuffer(buffer: buffer, capacity: capacity)
        }

        public func makeAsyncWorkspace(
            maxPooledResources: Int = BLAKE3Metal.defaultAsyncInflightCommandCount,
            preallocateForByteCount: Int? = nil
        ) throws -> AsyncWorkspace {
            try AsyncWorkspace(
                device: device,
                maxPooledResources: maxPooledResources,
                preallocateForByteCount: preallocateForByteCount
            )
        }

        public func makeChunkChainingValueBuffer(chunkCapacity: Int) throws -> ChunkChainingValueBuffer {
            guard chunkCapacity >= 0 else {
                throw BLAKE3Error.metalCommandFailed("Chunk chaining value capacity must be non-negative.")
            }
            guard let buffer = device.makeBuffer(
                length: max(1, chunkCapacity * BLAKE3.digestByteCount),
                options: .storageModeShared
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate chunk chaining value buffer.")
            }
            return ChunkChainingValueBuffer(buffer: buffer, chunkCapacity: chunkCapacity)
        }

        public func makeAsyncPipeline(
            inputCapacity: Int,
            inFlightCount: Int = BLAKE3Metal.defaultAsyncInflightCommandCount,
            policy: ExecutionPolicy = .automatic,
            usesPrivateBuffers: Bool = false
        ) throws -> AsyncPipeline {
            guard inputCapacity >= 0 else {
                throw BLAKE3Error.metalCommandFailed("Async pipeline input capacity must be non-negative.")
            }
            guard inFlightCount > 0 else {
                throw BLAKE3Error.metalCommandFailed("Async pipeline in-flight count must be positive.")
            }

            let asyncWorkspace = try makeAsyncWorkspace(
                maxPooledResources: inFlightCount,
                preallocateForByteCount: inputCapacity
            )
            let stagingBuffers = try (0..<inFlightCount).map { _ in
                try makeStagingBuffer(capacity: inputCapacity)
            }
            let privateBuffers: [PrivateBuffer]? = usesPrivateBuffers
                ? try (0..<inFlightCount).map { _ in try makePrivateBuffer(capacity: inputCapacity) }
                : nil

            return AsyncPipeline(
                context: self,
                inputCapacity: inputCapacity,
                inFlightCount: inFlightCount,
                policy: policy,
                usesPrivateBuffers: usesPrivateBuffers,
                workspace: asyncWorkspace,
                stagingBuffers: stagingBuffers,
                privateBuffers: privateBuffers
            )
        }

        public func makePrivateBuffer(capacity: Int) throws -> PrivateBuffer {
            guard capacity >= 0 else {
                throw BLAKE3Error.metalCommandFailed("Private buffer capacity must be non-negative.")
            }
            guard let buffer = device.makeBuffer(
                length: max(1, capacity),
                options: .storageModePrivate
            ) else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate private input buffer.")
            }
            return PrivateBuffer(buffer: buffer, capacity: capacity, length: 0)
        }

        public func makePrivateBuffer(input: some ContiguousBytes) throws -> PrivateBuffer {
            try input.withUnsafeBytes { raw in
                let privateBuffer = try makePrivateBuffer(capacity: raw.count)
                try replaceContents(of: privateBuffer, with: raw)
                return privateBuffer
            }
        }

        public func makePrivateBuffer(
            input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer
        ) throws -> PrivateBuffer {
            try input.withUnsafeBytes { raw in
                let privateBuffer = try makePrivateBuffer(capacity: raw.count)
                try replaceContents(of: privateBuffer, with: raw, using: stagingBuffer)
                return privateBuffer
            }
        }

        public func replaceContents(
            of privateBuffer: PrivateBuffer,
            with input: some ContiguousBytes
        ) throws {
            try input.withUnsafeBytes { raw in
                try replaceContents(of: privateBuffer, with: raw)
            }
        }

        public func replaceContents(
            of privateBuffer: PrivateBuffer,
            with input: UnsafeRawBufferPointer
        ) throws {
            guard privateBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Private buffer belongs to a different Metal device.")
            }
            guard input.count <= privateBuffer.capacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Input length \(input.count) exceeds private buffer capacity \(privateBuffer.capacity)."
                )
            }

            privateBuffer.lock.lock()
            defer {
                privateBuffer.lock.unlock()
            }

            guard input.count > 0 else {
                privateBuffer.length = 0
                return
            }
            guard let baseAddress = input.baseAddress,
                  let source = device.makeBuffer(bytes: baseAddress, length: input.count, options: .storageModeShared),
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let blitEncoder = commandBuffer.makeBlitCommandEncoder()
            else {
                throw BLAKE3Error.metalCommandFailed("Unable to stage private buffer upload.")
            }

            blitEncoder.copy(
                from: source,
                sourceOffset: 0,
                to: privateBuffer.buffer,
                destinationOffset: 0,
                size: input.count
            )
            blitEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }
            privateBuffer.length = input.count
        }

        public func replaceContents(
            of privateBuffer: PrivateBuffer,
            with input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer
        ) throws {
            try input.withUnsafeBytes { raw in
                try replaceContents(of: privateBuffer, with: raw, using: stagingBuffer)
            }
        }

        public func replaceContents(
            of privateBuffer: PrivateBuffer,
            with input: UnsafeRawBufferPointer,
            using stagingBuffer: StagingBuffer
        ) throws {
            guard privateBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Private buffer belongs to a different Metal device.")
            }
            guard stagingBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Staging buffer belongs to a different Metal device.")
            }
            guard input.count <= privateBuffer.capacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Input length \(input.count) exceeds private buffer capacity \(privateBuffer.capacity)."
                )
            }
            guard input.count <= stagingBuffer.capacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Input length \(input.count) exceeds staging buffer capacity \(stagingBuffer.capacity)."
                )
            }

            stagingBuffer.lock.lock()
            privateBuffer.lock.lock()
            defer {
                privateBuffer.lock.unlock()
                stagingBuffer.lock.unlock()
            }

            guard input.count > 0 else {
                privateBuffer.length = 0
                return
            }
            guard let baseAddress = input.baseAddress,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let blitEncoder = commandBuffer.makeBlitCommandEncoder()
            else {
                throw BLAKE3Error.metalCommandFailed("Unable to stage private buffer upload.")
            }

            stagingBuffer.buffer.contents().copyMemory(from: baseAddress, byteCount: input.count)
            blitEncoder.copy(
                from: stagingBuffer.buffer,
                sourceOffset: 0,
                to: privateBuffer.buffer,
                destinationOffset: 0,
                size: input.count
            )
            blitEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }
            privateBuffer.length = input.count
        }

        public func replaceContentsAsync(
            of privateBuffer: PrivateBuffer,
            with input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer
        ) async throws {
            try Task.checkCancellation()

            stagingBuffer.lockForAsyncUse()
            privateBuffer.lockForAsyncUse()

            var inputLength = 0
            var commandBuffer: MTLCommandBuffer?

            do {
                guard privateBuffer.buffer.device.registryID == device.registryID else {
                    throw BLAKE3Error.metalCommandFailed("Private buffer belongs to a different Metal device.")
                }
                guard stagingBuffer.buffer.device.registryID == device.registryID else {
                    throw BLAKE3Error.metalCommandFailed("Staging buffer belongs to a different Metal device.")
                }

                try input.withUnsafeBytes { raw in
                    inputLength = raw.count
                    guard raw.count <= privateBuffer.capacity else {
                        throw BLAKE3Error.metalCommandFailed(
                            "Input length \(raw.count) exceeds private buffer capacity \(privateBuffer.capacity)."
                        )
                    }
                    guard raw.count <= stagingBuffer.capacity else {
                        throw BLAKE3Error.metalCommandFailed(
                            "Input length \(raw.count) exceeds staging buffer capacity \(stagingBuffer.capacity)."
                        )
                    }
                    guard raw.count > 0 else {
                        return
                    }
                    guard let baseAddress = raw.baseAddress else {
                        throw BLAKE3Error.metalCommandFailed("Input bytes are unavailable.")
                    }
                    stagingBuffer.buffer.contents().copyMemory(from: baseAddress, byteCount: raw.count)
                }

                guard inputLength > 0 else {
                    privateBuffer.length = 0
                    privateBuffer.unlockForAsyncUse()
                    stagingBuffer.unlockForAsyncUse()
                    return
                }

                guard let pendingCommandBuffer = commandQueue.makeCommandBuffer(),
                      let blitEncoder = pendingCommandBuffer.makeBlitCommandEncoder()
                else {
                    throw BLAKE3Error.metalCommandFailed("Unable to stage private buffer upload.")
                }
                blitEncoder.copy(
                    from: stagingBuffer.buffer,
                    sourceOffset: 0,
                    to: privateBuffer.buffer,
                    destinationOffset: 0,
                    size: inputLength
                )
                blitEncoder.endEncoding()
                commandBuffer = pendingCommandBuffer
            } catch {
                privateBuffer.unlockForAsyncUse()
                stagingBuffer.unlockForAsyncUse()
                throw error
            }

            guard let commandBuffer else {
                privateBuffer.unlockForAsyncUse()
                stagingBuffer.unlockForAsyncUse()
                throw BLAKE3Error.metalCommandFailed("Unable to stage private buffer upload.")
            }

            let committedInputLength = inputLength
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                commandBuffer.addCompletedHandler { completedBuffer in
                    defer {
                        privateBuffer.unlockForAsyncUse()
                        stagingBuffer.unlockForAsyncUse()
                    }
                    if let error = completedBuffer.error {
                        continuation.resume(throwing: BLAKE3Error.metalCommandFailed(error.localizedDescription))
                        return
                    }
                    privateBuffer.length = committedInputLength
                    continuation.resume()
                }
                commandBuffer.commit()
            }
            try Task.checkCancellation()
        }

        public func hash(
            buffer: MTLBuffer,
            length: Int,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try hash(buffer: buffer, range: 0..<length, policy: policy)
        }

        public func hash(
            buffer: MTLBuffer,
            range: Range<Int>,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            return try BLAKE3Metal.hash(
                buffer: buffer,
                range: range,
                policy: policy,
                minimumGPUByteCount: minimumGPUByteCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                workspace: self
            )
        }

        @discardableResult
        public func writeChunkChainingValues(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            into outputBuffer: ChunkChainingValueBuffer
        ) throws -> Int {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            guard outputBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Chunk chaining value buffer belongs to a different Metal device.")
            }
            guard range.lowerBound >= 0,
                  range.upperBound <= buffer.length,
                  range.lowerBound <= range.upperBound
            else {
                throw BLAKE3Error.invalidBufferRange
            }
            guard range.count.isMultiple(of: BLAKE3.chunkByteCount) else {
                throw BLAKE3Error.metalCommandFailed("Chunk chaining value ranges must contain only complete BLAKE3 chunks.")
            }

            let chunkCount = range.count / BLAKE3.chunkByteCount
            guard chunkCount <= outputBuffer.chunkCapacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Chunk chaining value output capacity \(outputBuffer.chunkCapacity) is smaller than required chunk count \(chunkCount)."
                )
            }
            guard chunkCount > 0 else {
                outputBuffer.setWrittenChunkCount(0)
                return 0
            }

            outputBuffer.lock.lock()
            defer {
                outputBuffer.lock.unlock()
            }

            return try withWorkspace(chunkCount: chunkCount) { _, _, _, parameterBuffer in
                let commandBuffer = try BLAKE3Metal.makeChunkChainingValuesCommandBuffer(
                    buffer: buffer,
                    range: range,
                    chunkCount: chunkCount,
                    baseChunkCounter: baseChunkCounter,
                    pipelines: pipelines,
                    commandQueue: commandQueue,
                    retainsReferences: false,
                    outputBuffer: outputBuffer.buffer,
                    parameterBuffer: parameterBuffer
                )
                commandBuffer.commit()
                commandBuffer.waitUntilCompleted()

                if let error = commandBuffer.error {
                    throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
                }

                outputBuffer.writtenChunkCount = chunkCount
                return chunkCount
            }
        }

        @discardableResult
        public func writeChunkChainingValuesAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            into outputBuffer: ChunkChainingValueBuffer
        ) async throws -> Int {
            try await writeChunkChainingValuesAsync(
                buffer: buffer,
                range: range,
                baseChunkCounter: baseChunkCounter,
                into: outputBuffer,
                workspace: defaultAsyncWorkspace
            )
        }

        @discardableResult
        public func writeChunkChainingValuesAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            baseChunkCounter: UInt64,
            into outputBuffer: ChunkChainingValueBuffer,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> Int {
            try Task.checkCancellation()
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            guard outputBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Chunk chaining value buffer belongs to a different Metal device.")
            }
            guard asyncWorkspace.deviceRegistryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Async workspace belongs to a different Metal device.")
            }
            guard range.lowerBound >= 0,
                  range.upperBound <= buffer.length,
                  range.lowerBound <= range.upperBound
            else {
                throw BLAKE3Error.invalidBufferRange
            }
            guard range.count.isMultiple(of: BLAKE3.chunkByteCount) else {
                throw BLAKE3Error.metalCommandFailed("Chunk chaining value ranges must contain only complete BLAKE3 chunks.")
            }

            let chunkCount = range.count / BLAKE3.chunkByteCount
            guard chunkCount <= outputBuffer.chunkCapacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Chunk chaining value output capacity \(outputBuffer.chunkCapacity) is smaller than required chunk count \(chunkCount)."
                )
            }
            guard chunkCount > 0 else {
                outputBuffer.setWrittenChunkCount(0)
                return 0
            }

            let lease = try asyncWorkspace.lease(chunkCount: chunkCount)
            let buffers: AsyncHashBuffers
            do {
                buffers = try lease.resources.buffers()
            } catch {
                asyncWorkspace.release(lease)
                throw error
            }

            outputBuffer.lockForAsyncUse()
            let commandBuffer: MTLCommandBuffer
            do {
                commandBuffer = try BLAKE3Metal.makeChunkChainingValuesCommandBuffer(
                    buffer: buffer,
                    range: range,
                    chunkCount: chunkCount,
                    baseChunkCounter: baseChunkCounter,
                    pipelines: pipelines,
                    commandQueue: commandQueue,
                    retainsReferences: true,
                    outputBuffer: outputBuffer.buffer,
                    parameterBuffer: buffers.parameterBuffer
                )
            } catch {
                outputBuffer.unlockForAsyncUse()
                asyncWorkspace.release(lease)
                throw error
            }

            let completedChunkCount = chunkCount
            let writtenCount = try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<Int, Error>) in
                commandBuffer.addCompletedHandler { completedBuffer in
                    defer {
                        outputBuffer.unlockForAsyncUse()
                        asyncWorkspace.release(lease)
                    }
                    if let error = completedBuffer.error {
                        continuation.resume(throwing: BLAKE3Error.metalCommandFailed(error.localizedDescription))
                        return
                    }
                    outputBuffer.writtenChunkCount = completedChunkCount
                    continuation.resume(returning: completedChunkCount)
                }
                commandBuffer.commit()
            }
            try Task.checkCancellation()
            return writtenCount
        }

        public func hashAsync(
            buffer: MTLBuffer,
            length: Int,
            policy: ExecutionPolicy = .automatic
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(buffer: buffer, range: 0..<length, policy: policy, workspace: defaultAsyncWorkspace)
        }

        public func hashAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            policy: ExecutionPolicy = .automatic
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(buffer: buffer, range: range, policy: policy, workspace: defaultAsyncWorkspace)
        }

        public func hashAsync(
            buffer: MTLBuffer,
            length: Int,
            policy: ExecutionPolicy = .automatic,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(buffer: buffer, range: 0..<length, policy: policy, workspace: asyncWorkspace)
        }

        public func hashAsync(
            buffer: MTLBuffer,
            range: Range<Int>,
            policy: ExecutionPolicy = .automatic,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            guard buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Buffer belongs to a different Metal device.")
            }
            guard asyncWorkspace.deviceRegistryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Async workspace belongs to a different Metal device.")
            }
            return try await BLAKE3Metal.hashAsync(
                buffer: buffer,
                range: range,
                policy: policy,
                minimumGPUByteCount: minimumGPUByteCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                asyncWorkspace: asyncWorkspace
            )
        }

        public func hash(
            privateBuffer: PrivateBuffer,
            policy: ExecutionPolicy = .gpu
        ) throws -> BLAKE3.Digest {
            privateBuffer.lock.lock()
            defer {
                privateBuffer.lock.unlock()
            }
            return try hashLocked(privateBuffer: privateBuffer, length: privateBuffer.length, policy: policy)
        }

        public func hash(
            privateBuffer: PrivateBuffer,
            length: Int,
            policy: ExecutionPolicy = .gpu
        ) throws -> BLAKE3.Digest {
            privateBuffer.lock.lock()
            defer {
                privateBuffer.lock.unlock()
            }
            return try hashLocked(privateBuffer: privateBuffer, length: length, policy: policy)
        }

        private func hashLocked(
            privateBuffer: PrivateBuffer,
            length: Int,
            policy: ExecutionPolicy
        ) throws -> BLAKE3.Digest {
            guard length >= 0, length <= privateBuffer.length else {
                throw BLAKE3Error.invalidBufferRange
            }
            guard length > 0 else {
                return BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
            }
            return try hash(buffer: privateBuffer.buffer, length: length, policy: policy)
        }

        public func hashAsync(
            privateBuffer: PrivateBuffer,
            policy: ExecutionPolicy = .gpu
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(
                privateBuffer: privateBuffer,
                policy: policy,
                workspace: defaultAsyncWorkspace
            )
        }

        public func hashAsync(
            privateBuffer: PrivateBuffer,
            length: Int,
            policy: ExecutionPolicy = .gpu
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(
                privateBuffer: privateBuffer,
                length: length,
                policy: policy,
                workspace: defaultAsyncWorkspace
            )
        }

        public func hashAsync(
            privateBuffer: PrivateBuffer,
            policy: ExecutionPolicy = .gpu,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            privateBuffer.lockForAsyncUse()
            defer {
                privateBuffer.unlockForAsyncUse()
            }
            return try await hashLockedAsync(
                privateBuffer: privateBuffer,
                length: privateBuffer.length,
                policy: policy,
                workspace: asyncWorkspace
            )
        }

        public func hashAsync(
            privateBuffer: PrivateBuffer,
            length: Int,
            policy: ExecutionPolicy = .gpu,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            privateBuffer.lockForAsyncUse()
            defer {
                privateBuffer.unlockForAsyncUse()
            }
            return try await hashLockedAsync(
                privateBuffer: privateBuffer,
                length: length,
                policy: policy,
                workspace: asyncWorkspace
            )
        }

        private func hashLockedAsync(
            privateBuffer: PrivateBuffer,
            length: Int,
            policy: ExecutionPolicy,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            guard asyncWorkspace.deviceRegistryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Async workspace belongs to a different Metal device.")
            }
            guard length >= 0, length <= privateBuffer.length else {
                throw BLAKE3Error.invalidBufferRange
            }
            guard length > 0 else {
                return BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
            }
            return try await hashAsync(buffer: privateBuffer.buffer, length: length, policy: policy, workspace: asyncWorkspace)
        }

        public func hash(
            input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            try input.withUnsafeBytes { raw in
                try hash(input: raw, using: stagingBuffer, policy: policy)
            }
        }

        public func hash(
            input: UnsafeRawBufferPointer,
            using stagingBuffer: StagingBuffer,
            policy: ExecutionPolicy = .automatic
        ) throws -> BLAKE3.Digest {
            guard stagingBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Staging buffer belongs to a different Metal device.")
            }
            guard input.count <= stagingBuffer.capacity else {
                throw BLAKE3Error.metalCommandFailed(
                    "Input length \(input.count) exceeds staging buffer capacity \(stagingBuffer.capacity)."
                )
            }
            stagingBuffer.lock.lock()
            defer {
                stagingBuffer.lock.unlock()
            }
            if input.count > 0 {
                guard let baseAddress = input.baseAddress else {
                    throw BLAKE3Error.metalCommandFailed("Input bytes are unavailable.")
                }
                stagingBuffer.buffer.contents().copyMemory(
                    from: baseAddress,
                    byteCount: input.count
                )
            }
            return try hash(buffer: stagingBuffer.buffer, length: input.count, policy: policy)
        }

        public func hashAsync(
            input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer,
            policy: ExecutionPolicy = .automatic
        ) async throws -> BLAKE3.Digest {
            try await hashAsync(
                input: input,
                using: stagingBuffer,
                policy: policy,
                workspace: defaultAsyncWorkspace
            )
        }

        public func hashAsync(
            input: some ContiguousBytes,
            using stagingBuffer: StagingBuffer,
            policy: ExecutionPolicy = .automatic,
            workspace asyncWorkspace: AsyncWorkspace
        ) async throws -> BLAKE3.Digest {
            stagingBuffer.lockForAsyncUse()
            defer {
                stagingBuffer.unlockForAsyncUse()
            }
            guard stagingBuffer.buffer.device.registryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Staging buffer belongs to a different Metal device.")
            }
            guard asyncWorkspace.deviceRegistryID == device.registryID else {
                throw BLAKE3Error.metalCommandFailed("Async workspace belongs to a different Metal device.")
            }
            var inputLength = 0
            try input.withUnsafeBytes { raw in
                inputLength = raw.count
                guard raw.count <= stagingBuffer.capacity else {
                    throw BLAKE3Error.metalCommandFailed(
                        "Input length \(raw.count) exceeds staging buffer capacity \(stagingBuffer.capacity)."
                    )
                }
                if raw.count > 0 {
                    guard let baseAddress = raw.baseAddress else {
                        throw BLAKE3Error.metalCommandFailed("Input bytes are unavailable.")
                    }
                    stagingBuffer.buffer.contents().copyMemory(
                        from: baseAddress,
                        byteCount: raw.count
                    )
                }
            }
            return try await hashAsync(
                buffer: stagingBuffer.buffer,
                length: inputLength,
                policy: policy,
                workspace: asyncWorkspace
            )
        }

        fileprivate func withWorkspace<R>(
            chunkCount: Int,
            _ body: (MTLBuffer, MTLBuffer, MTLBuffer, MTLBuffer) throws -> R
        ) throws -> R {
            lock.lock()
            defer {
                lock.unlock()
            }

            try ensureBuffers(chunkCount: chunkCount)
            guard let chunkCVBuffer,
                  let parentCVBuffer,
                  let digestBuffer,
                  let parameterBuffer
            else {
                throw BLAKE3Error.metalCommandFailed("Metal workspace buffers are unavailable.")
            }
            return try body(chunkCVBuffer, parentCVBuffer, digestBuffer, parameterBuffer)
        }

        private func ensureBuffers(chunkCount: Int) throws {
            let chunkCVByteCount = chunkCount * BLAKE3.digestByteCount
            let parentCVByteCount = ((chunkCount + 1) / 2) * BLAKE3.digestByteCount

            if chunkCVCapacity < chunkCVByteCount {
                let capacity = Self.roundedCapacity(for: chunkCVByteCount)
                guard let buffer = device.makeBuffer(
                    length: capacity,
                    options: .storageModePrivate
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate chunk chaining value buffer.")
                }
                chunkCVBuffer = buffer
                chunkCVCapacity = capacity
            }
            if parentCVCapacity < parentCVByteCount {
                let capacity = Self.roundedCapacity(for: parentCVByteCount)
                guard let buffer = device.makeBuffer(
                    length: capacity,
                    options: .storageModePrivate
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate parent chaining value buffer.")
                }
                parentCVBuffer = buffer
                parentCVCapacity = capacity
            }
            if digestBuffer == nil {
                guard let buffer = device.makeBuffer(
                    length: BLAKE3.digestByteCount,
                    options: .storageModeShared
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate digest buffer.")
                }
                digestBuffer = buffer
            }
            let parameterSlotCount = 1 + Self.parentReductionStepCount(for: chunkCount)
            if parameterSlotCapacity < parameterSlotCount {
                guard let buffer = device.makeBuffer(
                    length: parameterSlotCount * Self.parameterSlotStride,
                    options: .storageModeShared
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate reusable Metal parameter buffer.")
                }
                parameterBuffer = buffer
                parameterSlotCapacity = parameterSlotCount
            }

            guard chunkCVBuffer != nil,
                  parentCVBuffer != nil,
                  digestBuffer != nil,
                  parameterBuffer != nil
            else {
                throw BLAKE3Error.metalCommandFailed("Unable to allocate reusable Metal workspace buffers.")
            }
        }

        fileprivate static func roundedCapacity(for byteCount: Int) -> Int {
            var capacity = 4 * 1024
            while capacity < byteCount {
                capacity <<= 1
            }
            return capacity
        }

        fileprivate static let parameterSlotStride = 256

        fileprivate static func parentReductionStepCount(for chunkCount: Int) -> Int {
            var count = chunkCount
            var steps = 0
            while count > 4 {
                if count >= BLAKE3Metal.wideParentReductionThreshold {
                    count = (count + 15) / 16
                } else if count >= BLAKE3Metal.quadParentReductionThreshold {
                    count = (count + 3) / 4
                } else {
                    count = (count + 1) / 2
                }
                steps += 1
            }
            return steps
        }
    }

    public final class AsyncWorkspace: @unchecked Sendable {
        public let maxPooledResources: Int
        public let preallocatedByteCount: Int?

        fileprivate let deviceRegistryID: UInt64
        private let pool: AsyncHashResourcePool

        fileprivate init(
            device: MTLDevice,
            maxPooledResources: Int,
            preallocateForByteCount: Int? = nil
        ) throws {
            guard maxPooledResources > 0 else {
                throw BLAKE3Error.metalCommandFailed("Async workspace pool size must be positive.")
            }
            if let preallocateForByteCount, preallocateForByteCount < 0 {
                throw BLAKE3Error.metalCommandFailed("Async workspace preallocation size must be non-negative.")
            }

            self.maxPooledResources = maxPooledResources
            self.preallocatedByteCount = preallocateForByteCount
            self.deviceRegistryID = device.registryID
            self.pool = try AsyncHashResourcePool(
                device: device,
                maxPooledResources: maxPooledResources,
                preallocateForByteCount: preallocateForByteCount
            )
        }

        fileprivate func lease(chunkCount: Int) throws -> AsyncHashResourceLease {
            try pool.lease(chunkCount: chunkCount)
        }

        fileprivate func release(_ lease: AsyncHashResourceLease) {
            pool.release(lease)
        }
    }

    public final class ChunkChainingValueBuffer: @unchecked Sendable {
        public let chunkCapacity: Int

        fileprivate let buffer: MTLBuffer
        fileprivate let lock = NSLock()
        fileprivate var writtenChunkCount = 0

        public var metalBuffer: MTLBuffer {
            buffer
        }

        public var chunkCount: Int {
            lock.lock()
            defer {
                lock.unlock()
            }
            return writtenChunkCount
        }

        public var byteCount: Int {
            chunkCount * BLAKE3.digestByteCount
        }

        public func withUnsafeBytes<R>(
            _ body: (UnsafeRawBufferPointer) throws -> R
        ) rethrows -> R {
            lock.lock()
            defer {
                lock.unlock()
            }
            return try body(
                UnsafeRawBufferPointer(
                    start: buffer.contents(),
                    count: writtenChunkCount * BLAKE3.digestByteCount
                )
            )
        }

        fileprivate func setWrittenChunkCount(_ count: Int) {
            lock.lock()
            writtenChunkCount = count
            lock.unlock()
        }

        fileprivate func lockForAsyncUse() {
            lock.lock()
        }

        fileprivate func unlockForAsyncUse() {
            lock.unlock()
        }

        fileprivate init(buffer: MTLBuffer, chunkCapacity: Int) {
            self.buffer = buffer
            self.chunkCapacity = chunkCapacity
        }
    }

    public final class AsyncPipeline: @unchecked Sendable {
        public let inputCapacity: Int
        public let inFlightCount: Int
        public let policy: ExecutionPolicy
        public let usesPrivateBuffers: Bool

        private let context: Context
        private let workspace: AsyncWorkspace
        private let stagingBuffers: [StagingBuffer]
        private let privateBuffers: [PrivateBuffer]?
        private let slots: AsyncPipelineSlotPool

        fileprivate init(
            context: Context,
            inputCapacity: Int,
            inFlightCount: Int,
            policy: ExecutionPolicy,
            usesPrivateBuffers: Bool,
            workspace: AsyncWorkspace,
            stagingBuffers: [StagingBuffer],
            privateBuffers: [PrivateBuffer]?
        ) {
            self.context = context
            self.inputCapacity = inputCapacity
            self.inFlightCount = inFlightCount
            self.policy = policy
            self.usesPrivateBuffers = usesPrivateBuffers
            self.workspace = workspace
            self.stagingBuffers = stagingBuffers
            self.privateBuffers = privateBuffers
            self.slots = AsyncPipelineSlotPool(slotCount: inFlightCount)
        }

        public func hash(input: some ContiguousBytes) async throws -> BLAKE3.Digest {
            let slot = try slots.acquire()
            defer {
                slots.release(slot)
            }

            if let privateBuffers {
                if let smallInputDigest = input.withUnsafeBytes({ raw -> BLAKE3.Digest? in
                    guard raw.count <= BLAKE3.chunkByteCount else {
                        return nil
                    }
                    return BLAKE3.hash(raw)
                }) {
                    try Task.checkCancellation()
                    return smallInputDigest
                }

                try await context.replaceContentsAsync(
                    of: privateBuffers[slot],
                    with: input,
                    using: stagingBuffers[slot]
                )
                try Task.checkCancellation()
                let digest = try await context.hashAsync(
                    privateBuffer: privateBuffers[slot],
                    policy: policy,
                    workspace: workspace
                )
                try Task.checkCancellation()
                return digest
            }

            let digest = try await context.hashAsync(
                input: input,
                using: stagingBuffers[slot],
                policy: policy,
                workspace: workspace
            )
            try Task.checkCancellation()
            return digest
        }

        public func hash(buffer: MTLBuffer, length: Int) async throws -> BLAKE3.Digest {
            let slot = try slots.acquire()
            defer {
                slots.release(slot)
            }
            let digest = try await context.hashAsync(
                buffer: buffer,
                length: length,
                policy: policy,
                workspace: workspace
            )
            try Task.checkCancellation()
            return digest
        }

        public func hash(buffer: MTLBuffer, range: Range<Int>) async throws -> BLAKE3.Digest {
            let slot = try slots.acquire()
            defer {
                slots.release(slot)
            }
            let digest = try await context.hashAsync(
                buffer: buffer,
                range: range,
                policy: policy,
                workspace: workspace
            )
            try Task.checkCancellation()
            return digest
        }

        public func hash(privateBuffer: PrivateBuffer) async throws -> BLAKE3.Digest {
            let slot = try slots.acquire()
            defer {
                slots.release(slot)
            }
            let digest = try await context.hashAsync(
                privateBuffer: privateBuffer,
                policy: policy,
                workspace: workspace
            )
            try Task.checkCancellation()
            return digest
        }

        public func hash(privateBuffer: PrivateBuffer, length: Int) async throws -> BLAKE3.Digest {
            let slot = try slots.acquire()
            defer {
                slots.release(slot)
            }
            let digest = try await context.hashAsync(
                privateBuffer: privateBuffer,
                length: length,
                policy: policy,
                workspace: workspace
            )
            try Task.checkCancellation()
            return digest
        }
    }

    public final class StagingBuffer: @unchecked Sendable {
        public let capacity: Int
        fileprivate let buffer: MTLBuffer
        fileprivate let lock = NSLock()

        public var metalBuffer: MTLBuffer {
            buffer
        }

        fileprivate func lockForAsyncUse() {
            lock.lock()
        }

        fileprivate func unlockForAsyncUse() {
            lock.unlock()
        }

        fileprivate init(buffer: MTLBuffer, capacity: Int) {
            self.buffer = buffer
            self.capacity = capacity
        }
    }

    public final class PrivateBuffer: @unchecked Sendable {
        public let capacity: Int
        fileprivate let buffer: MTLBuffer
        fileprivate let lock = NSLock()
        fileprivate var length: Int

        public var metalBuffer: MTLBuffer {
            buffer
        }

        public var byteCount: Int {
            lock.lock()
            defer {
                lock.unlock()
            }
            return length
        }

        fileprivate func lockForAsyncUse() {
            lock.lock()
        }

        fileprivate func unlockForAsyncUse() {
            lock.unlock()
        }

        fileprivate init(buffer: MTLBuffer, capacity: Int, length: Int) {
            self.buffer = buffer
            self.capacity = capacity
            self.length = length
        }
    }

    private final class AsyncPipelineSlotPool: @unchecked Sendable {
        private let semaphore: DispatchSemaphore
        private let lock = NSLock()
        private var availableSlots: [Int]

        init(slotCount: Int) {
            self.semaphore = DispatchSemaphore(value: slotCount)
            self.availableSlots = Array((0..<slotCount).reversed())
        }

        func acquire() throws -> Int {
            try Task.checkCancellation()
            semaphore.wait()
            if Task.isCancelled {
                semaphore.signal()
                throw CancellationError()
            }

            lock.lock()
            guard let slot = availableSlots.popLast() else {
                lock.unlock()
                semaphore.signal()
                throw BLAKE3Error.metalCommandFailed("Async pipeline slot accounting failed.")
            }
            lock.unlock()
            return slot
        }

        func release(_ slot: Int) {
            lock.lock()
            availableSlots.append(slot)
            lock.unlock()
            semaphore.signal()
        }
    }

    fileprivate struct AsyncHashResourceLease: Sendable {
        let resources: AsyncHashResources
        let isPooled: Bool
    }

    fileprivate final class AsyncHashResourcePool: @unchecked Sendable {
        private let device: MTLDevice
        private let maxPooledResources: Int
        private let lock = NSLock()
        private var pooledResourceCount = 0
        private var idleResources: [AsyncHashResources] = []

        init(
            device: MTLDevice,
            maxPooledResources: Int,
            preallocateForByteCount: Int?
        ) throws {
            self.device = device
            self.maxPooledResources = maxPooledResources

            guard let preallocateForByteCount else {
                return
            }

            let chunkCount = max(
                1,
                (preallocateForByteCount + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount
            )
            for _ in 0..<maxPooledResources {
                let resources = AsyncHashResources(device: device)
                try resources.ensureBuffers(chunkCount: chunkCount)
                idleResources.append(resources)
                pooledResourceCount += 1
            }
        }

        func lease(chunkCount: Int) throws -> AsyncHashResourceLease {
            lock.lock()
            if let resources = idleResources.popLast() {
                lock.unlock()
                do {
                    try resources.ensureBuffers(chunkCount: chunkCount)
                    return AsyncHashResourceLease(resources: resources, isPooled: true)
                } catch {
                    lock.lock()
                    pooledResourceCount -= 1
                    lock.unlock()
                    throw error
                }
            }
            if pooledResourceCount < maxPooledResources {
                pooledResourceCount += 1
                lock.unlock()
                do {
                    let resources = AsyncHashResources(device: device)
                    try resources.ensureBuffers(chunkCount: chunkCount)
                    return AsyncHashResourceLease(resources: resources, isPooled: true)
                } catch {
                    lock.lock()
                    pooledResourceCount -= 1
                    lock.unlock()
                    throw error
                }
            }
            lock.unlock()

            let resources = AsyncHashResources(device: device)
            try resources.ensureBuffers(chunkCount: chunkCount)
            return AsyncHashResourceLease(resources: resources, isPooled: false)
        }

        func release(_ lease: AsyncHashResourceLease) {
            guard lease.isPooled else {
                return
            }
            lock.lock()
            idleResources.append(lease.resources)
            lock.unlock()
        }
    }

    fileprivate struct AsyncHashBuffers: @unchecked Sendable {
        let chunkCVBuffer: MTLBuffer
        let parentCVBuffer: MTLBuffer
        let digestBuffer: MTLBuffer
        let parameterBuffer: MTLBuffer
    }

    fileprivate final class AsyncHashResources: @unchecked Sendable {
        private let device: MTLDevice
        private var chunkCVBuffer: MTLBuffer?
        private var parentCVBuffer: MTLBuffer?
        private var digestBuffer: MTLBuffer?
        private var parameterBuffer: MTLBuffer?
        private var chunkCVCapacity = 0
        private var parentCVCapacity = 0
        private var parameterSlotCapacity = 0

        init(device: MTLDevice) {
            self.device = device
        }

        func ensureBuffers(chunkCount: Int) throws {
            let chunkCVByteCount = chunkCount * BLAKE3.digestByteCount
            let parentCVByteCount = ((chunkCount + 1) / 2) * BLAKE3.digestByteCount

            if chunkCVCapacity < chunkCVByteCount {
                let capacity = Context.roundedCapacity(for: chunkCVByteCount)
                guard let buffer = device.makeBuffer(
                    length: capacity,
                    options: .storageModePrivate
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate async chunk chaining value buffer.")
                }
                chunkCVBuffer = buffer
                chunkCVCapacity = capacity
            }
            if parentCVCapacity < parentCVByteCount {
                let capacity = Context.roundedCapacity(for: parentCVByteCount)
                guard let buffer = device.makeBuffer(
                    length: capacity,
                    options: .storageModePrivate
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate async parent chaining value buffer.")
                }
                parentCVBuffer = buffer
                parentCVCapacity = capacity
            }
            if digestBuffer == nil {
                guard let buffer = device.makeBuffer(
                    length: BLAKE3.digestByteCount,
                    options: .storageModeShared
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate async digest buffer.")
                }
                digestBuffer = buffer
            }
            let parameterSlotCount = 1 + Context.parentReductionStepCount(for: chunkCount)
            if parameterSlotCapacity < parameterSlotCount {
                guard let buffer = device.makeBuffer(
                    length: parameterSlotCount * Context.parameterSlotStride,
                    options: .storageModeShared
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to allocate async parameter buffer.")
                }
                parameterBuffer = buffer
                parameterSlotCapacity = parameterSlotCount
            }
        }

        func buffers() throws -> AsyncHashBuffers {
            guard let chunkCVBuffer,
                  let parentCVBuffer,
                  let digestBuffer,
                  let parameterBuffer
            else {
                throw BLAKE3Error.metalCommandFailed("Async Metal workspace buffers are unavailable.")
            }
            return AsyncHashBuffers(
                chunkCVBuffer: chunkCVBuffer,
                parentCVBuffer: parentCVBuffer,
                digestBuffer: digestBuffer,
                parameterBuffer: parameterBuffer
            )
        }
    }

    private static func hash(
        buffer: MTLBuffer,
        range: Range<Int>,
        policy: ExecutionPolicy,
        minimumGPUByteCount: Int,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        workspace: Context
    ) throws -> BLAKE3.Digest {
        guard range.lowerBound >= 0,
              range.upperBound <= buffer.length,
              range.lowerBound <= range.upperBound
        else {
            throw BLAKE3Error.invalidBufferRange
        }

        switch policy {
        case .cpu:
            return try hashOnCPU(buffer: buffer, range: range)
        case .automatic:
            guard range.count >= minimumGPUByteCount || buffer.storageMode == .private else {
                return try hashOnCPU(buffer: buffer, range: range)
            }
        case .gpu:
            break
        }

        guard range.count > BLAKE3.chunkByteCount else {
            return try hashOnCPU(buffer: buffer, range: range)
        }

        let chunkCount = (range.count + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount

        return try workspace.withWorkspace(chunkCount: chunkCount) { cvBuffer, scratchBuffer, digestBuffer, parameterBuffer in
            let commandBuffer = try makeHashCommandBuffer(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                retainsReferences: false,
                cvBuffer: cvBuffer,
                scratchBuffer: scratchBuffer,
                digestBuffer: digestBuffer,
                parameterBuffer: parameterBuffer
            )
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()

            if let error = commandBuffer.error {
                throw BLAKE3Error.metalCommandFailed(error.localizedDescription)
            }

            return BLAKE3.Digest(
                UnsafeRawBufferPointer(
                    start: digestBuffer.contents(),
                    count: BLAKE3.digestByteCount
                )
            )
        }
    }

    private static func hashAsync(
        buffer: MTLBuffer,
        range: Range<Int>,
        policy: ExecutionPolicy,
        minimumGPUByteCount: Int,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        asyncWorkspace: AsyncWorkspace
    ) async throws -> BLAKE3.Digest {
        guard range.lowerBound >= 0,
              range.upperBound <= buffer.length,
              range.lowerBound <= range.upperBound
        else {
            throw BLAKE3Error.invalidBufferRange
        }
        guard asyncWorkspace.deviceRegistryID == buffer.device.registryID else {
            throw BLAKE3Error.metalCommandFailed("Async workspace belongs to a different Metal device.")
        }

        switch policy {
        case .cpu:
            return try hashOnCPU(buffer: buffer, range: range)
        case .automatic:
            guard range.count >= minimumGPUByteCount || buffer.storageMode == .private else {
                return try hashOnCPU(buffer: buffer, range: range)
            }
        case .gpu:
            break
        }

        guard range.count > BLAKE3.chunkByteCount else {
            return try hashOnCPU(buffer: buffer, range: range)
        }

        let chunkCount = (range.count + BLAKE3.chunkByteCount - 1) / BLAKE3.chunkByteCount
        let lease = try asyncWorkspace.lease(chunkCount: chunkCount)
        let resources = lease.resources
        let buffers: AsyncHashBuffers
        do {
            buffers = try resources.buffers()
        } catch {
            asyncWorkspace.release(lease)
            throw error
        }
        let commandBuffer: MTLCommandBuffer
        do {
            commandBuffer = try makeHashCommandBuffer(
                buffer: buffer,
                range: range,
                chunkCount: chunkCount,
                pipelines: pipelines,
                commandQueue: commandQueue,
                retainsReferences: true,
                cvBuffer: buffers.chunkCVBuffer,
                scratchBuffer: buffers.parentCVBuffer,
                digestBuffer: buffers.digestBuffer,
                parameterBuffer: buffers.parameterBuffer
            )
        } catch {
            asyncWorkspace.release(lease)
            throw error
        }

        return try await withCheckedThrowingContinuation { continuation in
            commandBuffer.addCompletedHandler { completedBuffer in
                if let error = completedBuffer.error {
                    asyncWorkspace.release(lease)
                    continuation.resume(throwing: BLAKE3Error.metalCommandFailed(error.localizedDescription))
                    return
                }
                let digest = BLAKE3.Digest(
                    UnsafeRawBufferPointer(
                        start: buffers.digestBuffer.contents(),
                        count: BLAKE3.digestByteCount
                    )
                )
                asyncWorkspace.release(lease)
                continuation.resume(returning: digest)
            }
            commandBuffer.commit()
        }
    }

    private static func makeHashCommandBuffer(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        retainsReferences: Bool,
        cvBuffer: MTLBuffer,
        scratchBuffer: MTLBuffer,
        digestBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer
    ) throws -> MTLCommandBuffer {
        let commandBuffer = retainsReferences
            ? commandQueue.makeCommandBuffer()
            : commandQueue.makeCommandBufferWithUnretainedReferences()
        guard let commandBuffer,
              let encoder = commandBuffer.makeComputeCommandEncoder()
        else {
            throw BLAKE3Error.metalCommandFailed("Unable to create command buffer or encoder.")
        }

        let params = BLAKE3MetalChunkParams(
            inputOffset: UInt64(range.lowerBound),
            inputLength: UInt64(range.count),
            baseChunkCounter: 0,
            chunkCount: UInt32(chunkCount)
        )
        copyParameter(params, into: parameterBuffer, slot: 0)
        let chunkPipeline = range.count.isMultiple(of: BLAKE3.chunkByteCount)
            ? pipelines.chunkFullCVs
            : pipelines.chunkCVs

        encoder.setComputePipelineState(chunkPipeline)
        encoder.setBuffer(buffer, offset: 0, index: 0)
        encoder.setBuffer(cvBuffer, offset: 0, index: 1)
        encoder.setBuffer(parameterBuffer, offset: 0, index: 2)

        dispatchThreads(
            count: chunkCount,
            pipeline: chunkPipeline,
            encoder: encoder
        )

        var currentBuffer = cvBuffer
        var nextBuffer = scratchBuffer
        var currentCount = chunkCount
        var parameterSlot = 1

        while currentCount > 4 {
            let parentParams = BLAKE3MetalParentParams(inputCount: UInt32(currentCount))
            copyParameter(parentParams, into: parameterBuffer, slot: parameterSlot)
            let useWideReduction = currentCount >= wideParentReductionThreshold
            let useQuadReduction = !useWideReduction
                && currentCount >= quadParentReductionThreshold
            let pipeline = if useWideReduction {
                currentCount.isMultiple(of: 16)
                    ? pipelines.parent16CVs
                    : pipelines.parent16TailCVs
            } else if useQuadReduction {
                pipelines.parent4CVs
            } else {
                pipelines.parentCVs
            }
            let nextCount = if useWideReduction {
                (currentCount + 15) / 16
            } else if useQuadReduction {
                (currentCount + 3) / 4
            } else {
                (currentCount + 1) / 2
            }
            encoder.setComputePipelineState(pipeline)
            encoder.setBuffer(currentBuffer, offset: 0, index: 0)
            encoder.setBuffer(nextBuffer, offset: 0, index: 1)
            encoder.setBuffer(parameterBuffer, offset: parameterOffset(for: parameterSlot), index: 2)
            dispatchThreads(
                count: nextCount,
                pipeline: pipeline,
                encoder: encoder
            )

            swap(&currentBuffer, &nextBuffer)
            currentCount = nextCount
            parameterSlot += 1
        }

        let rootPipeline: MTLComputePipelineState? = switch currentCount {
        case 2:
            pipelines.rootDigest
        case 3:
            pipelines.root3Digest
        case 4:
            pipelines.root4Digest
        default:
            nil
        }
        guard let rootPipeline else {
            encoder.endEncoding()
            throw BLAKE3Error.metalCommandFailed("Unable to create root digest encoder.")
        }
        encoder.setComputePipelineState(rootPipeline)
        encoder.setBuffer(currentBuffer, offset: 0, index: 0)
        encoder.setBuffer(digestBuffer, offset: 0, index: 1)
        dispatchThreads(
            count: 1,
            pipeline: rootPipeline,
            encoder: encoder
        )
        encoder.endEncoding()

        return commandBuffer
    }

    private static func makeChunkChainingValuesCommandBuffer(
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        baseChunkCounter: UInt64,
        pipelines: BLAKE3MetalPipelines,
        commandQueue: MTLCommandQueue,
        retainsReferences: Bool,
        outputBuffer: MTLBuffer,
        parameterBuffer: MTLBuffer
    ) throws -> MTLCommandBuffer {
        let commandBuffer = retainsReferences
            ? commandQueue.makeCommandBuffer()
            : commandQueue.makeCommandBufferWithUnretainedReferences()
        guard let commandBuffer,
              let encoder = commandBuffer.makeComputeCommandEncoder()
        else {
            throw BLAKE3Error.metalCommandFailed("Unable to create chunk chaining value command buffer.")
        }

        let params = BLAKE3MetalChunkParams(
            inputOffset: UInt64(range.lowerBound),
            inputLength: UInt64(range.count),
            baseChunkCounter: baseChunkCounter,
            chunkCount: UInt32(chunkCount)
        )
        copyParameter(params, into: parameterBuffer, slot: 0)
        encoder.setComputePipelineState(pipelines.chunkFullCVs)
        encoder.setBuffer(buffer, offset: 0, index: 0)
        encoder.setBuffer(outputBuffer, offset: 0, index: 1)
        encoder.setBuffer(parameterBuffer, offset: 0, index: 2)
        dispatchThreads(
            count: chunkCount,
            pipeline: pipelines.chunkFullCVs,
            encoder: encoder
        )
        encoder.endEncoding()

        return commandBuffer
    }

    private static func parameterOffset(for slot: Int) -> Int {
        slot * Context.parameterSlotStride
    }

    private static func copyParameter<T>(_ value: T, into buffer: MTLBuffer, slot: Int) {
        var value = value
        withUnsafeBytes(of: &value) { raw in
            buffer.contents()
                .advanced(by: parameterOffset(for: slot))
                .copyMemory(from: raw.baseAddress!, byteCount: raw.count)
        }
    }

    private static func dispatchThreads(
        count: Int,
        pipeline: MTLComputePipelineState,
        encoder: MTLComputeCommandEncoder
    ) {
        let executionWidth = max(1, pipeline.threadExecutionWidth)
        let targetSIMDGroups = count >= largeGridThreadThreshold
            ? largeGridSIMDGroupsPerThreadgroup
            : smallGridSIMDGroupsPerThreadgroup
        let threadgroupCount = max(1, min(targetSIMDGroups, pipeline.maxTotalThreadsPerThreadgroup / executionWidth))
        let threadgroupWidth = threadgroupCount * executionWidth
        let threadsPerThreadgroup = MTLSize(width: threadgroupWidth, height: 1, depth: 1)
        let threads = MTLSize(width: count, height: 1, depth: 1)
        encoder.dispatchThreads(threads, threadsPerThreadgroup: threadsPerThreadgroup)
    }

    private static func hashOnCPU(buffer: MTLBuffer, range: Range<Int>) throws -> BLAKE3.Digest {
        guard buffer.storageMode != .private else {
            throw BLAKE3Error.metalCommandFailed("CPU fallback requires a CPU-visible Metal buffer.")
        }
        let start = buffer.contents().advanced(by: range.lowerBound)
        return BLAKE3.hashParallel(
            UnsafeRawBufferPointer(start: start, count: range.count)
        )
    }
}

private final class BLAKE3MetalContextCache: @unchecked Sendable {
    private let lock = NSLock()
    private var contexts: [UInt64: BLAKE3Metal.Context] = [:]

    func context(device: MTLDevice) throws -> BLAKE3Metal.Context {
        lock.lock()
        if let context = contexts[device.registryID] {
            lock.unlock()
            return context
        }
        lock.unlock()

        let context = try BLAKE3Metal.Context(device: device)

        lock.lock()
        defer {
            lock.unlock()
        }
        if let existing = contexts[device.registryID] {
            return existing
        }
        contexts[device.registryID] = context
        return context
    }
}
#endif
