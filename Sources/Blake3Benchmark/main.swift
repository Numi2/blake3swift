@_spi(Benchmark) import Blake3
import Blake3BenchmarkSupport
import Darwin
import Foundation
#if canImport(Metal)
import Metal
#endif

#if canImport(Metal)
private enum MetalTimingMode: String {
    case resident
    case privateResident = "private"
    case privateStaged = "private-staged"
    case staged
    case wrapped
    case endToEnd = "e2e"

    var labelComponent: String {
        switch self {
        case .resident:
            return "resident"
        case .privateResident:
            return "private"
        case .privateStaged:
            return "private-staged"
        case .staged:
            return "staged"
        case .wrapped:
            return "wrapped"
        case .endToEnd:
            return "e2e"
        }
    }

    var description: String {
        switch self {
        case .resident:
            return "pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read"
        case .privateResident:
            return "pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read"
        case .privateStaged:
            return "pre-created shared staging and private MTLBuffers; timed Swift-byte copy into staging, private upload/hash command completion, digest read"
        case .staged:
            return "pre-created shared staging MTLBuffer; timed Swift-byte copy into staging buffer plus hash"
        case .wrapped:
            return "timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash"
        case .endToEnd:
            return "timed shared MTLBuffer allocation/copy from Swift bytes plus hash"
        }
    }
}
#endif

private enum FileTimingMode: String {
    case read
    case memoryMapped = "mmap"
    case memoryMappedParallel = "mmap-parallel"
    #if canImport(Metal)
    case metalMemoryMapped = "metal-mmap"
    case metalTiledMemoryMapped = "metal-tiled-mmap"
    #endif

    var description: String {
        switch self {
        case .read:
            return "timed file open, streaming read loop, CPU update/finalize, close; benchmark file creation excluded"
        case .memoryMapped:
            return "timed file open/stat, mmap, bounded tiled CPU hash, finalize, munmap, close; benchmark file creation excluded"
        case .memoryMappedParallel:
            return "timed file open/stat, mmap, bounded tiled CPU parallel hash, finalize, munmap, close; benchmark file creation excluded"
        #if canImport(Metal)
        case .metalMemoryMapped:
            return "timed file open/stat, mmap, no-copy Metal buffer wrapper, GPU hash wait, digest read, munmap, close; benchmark file creation excluded"
        case .metalTiledMemoryMapped:
            return "timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded"
        #endif
        }
    }
}

private let defaultSizes = [
    1,
    1 * 1024,
    1024 * 1024,
    16 * 1024 * 1024,
    64 * 1024 * 1024,
    256 * 1024 * 1024,
    512 * 1024 * 1024,
    1024 * 1024 * 1024
]

private func argumentValue(named name: String) -> String? {
    let arguments = Array(CommandLine.arguments.dropFirst())
    for index in arguments.indices {
        if arguments[index] == name, arguments.indices.contains(index + 1) {
            return arguments[index + 1]
        }
        if arguments[index].hasPrefix("\(name)=") {
            return String(arguments[index].dropFirst(name.count + 1))
        }
    }
    return nil
}

private func hasArgument(named name: String) -> Bool {
    CommandLine.arguments.dropFirst().contains { argument in
        argument == name || argument == "\(name)=true" || argument == "\(name)=1"
    }
}

private func benchmarkSizes() -> [Int] {
    guard let rawValue = argumentValue(named: "--sizes") else {
        return defaultSizes
    }

    let parsed = rawValue
        .split(separator: ",")
        .compactMap(parseByteCount)

    return parsed.isEmpty ? defaultSizes : parsed
}

private func parseByteCount(_ token: Substring) -> Int? {
    let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if let bytes = Int(trimmed), bytes > 0 {
        return bytes
    }

    let suffixes: [(String, Int)] = [
        ("gib", 1024 * 1024 * 1024),
        ("gb", 1024 * 1024 * 1024),
        ("g", 1024 * 1024 * 1024),
        ("mib", 1024 * 1024),
        ("mb", 1024 * 1024),
        ("m", 1024 * 1024),
        ("kib", 1024),
        ("kb", 1024),
        ("k", 1024)
    ]

    for (suffix, multiplier) in suffixes where trimmed.hasSuffix(suffix) {
        let numberPart = trimmed.dropLast(suffix.count)
        guard let value = Int(numberPart), value > 0 else {
            return nil
        }
        let multiplied = value.multipliedReportingOverflow(by: multiplier)
        return multiplied.overflow ? nil : multiplied.partialValue
    }
    return nil
}

private func iterationCount(for byteCount: Int) -> Int {
    if let rawValue = argumentValue(named: "--iterations"),
       let parsed = Int(rawValue),
       parsed > 0 {
        return parsed
    }
    switch byteCount {
    case 0..<(1024 * 1024):
        return 25
    case 0..<(32 * 1024 * 1024):
        return 8
    default:
        return 4
    }
}

private func cpuWorkerCount() -> Int? {
    guard let rawValue = argumentValue(named: "--cpu-workers"),
          let parsed = Int(rawValue),
          parsed > 0
    else {
        return nil
    }
    return parsed
}

private func reportsMemoryStats() -> Bool {
    hasArgument(named: "--memory-stats")
}

private func jsonOutputPath() -> String? {
    guard let path = argumentValue(named: "--json-output"),
          !path.isEmpty
    else {
        return nil
    }
    return path
}

private func jsonValidationPath() -> String? {
    guard let path = argumentValue(named: "--validate-json"),
          !path.isEmpty
    else {
        return nil
    }
    return path
}

private func fileTimingModes() -> [FileTimingMode] {
    guard let rawValue = argumentValue(named: "--file-modes") else {
        return []
    }

    let tokens = rawValue
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }

    if tokens.contains("none") || tokens.contains("off") || tokens.contains("disabled") {
        return []
    }

    let modes = tokens.compactMap { token -> FileTimingMode? in
        switch token {
        case "read", "stream", "streaming":
            return .read
        case "mmap", "memory-mapped", "mapped":
            return .memoryMapped
        case "mmap-parallel", "memory-mapped-parallel", "mapped-parallel", "parallel-mmap":
            return .memoryMappedParallel
        #if canImport(Metal)
        case "metal-mmap", "mmap-metal", "metal-memory-mapped", "metal-mapped":
            return .metalMemoryMapped
        case "metal-tiled-mmap", "tiled-metal-mmap", "metal-mmap-tiled", "metal-tiled":
            return .metalTiledMemoryMapped
        #endif
        default:
            return nil
        }
    }

    return modes
}

#if canImport(Metal)
private func metalTimingModes() -> [MetalTimingMode] {
    guard let rawValue = argumentValue(named: "--metal-modes") else {
        return [.resident]
    }

    let tokens = rawValue
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }

    if tokens.contains("none") || tokens.contains("off") || tokens.contains("disabled") {
        return []
    }

    let modes = tokens
        .compactMap { token -> MetalTimingMode? in
            switch token {
            case "resident", "device", "device-resident":
                return .resident
            case "private", "private-resident", "device-private":
                return .privateResident
            case "private-staged", "private-upload", "staged-private":
                return .privateStaged
            case "staged", "pooled", "reused", "reuse":
                return .staged
            case "wrapped", "nocopy", "no-copy", "bytes-no-copy":
                return .wrapped
            case "e2e", "end-to-end", "endtoend":
                return .endToEnd
            default:
                return nil
            }
        }

    return modes.isEmpty ? [.resident] : modes
}

private func sustainedSeconds() -> Double? {
    guard let rawValue = argumentValue(named: "--sustained-seconds"),
          let parsed = Double(rawValue),
          parsed > 0
    else {
        return nil
    }
    return parsed
}

private func sustainedMode() -> MetalTimingMode {
    guard let rawValue = argumentValue(named: "--sustained-mode")?.lowercased() else {
        return .resident
    }
    switch rawValue {
    case "private", "private-resident", "device-private":
        return .privateResident
    case "private-staged", "private-upload", "staged-private":
        return .privateStaged
    case "staged", "pooled", "reused", "reuse":
        return .staged
    case "wrapped", "nocopy", "no-copy", "bytes-no-copy":
        return .wrapped
    case "e2e", "end-to-end", "endtoend":
        return .endToEnd
    default:
        return .resident
    }
}

private func sustainedPolicy() -> BLAKE3Metal.ExecutionPolicy {
    guard let rawValue = argumentValue(named: "--sustained-policy")?.lowercased() else {
        return .automatic
    }
    switch rawValue {
    case "gpu":
        return .gpu
    case "cpu":
        return .cpu
    default:
        return .automatic
    }
}

private func metalMinimumGPUByteCount() -> Int {
    guard let rawValue = argumentValue(named: "--minimum-gpu-bytes"),
          let parsed = parseByteCount(Substring(rawValue))
    else {
        return BLAKE3Metal.defaultMinimumGPUByteCount
    }
    return parsed
}

private func metalTileByteCount() -> Int {
    guard let rawValue = argumentValue(named: "--metal-tile-size") ?? argumentValue(named: "--tile-size"),
          let parsed = parseByteCount(Substring(rawValue))
    else {
        return BLAKE3File.mappedTileByteCount
    }
    return max(BLAKE3.chunkByteCount, parsed)
}

private func metalLibrarySource() -> BLAKE3Metal.LibrarySource {
    guard let path = argumentValue(named: "--metal-library"),
          !path.isEmpty
    else {
        return .runtimeSource
    }
    return .metallib(URL(fileURLWithPath: path))
}

private func metalLibraryDescription(_ source: BLAKE3Metal.LibrarySource) -> String {
    switch source {
    case .runtimeSource:
        return "runtime-source"
    case let .metallib(url):
        return "metallib:\(url.standardizedFileURL.path)"
    }
}
#endif

private let deterministicFillBlock: [UInt8] = {
    (0..<16_384).map { UInt8(truncatingIfNeeded: ($0 &* 31) &+ 17) }
}()

