#if canImport(Darwin)
import Darwin
#endif

import Foundation
#if canImport(Metal)
import Metal
#endif

/// File hashing APIs for regular files.
///
/// CPU strategies work without Metal. Metal strategies fall back to CPU by default unless their
/// `fallbackToCPU` parameter is set to `false`.
public enum BLAKE3File {
    /// Default tile size used by mapped CPU file paths.
    public static let mappedTileByteCount = 16 * 1024 * 1024

    /// Default tile size used by regular-file read paths.
    public static let readTileByteCount = 64 * 1024 * 1024

    /// Default tile size used by tiled Metal file paths.
    public static let metalMappedTileByteCount = readTileByteCount

    /// Default tile size used by staged Metal read paths.
    public static let metalStagedReadTileByteCount = 32 * 1024 * 1024

    private struct HashMode: Sendable {
        let key: BLAKE3Core.ChainingValue
        let flags: UInt32

        static let unkeyed = HashMode(key: BLAKE3Core.iv, flags: 0)

        #if canImport(Metal)
        var metalMode: BLAKE3Metal.HashMode {
            BLAKE3Metal.HashMode(key: key, flags: flags)
        }
        #endif
    }

    /// File hashing strategy.
    public enum Strategy: Equatable, Sendable {
        /// Chooses the bounded memory-mapped CPU path with read fallback.
        case automatic
        /// Streams the file through bounded reusable read buffers.
        case read(bufferSize: Int = BLAKE3File.readTileByteCount)
        /// Hashes a memory-mapped regular file on the calling thread.
        case memoryMapped
        /// Hashes a memory-mapped regular file with CPU parallelism.
        case memoryMappedParallel(maxThreads: Int? = nil)
        #if canImport(Metal)
        /// Wraps mapped file pages in a shared Metal buffer and hashes through ``BLAKE3Metal``.
        ///
        /// Pass `librarySource` to use a precompiled `.metallib` instead of runtime source compilation.
        case metalMemoryMapped(
            policy: BLAKE3Metal.ExecutionPolicy = .automatic,
            fallbackToCPU: Bool = true,
            librarySource: BLAKE3Metal.LibrarySource = .runtimeSource
        )
        /// Processes mapped file chunks on Metal in bounded tiles and performs canonical final tree reduction.
        ///
        /// Pass `librarySource` to use a precompiled `.metallib` instead of runtime source compilation.
        case metalTiledMemoryMapped(
            tileByteCount: Int = BLAKE3File.metalMappedTileByteCount,
            fallbackToCPU: Bool = true,
            librarySource: BLAKE3Metal.LibrarySource = .runtimeSource
        )
        /// Reads file tiles directly into a reusable shared Metal buffer and hashes each tile on the GPU.
        ///
        /// This path avoids GPU page faults from memory-mapped file pages while keeping memory bounded.
        /// Pass `librarySource` to use a precompiled `.metallib` instead of runtime source compilation.
        case metalStagedRead(
            tileByteCount: Int = BLAKE3File.metalStagedReadTileByteCount,
            fallbackToCPU: Bool = true,
            librarySource: BLAKE3Metal.LibrarySource = .runtimeSource
        )
        #endif
    }

    /// Hashes a regular file with the selected strategy.
    public static func hash(
        path: String,
        strategy: Strategy = .automatic
    ) throws -> BLAKE3.Digest {
        try digest(
            from: hashOutput(
                path: path,
                strategy: strategy,
                mode: .unkeyed,
                outputByteCount: BLAKE3.digestByteCount,
                seek: 0,
                cancellationCheck: nil
            )
        )
    }

    /// Hashes a regular file and returns `outputByteCount` BLAKE3 XOF output bytes.
    public static func hash(
        path: String,
        strategy: Strategy = .automatic,
        outputByteCount: Int,
        seek: UInt64 = 0
    ) throws -> [UInt8] {
        try hashOutput(
            path: path,
            strategy: strategy,
            mode: .unkeyed,
            outputByteCount: outputByteCount,
            seek: seek,
            cancellationCheck: nil
        )
    }

    /// Computes a keyed 32-byte BLAKE3 digest for a regular file.
    public static func keyedHash(
        key: some ContiguousBytes,
        path: String,
        strategy: Strategy = .automatic
    ) throws -> BLAKE3.Digest {
        try key.withUnsafeBytes { keyBytes in
            try digest(
                from: hashOutput(
                    path: path,
                    strategy: strategy,
                    mode: keyedMode(keyBytes),
                    outputByteCount: BLAKE3.digestByteCount,
                    seek: 0,
                    cancellationCheck: nil
                )
            )
        }
    }

    /// Computes keyed BLAKE3 XOF output for a regular file.
    public static func keyedHash(
        key: some ContiguousBytes,
        path: String,
        strategy: Strategy = .automatic,
        outputByteCount: Int,
        seek: UInt64 = 0
    ) throws -> [UInt8] {
        try key.withUnsafeBytes { keyBytes in
            try hashOutput(
                path: path,
                strategy: strategy,
                mode: keyedMode(keyBytes),
                outputByteCount: outputByteCount,
                seek: seek,
                cancellationCheck: nil
            )
        }
    }

    /// Derives key material from a regular file using BLAKE3 key derivation.
    public static func deriveKey(
        context: String,
        path: String,
        strategy: Strategy = .automatic,
        outputByteCount: Int = BLAKE3.digestByteCount,
        seek: UInt64 = 0
    ) throws -> [UInt8] {
        try hashOutput(
            path: path,
            strategy: strategy,
            mode: deriveKeyMaterialMode(context: context),
            outputByteCount: outputByteCount,
            seek: seek,
            cancellationCheck: nil
        )
    }

    /// Hashes a regular file asynchronously.
    ///
    /// CPU strategies run on a detached task. Metal strategies keep mapped pages alive until GPU work
    /// completes and check task cancellation between major file or tile operations.
    public static func hashAsync(
        path: String,
        strategy: Strategy = .automatic
    ) async throws -> BLAKE3.Digest {
        try Task.checkCancellation()
        #if canImport(Metal)
        if case let .metalMemoryMapped(policy, fallbackToCPU, librarySource) = strategy {
            return try await hashMetalMappedAsync(
                path: path,
                policy: policy,
                fallbackToCPU: fallbackToCPU,
                librarySource: librarySource,
                mode: .unkeyed
            )
        }
        if case let .metalTiledMemoryMapped(tileByteCount, fallbackToCPU, librarySource) = strategy {
            return try await hashMetalTiledMappedAsync(
                path: path,
                tileByteCount: tileByteCount,
                fallbackToCPU: fallbackToCPU,
                librarySource: librarySource,
                mode: .unkeyed
            )
        }
        if case let .metalStagedRead(tileByteCount, fallbackToCPU, librarySource) = strategy {
            let output = try await Task.detached {
                try hashMetalStagedRead(
                    path: path,
                    tileByteCount: tileByteCount,
                    fallbackToCPU: fallbackToCPU,
                    librarySource: librarySource,
                    mode: .unkeyed,
                    outputByteCount: BLAKE3.digestByteCount,
                    seek: 0,
                    cancellationCheck: { try Task.checkCancellation() }
                )
            }.value
            return try digest(from: output)
        }
        #endif
        return try await Task.detached {
            try hash(
                path: path,
                strategy: strategy,
                mode: .unkeyed,
                outputByteCount: BLAKE3.digestByteCount,
                seek: 0,
                cancellationCheck: { try Task.checkCancellation() }
            )
        }.value
    }

