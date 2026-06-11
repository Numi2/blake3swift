import XCTest
@_spi(Benchmark) @testable import Blake3
import Blake3BenchmarkSupport
#if canImport(CryptoKit)
import CryptoKit
#endif
#if canImport(Metal)
import Metal
#endif

private struct TestVectors: Decodable {
    let key: String
    let contextString: String
    let cases: [TestCase]

    enum CodingKeys: String, CodingKey {
        case key
        case contextString = "context_string"
        case cases
    }
}

private struct TestCase: Decodable {
    let inputLength: Int
    let hash: String
    let keyedHash: String
    let deriveKey: String

    enum CodingKeys: String, CodingKey {
        case inputLength = "input_len"
        case hash
        case keyedHash = "keyed_hash"
        case deriveKey = "derive_key"
    }
}

final class BLAKE3Tests: XCTestCase {
    func testOfficialVectors() throws {
        let vectors = try loadTestVectors()
        let key = Array(vectors.key.utf8)
        XCTAssertEqual(key.count, BLAKE3.keyByteCount)

        for testCase in vectors.cases {
            let input = deterministicInput(byteCount: testCase.inputLength)
            let expectedHash = try decodeHex(testCase.hash)
            let expectedKeyedHash = try decodeHex(testCase.keyedHash)
            let expectedDerivedKey = try decodeHex(testCase.deriveKey)

            XCTAssertEqual(
                BLAKE3.hash(input).bytes,
                Array(expectedHash.prefix(BLAKE3.digestByteCount)),
                "default hash mismatch for input_len=\(testCase.inputLength)"
            )
            XCTAssertEqual(
                try BLAKE3.hash(input, outputByteCount: expectedHash.count),
                expectedHash,
                "default XOF convenience mismatch for input_len=\(testCase.inputLength)"
            )
            XCTAssertEqual(
                BLAKE3.hashParallel(input).bytes,
                Array(expectedHash.prefix(BLAKE3.digestByteCount)),
                "parallel hash mismatch for input_len=\(testCase.inputLength)"
            )
            XCTAssertEqual(
                try BLAKE3.keyedHash(key: key, input: input).bytes,
                Array(expectedKeyedHash.prefix(BLAKE3.digestByteCount)),
                "keyed hash mismatch for input_len=\(testCase.inputLength)"
            )
            XCTAssertEqual(
                try BLAKE3.keyedHash(key: key, input: input, outputByteCount: expectedKeyedHash.count),
                expectedKeyedHash,
                "keyed XOF convenience mismatch for input_len=\(testCase.inputLength)"
            )
            XCTAssertEqual(
                try BLAKE3.keyedHashParallel(key: key, input: input).bytes,
                Array(expectedKeyedHash.prefix(BLAKE3.digestByteCount)),
                "parallel keyed hash mismatch for input_len=\(testCase.inputLength)"
            )
            XCTAssertEqual(
                try BLAKE3.keyedHashParallel(key: key, input: input, outputByteCount: expectedKeyedHash.count),
                expectedKeyedHash,
                "parallel keyed XOF convenience mismatch for input_len=\(testCase.inputLength)"
            )
            XCTAssertEqual(
                try BLAKE3.deriveKey(
                    context: vectors.contextString,
                    material: input,
                    outputByteCount: expectedDerivedKey.count
                ),
                expectedDerivedKey,
                "derive_key mismatch for input_len=\(testCase.inputLength)"
            )
            XCTAssertEqual(
                try BLAKE3.deriveKeyParallel(
                    context: vectors.contextString,
                    material: input,
                    outputByteCount: expectedDerivedKey.count
                ),
                expectedDerivedKey,
                "parallel derive_key mismatch for input_len=\(testCase.inputLength)"
            )

            var hasher = BLAKE3.Hasher()
            update(&hasher, with: input, splitAt: testCase.inputLength / 2)
            XCTAssertEqual(
                hasher.finalize().bytes,
                Array(expectedHash.prefix(BLAKE3.digestByteCount)),
                "incremental hash mismatch for input_len=\(testCase.inputLength)"
            )

            var outputReader = hasher.finalizeXOF()
            var xof = [UInt8](repeating: 0, count: expectedHash.count)
            xof.withUnsafeMutableBytes { outputReader.read(into: $0) }
            XCTAssertEqual(
                xof,
                expectedHash,
                "hash XOF mismatch for input_len=\(testCase.inputLength)"
            )

            var keyedHasher = try BLAKE3.Hasher(key: key)
            update(&keyedHasher, with: input, splitAt: max(0, testCase.inputLength - 1))
            var keyedXOFReader = keyedHasher.finalizeXOF()
            var keyedXOF = [UInt8](repeating: 0, count: expectedKeyedHash.count)
            keyedXOF.withUnsafeMutableBytes { keyedXOFReader.read(into: $0) }
            XCTAssertEqual(
                keyedXOF,
                expectedKeyedHash,
                "keyed XOF mismatch for input_len=\(testCase.inputLength)"
            )
        }
    }

    func testOutputReaderSeek() throws {
        let input = deterministicInput(byteCount: 65_537)
        var hasher = BLAKE3.Hasher()
        hasher.update(input)

        var fullReader = hasher.finalizeXOF()
        var fullOutput = [UInt8](repeating: 0, count: 256)
        fullOutput.withUnsafeMutableBytes { fullReader.read(into: $0) }

        var seekReader = hasher.finalizeXOF()
        seekReader.seek(to: 96)
        var suffix = [UInt8](repeating: 0, count: 80)
        suffix.withUnsafeMutableBytes { seekReader.read(into: $0) }

        XCTAssertEqual(suffix, Array(fullOutput[96..<176]))
    }

    func testHasherCopyOnWrite() {
        let prefix = deterministicInput(byteCount: 2_048)
        let leftSuffix = deterministicInput(byteCount: 17)
        let rightSuffix = deterministicInput(byteCount: 31)

        var left = BLAKE3.Hasher()
        left.update(prefix)
        var right = left

        left.update(leftSuffix)
        right.update(rightSuffix)

        XCTAssertEqual(left.finalize(), BLAKE3.hash(prefix + leftSuffix))
        XCTAssertEqual(right.finalize(), BLAKE3.hash(prefix + rightSuffix))
    }