private func fillDeterministically(_ bytes: inout [UInt8]) {
    guard !bytes.isEmpty else {
        return
    }

    deterministicFillBlock.withUnsafeBytes { pattern in
        bytes.withUnsafeMutableBytes { destination in
            guard let patternBase = pattern.baseAddress,
                  let destinationBase = destination.baseAddress
            else {
                return
            }

            var offset = 0
            while offset < destination.count {
                let byteCount = min(pattern.count, destination.count - offset)
                memcpy(destinationBase.advanced(by: offset), patternBase, byteCount)
                offset += byteCount
            }
        }
    }
}

@inline(never)
private func hashScalarForBenchmark(_ input: UnsafeRawBufferPointer) -> BLAKE3.Digest {
    BLAKE3.hashScalar(input)
}

@inline(never)
private func hashSingleForBenchmark(_ input: UnsafeRawBufferPointer) -> BLAKE3.Digest {
    BLAKE3.hashSerial(input)
}

@inline(never)
private func hashParallelForBenchmark(_ input: UnsafeRawBufferPointer) -> BLAKE3.Digest {
    BLAKE3.hashParallel(input)
}

@inline(never)
private func hashParallelForBenchmark(_ input: UnsafeRawBufferPointer, maxWorkers: Int?) -> BLAKE3.Digest {
    BLAKE3.hashParallel(input, maxWorkers: maxWorkers)
}

@inline(never)
private func hashOfficialCForBenchmark(_ input: UnsafeRawBufferPointer) -> BLAKE3.Digest {
    OfficialCBLAKE3.hash(input)
}

@inline(never)
private func hashMetalAutoForBenchmark(
    context: BLAKE3Metal.Context,
    buffer: MTLBuffer,
    length: Int
) -> BLAKE3.Digest {
    try! context.hash(buffer: buffer, length: length, policy: .automatic)
}

@inline(never)
private func hashMetalGPUForBenchmark(
    context: BLAKE3Metal.Context,
    buffer: MTLBuffer,
    length: Int
) -> BLAKE3.Digest {
    try! context.hash(buffer: buffer, length: length, policy: .gpu)
}

private func makeMetalBuffer(device: MTLDevice, input: [UInt8]) -> MTLBuffer? {
    guard !input.isEmpty else {
        return device.makeBuffer(length: 1, options: .storageModeShared)
    }
    return input.withUnsafeBytes { raw in
        guard let baseAddress = raw.baseAddress else {
            return nil
        }
        return device.makeBuffer(bytes: baseAddress, length: input.count, options: .storageModeShared)
    }
}

private func runBenchmark(
    backend: String,
    mode: String,
    input: [UInt8],
    iterations: Int,
    operation: ([UInt8]) -> BLAKE3.Digest
) -> BenchmarkResult {
    var sampleNanoseconds = [UInt64]()
    sampleNanoseconds.reserveCapacity(iterations)
    var finalDigest = operation(input)

    for _ in 0..<iterations {
        let started = DispatchTime.now().uptimeNanoseconds
        finalDigest = operation(input)
        let elapsed = DispatchTime.now().uptimeNanoseconds - started
        sampleNanoseconds.append(elapsed)
    }

    return BenchmarkResult(
        backend: backend,
        mode: mode,
        byteCount: input.count,
        sampleNanoseconds: sampleNanoseconds,
        digest: finalDigest
    )
}

private func runRawBenchmark(
    backend: String,
    mode: String,
    input: [UInt8],
    iterations: Int,
    operation: (UnsafeRawBufferPointer) -> BLAKE3.Digest
) -> BenchmarkResult {
    input.withUnsafeBytes { rawInput in
        var sampleNanoseconds = [UInt64]()
        sampleNanoseconds.reserveCapacity(iterations)
        var finalDigest = operation(rawInput)

        for _ in 0..<iterations {
            let started = DispatchTime.now().uptimeNanoseconds
            finalDigest = operation(rawInput)
            let elapsed = DispatchTime.now().uptimeNanoseconds - started
            sampleNanoseconds.append(elapsed)
        }

        return BenchmarkResult(
            backend: backend,
            mode: mode,
            byteCount: rawInput.count,
            sampleNanoseconds: sampleNanoseconds,
            digest: finalDigest
        )
    }
}

private func runThrowingBenchmark(
    backend: String,
    mode: String,
    input: [UInt8],
    iterations: Int,
    operation: ([UInt8]) throws -> BLAKE3.Digest
) throws -> BenchmarkResult {
    var sampleNanoseconds = [UInt64]()
    sampleNanoseconds.reserveCapacity(iterations)
    var finalDigest = try operation(input)

    for _ in 0..<iterations {
        let started = DispatchTime.now().uptimeNanoseconds
        finalDigest = try operation(input)
        let elapsed = DispatchTime.now().uptimeNanoseconds - started
        sampleNanoseconds.append(elapsed)
    }

    return BenchmarkResult(
        backend: backend,
        mode: mode,
        byteCount: input.count,
        sampleNanoseconds: sampleNanoseconds,
        digest: finalDigest
    )
}

private func runFileBenchmark(
    backend: String,
    mode: String,
    path: String,
    byteCount: Int,
    iterations: Int,
    operation: (String) throws -> BLAKE3.Digest
) throws -> BenchmarkResult {
    var sampleNanoseconds = [UInt64]()
    sampleNanoseconds.reserveCapacity(iterations)
    var finalDigest = try operation(path)

    for _ in 0..<iterations {
        let started = DispatchTime.now().uptimeNanoseconds
        finalDigest = try operation(path)
        let elapsed = DispatchTime.now().uptimeNanoseconds - started
        sampleNanoseconds.append(elapsed)
    }

    return BenchmarkResult(
        backend: backend,
        mode: mode,
        byteCount: byteCount,
        sampleNanoseconds: sampleNanoseconds,
        digest: finalDigest
    )
}

private func makeBenchmarkFile(input: [UInt8], byteCount: Int) throws -> URL {
    let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent(
            "blake3swift-bench-\(ProcessInfo.processInfo.processIdentifier)-\(UUID().uuidString)",
            isDirectory: true
        )
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

    let url = directory.appendingPathComponent("input-\(byteCount).bin", isDirectory: false)
    let fd = open(url.path, O_CREAT | O_TRUNC | O_WRONLY, S_IRUSR | S_IWUSR)
    guard fd >= 0 else {
        throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
    }
    defer { close(fd) }

    try input.withUnsafeBytes { rawBuffer in
        guard let baseAddress = rawBuffer.baseAddress else {
            return
        }
        var offset = 0
        while offset < rawBuffer.count {
            let written = Darwin.write(fd, baseAddress.advanced(by: offset), rawBuffer.count - offset)
            if written > 0 {
                offset += written
            } else if written < 0, errno == EINTR {
                continue
            } else {
                throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
            }
        }
    }

    return url
}

private struct BenchmarkResult {
    let backend: String
    let mode: String
    let byteCount: Int
    let sampleNanoseconds: [UInt64]
    let digest: BLAKE3.Digest

    var throughputStats: ThroughputStats {
        makeThroughputStats(
            sampleNanoseconds.map { nanoseconds in
                throughput(byteCount: byteCount, nanoseconds: nanoseconds)
            }
        )
    }
}

private struct BenchmarkReport: Codable {
    let schemaVersion: Int
    let generatedAtUTC: String
    let commandLine: [String]
    let environment: BenchmarkEnvironment
    let request: BenchmarkRequest
    let rows: [BenchmarkRow]
    let sustainedRows: [SustainedRow]
    let memorySamples: [MemorySample]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case generatedAtUTC = "generated_at_utc"
        case commandLine = "command_line"
        case environment
        case request
        case rows
        case sustainedRows = "sustained_rows"
        case memorySamples = "memory_samples"
    }
}

private struct BenchmarkEnvironment: Codable {
    let backend: String
    let simdDegree: Int
    let parallelSIMDDegree: Int
    let defaultParallelWorkers: Int
    let hasherBytes: Int
    let defaultBackendPolicy: String
    let defaultMetalMinimumByteCount: Int
    let metalDevice: String?
    let metalLibrary: String?
    let metalMinimumGPUByteCount: Int?
    let metalTileByteCount: Int?
    let metalModes: [String]
    let fileModes: [String]
    let cpuWorkers: Int?
    let memoryStats: Bool

    enum CodingKeys: String, CodingKey {
        case backend
        case simdDegree = "simd_degree"
        case parallelSIMDDegree = "parallel_simd_degree"
        case defaultParallelWorkers = "default_parallel_workers"
        case hasherBytes = "hasher_bytes"
        case defaultBackendPolicy = "default_backend_policy"
        case defaultMetalMinimumByteCount = "default_metal_minimum_byte_count"
        case metalDevice = "metal_device"
        case metalLibrary = "metal_library"
        case metalMinimumGPUByteCount = "metal_minimum_gpu_byte_count"
        case metalTileByteCount = "metal_tile_byte_count"
        case metalModes = "metal_modes"
        case fileModes = "file_modes"
        case cpuWorkers = "cpu_workers"
        case memoryStats = "memory_stats"
    }
}

private struct BenchmarkRequest: Codable {
    let sizes: [String]
    let sizesBytes: [Int]
    let iterationsOverride: Int?
    let sustainedSeconds: Double?

    enum CodingKeys: String, CodingKey {
        case sizes
        case sizesBytes = "sizes_bytes"
        case iterationsOverride = "iterations_override"
        case sustainedSeconds = "sustained_seconds"
    }
}

private struct BenchmarkRow: Codable {
    let size: String
    let byteCount: Int
    let backend: String
    let mode: String
    let iterations: Int
    let sampleNanoseconds: [UInt64]
    let medianGiBPerSecond: Double
    let minimumGiBPerSecond: Double
    let p95GiBPerSecond: Double
    let maximumGiBPerSecond: Double
    let digest: String
    let correct: Bool

    enum CodingKeys: String, CodingKey {
        case size
        case byteCount = "byte_count"
        case backend
        case mode
        case iterations
        case sampleNanoseconds = "sample_nanoseconds"
        case medianGiBPerSecond = "median_gib_per_second"
        case minimumGiBPerSecond = "minimum_gib_per_second"
        case p95GiBPerSecond = "p95_gib_per_second"
        case maximumGiBPerSecond = "maximum_gib_per_second"
        case digest
        case correct
    }
}

