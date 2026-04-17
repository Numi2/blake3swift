import Foundation

enum BLAKE3SIMD4 {
    private typealias Vector = SIMD4<UInt32>

    private struct CV4 {
        var v0: Vector
        var v1: Vector
        var v2: Vector
        var v3: Vector
        var v4: Vector
        var v5: Vector
        var v6: Vector
        var v7: Vector

        init(
            _ v0: Vector,
            _ v1: Vector,
            _ v2: Vector,
            _ v3: Vector,
            _ v4: Vector,
            _ v5: Vector,
            _ v6: Vector,
            _ v7: Vector
        ) {
            self.v0 = v0
            self.v1 = v1
            self.v2 = v2
            self.v3 = v3
            self.v4 = v4
            self.v5 = v5
            self.v6 = v6
            self.v7 = v7
        }

        @inline(__always)
        subscript(index: Int) -> Vector {
            get {
                switch index {
                case 0: v0
                case 1: v1
                case 2: v2
                case 3: v3
                case 4: v4
                case 5: v5
                case 6: v6
                case 7: v7
                default: preconditionFailure("Invalid CV4 index")
                }
            }
            set {
                switch index {
                case 0: v0 = newValue
                case 1: v1 = newValue
                case 2: v2 = newValue
                case 3: v3 = newValue
                case 4: v4 = newValue
                case 5: v5 = newValue
                case 6: v6 = newValue
                case 7: v7 = newValue
                default: preconditionFailure("Invalid CV4 index")
                }
            }
        }
    }

    private struct BlockWords4 {
        var v0: Vector
        var v1: Vector
        var v2: Vector
        var v3: Vector
        var v4: Vector
        var v5: Vector
        var v6: Vector
        var v7: Vector
        var v8: Vector
        var v9: Vector
        var v10: Vector
        var v11: Vector
        var v12: Vector
        var v13: Vector
        var v14: Vector
        var v15: Vector

        init(
            _ v0: Vector,
            _ v1: Vector,
            _ v2: Vector,
            _ v3: Vector,
            _ v4: Vector,
            _ v5: Vector,
            _ v6: Vector,
            _ v7: Vector,
            _ v8: Vector,
            _ v9: Vector,
            _ v10: Vector,
            _ v11: Vector,
            _ v12: Vector,
            _ v13: Vector,
            _ v14: Vector,
            _ v15: Vector
        ) {
            self.v0 = v0
            self.v1 = v1
            self.v2 = v2
            self.v3 = v3
            self.v4 = v4
            self.v5 = v5
            self.v6 = v6
            self.v7 = v7
            self.v8 = v8
            self.v9 = v9
            self.v10 = v10
            self.v11 = v11
            self.v12 = v12
            self.v13 = v13
            self.v14 = v14
            self.v15 = v15
        }

        @inline(__always)
        subscript(index: Int) -> Vector {
            get {
                switch index {
                case 0: v0
                case 1: v1
                case 2: v2
                case 3: v3
                case 4: v4
                case 5: v5
                case 6: v6
                case 7: v7
                case 8: v8
                case 9: v9
                case 10: v10
                case 11: v11
                case 12: v12
                case 13: v13
                case 14: v14
                case 15: v15
                default: preconditionFailure("Invalid BlockWords4 index")
                }
            }
            set {
                switch index {
                case 0: v0 = newValue
                case 1: v1 = newValue
                case 2: v2 = newValue
                case 3: v3 = newValue
                case 4: v4 = newValue
                case 5: v5 = newValue
                case 6: v6 = newValue
                case 7: v7 = newValue
                case 8: v8 = newValue
                case 9: v9 = newValue
                case 10: v10 = newValue
                case 11: v11 = newValue
                case 12: v12 = newValue
                case 13: v13 = newValue
                case 14: v14 = newValue
                case 15: v15 = newValue
                default: preconditionFailure("Invalid BlockWords4 index")
                }
            }
        }
    }