    func testStreamingHasherUsesBoundedCVStackAcrossBoundaries() {
        let sizes = [
            0,
            1,
            1_023,
            1_024,
            1_025,
            2_047,
            2_048,
            2_049,
            16 * 1_024 - 1,
            16 * 1_024,
            16 * 1_024 + 1,
            1 * 1_024 * 1_024 + 123
        ]
        let splitPattern = [1, 3, 7, 64, 1_023, 2_049, 65_537]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            var hasher = BLAKE3.Hasher()
            var offset = 0
            var splitIndex = 0
            while offset < input.count {
                let step = splitPattern[splitIndex % splitPattern.count]
                let end = min(input.count, offset + step)
                hasher.update(input[offset..<end])
                offset = end
                splitIndex += 1
            }

            XCTAssertEqual(hasher.finalize(), BLAKE3.hash(input), "streaming mismatch for byteCount=\(size)")
            XCTAssertLessThanOrEqual(
                hasher._debugRetainedTreeNodeCount,
                UInt64.bitWidth + 1,
                "streaming retained too many tree nodes for byteCount=\(size)"
            )
        }
    }

    func testParallelUpdateMatchesSerialForLargeInput() {
        let input = deterministicInput(byteCount: 1 * 1024 * 1024 + 333)
        var serial = BLAKE3.Hasher()
        serial.update(input)

        var parallel = BLAKE3.Hasher()
        parallel.updateParallel(input, maxWorkers: 2)

        XCTAssertEqual(parallel.finalize(), serial.finalize())
        XCTAssertEqual(BLAKE3.hashParallel(input), BLAKE3.hash(input))
    }

    func testParallelStreamingAcrossExactTileBoundaries() {
        let tileByteCount = 512 * 1_024
        let input = deterministicInput(byteCount: tileByteCount * 3 + 333)
        var hasher = BLAKE3.Hasher()

        input.withUnsafeBytes { raw in
            var offset = 0
            while offset < raw.count {
                let byteCount = min(tileByteCount, raw.count - offset)
                let tile = UnsafeRawBufferPointer(
                    start: raw.baseAddress!.advanced(by: offset),
                    count: byteCount
                )
                if offset + byteCount < raw.count {
                    hasher._updateParallelNonFinal(tile, maxWorkers: 2)
                } else {
                    hasher.updateParallel(tile, maxWorkers: 2)
                }
                offset += byteCount
            }
        }

        XCTAssertEqual(hasher.finalize(), BLAKE3.hash(input))
        XCTAssertLessThanOrEqual(
            hasher._debugRetainedTreeNodeCount,
            UInt64.bitWidth + 1
        )
    }

    func testParallelOneShotMatchesSerialAcrossTreeShapes() throws {
        let key = Array("whats the Elvish word for friend".utf8)
        let sizes = [
            256 * 1024 + 1,
            300 * 1024 + 17,
            1024 * 1024 + 333
        ]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            XCTAssertEqual(
                BLAKE3.hashParallel(input),
                BLAKE3.hash(input),
                "parallel hash mismatch for byteCount=\(size)"
            )
            XCTAssertEqual(
                try BLAKE3.keyedHashParallel(key: key, input: input),
                try BLAKE3.keyedHash(key: key, input: input),
                "parallel keyed hash mismatch for byteCount=\(size)"
            )
        }
    }

    func testDefaultOneShotMatchesExplicitCPUForTreeInput() {
        let sizes = [
            1 * 1_024 * 1_024 + 333
        ]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            let expected = BLAKE3.hashCPU(input)
            XCTAssertEqual(BLAKE3.hash(input), expected, "default hash mismatch for byteCount=\(size)")
            XCTAssertEqual(BLAKE3.hashSerial(input), expected, "serial hash mismatch for byteCount=\(size)")
        }
    }

    func testOfficialCBLAKE3DifferentialHashes() {
        let sizes = [
            0,
            1,
            63,
            64,
            65,
            1_023,
            1_024,
            1_025,
            2_047,
            2_048,
            2_049,
            4_095,
            4_096,
            4_097,
            16_383,
            16_384,
            16_385,
            65_535,
            65_536,
            65_537,
            256 * 1_024 - 1,
            256 * 1_024,
            256 * 1_024 + 1,
            1_024 * 1_024 + 333,
            1 * 1_024 * 1_024 + 777
        ]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            let expected = input.withUnsafeBytes { OfficialCBLAKE3.hash($0) }

            XCTAssertEqual(
                BLAKE3.hash(input),
                expected,
                "default hash mismatch against official C for byteCount=\(size)"
            )
            XCTAssertEqual(
                BLAKE3.hashSerial(input),
                expected,
                "serial hash mismatch against official C for byteCount=\(size)"
            )
            XCTAssertEqual(
                BLAKE3.hashScalar(input),
                expected,
                "scalar hash mismatch against official C for byteCount=\(size)"
            )
            XCTAssertEqual(
                BLAKE3.hashParallel(input, maxWorkers: 2),
                expected,
                "parallel hash mismatch against official C for byteCount=\(size)"
            )

            var hasher = BLAKE3.Hasher()
            update(&hasher, with: input, splitPattern: [1, 63, 64, 65, 1_023, 1_024, 1_025, 4_097])
            XCTAssertEqual(
                hasher.finalize(),
                expected,
                "streaming hash mismatch against official C for byteCount=\(size)"
            )
        }
    }

    func testPublicSwiftSurfacesMatchOfficialCBLAKE3() throws {
        let key = deterministicInput(byteCount: BLAKE3.keyByteCount)
        let contextString = "blake3swift vendored differential context"
        let sizes = [
            0,
            1,
            63,
            64,
            65,
            1_023,
            1_024,
            1_025,
            16_384 + 1,
            256 * 1_024 + 1,
            1_024 * 1_024 + 333
        ]
        let xofOutputByteCount = 257
        let xofSeek: UInt64 = 17

        try withTemporaryDirectory(prefix: "blake3swift-official-c-public-") { directory in
            for size in sizes {
                let input = deterministicInput(byteCount: size)
                let expectedDigest = input.withUnsafeBytes { OfficialCBLAKE3.hash($0) }
                let expectedXOFNoSeek = input.withUnsafeBytes {
                    OfficialCBLAKE3.hash($0, outputByteCount: xofOutputByteCount)
                }
                let expectedXOF = input.withUnsafeBytes {
                    OfficialCBLAKE3.hash($0, outputByteCount: xofOutputByteCount, seek: xofSeek)
                }
                let expectedKeyedDigest = key.withUnsafeBytes { keyRaw in
                    input.withUnsafeBytes { inputRaw in
                        OfficialCBLAKE3.keyedHash(key: keyRaw, input: inputRaw)
                    }
                }
                let expectedKeyedXOFNoSeek = key.withUnsafeBytes { keyRaw in
                    input.withUnsafeBytes { inputRaw in
                        OfficialCBLAKE3.keyedHash(
                            key: keyRaw,
                            input: inputRaw,
                            outputByteCount: xofOutputByteCount
                        )
                    }
                }
                let expectedKeyedXOF = key.withUnsafeBytes { keyRaw in
                    input.withUnsafeBytes { inputRaw in
                        OfficialCBLAKE3.keyedHash(
                            key: keyRaw,
                            input: inputRaw,
                            outputByteCount: xofOutputByteCount,
                            seek: xofSeek
                        )
                    }
                }
                let expectedDerivedNoSeek = contextString.utf8CString.withUnsafeBytes { contextRaw in
                    input.withUnsafeBytes { inputRaw in
                        OfficialCBLAKE3.deriveKey(
                            context: UnsafeRawBufferPointer(rebasing: contextRaw.dropLast()),
                            material: inputRaw,
                            outputByteCount: xofOutputByteCount
                        )
                    }
                }
                let expectedDerived = contextString.utf8CString.withUnsafeBytes { contextRaw in
                    input.withUnsafeBytes { inputRaw in
                        OfficialCBLAKE3.deriveKey(
                            context: UnsafeRawBufferPointer(rebasing: contextRaw.dropLast()),
                            material: inputRaw,
                            outputByteCount: xofOutputByteCount,
                            seek: xofSeek
                        )
                    }
                }

                XCTAssertEqual(BLAKE3.hash(input), expectedDigest, "one-shot mismatch for byteCount=\(size)")
                XCTAssertEqual(BLAKE3.hashSerial(input), expectedDigest, "serial mismatch for byteCount=\(size)")
                XCTAssertEqual(BLAKE3.hashScalar(input), expectedDigest, "scalar mismatch for byteCount=\(size)")
                XCTAssertEqual(
                    BLAKE3.hashParallel(input, maxWorkers: 2),
                    expectedDigest,
                    "parallel mismatch for byteCount=\(size)"
                )
                XCTAssertEqual(
                    try BLAKE3.hash(input, outputByteCount: xofOutputByteCount),
                    expectedXOFNoSeek,
                    "XOF convenience mismatch for byteCount=\(size)"
                )
                XCTAssertEqual(
                    try BLAKE3.keyedHash(key: key, input: input),
                    expectedKeyedDigest,
                    "keyed digest mismatch for byteCount=\(size)"
                )
                XCTAssertEqual(
                    try BLAKE3.keyedHash(
                        key: key,
                        input: input,
                        outputByteCount: xofOutputByteCount
                    ),
                    expectedKeyedXOFNoSeek,
                    "keyed XOF convenience mismatch for byteCount=\(size)"
                )
                XCTAssertEqual(
                    try BLAKE3.keyedHashParallel(key: key, input: input),
                    expectedKeyedDigest,
                    "parallel keyed digest mismatch for byteCount=\(size)"
                )
                XCTAssertEqual(
                    try BLAKE3.keyedHashParallel(
                        key: key,
                        input: input,
                        outputByteCount: xofOutputByteCount
                    ),
                    expectedKeyedXOFNoSeek,
                    "parallel keyed XOF convenience mismatch for byteCount=\(size)"
                )
                XCTAssertEqual(
                    try BLAKE3.deriveKey(
                        context: contextString,
                        material: input,
                        outputByteCount: xofOutputByteCount
                    ),
                    expectedDerivedNoSeek,
                    "derive-key convenience mismatch for byteCount=\(size)"
                )
                XCTAssertEqual(
                    try BLAKE3.deriveKeyParallel(
                        context: contextString,
                        material: input,
                        outputByteCount: xofOutputByteCount
                    ),
                    expectedDerivedNoSeek,
                    "parallel derive-key convenience mismatch for byteCount=\(size)"
                )

                let context = BLAKE3.Context()
                XCTAssertEqual(context.hash(input, mode: .scalar), expectedDigest, "context scalar mismatch for byteCount=\(size)")
                XCTAssertEqual(context.hash(input, mode: .serial), expectedDigest, "context serial mismatch for byteCount=\(size)")
                XCTAssertEqual(context.hash(input, mode: .automatic), expectedDigest, "context automatic mismatch for byteCount=\(size)")
                XCTAssertEqual(
                    context.hash(input, mode: .parallel(maxWorkers: 2)),
                    expectedDigest,
                    "context parallel mismatch for byteCount=\(size)"
                )

                var hasher = BLAKE3.Hasher()
                update(&hasher, with: input, splitPattern: [1, 63, 64, 65, 1_023, 1_024, 1_025])
                XCTAssertEqual(hasher.finalize(), expectedDigest, "streaming digest mismatch for byteCount=\(size)")
                XCTAssertEqual(
                    xofBytes(from: hasher, count: xofOutputByteCount, seek: xofSeek),
                    expectedXOF,
                    "streaming XOF mismatch for byteCount=\(size)"
                )

                var keyedHasher = try BLAKE3.Hasher(key: key)
                update(&keyedHasher, with: input, splitPattern: [2, 31, 64, 257])
                XCTAssertEqual(keyedHasher.finalize(), expectedKeyedDigest, "streaming keyed digest mismatch for byteCount=\(size)")
                XCTAssertEqual(
                    xofBytes(from: keyedHasher, count: xofOutputByteCount, seek: xofSeek),
                    expectedKeyedXOF,
                    "streaming keyed XOF mismatch for byteCount=\(size)"
                )

                var deriveHasher = BLAKE3.Hasher(deriveKeyContext: contextString)
                update(&deriveHasher, with: input, splitPattern: [3, 17, 128, 511])
                XCTAssertEqual(
                    xofBytes(from: deriveHasher, count: xofOutputByteCount, seek: xofSeek),
                    expectedDerived,
                    "streaming derive-key mismatch for byteCount=\(size)"
                )

                let fileURL = directory.appendingPathComponent("input-\(size).bin")
                try Data(input).write(to: fileURL, options: .atomic)
                var strategies: [(String, BLAKE3File.Strategy)] = [
                    ("automatic", .automatic),
                    ("read", .read(bufferSize: 257)),
                    ("mmap", .memoryMapped),
                    ("mmap-parallel", .memoryMappedParallel(maxThreads: 2))
                ]
                #if canImport(Metal)
                if BLAKE3Metal.isAvailable {
                    strategies.append(("metal-mmap", .metalMemoryMapped(policy: .gpu, fallbackToCPU: false)))
                    strategies.append(
                        (
                            "metal-tiled-mmap",
                            .metalTiledMemoryMapped(tileByteCount: 2 * BLAKE3.chunkByteCount, fallbackToCPU: false)
                        )
                    )
                    strategies.append(
                        (
                            "metal-staged-read",
                            .metalStagedRead(tileByteCount: 2 * BLAKE3.chunkByteCount, fallbackToCPU: false)
                        )
                    )
                }
                #endif

                for (label, strategy) in strategies {
                    XCTAssertEqual(
                        try BLAKE3File.hash(path: fileURL.path, strategy: strategy),
                        expectedDigest,
                        "file digest mismatch against official C for strategy=\(label), byteCount=\(size)"
                    )
                    XCTAssertEqual(
                        try BLAKE3File.hash(
                            path: fileURL.path,
                            strategy: strategy,
                            outputByteCount: xofOutputByteCount,
                            seek: xofSeek
                        ),
                        expectedXOF,
                        "file XOF mismatch against official C for strategy=\(label), byteCount=\(size)"
                    )
                    XCTAssertEqual(
                        try BLAKE3File.keyedHash(key: key, path: fileURL.path, strategy: strategy),
                        expectedKeyedDigest,
                        "file keyed digest mismatch against official C for strategy=\(label), byteCount=\(size)"
                    )
                    XCTAssertEqual(
                        try BLAKE3File.keyedHash(
                            key: key,
                            path: fileURL.path,
                            strategy: strategy,
                            outputByteCount: xofOutputByteCount,
                            seek: xofSeek
                        ),
                        expectedKeyedXOF,
                        "file keyed XOF mismatch against official C for strategy=\(label), byteCount=\(size)"
                    )
                    XCTAssertEqual(
                        try BLAKE3File.deriveKey(
                            context: contextString,
                            path: fileURL.path,
                            strategy: strategy,
                            outputByteCount: xofOutputByteCount,
                            seek: xofSeek
                        ),
                        expectedDerived,
                        "file derive-key mismatch against official C for strategy=\(label), byteCount=\(size)"
                    )
                }

                #if canImport(Metal)
                if BLAKE3Metal.isAvailable {
                    XCTAssertEqual(
                        try BLAKE3Metal.hash(input: input, policy: .gpu),
                        expectedDigest,
                        "metal digest mismatch against official C for byteCount=\(size)"
                    )
                    XCTAssertEqual(
                        try BLAKE3Metal.hash(
                            input: input,
                            outputByteCount: xofOutputByteCount,
                            seek: xofSeek,
                            policy: .gpu
                        ),
                        expectedXOF,
                        "metal XOF mismatch against official C for byteCount=\(size)"
                    )
                    XCTAssertEqual(
                        try BLAKE3Metal.keyedHash(key: key, input: input, policy: .gpu),
                        expectedKeyedDigest,
                        "metal keyed digest mismatch against official C for byteCount=\(size)"
                    )
                    XCTAssertEqual(
                        try BLAKE3Metal.keyedHash(
                            key: key,
                            input: input,
                            outputByteCount: xofOutputByteCount,
                            seek: xofSeek,
                            policy: .gpu
                        ),
                        expectedKeyedXOF,
                        "metal keyed XOF mismatch against official C for byteCount=\(size)"
                    )
                    XCTAssertEqual(
                        try BLAKE3Metal.deriveKey(
                            context: contextString,
                            material: input,
                            outputByteCount: xofOutputByteCount,
                            seek: xofSeek,
                            policy: .gpu
                        ),
                        expectedDerived,
                        "metal derive-key mismatch against official C for byteCount=\(size)"
                    )
                }
                #endif
            }
        }
    }

    func testAsyncFileHashingMatchesOfficialCBLAKE3() async throws {
        let sizes = [0, 1, 1_025, 256 * 1_024 + 1, 1 * 1_024 * 1_024 + 333]

        try await withTemporaryDirectory(prefix: "blake3swift-official-c-async-") { directory in
            for size in sizes {
                let input = deterministicInput(byteCount: size)
                let expectedDigest = input.withUnsafeBytes { OfficialCBLAKE3.hash($0) }
                let fileURL = directory.appendingPathComponent("async-\(size).bin")
                try Data(input).write(to: fileURL, options: .atomic)

                let automaticDigest = try await BLAKE3File.hashAsync(path: fileURL.path, strategy: .automatic)
                XCTAssertEqual(automaticDigest, expectedDigest, "async automatic mismatch against official C for byteCount=\(size)")

                let readDigest = try await BLAKE3File.hashAsync(path: fileURL.path, strategy: .read())
                XCTAssertEqual(readDigest, expectedDigest, "async read mismatch against official C for byteCount=\(size)")

                let mappedDigest = try await BLAKE3File.hashAsync(path: fileURL.path, strategy: .memoryMapped)
                XCTAssertEqual(mappedDigest, expectedDigest, "async mmap mismatch against official C for byteCount=\(size)")

                let mappedParallelDigest = try await BLAKE3File.hashAsync(
                    path: fileURL.path,
                    strategy: .memoryMappedParallel(maxThreads: 2)
                )
                XCTAssertEqual(
                    mappedParallelDigest,
                    expectedDigest,
                    "async mmap-parallel mismatch against official C for byteCount=\(size)"
                )

                #if canImport(Metal)
                if BLAKE3Metal.isAvailable {
                    let metalMappedDigest = try await BLAKE3File.hashAsync(
                        path: fileURL.path,
                        strategy: .metalMemoryMapped(policy: .gpu, fallbackToCPU: false)
                    )
                    XCTAssertEqual(
                        metalMappedDigest,
                        expectedDigest,
                        "async metal-mmap mismatch against official C for byteCount=\(size)"
                    )

                    let metalTiledDigest = try await BLAKE3File.hashAsync(
                        path: fileURL.path,
                        strategy: .metalTiledMemoryMapped(
                            tileByteCount: 2 * BLAKE3.chunkByteCount,
                            fallbackToCPU: false
                        )
                    )
                    XCTAssertEqual(
                        metalTiledDigest,
                        expectedDigest,
                        "async metal-tiled-mmap mismatch against official C for byteCount=\(size)"
                    )

                    let metalStagedDigest = try await BLAKE3File.hashAsync(
                        path: fileURL.path,
                        strategy: .metalStagedRead(
                            tileByteCount: 2 * BLAKE3.chunkByteCount,
                            fallbackToCPU: false
                        )
                    )
                    XCTAssertEqual(
                        metalStagedDigest,
                        expectedDigest,
                        "async metal-staged-read mismatch against official C for byteCount=\(size)"
                    )
                }
                #endif
            }
        }
    }

    func testDifferentialWeirdBoundariesAndStreamingSplits() throws {
        let key = Array("whats the Elvish word for friend".utf8)
        let contextString = "BLAKE3 2019-12-27 16:29:52 test vectors context"
        let sizes = [
            0,
            1,
            63,
            64,
            65,
            1_023,
            1_024,
            1_025,
            2_047,
            2_048,
            2_049,
            4_095,
            4_096,
            4_097,
            16_383,
            16_384,
            16_385,
            65_535,
            65_536,
            65_537,
            256 * 1_024 - 1,
            256 * 1_024,
            256 * 1_024 + 1
        ]
        let splitPattern = [1, 63, 64, 65, 1_023, 1_024, 1_025, 4_097]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            let serialDigest = BLAKE3.hash(input)
            XCTAssertEqual(BLAKE3.hashScalar(input), serialDigest, "scalar mismatch for byteCount=\(size)")
            XCTAssertEqual(BLAKE3.hashParallel(input, maxWorkers: 2), serialDigest, "parallel mismatch for byteCount=\(size)")
            XCTAssertEqual(
                try BLAKE3.keyedHashParallel(key: key, input: input),
                try BLAKE3.keyedHash(key: key, input: input),
                "keyed parallel mismatch for byteCount=\(size)"
            )
            XCTAssertEqual(
                try BLAKE3.deriveKeyParallel(context: contextString, material: input, outputByteCount: 96),
                try BLAKE3.deriveKey(context: contextString, material: input, outputByteCount: 96),
                "derive-key parallel mismatch for byteCount=\(size)"
            )

            var stream = BLAKE3.Hasher()
            var offset = 0
            var splitIndex = 0
            while offset < input.count {
                let step = splitPattern[splitIndex % splitPattern.count]
                let end = min(input.count, offset + step)
                stream.update(input[offset..<end])
                offset = end
                splitIndex += 1
            }
            XCTAssertEqual(stream.finalize(), serialDigest, "streaming mismatch for byteCount=\(size)")

            var xofReader = stream.finalizeXOF()
            var xof = [UInt8](repeating: 0, count: 96)
            xof.withUnsafeMutableBytes { xofReader.read(into: $0) }
            var oneShotReader = BLAKE3.Hasher()
            oneShotReader.update(input)
            var expectedReader = oneShotReader.finalizeXOF()
            var expectedXOF = [UInt8](repeating: 0, count: 96)
            expectedXOF.withUnsafeMutableBytes { expectedReader.read(into: $0) }
            XCTAssertEqual(xof, expectedXOF, "XOF mismatch for byteCount=\(size)")
        }
    }

    func testKeyedAndDerivedStreamingXOFAcrossWeirdSplits() throws {
        let key = Array("whats the Elvish word for friend".utf8)
        let contextString = "BLAKE3 2019-12-27 16:29:52 test vectors context"
        let sizes = [
            0,
            1,
            63,
            64,
            65,
            1_023,
            1_024,
            1_025,
            16_383,
            16_384,
            16_385,
            65_537,
            256 * 1_024 + 1
        ]
        let splitPatterns = [
            [1],
            [63, 1, 64, 65],
            [1_023, 1, 1_024, 1_025, 7],
            [4_097, 257, 65_537]
        ]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            var keyedReference = try BLAKE3.Hasher(key: key)
            keyedReference.update(input)
            var derivedReference = BLAKE3.Hasher(deriveKeyContext: contextString)
            derivedReference.update(input)

            let keyedDigest = keyedReference.finalize()
            let keyedXOF = xofBytes(from: keyedReference, count: 160)
            let keyedSeek = xofBytes(from: keyedReference, count: 73, seek: 31)
            let derivedBytes = try BLAKE3.deriveKey(
                context: contextString,
                material: input,
                outputByteCount: 160
            )
            let derivedSeek = Array(derivedBytes[47..<120])

            XCTAssertEqual(
                derivedReference.finalize().bytes,
                Array(derivedBytes.prefix(BLAKE3.digestByteCount)),
                "derived digest prefix mismatch for byteCount=\(size)"
            )

            for splitPattern in splitPatterns {
                var keyedStream = try BLAKE3.Hasher(key: key)
                update(&keyedStream, with: input, splitPattern: splitPattern)
                XCTAssertEqual(
                    keyedStream.finalize(),
                    keyedDigest,
                    "keyed streaming digest mismatch for byteCount=\(size), splitPattern=\(splitPattern)"
                )
                XCTAssertEqual(
                    xofBytes(from: keyedStream, count: 160),
                    keyedXOF,
                    "keyed streaming XOF mismatch for byteCount=\(size), splitPattern=\(splitPattern)"
                )
                XCTAssertEqual(
                    xofBytes(from: keyedStream, count: 73, seek: 31),
                    keyedSeek,
                    "keyed streaming XOF seek mismatch for byteCount=\(size), splitPattern=\(splitPattern)"
                )

                var derivedStream = BLAKE3.Hasher(deriveKeyContext: contextString)
                update(&derivedStream, with: input, splitPattern: splitPattern)
                XCTAssertEqual(
                    xofBytes(from: derivedStream, count: 160),
                    derivedBytes,
                    "derived streaming XOF mismatch for byteCount=\(size), splitPattern=\(splitPattern)"
                )
                XCTAssertEqual(
                    xofBytes(from: derivedStream, count: 73, seek: 47),
                    derivedSeek,
                    "derived streaming XOF seek mismatch for byteCount=\(size), splitPattern=\(splitPattern)"
                )
            }

            var reusableKeyedStream = try BLAKE3.Hasher(key: key)
            reusableKeyedStream.update(input)
            XCTAssertEqual(reusableKeyedStream.finalize(), keyedDigest)
            reusableKeyedStream.reset()
            reusableKeyedStream.update(input)
            XCTAssertEqual(
                reusableKeyedStream.finalize(),
                keyedDigest,
                "keyed reset should preserve reusable keyed state for byteCount=\(size)"
            )
        }
    }

    #if canImport(CryptoKit)
    func testCryptoKitHashFunctionConformance() {
        let input = deterministicInput(byteCount: 4_097)
        var hasher = BLAKE3.Hasher()

        hasher.update(data: Data(input[..<257]))
        input[257...].withUnsafeBytes { raw in
            hasher.update(bufferPointer: raw)
        }

        XCTAssertEqual(BLAKE3.Hasher.blockByteCount, BLAKE3.blockByteCount)
        XCTAssertEqual(BLAKE3.Hasher.byteCount, BLAKE3.digestByteCount)
        XCTAssertEqual(hasher.finalize(), BLAKE3.hash(input))
    }
    #endif

    func testCPUContextMatchesOneShotAcrossModes() throws {
        let context = BLAKE3.Context()
        let tunedContext = BLAKE3.Context(maxWorkers: 2)
        let sizes = [
            0,
            1,
            1_024,
            1_025,
            256 * 1_024 + 17,
            1 * 1_024 * 1_024 + 777
        ]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            let expected = BLAKE3.hash(input)
            XCTAssertEqual(BLAKE3.hashScalar(input), expected, "scalar hash mismatch for byteCount=\(size)")
            XCTAssertEqual(context.hash(input, mode: .scalar), expected, "scalar context mismatch for byteCount=\(size)")
            XCTAssertEqual(context.hash(input, mode: .serial), expected, "serial context mismatch for byteCount=\(size)")
            XCTAssertEqual(context.hash(input, mode: .automatic), expected, "automatic context mismatch for byteCount=\(size)")
            XCTAssertEqual(
                context.hash(input, mode: .parallel(maxWorkers: 2)),
                expected,
                "parallel context mismatch for byteCount=\(size)"
            )
            XCTAssertEqual(
                tunedContext.hash(input, mode: .automatic),
                expected,
                "tuned reusable context mismatch for byteCount=\(size)"
            )
        }
    }

    func testCPUContextPersistentSchedulerHandlesRepeatedAndConcurrentHashes() async throws {
        let context = BLAKE3.Context(maxWorkers: 2)
        let inputs = [
            deterministicInput(byteCount: 256 * 1_024 + 1),
            deterministicInput(byteCount: 512 * 1_024 + 17),
            deterministicInput(byteCount: 1_024 * 1_024 + 333),
            deterministicInput(byteCount: 300 * 1_024 + 11)
        ]
        let expected = inputs.map { BLAKE3.hash($0) }

        for _ in 0..<3 {
            for (index, input) in inputs.enumerated() {
                XCTAssertEqual(context.hash(input, mode: .automatic), expected[index])
                XCTAssertEqual(context.hash(input, mode: .parallel(maxWorkers: 2)), expected[index])
            }
        }

        try await withThrowingTaskGroup(of: (Int, BLAKE3.Digest).self) { group in
            for (index, input) in inputs.enumerated() {
                group.addTask {
                    (index, context.hash(input, mode: .automatic))
                }
            }
            for try await (index, digest) in group {
                XCTAssertEqual(digest, expected[index])
            }
        }
    }

    func testCPUContextSupportsKeyedAndDeriveKeyModes() throws {
        let key = Array("whats the Elvish word for friend".utf8)
        let contextString = "BLAKE3 2019-12-27 16:29:52 test vectors context"
        let input = deterministicInput(byteCount: 512 * 1_024 + 19)

        let keyedContext = try BLAKE3.Context(key: key)
        XCTAssertEqual(
            keyedContext.hash(input, mode: .parallel(maxWorkers: 2)),
            try BLAKE3.keyedHash(key: key, input: input)
        )

        let deriveContext = BLAKE3.Context(deriveKeyContext: contextString)
        XCTAssertEqual(
            deriveContext.hash(input, mode: .parallel(maxWorkers: 2)).bytes,
            Array(try BLAKE3.deriveKey(context: contextString, material: input).prefix(BLAKE3.digestByteCount))
        )
    }

    func testInputValidation() throws {
        XCTAssertThrowsError(try BLAKE3.keyedHash(key: [UInt8](), input: [UInt8]())) { error in
            XCTAssertEqual(error as? BLAKE3Error, .invalidKeyLength(expected: BLAKE3.keyByteCount, actual: 0))
        }

        XCTAssertThrowsError(try BLAKE3.deriveKey(context: "context", material: [UInt8](), outputByteCount: -1)) { error in
            XCTAssertEqual(error as? BLAKE3Error, .invalidOutputLength(-1))
        }

        XCTAssertThrowsError(try BLAKE3.hash([UInt8](), outputByteCount: -1)) { error in
            XCTAssertEqual(error as? BLAKE3Error, .invalidOutputLength(-1))
        }

        XCTAssertThrowsError(try BLAKE3.keyedHash(key: [UInt8](repeating: 0, count: BLAKE3.keyByteCount), input: [UInt8](), outputByteCount: -1)) { error in
            XCTAssertEqual(error as? BLAKE3Error, .invalidOutputLength(-1))
        }

        let key = [UInt8](repeating: 7, count: BLAKE3.keyByteCount)
        XCTAssertEqual(try BLAKE3.hash([1, 2, 3], outputByteCount: 0), [])
        XCTAssertEqual(try BLAKE3.keyedHash(key: key, input: [1, 2, 3], outputByteCount: 0), [])
        XCTAssertEqual(try BLAKE3.deriveKey(context: "context", material: [1, 2, 3], outputByteCount: 0), [])
        XCTAssertThrowsError(try BLAKE3.keyedHash(key: [UInt8](), input: [1, 2, 3], outputByteCount: 0)) { error in
            XCTAssertEqual(error as? BLAKE3Error, .invalidKeyLength(expected: BLAKE3.keyByteCount, actual: 0))
        }
    }

    func testFileHashing() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("blake3swift-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let fileURL = directory.appendingPathComponent("input.bin")
        let input = deterministicInput(byteCount: 128 * 1024 + 19)
        try Data(input).write(to: fileURL, options: .atomic)

        XCTAssertEqual(try BLAKE3File.hash(path: fileURL.path, strategy: .read()), BLAKE3.hash(input))
        XCTAssertEqual(try BLAKE3File.hash(path: fileURL.path, strategy: .memoryMapped), BLAKE3.hash(input))
        XCTAssertEqual(try BLAKE3File.hash(path: fileURL.path, strategy: .automatic), BLAKE3.hash(input))
        XCTAssertEqual(
            try BLAKE3File.hash(path: fileURL.path, strategy: .memoryMappedParallel(maxThreads: 2)),
            BLAKE3.hash(input)
        )

        let emptyURL = directory.appendingPathComponent("empty.bin")
        try Data().write(to: emptyURL, options: .atomic)
        let emptyDigest = BLAKE3.hash([UInt8]())
        XCTAssertEqual(try BLAKE3File.hash(path: emptyURL.path, strategy: .read()), emptyDigest)
        XCTAssertEqual(try BLAKE3File.hash(path: emptyURL.path, strategy: .memoryMapped), emptyDigest)
        XCTAssertEqual(try BLAKE3File.hash(path: emptyURL.path, strategy: .automatic), emptyDigest)

        #if canImport(Metal)
        if BLAKE3Metal.isAvailable {
            XCTAssertEqual(
                try BLAKE3File.hash(path: fileURL.path, strategy: .metalMemoryMapped(policy: .gpu)),
                BLAKE3.hash(input)
            )
            XCTAssertEqual(
                try BLAKE3File.hash(path: emptyURL.path, strategy: .metalMemoryMapped(policy: .gpu, fallbackToCPU: false)),
                emptyDigest
            )

            let metalTiledURL = directory.appendingPathComponent("metal-tiled.bin")
            let metalTiledInput = deterministicInput(byteCount: 2 * 512 * 1_024 + 333)
            try Data(metalTiledInput).write(to: metalTiledURL, options: .atomic)
            XCTAssertEqual(
                try BLAKE3File.hash(
                    path: metalTiledURL.path,
                    strategy: .metalTiledMemoryMapped(tileByteCount: 512 * 1_024, fallbackToCPU: false)
                ),
                BLAKE3.hash(metalTiledInput)
            )
            XCTAssertEqual(
                try BLAKE3File.hash(
                    path: metalTiledURL.path,
                    strategy: .metalStagedRead(tileByteCount: 512 * 1_024, fallbackToCPU: false)
                ),
                BLAKE3.hash(metalTiledInput)
            )
        }
        #endif
    }

    func testFileStrategiesMatchOneShotAcrossWeirdBoundaries() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("blake3swift-file-boundary-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let sizes = [
            0,
            1,
            63,
            64,
            65,
            1_023,
            1_024,
            1_025,
            16_383,
            16_384,
            16_385,
            256 * 1_024 + 1
        ]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            let expected = BLAKE3.hash(input)
            let url = directory.appendingPathComponent("input-\(size).bin")
            try Data(input).write(to: url, options: .atomic)

            XCTAssertEqual(
                try BLAKE3File.hash(path: url.path, strategy: .read(bufferSize: 257)),
                expected,
                "read file mismatch for byteCount=\(size)"
            )
            XCTAssertEqual(
                try BLAKE3File.hash(path: url.path, strategy: .memoryMapped),
                expected,
                "mapped file mismatch for byteCount=\(size)"
            )
            XCTAssertEqual(
                try BLAKE3File.hash(path: url.path, strategy: .memoryMappedParallel(maxThreads: 2)),
                expected,
                "mapped parallel file mismatch for byteCount=\(size)"
            )
            #if canImport(Metal)
            if BLAKE3Metal.isAvailable {
                XCTAssertEqual(
                    try BLAKE3File.hash(
                        path: url.path,
                        strategy: .metalStagedRead(tileByteCount: 4 * 1_024, fallbackToCPU: false)
                    ),
                    expected,
                    "metal staged read file mismatch for byteCount=\(size)"
                )
            }
            #endif
        }
    }

    func testFileKeyedDeriveAndXOFStrategiesMatchOneShot() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("blake3swift-file-mode-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let fileURL = directory.appendingPathComponent("input.bin")
        let input = deterministicInput(byteCount: 5 * BLAKE3.chunkByteCount + 901)
        try Data(input).write(to: fileURL, options: .atomic)

        let key = deterministicInput(byteCount: BLAKE3.keyByteCount)
        let kdfContext = "BLAKE3 file mode test context"
        let outputByteCount = 513
        let seek: UInt64 = 17

        var unkeyedHasher = BLAKE3.Hasher()
        unkeyedHasher.update(input)
        let expectedXOF = xofBytes(from: unkeyedHasher, count: outputByteCount, seek: seek)
        let expectedKeyedDigest = try BLAKE3.keyedHash(key: key, input: input)
        var keyedHasher = try BLAKE3.Hasher(key: key)
        keyedHasher.update(input)
        let expectedKeyedXOF = xofBytes(from: keyedHasher, count: outputByteCount, seek: seek)
        var deriveHasher = BLAKE3.Hasher(deriveKeyContext: kdfContext)
        deriveHasher.update(input)
        let expectedDerived = xofBytes(from: deriveHasher, count: outputByteCount, seek: seek)

        var strategies: [(String, BLAKE3File.Strategy)] = [
            ("read", .read(bufferSize: 2 * BLAKE3.chunkByteCount)),
            ("mmap", .memoryMapped),
            ("mmap-parallel", .memoryMappedParallel(maxThreads: 2))
        ]
        #if canImport(Metal)
        if BLAKE3Metal.isAvailable {
            strategies.append(
                ("metal-mmap", .metalMemoryMapped(policy: .gpu, fallbackToCPU: false))
            )
            strategies.append(
                (
                    "metal-tiled",
                    .metalTiledMemoryMapped(
                        tileByteCount: 2 * BLAKE3.chunkByteCount,
                        fallbackToCPU: false
                    )
                )
            )
            strategies.append(
                (
                    "metal-staged",
                    .metalStagedRead(
                        tileByteCount: 2 * BLAKE3.chunkByteCount,
                        fallbackToCPU: false
                    )
                )
            )
        }
        #endif

        for (label, strategy) in strategies {
            XCTAssertEqual(
                try BLAKE3File.hash(
                    path: fileURL.path,
                    strategy: strategy,
                    outputByteCount: outputByteCount,
                    seek: seek
                ),
                expectedXOF,
                "file XOF mismatch for strategy=\(label)"
            )
            XCTAssertEqual(
                try BLAKE3File.keyedHash(key: key, path: fileURL.path, strategy: strategy),
                expectedKeyedDigest,
                "file keyed digest mismatch for strategy=\(label)"
            )
            XCTAssertEqual(
                try BLAKE3File.keyedHash(
                    key: key,
                    path: fileURL.path,
                    strategy: strategy,
                    outputByteCount: outputByteCount,
                    seek: seek
                ),
                expectedKeyedXOF,
                "file keyed XOF mismatch for strategy=\(label)"
            )
            XCTAssertEqual(
                try BLAKE3File.deriveKey(
                    context: kdfContext,
                    path: fileURL.path,
                    strategy: strategy,
                    outputByteCount: outputByteCount,
                    seek: seek
                ),
                expectedDerived,
                "file derive-key mismatch for strategy=\(label)"
            )
        }

        XCTAssertEqual(
            try BLAKE3File.deriveKey(
                context: kdfContext,
                path: fileURL.path,
                outputByteCount: 0
            ),
            []
        )
    }

    func testFileAsyncHashing() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("blake3swift-async-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let fileURL = directory.appendingPathComponent("input.bin")
        let input = deterministicInput(byteCount: 1 * 1_024 * 1_024 + 333)
        try Data(input).write(to: fileURL, options: .atomic)
        let expected = BLAKE3.hash(input)

        let readDigest = try await BLAKE3File.hashAsync(
            path: fileURL.path,
            strategy: .read(bufferSize: 4 * 1_024)
        )
        XCTAssertEqual(readDigest, expected)

        let mappedDigest = try await BLAKE3File.hashAsync(path: fileURL.path, strategy: .memoryMapped)
        XCTAssertEqual(mappedDigest, expected)

        let mappedParallelDigest = try await BLAKE3File.hashAsync(
            path: fileURL.path,
            strategy: .memoryMappedParallel(maxThreads: 2)
        )
        XCTAssertEqual(mappedParallelDigest, expected)

        let automaticDigest = try await BLAKE3File.hashAsync(path: fileURL.path, strategy: .automatic)
        XCTAssertEqual(automaticDigest, expected)

        let emptyURL = directory.appendingPathComponent("empty.bin")
        try Data().write(to: emptyURL, options: .atomic)
        let emptyDigest = BLAKE3.hash([UInt8]())
        let asyncEmptyDigest = try await BLAKE3File.hashAsync(path: emptyURL.path, strategy: .automatic)
        XCTAssertEqual(asyncEmptyDigest, emptyDigest)

        #if canImport(Metal)
        if BLAKE3Metal.isAvailable {
            let metalDigest = try await BLAKE3File.hashAsync(
                path: fileURL.path,
                strategy: .metalMemoryMapped(policy: .gpu)
            )
            XCTAssertEqual(metalDigest, expected)

            let metalEmptyDigest = try await BLAKE3File.hashAsync(
                path: emptyURL.path,
                strategy: .metalMemoryMapped(policy: .gpu, fallbackToCPU: false)
            )
            XCTAssertEqual(metalEmptyDigest, emptyDigest)

            let metalTiledDigest = try await BLAKE3File.hashAsync(
                path: fileURL.path,
                strategy: .metalTiledMemoryMapped(tileByteCount: 512 * 1_024, fallbackToCPU: false)
            )
            XCTAssertEqual(metalTiledDigest, expected)

            let metalStagedReadDigest = try await BLAKE3File.hashAsync(
                path: fileURL.path,
                strategy: .metalStagedRead(tileByteCount: 512 * 1_024, fallbackToCPU: false)
            )
            XCTAssertEqual(metalStagedReadDigest, expected)
        }
        #endif
    }

    #if canImport(Metal)
    func testMetalKernelSourceIsExportable() {
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_chunk_cvs"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_chunk_full_aligned_cvs"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_chunk_tile256_cvs"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_chunk_tile128_simdgroup_cvs"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_chunk_tile128_pingpong_cvs"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_chunk_tile512_cvs"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_root_digest"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_root_xof"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_batch_contiguous_block_digest"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_batch_contiguous_block_output_chunk_cvs"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_batch_one_block_digest"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_batch_one_block_output_chunk_cvs"))
        XCTAssertTrue(BLAKE3Metal.kernelSource.contains("blake3_batch_one_full_chunk_output_chunk_cvs"))
    }

    #endif
}