private struct SustainedRow: Codable {
    let size: String
    let byteCount: Int
    let name: String
    let iterations: Int
    let elapsedSeconds: Double
    let averageGiBPerSecond: Double
    let medianGiBPerSecond: Double
    let minimumGiBPerSecond: Double
    let p95GiBPerSecond: Double
    let maximumGiBPerSecond: Double
    let firstQuarterGiBPerSecond: Double
    let lastQuarterGiBPerSecond: Double
    let digest: String
    let correct: Bool

    enum CodingKeys: String, CodingKey {
        case size
        case byteCount = "byte_count"
        case name
        case iterations
        case elapsedSeconds = "elapsed_seconds"
        case averageGiBPerSecond = "average_gib_per_second"
        case medianGiBPerSecond = "median_gib_per_second"
        case minimumGiBPerSecond = "minimum_gib_per_second"
        case p95GiBPerSecond = "p95_gib_per_second"
        case maximumGiBPerSecond = "maximum_gib_per_second"
        case firstQuarterGiBPerSecond = "first_quarter_gib_per_second"
        case lastQuarterGiBPerSecond = "last_quarter_gib_per_second"
        case digest
        case correct
    }
}

#if canImport(Metal)
private struct SustainedResult {
    let name: String
    let iterations: Int
    let elapsedSeconds: Double
    let averageGiBPerSecond: Double
    let throughputStats: ThroughputStats
    let firstQuarterGiBPerSecond: Double
    let lastQuarterGiBPerSecond: Double
    let digest: BLAKE3.Digest
}

private func runSustainedMetal(
    name: String,
    byteCount: Int,
    seconds duration: Double,
    expectedDigest: BLAKE3.Digest,
    operation: () -> BLAKE3.Digest
) -> SustainedResult {
    var samples = [Double]()
    samples.reserveCapacity(max(1, Int(duration * 100)))
    var finalDigest = operation()
    let started = DispatchTime.now().uptimeNanoseconds
    let durationNanoseconds = UInt64(duration * 1_000_000_000.0)

    repeat {
        let iterationStarted = DispatchTime.now().uptimeNanoseconds
        finalDigest = operation()
        if finalDigest != expectedDigest {
            fatalError("\(name) digest mismatch during sustained run")
        }
        let elapsed = DispatchTime.now().uptimeNanoseconds - iterationStarted
        let seconds = Double(elapsed) / 1_000_000_000.0
        samples.append((Double(byteCount) / 1_073_741_824.0) / seconds)
    } while DispatchTime.now().uptimeNanoseconds - started < durationNanoseconds

    let elapsed = Double(DispatchTime.now().uptimeNanoseconds - started) / 1_000_000_000.0
    let average = (Double(byteCount * samples.count) / 1_073_741_824.0) / elapsed
    let stats = makeThroughputStats(samples)
    let quarterCount = max(1, samples.count / 4)
    let firstQuarter = samples.prefix(quarterCount).reduce(0, +) / Double(quarterCount)
    let lastQuarter = samples.suffix(quarterCount).reduce(0, +) / Double(quarterCount)

    return SustainedResult(
        name: name,
        iterations: samples.count,
        elapsedSeconds: elapsed,
        averageGiBPerSecond: average,
        throughputStats: stats,
        firstQuarterGiBPerSecond: firstQuarter,
        lastQuarterGiBPerSecond: lastQuarter,
        digest: finalDigest
    )
}
#endif

private struct ThroughputStats {
    let minimum: Double
    let median: Double
    let p95: Double
    let maximum: Double
}

private func throughput(byteCount: Int, nanoseconds: UInt64) -> Double {
    guard byteCount > 0, nanoseconds > 0 else {
        return 0
    }
    let seconds = Double(nanoseconds) / 1_000_000_000.0
    return (Double(byteCount) / 1_073_741_824.0) / seconds
}

private func makeThroughputStats(_ samples: [Double]) -> ThroughputStats {
    let sorted = samples.sorted()
    guard !sorted.isEmpty else {
        return ThroughputStats(minimum: 0, median: 0, p95: 0, maximum: 0)
    }
    return ThroughputStats(
        minimum: sorted.first ?? 0,
        median: median(sorted),
        p95: percentile(sorted, 0.95),
        maximum: sorted.last ?? 0
    )
}

private func median(_ sorted: [Double]) -> Double {
    guard !sorted.isEmpty else {
        return 0
    }
    let midpoint = sorted.count / 2
    if sorted.count.isMultiple(of: 2) {
        return (sorted[midpoint - 1] + sorted[midpoint]) / 2
    }
    return sorted[midpoint]
}

private func percentile(_ sorted: [Double], _ percentile: Double) -> Double {
    guard !sorted.isEmpty else {
        return 0
    }
    let clamped = min(max(percentile, 0), 1)
    let rank = Int(ceil(clamped * Double(sorted.count))) - 1
    let index = min(max(rank, 0), sorted.count - 1)
    return sorted[index]
}

private func digestPrefix(_ digest: BLAKE3.Digest) -> String {
    String(digest.description.prefix(16))
}

private func formatBytes(_ byteCount: Int) -> String {
    let kib = 1024
    let mib = 1024 * kib
    let gib = 1024 * mib

    if byteCount >= gib {
        if byteCount.isMultiple(of: gib) {
            return String(format: "%.1f GiB", Double(byteCount) / Double(gib))
        }
        if byteCount.isMultiple(of: mib) {
            return "\(byteCount / gib) GiB + \((byteCount % gib) / mib) MiB"
        }
        if byteCount.isMultiple(of: kib) {
            return "\(byteCount / gib) GiB + \((byteCount % gib) / kib) KiB"
        }
        return String(format: "%.3f GiB (%d B)", Double(byteCount) / Double(gib), byteCount)
    }
    if byteCount >= mib {
        if byteCount.isMultiple(of: mib) {
            return String(format: "%.1f MiB", Double(byteCount) / Double(mib))
        }
        if byteCount.isMultiple(of: kib) {
            return "\(byteCount / mib) MiB + \((byteCount % mib) / kib) KiB"
        }
        return String(format: "%.3f MiB (%d B)", Double(byteCount) / Double(mib), byteCount)
    }
    if byteCount >= kib {
        if byteCount.isMultiple(of: kib) {
            return String(format: "%.1f KiB", Double(byteCount) / Double(kib))
        }
        return "\(byteCount / kib) KiB + \(byteCount % kib) B"
    }
    return "\(byteCount) B"
}

private func residentMemoryBytes() -> UInt64? {
    var info = mach_task_basic_info_data_t()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size)
    let result = withUnsafeMutablePointer(to: &info) { pointer in
        pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
            task_info(
                mach_task_self_,
                task_flavor_t(MACH_TASK_BASIC_INFO),
                rebound,
                &count
            )
        }
    }
    guard result == KERN_SUCCESS else {
        return nil
    }
    return UInt64(info.resident_size)
}

private struct AllocatorStats {
    let bytesInUse: UInt64
    let blocksInUse: UInt64
}

private func allocatorStats() -> AllocatorStats? {
    var stats = malloc_statistics_t()
    malloc_zone_statistics(nil, &stats)
    guard stats.size_in_use > 0 || stats.blocks_in_use > 0 else {
        return nil
    }
    return AllocatorStats(
        bytesInUse: UInt64(stats.size_in_use),
        blocksInUse: UInt64(stats.blocks_in_use)
    )
}

private func formatMemory(_ byteCount: UInt64) -> String {
    let mib = Double(byteCount) / 1_048_576.0
    return String(format: "%.1f MiB", mib)
}

private func formatOptionalMemory(_ byteCount: UInt64?) -> String {
    guard let byteCount else {
        return "n/a"
    }
    return formatMemory(byteCount)
}

private struct MemorySample: Codable {
    let sizeLabel: String
    let phase: String
    let residentBytes: UInt64?
    let allocatorBytesInUse: UInt64?
    let allocatorBlocksInUse: UInt64?

    enum CodingKeys: String, CodingKey {
        case sizeLabel = "size_label"
        case phase
        case residentBytes = "resident_bytes"
        case allocatorBytesInUse = "allocator_bytes_in_use"
        case allocatorBlocksInUse = "allocator_blocks_in_use"
    }
}

private func recordMemoryStats(
    size label: String,
    phase: String,
    into memorySamples: inout [MemorySample]
) {
    guard reportsMemoryStats() else {
        return
    }
    let rss = residentMemoryBytes()
    let allocator = allocatorStats()
    guard rss != nil || allocator != nil else {
        return
    }
    memorySamples.append(
        MemorySample(
            sizeLabel: label,
            phase: phase,
            residentBytes: rss,
            allocatorBytesInUse: allocator?.bytesInUse,
            allocatorBlocksInUse: allocator?.blocksInUse
        )
    )
}

private func printMemoryStats(_ memorySamples: [MemorySample]) {
    guard !memorySamples.isEmpty else {
        return
    }
    print("")
    print("| Size | Memory Phase | RSS | Allocator In Use | Allocator Blocks |")
    print("| --- | --- | ---: | ---: | ---: |")
    for sample in memorySamples {
        let allocatorBlocks = sample.allocatorBlocksInUse.map(String.init) ?? "n/a"
        print(
            "| \(sample.sizeLabel) | \(sample.phase) | \(formatOptionalMemory(sample.residentBytes)) | \(formatOptionalMemory(sample.allocatorBytesInUse)) | \(allocatorBlocks) |"
        )
    }
}

private func generatedTimestampUTC() -> String {
    let formatter = ISO8601DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: Date())
}

private func iterationsOverride() -> Int? {
    guard let rawValue = argumentValue(named: "--iterations"),
          let parsed = Int(rawValue),
          parsed > 0
    else {
        return nil
    }
    return parsed
}

private func writeJSONReport(_ report: BenchmarkReport, to path: String) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    let data = try encoder.encode(report)
    let url = URL(fileURLWithPath: path)
    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try data.write(to: url, options: .atomic)
}

private func validateJSONReport(at path: String) throws {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let decoder = JSONDecoder()
    let report = try decoder.decode(BenchmarkReport.self, from: data)
    try validate(report)
}

