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
    /// Default tile size used by mapped CPU and tiled Metal file paths.
    public static let mappedTileByteCount = 16 * 1024 * 1024

    /// File hashing strategy.
    public enum Strategy: Equatable, Sendable {
        /// Chooses the bounded memory-mapped CPU path with read fallback.
        case automatic
        /// Streams the file through a reusable read buffer.
        case read(bufferSize: Int = 64 * 1024)
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
            tileByteCount: Int = BLAKE3File.mappedTileByteCount,
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
        try hash(path: path, strategy: strategy, cancellationCheck: nil)
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
                librarySource: librarySource
            )
        }
        if case let .metalTiledMemoryMapped(tileByteCount, fallbackToCPU, librarySource) = strategy {
            return try await hashMetalTiledMappedAsync(
                path: path,
                tileByteCount: tileByteCount,
                fallbackToCPU: fallbackToCPU,
                librarySource: librarySource
            )
        }
        #endif
        return try await Task.detached {
            try hash(
                path: path,
                strategy: strategy,
                cancellationCheck: { try Task.checkCancellation() }
            )
        }.value
    }

    private static func hash(
        path: String,
        strategy: Strategy,
        cancellationCheck: (() throws -> Void)?
    ) throws -> BLAKE3.Digest {
        try cancellationCheck?()
        switch strategy {
        case .automatic:
            return try hashMapped(
                path: path,
                fallbackToRead: true,
                parallel: true,
                cancellationCheck: cancellationCheck
            )
        case let .read(bufferSize):
            return try hashRead(path: path, bufferSize: bufferSize, cancellationCheck: cancellationCheck)
        case .memoryMapped:
            return try hashMapped(
                path: path,
                fallbackToRead: false,
                parallel: false,
                cancellationCheck: cancellationCheck
            )
        case let .memoryMappedParallel(maxThreads):
            return try hashMapped(
                path: path,
                fallbackToRead: true,
                parallel: true,
                maxWorkers: maxThreads,
                cancellationCheck: cancellationCheck
            )
        #if canImport(Metal)
        case let .metalMemoryMapped(policy, fallbackToCPU, librarySource):
            return try hashMetalMapped(
                path: path,
                policy: policy,
                fallbackToCPU: fallbackToCPU,
                librarySource: librarySource,
                cancellationCheck: cancellationCheck
            )
        case let .metalTiledMemoryMapped(tileByteCount, fallbackToCPU, librarySource):
            return try hashMetalTiledMapped(
                path: path,
                tileByteCount: tileByteCount,
                fallbackToCPU: fallbackToCPU,
                librarySource: librarySource,
                cancellationCheck: cancellationCheck
            )
        #endif
        }
    }

    private static func hashRead(
        path: String,
        bufferSize: Int,
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> BLAKE3.Digest {
        try cancellationCheck?()
        let fd = open(path, O_RDONLY)
        guard fd >= 0 else {
            throw BLAKE3Error.fileOpenFailed(path)
        }
        defer { close(fd) }

        let clampedBufferSize = max(bufferSize, 1)
        let buffer = UnsafeMutableRawPointer.allocate(
            byteCount: clampedBufferSize,
            alignment: MemoryLayout<UInt64>.alignment
        )
        defer { buffer.deallocate() }

        var hasher = BLAKE3.Hasher()
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
        return hasher.finalize()
    }

    private static func hashMapped(
        path: String,
        fallbackToRead: Bool,
        parallel: Bool = false,
        maxWorkers: Int? = nil,
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> BLAKE3.Digest {
        do {
            return try withMappedRegion(path: path) { region in
                try cancellationCheck?()
                return try hashMappedRegion(
                    region,
                    parallel: parallel,
                    maxWorkers: maxWorkers,
                    cancellationCheck: cancellationCheck
                )
            }
        } catch {
            if fallbackToRead {
                return try hashRead(
                    path: path,
                    bufferSize: 64 * 1024,
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
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> BLAKE3.Digest {
        do {
            try cancellationCheck?()
            guard let device = MTLCreateSystemDefaultDevice() else {
                throw BLAKE3Error.metalUnavailable
            }
            return try withMappedRegion(path: path) { region in
                try cancellationCheck?()
                guard region.size > 0,
                      let pointer = region.pointer
                else {
                    return BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
                }
                guard let buffer = device.makeBuffer(
                    bytesNoCopy: pointer,
                    length: region.size,
                    options: .storageModeShared,
                    deallocator: nil
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to wrap mapped file pages in a Metal buffer.")
                }
                return try BLAKE3Metal
                    .makeContext(device: device, librarySource: librarySource)
                    .hash(buffer: buffer, length: region.size, policy: policy)
            }
        } catch let error as CancellationError {
            throw error
        } catch {
            if fallbackToCPU {
                return try hashMapped(
                    path: path,
                    fallbackToRead: true,
                    parallel: true,
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
        librarySource: BLAKE3Metal.LibrarySource
    ) async throws -> BLAKE3.Digest {
        do {
            try Task.checkCancellation()
            guard let device = MTLCreateSystemDefaultDevice() else {
                throw BLAKE3Error.metalUnavailable
            }
            let context = try BLAKE3Metal.makeContext(device: device, librarySource: librarySource)
            return try await withMappedRegionAsync(path: path) { region in
                try Task.checkCancellation()
                guard region.size > 0,
                      let pointer = region.pointer
                else {
                    return BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
                }
                guard let buffer = device.makeBuffer(
                    bytesNoCopy: pointer,
                    length: region.size,
                    options: .storageModeShared,
                    deallocator: nil
                ) else {
                    throw BLAKE3Error.metalCommandFailed("Unable to wrap mapped file pages in a Metal buffer.")
                }
                return try await context.hashAsync(buffer: buffer, length: region.size, policy: policy)
            }
        } catch let error as CancellationError {
            throw error
        } catch {
            if fallbackToCPU {
                return try await Task.detached {
                    try hashMapped(
                        path: path,
                        fallbackToRead: true,
                        parallel: true,
                        cancellationCheck: { try Task.checkCancellation() }
                    )
                }.value
            }
            throw error
        }
    }

    private static func hashMetalTiledMappedAsync(
        path: String,
        tileByteCount: Int,
        fallbackToCPU: Bool,
        librarySource: BLAKE3Metal.LibrarySource
    ) async throws -> BLAKE3.Digest {
        do {
            try Task.checkCancellation()
            guard let device = MTLCreateSystemDefaultDevice() else {
                throw BLAKE3Error.metalUnavailable
            }
            let alignedTileByteCount = alignedMetalTileByteCount(tileByteCount)
            let tileChunkCapacity = max(1, alignedTileByteCount / BLAKE3.chunkByteCount)
            let context = try BLAKE3Metal.makeContext(device: device, librarySource: librarySource)
            let chunkCVBuffer = try context.makeChunkChainingValueBuffer(chunkCapacity: tileChunkCapacity)

            return try await withMappedRegionAsync(path: path) { region in
                try Task.checkCancellation()
                guard region.size > 0,
                      let pointer = region.pointer
                else {
                    return BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
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
                        let chunkCount = try await context.writeChunkChainingValuesAsync(
                            buffer: fileBuffer,
                            range: offset..<(offset + completeChunkByteCount),
                            baseChunkCounter: stack.finalizedChunkCount,
                            into: chunkCVBuffer
                        )
                        try Task.checkCancellation()
                        try pushChunkChainingValues(
                            chunkCVBuffer,
                            chunkCount: chunkCount,
                            into: &stack
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
                            key: BLAKE3Core.iv,
                            flags: 0
                        )
                        return BLAKE3.Digest(
                            stack.rootOutput(
                                currentChunkOutput: output,
                                key: BLAKE3Core.iv,
                                flags: 0
                            )
                            .rootBytes(byteCount: BLAKE3.digestByteCount)
                        )
                    }
                }

                return BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
            }
        } catch let error as CancellationError {
            throw error
        } catch {
            if fallbackToCPU {
                return try await Task.detached {
                    try hashMapped(
                        path: path,
                        fallbackToRead: true,
                        parallel: true,
                        cancellationCheck: { try Task.checkCancellation() }
                    )
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
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> BLAKE3.Digest {
        do {
            try cancellationCheck?()
            guard let device = MTLCreateSystemDefaultDevice() else {
                throw BLAKE3Error.metalUnavailable
            }
            let alignedTileByteCount = alignedMetalTileByteCount(tileByteCount)
            let tileChunkCapacity = max(1, alignedTileByteCount / BLAKE3.chunkByteCount)
            let context = try BLAKE3Metal.makeContext(device: device, librarySource: librarySource)
            let chunkCVBuffer = try context.makeChunkChainingValueBuffer(chunkCapacity: tileChunkCapacity)

            return try withMappedRegion(path: path) { region in
                try cancellationCheck?()
                guard region.size > 0,
                      let pointer = region.pointer
                else {
                    return BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
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
                        let chunkCount = try context.writeChunkChainingValues(
                            buffer: fileBuffer,
                            range: offset..<(offset + completeChunkByteCount),
                            baseChunkCounter: stack.finalizedChunkCount,
                            into: chunkCVBuffer
                        )
                        try pushChunkChainingValues(
                            chunkCVBuffer,
                            chunkCount: chunkCount,
                            into: &stack
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
                            key: BLAKE3Core.iv,
                            flags: 0
                        )
                        return BLAKE3.Digest(
                            stack.rootOutput(
                                currentChunkOutput: output,
                                key: BLAKE3Core.iv,
                                flags: 0
                            )
                            .rootBytes(byteCount: BLAKE3.digestByteCount)
                        )
                    }
                }

                return BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
            }
        } catch let error as CancellationError {
            throw error
        } catch {
            if fallbackToCPU {
                return try hashMapped(
                    path: path,
                    fallbackToRead: true,
                    parallel: true,
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
    #endif

    private struct MappedRegion {
        let pointer: UnsafeMutableRawPointer?
        let size: Int
    }

    private static func hashMappedRegion(
        _ region: MappedRegion,
        parallel: Bool,
        maxWorkers: Int?,
        cancellationCheck: (() throws -> Void)? = nil
    ) throws -> BLAKE3.Digest {
        guard region.size > 0,
              let pointer = region.pointer
        else {
            return BLAKE3.hash(UnsafeRawBufferPointer(start: nil, count: 0))
        }

        var hasher = BLAKE3.Hasher()
        var offset = 0
        while offset < region.size {
            try cancellationCheck?()
            let byteCount = min(mappedTileByteCount, region.size - offset)
            let tile = UnsafeRawBufferPointer(start: pointer.advanced(by: offset), count: byteCount)
            if parallel {
                if offset + byteCount < region.size {
                    hasher._updateParallelNonFinal(tile, maxWorkers: maxWorkers)
                } else {
                    hasher.updateParallel(tile, maxWorkers: maxWorkers)
                }
            } else {
                hasher.update(tile)
            }
            offset += byteCount
        }
        return hasher.finalize()
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
        into stack: inout BLAKE3Core.CVStack
    ) throws {
        try chunkCVBuffer.withUnsafeBytes { raw in
            guard raw.count >= chunkCount * BLAKE3.digestByteCount else {
                throw BLAKE3Error.metalCommandFailed("Metal chunk chaining value output is shorter than expected.")
            }
            for chunkIndex in 0..<chunkCount {
                let offset = chunkIndex * BLAKE3.digestByteCount
                let cv = BLAKE3Core.chainingValue(from: raw, atByteOffset: offset)
                stack.pushChunkCV(cv, key: BLAKE3Core.iv, flags: 0)
            }
        }
    }
    #endif
}