private func loadTestVectors() throws -> TestVectors {
    let url = try XCTUnwrap(
        Bundle.module.url(forResource: "test_vectors", withExtension: "json")
    )
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(TestVectors.self, from: data)
}

private func deterministicInput(byteCount: Int) -> [UInt8] {
    (0..<byteCount).map { UInt8($0 % 251) }
}

private func officialDigest(_ input: [UInt8]) -> BLAKE3.Digest {
    input.withUnsafeBytes { OfficialCBLAKE3.hash($0) }
}

private func officialXOFBytes(
    input: [UInt8],
    outputByteCount: Int,
    seek: UInt64 = 0
) -> [UInt8] {
    input.withUnsafeBytes {
        OfficialCBLAKE3.hash($0, outputByteCount: outputByteCount, seek: seek)
    }
}

private func officialKeyedDigest(
    key: [UInt8],
    input: [UInt8]
) -> BLAKE3.Digest {
    key.withUnsafeBytes { keyRaw in
        input.withUnsafeBytes { inputRaw in
            OfficialCBLAKE3.keyedHash(key: keyRaw, input: inputRaw)
        }
    }
}

private func officialKeyedXOFBytes(
    key: [UInt8],
    input: [UInt8],
    outputByteCount: Int,
    seek: UInt64 = 0
) -> [UInt8] {
    key.withUnsafeBytes { keyRaw in
        input.withUnsafeBytes { inputRaw in
            OfficialCBLAKE3.keyedHash(
                key: keyRaw,
                input: inputRaw,
                outputByteCount: outputByteCount,
                seek: seek
            )
        }
    }
}

