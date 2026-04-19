import Blake3
import Darwin
import Foundation
#if canImport(Metal)
import Metal
#endif

@main
struct Blake3Examples {
    private static let mebibyte = 1024 * 1024

    private static let commands: [(name: String, summary: String)] = [
        ("all", "Run every sample, skipping Metal work when no Metal device is available."),
        ("backend-info", "Print the default backend policy, CPU backend, worker count, and Metal availability."),
        ("one-shot", "Hash a small buffer with automatic, CPU-only, and serial CPU paths."),
        ("streaming", "Hash the same message through incremental updates."),
        ("keyed", "Compute a keyed 32-byte digest."),
        ("derive-key", "Derive 64 bytes of key material from a context string and input material."),
        ("xof", "Read 64 bytes from BLAKE3 extendable output."),
        ("context", "Reuse a CPU context across multiple hashes."),
        ("file [path]", "Hash a file with the CPU memory-mapped parallel strategy."),
        ("metal-resident", "Hash a resident shared Metal buffer."),
        ("async-pipeline", "Hash Swift-owned input through a reusable Metal async pipeline."),
        ("tiled-file [path]", "Hash a file with tiled Metal memory mapping.")
    ]

    static func main() async {
        do {
            let arguments = Array(CommandLine.arguments.dropFirst())
            let command = arguments.first?.lowercased() ?? "help"
            let commandArguments = Array(arguments.dropFirst())
            try await run(command: command, arguments: commandArguments)
        } catch {
            writeError("error: \(error)")
            exit(1)
        }
    }

    private static func run(command: String, arguments: [String]) async throws {
        switch command {
        case "all":
            try await runAll()
        case "backend-info":
            backendInfo()
        case "one-shot":
            oneShot()
        case "streaming":
            streaming()
        case "keyed":
            try keyed()
        case "derive-key":
            try deriveKey()
        case "xof":
            xof()
        case "context":
            reusableContext()
        case "file", "cpu-file":
            try cpuFile(path: arguments.first)
        case "metal-resident":
            try metalResident()
        case "async-pipeline":
            try await asyncPipeline()
        case "tiled-file":
            try await tiledFile(path: arguments.first)
        case "help", "--help", "-h":
            printUsage()
        default:
            printUsage()
            throw ExampleFailure("Unknown command: \(command)")
        }
    }

    private static func runAll() async throws {
        section("backend-info")
        backendInfo()

        section("one-shot")
        oneShot()

        section("streaming")
        streaming()

        section("keyed")
        try keyed()

        section("derive-key")
        try deriveKey()

        section("xof")
        xof()

        section("context")
        reusableContext()

        section("file")
        try cpuFile(path: nil)

        section("metal-resident")
        try metalResident()

        section("async-pipeline")
        try await asyncPipeline()

        section("tiled-file")
        try await tiledFile(path: nil)
    }

    private static func printUsage() {
        print(
            """
            usage: swift run --package-path Examples Blake3Examples <command> [arguments]

            Commands:
            """
        )
        for command in commands {
            print("  \(command.name.padding(toLength: 20, withPad: " ", startingAt: 0)) \(command.summary)")
        }
    }

    private static func backendInfo() {
        print("backend policy \(BLAKE3.defaultBackendPolicy.rawValue)")
        print("active CPU backend \(BLAKE3.activeBackend.rawValue)")
        print("default CPU workers \(BLAKE3.defaultParallelWorkerCount)")
        print("default Metal threshold \(formatBytes(BLAKE3.defaultMetalMinimumByteCount))")
        #if canImport(Metal)
        let metalStatus = BLAKE3Metal.isAvailable
            ? "available (\(BLAKE3Metal.deviceName ?? "unknown device"))"
            : "unavailable"
        print("metal \(metalStatus)")
        #else
        print("metal unavailable")
        #endif
    }

    private static func oneShot() {
        let input = Data("hello".utf8)
        let automatic = BLAKE3.hash(input)
        let cpu = BLAKE3.hashCPU(input)
        let serial = BLAKE3.hashSerial(input)

        print("input \"hello\"")
        print("automatic \(automatic)")
        print("cpu       \(cpu)")
        print("serial    \(serial)")
        print("automatic-matches-cpu \(automatic.constantTimeEquals(cpu))")
    }

    private static func streaming() {
        var hasher = BLAKE3.Hasher()
        hasher.update(Data("hello ".utf8))
        hasher.update(Data("world".utf8))
        let digest = hasher.finalize()

        print("chunks [\"hello \", \"world\"]")
        print("streaming \(digest)")
        print("one-shot  \(BLAKE3.hash(Data("hello world".utf8)))")
    }

    private static func keyed() throws {
        let key = Data((0..<BLAKE3.keyByteCount).map { UInt8(truncatingIfNeeded: $0) })
        let digest = try BLAKE3.keyedHash(key: key, input: Data("message".utf8))

        print("key bytes \(BLAKE3.keyByteCount)")
        print("keyed \(digest)")
    }

    private static func deriveKey() throws {
        let material = Data("session:alice@example.com".utf8)
        let output = try BLAKE3.deriveKey(
            context: "com.example.blake3swift.examples.derive-key.v1",
            material: material,
            outputByteCount: 64
        )

        print("derive-key bytes \(output.count)")
        print(hex(output))
    }