private func validate(_ report: BenchmarkReport) throws {
    try require(report.schemaVersion == 1, "unsupported schema_version \(report.schemaVersion)")
    try require(!report.generatedAtUTC.isEmpty, "missing generated_at_utc")
    try require(!report.commandLine.isEmpty, "missing command_line")
    try require(!report.request.sizesBytes.isEmpty, "missing requested sizes")
    try require(
        report.request.sizes.count == report.request.sizesBytes.count,
        "requested sizes and sizes_bytes counts differ"
    )
    try require(!report.rows.isEmpty, "report contains no benchmark rows")

    let requestedSizes = Set(report.request.sizesBytes)
    for byteCount in requestedSizes {
        try require(
            report.rows.contains { $0.byteCount == byteCount && $0.backend == "cpu" && $0.mode == "scalar" },
            "missing cpu scalar baseline row for byte_count \(byteCount)"
        )
    }

    for row in report.rows {
        try validate(row, requestedSizes: requestedSizes)
    }

    if let sustainedSeconds = report.request.sustainedSeconds, sustainedSeconds > 0 {
        try require(!report.sustainedRows.isEmpty, "sustained run requested but no sustained rows found")
    }
    for row in report.sustainedRows {
        try validate(row, requestedSizes: requestedSizes)
    }

    if report.environment.memoryStats {
        try require(!report.memorySamples.isEmpty, "memory_stats was requested but no memory samples were recorded")
    }
    for sample in report.memorySamples {
        try require(!sample.sizeLabel.isEmpty, "memory sample has empty size label")
        try require(!sample.phase.isEmpty, "memory sample has empty phase")
        try require(
            sample.residentBytes != nil || sample.allocatorBytesInUse != nil || sample.allocatorBlocksInUse != nil,
            "memory sample has no recorded memory metrics"
        )
        if let residentBytes = sample.residentBytes {
            try require(residentBytes > 0, "memory sample has non-positive RSS")
        }
        if let allocatorBytesInUse = sample.allocatorBytesInUse {
            try require(allocatorBytesInUse > 0, "memory sample has non-positive allocator bytes")
        }
        if let allocatorBlocksInUse = sample.allocatorBlocksInUse {
            try require(allocatorBlocksInUse > 0, "memory sample has non-positive allocator blocks")
        }
    }
}

private func validate(_ row: BenchmarkRow, requestedSizes: Set<Int>) throws {
    try require(requestedSizes.contains(row.byteCount), "row byte_count \(row.byteCount) was not requested")
    try require(!row.size.isEmpty, "row has empty size label")
    try require(row.byteCount > 0, "row has non-positive byte_count")
    try require(!row.backend.isEmpty, "row has empty backend")
    try require(!row.mode.isEmpty, "row has empty mode")
    try require(row.correct, "\(row.backend) \(row.mode) \(row.size) is not correct")
    try require(row.iterations > 0, "\(row.backend) \(row.mode) \(row.size) has no iterations")
    try require(
        row.iterations == row.sampleNanoseconds.count,
        "\(row.backend) \(row.mode) \(row.size) iteration count does not match sample count"
    )
    try require(
        row.sampleNanoseconds.allSatisfy { $0 > 0 },
        "\(row.backend) \(row.mode) \(row.size) contains non-positive sample"
    )
    try validateThroughputStats(
        minimum: row.minimumGiBPerSecond,
        median: row.medianGiBPerSecond,
        p95: row.p95GiBPerSecond,
        maximum: row.maximumGiBPerSecond,
        label: "\(row.backend) \(row.mode) \(row.size)"
    )
    try validateDigest(row.digest, label: "\(row.backend) \(row.mode) \(row.size)")
}

private func validate(_ row: SustainedRow, requestedSizes: Set<Int>) throws {
    try require(requestedSizes.contains(row.byteCount), "sustained byte_count \(row.byteCount) was not requested")
    try require(!row.size.isEmpty, "sustained row has empty size label")
    try require(!row.name.isEmpty, "sustained row has empty name")
    try require(row.correct, "\(row.name) \(row.size) is not correct")
    try require(row.iterations > 0, "\(row.name) \(row.size) has no iterations")
    try require(row.elapsedSeconds.isFinite && row.elapsedSeconds > 0, "\(row.name) has invalid elapsed seconds")
    try require(
        row.averageGiBPerSecond.isFinite && row.averageGiBPerSecond >= 0,
        "\(row.name) has invalid average throughput"
    )
    try validateThroughputStats(
        minimum: row.minimumGiBPerSecond,
        median: row.medianGiBPerSecond,
        p95: row.p95GiBPerSecond,
        maximum: row.maximumGiBPerSecond,
        label: "\(row.name) \(row.size)"
    )
    try require(
        row.firstQuarterGiBPerSecond.isFinite && row.firstQuarterGiBPerSecond >= 0,
        "\(row.name) has invalid first-quarter throughput"
    )
    try require(
        row.lastQuarterGiBPerSecond.isFinite && row.lastQuarterGiBPerSecond >= 0,
        "\(row.name) has invalid last-quarter throughput"
    )
    try validateDigest(row.digest, label: "\(row.name) \(row.size)")
}

private func validateThroughputStats(
    minimum: Double,
    median: Double,
    p95: Double,
    maximum: Double,
    label: String
) throws {
    for (name, value) in [
        ("minimum", minimum),
        ("median", median),
        ("p95", p95),
        ("maximum", maximum)
    ] {
        try require(value.isFinite && value >= 0, "\(label) has invalid \(name) throughput")
    }
    try require(minimum <= median, "\(label) minimum throughput exceeds median")
    try require(median <= maximum, "\(label) median throughput exceeds maximum")
    try require(minimum <= p95 && p95 <= maximum, "\(label) p95 throughput is outside min/max")
}

private func validateDigest(_ digest: String, label: String) throws {
    try require(digest.count == BLAKE3.Digest.byteCount * 2, "\(label) has invalid digest length")
    try require(
        digest.utf8.allSatisfy { byte in
            (byte >= 48 && byte <= 57) || (byte >= 97 && byte <= 102)
        },
        "\(label) digest is not lowercase hexadecimal"
    )
}

private func require(_ condition: Bool, _ message: String) throws {
    if !condition {
        throw BenchmarkValidationError(message)
    }
}

private struct BenchmarkValidationError: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}

#if canImport(Metal)
private struct AutotuneReport: Codable {
    let schemaVersion: Int
    let generatedAtUTC: String
    let commandLine: [String]
    let environment: AutotuneEnvironment
    let request: AutotuneRequest
    let measurements: [AutotuneMeasurement]
    let recommendations: [AutotuneRecommendation]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case generatedAtUTC = "generated_at_utc"
        case commandLine = "command_line"
        case environment
        case request
        case measurements
        case recommendations
    }
}

private struct AutotuneEnvironment: Codable {
    let backend: String
    let simdDegree: Int
    let parallelSIMDDegree: Int
    let defaultParallelWorkers: Int
    let metalDevice: String
    let metalLibrary: String

    enum CodingKeys: String, CodingKey {
        case backend
        case simdDegree = "simd_degree"
        case parallelSIMDDegree = "parallel_simd_degree"
        case defaultParallelWorkers = "default_parallel_workers"
        case metalDevice = "metal_device"
        case metalLibrary = "metal_library"
    }
}

private struct AutotuneRequest: Codable {
    let sizes: [String]
    let sizesBytes: [Int]
    let iterations: Int
    let gateCandidatesBytes: [Int]
    let modeCandidates: [String]
    let tileCandidatesBytes: [Int]
    let includesFileTileSweep: Bool

    enum CodingKeys: String, CodingKey {
        case sizes
        case sizesBytes = "sizes_bytes"
        case iterations
        case gateCandidatesBytes = "gate_candidates_bytes"
        case modeCandidates = "mode_candidates"
        case tileCandidatesBytes = "tile_candidates_bytes"
        case includesFileTileSweep = "includes_file_tile_sweep"
    }
}

private struct AutotuneMeasurement: Codable {
    let category: String
    let candidate: String
    let parameterName: String?
    let parameterValueBytes: Int?
    let size: String
    let byteCount: Int
    let iterations: Int
    let sampleNanoseconds: [UInt64]
    let medianGiBPerSecond: Double
    let minimumGiBPerSecond: Double
    let p95GiBPerSecond: Double
    let maximumGiBPerSecond: Double
    let digest: String
    let correct: Bool

    enum CodingKeys: String, CodingKey {
        case category
        case candidate
        case parameterName = "parameter_name"
        case parameterValueBytes = "parameter_value_bytes"
        case size
        case byteCount = "byte_count"
        case iterations
        case sampleNanoseconds = "sample_nanoseconds"
        case medianGiBPerSecond = "median_gib_per_second"
        case minimumGiBPerSecond = "minimum_gib_per_second"
        case p95GiBPerSecond = "p95_gib_per_second"
        case maximumGiBPerSecond = "maximum_gib_per_second"
        case digest
        case correct
    }
}

private struct AutotuneRecommendation: Codable {
    let category: String
    let parameterName: String
    let recommendedValue: String
    let recommendedValueBytes: Int?
    let scoreGiBPerSecond: Double
    let rationale: String

    enum CodingKeys: String, CodingKey {
        case category
        case parameterName = "parameter_name"
        case recommendedValue = "recommended_value"
        case recommendedValueBytes = "recommended_value_bytes"
        case scoreGiBPerSecond = "score_gib_per_second"
        case rationale
    }
}

private func autotuneOutputPath() -> String? {
    if let path = argumentValue(named: "--autotune-output"), !path.isEmpty {
        return path
    }
    return jsonOutputPath()
}

private func autotuneValidationPath() -> String? {
    guard let path = argumentValue(named: "--validate-autotune-json"), !path.isEmpty else {
        return nil
    }
    return path
}

private func byteCountListArgument(named name: String, default defaultValues: [Int]) -> [Int] {
    guard let rawValue = argumentValue(named: name) else {
        return defaultValues
    }
    let parsed = rawValue
        .split(separator: ",")
        .compactMap(parseByteCount)
        .filter { $0 > 0 }
    return parsed.isEmpty ? defaultValues : Array(Set(parsed)).sorted()
}