private func officialDerivedBytes(
    context: String,
    material: [UInt8],
    outputByteCount: Int,
    seek: UInt64 = 0
) -> [UInt8] {
    context.utf8CString.withUnsafeBytes { contextRaw in
        material.withUnsafeBytes { materialRaw in
            OfficialCBLAKE3.deriveKey(
                context: UnsafeRawBufferPointer(rebasing: contextRaw.dropLast()),
                material: materialRaw,
                outputByteCount: outputByteCount,
                seek: seek
            )
        }
    }
}

private func withTemporaryDirectory<R>(
    prefix: String,
    _ body: (URL) throws -> R
) throws -> R {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("\(prefix)\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    return try body(directory)
}

private func withTemporaryDirectory<R>(
    prefix: String,
    _ body: (URL) async throws -> R
) async throws -> R {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("\(prefix)\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    return try await body(directory)
}

private func update(
    _ hasher: inout BLAKE3.Hasher,
    with input: [UInt8],
    splitAt splitIndex: Int
) {
    let clampedSplitIndex = min(max(0, splitIndex), input.count)
    hasher.update(input[..<clampedSplitIndex])
    hasher.update(input[clampedSplitIndex...])
}

private func update(
    _ hasher: inout BLAKE3.Hasher,
    with input: [UInt8],
    splitPattern: [Int]
) {
    guard !splitPattern.isEmpty else {
        hasher.update(input)
        return
    }

    var offset = 0
    var splitIndex = 0
    while offset < input.count {
        let step = max(1, splitPattern[splitIndex % splitPattern.count])
        let end = min(input.count, offset + step)
        hasher.update(input[offset..<end])
        offset = end
        splitIndex += 1
    }
}

private func xofBytes(from hasher: BLAKE3.Hasher, count: Int, seek: UInt64 = 0) -> [UInt8] {
    var reader = hasher.finalizeXOF()
    reader.seek(to: seek)
    var output = [UInt8](repeating: 0, count: count)
    output.withUnsafeMutableBytes { reader.read(into: $0) }
    return output
}

#if canImport(Metal)
private struct AsyncMetalHashCase: @unchecked Sendable {
    let index: Int
    let byteCount: Int
    let buffer: MTLBuffer
}
#endif

private func decodeHex(_ hex: String) throws -> [UInt8] {
    struct InvalidHex: Error {}

    guard hex.count.isMultiple(of: 2) else {
        throw InvalidHex()
    }

    var output = [UInt8]()
    output.reserveCapacity(hex.count / 2)

    var index = hex.startIndex
    while index < hex.endIndex {
        let nextIndex = hex.index(index, offsetBy: 2)
        guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else {
            throw InvalidHex()
        }
        output.append(byte)
        index = nextIndex
    }
    return output
}
