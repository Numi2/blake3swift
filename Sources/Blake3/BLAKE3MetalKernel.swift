#if canImport(Metal)
import Foundation
import Metal

struct BLAKE3MetalChunkParams {
    var inputOffset: UInt64
    var inputLength: UInt64
    var baseChunkCounter: UInt64
    var chunkCount: UInt32
    var padding: UInt32 = 0
}

struct BLAKE3MetalParentParams {
    var inputCount: UInt32
    var padding0: UInt32 = 0
    var padding1: UInt32 = 0
    var padding2: UInt32 = 0
}

struct BLAKE3MetalPipelines {
    let chunkCVs: MTLComputePipelineState
    let chunkFullCVs: MTLComputePipelineState
    let parentCVs: MTLComputePipelineState
    let parent4CVs: MTLComputePipelineState
    let parent16CVs: MTLComputePipelineState
    let parent16TailCVs: MTLComputePipelineState
    let rootDigest: MTLComputePipelineState
    let root3Digest: MTLComputePipelineState
    let root4Digest: MTLComputePipelineState
}

final class BLAKE3MetalPipelineCache: @unchecked Sendable {
    static let shared = BLAKE3MetalPipelineCache()

    private let lock = NSLock()
    private var pipelines: [UInt64: BLAKE3MetalPipelines] = [:]

    private init() {}

    func pipelines(device: MTLDevice) throws -> BLAKE3MetalPipelines {
        lock.lock()
        if let pipelines = pipelines[device.registryID] {
            lock.unlock()
            return pipelines
        }
        lock.unlock()

        let library = try device.makeLibrary(source: BLAKE3MetalKernelSource.chunkCVs, options: nil)
        guard let chunkFunction = library.makeFunction(name: "blake3_chunk_cvs"),
              let chunkFullFunction = library.makeFunction(name: "blake3_chunk_full_cvs"),
              let parentFunction = library.makeFunction(name: "blake3_parent_cvs"),
              let parent4Function = library.makeFunction(name: "blake3_parent4_cvs"),
              let parent16Function = library.makeFunction(name: "blake3_parent16_cvs"),
              let parent16TailFunction = library.makeFunction(name: "blake3_parent16_tail_cvs"),
              let rootFunction = library.makeFunction(name: "blake3_root_digest"),
              let root3Function = library.makeFunction(name: "blake3_root3_digest"),
              let root4Function = library.makeFunction(name: "blake3_root4_digest")
        else {
            throw BLAKE3Error.metalCommandFailed("Unable to load BLAKE3 Metal kernels.")
        }
        let pipelines = BLAKE3MetalPipelines(
            chunkCVs: try device.makeComputePipelineState(function: chunkFunction),
            chunkFullCVs: try device.makeComputePipelineState(function: chunkFullFunction),
            parentCVs: try device.makeComputePipelineState(function: parentFunction),
            parent4CVs: try device.makeComputePipelineState(function: parent4Function),
            parent16CVs: try device.makeComputePipelineState(function: parent16Function),
            parent16TailCVs: try device.makeComputePipelineState(function: parent16TailFunction),
            rootDigest: try device.makeComputePipelineState(function: rootFunction),
            root3Digest: try device.makeComputePipelineState(function: root3Function),
            root4Digest: try device.makeComputePipelineState(function: root4Function)
        )

        lock.lock()
        self.pipelines[device.registryID] = pipelines
        lock.unlock()

        return pipelines
    }
}