private func autotuneSizes() -> [Int] {
    if argumentValue(named: "--autotune-sizes") != nil {
        return byteCountListArgument(
            named: "--autotune-sizes",
            default: [16 * 1024 * 1024, 64 * 1024 * 1024]
        )
    }
    if argumentValue(named: "--sizes") != nil {
        return benchmarkSizes()
    }
    return [16 * 1024 * 1024, 64 * 1024 * 1024]
}

private func autotuneIterations() -> Int {
    if let rawValue = argumentValue(named: "--autotune-iterations"),
       let parsed = Int(rawValue),
       parsed > 0 {
        return parsed
    }
    if let rawValue = argumentValue(named: "--iterations"),
       let parsed = Int(rawValue),
       parsed > 0 {
        return parsed
    }
    return 3
}

private func autotuneGateCandidates() -> [Int] {
    byteCountListArgument(
        named: "--autotune-gates",
        default: [
            1 * 1024 * 1024,
            4 * 1024 * 1024,
            16 * 1024 * 1024,
            32 * 1024 * 1024,
            64 * 1024 * 1024
        ]
    )
}

private func autotuneTileCandidates() -> [Int] {
    byteCountListArgument(
        named: "--autotune-tile-sizes",
        default: [
            8 * 1024 * 1024,
            16 * 1024 * 1024,
            32 * 1024 * 1024,
            64 * 1024 * 1024
        ]
    ).map { max(BLAKE3.chunkByteCount, $0) }
}

private func parseAutotuneMetalMode(_ token: String) -> MetalTimingMode? {
    switch token.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
    case "resident", "resident-gpu", "device", "device-resident":
        return .resident
    case "private", "private-gpu", "private-resident", "device-private":
        return .privateResident
    case "private-staged", "private-staged-gpu", "private-upload", "staged-private":
        return .privateStaged
    case "staged", "staged-gpu", "pooled", "reused", "reuse":
        return .staged
    case "wrapped", "wrapped-gpu", "nocopy", "no-copy", "bytes-no-copy":
        return .wrapped
    case "e2e", "e2e-gpu", "end-to-end", "endtoend":
        return .endToEnd
    default:
        return nil
    }
}

private func autotuneModeCandidates() -> [MetalTimingMode] {
    guard let rawValue = argumentValue(named: "--autotune-metal-modes") else {
        return [.resident, .staged, .privateStaged, .endToEnd, .privateResident]
    }
    let modes = rawValue
        .split(separator: ",")
        .compactMap { parseAutotuneMetalMode(String($0)) }
    return modes.isEmpty ? [.resident, .staged, .privateStaged, .endToEnd, .privateResident] : modes
}

private func includesAutotuneFileTileSweep() -> Bool {
    hasArgument(named: "--autotune-file-tiles")
        || hasArgument(named: "--autotune-tiles")
}

private func makeAutotuneMeasurement(
    category: String,
    candidate: String,
    parameterName: String?,
    parameterValueBytes: Int?,
    label: String,
    result: BenchmarkResult,
    expectedDigest: BLAKE3.Digest
) -> AutotuneMeasurement {
    let stats = result.throughputStats
    return AutotuneMeasurement(
        category: category,
        candidate: candidate,
        parameterName: parameterName,
        parameterValueBytes: parameterValueBytes,
        size: label,
        byteCount: result.byteCount,
        iterations: result.sampleNanoseconds.count,
        sampleNanoseconds: result.sampleNanoseconds,
        medianGiBPerSecond: stats.median,
        minimumGiBPerSecond: stats.minimum,
        p95GiBPerSecond: stats.p95,
        maximumGiBPerSecond: stats.maximum,
        digest: result.digest.description,
        correct: result.digest == expectedDigest
    )
}

private func geometricMean(_ values: [Double]) -> Double {
    guard !values.isEmpty,
          values.allSatisfy({ $0.isFinite && $0 > 0 })
    else {
        return 0
    }
    return exp(values.map(log).reduce(0, +) / Double(values.count))
}

private func bestScoredCandidate<Key: Comparable>(
    _ scores: [Key: [Double]]
) -> (key: Key, score: Double)? {
    scores
        .map { (key: $0.key, score: geometricMean($0.value)) }
        .sorted { lhs, rhs in
            if lhs.score == rhs.score {
                return lhs.key < rhs.key
            }
            return lhs.score > rhs.score
        }
        .first
}

private func writeAutotuneReport(_ report: AutotuneReport, to path: String) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    let data = try encoder.encode(report)
    let url = URL(fileURLWithPath: path)
    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try data.write(to: url, options: .atomic)
}

private func validateAutotuneReport(at path: String) throws {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let report = try JSONDecoder().decode(AutotuneReport.self, from: data)
    try validate(report)
}

private func validate(_ report: AutotuneReport) throws {
    try require(report.schemaVersion == 1, "unsupported autotune schema_version \(report.schemaVersion)")
    try require(!report.generatedAtUTC.isEmpty, "missing generated_at_utc")
    try require(!report.commandLine.isEmpty, "missing command_line")
    try require(!report.request.sizesBytes.isEmpty, "missing autotune sizes")
    try require(!report.measurements.isEmpty, "autotune report has no measurements")
    try require(!report.recommendations.isEmpty, "autotune report has no recommendations")
    for measurement in report.measurements {
        try require(measurement.byteCount > 0, "measurement has non-positive byte_count")
        try require(measurement.iterations > 0, "measurement has no iterations")
        try require(measurement.iterations == measurement.sampleNanoseconds.count, "measurement sample count mismatch")
        try require(measurement.sampleNanoseconds.allSatisfy { $0 > 0 }, "measurement contains non-positive sample")
        try require(measurement.correct, "measurement \(measurement.category)/\(measurement.candidate)/\(measurement.size) is not correct")
        try validateThroughputStats(
            minimum: measurement.minimumGiBPerSecond,
            median: measurement.medianGiBPerSecond,
            p95: measurement.p95GiBPerSecond,
            maximum: measurement.maximumGiBPerSecond,
            label: "\(measurement.category) \(measurement.candidate) \(measurement.size)"
        )
        try validateDigest(measurement.digest, label: "\(measurement.category) \(measurement.candidate)")
    }
    for recommendation in report.recommendations {
        try require(!recommendation.category.isEmpty, "recommendation has empty category")
        try require(!recommendation.parameterName.isEmpty, "recommendation has empty parameter name")
        try require(!recommendation.recommendedValue.isEmpty, "recommendation has empty value")
        try require(
            recommendation.scoreGiBPerSecond.isFinite && recommendation.scoreGiBPerSecond >= 0,
            "recommendation has invalid score"
        )
    }
}

private func printAutotuneMeasurement(_ measurement: AutotuneMeasurement) {
    print(
        String(
            format: "| %@ | %@ | %@ | %@ | %.2f | %.2f | %.2f | %.2f | %@ |",
            measurement.category as NSString,
            measurement.candidate as NSString,
            measurement.size as NSString,
            measurement.parameterValueBytes.map(formatBytes) as NSString? ?? "n/a",
            measurement.medianGiBPerSecond,
            measurement.minimumGiBPerSecond,
            measurement.p95GiBPerSecond,
            measurement.maximumGiBPerSecond,
            (measurement.correct ? "ok" : "FAIL") as NSString
        )
    )
}

