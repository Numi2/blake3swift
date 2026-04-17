import Blake3
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
            return "pre-created shared staging and private MTLBuffers; timed Swift-byte copy into staging, blit into private storage, private hash, waits, digest read"
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
#endif

private func fillDeterministically(_ bytes: inout [UInt8]) {
    for index in bytes.indices {
        bytes[index] = UInt8(truncatingIfNeeded: (index &* 31) &+ 17)
    }
}

@inline(never)
private func hashScalarForBenchmark(_ input: [UInt8]) -> BLAKE3.Digest {
    BLAKE3.hashScalar(input)
}

@inline(never)
private func hashSingleForBenchmark(_ input: [UInt8]) -> BLAKE3.Digest {
    BLAKE3.hash(input)
}

@inline(never)
private func hashParallelForBenchmark(_ input: [UInt8]) -> BLAKE3.Digest {
    BLAKE3.hashParallel(input)
}

@inline(never)
private func hashParallelForBenchmark(_ input: [UInt8], maxWorkers: Int?) -> BLAKE3.Digest {
    BLAKE3.hashParallel(input, maxWorkers: maxWorkers)
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

private func withNoCopyMetalBuffer<R>(
    device: MTLDevice,
    input: [UInt8],
    _ body: (MTLBuffer) -> R
) -> R? {
    guard !input.isEmpty else {
        guard let buffer = device.makeBuffer(length: 1, options: .storageModeShared) else {
            return nil
        }
        return body(buffer)
    }
    return input.withUnsafeBytes { raw -> R? in
        guard let baseAddress = raw.baseAddress,
              let buffer = device.makeBuffer(
                bytesNoCopy: UnsafeMutableRawPointer(mutating: baseAddress),
                length: raw.count,
                options: .storageModeShared,
                deallocator: nil
              )
        else {
            return nil
        }
        return body(buffer)
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

print("BLAKE3 Swift benchmark")
print("backend=\(BLAKE3.activeBackend.rawValue) simdDegree=\(BLAKE3.simdDegree) parallelSIMDDegree=\(BLAKE3.parallelSIMDDegree) hasherBytes=\(BLAKE3.nativeHasherByteCount)")
private let requestedFileTimingModes = fileTimingModes()
#if canImport(Metal)
let metalDevice = MTLCreateSystemDefaultDevice()
let metalContext = metalDevice.flatMap { try? BLAKE3Metal.makeContext(device: $0) }
private let requestedMetalTimingModes = metalTimingModes()
if let metalDevice {
    print("metalDevice=\(metalDevice.name)")
    print("metalModes=\(requestedMetalTimingModes.map(\.rawValue).joined(separator: ","))")
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
print("sizes=\(benchmarkSizes().map(formatBytes).joined(separator: ", "))")
if !requestedFileTimingModes.isEmpty {
    print("fileModes=\(requestedFileTimingModes.map(\.rawValue).joined(separator: ","))")
    for mode in requestedFileTimingModes {
        print("file-\(mode.rawValue) includes: \(mode.description)")
    }
}
if let cpuWorkers = cpuWorkerCount() {
    print("cpuWorkers=\(cpuWorkers)")
}
print("")
print("| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |")
print("| --- | --- | --- | ---: | ---: | ---: | ---: | --- |")

for size in benchmarkSizes() {
    var input = [UInt8](repeating: 0, count: size)
    fillDeterministically(&input)

    let iterations = iterationCount(for: size)
    let cpuWorkers = cpuWorkerCount()
    let label = formatBytes(size)
    let scalar = runBenchmark(
        backend: "cpu",
        mode: "scalar",
        input: input,
        iterations: iterations,
        operation: hashScalarForBenchmark
    )
    let single = runBenchmark(
        backend: "cpu",
        mode: "single-simd",
        input: input,
        iterations: iterations,
        operation: hashSingleForBenchmark
    )
    let parallel = runBenchmark(
        backend: "cpu",
        mode: cpuWorkers.map { "parallel-\($0)" } ?? "parallel",
        input: input,
        iterations: iterations,
    ) { bytes in
        hashParallelForBenchmark(bytes, maxWorkers: cpuWorkers)
    }
    let cpuContext = BLAKE3.Context()
    let cpuContextAuto = runBenchmark(
        backend: "cpu",
        mode: "context-auto",
        input: input,
        iterations: iterations
    ) { bytes in
        cpuContext.hash(bytes, mode: .automatic)
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
                            strategy: .metalMemoryMapped(policy: .gpu, fallbackToCPU: false)
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
                            strategy: .metalTiledMemoryMapped(fallbackToCPU: false)
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
                try! metalContext.hash(privateBuffer: privateBuffer, policy: .gpu)
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
                try! metalContext.replaceContents(
                    of: privateBuffer,
                    with: bytes,
                    using: privateStagingBuffer
                )
                return try! metalContext.hash(privateBuffer: privateBuffer, policy: .gpu)
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
                withNoCopyMetalBuffer(device: metalDevice, input: bytes) { buffer in
                    hashMetalAutoForBenchmark(context: metalContext, buffer: buffer, length: size)
                }!
            }
            metalWrappedGPU = runBenchmark(
                backend: "metal",
                mode: "wrapped-gpu",
                input: input,
                iterations: iterations
            ) { bytes in
                withNoCopyMetalBuffer(device: metalDevice, input: bytes) { buffer in
                    hashMetalGPUForBenchmark(context: metalContext, buffer: buffer, length: size)
                }!
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

    var results = [scalar, single, parallel, cpuContextAuto]
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
                try! metalContext.replaceContents(
                    of: privateStagedBuffer!,
                    with: input,
                    using: privateStagedUploadBuffer!
                )
                return try! metalContext.hash(privateBuffer: privateStagedBuffer!, policy: .gpu)
            case .staged:
                return try! metalContext.hash(input: input, using: stagedBuffer!, policy: policy)
            case .wrapped:
                return withNoCopyMetalBuffer(device: metalDevice, input: input) { buffer in
                    try! metalContext.hash(buffer: buffer, length: size, policy: policy)
                }!
            case .endToEnd:
                let buffer = makeMetalBuffer(device: metalDevice, input: input)!
                return try! metalContext.hash(buffer: buffer, length: size, policy: policy)
            }
        }
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
    }
    #endif
}