    private static func hash(
        path: String,
        strategy: Strategy,
        mode: HashMode = .unkeyed,
        outputByteCount: Int = BLAKE3.digestByteCount,
        seek: UInt64 = 0,
        cancellationCheck: (() throws -> Void)?
    ) throws -> BLAKE3.Digest {
        try digest(
            from: hashOutput(
                path: path,
                strategy: strategy,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                cancellationCheck: cancellationCheck
            )
        )
    }

    private static func hashOutput(
        path: String,
        strategy: Strategy,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64,
        cancellationCheck: (() throws -> Void)?
    ) throws -> [UInt8] {
        try cancellationCheck?()
        try validateOutput(outputByteCount: outputByteCount, seek: seek)
        guard outputByteCount > 0 else {
            return []
        }
        switch strategy {
        case .automatic:
            return try hashMapped(
                path: path,
                fallbackToRead: true,
                parallel: true,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                cancellationCheck: cancellationCheck
            )
        case let .read(bufferSize):
            return try hashRead(
                path: path,
                bufferSize: bufferSize,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                cancellationCheck: cancellationCheck
            )
        case .memoryMapped:
            return try hashMapped(
                path: path,
                fallbackToRead: false,
                parallel: false,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                cancellationCheck: cancellationCheck
            )
        case let .memoryMappedParallel(maxThreads):
            return try hashMapped(
                path: path,
                fallbackToRead: true,
                parallel: true,
                maxWorkers: maxThreads,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                cancellationCheck: cancellationCheck
            )
        #if canImport(Metal)
        case let .metalMemoryMapped(policy, fallbackToCPU, librarySource):
            return try hashMetalMapped(
                path: path,
                policy: policy,
                fallbackToCPU: fallbackToCPU,
                librarySource: librarySource,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                cancellationCheck: cancellationCheck
            )
        case let .metalTiledMemoryMapped(tileByteCount, fallbackToCPU, librarySource):
            return try hashMetalTiledMapped(
                path: path,
                tileByteCount: tileByteCount,
                fallbackToCPU: fallbackToCPU,
                librarySource: librarySource,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                cancellationCheck: cancellationCheck
            )
        case let .metalStagedRead(tileByteCount, fallbackToCPU, librarySource):
            return try hashMetalStagedRead(
                path: path,
                tileByteCount: tileByteCount,
                fallbackToCPU: fallbackToCPU,
                librarySource: librarySource,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                cancellationCheck: cancellationCheck
            )
        #endif
        }
    }