private func runMetalAutotune() throws {
    guard let device = MTLCreateSystemDefaultDevice() else {
        throw BLAKE3Error.metalUnavailable
    }

    let librarySource = metalLibrarySource()
    let sizes = autotuneSizes()
    let iterations = autotuneIterations()
    let gateCandidates = autotuneGateCandidates()
    let modeCandidates = autotuneModeCandidates()
    let tileCandidates = autotuneTileCandidates()
    let includeFileTiles = includesAutotuneFileTileSweep()

    var measurements = [AutotuneMeasurement]()
    var gateScores = [Int: [Double]]()
    var modeScores = [String: [Double]]()
    var tileScores = [Int: [Double]]()

    print("BLAKE3 Swift Metal autotune")
    print("metalDevice=\(device.name)")
    print("metalLibrary=\(metalLibraryDescription(librarySource))")
    print("sizes=\(sizes.map(formatBytes).joined(separator: ", "))")
    print("iterations=\(iterations)")
    print("gateCandidates=\(gateCandidates.map(formatBytes).joined(separator: ", "))")
    print("modeCandidates=\(modeCandidates.map(\.labelComponent).joined(separator: ","))")
    if includeFileTiles {
        print("tileCandidates=\(tileCandidates.map(formatBytes).joined(separator: ", "))")
    }
    print("")
    print("| Category | Candidate | Size | Parameter | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |")
    print("| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | --- |")

    for size in sizes {
        let label = formatBytes(size)
        var input = [UInt8](repeating: 0, count: size)
        fillDeterministically(&input)
        let expectedDigest = input.withUnsafeBytes { hashScalarForBenchmark($0) }
        let cpuContext = BLAKE3.Context()
        let cpuBaseline = runRawBenchmark(
            backend: "cpu",
            mode: "context-auto",
            input: input,
            iterations: iterations
        ) { rawInput in
            cpuContext.hash(rawInput, mode: .automatic)
        }
        let cpuMeasurement = makeAutotuneMeasurement(
            category: "cpu-baseline",
            candidate: "context-auto",
            parameterName: nil,
            parameterValueBytes: nil,
            label: label,
            result: cpuBaseline,
            expectedDigest: expectedDigest
        )
        measurements.append(cpuMeasurement)
        printAutotuneMeasurement(cpuMeasurement)

        guard let residentBuffer = makeMetalBuffer(device: device, input: input) else {
            throw BLAKE3Error.metalCommandFailed("Unable to allocate resident autotune buffer.")
        }

        for gate in gateCandidates {
            let context = try BLAKE3Metal.makeContext(
                device: device,
                minimumGPUByteCount: gate,
                librarySource: librarySource
            )
            let result = try runThrowingBenchmark(
                backend: "metal-autotune",
                mode: "resident-auto-gate-\(gate)",
                input: input,
                iterations: iterations
            ) { _ in
                try context.hash(buffer: residentBuffer, length: size, policy: .automatic)
            }
            let measurement = makeAutotuneMeasurement(
                category: "minimum-gpu-bytes",
                candidate: "resident-auto",
                parameterName: "minimum_gpu_bytes",
                parameterValueBytes: gate,
                label: label,
                result: result,
                expectedDigest: expectedDigest
            )
            measurements.append(measurement)
            gateScores[gate, default: []].append(measurement.medianGiBPerSecond)
            printAutotuneMeasurement(measurement)
        }

        let modeContext = try BLAKE3Metal.makeContext(
            device: device,
            minimumGPUByteCount: metalMinimumGPUByteCount(),
            librarySource: librarySource
        )

        for mode in modeCandidates {
            let candidate = "\(mode.labelComponent)-gpu"
            let result: BenchmarkResult?
            switch mode {
            case .resident:
                result = try runThrowingBenchmark(
                    backend: "metal-autotune",
                    mode: candidate,
                    input: input,
                    iterations: iterations
                ) { _ in
                    try modeContext.hash(buffer: residentBuffer, length: size, policy: .gpu)
                }
            case .privateResident:
                guard size > BLAKE3.chunkByteCount else {
                    result = nil
                    break
                }
                let privateBuffer = try modeContext.makePrivateBuffer(input: input)
                result = try runThrowingBenchmark(
                    backend: "metal-autotune",
                    mode: candidate,
                    input: input,
                    iterations: iterations
                ) { _ in
                    try modeContext.hash(privateBuffer: privateBuffer, policy: .gpu)
                }
            case .privateStaged:
                guard size > BLAKE3.chunkByteCount else {
                    result = nil
                    break
                }
                let privateBuffer = try modeContext.makePrivateBuffer(capacity: size)
                let stagingBuffer = try modeContext.makeStagingBuffer(capacity: size)
                result = try runThrowingBenchmark(
                    backend: "metal-autotune",
                    mode: candidate,
                    input: input,
                    iterations: iterations
                ) { bytes in
                    try modeContext.hash(
                        input: bytes,
                        using: stagingBuffer,
                        privateBuffer: privateBuffer,
                        policy: .gpu
                    )
                }
            case .staged:
                let stagingBuffer = try modeContext.makeStagingBuffer(capacity: size)
                result = try runThrowingBenchmark(
                    backend: "metal-autotune",
                    mode: candidate,
                    input: input,
                    iterations: iterations
                ) { bytes in
                    try modeContext.hash(input: bytes, using: stagingBuffer, policy: .gpu)
                }
            case .wrapped:
                result = try runThrowingBenchmark(
                    backend: "metal-autotune",
                    mode: candidate,
                    input: input,
                    iterations: iterations
                ) { bytes in
                    try modeContext.hash(input: bytes, policy: .gpu)
                }
            case .endToEnd:
                result = try runThrowingBenchmark(
                    backend: "metal-autotune",
                    mode: candidate,
                    input: input,
                    iterations: iterations
                ) { bytes in
                    guard let buffer = makeMetalBuffer(device: device, input: bytes) else {
                        throw BLAKE3Error.metalCommandFailed("Unable to allocate end-to-end autotune buffer.")
                    }
                    return try modeContext.hash(buffer: buffer, length: size, policy: .gpu)
                }
            }

            guard let result else {
                continue
            }
            let measurement = makeAutotuneMeasurement(
                category: "metal-mode",
                candidate: candidate,
                parameterName: "mode",
                parameterValueBytes: nil,
                label: label,
                result: result,
                expectedDigest: expectedDigest
            )
            measurements.append(measurement)
            modeScores[candidate, default: []].append(measurement.medianGiBPerSecond)
            printAutotuneMeasurement(measurement)
        }

        if includeFileTiles {
            let fileURL = try makeBenchmarkFile(input: input, byteCount: size)
            defer {
                try? FileManager.default.removeItem(at: fileURL)
                try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
            }
            for tile in tileCandidates {
                let result = try runFileBenchmark(
                    backend: "metal-autotune-file",
                    mode: "metal-tiled-mmap-tile-\(tile)",
                    path: fileURL.path,
                    byteCount: size,
                    iterations: iterations
                ) { path in
                    try BLAKE3File.hash(
                        path: path,
                        strategy: .metalTiledMemoryMapped(
                            tileByteCount: tile,
                            fallbackToCPU: false,
                            librarySource: librarySource
                        )
                    )
                }
                let measurement = makeAutotuneMeasurement(
                    category: "metal-file-tile",
                    candidate: "metal-tiled-mmap",
                    parameterName: "tile_bytes",
                    parameterValueBytes: tile,
                    label: label,
                    result: result,
                    expectedDigest: expectedDigest
                )
                measurements.append(measurement)
                tileScores[tile, default: []].append(measurement.medianGiBPerSecond)
                printAutotuneMeasurement(measurement)
            }
        }
    }

    var recommendations = [AutotuneRecommendation]()
    if let bestGate = bestScoredCandidate(gateScores) {
        recommendations.append(
            AutotuneRecommendation(
                category: "minimum-gpu-bytes",
                parameterName: "minimum_gpu_bytes",
                recommendedValue: formatBytes(bestGate.key),
                recommendedValueBytes: bestGate.key,
                scoreGiBPerSecond: bestGate.score,
                rationale: "Highest geometric mean resident-auto throughput across autotune sizes."
            )
        )
    }
    if let bestMode = bestScoredCandidate(modeScores) {
        recommendations.append(
            AutotuneRecommendation(
                category: "metal-mode",
                parameterName: "mode",
                recommendedValue: bestMode.key,
                recommendedValueBytes: nil,
                scoreGiBPerSecond: bestMode.score,
                rationale: "Highest geometric mean forced-GPU throughput across autotune sizes; compare timing class before publishing."
            )
        )
    }
    if let bestTile = bestScoredCandidate(tileScores) {
        recommendations.append(
            AutotuneRecommendation(
                category: "metal-file-tile",
                parameterName: "tile_bytes",
                recommendedValue: formatBytes(bestTile.key),
                recommendedValueBytes: bestTile.key,
                scoreGiBPerSecond: bestTile.score,
                rationale: "Highest geometric mean tiled Metal file throughput across autotune sizes."
            )
        )
    }

    let report = AutotuneReport(
        schemaVersion: 1,
        generatedAtUTC: generatedTimestampUTC(),
        commandLine: CommandLine.arguments,
        environment: AutotuneEnvironment(
            backend: BLAKE3.activeBackend.rawValue,
            simdDegree: BLAKE3.simdDegree,
            parallelSIMDDegree: BLAKE3.parallelSIMDDegree,
            defaultParallelWorkers: BLAKE3.defaultParallelWorkerCount,
            metalDevice: device.name,
            metalLibrary: metalLibraryDescription(librarySource)
        ),
        request: AutotuneRequest(
            sizes: sizes.map(formatBytes),
            sizesBytes: sizes,
            iterations: iterations,
            gateCandidatesBytes: gateCandidates,
            modeCandidates: modeCandidates.map(\.labelComponent),
            tileCandidatesBytes: includeFileTiles ? tileCandidates : [],
            includesFileTileSweep: includeFileTiles
        ),
        measurements: measurements,
        recommendations: recommendations
    )
    try validate(report)

    print("")
    print("| Recommendation | Value | Score GiB/s | Rationale |")
    print("| --- | --- | ---: | --- |")
    for recommendation in recommendations {
        print(
            String(
                format: "| %@ | %@ | %.2f | %@ |",
                recommendation.parameterName as NSString,
                recommendation.recommendedValue as NSString,
                recommendation.scoreGiBPerSecond,
                recommendation.rationale as NSString
            )
        )
    }

    if let outputPath = autotuneOutputPath() {
        try writeAutotuneReport(report, to: outputPath)
        print("autotuneJsonOutput=\(outputPath)")
    }
}
#endif

#if canImport(Metal)
if hasArgument(named: "--print-metal-source") {
    print(BLAKE3Metal.kernelSource)
    Darwin.exit(0)
}
if let validationPath = autotuneValidationPath() {
    do {
        try validateAutotuneReport(at: validationPath)
        print("autotuneJsonValidation=ok path=\(validationPath)")
        Darwin.exit(0)
    } catch {
        fputs("autotuneJsonValidation=FAIL path=\(validationPath) error=\(error)\n", stderr)
        Darwin.exit(1)
    }
}
if hasArgument(named: "--autotune-metal") {
    do {
        try runMetalAutotune()
        Darwin.exit(0)
    } catch {
        fputs("autotuneMetal=FAIL error=\(error)\n", stderr)
        Darwin.exit(1)
    }
}
#endif
if let validationPath = jsonValidationPath() {
    do {
        try validateJSONReport(at: validationPath)
        print("jsonValidation=ok path=\(validationPath)")
        Darwin.exit(0)
    } catch {
        fputs("jsonValidation=FAIL path=\(validationPath) error=\(error)\n", stderr)
        Darwin.exit(1)
    }
}

print("BLAKE3 Swift benchmark")
print(
    "backend=\(BLAKE3.activeBackend.rawValue) simdDegree=\(BLAKE3.simdDegree) " +
        "parallelSIMDDegree=\(BLAKE3.parallelSIMDDegree) " +
        "defaultParallelWorkers=\(BLAKE3.defaultParallelWorkerCount) " +
        "hasherBytes=\(BLAKE3.nativeHasherByteCount) " +
        "defaultBackendPolicy=\(BLAKE3.defaultBackendPolicy.rawValue) " +
        "defaultMetalMinimumBytes=\(BLAKE3.defaultMetalMinimumByteCount)"
)
print("officialCVersion=\(OfficialCBLAKE3.version)")
private let requestedSizes = benchmarkSizes()
private let requestedIterationsOverride = iterationsOverride()
private let requestedJSONOutputPath = jsonOutputPath()
private let requestedFileTimingModes = fileTimingModes()
#if canImport(Metal)
private let requestedMetalLibrarySource = metalLibrarySource()
private let requestedMetalMinimumGPUByteCount = metalMinimumGPUByteCount()
private let requestedMetalTileByteCount = metalTileByteCount()
private let requestedMetalTimingModes = metalTimingModes()
private let requestedMetalFileTiming = requestedFileTimingModes.contains(.metalMemoryMapped)
    || requestedFileTimingModes.contains(.metalTiledMemoryMapped)