    @inline(__always)
    static func hashFourFullChunks(
        input: BLAKE3Core.SendableRawBuffer,
        firstChunkIndex: Int,
        firstChunkCounter: Int,
        key: BLAKE3Core.ChainingValue,
        flags: UInt32,
        output: BLAKE3Core.SendableCVStorage
    ) {
        var cv = CV4(
            Vector(repeating: key[0]),
            Vector(repeating: key[1]),
            Vector(repeating: key[2]),
            Vector(repeating: key[3]),
            Vector(repeating: key[4]),
            Vector(repeating: key[5]),
            Vector(repeating: key[6]),
            Vector(repeating: key[7])
        )

        let counters = (
            UInt64(firstChunkCounter),
            UInt64(firstChunkCounter + 1),
            UInt64(firstChunkCounter + 2),
            UInt64(firstChunkCounter + 3)
        )
        let counterLow = Vector(
            UInt32(truncatingIfNeeded: counters.0),
            UInt32(truncatingIfNeeded: counters.1),
            UInt32(truncatingIfNeeded: counters.2),
            UInt32(truncatingIfNeeded: counters.3)
        )
        let counterHigh = Vector(
            UInt32(truncatingIfNeeded: counters.0 >> 32),
            UInt32(truncatingIfNeeded: counters.1 >> 32),
            UInt32(truncatingIfNeeded: counters.2 >> 32),
            UInt32(truncatingIfNeeded: counters.3 >> 32)
        )

        for blockIndex in 0..<16 {
            var blockFlags = flags
            if blockIndex == 0 {
                blockFlags |= BLAKE3Core.chunkStart
            }
            if blockIndex == 15 {
                blockFlags |= BLAKE3Core.chunkEnd
            }

            compressInPlace(
                cv: &cv,
                blockWords: loadBlockWords(input: input, firstChunkIndex: firstChunkIndex, blockIndex: blockIndex),
                blockLength: Vector(repeating: UInt32(BLAKE3Core.blockLen)),
                counterLow: counterLow,
                counterHigh: counterHigh,
                flags: Vector(repeating: blockFlags)
            )
        }

        for lane in 0..<4 {
            output.store(
                BLAKE3Core.ChainingValue(
                    cv.v0[lane],
                    cv.v1[lane],
                    cv.v2[lane],
                    cv.v3[lane],
                    cv.v4[lane],
                    cv.v5[lane],
                    cv.v6[lane],
                    cv.v7[lane]
                ),
                at: firstChunkIndex + lane
            )
        }
    }

    @inline(__always)
    static func hashFourParents(
        input: BLAKE3Core.SendableCVInput,
        firstParentIndex: Int,
        key: BLAKE3Core.ChainingValue,
        flags: UInt32,
        output: BLAKE3Core.SendableCVStorage
    ) {
        var cv = CV4(
            Vector(repeating: key[0]),
            Vector(repeating: key[1]),
            Vector(repeating: key[2]),
            Vector(repeating: key[3]),
            Vector(repeating: key[4]),
            Vector(repeating: key[5]),
            Vector(repeating: key[6]),
            Vector(repeating: key[7])
        )
        compressInPlace(
            cv: &cv,
            blockWords: loadParentBlockWords(input: input, firstParentIndex: firstParentIndex),
            blockLength: Vector(repeating: UInt32(BLAKE3Core.blockLen)),
            counterLow: Vector(repeating: 0),
            counterHigh: Vector(repeating: 0),
            flags: Vector(repeating: flags | BLAKE3Core.parent)
        )

        for lane in 0..<4 {
            output.store(
                BLAKE3Core.ChainingValue(
                    cv.v0[lane],
                    cv.v1[lane],
                    cv.v2[lane],
                    cv.v3[lane],
                    cv.v4[lane],
                    cv.v5[lane],
                    cv.v6[lane],
                    cv.v7[lane]
                ),
                at: firstParentIndex + lane
            )
        }
    }

