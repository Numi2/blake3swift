import Blake3
import Foundation
#if canImport(Metal)
import Metal
#endif

@main
struct Blake3Examples {
    static func main() async throws {
        let command = CommandLine.arguments.dropFirst().first ?? "all"

        switch command {
        case "all":
            try await oneShot()
            try await streaming()
            try await keyedAndXOF()
            try await cpuFile()
            try await metalResident()
            try await asyncPipeline()
            try await tiledFile()
        case "one-shot":
            try await oneShot()
        case "streaming":
            try await streaming()
        case "keyed-xof":
            try await keyedAndXOF()
        case "cpu-file":
            try await cpuFile()
        case "metal-resident":
            try await metalResident()
        case "async-pipeline":
            try await asyncPipeline()
        case "tiled-file":
            try await tiledFile()
        default:
            print("usage: swift run Blake3Examples [all|one-shot|streaming|keyed-xof|cpu-file|metal-resident|async-pipeline|tiled-file]")
        }
    }

    private static func oneShot() async throws {
        let digest = BLAKE3.hash(Data("hello".utf8))
        print("one-shot \(digest)")
    }

    private static func streaming() async throws {
        var hasher = BLAKE3.Hasher()
        hasher.update(Data("hello ".utf8))
        hasher.update(Data("world".utf8))
        print("streaming \(hasher.finalize())")
    }

    private static func keyedAndXOF() async throws {
        let key = Data(repeating: 7, count: BLAKE3.keyByteCount)
        let digest = try BLAKE3.keyedHash(key: key, input: Data("message".utf8))

        var hasher = BLAKE3.Hasher()
        hasher.update(Data("material".utf8))
        var reader = hasher.finalizeXOF()
        var output = [UInt8](repeating: 0, count: 64)
        output.withUnsafeMutableBytes { reader.read(into: $0) }

        print("keyed \(digest)")
        print("xof64 \(output.map { String(format: "%02x", $0) }.joined())")
    }

    private static func cpuFile() async throws {
        let url = try makeExampleFile()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let digest = try BLAKE3File.hash(path: url.path, strategy: .memoryMappedParallel())
        print("cpu-file \(digest)")
    }

    private static func metalResident() async throws {
        #if canImport(Metal)
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("metal-resident unavailable")
            return
        }
        let input = Data(repeating: 0x42, count: 16 * 1024 * 1024)
        guard let buffer = input.withUnsafeBytes({
            $0.baseAddress.map {
                device.makeBuffer(bytes: $0, length: input.count, options: .storageModeShared)
            } ?? nil
        }) else {
            print("metal-resident buffer allocation failed")
            return
        }
        let context = try BLAKE3Metal.makeContext(device: device)
        let digest = try context.hash(buffer: buffer, length: input.count, policy: .gpu)
        print("metal-resident \(digest)")
        #else
        print("metal-resident unavailable")
        #endif
    }

    private static func asyncPipeline() async throws {
        #if canImport(Metal)
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("async-pipeline unavailable")
            return
        }
        let context = try BLAKE3Metal.makeContext(device: device)
        let pipeline = try context.makeAsyncPipeline(
            inputCapacity: 16 * 1024 * 1024,
            inFlightCount: 3,
            policy: .gpu,
            usesPrivateBuffers: true
        )
        let input = Data(repeating: 0x33, count: 16 * 1024 * 1024)
        let digest = try await pipeline.hash(input: input)
        print("async-pipeline \(digest)")
        #else
        print("async-pipeline unavailable")
        #endif
    }

    private static func tiledFile() async throws {
        #if canImport(Metal)
        let url = try makeExampleFile(byteCount: 32 * 1024 * 1024 + 333)
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        let digest = try await BLAKE3File.hashAsync(
            path: url.path,
            strategy: .metalTiledMemoryMapped(tileByteCount: 4 * 1024 * 1024)
        )
        print("tiled-file \(digest)")
        #else
        print("tiled-file unavailable")
        #endif
    }

    private static func makeExampleFile(byteCount: Int = 2 * 1024 * 1024 + 333) throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("blake3swift-examples-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("input.bin")
        var input = [UInt8](repeating: 0, count: byteCount)
        for index in input.indices {
            input[index] = UInt8(truncatingIfNeeded: index &* 31 &+ 17)
        }
        try Data(input).write(to: url, options: .atomic)
        return url
    }
}