private let requestedMetalWork = !requestedMetalTimingModes.isEmpty || requestedMetalFileTiming
let metalDevice = MTLCreateSystemDefaultDevice()
let metalContext: BLAKE3Metal.Context?
let metalContextError: Error?
if let metalDevice, requestedMetalWork {
    do {
        metalContext = try BLAKE3Metal.makeContext(
            device: metalDevice,
            minimumGPUByteCount: requestedMetalMinimumGPUByteCount,
            librarySource: requestedMetalLibrarySource
        )
        metalContextError = nil
    } catch {
        metalContext = nil
        metalContextError = error
    }
} else {
    metalContext = nil
    metalContextError = nil
}
if let metalDevice {
    print("metalDevice=\(metalDevice.name)")
    print("metalLibrary=\(metalLibraryDescription(requestedMetalLibrarySource))")
    print("metalMinimumGPUByteCount=\(requestedMetalMinimumGPUByteCount)")
    print("metalTileByteCount=\(requestedMetalTileByteCount)")
    print("metalModes=\(requestedMetalTimingModes.map(\.rawValue).joined(separator: ","))")
    if let metalContextError {
        print("metalLibraryError=\(metalContextError)")
        if requestedMetalWork {
            fatalError("Metal context creation failed for requested Metal benchmark/file modes.")
        }
    }
    if requestedMetalTimingModes.contains(.resident) {
        print("metal-resident includes: \(MetalTimingMode.resident.description)")
    }
    if requestedMetalTimingModes.contains(.privateResident) {
        print("metal-private includes: \(MetalTimingMode.privateResident.description)")
    }
    if requestedMetalTimingModes.contains(.privateStaged) {
        print("metal-private-staged includes: \(MetalTimingMode.privateStaged.description)")
    }
    if requestedMetalTimingModes.contains(.staged) {
        print("metal-staged includes: \(MetalTimingMode.staged.description)")
    }
    if requestedMetalTimingModes.contains(.wrapped) {
        print("metal-wrapped includes: \(MetalTimingMode.wrapped.description)")
    }
    if requestedMetalTimingModes.contains(.endToEnd) {
        print("metal-e2e includes: \(MetalTimingMode.endToEnd.description)")
    }
}
#endif
print("sizes=\(requestedSizes.map(formatBytes).joined(separator: ", "))")
if !requestedFileTimingModes.isEmpty {
    print("fileModes=\(requestedFileTimingModes.map(\.rawValue).joined(separator: ","))")
    for mode in requestedFileTimingModes {
        print("file-\(mode.rawValue) includes: \(mode.description)")
    }
}
if let cpuWorkers = cpuWorkerCount() {
    print("cpuWorkers=\(cpuWorkers)")
}
if reportsMemoryStats() {
    print("memoryStats=rss,allocator")
}
print("")
print("| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |")
print("| --- | --- | --- | ---: | ---: | ---: | ---: | --- |")

private var memorySamples = [MemorySample]()
private var benchmarkRows = [BenchmarkRow]()
private var sustainedRows = [SustainedRow]()