    @inline(__always)
    private static func loadBlockWords(
        input: BLAKE3Core.SendableRawBuffer,
        firstChunkIndex: Int,
        blockIndex: Int
    ) -> BlockWords4 {
        let blockByteOffset = blockIndex * BLAKE3Core.blockLen
        return BlockWords4(
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 0),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 4),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 8),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 12),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 16),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 20),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 24),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 28),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 32),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 36),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 40),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 44),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 48),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 52),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 56),
            loadWordVector(input, firstChunkIndex: firstChunkIndex, wordByteOffset: blockByteOffset + 60)
        )
    }

    @inline(__always)
    private static func loadParentBlockWords(
        input: BLAKE3Core.SendableCVInput,
        firstParentIndex: Int
    ) -> BlockWords4 {
        let left0 = input[firstParentIndex * 2]
        let right0 = input[firstParentIndex * 2 + 1]
        let left1 = input[(firstParentIndex + 1) * 2]
        let right1 = input[(firstParentIndex + 1) * 2 + 1]
        let left2 = input[(firstParentIndex + 2) * 2]
        let right2 = input[(firstParentIndex + 2) * 2 + 1]
        let left3 = input[(firstParentIndex + 3) * 2]
        let right3 = input[(firstParentIndex + 3) * 2 + 1]

        return BlockWords4(
            Vector(left0[0], left1[0], left2[0], left3[0]),
            Vector(left0[1], left1[1], left2[1], left3[1]),
            Vector(left0[2], left1[2], left2[2], left3[2]),
            Vector(left0[3], left1[3], left2[3], left3[3]),
            Vector(left0[4], left1[4], left2[4], left3[4]),
            Vector(left0[5], left1[5], left2[5], left3[5]),
            Vector(left0[6], left1[6], left2[6], left3[6]),
            Vector(left0[7], left1[7], left2[7], left3[7]),
            Vector(right0[0], right1[0], right2[0], right3[0]),
            Vector(right0[1], right1[1], right2[1], right3[1]),
            Vector(right0[2], right1[2], right2[2], right3[2]),
            Vector(right0[3], right1[3], right2[3], right3[3]),
            Vector(right0[4], right1[4], right2[4], right3[4]),
            Vector(right0[5], right1[5], right2[5], right3[5]),
            Vector(right0[6], right1[6], right2[6], right3[6]),
            Vector(right0[7], right1[7], right2[7], right3[7])
        )
    }

    @inline(__always)
    private static func loadWordVector(
        _ input: BLAKE3Core.SendableRawBuffer,
        firstChunkIndex: Int,
        wordByteOffset: Int
    ) -> Vector {
        Vector(
            load32(input, chunkIndex: firstChunkIndex, wordByteOffset: wordByteOffset),
            load32(input, chunkIndex: firstChunkIndex + 1, wordByteOffset: wordByteOffset),
            load32(input, chunkIndex: firstChunkIndex + 2, wordByteOffset: wordByteOffset),
            load32(input, chunkIndex: firstChunkIndex + 3, wordByteOffset: wordByteOffset)
        )
    }

    @inline(__always)
    private static func load32(
        _ input: BLAKE3Core.SendableRawBuffer,
        chunkIndex: Int,
        wordByteOffset: Int
    ) -> UInt32 {
        let offset = chunkIndex * BLAKE3Core.chunkLen + wordByteOffset
        return UInt32(littleEndian: input.baseAddress.advanced(by: offset).loadUnaligned(as: UInt32.self))
    }

    @inline(__always)
    private static func compressInPlace(
        cv: inout CV4,
        blockWords: BlockWords4,
        blockLength: Vector,
        counterLow: Vector,
        counterHigh: Vector,
        flags: Vector
    ) {
        let state = compressedState(
            cv: cv,
            blockWords: blockWords,
            blockLength: blockLength,
            counterLow: counterLow,
            counterHigh: counterHigh,
            flags: flags
        )

        cv.v0 = state.v0 ^ state.v8
        cv.v1 = state.v1 ^ state.v9
        cv.v2 = state.v2 ^ state.v10
        cv.v3 = state.v3 ^ state.v11
        cv.v4 = state.v4 ^ state.v12
        cv.v5 = state.v5 ^ state.v13
        cv.v6 = state.v6 ^ state.v14
        cv.v7 = state.v7 ^ state.v15
    }

    @inline(__always)
    private static func compressedState(
        cv: CV4,
        blockWords: BlockWords4,
        blockLength: Vector,
        counterLow: Vector,
        counterHigh: Vector,
        flags: Vector
    ) -> BlockWords4 {
        var state = BlockWords4(
            cv.v0, cv.v1, cv.v2, cv.v3,
            cv.v4, cv.v5, cv.v6, cv.v7,
            Vector(repeating: BLAKE3Core.iv[0]),
            Vector(repeating: BLAKE3Core.iv[1]),
            Vector(repeating: BLAKE3Core.iv[2]),
            Vector(repeating: BLAKE3Core.iv[3]),
            counterLow,
            counterHigh,
            blockLength,
            flags
        )

        roundFunction(
            state: &state,
            blockWords.v0, blockWords.v1, blockWords.v2, blockWords.v3,
            blockWords.v4, blockWords.v5, blockWords.v6, blockWords.v7,
            blockWords.v8, blockWords.v9, blockWords.v10, blockWords.v11,
            blockWords.v12, blockWords.v13, blockWords.v14, blockWords.v15
        )
        roundFunction(
            state: &state,
            blockWords.v2, blockWords.v6, blockWords.v3, blockWords.v10,
            blockWords.v7, blockWords.v0, blockWords.v4, blockWords.v13,
            blockWords.v1, blockWords.v11, blockWords.v12, blockWords.v5,
            blockWords.v9, blockWords.v14, blockWords.v15, blockWords.v8
        )
        roundFunction(
            state: &state,
            blockWords.v3, blockWords.v4, blockWords.v10, blockWords.v12,
            blockWords.v13, blockWords.v2, blockWords.v7, blockWords.v14,
            blockWords.v6, blockWords.v5, blockWords.v9, blockWords.v0,
            blockWords.v11, blockWords.v15, blockWords.v8, blockWords.v1
        )
        roundFunction(
            state: &state,
            blockWords.v10, blockWords.v7, blockWords.v12, blockWords.v9,
            blockWords.v14, blockWords.v3, blockWords.v13, blockWords.v15,
            blockWords.v4, blockWords.v0, blockWords.v11, blockWords.v2,
            blockWords.v5, blockWords.v8, blockWords.v1, blockWords.v6
        )
        roundFunction(
            state: &state,
            blockWords.v12, blockWords.v13, blockWords.v9, blockWords.v11,
            blockWords.v15, blockWords.v10, blockWords.v14, blockWords.v8,
            blockWords.v7, blockWords.v2, blockWords.v5, blockWords.v3,
            blockWords.v0, blockWords.v1, blockWords.v6, blockWords.v4
        )
        roundFunction(
            state: &state,
            blockWords.v9, blockWords.v14, blockWords.v11, blockWords.v5,
            blockWords.v8, blockWords.v12, blockWords.v15, blockWords.v1,
            blockWords.v13, blockWords.v3, blockWords.v0, blockWords.v10,
            blockWords.v2, blockWords.v6, blockWords.v4, blockWords.v7
        )
        roundFunction(
            state: &state,
            blockWords.v11, blockWords.v15, blockWords.v5, blockWords.v0,
            blockWords.v1, blockWords.v9, blockWords.v8, blockWords.v6,
            blockWords.v14, blockWords.v10, blockWords.v2, blockWords.v12,
            blockWords.v3, blockWords.v4, blockWords.v7, blockWords.v13
        )
        return state
    }

    @inline(__always)
    private static func roundFunction(
        state: inout BlockWords4,
        _ m0: Vector,
        _ m1: Vector,
        _ m2: Vector,
        _ m3: Vector,
        _ m4: Vector,
        _ m5: Vector,
        _ m6: Vector,
        _ m7: Vector,
        _ m8: Vector,
        _ m9: Vector,
        _ m10: Vector,
        _ m11: Vector,
        _ m12: Vector,
        _ m13: Vector,
        _ m14: Vector,
        _ m15: Vector
    ) {
        g(&state.v0, &state.v4, &state.v8, &state.v12, m0, m1)
        g(&state.v1, &state.v5, &state.v9, &state.v13, m2, m3)
        g(&state.v2, &state.v6, &state.v10, &state.v14, m4, m5)
        g(&state.v3, &state.v7, &state.v11, &state.v15, m6, m7)
        g(&state.v0, &state.v5, &state.v10, &state.v15, m8, m9)
        g(&state.v1, &state.v6, &state.v11, &state.v12, m10, m11)
        g(&state.v2, &state.v7, &state.v8, &state.v13, m12, m13)
        g(&state.v3, &state.v4, &state.v9, &state.v14, m14, m15)
    }

    @inline(__always)
    private static func g(
        _ a: inout Vector,
        _ b: inout Vector,
        _ c: inout Vector,
        _ d: inout Vector,
        _ x: Vector,
        _ y: Vector
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
    private static func rotateRight(_ word: Vector, by count: UInt32) -> Vector {
        (word &>> count) | (word &<< (32 - count))
    }

    @inline(__always)
    private static func rotateRight(_ word: UInt32, by count: UInt32) -> UInt32 {
        (word >> count) | (word << (32 - count))
    }
}
