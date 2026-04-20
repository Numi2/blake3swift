import XCTest
@testable import Blake3
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
            4 * 1_024 * 1_024 + 123
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
        let input = deterministicInput(byteCount: 3 * 1024 * 1024 + 333)
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
            1024 * 1024 + 333,
            3 * 1024 * 1024 + 777
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

    func testDefaultOneShotMatchesExplicitCPUForLargeInputs() {
        let sizes = [
            16 * 1_024 * 1_024,
            16 * 1_024 * 1_024 + 333
        ]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            let expected = BLAKE3.hashCPU(input)
            XCTAssertEqual(BLAKE3.hash(input), expected, "default hash mismatch for byteCount=\(size)")
            XCTAssertEqual(BLAKE3.hashSerial(input), expected, "serial hash mismatch for byteCount=\(size)")
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
            3 * 1_024 * 1_024 + 777
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

        let largeURL = directory.appendingPathComponent("large.bin")
        let largeInput = deterministicInput(byteCount: 2 * BLAKE3File.mappedTileByteCount + 333)
        try Data(largeInput).write(to: largeURL, options: .atomic)
        XCTAssertEqual(
            try BLAKE3File.hash(path: largeURL.path, strategy: .memoryMappedParallel(maxThreads: 2)),
            BLAKE3.hash(largeInput)
        )
        XCTAssertEqual(try BLAKE3File.hash(path: largeURL.path, strategy: .automatic), BLAKE3.hash(largeInput))

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
        let input = deterministicInput(byteCount: 2 * 1_024 * 1_024 + 333)
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
    }

    func testMetalContextRecordsLibrarySource() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let context = try BLAKE3Metal.makeContext(device: device, librarySource: .runtimeSource)

        XCTAssertEqual(context.librarySource, .runtimeSource)
    }

    func testMetalBufferHashSurfaceWhenDeviceExists() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let sizes = [
            0,
            1,
            1_024,
            1_025,
            3 * 1_024,
            4_096,
            5 * 1_024,
            6 * 1_024,
            7 * 1_024,
            8 * 1_024,
            9 * 1_024,
            16 * 1_024,
            17 * 1_024,
            300 * 1_024 + 17,
            1 * 1_024 * 1_024,
            2 * 1_024 * 1_024,
            3 * 1_024 * 1_024 + 777
        ]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            let buffer = try XCTUnwrap(device.makeBuffer(length: max(1, input.count), options: .storageModeShared))
            if !input.isEmpty {
                input.withUnsafeBytes { raw in
                    buffer.contents().copyMemory(from: raw.baseAddress!, byteCount: input.count)
                }
            }
            XCTAssertEqual(
                try BLAKE3Metal.hash(buffer: buffer, length: input.count),
                BLAKE3.hash(input),
                "automatic Metal hash mismatch for byteCount=\(size)"
            )
            XCTAssertEqual(
                try BLAKE3Metal.hash(buffer: buffer, length: input.count, policy: .gpu),
                BLAKE3.hash(input),
                "forced GPU Metal hash mismatch for byteCount=\(size)"
            )
            XCTAssertEqual(
                try BLAKE3Metal.hash(buffer: buffer, length: input.count, policy: .cpu),
                BLAKE3.hash(input),
                "forced CPU Metal hash mismatch for byteCount=\(size)"
            )
        }
    }

    func testMetalChunkChainingValuesHonorBaseCounter() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let context = try BLAKE3Metal.makeContext(device: device)
        let baseChunkCounter = UInt64(7)
        let input = deterministicInput(byteCount: 4 * BLAKE3.chunkByteCount)
        let inputBuffer = try XCTUnwrap(input.withUnsafeBytes { raw in
            device.makeBuffer(bytes: raw.baseAddress!, length: raw.count, options: .storageModeShared)
        })
        let outputBuffer = try context.makeChunkChainingValueBuffer(chunkCapacity: 4)

        let chunkCount = try context.writeChunkChainingValues(
            buffer: inputBuffer,
            range: 0..<input.count,
            baseChunkCounter: baseChunkCounter,
            into: outputBuffer
        )

        XCTAssertEqual(chunkCount, 4)
        XCTAssertEqual(outputBuffer.chunkCount, 4)

        let expected = input.withUnsafeBytes { raw in
            (0..<4).map { chunkIndex in
                BLAKE3Core.blake3ProcessFullChunk(
                    baseAddress: raw.baseAddress!,
                    chunkByteOffset: chunkIndex * BLAKE3.chunkByteCount,
                    chunkCounter: baseChunkCounter + UInt64(chunkIndex),
                    key: BLAKE3Core.iv,
                    flags: 0
                )
            }
        }

        outputBuffer.withUnsafeBytes { raw in
            for chunkIndex in 0..<chunkCount {
                let offset = chunkIndex * BLAKE3.digestByteCount
                let actual = BLAKE3Core.chainingValue(from: raw, atByteOffset: offset)
                XCTAssertEqual(actual, expected[chunkIndex])
            }
        }
    }

    func testMetalAsyncChunkChainingValuesHonorBaseCounter() async throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let context = try BLAKE3Metal.makeContext(device: device)
        let baseChunkCounter = UInt64(11)
        let input = deterministicInput(byteCount: 6 * BLAKE3.chunkByteCount)
        let inputBuffer = try XCTUnwrap(input.withUnsafeBytes { raw in
            device.makeBuffer(bytes: raw.baseAddress!, length: raw.count, options: .storageModeShared)
        })
        let outputBuffer = try context.makeChunkChainingValueBuffer(chunkCapacity: 6)

        let chunkCount = try await context.writeChunkChainingValuesAsync(
            buffer: inputBuffer,
            range: 0..<input.count,
            baseChunkCounter: baseChunkCounter,
            into: outputBuffer
        )

        XCTAssertEqual(chunkCount, 6)
        XCTAssertEqual(outputBuffer.chunkCount, 6)

        let expected = input.withUnsafeBytes { raw in
            (0..<6).map { chunkIndex in
                BLAKE3Core.blake3ProcessFullChunk(
                    baseAddress: raw.baseAddress!,
                    chunkByteOffset: chunkIndex * BLAKE3.chunkByteCount,
                    chunkCounter: baseChunkCounter + UInt64(chunkIndex),
                    key: BLAKE3Core.iv,
                    flags: 0
                )
            }
        }

        outputBuffer.withUnsafeBytes { raw in
            for chunkIndex in 0..<chunkCount {
                let offset = chunkIndex * BLAKE3.digestByteCount
                let actual = BLAKE3Core.chainingValue(from: raw, atByteOffset: offset)
                XCTAssertEqual(actual, expected[chunkIndex])
            }
        }
    }

    func testMetalFusedTileKernelsProduceSubtreeChainingValues() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let pipelines = try BLAKE3MetalPipelineCache.shared.pipelines(device: device)
        let commandQueue = try XCTUnwrap(device.makeCommandQueue())
        let cases: [(Int, MTLComputePipelineState, Int, String)] = [
            (128, pipelines.chunkTile128CVs, 128 * BLAKE3.digestByteCount, "in-place"),
            (256, pipelines.chunkTile256CVs, 256 * BLAKE3.digestByteCount, "in-place"),
            (512, pipelines.chunkTile512CVs, 512 * BLAKE3.digestByteCount, "in-place"),
            (1024, pipelines.chunkTile1024CVs, 1024 * BLAKE3.digestByteCount, "in-place"),
            (128, pipelines.chunkTile128SIMDGroupCVs, 4 * BLAKE3.digestByteCount, "simdgroup"),
            (128, pipelines.chunkTile128PingPongCVs, 128 * BLAKE3.digestByteCount * 2, "ping-pong"),
            (256, pipelines.chunkTile256PingPongCVs, 256 * BLAKE3.digestByteCount * 2, "ping-pong"),
            (512, pipelines.chunkTile512PingPongCVs, 512 * BLAKE3.digestByteCount * 2, "ping-pong"),
            (1024, pipelines.chunkTile1024PingPongCVs, 1024 * BLAKE3.digestByteCount * 2, "ping-pong")
        ]

        var testedCaseCount = 0
        for (tileChunkCount, pipeline, scratchByteCount, label) in cases {
            let executionWidth = max(1, pipeline.threadExecutionWidth)
            guard tileChunkCount <= pipeline.maxTotalThreadsPerThreadgroup,
                  scratchByteCount <= device.maxThreadgroupMemoryLength,
                  tileChunkCount.isMultiple(of: executionWidth) else {
                continue
            }
            if label == "simdgroup" && executionWidth != 32 {
                continue
            }
            testedCaseCount += 1

            let input = deterministicInput(byteCount: tileChunkCount * BLAKE3.chunkByteCount)
            let baseChunkCounter = UInt64(13)
            let inputBuffer = try XCTUnwrap(input.withUnsafeBytes { raw in
                device.makeBuffer(bytes: raw.baseAddress!, length: raw.count, options: .storageModeShared)
            })
            XCTAssertTrue(Int(bitPattern: inputBuffer.contents()).isMultiple(of: MemoryLayout<UInt32>.stride))
            let outputBuffer = try XCTUnwrap(device.makeBuffer(length: BLAKE3.digestByteCount, options: .storageModeShared))
            var params = BLAKE3MetalChunkParams(
                inputOffset: 0,
                inputLength: UInt64(input.count),
                baseChunkCounter: baseChunkCounter,
                chunkCount: UInt32(tileChunkCount),
                canLoadWords: 1
            )
            let paramsBuffer = try XCTUnwrap(withUnsafeBytes(of: &params) { raw in
                device.makeBuffer(bytes: raw.baseAddress!, length: raw.count, options: .storageModeShared)
            })

            let commandBuffer = try XCTUnwrap(commandQueue.makeCommandBuffer())
            let encoder = try XCTUnwrap(commandBuffer.makeComputeCommandEncoder())
            encoder.setComputePipelineState(pipeline)
            encoder.setBuffer(inputBuffer, offset: 0, index: 0)
            encoder.setBuffer(outputBuffer, offset: 0, index: 1)
            encoder.setBuffer(paramsBuffer, offset: 0, index: 2)
            encoder.setThreadgroupMemoryLength(scratchByteCount, index: 0)
            encoder.dispatchThreadgroups(
                MTLSize(width: 1, height: 1, depth: 1),
                threadsPerThreadgroup: MTLSize(width: tileChunkCount, height: 1, depth: 1)
            )
            encoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            XCTAssertNil(commandBuffer.error)

            let expected = input.withUnsafeBytes { raw in
                var chunkCVs = [BLAKE3Core.ChainingValue]()
                chunkCVs.reserveCapacity(tileChunkCount)
                for chunkIndex in 0..<tileChunkCount {
                    chunkCVs.append(
                        BLAKE3Core.blake3ProcessFullChunk(
                            baseAddress: raw.baseAddress!,
                            chunkByteOffset: chunkIndex * BLAKE3.chunkByteCount,
                            chunkCounter: baseChunkCounter + UInt64(chunkIndex),
                            key: BLAKE3Core.iv,
                            flags: 0
                        )
                    )
                }
                return BLAKE3Core.rootOutput(fromChunkCVs: chunkCVs, key: BLAKE3Core.iv, flags: 0)
                    .chainingValue()
            }
            let actual = BLAKE3Core.chainingValue(
                from: UnsafeRawBufferPointer(start: outputBuffer.contents(), count: BLAKE3.digestByteCount)
            )
            XCTAssertEqual(actual, expected, "fused tile subtree mismatch for \(label) tileChunkCount=\(tileChunkCount)")
        }
        XCTAssertGreaterThan(testedCaseCount, 0)
    }

    func testMetalBufferHashSupportsUnalignedRanges() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let input = deterministicInput(byteCount: 2 * 1_024 * 1_024 + 777)
        let buffer = try XCTUnwrap(
            device.makeBuffer(length: input.count + 3, options: .storageModeShared)
        )
        input.withUnsafeBytes { raw in
            buffer.contents().advanced(by: 1).copyMemory(
                from: raw.baseAddress!,
                byteCount: input.count
            )
        }

        XCTAssertEqual(
            try BLAKE3Metal.hash(buffer: buffer, range: 1..<(input.count + 1), policy: .gpu),
            BLAKE3.hash(input)
        )
    }

    func testMetalBufferHashCoversQuadReductionTails() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let pipelines = try BLAKE3MetalPipelineCache.shared.pipelines(device: device)
        let commandQueue = try XCTUnwrap(device.makeCommandQueue())
        let counts = [5, 6, 7, 8, 9, 10, 15, 16, 17]

        for count in counts {
            let inputCVs = deterministicInput(byteCount: count * BLAKE3.digestByteCount)
            let expectedDigest = try XCTUnwrap(
                inputCVs.withUnsafeBytes { raw in
                    BLAKE3.hashFromChunkChainingValues(raw, chunkCount: count)
                }
            )
            let outputCount = (count + 3) / 4
            let outputByteCount = outputCount * BLAKE3.digestByteCount
            let inputBuffer = try XCTUnwrap(inputCVs.withUnsafeBytes { raw in
                device.makeBuffer(bytes: raw.baseAddress!, length: raw.count, options: .storageModeShared)
            })
            let outputBuffer = try XCTUnwrap(
                device.makeBuffer(length: outputByteCount, options: .storageModeShared)
            )
            var params = BLAKE3MetalParentParams(inputCount: UInt32(count))
            let paramsBuffer = try XCTUnwrap(withUnsafeBytes(of: &params) { raw in
                device.makeBuffer(bytes: raw.baseAddress!, length: raw.count, options: .storageModeShared)
            })
            let commandBuffer = try XCTUnwrap(commandQueue.makeCommandBuffer())
            let encoder = try XCTUnwrap(commandBuffer.makeComputeCommandEncoder())
            encoder.setComputePipelineState(pipelines.parent4CVs)
            encoder.setBuffer(inputBuffer, offset: 0, index: 0)
            encoder.setBuffer(outputBuffer, offset: 0, index: 1)
            encoder.setBuffer(paramsBuffer, offset: 0, index: 2)
            encoder.dispatchThreads(
                MTLSize(width: outputCount, height: 1, depth: 1),
                threadsPerThreadgroup: MTLSize(
                    width: max(1, pipelines.parent4CVs.threadExecutionWidth),
                    height: 1,
                    depth: 1
                )
            )
            encoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            XCTAssertNil(commandBuffer.error)

            let reducedDigest = try XCTUnwrap(
                BLAKE3.hashFromChunkChainingValues(
                    UnsafeRawBufferPointer(start: outputBuffer.contents(), count: outputByteCount),
                    chunkCount: outputCount
                )
            )
            XCTAssertEqual(reducedDigest, expectedDigest, "quad-tail reduction mismatch for count=\(count)")
        }
    }

    func testMetalBufferHashCoversWideReductionTails() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let pipelines = try BLAKE3MetalPipelineCache.shared.pipelines(device: device)
        let commandQueue = try XCTUnwrap(device.makeCommandQueue())
        let counts = [17, 18, 31, 32, 33]

        for count in counts {
            let inputCVs = deterministicInput(byteCount: count * BLAKE3.digestByteCount)
            let expectedDigest = try XCTUnwrap(
                inputCVs.withUnsafeBytes { raw in
                    BLAKE3.hashFromChunkChainingValues(raw, chunkCount: count)
                }
            )
            let outputCount = (count + 15) / 16
            let outputByteCount = outputCount * BLAKE3.digestByteCount
            let inputBuffer = try XCTUnwrap(inputCVs.withUnsafeBytes { raw in
                device.makeBuffer(bytes: raw.baseAddress!, length: raw.count, options: .storageModeShared)
            })
            let outputBuffer = try XCTUnwrap(
                device.makeBuffer(length: outputByteCount, options: .storageModeShared)
            )
            var params = BLAKE3MetalParentParams(inputCount: UInt32(count))
            let paramsBuffer = try XCTUnwrap(withUnsafeBytes(of: &params) { raw in
                device.makeBuffer(bytes: raw.baseAddress!, length: raw.count, options: .storageModeShared)
            })
            let commandBuffer = try XCTUnwrap(commandQueue.makeCommandBuffer())
            let encoder = try XCTUnwrap(commandBuffer.makeComputeCommandEncoder())
            encoder.setComputePipelineState(pipelines.parent16TailCVs)
            encoder.setBuffer(inputBuffer, offset: 0, index: 0)
            encoder.setBuffer(outputBuffer, offset: 0, index: 1)
            encoder.setBuffer(paramsBuffer, offset: 0, index: 2)
            encoder.dispatchThreads(
                MTLSize(width: outputCount, height: 1, depth: 1),
                threadsPerThreadgroup: MTLSize(
                    width: max(1, pipelines.parent16TailCVs.threadExecutionWidth),
                    height: 1,
                    depth: 1
                )
            )
            encoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            XCTAssertNil(commandBuffer.error)

            let reducedDigest = try XCTUnwrap(
                BLAKE3.hashFromChunkChainingValues(
                    UnsafeRawBufferPointer(start: outputBuffer.contents(), count: outputByteCount),
                    chunkCount: outputCount
                )
            )
            XCTAssertEqual(reducedDigest, expectedDigest, "wide-tail reduction mismatch for count=\(count)")
        }
    }

    func testMetalStagingBufferHashesSwiftOwnedInput() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let context = try BLAKE3Metal.makeContext()
        let input = deterministicInput(byteCount: 2 * 1_024 * 1_024 + 333)
        let stagingBuffer = try context.makeStagingBuffer(capacity: input.count)

        XCTAssertEqual(
            try context.hash(input: input, using: stagingBuffer, policy: .automatic),
            BLAKE3.hash(input)
        )
        XCTAssertEqual(
            try context.hash(input: input, using: stagingBuffer, policy: .gpu),
            BLAKE3.hash(input)
        )
        XCTAssertThrowsError(
            try context.hash(
                input: input,
                using: context.makeStagingBuffer(capacity: input.count - 1),
                policy: .gpu
            )
        )
    }

    func testMetalNoCopyHashesSwiftOwnedInput() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let context = try BLAKE3Metal.makeContext()
        let sizes = [
            0,
            1,
            BLAKE3.chunkByteCount,
            BLAKE3.chunkByteCount + 1,
            2 * 1_024 * 1_024 + 333
        ]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            let expected = BLAKE3.hash(input)
            XCTAssertEqual(
                try BLAKE3Metal.hash(input: input, policy: .automatic),
                expected,
                "static no-copy automatic mismatch for byteCount=\(size)"
            )
            XCTAssertEqual(
                try context.hash(input: input, policy: .automatic),
                expected,
                "context no-copy automatic mismatch for byteCount=\(size)"
            )
            XCTAssertEqual(
                try context.hash(input: input, policy: .gpu),
                expected,
                "context no-copy GPU mismatch for byteCount=\(size)"
            )
        }
    }

    func testMetalOneChunkBatchMatchesCPUAcrossSmallRanges() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let context = try BLAKE3Metal.makeContext(device: device)
        let lengths = [0, 1, 2, 63, 64, 65, 255, 1_023, 1_024]
        var input = [UInt8]()
        var ranges = [Range<Int>]()
        for (index, length) in lengths.enumerated() {
            let lowerBound = input.count
            input.append(
                contentsOf: (0..<length).map { byteIndex in
                    UInt8((byteIndex + index * 17) % 251)
                }
            )
            ranges.append(lowerBound..<input.count)
        }

        let buffer = try XCTUnwrap(input.withUnsafeBytes { raw in
            device.makeBuffer(bytes: raw.baseAddress!, length: raw.count, options: .storageModeShared)
        })
        let expected = ranges.map { range in
            input.withUnsafeBytes { raw in
                BLAKE3.hash(
                    UnsafeRawBufferPointer(
                        start: raw.baseAddress!.advanced(by: range.lowerBound),
                        count: range.count
                    )
                )
            }
        }

        XCTAssertEqual(
            try context.hashOneChunkBatch(buffer: buffer, ranges: ranges),
            expected
        )
        XCTAssertEqual(
            try BLAKE3Metal.hashOneChunkBatch(buffer: buffer, ranges: ranges),
            expected
        )
        XCTAssertEqual(try context.hashOneChunkBatch(buffer: buffer, ranges: []), [])

        func readDigests(_ outputBuffer: MTLBuffer, count: Int) -> [BLAKE3.Digest] {
            let rawOutput = UnsafeRawBufferPointer(
                start: outputBuffer.contents(),
                count: count * BLAKE3.digestByteCount
            )
            let baseAddress = rawOutput.baseAddress!
            return (0..<count).map { index in
                BLAKE3.Digest(
                    UnsafeRawBufferPointer(
                        start: baseAddress.advanced(by: index * BLAKE3.digestByteCount),
                        count: BLAKE3.digestByteCount
                    )
                )
            }
        }

        let outputBuffer = try XCTUnwrap(
            device.makeBuffer(
                length: ranges.count * BLAKE3.digestByteCount,
                options: .storageModeShared
            )
        )
        XCTAssertEqual(
            try context.writeOneChunkBatchDigests(buffer: buffer, ranges: ranges, into: outputBuffer),
            ranges.count
        )
        XCTAssertEqual(readDigests(outputBuffer, count: ranges.count), expected)

        let staticOutputBuffer = try XCTUnwrap(
            device.makeBuffer(
                length: ranges.count * BLAKE3.digestByteCount,
                options: .storageModeShared
            )
        )
        XCTAssertEqual(
            try BLAKE3Metal.writeOneChunkBatchDigests(
                buffer: buffer,
                ranges: ranges,
                into: staticOutputBuffer
            ),
            ranges.count
        )
        XCTAssertEqual(readDigests(staticOutputBuffer, count: ranges.count), expected)

        let aggregateExpected = BLAKE3.hashCPU(expected.flatMap(\.bytes))
        let privateOutputBuffer = try XCTUnwrap(
            device.makeBuffer(
                length: ranges.count * BLAKE3.digestByteCount,
                options: .storageModePrivate
            )
        )
        XCTAssertEqual(
            try context.writeOneChunkBatchDigests(buffer: buffer, ranges: ranges, into: privateOutputBuffer),
            ranges.count
        )
        XCTAssertEqual(
            try context.hashOneChunkBatch(
                buffer: privateOutputBuffer,
                ranges: [0..<(ranges.count * BLAKE3.digestByteCount)]
            ).first,
            aggregateExpected
        )

        let emptyOutputBuffer = try XCTUnwrap(device.makeBuffer(length: 1, options: .storageModeShared))
        XCTAssertEqual(
            try context.writeOneChunkBatchDigests(buffer: buffer, ranges: [], into: emptyOutputBuffer),
            0
        )

        let key = deterministicInput(byteCount: BLAKE3.keyByteCount)
        let expectedKeyed = ranges.map { range in
            input.withUnsafeBytes { raw in
                try! BLAKE3.keyedHash(
                    key: key,
                    input: UnsafeRawBufferPointer(
                        start: raw.baseAddress!.advanced(by: range.lowerBound),
                        count: range.count
                    )
                )
            }
        }
        XCTAssertEqual(
            try context.keyedHashOneChunkBatch(key: key, buffer: buffer, ranges: ranges),
            expectedKeyed
        )

        let keyedOutputBuffer = try XCTUnwrap(
            device.makeBuffer(
                length: ranges.count * BLAKE3.digestByteCount,
                options: .storageModeShared
            )
        )
        XCTAssertEqual(
            try context.writeKeyedOneChunkBatchDigests(
                key: key,
                buffer: buffer,
                ranges: ranges,
                into: keyedOutputBuffer
            ),
            ranges.count
        )
        XCTAssertEqual(readDigests(keyedOutputBuffer, count: ranges.count), expectedKeyed)

        let staticKeyedOutputBuffer = try XCTUnwrap(
            device.makeBuffer(
                length: ranges.count * BLAKE3.digestByteCount,
                options: .storageModeShared
            )
        )
        XCTAssertEqual(
            try BLAKE3Metal.writeKeyedOneChunkBatchDigests(
                key: key,
                buffer: buffer,
                ranges: ranges,
                into: staticKeyedOutputBuffer
            ),
            ranges.count
        )
        XCTAssertEqual(readDigests(staticKeyedOutputBuffer, count: ranges.count), expectedKeyed)

        let aggregateExpectedKeyed = BLAKE3.hashCPU(expectedKeyed.flatMap(\.bytes))
        let privateKeyedOutputBuffer = try XCTUnwrap(
            device.makeBuffer(
                length: ranges.count * BLAKE3.digestByteCount,
                options: .storageModePrivate
            )
        )
        XCTAssertEqual(
            try context.writeKeyedOneChunkBatchDigests(
                key: key,
                buffer: buffer,
                ranges: ranges,
                into: privateKeyedOutputBuffer
            ),
            ranges.count
        )
        XCTAssertEqual(
            try context.hashOneChunkBatch(
                buffer: privateKeyedOutputBuffer,
                ranges: [0..<(ranges.count * BLAKE3.digestByteCount)]
            ).first,
            aggregateExpectedKeyed
        )

        let tooSmallOutputBuffer = try XCTUnwrap(
            device.makeBuffer(
                length: ranges.count * BLAKE3.digestByteCount - 1,
                options: .storageModeShared
            )
        )
        XCTAssertThrowsError(
            try context.writeOneChunkBatchDigests(buffer: buffer, ranges: ranges, into: tooSmallOutputBuffer)
        )

        XCTAssertThrowsError(
            try context.hashOneChunkBatch(buffer: buffer, ranges: [0..<(BLAKE3.chunkByteCount + 1)])
        )
        XCTAssertThrowsError(
            try context.hashOneChunkBatch(buffer: buffer, ranges: [0..<(buffer.length + 1)])
        )
    }

    func testMetalKeyedHashMatchesCPUAcrossTreeShapes() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let context = try BLAKE3Metal.makeContext(device: device)
        let key = deterministicInput(byteCount: BLAKE3.keyByteCount)
        let sizes = [
            2 * BLAKE3.chunkByteCount,
            3 * BLAKE3.chunkByteCount,
            4 * BLAKE3.chunkByteCount,
            5 * BLAKE3.chunkByteCount + 17,
            2 * 1_024 * 1_024 + 333
        ]

        for size in sizes {
            let input = deterministicInput(byteCount: size)
            let expected = try BLAKE3.keyedHash(key: key, input: input)

            XCTAssertEqual(
                try BLAKE3Metal.keyedHash(key: key, input: input, policy: .gpu),
                expected,
                "static keyed GPU mismatch for byteCount=\(size)"
            )
            XCTAssertEqual(
                try context.keyedHash(key: key, input: input, policy: .gpu),
                expected,
                "context keyed GPU mismatch for byteCount=\(size)"
            )

            let buffer = try XCTUnwrap(device.makeBuffer(length: input.count + 2, options: .storageModeShared))
            input.withUnsafeBytes { raw in
                buffer.contents().advanced(by: 1).copyMemory(
                    from: raw.baseAddress!,
                    byteCount: input.count
                )
            }
            XCTAssertEqual(
                try context.keyedHash(key: key, buffer: buffer, range: 1..<(input.count + 1), policy: .gpu),
                expected,
                "resident keyed GPU mismatch for byteCount=\(size)"
            )
        }
    }

    func testMetalXOFMatchesCPUAndSeek() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let context = try BLAKE3Metal.makeContext(device: device)
        let key = deterministicInput(byteCount: BLAKE3.keyByteCount)
        let input = deterministicInput(byteCount: 5 * BLAKE3.chunkByteCount + 777)
        let outputSizes = [1, 31, 32, 63, 64, 65, 257, 1_000]
        let seeks: [UInt64] = [0, 1, 63, 64, 65, 511]

        for outputSize in outputSizes {
            for seek in seeks {
                var unkeyedHasher = BLAKE3.Hasher()
                unkeyedHasher.update(input)
                let expected = xofBytes(from: unkeyedHasher, count: outputSize, seek: seek)
                XCTAssertEqual(
                    try BLAKE3Metal.hash(
                        input: input,
                        outputByteCount: outputSize,
                        seek: seek,
                        policy: .gpu
                    ),
                    expected,
                    "unkeyed GPU XOF mismatch for outputSize=\(outputSize), seek=\(seek)"
                )

                var keyedHasher = try BLAKE3.Hasher(key: key)
                keyedHasher.update(input)
                let expectedKeyed = xofBytes(from: keyedHasher, count: outputSize, seek: seek)
                XCTAssertEqual(
                    try BLAKE3Metal.keyedHash(
                        key: key,
                        input: input,
                        outputByteCount: outputSize,
                        seek: seek,
                        policy: .gpu
                    ),
                    expectedKeyed,
                    "keyed GPU XOF mismatch for outputSize=\(outputSize), seek=\(seek)"
                )
            }
        }

        let buffer = try XCTUnwrap(device.makeBuffer(length: input.count + 2, options: .storageModeShared))
        input.withUnsafeBytes { raw in
            buffer.contents().advanced(by: 1).copyMemory(
                from: raw.baseAddress!,
                byteCount: input.count
            )
        }
        var unkeyedHasher = BLAKE3.Hasher()
        unkeyedHasher.update(input)
        let expectedResidentXOF = xofBytes(from: unkeyedHasher, count: 513, seek: 17)
        XCTAssertEqual(
            try context.hash(
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 513,
                seek: 17,
                policy: .gpu
            ),
            expectedResidentXOF
        )
        func readOutput(_ outputBuffer: MTLBuffer, count: Int) -> [UInt8] {
            Array(
                UnsafeRawBufferPointer(
                    start: outputBuffer.contents(),
                    count: count
                )
            )
        }

        let outputBuffer = try XCTUnwrap(device.makeBuffer(length: 513, options: .storageModeShared))
        XCTAssertEqual(
            try context.writeXOF(
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 513,
                seek: 17,
                policy: .gpu,
                into: outputBuffer
            ),
            513
        )
        XCTAssertEqual(readOutput(outputBuffer, count: 513), expectedResidentXOF)

        let staticOutputBuffer = try XCTUnwrap(device.makeBuffer(length: 513, options: .storageModeShared))
        XCTAssertEqual(
            try BLAKE3Metal.writeXOF(
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 513,
                seek: 17,
                policy: .gpu,
                into: staticOutputBuffer
            ),
            513
        )
        XCTAssertEqual(readOutput(staticOutputBuffer, count: 513), expectedResidentXOF)

        let privateOutputBuffer = try XCTUnwrap(device.makeBuffer(length: 513, options: .storageModePrivate))
        XCTAssertEqual(
            try context.writeXOF(
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 513,
                seek: 17,
                policy: .gpu,
                into: privateOutputBuffer
            ),
            513
        )
        let readbackBuffer = try XCTUnwrap(device.makeBuffer(length: 513, options: .storageModeShared))
        let commandQueue = try XCTUnwrap(device.makeCommandQueue())
        let commandBuffer = try XCTUnwrap(commandQueue.makeCommandBuffer())
        let blitEncoder = try XCTUnwrap(commandBuffer.makeBlitCommandEncoder())
        blitEncoder.copy(
            from: privateOutputBuffer,
            sourceOffset: 0,
            to: readbackBuffer,
            destinationOffset: 0,
            size: 513
        )
        blitEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        XCTAssertNil(commandBuffer.error)
        XCTAssertEqual(readOutput(readbackBuffer, count: 513), expectedResidentXOF)
        XCTAssertEqual(
            try context.hashOneChunkBatch(buffer: privateOutputBuffer, ranges: [0..<513]).first,
            BLAKE3.hashCPU(expectedResidentXOF)
        )

        var keyedHasher = try BLAKE3.Hasher(key: key)
        keyedHasher.update(input)
        let expectedResidentKeyedXOF = xofBytes(from: keyedHasher, count: 513, seek: 17)
        XCTAssertEqual(
            try context.keyedHash(
                key: key,
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 513,
                seek: 17,
                policy: .gpu
            ),
            expectedResidentKeyedXOF
        )
        let keyedOutputBuffer = try XCTUnwrap(device.makeBuffer(length: 513, options: .storageModeShared))
        XCTAssertEqual(
            try context.writeKeyedXOF(
                key: key,
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 513,
                seek: 17,
                policy: .gpu,
                into: keyedOutputBuffer
            ),
            513
        )
        XCTAssertEqual(readOutput(keyedOutputBuffer, count: 513), expectedResidentKeyedXOF)

        let staticKeyedOutputBuffer = try XCTUnwrap(device.makeBuffer(length: 513, options: .storageModeShared))
        XCTAssertEqual(
            try BLAKE3Metal.writeKeyedXOF(
                key: key,
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 513,
                seek: 17,
                policy: .gpu,
                into: staticKeyedOutputBuffer
            ),
            513
        )
        XCTAssertEqual(readOutput(staticKeyedOutputBuffer, count: 513), expectedResidentKeyedXOF)

        let tooSmallOutputBuffer = try XCTUnwrap(device.makeBuffer(length: 512, options: .storageModeShared))
        XCTAssertThrowsError(
            try context.writeXOF(
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 513,
                seek: 17,
                policy: .gpu,
                into: tooSmallOutputBuffer
            )
        )
        XCTAssertEqual(
            try BLAKE3Metal.hash(input: input, outputByteCount: 0, policy: .gpu),
            []
        )
        XCTAssertEqual(
            try BLAKE3Metal.keyedHash(key: key, input: input, outputByteCount: 0, policy: .gpu),
            []
        )
        XCTAssertEqual(
            try context.writeXOF(
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 0,
                policy: .gpu,
                into: tooSmallOutputBuffer
            ),
            0
        )
    }

    func testMetalDeriveKeyMatchesCPUAndSeek() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let metalContext = try BLAKE3Metal.makeContext(device: device)
        let kdfContext = "BLAKE3 2026-04-20 test derive-key material acceleration"
        let input = deterministicInput(byteCount: 5 * BLAKE3.chunkByteCount + 901)
        let outputSizes = [1, 32, 65, 257, 1_000]
        let seeks: [UInt64] = [0, 1, 64, 65, 511]

        for outputSize in outputSizes {
            for seek in seeks {
                var hasher = BLAKE3.Hasher(deriveKeyContext: kdfContext)
                hasher.update(input)
                let expected = xofBytes(from: hasher, count: outputSize, seek: seek)

                XCTAssertEqual(
                    try BLAKE3Metal.deriveKey(
                        context: kdfContext,
                        material: input,
                        outputByteCount: outputSize,
                        seek: seek,
                        policy: .gpu
                    ),
                    expected,
                    "static derive-key GPU mismatch for outputSize=\(outputSize), seek=\(seek)"
                )
                XCTAssertEqual(
                    try metalContext.deriveKey(
                        context: kdfContext,
                        material: input,
                        outputByteCount: outputSize,
                        seek: seek,
                        policy: .gpu
                    ),
                    expected,
                    "context derive-key GPU mismatch for outputSize=\(outputSize), seek=\(seek)"
                )
            }
        }

        let buffer = try XCTUnwrap(device.makeBuffer(length: input.count + 2, options: .storageModeShared))
        input.withUnsafeBytes { raw in
            buffer.contents().advanced(by: 1).copyMemory(
                from: raw.baseAddress!,
                byteCount: input.count
            )
        }
        var hasher = BLAKE3.Hasher(deriveKeyContext: kdfContext)
        hasher.update(input)
        let expectedResidentDerived = xofBytes(from: hasher, count: 513, seek: 17)
        XCTAssertEqual(
            try metalContext.deriveKey(
                context: kdfContext,
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 513,
                seek: 17,
                policy: .gpu
            ),
            expectedResidentDerived
        )

        func readOutput(_ outputBuffer: MTLBuffer, count: Int) -> [UInt8] {
            Array(
                UnsafeRawBufferPointer(
                    start: outputBuffer.contents(),
                    count: count
                )
            )
        }

        let outputBuffer = try XCTUnwrap(device.makeBuffer(length: 513, options: .storageModeShared))
        XCTAssertEqual(
            try metalContext.writeDerivedKey(
                context: kdfContext,
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 513,
                seek: 17,
                policy: .gpu,
                into: outputBuffer
            ),
            513
        )
        XCTAssertEqual(readOutput(outputBuffer, count: 513), expectedResidentDerived)

        let staticOutputBuffer = try XCTUnwrap(device.makeBuffer(length: 513, options: .storageModeShared))
        XCTAssertEqual(
            try BLAKE3Metal.writeDerivedKey(
                context: kdfContext,
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 513,
                seek: 17,
                policy: .gpu,
                into: staticOutputBuffer
            ),
            513
        )
        XCTAssertEqual(readOutput(staticOutputBuffer, count: 513), expectedResidentDerived)

        XCTAssertEqual(
            try BLAKE3Metal.deriveKey(
                context: kdfContext,
                material: input,
                outputByteCount: 0,
                policy: .gpu
            ),
            []
        )
        XCTAssertEqual(
            try metalContext.writeDerivedKey(
                context: kdfContext,
                buffer: buffer,
                range: 1..<(input.count + 1),
                outputByteCount: 0,
                policy: .gpu,
                into: outputBuffer
            ),
            0
        )
    }

    func testMetalNoCopyHandlesUnalignedWrappedInputBase() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let context = try BLAKE3Metal.makeContext()
        let input = deterministicInput(byteCount: 2 * 1_024 * 1_024)
        var backing = [UInt8](repeating: 0xA5, count: input.count + 1)
        backing.replaceSubrange(1..., with: input)

        let digest = try backing.withUnsafeBytes { raw in
            try context.hash(
                input: UnsafeRawBufferPointer(
                    start: raw.baseAddress!.advanced(by: 1),
                    count: input.count
                ),
                policy: .gpu
            )
        }

        XCTAssertEqual(digest, BLAKE3.hash(input))
    }

    func testMetalAsyncHashMatchesSynchronousPaths() async throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let context = try BLAKE3Metal.makeContext(device: device)
        let input = deterministicInput(byteCount: 2 * 1_024 * 1_024 + 333)
        let expected = BLAKE3.hash(input)
        let buffer = try XCTUnwrap(input.withUnsafeBytes { raw in
            device.makeBuffer(bytes: raw.baseAddress!, length: raw.count, options: .storageModeShared)
        })

        let staticAsyncDigest = try await BLAKE3Metal.hashAsync(buffer: buffer, length: input.count, policy: .gpu)
        XCTAssertEqual(staticAsyncDigest, expected)

        let contextAsyncDigest = try await context.hashAsync(buffer: buffer, length: input.count, policy: .gpu)
        XCTAssertEqual(contextAsyncDigest, expected)

        let stagingBuffer = try context.makeStagingBuffer(capacity: input.count)
        let stagedAsyncDigest = try await context.hashAsync(input: input, using: stagingBuffer, policy: .gpu)
        XCTAssertEqual(stagedAsyncDigest, expected)

        let privateBuffer = try context.makePrivateBuffer(input: input)
        let privateAsyncDigest = try await context.hashAsync(privateBuffer: privateBuffer, policy: .gpu)
        XCTAssertEqual(privateAsyncDigest, expected)
    }

    func testMetalAsyncWorkspaceHandlesConcurrentHashes() async throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let device = try XCTUnwrap(MTLCreateSystemDefaultDevice())
        let context = try BLAKE3Metal.makeContext(device: device)
        let workspace = try context.makeAsyncWorkspace(
            maxPooledResources: 2,
            preallocateForByteCount: 3 * 1_024 * 1_024 + 777
        )
        let inputs = [
            deterministicInput(byteCount: 2 * 1_024 * 1_024 + 333),
            deterministicInput(byteCount: 2 * 1_024 * 1_024 + 777),
            deterministicInput(byteCount: 3 * 1_024 * 1_024 + 17),
            deterministicInput(byteCount: 3 * 1_024 * 1_024 + 777)
        ]
        let expected = inputs.map { BLAKE3.hash($0) }
        let cases = try inputs.enumerated().map { index, input in
            let buffer = try XCTUnwrap(input.withUnsafeBytes { raw in
                device.makeBuffer(bytes: raw.baseAddress!, length: raw.count, options: .storageModeShared)
            })
            return AsyncMetalHashCase(index: index, byteCount: input.count, buffer: buffer)
        }

        try await withThrowingTaskGroup(of: (Int, BLAKE3.Digest).self) { group in
            for testCase in cases {
                group.addTask {
                    let digest = try await context.hashAsync(
                        buffer: testCase.buffer,
                        length: testCase.byteCount,
                        policy: .gpu,
                        workspace: workspace
                    )
                    return (testCase.index, digest)
                }
            }
            for try await (index, digest) in group {
                XCTAssertEqual(digest, expected[index])
            }
        }
    }

    func testMetalAsyncPipelineHashesConcurrentSwiftOwnedInputs() async throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let context = try BLAKE3Metal.makeContext()
        let inputs = [
            deterministicInput(byteCount: 2 * 1_024 * 1_024 + 333),
            deterministicInput(byteCount: 2 * 1_024 * 1_024 + 777),
            deterministicInput(byteCount: 3 * 1_024 * 1_024 + 17),
            deterministicInput(byteCount: 3 * 1_024 * 1_024 + 777)
        ]
        let inputCapacity = try XCTUnwrap(inputs.map(\.count).max())
        let expected = inputs.map { BLAKE3.hash($0) }
        let pipeline = try context.makeAsyncPipeline(
            inputCapacity: inputCapacity,
            inFlightCount: 2,
            policy: .gpu
        )

        try await withThrowingTaskGroup(of: (Int, BLAKE3.Digest).self) { group in
            for (index, input) in inputs.enumerated() {
                group.addTask {
                    let digest = try await pipeline.hash(input: input)
                    return (index, digest)
                }
            }
            for try await (index, digest) in group {
                XCTAssertEqual(digest, expected[index])
            }
        }

        let tooLarge = deterministicInput(byteCount: inputCapacity + 1)
        do {
            _ = try await pipeline.hash(input: tooLarge)
            XCTFail("Expected the async pipeline to reject input beyond its staging capacity.")
        } catch {
            // Expected.
        }
    }

    func testMetalAsyncPipelinePrivateUploadModeHashesConcurrentInputs() async throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let context = try BLAKE3Metal.makeContext()
        let inputs = [
            deterministicInput(byteCount: 2 * 1_024 * 1_024 + 333),
            deterministicInput(byteCount: 3 * 1_024 * 1_024 + 777),
            [UInt8]()
        ]
        let inputCapacity = try XCTUnwrap(inputs.map(\.count).max())
        let expected = inputs.map { BLAKE3.hash($0) }
        let pipeline = try context.makeAsyncPipeline(
            inputCapacity: inputCapacity,
            inFlightCount: 2,
            policy: .gpu,
            usesPrivateBuffers: true
        )

        try await withThrowingTaskGroup(of: (Int, BLAKE3.Digest).self) { group in
            for (index, input) in inputs.enumerated() {
                group.addTask {
                    let digest = try await pipeline.hash(input: input)
                    return (index, digest)
                }
            }
            for try await (index, digest) in group {
                XCTAssertEqual(digest, expected[index])
            }
        }
    }

    func testMetalPrivateBufferHashesAndReplacesSwiftOwnedInput() throws {
        guard BLAKE3Metal.isAvailable else {
            throw XCTSkip("Metal is not available on this host.")
        }
        let context = try BLAKE3Metal.makeContext()
        let first = deterministicInput(byteCount: 2 * 1_024 * 1_024 + 333)
        let second = deterministicInput(byteCount: 1 * 1_024 * 1_024 + 17)
        let stagingBuffer = try context.makeStagingBuffer(capacity: first.count)
        let privateBuffer = try context.makePrivateBuffer(input: first)

        XCTAssertEqual(privateBuffer.byteCount, first.count)
        XCTAssertEqual(
            try context.hash(privateBuffer: privateBuffer),
            BLAKE3.hash(first)
        )

        try context.replaceContents(of: privateBuffer, with: second)
        XCTAssertEqual(privateBuffer.byteCount, second.count)
        XCTAssertEqual(
            try context.hash(privateBuffer: privateBuffer),
            BLAKE3.hash(second)
        )

        try context.replaceContents(of: privateBuffer, with: first, using: stagingBuffer)
        XCTAssertEqual(privateBuffer.byteCount, first.count)
        XCTAssertEqual(
            try context.hash(privateBuffer: privateBuffer),
            BLAKE3.hash(first)
        )

        let combinedDigest = try context.hash(
            input: second,
            using: stagingBuffer,
            privateBuffer: privateBuffer,
            policy: .gpu
        )
        XCTAssertEqual(combinedDigest, BLAKE3.hash(second))
        XCTAssertEqual(privateBuffer.byteCount, second.count)
        XCTAssertEqual(
            try context.hash(privateBuffer: privateBuffer),
            BLAKE3.hash(second)
        )

        let large = deterministicInput(byteCount: 17 * 1_024 * 1_024 + 17)
        let largeStagingBuffer = try context.makeStagingBuffer(capacity: large.count)
        let largePrivateBuffer = try context.makePrivateBuffer(capacity: large.count)
        let splitDigest = try context.hash(
            input: large,
            using: largeStagingBuffer,
            privateBuffer: largePrivateBuffer,
            policy: .gpu
        )
        XCTAssertEqual(splitDigest, BLAKE3.hash(large))
        XCTAssertEqual(largePrivateBuffer.byteCount, large.count)
        XCTAssertEqual(
            try context.hash(privateBuffer: largePrivateBuffer),
            BLAKE3.hash(large)
        )

        let tooLarge = deterministicInput(byteCount: first.count + 1)
        XCTAssertThrowsError(try context.replaceContents(of: privateBuffer, with: tooLarge))
        XCTAssertThrowsError(
            try context.hash(
                input: tooLarge,
                using: stagingBuffer,
                privateBuffer: privateBuffer,
                policy: .gpu
            )
        )
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