    private static func hashRead(
        path: String,
        bufferSize: Int,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64,
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> [UInt8] {
        try cancellationCheck?()
        let fd = open(path, O_RDONLY)
        guard fd >= 0 else {
            throw BLAKE3Error.fileOpenFailed(path)
        }
        defer { close(fd) }

        var info = stat()
        if fstat(fd, &info) == 0,
           isRegularFile(mode: info.st_mode),
           info.st_size > 0,
           info.st_size <= off_t(Int.max) {
            return try hashReadRegularFile(
                fd: fd,
                path: path,
                fileSize: Int(info.st_size),
                bufferSize: bufferSize,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                cancellationCheck: cancellationCheck
            )
        }

        let clampedBufferSize = max(bufferSize, 1)
        let buffer = UnsafeMutableRawPointer.allocate(
            byteCount: clampedBufferSize,
            alignment: MemoryLayout<UInt64>.alignment
        )
        defer { buffer.deallocate() }

        var hasher = BLAKE3.Hasher(key: mode.key, flags: mode.flags)
        while true {
            try cancellationCheck?()
            let readCount = Darwin.read(fd, buffer, clampedBufferSize)
            if readCount > 0 {
                hasher.update(UnsafeRawBufferPointer(start: buffer, count: readCount))
            } else if readCount == 0 {
                break
            } else if errno == EINTR {
                continue
            } else {
                throw BLAKE3Error.fileReadFailed(path)
            }
        }
        return readOutput(from: hasher, outputByteCount: outputByteCount, seek: seek)
    }

    private static func hashReadRegularFile(
        fd: Int32,
        path: String,
        fileSize: Int,
        bufferSize: Int,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64,
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> [UInt8] {
        enableReadAhead(fd: fd)
        let clampedBufferSize = max(1, min(bufferSize, fileSize))
        let readInflightCount = configuredReadInflightCount()
        let buffers = (0..<readInflightCount).map { _ in
            UnsafeMutableRawPointer.allocate(
                byteCount: clampedBufferSize,
                alignment: MemoryLayout<UInt64>.alignment
            )
        }
        defer {
            for buffer in buffers {
                buffer.deallocate()
            }
        }

        var hasher = BLAKE3.Hasher(key: mode.key, flags: mode.flags)
        var fileOffset = 0
        let alignedBufferSize = (clampedBufferSize / BLAKE3.chunkByteCount) * BLAKE3.chunkByteCount
        guard alignedBufferSize >= BLAKE3.chunkByteCount else {
            let buffer = buffers[0]
            while fileOffset < fileSize {
                try cancellationCheck?()
                let requested = min(clampedBufferSize, fileSize - fileOffset)
                try readExactly(fd: fd, into: buffer, byteCount: requested, path: path)
                hasher.update(UnsafeRawBufferPointer(start: buffer, count: requested))
                fileOffset += requested
            }
            return readOutput(from: hasher, outputByteCount: outputByteCount, seek: seek)
        }

        var stack = BLAKE3Core.CVStack()
        let scheduler = BLAKE3Core.defaultScheduler(forByteCount: fileSize, maxWorkers: nil)
        let tileWorker = CPUFileTileWorker(scheduler: scheduler, mode: mode)
        var pendingTileWork: CPUFileTileWork?
        defer {
            _ = try? pendingTileWork?.wait()
        }
        var bufferIndex = 0

        while fileOffset < fileSize {
            try cancellationCheck?()
            if readInflightCount == 1, let tileWork = pendingTileWork {
                pendingTileWork = nil
                pushCPUFileStackEntries(try tileWork.wait(), into: &stack, mode: mode)
            }
            let buffer = buffers[bufferIndex]
            let requested = min(alignedBufferSize, fileSize - fileOffset)
            try readExactly(fd: fd, into: buffer, byteCount: requested, path: path)
            let isFinalTile = fileOffset + requested == fileSize
            let completeChunkByteCount = if isFinalTile {
                ((requested - 1) / BLAKE3.chunkByteCount) * BLAKE3.chunkByteCount
            } else {
                requested
            }

            if readInflightCount > 1, let tileWork = pendingTileWork {
                pendingTileWork = nil
                pushCPUFileStackEntries(try tileWork.wait(), into: &stack, mode: mode)
            }

            if completeChunkByteCount > 0 {
                pendingTileWork = tileWorker.start(
                    buffer: buffer,
                    byteCount: completeChunkByteCount,
                    baseChunkCounter: UInt64(fileOffset / BLAKE3.chunkByteCount)
                )
            }
            if isFinalTile {
                if let tileWork = pendingTileWork {
                    pendingTileWork = nil
                    pushCPUFileStackEntries(try tileWork.wait(), into: &stack, mode: mode)
                }
                let currentChunkLength = requested - completeChunkByteCount
                let currentChunk = UnsafeRawBufferPointer(
                    start: buffer.advanced(by: completeChunkByteCount),
                    count: currentChunkLength
                )
                let output = BLAKE3Core.chunkOutput(
                    currentChunk,
                    chunkCounter: stack.finalizedChunkCount,
                    key: mode.key,
                    flags: mode.flags
                )
                return stack.rootOutput(
                    currentChunkOutput: output,
                    key: mode.key,
                    flags: mode.flags
                )
                .rootBytes(byteCount: outputByteCount, seek: seek)
            }
            fileOffset += requested
            bufferIndex = (bufferIndex + 1) % readInflightCount
        }

        return emptyOutput(mode: mode, outputByteCount: outputByteCount, seek: seek)
    }

    private static func hashMapped(
        path: String,
        fallbackToRead: Bool,
        parallel: Bool = false,
        maxWorkers: Int? = nil,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64,
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> [UInt8] {
        do {
            return try withMappedRegion(path: path) { region in
                try cancellationCheck?()
                return try hashMappedRegion(
                    region,
                    parallel: parallel,
                    maxWorkers: maxWorkers,
                    mode: mode,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    cancellationCheck: cancellationCheck
                )
            }
        } catch {
            if fallbackToRead {
                return try hashRead(
                    path: path,
                    bufferSize: 64 * 1024,
                    mode: mode,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    cancellationCheck: cancellationCheck
                )
            }
            throw error
        }
    }

    #if canImport(Metal)
    private static func hashMetalMapped(
        path: String,
        policy: BLAKE3Metal.ExecutionPolicy,
        fallbackToCPU: Bool,
        librarySource: BLAKE3Metal.LibrarySource,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64,
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> [UInt8] {
        do {
            try cancellationCheck?()
            guard let device = MTLCreateSystemDefaultDevice() else {
                throw BLAKE3Error.metalUnavailable
            }
            let context = try BLAKE3Metal.cachedContext(device: device, librarySource: librarySource)
            return try withMappedRegion(path: path) { region in
                try cancellationCheck?()
                guard region.size > 0,
                      let pointer = region.pointer
                else {
                    return emptyOutput(mode: mode, outputByteCount: outputByteCount, seek: seek)
                }
                guard let buffer = device.makeBuffer(
                    bytesNoCopy: pointer,
                    length: region.size,
                    options: .storageModeShared,
                    deallocator: nil
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to wrap mapped file pages in a Metal buffer.")
                }
                if outputByteCount == BLAKE3.digestByteCount, seek == 0 {
                    return try context.hash(
                        buffer: buffer,
                        range: 0..<region.size,
                        policy: policy,
                        mode: mode.metalMode
                    ).bytes
                }
                return try context.hash(
                    buffer: buffer,
                    range: 0..<region.size,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    policy: policy,
                    mode: mode.metalMode
                )
            }
        } catch let error as CancellationError {
            throw error
        } catch {
            if fallbackToCPU {
                return try hashMapped(
                    path: path,
                    fallbackToRead: true,
                    parallel: true,
                    mode: mode,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    cancellationCheck: cancellationCheck
                )
            }
            throw error
        }
    }

    private static func hashMetalMappedAsync(
        path: String,
        policy: BLAKE3Metal.ExecutionPolicy,
        fallbackToCPU: Bool,
        librarySource: BLAKE3Metal.LibrarySource,
        mode: HashMode
    ) async throws -> BLAKE3.Digest {
        do {
            try Task.checkCancellation()
            guard let device = MTLCreateSystemDefaultDevice() else {
                throw BLAKE3Error.metalUnavailable
            }
            let context = try BLAKE3Metal.cachedContext(device: device, librarySource: librarySource)
            return try await withMappedRegionAsync(path: path) { region in
                try Task.checkCancellation()
                guard region.size > 0,
                      let pointer = region.pointer
                else {
                    return try digest(from: emptyOutput(mode: mode, outputByteCount: BLAKE3.digestByteCount, seek: 0))
                }
                guard let buffer = device.makeBuffer(
                    bytesNoCopy: pointer,
                    length: region.size,
                    options: .storageModeShared,
                    deallocator: nil
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to wrap mapped file pages in a Metal buffer.")
                }
                return try context.hash(
                    buffer: buffer,
                    range: 0..<region.size,
                    policy: policy,
                    mode: mode.metalMode
                )
            }
        } catch let error as CancellationError {
            throw error
        } catch {
            if fallbackToCPU {
                return try await Task.detached {
                    let output = try hashMapped(
                        path: path,
                        fallbackToRead: true,
                        parallel: true,
                        mode: mode,
                        outputByteCount: BLAKE3.digestByteCount,
                        seek: 0,
                        cancellationCheck: { try Task.checkCancellation() }
                    )
                    return try digest(from: output)
                }.value
            }
            throw error
        }
    }

    private static func hashMetalTiledMappedAsync(
        path: String,
        tileByteCount: Int,
        fallbackToCPU: Bool,
        librarySource: BLAKE3Metal.LibrarySource,
        mode: HashMode
    ) async throws -> BLAKE3.Digest {
        do {
            try Task.checkCancellation()
            guard let device = MTLCreateSystemDefaultDevice() else {
                throw BLAKE3Error.metalUnavailable
            }
            let alignedTileByteCount = alignedMetalTileByteCount(tileByteCount)
            let tileChunkCapacity = max(1, alignedTileByteCount / BLAKE3.chunkByteCount)
            let context = try BLAKE3Metal.cachedContext(device: device, librarySource: librarySource)
            let chunkCVBuffer = try context.makeChunkChainingValueBuffer(chunkCapacity: tileChunkCapacity)

            return try await withMappedRegionAsync(path: path) { region in
                try Task.checkCancellation()
                guard region.size > 0,
                      let pointer = region.pointer
                else {
                    return try digest(from: emptyOutput(mode: mode, outputByteCount: BLAKE3.digestByteCount, seek: 0))
                }

                guard let fileBuffer = device.makeBuffer(
                    bytesNoCopy: pointer,
                    length: region.size,
                    options: .storageModeShared,
                    deallocator: nil
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to wrap mapped file pages in a Metal buffer.")
                }

                var stack = BLAKE3Core.CVStack()
                var offset = 0
                while offset < region.size {
                    try Task.checkCancellation()
                    let remaining = region.size - offset
                    let tileLength = min(alignedTileByteCount, remaining)
                    let isFinalTile = offset + tileLength == region.size
                    let completeChunkByteCount = if isFinalTile {
                        ((tileLength - 1) / BLAKE3.chunkByteCount) * BLAKE3.chunkByteCount
                    } else {
                        tileLength
                    }

                    if completeChunkByteCount > 0 {
                        let chunkRange = offset..<(offset + completeChunkByteCount)
                        let completeChunkCount = completeChunkByteCount / BLAKE3.chunkByteCount
                        if !isFinalTile,
                           completeChunkByteCount == alignedTileByteCount,
                           completeChunkCount.nonzeroBitCount == 1 {
                            let cv = try await context.chunkSubtreeChainingValueAsync(
                                buffer: fileBuffer,
                                range: chunkRange,
                                baseChunkCounter: stack.finalizedChunkCount,
                                mode: mode.metalMode
                            )
                            try Task.checkCancellation()
                            stack.pushSubtreeCV(
                                cv,
                                chunkCount: UInt64(completeChunkCount),
                                key: mode.key,
                                flags: mode.flags
                            )
                        } else {
                            let chunkCount = try await context.writeChunkChainingValuesAsync(
                                buffer: fileBuffer,
                                range: chunkRange,
                                baseChunkCounter: stack.finalizedChunkCount,
                                into: chunkCVBuffer,
                                mode: mode.metalMode
                            )
                            try Task.checkCancellation()
                            try pushChunkChainingValues(
                                chunkCVBuffer,
                                chunkCount: chunkCount,
                                into: &stack,
                                mode: mode
                            )
                        }
                        offset += completeChunkByteCount
                    }

                    if isFinalTile {
                        let currentChunkLength = region.size - offset
                        let currentChunk = UnsafeRawBufferPointer(
                            start: pointer.advanced(by: offset),
                            count: currentChunkLength
                        )
                        let output = BLAKE3Core.chunkOutput(
                            currentChunk,
                            chunkCounter: stack.finalizedChunkCount,
                            key: mode.key,
                            flags: mode.flags
                        )
                        return try digest(
                            from: stack.rootOutput(
                                currentChunkOutput: output,
                                key: mode.key,
                                flags: mode.flags
                            )
                            .rootBytes(byteCount: BLAKE3.digestByteCount)
                        )
                    }
                }

                return try digest(from: emptyOutput(mode: mode, outputByteCount: BLAKE3.digestByteCount, seek: 0))
            }
        } catch let error as CancellationError {
            throw error
        } catch {
            if fallbackToCPU {
                return try await Task.detached {
                    let output = try hashMapped(
                        path: path,
                        fallbackToRead: true,
                        parallel: true,
                        mode: mode,
                        outputByteCount: BLAKE3.digestByteCount,
                        seek: 0,
                        cancellationCheck: { try Task.checkCancellation() }
                    )
                    return try digest(from: output)
                }.value
            }
            throw error
        }
    }

    private static func hashMetalTiledMapped(
        path: String,
        tileByteCount: Int,
        fallbackToCPU: Bool,
        librarySource: BLAKE3Metal.LibrarySource,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64,
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> [UInt8] {
        do {
            try cancellationCheck?()
            guard let device = MTLCreateSystemDefaultDevice() else {
                throw BLAKE3Error.metalUnavailable
            }
            let alignedTileByteCount = alignedMetalTileByteCount(tileByteCount)
            let tileChunkCapacity = max(1, alignedTileByteCount / BLAKE3.chunkByteCount)
            let context = try BLAKE3Metal.cachedContext(device: device, librarySource: librarySource)
            let chunkCVBuffer = try context.makeChunkChainingValueBuffer(chunkCapacity: tileChunkCapacity)

            return try withMappedRegion(path: path) { region in
                try cancellationCheck?()
                guard region.size > 0,
                      let pointer = region.pointer
                else {
                    return emptyOutput(mode: mode, outputByteCount: outputByteCount, seek: seek)
                }

                guard let fileBuffer = device.makeBuffer(
                    bytesNoCopy: pointer,
                    length: region.size,
                    options: .storageModeShared,
                    deallocator: nil
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to wrap mapped file pages in a Metal buffer.")
                }

                var stack = BLAKE3Core.CVStack()
                var offset = 0
                while offset < region.size {
                    try cancellationCheck?()
                    let remaining = region.size - offset
                    let tileLength = min(alignedTileByteCount, remaining)
                    let isFinalTile = offset + tileLength == region.size
                    let completeChunkByteCount = if isFinalTile {
                        ((tileLength - 1) / BLAKE3.chunkByteCount) * BLAKE3.chunkByteCount
                    } else {
                        tileLength
                    }

                    if completeChunkByteCount > 0 {
                        let chunkRange = offset..<(offset + completeChunkByteCount)
                        let completeChunkCount = completeChunkByteCount / BLAKE3.chunkByteCount
                        try pushCompleteMetalChunks(
                            context: context,
                            buffer: fileBuffer,
                            range: chunkRange,
                            chunkCount: completeChunkCount,
                            chunkCVBuffer: chunkCVBuffer,
                            subtreeDecompositionChunkThreshold: metalMappedSubtreeDecompositionChunkThreshold,
                            into: &stack,
                            mode: mode
                        )
                        offset += completeChunkByteCount
                    }

                    if isFinalTile {
                        let currentChunkLength = region.size - offset
                        let currentChunk = UnsafeRawBufferPointer(
                            start: pointer.advanced(by: offset),
                            count: currentChunkLength
                        )
                        let output = BLAKE3Core.chunkOutput(
                            currentChunk,
                            chunkCounter: stack.finalizedChunkCount,
                            key: mode.key,
                            flags: mode.flags
                        )
                        return stack.rootOutput(
                            currentChunkOutput: output,
                            key: mode.key,
                            flags: mode.flags
                        )
                        .rootBytes(byteCount: outputByteCount, seek: seek)
                    }
                }

                return emptyOutput(mode: mode, outputByteCount: outputByteCount, seek: seek)
            }
        } catch let error as CancellationError {
            throw error
        } catch {
            if fallbackToCPU {
                return try hashMapped(
                    path: path,
                    fallbackToRead: true,
                    parallel: true,
                    mode: mode,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    cancellationCheck: cancellationCheck
                )
            }
            throw error
        }
    }

    private static func alignedMetalTileByteCount(_ tileByteCount: Int) -> Int {
        max(
            BLAKE3.chunkByteCount,
            (max(tileByteCount, BLAKE3.chunkByteCount) / BLAKE3.chunkByteCount) * BLAKE3.chunkByteCount
        )
    }

    private static func hashMetalStagedRead(
        path: String,
        tileByteCount: Int,
        fallbackToCPU: Bool,
        librarySource: BLAKE3Metal.LibrarySource,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64,
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> [UInt8] {
        do {
            try cancellationCheck?()
            guard let device = MTLCreateSystemDefaultDevice() else {
                throw BLAKE3Error.metalUnavailable
            }
            let alignedTileByteCount = alignedMetalTileByteCount(tileByteCount)
            let tileChunkCapacity = max(1, alignedTileByteCount / BLAKE3.chunkByteCount)
            let stagedReadInflightCount = configuredMetalStagedReadInflightCount()
            let context = try BLAKE3Metal.cachedContext(device: device, librarySource: librarySource)
            let stagingBuffers = try (0..<stagedReadInflightCount).map { _ in
                try context.makeStagingBuffer(capacity: alignedTileByteCount)
            }
            let chunkCVBuffers = try (0..<stagedReadInflightCount).map { _ in
                try context.makeChunkChainingValueBuffer(chunkCapacity: tileChunkCapacity)
            }

            let fd = open(path, O_RDONLY)
            guard fd >= 0 else {
                throw BLAKE3Error.fileOpenFailed(path)
            }
            defer { close(fd) }

            var info = stat()
            guard fstat(fd, &info) == 0 else {
                throw BLAKE3Error.fileStatFailed(path)
            }
            guard isRegularFile(mode: info.st_mode) else {
                throw BLAKE3Error.memoryMapFailed(path)
            }
            guard info.st_size >= 0,
                  info.st_size <= off_t(Int.max)
            else {
                throw BLAKE3Error.memoryMapFailed(path)
            }

            let fileSize = Int(info.st_size)
            guard fileSize > 0 else {
                return emptyOutput(mode: mode, outputByteCount: outputByteCount, seek: seek)
            }

            enableReadAhead(fd: fd)
            var stack = BLAKE3Core.CVStack()
            var fileOffset = 0
            var bufferIndex = 0
            var pendingSlots = [MetalFileTileWork?](
                repeating: nil,
                count: stagedReadInflightCount
            )
            var pendingQueue = [MetalFileTileWork]()
            pendingQueue.reserveCapacity(stagedReadInflightCount)
            defer {
                for tileWork in pendingQueue {
                    _ = try? tileWork.wait()
                }
            }

            while fileOffset < fileSize {
                try cancellationCheck?()
                try drainMetalFileTileWork(
                    untilBufferAvailableAt: bufferIndex,
                    pendingSlots: &pendingSlots,
                    pendingQueue: &pendingQueue,
                    into: &stack,
                    mode: mode
                )

                let stagingBuffer = stagingBuffers[bufferIndex]
                let chunkCVBuffer = chunkCVBuffers[bufferIndex]
                let stagingPointer = stagingBuffer.metalBuffer.contents()
                let remaining = fileSize - fileOffset
                let tileLength = min(alignedTileByteCount, remaining)
                try readExactly(
                    fd: fd,
                    into: stagingPointer,
                    byteCount: tileLength,
                    path: path
                )

                let isFinalTile = fileOffset + tileLength == fileSize
                let completeChunkByteCount = if isFinalTile {
                    ((tileLength - 1) / BLAKE3.chunkByteCount) * BLAKE3.chunkByteCount
                } else {
                    tileLength
                }

                if completeChunkByteCount > 0 {
                    let chunkRange = 0..<completeChunkByteCount
                    let completeChunkCount = completeChunkByteCount / BLAKE3.chunkByteCount
                    let tileWork = startMetalFileTileWork(
                        context: context,
                        buffer: stagingBuffer.metalBuffer,
                        range: chunkRange,
                        chunkCount: completeChunkCount,
                        baseChunkCounter: UInt64(fileOffset / BLAKE3.chunkByteCount),
                        chunkCVBuffer: chunkCVBuffer,
                        subtreeDecompositionChunkThreshold: metalStagedReadSubtreeDecompositionChunkThreshold,
                        mode: mode,
                        bufferIndex: bufferIndex
                    )
                    pendingSlots[bufferIndex] = tileWork
                    pendingQueue.append(tileWork)
                }

                if isFinalTile {
                    try drainAllMetalFileTileWork(
                        pendingSlots: &pendingSlots,
                        pendingQueue: &pendingQueue,
                        into: &stack,
                        mode: mode
                    )
                    let currentChunkLength = tileLength - completeChunkByteCount
                    let currentChunk = UnsafeRawBufferPointer(
                        start: stagingPointer.advanced(by: completeChunkByteCount),
                        count: currentChunkLength
                    )
                    let output = BLAKE3Core.chunkOutput(
                        currentChunk,
                        chunkCounter: stack.finalizedChunkCount,
                        key: mode.key,
                        flags: mode.flags
                    )
                    return stack.rootOutput(
                        currentChunkOutput: output,
                        key: mode.key,
                        flags: mode.flags
                    )
                    .rootBytes(byteCount: outputByteCount, seek: seek)
                }

                fileOffset += tileLength
                bufferIndex = (bufferIndex + 1) % stagedReadInflightCount
            }

            return emptyOutput(mode: mode, outputByteCount: outputByteCount, seek: seek)
        } catch let error as CancellationError {
            throw error
        } catch {
            if fallbackToCPU {
                return try hashMapped(
                    path: path,
                    fallbackToRead: true,
                    parallel: true,
                    mode: mode,
                    outputByteCount: outputByteCount,
                    seek: seek,
                    cancellationCheck: cancellationCheck
                )
            }
            throw error
        }
    }

    private static func configuredMetalStagedReadInflightCount() -> Int {
        guard let rawValue = ProcessInfo.processInfo
            .environment["BLAKE3_SWIFT_METAL_STAGED_READ_INFLIGHT"],
              let parsed = Int(rawValue)
        else {
            return 4
        }
        return min(max(parsed, 1), 4)
    }

    private struct MetalFileStackEntry {
        var cv: BLAKE3Core.ChainingValue
        var chunkCount: Int
    }

    private final class MetalFileTileWork: @unchecked Sendable {
        let bufferIndex: Int
        private let semaphore = DispatchSemaphore(value: 0)
        private var result: Result<[MetalFileStackEntry], Error>?

        init(bufferIndex: Int) {
            self.bufferIndex = bufferIndex
        }

        func complete(_ result: Result<[MetalFileStackEntry], Error>) {
            self.result = result
            semaphore.signal()
        }

        func wait() throws -> [MetalFileStackEntry] {
            semaphore.wait()
            guard let result else {
                throw BLAKE3Error.metalCommandFailed("Metal staged-read tile work finished without a result.")
            }
            return try result.get()
        }
    }

    private struct MetalFileBufferReference: @unchecked Sendable {
        let buffer: MTLBuffer
    }

    private static func startMetalFileTileWork(
        context: BLAKE3Metal.Context,
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        baseChunkCounter: UInt64,
        chunkCVBuffer: BLAKE3Metal.ChunkChainingValueBuffer,
        subtreeDecompositionChunkThreshold: Int,
        mode: HashMode,
        bufferIndex: Int
    ) -> MetalFileTileWork {
        let work = MetalFileTileWork(bufferIndex: bufferIndex)
        let bufferReference = MetalFileBufferReference(buffer: buffer)
        Task.detached(priority: .userInitiated) {
            do {
                let entries = try collectCompleteMetalChunkEntries(
                    context: context,
                    buffer: bufferReference.buffer,
                    range: range,
                    chunkCount: chunkCount,
                    baseChunkCounter: baseChunkCounter,
                    chunkCVBuffer: chunkCVBuffer,
                    subtreeDecompositionChunkThreshold: subtreeDecompositionChunkThreshold,
                    mode: mode
                )
                work.complete(.success(entries))
            } catch {
                work.complete(.failure(error))
            }
        }
        return work
    }

    private static func drainMetalFileTileWork(
        untilBufferAvailableAt bufferIndex: Int,
        pendingSlots: inout [MetalFileTileWork?],
        pendingQueue: inout [MetalFileTileWork],
        into stack: inout BLAKE3Core.CVStack,
        mode: HashMode
    ) throws {
        while pendingSlots[bufferIndex] != nil {
            try drainNextMetalFileTileWork(
                pendingSlots: &pendingSlots,
                pendingQueue: &pendingQueue,
                into: &stack,
                mode: mode
            )
        }
    }

    private static func drainAllMetalFileTileWork(
        pendingSlots: inout [MetalFileTileWork?],
        pendingQueue: inout [MetalFileTileWork],
        into stack: inout BLAKE3Core.CVStack,
        mode: HashMode
    ) throws {
        while !pendingQueue.isEmpty {
            try drainNextMetalFileTileWork(
                pendingSlots: &pendingSlots,
                pendingQueue: &pendingQueue,
                into: &stack,
                mode: mode
            )
        }
    }

    private static func drainNextMetalFileTileWork(
        pendingSlots: inout [MetalFileTileWork?],
        pendingQueue: inout [MetalFileTileWork],
        into stack: inout BLAKE3Core.CVStack,
        mode: HashMode
    ) throws {
        guard !pendingQueue.isEmpty else {
            return
        }
        let tileWork = pendingQueue.removeFirst()
        pushMetalFileStackEntries(try tileWork.wait(), into: &stack, mode: mode)
        pendingSlots[tileWork.bufferIndex] = nil
    }
    #endif

    private struct MappedRegion {
        let pointer: UnsafeMutableRawPointer?
        let size: Int
    }

    private static func hashMappedRegion(
        _ region: MappedRegion,
        parallel: Bool,
        maxWorkers: Int?,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64,
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> [UInt8] {
        guard region.size > 0,
              let pointer = region.pointer
        else {
            return emptyOutput(mode: mode, outputByteCount: outputByteCount, seek: seek)
        }

        let regionBuffer = UnsafeRawBufferPointer(start: pointer, count: region.size)
        if parallel, region.size <= mappedParallelOneShotMaxByteCount {
            try cancellationCheck?()
            return hashCPU(
                regionBuffer,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                maxWorkers: maxWorkers
            )
        }

        if parallel {
            return try hashParallelTiledBuffer(
                regionBuffer,
                tileByteCount: mappedTileByteCount,
                maxWorkers: maxWorkers,
                mode: mode,
                outputByteCount: outputByteCount,
                seek: seek,
                cancellationCheck: cancellationCheck
            )
        }

        var hasher = BLAKE3.Hasher(key: mode.key, flags: mode.flags)
        var offset = 0
        while offset < region.size {
            try cancellationCheck?()
            let byteCount = min(mappedTileByteCount, region.size - offset)
            let tile = UnsafeRawBufferPointer(start: pointer.advanced(by: offset), count: byteCount)
            hasher.update(tile)
            offset += byteCount
        }
        return readOutput(from: hasher, outputByteCount: outputByteCount, seek: seek)
    }

    private static let mappedParallelOneShotMaxByteCount = 2 * 1024 * 1024 * 1024

    private static func hashParallelTiledBuffer(
        _ input: UnsafeRawBufferPointer,
        tileByteCount: Int,
        maxWorkers: Int?,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64,
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> [UInt8] {
        guard input.count > 0,
              let baseAddress = input.baseAddress
        else {
            return emptyOutput(mode: mode, outputByteCount: outputByteCount, seek: seek)
        }

        let alignedTileByteCount = max(
            BLAKE3.chunkByteCount,
            (max(tileByteCount, BLAKE3.chunkByteCount) / BLAKE3.chunkByteCount) * BLAKE3.chunkByteCount
        )
        var stack = BLAKE3Core.CVStack()
        var workspace = BLAKE3Core.Workspace()
        let scheduler = BLAKE3Core.defaultScheduler(forByteCount: input.count, maxWorkers: maxWorkers)
        var offset = 0

        while offset < input.count {
            try cancellationCheck?()
            let tileLength = min(alignedTileByteCount, input.count - offset)
            let isFinalTile = offset + tileLength == input.count
            let completeChunkByteCount = if isFinalTile {
                ((tileLength - 1) / BLAKE3.chunkByteCount) * BLAKE3.chunkByteCount
            } else {
                tileLength
            }

            if completeChunkByteCount > 0 {
                try pushCompleteCPUChunks(
                    buffer: input,
                    range: offset..<(offset + completeChunkByteCount),
                    baseChunkCounter: UInt64(offset / BLAKE3.chunkByteCount),
                    maxWorkers: maxWorkers,
                    scheduler: scheduler,
                    workspace: &workspace,
                    into: &stack,
                    mode: mode
                )
            }

            if isFinalTile {
                let currentChunkLength = tileLength - completeChunkByteCount
                let currentChunk = UnsafeRawBufferPointer(
                    start: baseAddress.advanced(by: offset + completeChunkByteCount),
                    count: currentChunkLength
                )
                let output = BLAKE3Core.chunkOutput(
                    currentChunk,
                    chunkCounter: stack.finalizedChunkCount,
                    key: mode.key,
                    flags: mode.flags
                )
                return stack.rootOutput(
                    currentChunkOutput: output,
                    key: mode.key,
                    flags: mode.flags
                )
                .rootBytes(byteCount: outputByteCount, seek: seek)
            }

            offset += tileLength
        }

        return emptyOutput(mode: mode, outputByteCount: outputByteCount, seek: seek)
    }

    private static func pushCompleteCPUChunks(
        buffer: UnsafeRawBufferPointer,
        range: Range<Int>,
        baseChunkCounter: UInt64,
        maxWorkers: Int?,
        scheduler: BLAKE3Core.ParallelScheduler?,
        workspace: inout BLAKE3Core.Workspace,
        into stack: inout BLAKE3Core.CVStack,
        mode: HashMode
    ) throws {
        let entries = try collectCompleteCPUChunkEntries(
            buffer: buffer,
            range: range,
            baseChunkCounter: baseChunkCounter,
            maxWorkers: maxWorkers,
            scheduler: scheduler,
            workspace: &workspace,
            mode: mode
        )
        pushCPUFileStackEntries(entries, into: &stack, mode: mode)
    }

    private static func collectCompleteCPUChunkEntries(
        buffer: UnsafeRawBufferPointer,
        range: Range<Int>,
        baseChunkCounter: UInt64,
        maxWorkers: Int?,
        scheduler: BLAKE3Core.ParallelScheduler?,
        workspace: inout BLAKE3Core.Workspace,
        mode: HashMode
    ) throws -> [CPUFileStackEntry] {
        guard range.count > 0 else {
            return []
        }
        guard let baseAddress = buffer.baseAddress,
              range.lowerBound >= 0,
              range.upperBound <= buffer.count,
              range.count.isMultiple(of: BLAKE3.chunkByteCount),
              baseChunkCounter <= UInt64(Int.max)
        else {
            throw BLAKE3Error.invalidBufferRange
        }

        var remainingChunkCount = range.count / BLAKE3.chunkByteCount
        var processedChunkCount = 0
        var entries = [CPUFileStackEntry]()
        entries.reserveCapacity(remainingChunkCount.nonzeroBitCount)
        while remainingChunkCount > 0 {
            let subtreeChunkCount = largestPowerOfTwo(notExceeding: remainingChunkCount)
            let subtreeLowerBound = range.lowerBound + processedChunkCount * BLAKE3.chunkByteCount
            let subtree = UnsafeRawBufferPointer(
                start: baseAddress.advanced(by: subtreeLowerBound),
                count: subtreeChunkCount * BLAKE3.chunkByteCount
            )
            let cv = BLAKE3Core.subtreeChainingValue(
                subtree,
                baseChunkCounter: Int(baseChunkCounter) + processedChunkCount,
                key: mode.key,
                flags: mode.flags,
                maxWorkers: maxWorkers,
                scheduler: scheduler,
                workspace: &workspace
            )
            entries.append(CPUFileStackEntry(cv: cv, chunkCount: subtreeChunkCount))
            processedChunkCount += subtreeChunkCount
            remainingChunkCount -= subtreeChunkCount
        }
        return entries
    }

    private static func pushCPUFileStackEntries(
        _ entries: [CPUFileStackEntry],
        into stack: inout BLAKE3Core.CVStack,
        mode: HashMode
    ) {
        for entry in entries {
            stack.pushSubtreeCV(
                entry.cv,
                chunkCount: UInt64(entry.chunkCount),
                key: mode.key,
                flags: mode.flags
            )
        }
    }

    private static func largestPowerOfTwo(notExceeding value: Int) -> Int {
        precondition(value > 0)
        return 1 << (Int.bitWidth - value.leadingZeroBitCount - 1)
    }

    private static func configuredReadInflightCount() -> Int {
        // The CPU file path overlaps one read with one subtree reduction worker. Higher values only add
        // buffer churn because this implementation does not schedule multiple independent CPU tile workers.
        guard let rawValue = ProcessInfo.processInfo
            .environment["BLAKE3_SWIFT_READ_INFLIGHT"],
              let parsed = Int(rawValue)
        else {
            return 2
        }
        return min(max(parsed, 1), 2)
    }

    private static func validateOutput(outputByteCount: Int, seek: UInt64) throws {
        guard outputByteCount >= 0 else {
            throw BLAKE3Error.invalidOutputLength(outputByteCount)
        }
        guard UInt64.max - seek >= UInt64(outputByteCount) else {
            throw BLAKE3Error.metalCommandFailed("BLAKE3 XOF output range overflows UInt64.")
        }
    }

    private static func digest(from output: [UInt8]) throws -> BLAKE3.Digest {
        guard output.count == BLAKE3.digestByteCount else {
            throw BLAKE3Error.invalidOutputLength(output.count)
        }
        return BLAKE3.Digest(output)
    }

    private static func keyedMode(_ keyBytes: UnsafeRawBufferPointer) throws -> HashMode {
        guard keyBytes.count == BLAKE3.keyByteCount else {
            throw BLAKE3Error.invalidKeyLength(
                expected: BLAKE3.keyByteCount,
                actual: keyBytes.count
            )
        }
        return HashMode(key: BLAKE3Core.keyedWords(keyBytes), flags: BLAKE3Core.keyedHash)
    }

    private static func deriveKeyMaterialMode(context: String) -> HashMode {
        let contextBytes = Array(context.utf8)
        return contextBytes.withUnsafeBytes { contextRaw in
            HashMode(
                key: BLAKE3Core.deriveKeyContextKey(contextRaw),
                flags: BLAKE3Core.deriveKeyMaterial
            )
        }
    }

    private static func emptyOutput(mode: HashMode, outputByteCount: Int, seek: UInt64) -> [UInt8] {
        let empty = UnsafeRawBufferPointer(start: nil, count: 0)
        return BLAKE3Core
            .chunkOutput(empty, chunkCounter: 0, key: mode.key, flags: mode.flags)
            .rootBytes(byteCount: outputByteCount, seek: seek)
    }

    private static func hashCPU(
        _ input: UnsafeRawBufferPointer,
        mode: HashMode,
        outputByteCount: Int,
        seek: UInt64,
        maxWorkers: Int?
    ) -> [UInt8] {
        var workspace = BLAKE3Core.Workspace()
        let output = BLAKE3Core.rootOutputParallel(
            input,
            key: mode.key,
            flags: mode.flags,
            maxWorkers: maxWorkers,
            workspace: &workspace
        )
        return output.rootBytes(byteCount: outputByteCount, seek: seek)
    }

    private static func readOutput(
        from hasher: BLAKE3.Hasher,
        outputByteCount: Int,
        seek: UInt64
    ) -> [UInt8] {
        var reader = hasher.finalizeXOF()
        reader.seek(to: seek)
        var output = [UInt8](repeating: 0, count: outputByteCount)
        output.withUnsafeMutableBytes { rawOutput in
            reader.read(into: rawOutput)
        }
        return output
    }

    private struct CPUFileStackEntry {
        var cv: BLAKE3Core.ChainingValue
        var chunkCount: Int
    }

    private final class CPUFileTileWork: @unchecked Sendable {
        private let semaphore = DispatchSemaphore(value: 0)
        private var result: Result<[CPUFileStackEntry], Error>?

        func complete(_ result: Result<[CPUFileStackEntry], Error>) {
            self.result = result
            semaphore.signal()
        }

        func wait() throws -> [CPUFileStackEntry] {
            semaphore.wait()
            guard let result else {
                throw BLAKE3Error.fileReadFailed("CPU read tile work finished without a result.")
            }
            return try result.get()
        }
    }

    private struct CPUFileBufferReference: @unchecked Sendable {
        let pointer: UnsafeMutableRawPointer
        let byteCount: Int
    }

    private final class CPUFileTileWorker: @unchecked Sendable {
        private let queue = DispatchQueue(label: "org.blake3swift.cpu-read")
        private let scheduler: BLAKE3Core.ParallelScheduler?
        private let mode: HashMode
        private var workspace = BLAKE3Core.Workspace()

        init(scheduler: BLAKE3Core.ParallelScheduler?, mode: HashMode) {
            self.scheduler = scheduler
            self.mode = mode
        }

        func start(
            buffer: UnsafeMutableRawPointer,
            byteCount: Int,
            baseChunkCounter: UInt64
        ) -> CPUFileTileWork {
            let work = CPUFileTileWork()
            let bufferReference = CPUFileBufferReference(pointer: buffer, byteCount: byteCount)
            queue.async {
                do {
                    let entries = try collectCompleteCPUChunkEntries(
                        buffer: UnsafeRawBufferPointer(
                            start: bufferReference.pointer,
                            count: bufferReference.byteCount
                        ),
                        range: 0..<bufferReference.byteCount,
                        baseChunkCounter: baseChunkCounter,
                        maxWorkers: nil,
                        scheduler: self.scheduler,
                        workspace: &self.workspace,
                        mode: self.mode
                    )
                    work.complete(.success(entries))
                } catch {
                    work.complete(.failure(error))
                }
            }
            return work
        }
    }

    private static func readExactly(
        fd: Int32,
        into pointer: UnsafeMutableRawPointer,
        byteCount: Int,
        path: String
    ) throws {
        var offset = 0
        while offset < byteCount {
            let readCount = Darwin.read(fd, pointer.advanced(by: offset), byteCount - offset)
            if readCount > 0 {
                offset += readCount
            } else if readCount == 0 {
                throw BLAKE3Error.fileReadFailed(path)
            } else if errno == EINTR {
                continue
            } else {
                throw BLAKE3Error.fileReadFailed(path)
            }
        }
    }

    private static func enableReadAhead(fd: Int32) {
        #if canImport(Darwin)
        _ = fcntl(fd, F_RDAHEAD, 1)
        #endif
    }

    private static func withMappedRegion<R>(
        path: String,
        _ body: (MappedRegion) throws -> R
    ) throws -> R {
        let fd = open(path, O_RDONLY)
        guard fd >= 0 else {
            throw BLAKE3Error.fileOpenFailed(path)
        }
        defer { close(fd) }

        var info = stat()
        guard fstat(fd, &info) == 0 else {
            throw BLAKE3Error.fileStatFailed(path)
        }

        guard isRegularFile(mode: info.st_mode) else {
            throw BLAKE3Error.memoryMapFailed(path)
        }
        guard info.st_size >= 0,
              info.st_size <= off_t(Int.max)
        else {
            throw BLAKE3Error.memoryMapFailed(path)
        }
        let size = Int(info.st_size)
        guard size > 0 else {
            return try body(MappedRegion(pointer: nil, size: 0))
        }

        let pointer = mmap(nil, size, PROT_READ, MAP_PRIVATE, fd, 0)
        guard let pointer,
              pointer != MAP_FAILED
        else {
            throw BLAKE3Error.memoryMapFailed(path)
        }
        defer { munmap(pointer, size) }

        return try body(MappedRegion(pointer: pointer, size: size))
    }

    private static func withMappedRegionAsync<R>(
        path: String,
        _ body: (MappedRegion) async throws -> R
    ) async throws -> R {
        try Task.checkCancellation()
        let fd = open(path, O_RDONLY)
        guard fd >= 0 else {
            throw BLAKE3Error.fileOpenFailed(path)
        }
        defer { close(fd) }

        var info = stat()
        guard fstat(fd, &info) == 0 else {
            throw BLAKE3Error.fileStatFailed(path)
        }

        guard isRegularFile(mode: info.st_mode) else {
            throw BLAKE3Error.memoryMapFailed(path)
        }
        guard info.st_size >= 0,
              info.st_size <= off_t(Int.max)
        else {
            throw BLAKE3Error.memoryMapFailed(path)
        }
        let size = Int(info.st_size)
        guard size > 0 else {
            return try await body(MappedRegion(pointer: nil, size: 0))
        }

        let pointer = mmap(nil, size, PROT_READ, MAP_PRIVATE, fd, 0)
        guard let pointer,
              pointer != MAP_FAILED
        else {
            throw BLAKE3Error.memoryMapFailed(path)
        }
        defer { munmap(pointer, size) }

        try Task.checkCancellation()
        return try await body(MappedRegion(pointer: pointer, size: size))
    }

    private static func isRegularFile(mode: mode_t) -> Bool {
        (mode & S_IFMT) == S_IFREG
    }

    #if canImport(Metal)
    private static func pushChunkChainingValues(
        _ chunkCVBuffer: BLAKE3Metal.ChunkChainingValueBuffer,
        chunkCount: Int,
        into stack: inout BLAKE3Core.CVStack,
        mode: HashMode
    ) throws {
        try chunkCVBuffer.withUnsafeBytes { raw in
            guard raw.count >= chunkCount * BLAKE3.digestByteCount else {
                throw BLAKE3Error.metalCommandFailed("Metal chunk chaining value output is shorter than expected.")
            }
            for chunkIndex in 0..<chunkCount {
                let offset = chunkIndex * BLAKE3.digestByteCount
                let cv = BLAKE3Core.chainingValue(from: raw, atByteOffset: offset)
                stack.pushChunkCV(cv, key: mode.key, flags: mode.flags)
            }
        }
    }

    private static func pushCompleteMetalChunks(
        context: BLAKE3Metal.Context,
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        chunkCVBuffer: BLAKE3Metal.ChunkChainingValueBuffer,
        subtreeDecompositionChunkThreshold: Int,
        into stack: inout BLAKE3Core.CVStack,
        mode: HashMode
    ) throws {
        let entries = try collectCompleteMetalChunkEntries(
            context: context,
            buffer: buffer,
            range: range,
            chunkCount: chunkCount,
            baseChunkCounter: stack.finalizedChunkCount,
            chunkCVBuffer: chunkCVBuffer,
            subtreeDecompositionChunkThreshold: subtreeDecompositionChunkThreshold,
            mode: mode
        )
        pushMetalFileStackEntries(entries, into: &stack, mode: mode)
    }

    private static func collectCompleteMetalChunkEntries(
        context: BLAKE3Metal.Context,
        buffer: MTLBuffer,
        range: Range<Int>,
        chunkCount: Int,
        baseChunkCounter: UInt64,
        chunkCVBuffer: BLAKE3Metal.ChunkChainingValueBuffer,
        subtreeDecompositionChunkThreshold: Int,
        mode: HashMode
    ) throws -> [MetalFileStackEntry] {
        guard chunkCount > 0 else {
            return []
        }
        guard range.count == chunkCount * BLAKE3.chunkByteCount else {
            throw BLAKE3Error.invalidBufferRange
        }

        if chunkCount.nonzeroBitCount == 1 || chunkCount >= subtreeDecompositionChunkThreshold {
            var entries = [MetalFileStackEntry]()
            entries.reserveCapacity(chunkCount.nonzeroBitCount)
            var remainingChunkCount = chunkCount
            var processedChunkCount = 0
            while remainingChunkCount > 0 {
                let subtreeChunkCount = largestPowerOfTwo(notExceeding: remainingChunkCount)
                let subtreeLowerBound = range.lowerBound + processedChunkCount * BLAKE3.chunkByteCount
                let subtreeRange = subtreeLowerBound..<(subtreeLowerBound + subtreeChunkCount * BLAKE3.chunkByteCount)
                let cv = try context.chunkSubtreeChainingValue(
                    buffer: buffer,
                    range: subtreeRange,
                    baseChunkCounter: baseChunkCounter + UInt64(processedChunkCount),
                    mode: mode.metalMode
                )
                entries.append(MetalFileStackEntry(cv: cv, chunkCount: subtreeChunkCount))
                processedChunkCount += subtreeChunkCount
                remainingChunkCount -= subtreeChunkCount
            }
            return entries
        }

        let writtenChunkCount = try context.writeChunkChainingValues(
            buffer: buffer,
            range: range,
            baseChunkCounter: baseChunkCounter,
            into: chunkCVBuffer,
            mode: mode.metalMode
        )
        var entries = [MetalFileStackEntry]()
        entries.reserveCapacity(writtenChunkCount)
        try chunkCVBuffer.withUnsafeBytes { raw in
            guard raw.count >= writtenChunkCount * BLAKE3.digestByteCount else {
                throw BLAKE3Error.metalCommandFailed("Metal chunk chaining value output is shorter than expected.")
            }
            for chunkIndex in 0..<writtenChunkCount {
                let offset = chunkIndex * BLAKE3.digestByteCount
                let cv = BLAKE3Core.chainingValue(from: raw, atByteOffset: offset)
                entries.append(MetalFileStackEntry(cv: cv, chunkCount: 1))
            }
        }
        return entries
    }

    private static func pushMetalFileStackEntries(
        _ entries: [MetalFileStackEntry],
        into stack: inout BLAKE3Core.CVStack,
        mode: HashMode
    ) {
        for entry in entries {
            stack.pushSubtreeCV(
                entry.cv,
                chunkCount: UInt64(entry.chunkCount),
                key: mode.key,
                flags: mode.flags
            )
        }
    }

    private static let metalMappedSubtreeDecompositionChunkThreshold = 8 * 1_024
    private static let metalStagedReadSubtreeDecompositionChunkThreshold = 32 * 1_024
    #endif
}