enum BLAKE3MetalKernelSource {
    static let chunkCVs = """
    #include <metal_stdlib>
    using namespace metal;

    struct BLAKE3ChunkParams {
        ulong inputOffset;
        ulong inputLength;
        ulong baseChunkCounter;
        uint chunkCount;
        uint padding;
    };

    struct BLAKE3ParentParams {
        uint inputCount;
        uint padding0;
        uint padding1;
        uint padding2;
    };

    constant uint IV[8] = {
        0x6A09E667u, 0xBB67AE85u, 0x3C6EF372u, 0xA54FF53Au,
        0x510E527Fu, 0x9B05688Cu, 0x1F83D9ABu, 0x5BE0CD19u
    };

    constant uchar MSG_SCHEDULE[112] = {
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
        2, 6, 3, 10, 7, 0, 4, 13, 1, 11, 12, 5, 9, 14, 15, 8,
        3, 4, 10, 12, 13, 2, 7, 14, 6, 5, 9, 0, 11, 15, 8, 1,
        10, 7, 12, 9, 14, 3, 13, 15, 4, 0, 11, 2, 5, 8, 1, 6,
        12, 13, 9, 11, 15, 10, 14, 8, 7, 2, 5, 3, 0, 1, 6, 4,
        9, 14, 11, 5, 8, 12, 15, 1, 13, 3, 0, 10, 2, 6, 4, 7,
        11, 15, 5, 0, 1, 9, 8, 6, 14, 10, 2, 12, 3, 4, 7, 13
    };

    static inline uint rotr32(uint word, uint count) {
        return (word >> count) | (word << (32u - count));
    }

    static inline void g(thread uint state[16], uint a, uint b, uint c, uint d, uint x, uint y) {
        state[a] = state[a] + state[b] + x;
        state[d] = rotr32(state[d] ^ state[a], 16u);
        state[c] = state[c] + state[d];
        state[b] = rotr32(state[b] ^ state[c], 12u);
        state[a] = state[a] + state[b] + y;
        state[d] = rotr32(state[d] ^ state[a], 8u);
        state[c] = state[c] + state[d];
        state[b] = rotr32(state[b] ^ state[c], 7u);
    }

    static inline void round_fn(thread uint state[16], thread const uint msg[16], uint round) {
        uint base = round * 16u;
        g(state, 0u, 4u, 8u, 12u, msg[MSG_SCHEDULE[base + 0u]], msg[MSG_SCHEDULE[base + 1u]]);
        g(state, 1u, 5u, 9u, 13u, msg[MSG_SCHEDULE[base + 2u]], msg[MSG_SCHEDULE[base + 3u]]);
        g(state, 2u, 6u, 10u, 14u, msg[MSG_SCHEDULE[base + 4u]], msg[MSG_SCHEDULE[base + 5u]]);
        g(state, 3u, 7u, 11u, 15u, msg[MSG_SCHEDULE[base + 6u]], msg[MSG_SCHEDULE[base + 7u]]);
        g(state, 0u, 5u, 10u, 15u, msg[MSG_SCHEDULE[base + 8u]], msg[MSG_SCHEDULE[base + 9u]]);
        g(state, 1u, 6u, 11u, 12u, msg[MSG_SCHEDULE[base + 10u]], msg[MSG_SCHEDULE[base + 11u]]);
        g(state, 2u, 7u, 8u, 13u, msg[MSG_SCHEDULE[base + 12u]], msg[MSG_SCHEDULE[base + 13u]]);
        g(state, 3u, 4u, 9u, 14u, msg[MSG_SCHEDULE[base + 14u]], msg[MSG_SCHEDULE[base + 15u]]);
    }

    static inline uint load32_chunk(device const uchar *chunk, uint offset, uint chunkLength) {
        uint word = 0u;
        if (offset < chunkLength) {
            word |= uint(chunk[offset]);
        }
        if (offset + 1u < chunkLength) {
            word |= uint(chunk[offset + 1u]) << 8u;
        }
        if (offset + 2u < chunkLength) {
            word |= uint(chunk[offset + 2u]) << 16u;
        }
        if (offset + 3u < chunkLength) {
            word |= uint(chunk[offset + 3u]) << 24u;
        }
        return word;
    }

    static inline uint load32_exact(device const uchar *bytes, uint offset) {
        return uint(bytes[offset]) |
            (uint(bytes[offset + 1u]) << 8u) |
            (uint(bytes[offset + 2u]) << 16u) |
            (uint(bytes[offset + 3u]) << 24u);
    }

    static inline uint load32_aligned(device const uint *words, uint wordOffset) {
        return words[wordOffset];
    }

    static inline void store32_aligned(device uint *words, uint wordOffset, uint word) {
        words[wordOffset] = word;
    }

    static inline void compress_in_place(thread uint cv[8],
                                         thread const uint blockWords[16],
                                         uint blockLength,
                                         ulong counter,
                                         uint flags) {
        uint state[16];
        state[0] = cv[0];
        state[1] = cv[1];
        state[2] = cv[2];
        state[3] = cv[3];
        state[4] = cv[4];
        state[5] = cv[5];
        state[6] = cv[6];
        state[7] = cv[7];
        state[8] = IV[0];
        state[9] = IV[1];
        state[10] = IV[2];
        state[11] = IV[3];
        state[12] = uint(counter & 0xffffffffUL);
        state[13] = uint(counter >> 32);
        state[14] = blockLength;
        state[15] = flags;

        round_fn(state, blockWords, 0u);
        round_fn(state, blockWords, 1u);
        round_fn(state, blockWords, 2u);
        round_fn(state, blockWords, 3u);
        round_fn(state, blockWords, 4u);
        round_fn(state, blockWords, 5u);
        round_fn(state, blockWords, 6u);

        cv[0] = state[0] ^ state[8];
        cv[1] = state[1] ^ state[9];
        cv[2] = state[2] ^ state[10];
        cv[3] = state[3] ^ state[11];
        cv[4] = state[4] ^ state[12];
        cv[5] = state[5] ^ state[13];
        cv[6] = state[6] ^ state[14];
        cv[7] = state[7] ^ state[15];
    }

    static inline void parent_cv(thread uint outCV[8], thread const uint blockWords[16]) {
        uint cv[8] = {
            IV[0], IV[1], IV[2], IV[3],
            IV[4], IV[5], IV[6], IV[7]
        };
        compress_in_place(cv, blockWords, 64u, 0UL, 4u);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            outCV[wordIndex] = cv[wordIndex];
        }
    }

    static inline void reduce_tail_cvs(thread uint cvs[15][8], uint count) {
        while (count > 1u) {
            uint parentCount = count / 2u;
            for (uint parentIndex = 0u; parentIndex < parentCount; parentIndex++) {
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex] = cvs[parentIndex * 2u][wordIndex];
                    blockWords[wordIndex + 8u] = cvs[parentIndex * 2u + 1u][wordIndex];
                }
                parent_cv(cvs[parentIndex], blockWords);
            }

            if ((count & 1u) != 0u) {
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    cvs[parentCount][wordIndex] = cvs[count - 1u][wordIndex];
                }
                count = parentCount + 1u;
            } else {
                count = parentCount;
            }
        }
    }

    static inline void store32(device uchar *destination, uint word) {
        destination[0] = uchar(word);
        destination[1] = uchar(word >> 8u);
        destination[2] = uchar(word >> 16u);
        destination[3] = uchar(word >> 24u);
    }

    static inline void chunk_cv(device const uchar *input,
                                constant BLAKE3ChunkParams &params,
                                uint chunkIndex,
                                thread uint cv[8]) {
        ulong chunkOffset = ulong(chunkIndex) * 1024UL;
        ulong remaining = params.inputLength - chunkOffset;
        uint chunkLength = remaining > 1024UL ? 1024u : uint(remaining);
        device const uchar *chunk = input + params.inputOffset + chunkOffset;
        ulong chunkCounter = params.baseChunkCounter + ulong(chunkIndex);
        bool canLoadWords = (params.inputOffset & 3UL) == 0UL;

        cv[0] = IV[0];
        cv[1] = IV[1];
        cv[2] = IV[2];
        cv[3] = IV[3];
        cv[4] = IV[4];
        cv[5] = IV[5];
        cv[6] = IV[6];
        cv[7] = IV[7];

        if (chunkLength == 1024u && canLoadWords) {
            device const uint *chunkWords32 = reinterpret_cast<device const uint *>(chunk);
            for (uint blockIndex = 0u; blockIndex < 16u; blockIndex++) {
                uint flags = 0u;
                if (blockIndex == 0u) {
                    flags |= 1u;
                }
                if (blockIndex == 15u) {
                    flags |= 2u;
                }

                uint wordBase = blockIndex * 16u;
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_aligned(chunkWords32, wordBase + wordIndex);
                }

                compress_in_place(cv, blockWords, 64u, chunkCounter, flags);
            }
        } else if (chunkLength == 1024u) {
            for (uint blockIndex = 0u; blockIndex < 16u; blockIndex++) {
                uint blockOffset = blockIndex * 64u;
                uint flags = 0u;
                if (blockIndex == 0u) {
                    flags |= 1u;
                }
                if (blockIndex == 15u) {
                    flags |= 2u;
                }

                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_exact(chunk, blockOffset + wordIndex * 4u);
                }

                compress_in_place(cv, blockWords, 64u, chunkCounter, flags);
            }
        } else {
            for (uint blockOffset = 0u; blockOffset < chunkLength; blockOffset += 64u) {
                uint remainingInChunk = chunkLength - blockOffset;
                uint blockLength = remainingInChunk > 64u ? 64u : remainingInChunk;
                uint flags = 0u;
                if (blockOffset == 0u) {
                    flags |= 1u;
                }
                if (blockOffset + blockLength == chunkLength) {
                    flags |= 2u;
                }

                uint blockWords[16];
                if (canLoadWords && blockLength == 64u) {
                    device const uint *chunkWords32 = reinterpret_cast<device const uint *>(chunk);
                    uint wordBase = blockOffset >> 2u;
                    for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                        blockWords[wordIndex] = load32_aligned(chunkWords32, wordBase + wordIndex);
                    }
                } else {
                    for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                        blockWords[wordIndex] = load32_chunk(chunk, blockOffset + wordIndex * 4u, chunkLength);
                    }
                }

                compress_in_place(cv, blockWords, blockLength, chunkCounter, flags);
            }
        }
    }

    kernel void blake3_chunk_cvs(device const uchar *input [[buffer(0)]],
                                 device uchar *chunkCVs [[buffer(1)]],
                                 constant BLAKE3ChunkParams &params [[buffer(2)]],
                                 uint gid [[thread_position_in_grid]]) {
        if (gid >= params.chunkCount) {
            return;
        }

        uint cv[8];
        chunk_cv(input, params, gid, cv);
        device uint *out = reinterpret_cast<device uint *>(chunkCVs + ulong(gid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_chunk_full_cvs(device const uchar *input [[buffer(0)]],
                                      device uchar *chunkCVs [[buffer(1)]],
                                      constant BLAKE3ChunkParams &params [[buffer(2)]],
                                      uint gid [[thread_position_in_grid]]) {
        device const uchar *chunk = input + params.inputOffset + ulong(gid) * 1024UL;
        ulong chunkCounter = params.baseChunkCounter + ulong(gid);
        bool canLoadWords = (params.inputOffset & 3UL) == 0UL;

        uint cv[8] = {
            IV[0], IV[1], IV[2], IV[3],
            IV[4], IV[5], IV[6], IV[7]
        };

        if (canLoadWords) {
            device const uint *chunkWords32 = reinterpret_cast<device const uint *>(chunk);
            for (uint blockIndex = 0u; blockIndex < 16u; blockIndex++) {
                uint flags = 0u;
                if (blockIndex == 0u) {
                    flags |= 1u;
                }
                if (blockIndex == 15u) {
                    flags |= 2u;
                }

                uint wordBase = blockIndex * 16u;
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_aligned(chunkWords32, wordBase + wordIndex);
                }

                compress_in_place(cv, blockWords, 64u, chunkCounter, flags);
            }
        } else {
            for (uint blockIndex = 0u; blockIndex < 16u; blockIndex++) {
                uint blockOffset = blockIndex * 64u;
                uint flags = 0u;
                if (blockIndex == 0u) {
                    flags |= 1u;
                }
                if (blockIndex == 15u) {
                    flags |= 2u;
                }

                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_exact(chunk, blockOffset + wordIndex * 4u);
                }

                compress_in_place(cv, blockWords, 64u, chunkCounter, flags);
            }
        }

        device uint *out = reinterpret_cast<device uint *>(chunkCVs + ulong(gid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_parent_cvs(device const uchar *inputCVs [[buffer(0)]],
                                  device uchar *parentCVs [[buffer(1)]],
                                  constant BLAKE3ParentParams &params [[buffer(2)]],
                                  uint gid [[thread_position_in_grid]]) {
        uint parentCount = params.inputCount / 2u;
        bool hasOdd = (params.inputCount & 1u) != 0u;

        if (gid < parentCount) {
            device const uint *block = reinterpret_cast<device const uint *>(inputCVs + ulong(gid) * 64UL);
            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_aligned(block, wordIndex);
            }

            uint cv[8] = {
                IV[0], IV[1], IV[2], IV[3],
                IV[4], IV[5], IV[6], IV[7]
            };
            compress_in_place(cv, blockWords, 64u, 0UL, 4u);

            device uint *out = reinterpret_cast<device uint *>(parentCVs + ulong(gid) * 32UL);
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                store32_aligned(out, wordIndex, cv[wordIndex]);
            }
            return;
        }

        if (hasOdd && gid == parentCount) {
            device const uint *last = reinterpret_cast<device const uint *>(inputCVs + ulong(params.inputCount - 1u) * 32UL);
            device uint *out = reinterpret_cast<device uint *>(parentCVs + ulong(parentCount) * 32UL);
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                store32_aligned(out, wordIndex, load32_aligned(last, wordIndex));
            }
        }
    }

    kernel void blake3_parent4_cvs(device const uchar *inputCVs [[buffer(0)]],
                                   device uchar *parentCVs [[buffer(1)]],
                                   constant BLAKE3ParentParams &params [[buffer(2)]],
                                   uint gid [[thread_position_in_grid]]) {
        uint fullGroupCount = params.inputCount / 4u;
        uint remainder = params.inputCount & 3u;
        uint outputCount = fullGroupCount + (remainder == 0u ? 0u : 1u);
        if (gid >= outputCount) {
            return;
        }

        if (gid < fullGroupCount) {
            device const uint *inputWords = reinterpret_cast<device const uint *>(inputCVs + ulong(gid) * 128UL);
            uint cvs[2][8];

            for (uint pairIndex = 0u; pairIndex < 2u; pairIndex++) {
                uint blockWords[16];
                uint wordBase = pairIndex * 16u;
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_aligned(inputWords, wordBase + wordIndex);
                }
                parent_cv(cvs[pairIndex], blockWords);
            }

            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = cvs[0][wordIndex];
                blockWords[wordIndex + 8u] = cvs[1][wordIndex];
            }
            parent_cv(cvs[0], blockWords);

            device uint *out = reinterpret_cast<device uint *>(parentCVs + ulong(gid) * 32UL);
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                store32_aligned(out, wordIndex, cvs[0][wordIndex]);
            }
            return;
        }

        device const uint *tailWords = reinterpret_cast<device const uint *>(inputCVs + ulong(fullGroupCount) * 128UL);
        device uint *out = reinterpret_cast<device uint *>(parentCVs + ulong(fullGroupCount) * 32UL);

        if (remainder == 1u) {
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                store32_aligned(out, wordIndex, load32_aligned(tailWords, wordIndex));
            }
            return;
        }

        uint blockWords[16];
        for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
            blockWords[wordIndex] = load32_aligned(tailWords, wordIndex);
        }
        uint cv[8];
        parent_cv(cv, blockWords);

        if (remainder == 3u) {
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = cv[wordIndex];
                blockWords[wordIndex + 8u] = load32_aligned(tailWords, 16u + wordIndex);
            }
            parent_cv(cv, blockWords);
        }

        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_parent16_cvs(device const uchar *inputCVs [[buffer(0)]],
                                    device uchar *parentCVs [[buffer(1)]],
                                    constant BLAKE3ParentParams &params [[buffer(2)]],
                                    uint gid [[thread_position_in_grid]]) {
        uint outputCount = params.inputCount / 16u;
        if (gid >= outputCount) {
            return;
        }

        device const uint *inputWords = reinterpret_cast<device const uint *>(inputCVs + ulong(gid) * 512UL);
        uint cvs[8][8];

        for (uint pairIndex = 0u; pairIndex < 8u; pairIndex++) {
            uint blockWords[16];
            uint wordBase = pairIndex * 16u;
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_aligned(inputWords, wordBase + wordIndex);
            }
            parent_cv(cvs[pairIndex], blockWords);
        }

        for (uint parentIndex = 0u; parentIndex < 4u; parentIndex++) {
            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = cvs[parentIndex * 2u][wordIndex];
                blockWords[wordIndex + 8u] = cvs[parentIndex * 2u + 1u][wordIndex];
            }
            parent_cv(cvs[parentIndex], blockWords);
        }

        for (uint parentIndex = 0u; parentIndex < 2u; parentIndex++) {
            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = cvs[parentIndex * 2u][wordIndex];
                blockWords[wordIndex + 8u] = cvs[parentIndex * 2u + 1u][wordIndex];
            }
            parent_cv(cvs[parentIndex], blockWords);
        }

        uint blockWords[16];
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            blockWords[wordIndex] = cvs[0][wordIndex];
            blockWords[wordIndex + 8u] = cvs[1][wordIndex];
        }
        parent_cv(cvs[0], blockWords);

        device uint *out = reinterpret_cast<device uint *>(parentCVs + ulong(gid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, cvs[0][wordIndex]);
        }
    }

    kernel void blake3_parent16_tail_cvs(device const uchar *inputCVs [[buffer(0)]],
                                         device uchar *parentCVs [[buffer(1)]],
                                         constant BLAKE3ParentParams &params [[buffer(2)]],
                                         uint gid [[thread_position_in_grid]]) {
        uint fullGroupCount = params.inputCount / 16u;
        uint remainder = params.inputCount & 15u;
        uint outputCount = fullGroupCount + (remainder == 0u ? 0u : 1u);
        if (gid >= outputCount) {
            return;
        }

        if (gid < fullGroupCount) {
            device const uint *inputWords = reinterpret_cast<device const uint *>(inputCVs + ulong(gid) * 512UL);
            uint cvs[8][8];

            for (uint pairIndex = 0u; pairIndex < 8u; pairIndex++) {
                uint blockWords[16];
                uint wordBase = pairIndex * 16u;
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_aligned(inputWords, wordBase + wordIndex);
                }
                parent_cv(cvs[pairIndex], blockWords);
            }

            for (uint parentIndex = 0u; parentIndex < 4u; parentIndex++) {
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex] = cvs[parentIndex * 2u][wordIndex];
                    blockWords[wordIndex + 8u] = cvs[parentIndex * 2u + 1u][wordIndex];
                }
                parent_cv(cvs[parentIndex], blockWords);
            }

            for (uint parentIndex = 0u; parentIndex < 2u; parentIndex++) {
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex] = cvs[parentIndex * 2u][wordIndex];
                    blockWords[wordIndex + 8u] = cvs[parentIndex * 2u + 1u][wordIndex];
                }
                parent_cv(cvs[parentIndex], blockWords);
            }

            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = cvs[0][wordIndex];
                blockWords[wordIndex + 8u] = cvs[1][wordIndex];
            }
            parent_cv(cvs[0], blockWords);

            device uint *out = reinterpret_cast<device uint *>(parentCVs + ulong(gid) * 32UL);
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                store32_aligned(out, wordIndex, cvs[0][wordIndex]);
            }
            return;
        }

        device const uint *tailWords = reinterpret_cast<device const uint *>(inputCVs + ulong(fullGroupCount) * 512UL);
        uint tailCVs[15][8];
        for (uint cvIndex = 0u; cvIndex < remainder; cvIndex++) {
            uint wordBase = cvIndex * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                tailCVs[cvIndex][wordIndex] = load32_aligned(tailWords, wordBase + wordIndex);
            }
        }
        reduce_tail_cvs(tailCVs, remainder);

        device uint *out = reinterpret_cast<device uint *>(parentCVs + ulong(fullGroupCount) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, tailCVs[0][wordIndex]);
        }
    }

    kernel void blake3_root_digest(device const uchar *rootCVs [[buffer(0)]],
                                   device uchar *digest [[buffer(1)]],
                                   uint gid [[thread_position_in_grid]]) {
        if (gid != 0u) {
            return;
        }

        device const uint *rootWords = reinterpret_cast<device const uint *>(rootCVs);
        uint blockWords[16];
        for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
            blockWords[wordIndex] = load32_aligned(rootWords, wordIndex);
        }

        uint cv[8] = {
            IV[0], IV[1], IV[2], IV[3],
            IV[4], IV[5], IV[6], IV[7]
        };
        compress_in_place(cv, blockWords, 64u, 0UL, 12u);

        device uint *digestWords = reinterpret_cast<device uint *>(digest);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(digestWords, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_root3_digest(device const uchar *rootCVs [[buffer(0)]],
                                    device uchar *digest [[buffer(1)]],
                                    uint gid [[thread_position_in_grid]]) {
        if (gid != 0u) {
            return;
        }

        device const uint *inputWords = reinterpret_cast<device const uint *>(rootCVs);
        uint leftCV[8];
        uint blockWords[16];

        for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
            blockWords[wordIndex] = load32_aligned(inputWords, wordIndex);
        }
        parent_cv(leftCV, blockWords);

        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            blockWords[wordIndex] = leftCV[wordIndex];
            blockWords[wordIndex + 8u] = load32_aligned(inputWords, 16u + wordIndex);
        }

        uint cv[8] = {
            IV[0], IV[1], IV[2], IV[3],
            IV[4], IV[5], IV[6], IV[7]
        };
        compress_in_place(cv, blockWords, 64u, 0UL, 12u);

        device uint *digestWords = reinterpret_cast<device uint *>(digest);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(digestWords, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_root4_digest(device const uchar *rootCVs [[buffer(0)]],
                                    device uchar *digest [[buffer(1)]],
                                    uint gid [[thread_position_in_grid]]) {
        if (gid != 0u) {
            return;
        }

        device const uint *inputWords = reinterpret_cast<device const uint *>(rootCVs);
        uint cvs[2][8];

        for (uint pairIndex = 0u; pairIndex < 2u; pairIndex++) {
            uint blockWords[16];
            uint wordBase = pairIndex * 16u;
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_aligned(inputWords, wordBase + wordIndex);
            }
            parent_cv(cvs[pairIndex], blockWords);
        }

        uint blockWords[16];
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            blockWords[wordIndex] = cvs[0][wordIndex];
            blockWords[wordIndex + 8u] = cvs[1][wordIndex];
        }

        uint cv[8] = {
            IV[0], IV[1], IV[2], IV[3],
            IV[4], IV[5], IV[6], IV[7]
        };
        compress_in_place(cv, blockWords, 64u, 0UL, 12u);

        device uint *digestWords = reinterpret_cast<device uint *>(digest);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(digestWords, wordIndex, cv[wordIndex]);
        }
    }

    """
}
#endif