for size in requestedSizes {
    let iterations = iterationCount(for: size)
    let cpuWorkers = cpuWorkerCount()
    let label = formatBytes(size)
    recordMemoryStats(size: label, phase: "before-input", into: &memorySamples)

    var input = [UInt8](repeating: 0, count: size)
    fillDeterministically(&input)
    recordMemoryStats(size: label, phase: "after-input", into: &memorySamples)

    let scalar = runRawBenchmark(
        backend: "cpu",
        mode: "scalar",
        input: input,
        iterations: iterations,
        operation: hashScalarForBenchmark
    )
    let single = runRawBenchmark(
        backend: "cpu",
        mode: "single-simd",
        input: input,
        iterations: iterations,
        operation: hashSingleForBenchmark
    )
    let parallel = runRawBenchmark(
        backend: "cpu",
        mode: cpuWorkers.map { "parallel-\($0)" } ?? "parallel",
        input: input,
        iterations: iterations,
    ) { rawInput in
        hashParallelForBenchmark(rawInput, maxWorkers: cpuWorkers)
    }
    let officialC = runRawBenchmark(
        backend: "official-c",
        mode: "one-shot",
        input: input,
        iterations: iterations,
        operation: hashOfficialCForBenchmark
    )
    let cpuContext = BLAKE3.Context()
    let cpuContextAuto = runRawBenchmark(
        backend: "cpu",
        mode: "context-auto",
        input: input,
        iterations: iterations
    ) { rawInput in
        cpuContext.hash(rawInput, mode: .automatic)
    }
    let defaultAuto = runRawBenchmark(
        backend: "blake3",
        mode: "default-auto",
        input: input,
        iterations: iterations
    ) { rawInput in
        BLAKE3.hash(rawInput)
    }

    var fileResults = [BenchmarkResult]()
    if !requestedFileTimingModes.isEmpty {
        let fileURL: URL
        do {
            fileURL = try makeBenchmarkFile(input: input, byteCount: size)
        } catch {
            fatalError("failed to create benchmark file for \(label): \(error)")
        }
        defer {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: fileURL.deletingLastPathComponent())
        }

        let path = fileURL.path
        do {
            if requestedFileTimingModes.contains(.read) {
                fileResults.append(
                    try runFileBenchmark(
                        backend: "cpu-file",
                        mode: "read",
                        path: path,
                        byteCount: size,
                        iterations: iterations
                    ) { path in
                        try BLAKE3File.hash(path: path, strategy: .read())
                    }
                )
            }
            if requestedFileTimingModes.contains(.memoryMapped) {
                fileResults.append(
                    try runFileBenchmark(
                        backend: "cpu-file",
                        mode: "mmap",
                        path: path,
                        byteCount: size,
                        iterations: iterations
                    ) { path in
                        try BLAKE3File.hash(path: path, strategy: .memoryMapped)
                    }
                )
            }
            if requestedFileTimingModes.contains(.memoryMappedParallel) {
                fileResults.append(
                    try runFileBenchmark(
                        backend: "cpu-file",
                        mode: cpuWorkers.map { "mmap-parallel-\($0)" } ?? "mmap-parallel",
                        path: path,
                        byteCount: size,
                        iterations: iterations
                    ) { path in
                        try BLAKE3File.hash(
                            path: path,
                            strategy: .memoryMappedParallel(maxThreads: cpuWorkers)
                        )
                    }
                )
            }
            #if canImport(Metal)
            if requestedFileTimingModes.contains(.metalMemoryMapped), metalDevice != nil {
                fileResults.append(
                    try runFileBenchmark(
                        backend: "metal-file",
                        mode: "metal-mmap-gpu",
                        path: path,
                        byteCount: size,
                        iterations: iterations
                    ) { path in
                        try BLAKE3File.hash(
                            path: path,
                            strategy: .metalMemoryMapped(
                                policy: .gpu,
                                fallbackToCPU: false,
                                librarySource: requestedMetalLibrarySource
                            )
                        )
                    }
                )
            }
            if requestedFileTimingModes.contains(.metalTiledMemoryMapped), metalDevice != nil {
                fileResults.append(
                    try runFileBenchmark(
                        backend: "metal-file",
                        mode: "metal-tiled-mmap-gpu",
                        path: path,
                        byteCount: size,
                        iterations: iterations
                    ) { path in
                        try BLAKE3File.hash(
                            path: path,
                            strategy: .metalTiledMemoryMapped(
                                tileByteCount: requestedMetalTileByteCount,
                                fallbackToCPU: false,
                                librarySource: requestedMetalLibrarySource
                            )
                        )
                    }
                )
            }
            #endif
        } catch {
            fatalError("file benchmark failed for \(label): \(error)")
        }
    }

    #if canImport(Metal)
    var metalAuto: BenchmarkResult?
    var metalGPU: BenchmarkResult?
    var metalPrivateGPU: BenchmarkResult?
    var metalPrivateStagedGPU: BenchmarkResult?
    var metalStagedAuto: BenchmarkResult?
    var metalStagedGPU: BenchmarkResult?
    var metalWrappedAuto: BenchmarkResult?
    var metalWrappedGPU: BenchmarkResult?
    var metalE2EAuto: BenchmarkResult?
    var metalE2EGPU: BenchmarkResult?
    if let metalDevice,
       let metalContext,
       let metalBuffer = makeMetalBuffer(device: metalDevice, input: input) {
        if requestedMetalTimingModes.contains(.resident) {
            metalAuto = runBenchmark(
                backend: "metal",
                mode: "resident-auto",
                input: input,
                iterations: iterations
            ) { _ in
                hashMetalAutoForBenchmark(context: metalContext, buffer: metalBuffer, length: size)
            }
            metalGPU = runBenchmark(
                backend: "metal",
                mode: "resident-gpu",
                input: input,
                iterations: iterations
            ) { _ in
                hashMetalGPUForBenchmark(context: metalContext, buffer: metalBuffer, length: size)
            }
        }
        if requestedMetalTimingModes.contains(.privateResident),
           size > BLAKE3.chunkByteCount,
           let privateBuffer = try? metalContext.makePrivateBuffer(input: input) {
            metalPrivateGPU = runBenchmark(
                backend: "metal",
                mode: "private-gpu",
                input: input,
                iterations: iterations
            ) { _ in
                return try! metalContext.hash(privateBuffer: privateBuffer, policy: .gpu)
            }
        }
        if requestedMetalTimingModes.contains(.privateStaged),
           size > BLAKE3.chunkByteCount,
           let privateBuffer = try? metalContext.makePrivateBuffer(capacity: size),
           let privateStagingBuffer = try? metalContext.makeStagingBuffer(capacity: size) {
            metalPrivateStagedGPU = runBenchmark(
                backend: "metal",
                mode: "private-staged-gpu",
                input: input,
                iterations: iterations
            ) { bytes in
                try! metalContext.hash(
                    input: bytes,
                    using: privateStagingBuffer,
                    privateBuffer: privateBuffer,
                    policy: .gpu
                )
            }
        }
        if requestedMetalTimingModes.contains(.staged),
           let stagingBuffer = try? metalContext.makeStagingBuffer(capacity: size) {
            metalStagedAuto = runBenchmark(
                backend: "metal",
                mode: "staged-auto",
                input: input,
                iterations: iterations
            ) { bytes in
                try! metalContext.hash(input: bytes, using: stagingBuffer, policy: .automatic)
            }
            metalStagedGPU = runBenchmark(
                backend: "metal",
                mode: "staged-gpu",
                input: input,
                iterations: iterations
            ) { bytes in
                try! metalContext.hash(input: bytes, using: stagingBuffer, policy: .gpu)
            }
        }
        if requestedMetalTimingModes.contains(.wrapped) {
            metalWrappedAuto = runBenchmark(
                backend: "metal",
                mode: "wrapped-auto",
                input: input,
                iterations: iterations
            ) { bytes in
                try! metalContext.hash(input: bytes, policy: .automatic)
            }
            metalWrappedGPU = runBenchmark(
                backend: "metal",
                mode: "wrapped-gpu",
                input: input,
                iterations: iterations
            ) { bytes in
                try! metalContext.hash(input: bytes, policy: .gpu)
            }
        }
        if requestedMetalTimingModes.contains(.endToEnd) {
            metalE2EAuto = runBenchmark(
                backend: "metal",
                mode: "e2e-auto",
                input: input,
                iterations: iterations
            ) { bytes in
                let buffer = makeMetalBuffer(device: metalDevice, input: bytes)!
                return hashMetalAutoForBenchmark(context: metalContext, buffer: buffer, length: size)
            }
            metalE2EGPU = runBenchmark(
                backend: "metal",
                mode: "e2e-gpu",
                input: input,
                iterations: iterations
            ) { bytes in
                let buffer = makeMetalBuffer(device: metalDevice, input: bytes)!
                return hashMetalGPUForBenchmark(context: metalContext, buffer: buffer, length: size)
            }
        }
    }
    #endif

    var results = [scalar, single, parallel, officialC, cpuContextAuto, defaultAuto]
    results.append(contentsOf: fileResults)
    #if canImport(Metal)
    if let metalAuto {
        results.append(metalAuto)
    }
    if let metalGPU {
        results.append(metalGPU)
    }
    if let metalPrivateGPU {
        results.append(metalPrivateGPU)
    }
    if let metalPrivateStagedGPU {
        results.append(metalPrivateStagedGPU)
    }
    if let metalStagedAuto {
        results.append(metalStagedAuto)
    }
    if let metalStagedGPU {
        results.append(metalStagedGPU)
    }
    if let metalWrappedAuto {
        results.append(metalWrappedAuto)
    }
    if let metalWrappedGPU {
        results.append(metalWrappedGPU)
    }
    if let metalE2EAuto {
        results.append(metalE2EAuto)
    }
    if let metalE2EGPU {
        results.append(metalE2EGPU)
    }
    #endif
    for result in results {
        let stats = result.throughputStats
        let correct = result.digest == scalar.digest
        benchmarkRows.append(
            BenchmarkRow(
                size: label,
                byteCount: result.byteCount,
                backend: result.backend,
                mode: result.mode,
                iterations: result.sampleNanoseconds.count,
                sampleNanoseconds: result.sampleNanoseconds,
                medianGiBPerSecond: stats.median,
                minimumGiBPerSecond: stats.minimum,
                p95GiBPerSecond: stats.p95,
                maximumGiBPerSecond: stats.maximum,
                digest: result.digest.description,
                correct: correct
            )
        )
        print(
            String(
                format: "| %@ | %@ | %@ | %.2f | %.2f | %.2f | %.2f | %@ |",
                label as NSString,
                result.backend as NSString,
                result.mode as NSString,
                stats.median,
                stats.minimum,
                stats.p95,
                stats.maximum,
                (correct ? "ok" : "FAIL") as NSString
            )
        )
        if !correct {
            fatalError("\(result.backend) \(result.mode) digest mismatch for \(label)")
        }
    }

    #if canImport(Metal)
    if let sustainedDuration = sustainedSeconds(),
       let metalDevice,
       let metalContext {
        let mode = sustainedMode()
        let policy = sustainedPolicy()
        let policyLabel: String
        switch policy {
        case .automatic:
            policyLabel = "auto"
        case .gpu:
            policyLabel = "gpu"
        case .cpu:
            policyLabel = "cpu"
        }
        let name = "sustained-\(mode.labelComponent)-\(policyLabel)"
        let residentBuffer = makeMetalBuffer(device: metalDevice, input: input)
        let privateResidentBuffer = mode == .privateResident
            ? try? metalContext.makePrivateBuffer(input: input)
            : nil
        let privateStagedBuffer = mode == .privateStaged
            ? try? metalContext.makePrivateBuffer(capacity: size)
            : nil
        let privateStagedUploadBuffer = mode == .privateStaged
            ? try? metalContext.makeStagingBuffer(capacity: size)
            : nil
        let stagedBuffer = try? metalContext.makeStagingBuffer(capacity: size)
        let sustained = runSustainedMetal(
            name: name,
            byteCount: size,
            seconds: sustainedDuration,
            expectedDigest: scalar.digest
        ) {
            switch mode {
            case .resident:
                return try! metalContext.hash(buffer: residentBuffer!, length: size, policy: policy)
            case .privateResident:
                return try! metalContext.hash(privateBuffer: privateResidentBuffer!, policy: .gpu)
            case .privateStaged:
                return try! metalContext.hash(
                    input: input,
                    using: privateStagedUploadBuffer!,
                    privateBuffer: privateStagedBuffer!,
                    policy: .gpu
                )
            case .staged:
                return try! metalContext.hash(input: input, using: stagedBuffer!, policy: policy)
            case .wrapped:
                return try! metalContext.hash(input: input, policy: policy)
            case .endToEnd:
                let buffer = makeMetalBuffer(device: metalDevice, input: input)!
                return try! metalContext.hash(buffer: buffer, length: size, policy: policy)
            }
        }
        let sustainedCorrect = sustained.digest == scalar.digest
        sustainedRows.append(
            SustainedRow(
                size: label,
                byteCount: size,
                name: sustained.name,
                iterations: sustained.iterations,
                elapsedSeconds: sustained.elapsedSeconds,
                averageGiBPerSecond: sustained.averageGiBPerSecond,
                medianGiBPerSecond: sustained.throughputStats.median,
                minimumGiBPerSecond: sustained.throughputStats.minimum,
                p95GiBPerSecond: sustained.throughputStats.p95,
                maximumGiBPerSecond: sustained.throughputStats.maximum,
                firstQuarterGiBPerSecond: sustained.firstQuarterGiBPerSecond,
                lastQuarterGiBPerSecond: sustained.lastQuarterGiBPerSecond,
                digest: sustained.digest.description,
                correct: sustainedCorrect
            )
        )
        print(
            String(
                format: "%@  %-20@ %.1f s  avg %8.2f GiB/s  min %8.2f  median %8.2f  p95 %8.2f  max %8.2f  first25%% %8.2f  last25%% %8.2f  n %d  correct ok",
                label as NSString,
                sustained.name as NSString,
                sustained.elapsedSeconds,
                sustained.averageGiBPerSecond,
                sustained.throughputStats.minimum,
                sustained.throughputStats.median,
                sustained.throughputStats.p95,
                sustained.throughputStats.maximum,
                sustained.firstQuarterGiBPerSecond,
                sustained.lastQuarterGiBPerSecond,
                sustained.iterations
            )
        )
        if !sustainedCorrect {
            fatalError("\(sustained.name) digest mismatch for \(label)")
        }
    }
    #endif

    recordMemoryStats(size: label, phase: "after-size", into: &memorySamples)
}

printMemoryStats(memorySamples)

if let requestedJSONOutputPath {
    #if canImport(Metal)
    let reportMetalDevice = metalDevice?.name
    let reportMetalLibrary = metalDevice.map { _ in metalLibraryDescription(requestedMetalLibrarySource) }
    let reportMetalMinimumGPUByteCount = metalDevice.map { _ in requestedMetalMinimumGPUByteCount }
    let reportMetalTileByteCount = metalDevice.map { _ in requestedMetalTileByteCount }
    let reportMetalModes = requestedMetalTimingModes.map(\.rawValue)
    let reportSustainedSeconds = sustainedSeconds()
    #else
    let reportMetalDevice: String? = nil
    let reportMetalLibrary: String? = nil
    let reportMetalMinimumGPUByteCount: Int? = nil
    let reportMetalTileByteCount: Int? = nil
    let reportMetalModes: [String] = []
    let reportSustainedSeconds: Double? = nil
    #endif

    let report = BenchmarkReport(
        schemaVersion: 1,
        generatedAtUTC: generatedTimestampUTC(),
        commandLine: CommandLine.arguments,
        environment: BenchmarkEnvironment(
            backend: BLAKE3.activeBackend.rawValue,
            simdDegree: BLAKE3.simdDegree,
            parallelSIMDDegree: BLAKE3.parallelSIMDDegree,
            defaultParallelWorkers: BLAKE3.defaultParallelWorkerCount,
            hasherBytes: BLAKE3.nativeHasherByteCount,
            defaultBackendPolicy: BLAKE3.defaultBackendPolicy.rawValue,
            defaultMetalMinimumByteCount: BLAKE3.defaultMetalMinimumByteCount,
            metalDevice: reportMetalDevice,
            metalLibrary: reportMetalLibrary,
            metalMinimumGPUByteCount: reportMetalMinimumGPUByteCount,
            metalTileByteCount: reportMetalTileByteCount,
            metalModes: reportMetalModes,
            fileModes: requestedFileTimingModes.map(\.rawValue),
            cpuWorkers: cpuWorkerCount(),
            memoryStats: reportsMemoryStats()
        ),
        request: BenchmarkRequest(
            sizes: requestedSizes.map(formatBytes),
            sizesBytes: requestedSizes,
            iterationsOverride: requestedIterationsOverride,
            sustainedSeconds: reportSustainedSeconds
        ),
        rows: benchmarkRows,
        sustainedRows: sustainedRows,
        memorySamples: memorySamples
    )

    do {
        try writeJSONReport(report, to: requestedJSONOutputPath)
        print("jsonOutput=\(requestedJSONOutputPath)")
    } catch {
        fatalError("failed to write JSON benchmark report: \(error)")
    }
}