    private static func xof() {
        var hasher = BLAKE3.Hasher()
        hasher.update(Data("material".utf8))
        var reader = hasher.finalizeXOF()
        var output = [UInt8](repeating: 0, count: 64)
        output.withUnsafeMutableBytes { reader.read(into: $0) }

        print("xof bytes \(output.count)")
        print(hex(output))
    }

    private static func reusableContext() {
        let context = BLAKE3.Context(maxWorkers: min(4, BLAKE3.defaultParallelWorkerCount))
        let first = context.hash(Data("first reusable context message".utf8))
        let second = context.hash(Data("second reusable context message".utf8))

        print("context workers \(context.maxWorkers)")
        print("first  \(first)")
        print("second \(second)")
    }

    private static func cpuFile(path: String?) throws {
        let exampleFile = try inputFile(path: path, byteCount: 2 * mebibyte + 333)
        defer { exampleFile.cleanup() }

        let digest = try BLAKE3File.hash(path: exampleFile.url.path, strategy: .memoryMappedParallel())
        print("file \(exampleFile.url.path)")
        print("strategy memoryMappedParallel")
        print("cpu-file \(digest)")
    }

    private static func metalResident() throws {
        #if canImport(Metal)
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("metal-resident skipped: no Metal device")
            return
        }
        let input = patternData(byteCount: 8 * mebibyte, seed: 0x42)
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
        let cpuDigest = BLAKE3.hashCPU(input)
        print("bytes \(formatBytes(input.count))")
        print("metal-resident \(digest)")
        print("matches-cpu \(digest.constantTimeEquals(cpuDigest))")
        #else
        print("metal-resident skipped: Metal is not available for this build")
        #endif
    }

    private static func asyncPipeline() async throws {
        #if canImport(Metal)
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("async-pipeline skipped: no Metal device")
            return
        }
        let input = patternData(byteCount: 8 * mebibyte, seed: 0x33)
        let context = try BLAKE3Metal.makeContext(device: device)
        let pipeline = try context.makeAsyncPipeline(
            inputCapacity: input.count,
            inFlightCount: 3,
            policy: .gpu,
            usesPrivateBuffers: true
        )
        let digest = try await pipeline.hash(input: input)
        let cpuDigest = BLAKE3.hashCPU(input)
        print("bytes \(formatBytes(input.count))")
        print("in-flight \(pipeline.inFlightCount)")
        print("private-buffers \(pipeline.usesPrivateBuffers)")
        print("async-pipeline \(digest)")
        print("matches-cpu \(digest.constantTimeEquals(cpuDigest))")
        #else
        print("async-pipeline skipped: Metal is not available for this build")
        #endif
    }

    private static func tiledFile(path: String?) async throws {
        #if canImport(Metal)
        guard BLAKE3Metal.isAvailable else {
            print("tiled-file skipped: no Metal device")
            return
        }
        let exampleFile = try inputFile(path: path, byteCount: 8 * mebibyte + 333)
        defer { exampleFile.cleanup() }

        let digest = try await BLAKE3File.hashAsync(
            path: exampleFile.url.path,
            strategy: .metalTiledMemoryMapped(tileByteCount: 4 * mebibyte)
        )
        let cpuDigest = try BLAKE3File.hash(path: exampleFile.url.path, strategy: .memoryMappedParallel())
        print("file \(exampleFile.url.path)")
        print("tile \(formatBytes(4 * mebibyte))")
        print("tiled-file \(digest)")
        print("matches-cpu \(digest.constantTimeEquals(cpuDigest))")
        #else
        print("tiled-file skipped: Metal is not available for this build")
        #endif
    }

    private static func inputFile(path: String?, byteCount: Int) throws -> ExampleFile {
        if let path {
            let expandedPath = (path as NSString).expandingTildeInPath
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: expandedPath, isDirectory: &isDirectory),
                  !isDirectory.boolValue else {
                throw ExampleFailure("Path does not name a file: \(path)")
            }
            return ExampleFile(url: URL(fileURLWithPath: expandedPath), cleanupDirectory: nil)
        }

        let directory = try makeExampleDirectory()
        let url = directory.appendingPathComponent("input.bin")
        try patternData(byteCount: byteCount, seed: 17).write(to: url, options: .atomic)
        return ExampleFile(url: url, cleanupDirectory: directory)
    }

    private static func makeExampleDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("blake3swift-examples-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private static func patternData(byteCount: Int, seed: UInt8) -> Data {
        var input = [UInt8](repeating: 0, count: byteCount)
        for index in input.indices {
            input[index] = UInt8(truncatingIfNeeded: index &* 31 &+ Int(seed))
        }
        return Data(input)
    }

    private static func section(_ name: String) {
        print("\n== \(name) ==")
    }

    private static func hex(_ bytes: some Sequence<UInt8>) -> String {
        bytes.map { String(format: "%02x", $0) }.joined()
    }

    private static func formatBytes(_ byteCount: Int) -> String {
        if byteCount >= mebibyte, byteCount % mebibyte == 0 {
            return "\(byteCount / mebibyte) MiB"
        }
        return "\(byteCount) bytes"
    }

    private static func writeError(_ message: String) {
        FileHandle.standardError.write(Data((message + "\n").utf8))
    }
}

private struct ExampleFile {
    let url: URL
    let cleanupDirectory: URL?

    func cleanup() {
        if let cleanupDirectory {
            try? FileManager.default.removeItem(at: cleanupDirectory)
        }
    }
}

private struct ExampleFailure: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}
