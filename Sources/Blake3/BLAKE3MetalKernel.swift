#if canImport(Metal)
import Foundation
import Metal

struct BLAKE3MetalKeyWords {
    var word0: UInt32 = 0x6A09_E667
    var word1: UInt32 = 0xBB67_AE85
    var word2: UInt32 = 0x3C6E_F372
    var word3: UInt32 = 0xA54F_F53A
    var word4: UInt32 = 0x510E_527F
    var word5: UInt32 = 0x9B05_688C
    var word6: UInt32 = 0x1F83_D9AB
    var word7: UInt32 = 0x5BE0_CD19

    init() {}

    init(_ words: BLAKE3Core.ChainingValue) {
        self.word0 = words[0]
        self.word1 = words[1]
        self.word2 = words[2]
        self.word3 = words[3]
        self.word4 = words[4]
        self.word5 = words[5]
        self.word6 = words[6]
        self.word7 = words[7]
    }
}

struct BLAKE3MetalChunkParams {
    var inputOffset: UInt64
    var inputLength: UInt64
    var baseChunkCounter: UInt64
    var chunkCount: UInt32
    var canLoadWords: UInt32
    var key: BLAKE3MetalKeyWords = BLAKE3MetalKeyWords()
    var flags: UInt32 = 0
    var padding0: UInt32 = 0
    var padding1: UInt32 = 0
    var padding2: UInt32 = 0
}

struct BLAKE3MetalDigestChunkParams {
    var inputOffset: UInt64
    var inputLength: UInt64
    var baseChunkCounter: UInt64
    var chunkCount: UInt32
    var canLoadWords: UInt32
    var padding0: UInt32 = 0
    var padding1: UInt32 = 0
}

struct BLAKE3MetalParentParams {
    var inputCount: UInt32
    var key: BLAKE3MetalKeyWords = BLAKE3MetalKeyWords()
    var flags: UInt32 = 0
    var padding0: UInt32 = 0
    var padding1: UInt32 = 0
    var padding2: UInt32 = 0
}

struct BLAKE3MetalDigestParentParams {
    var inputCount: UInt32
    var padding0: UInt32 = 0
    var padding1: UInt32 = 0
    var padding2: UInt32 = 0
}

struct BLAKE3MetalXOFParams {
    var outputByteCount: UInt64
    var seek: UInt64
    var key: BLAKE3MetalKeyWords = BLAKE3MetalKeyWords()
    var flags: UInt32 = 0
    var padding0: UInt32 = 0
    var padding1: UInt32 = 0
    var padding2: UInt32 = 0
}

struct BLAKE3MetalBatchEntry {
    var inputOffset: UInt64
    var inputLength: UInt32
    var padding0: UInt32 = 0
}

struct BLAKE3MetalBatchParams {
    var entryCount: UInt32
    var canLoadWords: UInt32
    var key: BLAKE3MetalKeyWords = BLAKE3MetalKeyWords()
    var flags: UInt32 = 0
    var padding0: UInt32 = 0
    var padding1: UInt32 = 0
}

struct BLAKE3MetalDigestPipelines {
    let chunkCVs: MTLComputePipelineState
    let chunkFullCVs: MTLComputePipelineState
    let chunkFullAlignedCVs: MTLComputePipelineState
    let chunkTile128CVs: MTLComputePipelineState
    let chunkTile256CVs: MTLComputePipelineState
    let chunkTile512CVs: MTLComputePipelineState
    let chunkTile1024CVs: MTLComputePipelineState
    let chunkTile128SIMDGroupCVs: MTLComputePipelineState
    let chunkTile128PingPongCVs: MTLComputePipelineState
    let chunkTile256PingPongCVs: MTLComputePipelineState
    let chunkTile512PingPongCVs: MTLComputePipelineState
    let chunkTile1024PingPongCVs: MTLComputePipelineState
    let parentCVs: MTLComputePipelineState
    let parent4ExactCVs: MTLComputePipelineState
    let parent4CVs: MTLComputePipelineState
    let parent16CVs: MTLComputePipelineState
    let parent16TailCVs: MTLComputePipelineState
    let rootDigest: MTLComputePipelineState
    let root3Digest: MTLComputePipelineState
    let root4Digest: MTLComputePipelineState
}

struct BLAKE3MetalPipelines {
    let digest: BLAKE3MetalDigestPipelines
    let chunkCVs: MTLComputePipelineState
    let chunkFullCVs: MTLComputePipelineState
    let chunkFullAlignedCVs: MTLComputePipelineState
    let chunkTile128CVs: MTLComputePipelineState
    let chunkTile256CVs: MTLComputePipelineState
    let chunkTile512CVs: MTLComputePipelineState
    let chunkTile1024CVs: MTLComputePipelineState
    let chunkTile128SIMDGroupCVs: MTLComputePipelineState
    let chunkTile128PingPongCVs: MTLComputePipelineState
    let chunkTile256PingPongCVs: MTLComputePipelineState
    let chunkTile512PingPongCVs: MTLComputePipelineState
    let chunkTile1024PingPongCVs: MTLComputePipelineState
    let parentCVs: MTLComputePipelineState
    let parent4ExactCVs: MTLComputePipelineState
    let parent4CVs: MTLComputePipelineState
    let parent16CVs: MTLComputePipelineState
    let parent16TailCVs: MTLComputePipelineState
    let rootDigest: MTLComputePipelineState
    let root3Digest: MTLComputePipelineState
    let root4Digest: MTLComputePipelineState
    let rootXOF: MTLComputePipelineState
    let batchOneChunkDigest: MTLComputePipelineState
    let batchOneContiguousBlockDigest: MTLComputePipelineState
    let batchOneBlockDigest: MTLComputePipelineState
    let batchOneFullChunkDigest: MTLComputePipelineState
    let batchOneChunkOutputChunkCVs: MTLComputePipelineState
    let batchOneContiguousBlockOutputChunkCVs: MTLComputePipelineState
    let batchOneBlockOutputChunkCVs: MTLComputePipelineState
    let batchOneFullChunkOutputChunkCVs: MTLComputePipelineState
}

final class BLAKE3MetalPipelineCache: @unchecked Sendable {
    static let shared = BLAKE3MetalPipelineCache()

    private struct CacheKey: Hashable {
        let deviceRegistryID: UInt64
        let libraryIdentifier: String
    }

    private let lock = NSLock()
    private var pipelines: [CacheKey: BLAKE3MetalPipelines] = [:]

    private init() {}

    func pipelines(
        device: MTLDevice,
        librarySource: BLAKE3Metal.LibrarySource = .runtimeSource
    ) throws -> BLAKE3MetalPipelines {
        let key = CacheKey(
            deviceRegistryID: device.registryID,
            libraryIdentifier: librarySource.cacheIdentifier
        )
        lock.lock()
        if let pipelines = pipelines[key] {
            lock.unlock()
            return pipelines
        }
        lock.unlock()

        let library = try librarySource.makeLibrary(device: device)
        let digestLibrary = try librarySource.makeDigestLibrary(device: device)
        guard let chunkFunction = library.makeFunction(name: "blake3_chunk_cvs"),
              let chunkFullFunction = library.makeFunction(name: "blake3_chunk_full_cvs"),
              let chunkFullAlignedFunction = library.makeFunction(name: "blake3_chunk_full_aligned_cvs"),
              let chunkTile128Function = library.makeFunction(name: "blake3_chunk_tile128_cvs"),
              let chunkTile256Function = library.makeFunction(name: "blake3_chunk_tile256_cvs"),
              let chunkTile512Function = library.makeFunction(name: "blake3_chunk_tile512_cvs"),
              let chunkTile1024Function = library.makeFunction(name: "blake3_chunk_tile1024_cvs"),
              let chunkTile128SIMDGroupFunction = library.makeFunction(name: "blake3_chunk_tile128_simdgroup_cvs"),
              let chunkTile128PingPongFunction = library.makeFunction(name: "blake3_chunk_tile128_pingpong_cvs"),
              let chunkTile256PingPongFunction = library.makeFunction(name: "blake3_chunk_tile256_pingpong_cvs"),
              let chunkTile512PingPongFunction = library.makeFunction(name: "blake3_chunk_tile512_pingpong_cvs"),
              let chunkTile1024PingPongFunction = library.makeFunction(name: "blake3_chunk_tile1024_pingpong_cvs"),
              let parentFunction = library.makeFunction(name: "blake3_parent_cvs"),
              let parent4ExactFunction = library.makeFunction(name: "blake3_parent4_exact_cvs"),
              let parent4Function = library.makeFunction(name: "blake3_parent4_cvs"),
              let parent16Function = library.makeFunction(name: "blake3_parent16_cvs"),
              let parent16TailFunction = library.makeFunction(name: "blake3_parent16_tail_cvs"),
              let rootFunction = library.makeFunction(name: "blake3_root_digest"),
              let root3Function = library.makeFunction(name: "blake3_root3_digest"),
              let root4Function = library.makeFunction(name: "blake3_root4_digest"),
              let rootXOFFunction = library.makeFunction(name: "blake3_root_xof"),
              let batchOneChunkDigestFunction = library.makeFunction(name: "blake3_batch_one_chunk_digest"),
              let batchOneContiguousBlockDigestFunction = library.makeFunction(
                name: "blake3_batch_contiguous_block_digest"
              ),
              let batchOneBlockDigestFunction = library.makeFunction(name: "blake3_batch_one_block_digest"),
              let batchOneFullChunkDigestFunction = library.makeFunction(name: "blake3_batch_one_full_chunk_digest"),
              let batchOneChunkOutputChunkCVsFunction = library.makeFunction(
                name: "blake3_batch_one_chunk_output_chunk_cvs"
              ),
              let batchOneContiguousBlockOutputChunkCVsFunction = library.makeFunction(
                name: "blake3_batch_contiguous_block_output_chunk_cvs"
              ),
              let batchOneBlockOutputChunkCVsFunction = library.makeFunction(
                name: "blake3_batch_one_block_output_chunk_cvs"
              ),
              let batchOneFullChunkOutputChunkCVsFunction = library.makeFunction(
                name: "blake3_batch_one_full_chunk_output_chunk_cvs"
              )
        else {
            throw BLAKE3Error.metalCommandFailed("Unable to load BLAKE3 Metal kernels.")
        }
        guard let digestChunkFunction = digestLibrary.makeFunction(name: "blake3_chunk_cvs"),
              let digestChunkFullFunction = digestLibrary.makeFunction(name: "blake3_chunk_full_cvs"),
              let digestChunkFullAlignedFunction = digestLibrary.makeFunction(name: "blake3_chunk_full_aligned_cvs"),
              let digestChunkTile128Function = digestLibrary.makeFunction(name: "blake3_chunk_tile128_cvs"),
              let digestChunkTile256Function = digestLibrary.makeFunction(name: "blake3_chunk_tile256_cvs"),
              let digestChunkTile512Function = digestLibrary.makeFunction(name: "blake3_chunk_tile512_cvs"),
              let digestChunkTile1024Function = digestLibrary.makeFunction(name: "blake3_chunk_tile1024_cvs"),
              let digestChunkTile128SIMDGroupFunction = digestLibrary.makeFunction(
                name: "blake3_chunk_tile128_simdgroup_cvs"
              ),
              let digestChunkTile128PingPongFunction = digestLibrary.makeFunction(
                name: "blake3_chunk_tile128_pingpong_cvs"
              ),
              let digestChunkTile256PingPongFunction = digestLibrary.makeFunction(
                name: "blake3_chunk_tile256_pingpong_cvs"
              ),
              let digestChunkTile512PingPongFunction = digestLibrary.makeFunction(
                name: "blake3_chunk_tile512_pingpong_cvs"
              ),
              let digestChunkTile1024PingPongFunction = digestLibrary.makeFunction(
                name: "blake3_chunk_tile1024_pingpong_cvs"
              ),
              let digestParentFunction = digestLibrary.makeFunction(name: "blake3_parent_cvs"),
              let digestParent4ExactFunction = digestLibrary.makeFunction(name: "blake3_parent4_exact_cvs"),
              let digestParent4Function = digestLibrary.makeFunction(name: "blake3_parent4_cvs"),
              let digestParent16Function = digestLibrary.makeFunction(name: "blake3_parent16_cvs"),
              let digestParent16TailFunction = digestLibrary.makeFunction(name: "blake3_parent16_tail_cvs"),
              let digestRootFunction = digestLibrary.makeFunction(name: "blake3_root_digest"),
              let digestRoot3Function = digestLibrary.makeFunction(name: "blake3_root3_digest"),
              let digestRoot4Function = digestLibrary.makeFunction(name: "blake3_root4_digest")
        else {
            throw BLAKE3Error.metalCommandFailed("Unable to load BLAKE3 digest-only Metal kernels.")
        }
        let digestPipelines = BLAKE3MetalDigestPipelines(
            chunkCVs: try device.makeComputePipelineState(function: digestChunkFunction),
            chunkFullCVs: try device.makeComputePipelineState(function: digestChunkFullFunction),
            chunkFullAlignedCVs: try device.makeComputePipelineState(function: digestChunkFullAlignedFunction),
            chunkTile128CVs: try device.makeComputePipelineState(function: digestChunkTile128Function),
            chunkTile256CVs: try device.makeComputePipelineState(function: digestChunkTile256Function),
            chunkTile512CVs: try device.makeComputePipelineState(function: digestChunkTile512Function),
            chunkTile1024CVs: try device.makeComputePipelineState(function: digestChunkTile1024Function),
            chunkTile128SIMDGroupCVs: try device.makeComputePipelineState(
                function: digestChunkTile128SIMDGroupFunction
            ),
            chunkTile128PingPongCVs: try device.makeComputePipelineState(function: digestChunkTile128PingPongFunction),
            chunkTile256PingPongCVs: try device.makeComputePipelineState(function: digestChunkTile256PingPongFunction),
            chunkTile512PingPongCVs: try device.makeComputePipelineState(function: digestChunkTile512PingPongFunction),
            chunkTile1024PingPongCVs: try device.makeComputePipelineState(
                function: digestChunkTile1024PingPongFunction
            ),
            parentCVs: try device.makeComputePipelineState(function: digestParentFunction),
            parent4ExactCVs: try device.makeComputePipelineState(function: digestParent4ExactFunction),
            parent4CVs: try device.makeComputePipelineState(function: digestParent4Function),
            parent16CVs: try device.makeComputePipelineState(function: digestParent16Function),
            parent16TailCVs: try device.makeComputePipelineState(function: digestParent16TailFunction),
            rootDigest: try device.makeComputePipelineState(function: digestRootFunction),
            root3Digest: try device.makeComputePipelineState(function: digestRoot3Function),
            root4Digest: try device.makeComputePipelineState(function: digestRoot4Function)
        )
        let pipelines = BLAKE3MetalPipelines(
            digest: digestPipelines,
            chunkCVs: try device.makeComputePipelineState(function: chunkFunction),
            chunkFullCVs: try device.makeComputePipelineState(function: chunkFullFunction),
            chunkFullAlignedCVs: try device.makeComputePipelineState(function: chunkFullAlignedFunction),
            chunkTile128CVs: try device.makeComputePipelineState(function: chunkTile128Function),
            chunkTile256CVs: try device.makeComputePipelineState(function: chunkTile256Function),
            chunkTile512CVs: try device.makeComputePipelineState(function: chunkTile512Function),
            chunkTile1024CVs: try device.makeComputePipelineState(function: chunkTile1024Function),
            chunkTile128SIMDGroupCVs: try device.makeComputePipelineState(function: chunkTile128SIMDGroupFunction),
            chunkTile128PingPongCVs: try device.makeComputePipelineState(function: chunkTile128PingPongFunction),
            chunkTile256PingPongCVs: try device.makeComputePipelineState(function: chunkTile256PingPongFunction),
            chunkTile512PingPongCVs: try device.makeComputePipelineState(function: chunkTile512PingPongFunction),
            chunkTile1024PingPongCVs: try device.makeComputePipelineState(function: chunkTile1024PingPongFunction),
            parentCVs: try device.makeComputePipelineState(function: parentFunction),
            parent4ExactCVs: try device.makeComputePipelineState(function: parent4ExactFunction),
            parent4CVs: try device.makeComputePipelineState(function: parent4Function),
            parent16CVs: try device.makeComputePipelineState(function: parent16Function),
            parent16TailCVs: try device.makeComputePipelineState(function: parent16TailFunction),
            rootDigest: try device.makeComputePipelineState(function: rootFunction),
            root3Digest: try device.makeComputePipelineState(function: root3Function),
            root4Digest: try device.makeComputePipelineState(function: root4Function),
            rootXOF: try device.makeComputePipelineState(function: rootXOFFunction),
            batchOneChunkDigest: try device.makeComputePipelineState(function: batchOneChunkDigestFunction),
            batchOneContiguousBlockDigest: try device.makeComputePipelineState(
                function: batchOneContiguousBlockDigestFunction
            ),
            batchOneBlockDigest: try device.makeComputePipelineState(function: batchOneBlockDigestFunction),
            batchOneFullChunkDigest: try device.makeComputePipelineState(function: batchOneFullChunkDigestFunction),
            batchOneChunkOutputChunkCVs: try device.makeComputePipelineState(
                function: batchOneChunkOutputChunkCVsFunction
            ),
            batchOneContiguousBlockOutputChunkCVs: try device.makeComputePipelineState(
                function: batchOneContiguousBlockOutputChunkCVsFunction
            ),
            batchOneBlockOutputChunkCVs: try device.makeComputePipelineState(
                function: batchOneBlockOutputChunkCVsFunction
            ),
            batchOneFullChunkOutputChunkCVs: try device.makeComputePipelineState(
                function: batchOneFullChunkOutputChunkCVsFunction
            )
        )

        lock.lock()
        self.pipelines[key] = pipelines
        lock.unlock()

        return pipelines
    }
}

private extension BLAKE3Metal.LibrarySource {
    var cacheIdentifier: String {
        switch self {
        case .runtimeSource:
            return "runtime-source"
        case let .metallib(url):
            return "metallib:\(url.standardizedFileURL.path)"
        }
    }

    func makeLibrary(device: MTLDevice) throws -> MTLLibrary {
        switch self {
        case .runtimeSource:
            return try device.makeLibrary(source: BLAKE3MetalKernelSource.chunkCVs, options: nil)
        case let .metallib(url):
            return try device.makeLibrary(URL: url)
        }
    }

    func makeDigestLibrary(device: MTLDevice) throws -> MTLLibrary {
        try device.makeLibrary(source: BLAKE3MetalKernelSource.digestOnlyHash, options: nil)
    }
}

enum BLAKE3MetalKernelSource {
    static let chunkCVs = """
    #include <metal_stdlib>
    using namespace metal;

    struct BLAKE3KeyWords {
        uint word0;
        uint word1;
        uint word2;
        uint word3;
        uint word4;
        uint word5;
        uint word6;
        uint word7;
    };

    struct BLAKE3ChunkParams {
        ulong inputOffset;
        ulong inputLength;
        ulong baseChunkCounter;
        uint chunkCount;
        uint canLoadWords;
        BLAKE3KeyWords key;
        uint flags;
        uint padding0;
        uint padding1;
        uint padding2;
    };

    struct BLAKE3ParentParams {
        uint inputCount;
        BLAKE3KeyWords key;
        uint flags;
        uint padding0;
        uint padding1;
        uint padding2;
    };

    struct BLAKE3XOFParams {
        ulong outputByteCount;
        ulong seek;
        BLAKE3KeyWords key;
        uint flags;
        uint padding0;
        uint padding1;
        uint padding2;
    };

    struct BLAKE3BatchEntry {
        ulong inputOffset;
        uint inputLength;
        uint padding0;
    };

    struct BLAKE3BatchParams {
        uint entryCount;
        uint canLoadWords;
        BLAKE3KeyWords key;
        uint flags;
        uint padding0;
        uint padding1;
    };

    constant uint IV[8] = {
        0x6A09E667u, 0xBB67AE85u, 0x3C6EF372u, 0xA54FF53Au,
        0x510E527Fu, 0x9B05688Cu, 0x1F83D9ABu, 0x5BE0CD19u
    };

    static inline void load_key(thread uint key[8], constant BLAKE3KeyWords &words) {
        key[0] = words.word0;
        key[1] = words.word1;
        key[2] = words.word2;
        key[3] = words.word3;
        key[4] = words.word4;
        key[5] = words.word5;
        key[6] = words.word6;
        key[7] = words.word7;
    }

    static inline void init_cv(thread uint cv[8], thread const uint key[8]) {
        cv[0] = key[0];
        cv[1] = key[1];
        cv[2] = key[2];
        cv[3] = key[3];
        cv[4] = key[4];
        cv[5] = key[5];
        cv[6] = key[6];
        cv[7] = key[7];
    }

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

    static inline void compress_xof(thread const uint cv[8],
                                    thread const uint blockWords[16],
                                    uint blockLength,
                                    ulong counter,
                                    uint flags,
                                    thread uint outWords[16]) {
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

        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            outWords[wordIndex] = state[wordIndex] ^ state[wordIndex + 8u];
            outWords[wordIndex + 8u] = state[wordIndex + 8u] ^ cv[wordIndex];
        }
    }

    static inline uchar xof_byte(thread const uint words[16], uint byteOffset) {
        uint word = words[byteOffset >> 2u];
        uint shift = (byteOffset & 3u) << 3u;
        return uchar((word >> shift) & 0xffu);
    }

    static inline void parent_cv(thread uint outCV[8],
                                 thread const uint blockWords[16],
                                 thread const uint key[8],
                                 uint flags) {
        uint cv[8];
        init_cv(cv, key);
        compress_in_place(cv, blockWords, 64u, 0UL, flags | 4u);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            outCV[wordIndex] = cv[wordIndex];
        }
    }

    static inline void reduce_tail_cvs(thread uint cvs[15][8],
                                       uint count,
                                       thread const uint key[8],
                                       uint flags) {
        while (count > 1u) {
            uint parentCount = count / 2u;
            for (uint parentIndex = 0u; parentIndex < parentCount; parentIndex++) {
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex] = cvs[parentIndex * 2u][wordIndex];
                    blockWords[wordIndex + 8u] = cvs[parentIndex * 2u + 1u][wordIndex];
                }
                parent_cv(cvs[parentIndex], blockWords, key, flags);
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

    static inline void chunk_full_aligned_cv(device const uchar *chunk,
                                             ulong chunkCounter,
                                             thread const uint key[8],
                                             uint flags,
                                             thread uint cv[8]) {
        device const uint *chunkWords32 = reinterpret_cast<device const uint *>(chunk);

        init_cv(cv, key);

        uint blockWords[16];
        for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
            blockWords[wordIndex] = load32_aligned(chunkWords32, wordIndex);
        }
        compress_in_place(cv, blockWords, 64u, chunkCounter, flags | 1u);

        for (uint blockIndex = 1u; blockIndex < 15u; blockIndex++) {
            uint wordBase = blockIndex * 16u;
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_aligned(chunkWords32, wordBase + wordIndex);
            }
            compress_in_place(cv, blockWords, 64u, chunkCounter, flags);
        }

        for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
            blockWords[wordIndex] = load32_aligned(chunkWords32, 240u + wordIndex);
        }
        compress_in_place(cv, blockWords, 64u, chunkCounter, flags | 2u);
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
        bool canLoadWords = params.canLoadWords != 0u;

        uint key[8];
        load_key(key, params.key);
        init_cv(cv, key);

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

                compress_in_place(cv, blockWords, 64u, chunkCounter, params.flags | flags);
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

                compress_in_place(cv, blockWords, 64u, chunkCounter, params.flags | flags);
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

                compress_in_place(cv, blockWords, blockLength, chunkCounter, params.flags | flags);
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

    static inline void batch_one_chunk_digest_words(device const uchar *input,
                                                    BLAKE3BatchEntry entry,
                                                    constant BLAKE3BatchParams &params,
                                                    thread uint digestWords[8]) {
        uint chunkLength = entry.inputLength;
        device const uchar *chunk = input + entry.inputOffset;
        device const uint *chunkWords32 = reinterpret_cast<device const uint *>(chunk);
        bool canLoadWords = params.canLoadWords != 0u;

        uint key[8];
        load_key(key, params.key);
        uint cv[8];
        init_cv(cv, key);

        uint blockCount = max(1u, (chunkLength + 63u) >> 6u);
        for (uint blockIndex = 0u; blockIndex + 1u < blockCount; blockIndex++) {
            uint blockOffset = blockIndex << 6u;
            uint blockWords[16];
            if (canLoadWords) {
                uint wordBase = blockOffset >> 2u;
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_aligned(chunkWords32, wordBase + wordIndex);
                }
            } else {
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_chunk(chunk, blockOffset + wordIndex * 4u, chunkLength);
                }
            }

            uint blockFlags = params.flags;
            if (blockIndex == 0u) {
                blockFlags |= 1u;
            }
            compress_in_place(cv, blockWords, 64u, 0UL, blockFlags);
        }

        uint lastBlockIndex = blockCount - 1u;
        uint lastBlockOffset = lastBlockIndex << 6u;
        uint lastBlockLength = chunkLength == 0u ? 0u : chunkLength - lastBlockOffset;
        uint blockWords[16];
        if (canLoadWords && lastBlockLength == 64u) {
            uint wordBase = lastBlockOffset >> 2u;
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_aligned(chunkWords32, wordBase + wordIndex);
            }
        } else {
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_chunk(chunk, lastBlockOffset + wordIndex * 4u, chunkLength);
            }
        }

        uint outputFlags = params.flags | 2u | 8u;
        if (lastBlockIndex == 0u) {
            outputFlags |= 1u;
        }

        uint outputWords[16];
        compress_xof(cv, blockWords, lastBlockLength, 0UL, outputFlags, outputWords);

        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            digestWords[wordIndex] = outputWords[wordIndex];
        }
    }

    kernel void blake3_batch_one_chunk_digest(device const uchar *input [[buffer(0)]],
                                              device const BLAKE3BatchEntry *entries [[buffer(1)]],
                                              device uchar *digests [[buffer(2)]],
                                              constant BLAKE3BatchParams &params [[buffer(3)]],
                                              uint gid [[thread_position_in_grid]]) {
        if (gid >= params.entryCount) {
            return;
        }

        uint outputWords[8];
        batch_one_chunk_digest_words(input, entries[gid], params, outputWords);

        device uint *digestWords = reinterpret_cast<device uint *>(digests + ulong(gid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(digestWords, wordIndex, outputWords[wordIndex]);
        }
    }

    static inline void batch_one_block_digest_words(device const uchar *chunk,
                                                    constant BLAKE3BatchParams &params,
                                                    bool canLoadWords,
                                                    thread uint digestWords[8]) {
        uint key[8];
        load_key(key, params.key);
        uint cv[8];
        init_cv(cv, key);

        uint blockWords[16];
        if (canLoadWords) {
            device const uint *chunkWords32 = reinterpret_cast<device const uint *>(chunk);
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_aligned(chunkWords32, wordIndex);
            }
        } else {
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_exact(chunk, wordIndex * 4u);
            }
        }

        uint outputWords[16];
        compress_xof(cv, blockWords, 64u, 0UL, params.flags | 1u | 2u | 8u, outputWords);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            digestWords[wordIndex] = outputWords[wordIndex];
        }
    }

    kernel void blake3_batch_one_block_digest(device const uchar *input [[buffer(0)]],
                                              device const BLAKE3BatchEntry *entries [[buffer(1)]],
                                              device uchar *digests [[buffer(2)]],
                                              constant BLAKE3BatchParams &params [[buffer(3)]],
                                              uint gid [[thread_position_in_grid]]) {
        if (gid >= params.entryCount) {
            return;
        }

        uint outputWords[8];
        device const uchar *chunk = input + entries[gid].inputOffset;
        batch_one_block_digest_words(chunk, params, params.canLoadWords != 0u, outputWords);

        device uint *digestWords = reinterpret_cast<device uint *>(digests + ulong(gid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(digestWords, wordIndex, outputWords[wordIndex]);
        }
    }

    kernel void blake3_batch_contiguous_block_digest(device const uchar *input [[buffer(0)]],
                                                     device const BLAKE3BatchEntry *entries [[buffer(1)]],
                                                     device uchar *digests [[buffer(2)]],
                                                     constant BLAKE3BatchParams &params [[buffer(3)]],
                                                     uint gid [[thread_position_in_grid]]) {
        if (gid >= params.entryCount) {
            return;
        }

        uint outputWords[8];
        ulong inputOffset = entries[0].inputOffset + ulong(gid) * 64UL;
        batch_one_block_digest_words(input + inputOffset, params, params.canLoadWords != 0u, outputWords);

        device uint *digestWords = reinterpret_cast<device uint *>(digests + ulong(gid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(digestWords, wordIndex, outputWords[wordIndex]);
        }
    }

    static inline void batch_one_full_chunk_digest_words(device const uchar *chunk,
                                                         constant BLAKE3BatchParams &params,
                                                         bool canLoadWords,
                                                         thread uint digestWords[8]) {
        device const uint *chunkWords32 = reinterpret_cast<device const uint *>(chunk);

        uint key[8];
        load_key(key, params.key);
        uint cv[8];
        init_cv(cv, key);

        for (uint blockIndex = 0u; blockIndex < 15u; blockIndex++) {
            uint wordBase = blockIndex * 16u;
            uint blockWords[16];
            if (canLoadWords) {
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_aligned(chunkWords32, wordBase + wordIndex);
                }
            } else {
                uint blockOffset = blockIndex << 6u;
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_exact(chunk, blockOffset + wordIndex * 4u);
                }
            }

            uint blockFlags = params.flags;
            if (blockIndex == 0u) {
                blockFlags |= 1u;
            }
            compress_in_place(cv, blockWords, 64u, 0UL, blockFlags);
        }

        uint finalBlockWords[16];
        if (canLoadWords) {
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                finalBlockWords[wordIndex] = load32_aligned(chunkWords32, 240u + wordIndex);
            }
        } else {
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                finalBlockWords[wordIndex] = load32_exact(chunk, 960u + wordIndex * 4u);
            }
        }

        uint outputWords[16];
        compress_xof(cv, finalBlockWords, 64u, 0UL, params.flags | 2u | 8u, outputWords);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            digestWords[wordIndex] = outputWords[wordIndex];
        }
    }

    kernel void blake3_batch_one_full_chunk_digest(device const uchar *input [[buffer(0)]],
                                                   device const BLAKE3BatchEntry *entries [[buffer(1)]],
                                                   device uchar *digests [[buffer(2)]],
                                                   constant BLAKE3BatchParams &params [[buffer(3)]],
                                                   uint gid [[thread_position_in_grid]]) {
        if (gid >= params.entryCount) {
            return;
        }

        uint outputWords[8];
        device const uchar *chunk = input + entries[gid].inputOffset;
        batch_one_full_chunk_digest_words(chunk, params, params.canLoadWords != 0u, outputWords);

        device uint *digestWords = reinterpret_cast<device uint *>(digests + ulong(gid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(digestWords, wordIndex, outputWords[wordIndex]);
        }
    }

    kernel void blake3_batch_one_chunk_output_chunk_cvs(device const uchar *input [[buffer(0)]],
                                                        device const BLAKE3BatchEntry *entries [[buffer(1)]],
                                                        device uchar *chunkCVs [[buffer(2)]],
                                                        constant BLAKE3BatchParams &params [[buffer(3)]],
                                                        threadgroup uint *digestScratch [[threadgroup(0)]],
                                                        uint tid [[thread_position_in_threadgroup]],
                                                        uint tgid [[threadgroup_position_in_grid]]) {
        uint firstEntry = tgid * 32u;
        uint entryIndex = firstEntry + tid;
        if (tid < 32u && entryIndex < params.entryCount) {
            uint digestWords[8];
            batch_one_chunk_digest_words(input, entries[entryIndex], params, digestWords);
            uint scratchBase = tid * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                digestScratch[scratchBase + wordIndex] = digestWords[wordIndex];
            }
        } else if (tid < 32u) {
            uint scratchBase = tid * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                digestScratch[scratchBase + wordIndex] = 0u;
            }
        }

        threadgroup_barrier(mem_flags::mem_threadgroup);
        if (tid != 0u) {
            return;
        }
        if (firstEntry >= params.entryCount) {
            return;
        }

        uint remaining = params.entryCount - firstEntry;
        uint digestCount = remaining > 32u ? 32u : remaining;
        uint blockCount = (digestCount + 1u) >> 1u;

        uint outputKey[8];
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            outputKey[wordIndex] = IV[wordIndex];
        }
        uint cv[8];
        init_cv(cv, outputKey);

        for (uint blockIndex = 0u; blockIndex < blockCount; blockIndex++) {
            uint blockWords[16];
            uint scratchBase = blockIndex * 16u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = digestScratch[scratchBase + wordIndex];
            }

            bool hasSecondDigest = blockIndex * 2u + 1u < digestCount;
            if (hasSecondDigest) {
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex + 8u] = digestScratch[scratchBase + 8u + wordIndex];
                }
            } else {
                for (uint wordIndex = 8u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = 0u;
                }
            }

            uint flags = 0u;
            if (blockIndex == 0u) {
                flags |= 1u;
            }
            if (blockIndex + 1u == blockCount) {
                flags |= 2u;
            }
            compress_in_place(cv, blockWords, hasSecondDigest ? 64u : 32u, ulong(tgid), flags);
        }

        device uint *out = reinterpret_cast<device uint *>(chunkCVs + ulong(tgid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_batch_one_block_output_chunk_cvs(device const uchar *input [[buffer(0)]],
                                                        device const BLAKE3BatchEntry *entries [[buffer(1)]],
                                                        device uchar *chunkCVs [[buffer(2)]],
                                                        constant BLAKE3BatchParams &params [[buffer(3)]],
                                                        threadgroup uint *digestScratch [[threadgroup(0)]],
                                                        uint tid [[thread_position_in_threadgroup]],
                                                        uint tgid [[threadgroup_position_in_grid]]) {
        uint firstEntry = tgid * 32u;
        uint entryIndex = firstEntry + tid;
        if (tid < 32u && entryIndex < params.entryCount) {
            uint digestWords[8];
            device const uchar *chunk = input + entries[entryIndex].inputOffset;
            batch_one_block_digest_words(chunk, params, params.canLoadWords != 0u, digestWords);
            uint scratchBase = tid * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                digestScratch[scratchBase + wordIndex] = digestWords[wordIndex];
            }
        } else if (tid < 32u) {
            uint scratchBase = tid * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                digestScratch[scratchBase + wordIndex] = 0u;
            }
        }

        threadgroup_barrier(mem_flags::mem_threadgroup);
        if (tid != 0u) {
            return;
        }
        if (firstEntry >= params.entryCount) {
            return;
        }

        uint remaining = params.entryCount - firstEntry;
        uint digestCount = remaining > 32u ? 32u : remaining;
        uint blockCount = (digestCount + 1u) >> 1u;

        uint outputKey[8];
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            outputKey[wordIndex] = IV[wordIndex];
        }
        uint cv[8];
        init_cv(cv, outputKey);

        for (uint blockIndex = 0u; blockIndex < blockCount; blockIndex++) {
            uint blockWords[16];
            uint scratchBase = blockIndex * 16u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = digestScratch[scratchBase + wordIndex];
            }

            bool hasSecondDigest = blockIndex * 2u + 1u < digestCount;
            if (hasSecondDigest) {
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex + 8u] = digestScratch[scratchBase + 8u + wordIndex];
                }
            } else {
                for (uint wordIndex = 8u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = 0u;
                }
            }

            uint flags = 0u;
            if (blockIndex == 0u) {
                flags |= 1u;
            }
            if (blockIndex + 1u == blockCount) {
                flags |= 2u;
            }
            compress_in_place(cv, blockWords, hasSecondDigest ? 64u : 32u, ulong(tgid), flags);
        }

        device uint *out = reinterpret_cast<device uint *>(chunkCVs + ulong(tgid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_batch_contiguous_block_output_chunk_cvs(device const uchar *input [[buffer(0)]],
                                                               device const BLAKE3BatchEntry *entries [[buffer(1)]],
                                                               device uchar *chunkCVs [[buffer(2)]],
                                                               constant BLAKE3BatchParams &params [[buffer(3)]],
                                                               threadgroup uint *digestScratch [[threadgroup(0)]],
                                                               uint tid [[thread_position_in_threadgroup]],
                                                               uint tgid [[threadgroup_position_in_grid]]) {
        uint firstEntry = tgid * 32u;
        uint entryIndex = firstEntry + tid;
        if (tid < 32u && entryIndex < params.entryCount) {
            uint digestWords[8];
            ulong inputOffset = entries[0].inputOffset + ulong(entryIndex) * 64UL;
            batch_one_block_digest_words(input + inputOffset, params, params.canLoadWords != 0u, digestWords);
            uint scratchBase = tid * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                digestScratch[scratchBase + wordIndex] = digestWords[wordIndex];
            }
        } else if (tid < 32u) {
            uint scratchBase = tid * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                digestScratch[scratchBase + wordIndex] = 0u;
            }
        }

        threadgroup_barrier(mem_flags::mem_threadgroup);
        if (tid != 0u) {
            return;
        }
        if (firstEntry >= params.entryCount) {
            return;
        }

        uint remaining = params.entryCount - firstEntry;
        uint digestCount = remaining > 32u ? 32u : remaining;
        uint blockCount = (digestCount + 1u) >> 1u;

        uint outputKey[8];
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            outputKey[wordIndex] = IV[wordIndex];
        }
        uint cv[8];
        init_cv(cv, outputKey);

        for (uint blockIndex = 0u; blockIndex < blockCount; blockIndex++) {
            uint blockWords[16];
            uint scratchBase = blockIndex * 16u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = digestScratch[scratchBase + wordIndex];
            }

            bool hasSecondDigest = blockIndex * 2u + 1u < digestCount;
            if (hasSecondDigest) {
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex + 8u] = digestScratch[scratchBase + 8u + wordIndex];
                }
            } else {
                for (uint wordIndex = 8u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = 0u;
                }
            }

            uint flags = 0u;
            if (blockIndex == 0u) {
                flags |= 1u;
            }
            if (blockIndex + 1u == blockCount) {
                flags |= 2u;
            }
            compress_in_place(cv, blockWords, hasSecondDigest ? 64u : 32u, ulong(tgid), flags);
        }

        device uint *out = reinterpret_cast<device uint *>(chunkCVs + ulong(tgid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_batch_one_full_chunk_output_chunk_cvs(device const uchar *input [[buffer(0)]],
                                                             device const BLAKE3BatchEntry *entries [[buffer(1)]],
                                                             device uchar *chunkCVs [[buffer(2)]],
                                                             constant BLAKE3BatchParams &params [[buffer(3)]],
                                                             threadgroup uint *digestScratch [[threadgroup(0)]],
                                                             uint tid [[thread_position_in_threadgroup]],
                                                             uint tgid [[threadgroup_position_in_grid]]) {
        uint firstEntry = tgid * 32u;
        uint entryIndex = firstEntry + tid;
        if (tid < 32u && entryIndex < params.entryCount) {
            uint digestWords[8];
            device const uchar *chunk = input + entries[entryIndex].inputOffset;
            batch_one_full_chunk_digest_words(chunk, params, params.canLoadWords != 0u, digestWords);
            uint scratchBase = tid * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                digestScratch[scratchBase + wordIndex] = digestWords[wordIndex];
            }
        } else if (tid < 32u) {
            uint scratchBase = tid * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                digestScratch[scratchBase + wordIndex] = 0u;
            }
        }

        threadgroup_barrier(mem_flags::mem_threadgroup);
        if (tid != 0u) {
            return;
        }
        if (firstEntry >= params.entryCount) {
            return;
        }

        uint remaining = params.entryCount - firstEntry;
        uint digestCount = remaining > 32u ? 32u : remaining;
        uint blockCount = (digestCount + 1u) >> 1u;

        uint outputKey[8];
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            outputKey[wordIndex] = IV[wordIndex];
        }
        uint cv[8];
        init_cv(cv, outputKey);

        for (uint blockIndex = 0u; blockIndex < blockCount; blockIndex++) {
            uint blockWords[16];
            uint scratchBase = blockIndex * 16u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = digestScratch[scratchBase + wordIndex];
            }

            bool hasSecondDigest = blockIndex * 2u + 1u < digestCount;
            if (hasSecondDigest) {
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex + 8u] = digestScratch[scratchBase + 8u + wordIndex];
                }
            } else {
                for (uint wordIndex = 8u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = 0u;
                }
            }

            uint flags = 0u;
            if (blockIndex == 0u) {
                flags |= 1u;
            }
            if (blockIndex + 1u == blockCount) {
                flags |= 2u;
            }
            compress_in_place(cv, blockWords, hasSecondDigest ? 64u : 32u, ulong(tgid), flags);
        }

        device uint *out = reinterpret_cast<device uint *>(chunkCVs + ulong(tgid) * 32UL);
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
        bool canLoadWords = params.canLoadWords != 0u;

        uint key[8];
        load_key(key, params.key);
        uint cv[8];
        init_cv(cv, key);

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

                compress_in_place(cv, blockWords, 64u, chunkCounter, params.flags | flags);
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

                compress_in_place(cv, blockWords, 64u, chunkCounter, params.flags | flags);
            }
        }

        device uint *out = reinterpret_cast<device uint *>(chunkCVs + ulong(gid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_chunk_full_aligned_cvs(device const uchar *input [[buffer(0)]],
                                              device uchar *chunkCVs [[buffer(1)]],
                                              constant BLAKE3ChunkParams &params [[buffer(2)]],
                                              uint gid [[thread_position_in_grid]]) {
        device const uchar *chunk = input + params.inputOffset + ulong(gid) * 1024UL;
        ulong chunkCounter = params.baseChunkCounter + ulong(gid);

        uint key[8];
        load_key(key, params.key);
        uint cv[8];
        chunk_full_aligned_cv(chunk, chunkCounter, key, params.flags, cv);

        device uint *out = reinterpret_cast<device uint *>(chunkCVs + ulong(gid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, cv[wordIndex]);
        }
    }

    static inline void tile_reduce_exact(threadgroup uint *tileScratch,
                                         uint tileChunkCount,
                                         uint tid,
                                         thread const uint key[8],
                                         uint flags) {
        for (uint activeCount = tileChunkCount; activeCount > 1u; activeCount >>= 1u) {
            threadgroup_barrier(mem_flags::mem_threadgroup);
            uint parentCount = activeCount >> 1u;
            uint blockWords[16];
            if (tid < parentCount) {
                uint leftWordBase = tid * 16u;
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = tileScratch[leftWordBase + wordIndex];
                }
            }

            threadgroup_barrier(mem_flags::mem_threadgroup);
            if (tid < parentCount) {
                uint outWordBase = tid * 8u;
                uint cv[8];
                parent_cv(cv, blockWords, key, flags);
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    tileScratch[outWordBase + wordIndex] = cv[wordIndex];
                }
            }
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
    }

    static inline void tile_reduce_pingpong_exact(threadgroup uint *tileScratch,
                                                 device uchar *tileCVs,
                                                 uint tileChunkCount,
                                                 uint tid,
                                                 uint tgid,
                                                 thread const uint key[8],
                                                 uint flags) {
        threadgroup uint *src = tileScratch;
        threadgroup uint *dst = tileScratch + tileChunkCount * 8u;

        for (uint activeCount = tileChunkCount; activeCount > 1u; activeCount >>= 1u) {
            threadgroup_barrier(mem_flags::mem_threadgroup);
            uint parentCount = activeCount >> 1u;
            if (tid < parentCount) {
                uint leftWordBase = tid * 16u;
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = src[leftWordBase + wordIndex];
                }

                uint outWordBase = tid * 8u;
                uint cv[8];
                parent_cv(cv, blockWords, key, flags);
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    dst[outWordBase + wordIndex] = cv[wordIndex];
                }
            }
            threadgroup uint *tmp = src;
            src = dst;
            dst = tmp;
        }

        threadgroup_barrier(mem_flags::mem_threadgroup);
        if (tid == 0u) {
            device uint *out = reinterpret_cast<device uint *>(tileCVs + ulong(tgid) * 32UL);
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                store32_aligned(out, wordIndex, src[wordIndex]);
            }
        }
    }

    static inline void chunk_tile_cvs(device const uchar *input,
                                      device uchar *tileCVs,
                                      constant BLAKE3ChunkParams &params,
                                      threadgroup uint *tileScratch,
                                      uint tileChunkCount,
                                      uint tid,
                                      uint gid,
                                      uint tgid) {
        if (gid >= params.chunkCount) {
            return;
        }

        device const uchar *chunk = input + params.inputOffset + ulong(gid) * 1024UL;
        ulong chunkCounter = params.baseChunkCounter + ulong(gid);
        uint key[8];
        load_key(key, params.key);
        uint cv[8];
        chunk_full_aligned_cv(chunk, chunkCounter, key, params.flags, cv);

        uint scratchBase = tid * 8u;
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            tileScratch[scratchBase + wordIndex] = cv[wordIndex];
        }

        tile_reduce_exact(tileScratch, tileChunkCount, tid, key, params.flags);

        if (tid == 0u) {
            device uint *out = reinterpret_cast<device uint *>(tileCVs + ulong(tgid) * 32UL);
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                store32_aligned(out, wordIndex, tileScratch[wordIndex]);
            }
        }
    }

    static inline void chunk_tile_pingpong_cvs(device const uchar *input,
                                               device uchar *tileCVs,
                                               constant BLAKE3ChunkParams &params,
                                               threadgroup uint *tileScratch,
                                               uint tileChunkCount,
                                               uint tid,
                                               uint gid,
                                               uint tgid) {
        if (gid >= params.chunkCount) {
            return;
        }

        device const uchar *chunk = input + params.inputOffset + ulong(gid) * 1024UL;
        ulong chunkCounter = params.baseChunkCounter + ulong(gid);
        uint key[8];
        load_key(key, params.key);
        uint cv[8];
        chunk_full_aligned_cv(chunk, chunkCounter, key, params.flags, cv);

        uint scratchBase = tid * 8u;
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            tileScratch[scratchBase + wordIndex] = cv[wordIndex];
        }

        tile_reduce_pingpong_exact(tileScratch, tileCVs, tileChunkCount, tid, tgid, key, params.flags);
    }

    static inline void reduce_simdgroup32_cv(thread uint cv[8],
                                             uint simdLane,
                                             thread const uint key[8],
                                             uint flags) {
        for (uint offset = 1u; offset < 32u; offset <<= 1u) {
            uint partner[8];
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                partner[wordIndex] = simd_shuffle_down(cv[wordIndex], ushort(offset));
            }

            if ((simdLane & ((offset << 1u) - 1u)) == 0u) {
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex] = cv[wordIndex];
                    blockWords[wordIndex + 8u] = partner[wordIndex];
                }
                parent_cv(cv, blockWords, key, flags);
            }
        }
    }

    static inline void chunk_tile128_simdgroup_cvs(device const uchar *input,
                                                   device uchar *tileCVs,
                                                   constant BLAKE3ChunkParams &params,
                                                   threadgroup uint *tileScratch,
                                                   uint tid,
                                                   uint gid,
                                                   uint tgid,
                                                   uint simdLane,
                                                   uint simdGroup) {
        device const uchar *chunk = input + params.inputOffset + ulong(gid) * 1024UL;
        ulong chunkCounter = params.baseChunkCounter + ulong(gid);
        uint key[8];
        load_key(key, params.key);
        uint cv[8];
        chunk_full_aligned_cv(chunk, chunkCounter, key, params.flags, cv);

        reduce_simdgroup32_cv(cv, simdLane, key, params.flags);

        if (simdLane == 0u) {
            uint scratchBase = simdGroup * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                tileScratch[scratchBase + wordIndex] = cv[wordIndex];
            }
        }

        threadgroup_barrier(mem_flags::mem_threadgroup);
        if (tid < 2u) {
            uint blockWords[16];
            uint wordBase = tid * 16u;
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = tileScratch[wordBase + wordIndex];
            }
            parent_cv(cv, blockWords, key, params.flags);
            uint outWordBase = tid * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                tileScratch[outWordBase + wordIndex] = cv[wordIndex];
            }
        }

        threadgroup_barrier(mem_flags::mem_threadgroup);
        if (tid == 0u) {
            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = tileScratch[wordIndex];
            }
            parent_cv(cv, blockWords, key, params.flags);
            device uint *out = reinterpret_cast<device uint *>(tileCVs + ulong(tgid) * 32UL);
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                store32_aligned(out, wordIndex, cv[wordIndex]);
            }
        }
    }

    kernel void blake3_chunk_tile128_cvs(device const uchar *input [[buffer(0)]],
                                         device uchar *tileCVs [[buffer(1)]],
                                         constant BLAKE3ChunkParams &params [[buffer(2)]],
                                         threadgroup uint *tileScratch [[threadgroup(0)]],
                                         uint tid [[thread_position_in_threadgroup]],
                                         uint gid [[thread_position_in_grid]],
                                         uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_cvs(input, tileCVs, params, tileScratch, 128u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile256_cvs(device const uchar *input [[buffer(0)]],
                                         device uchar *tileCVs [[buffer(1)]],
                                         constant BLAKE3ChunkParams &params [[buffer(2)]],
                                         threadgroup uint *tileScratch [[threadgroup(0)]],
                                         uint tid [[thread_position_in_threadgroup]],
                                         uint gid [[thread_position_in_grid]],
                                         uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_cvs(input, tileCVs, params, tileScratch, 256u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile512_cvs(device const uchar *input [[buffer(0)]],
                                         device uchar *tileCVs [[buffer(1)]],
                                         constant BLAKE3ChunkParams &params [[buffer(2)]],
                                         threadgroup uint *tileScratch [[threadgroup(0)]],
                                         uint tid [[thread_position_in_threadgroup]],
                                         uint gid [[thread_position_in_grid]],
                                         uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_cvs(input, tileCVs, params, tileScratch, 512u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile1024_cvs(device const uchar *input [[buffer(0)]],
                                          device uchar *tileCVs [[buffer(1)]],
                                          constant BLAKE3ChunkParams &params [[buffer(2)]],
                                          threadgroup uint *tileScratch [[threadgroup(0)]],
                                          uint tid [[thread_position_in_threadgroup]],
                                          uint gid [[thread_position_in_grid]],
                                          uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_cvs(input, tileCVs, params, tileScratch, 1024u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile128_simdgroup_cvs(device const uchar *input [[buffer(0)]],
                                                   device uchar *tileCVs [[buffer(1)]],
                                                   constant BLAKE3ChunkParams &params [[buffer(2)]],
                                                   threadgroup uint *tileScratch [[threadgroup(0)]],
                                                   uint tid [[thread_position_in_threadgroup]],
                                                   uint gid [[thread_position_in_grid]],
                                                   uint tgid [[threadgroup_position_in_grid]],
                                                   uint simdLane [[thread_index_in_simdgroup]],
                                                   uint simdGroup [[simdgroup_index_in_threadgroup]]) {
        chunk_tile128_simdgroup_cvs(input, tileCVs, params, tileScratch, tid, gid, tgid, simdLane, simdGroup);
    }

    kernel void blake3_chunk_tile128_pingpong_cvs(device const uchar *input [[buffer(0)]],
                                                  device uchar *tileCVs [[buffer(1)]],
                                                  constant BLAKE3ChunkParams &params [[buffer(2)]],
                                                  threadgroup uint *tileScratch [[threadgroup(0)]],
                                                  uint tid [[thread_position_in_threadgroup]],
                                                  uint gid [[thread_position_in_grid]],
                                                  uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_pingpong_cvs(input, tileCVs, params, tileScratch, 128u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile256_pingpong_cvs(device const uchar *input [[buffer(0)]],
                                                  device uchar *tileCVs [[buffer(1)]],
                                                  constant BLAKE3ChunkParams &params [[buffer(2)]],
                                                  threadgroup uint *tileScratch [[threadgroup(0)]],
                                                  uint tid [[thread_position_in_threadgroup]],
                                                  uint gid [[thread_position_in_grid]],
                                                  uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_pingpong_cvs(input, tileCVs, params, tileScratch, 256u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile512_pingpong_cvs(device const uchar *input [[buffer(0)]],
                                                  device uchar *tileCVs [[buffer(1)]],
                                                  constant BLAKE3ChunkParams &params [[buffer(2)]],
                                                  threadgroup uint *tileScratch [[threadgroup(0)]],
                                                  uint tid [[thread_position_in_threadgroup]],
                                                  uint gid [[thread_position_in_grid]],
                                                  uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_pingpong_cvs(input, tileCVs, params, tileScratch, 512u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile1024_pingpong_cvs(device const uchar *input [[buffer(0)]],
                                                   device uchar *tileCVs [[buffer(1)]],
                                                   constant BLAKE3ChunkParams &params [[buffer(2)]],
                                                   threadgroup uint *tileScratch [[threadgroup(0)]],
                                                   uint tid [[thread_position_in_threadgroup]],
                                                   uint gid [[thread_position_in_grid]],
                                                   uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_pingpong_cvs(input, tileCVs, params, tileScratch, 1024u, tid, gid, tgid);
    }

    kernel void blake3_parent_cvs(device const uchar *inputCVs [[buffer(0)]],
                                  device uchar *parentCVs [[buffer(1)]],
                                  constant BLAKE3ParentParams &params [[buffer(2)]],
                                  uint gid [[thread_position_in_grid]]) {
        uint parentCount = params.inputCount / 2u;
        bool hasOdd = (params.inputCount & 1u) != 0u;
        uint key[8];
        load_key(key, params.key);

        if (gid < parentCount) {
            device const uint *block = reinterpret_cast<device const uint *>(inputCVs + ulong(gid) * 64UL);
            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_aligned(block, wordIndex);
            }

            uint cv[8];
            parent_cv(cv, blockWords, key, params.flags);

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

    kernel void blake3_parent4_exact_cvs(device const uchar *inputCVs [[buffer(0)]],
                                         device uchar *parentCVs [[buffer(1)]],
                                         constant BLAKE3ParentParams &params [[buffer(2)]],
                                         uint gid [[thread_position_in_grid]]) {
        uint outputCount = params.inputCount / 4u;
        if (gid >= outputCount) {
            return;
        }

        device const uint *inputWords = reinterpret_cast<device const uint *>(inputCVs + ulong(gid) * 128UL);
        uint cvs[2][8];
        uint key[8];
        load_key(key, params.key);

        for (uint pairIndex = 0u; pairIndex < 2u; pairIndex++) {
            uint blockWords[16];
            uint wordBase = pairIndex * 16u;
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_aligned(inputWords, wordBase + wordIndex);
            }
            parent_cv(cvs[pairIndex], blockWords, key, params.flags);
        }

        uint blockWords[16];
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            blockWords[wordIndex] = cvs[0][wordIndex];
            blockWords[wordIndex + 8u] = cvs[1][wordIndex];
        }
        parent_cv(cvs[0], blockWords, key, params.flags);

        device uint *out = reinterpret_cast<device uint *>(parentCVs + ulong(gid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, cvs[0][wordIndex]);
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
            uint key[8];
            load_key(key, params.key);

            for (uint pairIndex = 0u; pairIndex < 2u; pairIndex++) {
                uint blockWords[16];
                uint wordBase = pairIndex * 16u;
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_aligned(inputWords, wordBase + wordIndex);
                }
                parent_cv(cvs[pairIndex], blockWords, key, params.flags);
            }

            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = cvs[0][wordIndex];
                blockWords[wordIndex + 8u] = cvs[1][wordIndex];
            }
            parent_cv(cvs[0], blockWords, key, params.flags);

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
        uint key[8];
        load_key(key, params.key);
        uint cv[8];
        parent_cv(cv, blockWords, key, params.flags);

        if (remainder == 3u) {
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = cv[wordIndex];
                blockWords[wordIndex + 8u] = load32_aligned(tailWords, 16u + wordIndex);
            }
            parent_cv(cv, blockWords, key, params.flags);
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
        uint key[8];
        load_key(key, params.key);

        for (uint pairIndex = 0u; pairIndex < 8u; pairIndex++) {
            uint blockWords[16];
            uint wordBase = pairIndex * 16u;
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_aligned(inputWords, wordBase + wordIndex);
            }
            parent_cv(cvs[pairIndex], blockWords, key, params.flags);
        }

        for (uint parentIndex = 0u; parentIndex < 4u; parentIndex++) {
            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = cvs[parentIndex * 2u][wordIndex];
                blockWords[wordIndex + 8u] = cvs[parentIndex * 2u + 1u][wordIndex];
            }
            parent_cv(cvs[parentIndex], blockWords, key, params.flags);
        }

        for (uint parentIndex = 0u; parentIndex < 2u; parentIndex++) {
            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = cvs[parentIndex * 2u][wordIndex];
                blockWords[wordIndex + 8u] = cvs[parentIndex * 2u + 1u][wordIndex];
            }
            parent_cv(cvs[parentIndex], blockWords, key, params.flags);
        }

        uint blockWords[16];
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            blockWords[wordIndex] = cvs[0][wordIndex];
            blockWords[wordIndex + 8u] = cvs[1][wordIndex];
        }
        parent_cv(cvs[0], blockWords, key, params.flags);

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
            uint key[8];
            load_key(key, params.key);

            for (uint pairIndex = 0u; pairIndex < 8u; pairIndex++) {
                uint blockWords[16];
                uint wordBase = pairIndex * 16u;
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = load32_aligned(inputWords, wordBase + wordIndex);
                }
                parent_cv(cvs[pairIndex], blockWords, key, params.flags);
            }

            for (uint parentIndex = 0u; parentIndex < 4u; parentIndex++) {
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex] = cvs[parentIndex * 2u][wordIndex];
                    blockWords[wordIndex + 8u] = cvs[parentIndex * 2u + 1u][wordIndex];
                }
                parent_cv(cvs[parentIndex], blockWords, key, params.flags);
            }

            for (uint parentIndex = 0u; parentIndex < 2u; parentIndex++) {
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex] = cvs[parentIndex * 2u][wordIndex];
                    blockWords[wordIndex + 8u] = cvs[parentIndex * 2u + 1u][wordIndex];
                }
                parent_cv(cvs[parentIndex], blockWords, key, params.flags);
            }

            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                blockWords[wordIndex] = cvs[0][wordIndex];
                blockWords[wordIndex + 8u] = cvs[1][wordIndex];
            }
            parent_cv(cvs[0], blockWords, key, params.flags);

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
        uint key[8];
        load_key(key, params.key);
        reduce_tail_cvs(tailCVs, remainder, key, params.flags);

        device uint *out = reinterpret_cast<device uint *>(parentCVs + ulong(fullGroupCount) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, tailCVs[0][wordIndex]);
        }
    }

    kernel void blake3_root_digest(device const uchar *rootCVs [[buffer(0)]],
                                   device uchar *digest [[buffer(1)]],
                                   constant BLAKE3ParentParams &params [[buffer(2)]],
                                   uint gid [[thread_position_in_grid]]) {
        if (gid != 0u) {
            return;
        }

        device const uint *rootWords = reinterpret_cast<device const uint *>(rootCVs);
        uint blockWords[16];
        for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
            blockWords[wordIndex] = load32_aligned(rootWords, wordIndex);
        }

        uint key[8];
        load_key(key, params.key);
        uint cv[8];
        init_cv(cv, key);
        compress_in_place(cv, blockWords, 64u, 0UL, params.flags | 12u);

        device uint *digestWords = reinterpret_cast<device uint *>(digest);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(digestWords, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_root3_digest(device const uchar *rootCVs [[buffer(0)]],
                                    device uchar *digest [[buffer(1)]],
                                    constant BLAKE3ParentParams &params [[buffer(2)]],
                                    uint gid [[thread_position_in_grid]]) {
        if (gid != 0u) {
            return;
        }

        device const uint *inputWords = reinterpret_cast<device const uint *>(rootCVs);
        uint leftCV[8];
        uint blockWords[16];
        uint key[8];
        load_key(key, params.key);

        for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
            blockWords[wordIndex] = load32_aligned(inputWords, wordIndex);
        }
        parent_cv(leftCV, blockWords, key, params.flags);

        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            blockWords[wordIndex] = leftCV[wordIndex];
            blockWords[wordIndex + 8u] = load32_aligned(inputWords, 16u + wordIndex);
        }

        uint cv[8];
        init_cv(cv, key);
        compress_in_place(cv, blockWords, 64u, 0UL, params.flags | 12u);

        device uint *digestWords = reinterpret_cast<device uint *>(digest);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(digestWords, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_root4_digest(device const uchar *rootCVs [[buffer(0)]],
                                    device uchar *digest [[buffer(1)]],
                                    constant BLAKE3ParentParams &params [[buffer(2)]],
                                    uint gid [[thread_position_in_grid]]) {
        if (gid != 0u) {
            return;
        }

        device const uint *inputWords = reinterpret_cast<device const uint *>(rootCVs);
        uint cvs[2][8];
        uint key[8];
        load_key(key, params.key);

        for (uint pairIndex = 0u; pairIndex < 2u; pairIndex++) {
            uint blockWords[16];
            uint wordBase = pairIndex * 16u;
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_aligned(inputWords, wordBase + wordIndex);
            }
            parent_cv(cvs[pairIndex], blockWords, key, params.flags);
        }

        uint blockWords[16];
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            blockWords[wordIndex] = cvs[0][wordIndex];
            blockWords[wordIndex + 8u] = cvs[1][wordIndex];
        }

        uint cv[8];
        init_cv(cv, key);
        compress_in_place(cv, blockWords, 64u, 0UL, params.flags | 12u);

        device uint *digestWords = reinterpret_cast<device uint *>(digest);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(digestWords, wordIndex, cv[wordIndex]);
        }
    }

    kernel void blake3_root_xof(device const uchar *rootCVs [[buffer(0)]],
                                device uchar *output [[buffer(1)]],
                                constant BLAKE3XOFParams &params [[buffer(2)]],
                                uint gid [[thread_position_in_grid]]) {
        if (params.outputByteCount == 0UL) {
            return;
        }

        ulong startBlock = params.seek / 64UL;
        ulong blockStart = (startBlock + ulong(gid)) * 64UL;
        ulong outputStart = params.seek;
        ulong outputEnd = params.seek + params.outputByteCount;
        ulong blockEnd = blockStart + 64UL;
        ulong copyStart = blockStart > outputStart ? blockStart : outputStart;
        ulong copyEnd = blockEnd < outputEnd ? blockEnd : outputEnd;
        if (copyStart >= copyEnd) {
            return;
        }

        device const uint *rootWords = reinterpret_cast<device const uint *>(rootCVs);
        uint blockWords[16];
        for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
            blockWords[wordIndex] = load32_aligned(rootWords, wordIndex);
        }

        uint key[8];
        load_key(key, params.key);
        uint words[16];
        compress_xof(key, blockWords, 64u, startBlock + ulong(gid), params.flags | 12u, words);

        uint sourceOffset = uint(copyStart - blockStart);
        ulong destinationOffset = copyStart - outputStart;
        uint copyCount = uint(copyEnd - copyStart);
        for (uint byteIndex = 0u; byteIndex < copyCount; byteIndex++) {
            output[destinationOffset + ulong(byteIndex)] = xof_byte(words, sourceOffset + byteIndex);
        }
    }

    """

    static let digestOnlyHash = """
    #include <metal_stdlib>
    using namespace metal;

    struct BLAKE3ChunkParams {
        ulong inputOffset;
        ulong inputLength;
        ulong baseChunkCounter;
        uint chunkCount;
        uint canLoadWords;
        uint padding0;
        uint padding1;
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

    static inline void chunk_full_aligned_cv(device const uchar *chunk,
                                             ulong chunkCounter,
                                             thread uint cv[8]) {
        device const uint *chunkWords32 = reinterpret_cast<device const uint *>(chunk);

        cv[0] = IV[0];
        cv[1] = IV[1];
        cv[2] = IV[2];
        cv[3] = IV[3];
        cv[4] = IV[4];
        cv[5] = IV[5];
        cv[6] = IV[6];
        cv[7] = IV[7];

        uint blockWords[16];
        for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
            blockWords[wordIndex] = load32_aligned(chunkWords32, wordIndex);
        }
        compress_in_place(cv, blockWords, 64u, chunkCounter, 1u);

        for (uint blockIndex = 1u; blockIndex < 15u; blockIndex++) {
            uint wordBase = blockIndex * 16u;
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = load32_aligned(chunkWords32, wordBase + wordIndex);
            }
            compress_in_place(cv, blockWords, 64u, chunkCounter, 0u);
        }

        for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
            blockWords[wordIndex] = load32_aligned(chunkWords32, 240u + wordIndex);
        }
        compress_in_place(cv, blockWords, 64u, chunkCounter, 2u);
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
        bool canLoadWords = params.canLoadWords != 0u;

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
        bool canLoadWords = params.canLoadWords != 0u;

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

    kernel void blake3_chunk_full_aligned_cvs(device const uchar *input [[buffer(0)]],
                                              device uchar *chunkCVs [[buffer(1)]],
                                              constant BLAKE3ChunkParams &params [[buffer(2)]],
                                              uint gid [[thread_position_in_grid]]) {
        device const uchar *chunk = input + params.inputOffset + ulong(gid) * 1024UL;
        ulong chunkCounter = params.baseChunkCounter + ulong(gid);

        uint cv[8];
        chunk_full_aligned_cv(chunk, chunkCounter, cv);

        device uint *out = reinterpret_cast<device uint *>(chunkCVs + ulong(gid) * 32UL);
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            store32_aligned(out, wordIndex, cv[wordIndex]);
        }
    }

    static inline void tile_reduce_exact(threadgroup uint *tileScratch,
                                         uint tileChunkCount,
                                         uint tid) {
        for (uint activeCount = tileChunkCount; activeCount > 1u; activeCount >>= 1u) {
            threadgroup_barrier(mem_flags::mem_threadgroup);
            uint parentCount = activeCount >> 1u;
            uint blockWords[16];
            if (tid < parentCount) {
                uint leftWordBase = tid * 16u;
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = tileScratch[leftWordBase + wordIndex];
                }
            }

            threadgroup_barrier(mem_flags::mem_threadgroup);
            if (tid < parentCount) {
                uint outWordBase = tid * 8u;
                uint cv[8];
                parent_cv(cv, blockWords);
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    tileScratch[outWordBase + wordIndex] = cv[wordIndex];
                }
            }
        }
        threadgroup_barrier(mem_flags::mem_threadgroup);
    }

    static inline void tile_reduce_pingpong_exact(threadgroup uint *tileScratch,
                                                 device uchar *tileCVs,
                                                 uint tileChunkCount,
                                                 uint tid,
                                                 uint tgid) {
        threadgroup uint *src = tileScratch;
        threadgroup uint *dst = tileScratch + tileChunkCount * 8u;

        for (uint activeCount = tileChunkCount; activeCount > 1u; activeCount >>= 1u) {
            threadgroup_barrier(mem_flags::mem_threadgroup);
            uint parentCount = activeCount >> 1u;
            if (tid < parentCount) {
                uint leftWordBase = tid * 16u;
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                    blockWords[wordIndex] = src[leftWordBase + wordIndex];
                }

                uint outWordBase = tid * 8u;
                uint cv[8];
                parent_cv(cv, blockWords);
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    dst[outWordBase + wordIndex] = cv[wordIndex];
                }
            }
            threadgroup uint *tmp = src;
            src = dst;
            dst = tmp;
        }

        threadgroup_barrier(mem_flags::mem_threadgroup);
        if (tid == 0u) {
            device uint *out = reinterpret_cast<device uint *>(tileCVs + ulong(tgid) * 32UL);
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                store32_aligned(out, wordIndex, src[wordIndex]);
            }
        }
    }

    static inline void chunk_tile_cvs(device const uchar *input,
                                      device uchar *tileCVs,
                                      constant BLAKE3ChunkParams &params,
                                      threadgroup uint *tileScratch,
                                      uint tileChunkCount,
                                      uint tid,
                                      uint gid,
                                      uint tgid) {
        if (gid >= params.chunkCount) {
            return;
        }

        device const uchar *chunk = input + params.inputOffset + ulong(gid) * 1024UL;
        ulong chunkCounter = params.baseChunkCounter + ulong(gid);
        uint cv[8];
        chunk_full_aligned_cv(chunk, chunkCounter, cv);

        uint scratchBase = tid * 8u;
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            tileScratch[scratchBase + wordIndex] = cv[wordIndex];
        }

        tile_reduce_exact(tileScratch, tileChunkCount, tid);

        if (tid == 0u) {
            device uint *out = reinterpret_cast<device uint *>(tileCVs + ulong(tgid) * 32UL);
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                store32_aligned(out, wordIndex, tileScratch[wordIndex]);
            }
        }
    }

    static inline void chunk_tile_pingpong_cvs(device const uchar *input,
                                               device uchar *tileCVs,
                                               constant BLAKE3ChunkParams &params,
                                               threadgroup uint *tileScratch,
                                               uint tileChunkCount,
                                               uint tid,
                                               uint gid,
                                               uint tgid) {
        if (gid >= params.chunkCount) {
            return;
        }

        device const uchar *chunk = input + params.inputOffset + ulong(gid) * 1024UL;
        ulong chunkCounter = params.baseChunkCounter + ulong(gid);
        uint cv[8];
        chunk_full_aligned_cv(chunk, chunkCounter, cv);

        uint scratchBase = tid * 8u;
        for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
            tileScratch[scratchBase + wordIndex] = cv[wordIndex];
        }

        tile_reduce_pingpong_exact(tileScratch, tileCVs, tileChunkCount, tid, tgid);
    }

    static inline void reduce_simdgroup32_cv(thread uint cv[8],
                                             uint simdLane) {
        for (uint offset = 1u; offset < 32u; offset <<= 1u) {
            uint partner[8];
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                partner[wordIndex] = simd_shuffle_down(cv[wordIndex], ushort(offset));
            }

            if ((simdLane & ((offset << 1u) - 1u)) == 0u) {
                uint blockWords[16];
                for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                    blockWords[wordIndex] = cv[wordIndex];
                    blockWords[wordIndex + 8u] = partner[wordIndex];
                }
                parent_cv(cv, blockWords);
            }
        }
    }

    static inline void chunk_tile128_simdgroup_cvs(device const uchar *input,
                                                   device uchar *tileCVs,
                                                   constant BLAKE3ChunkParams &params,
                                                   threadgroup uint *tileScratch,
                                                   uint tid,
                                                   uint gid,
                                                   uint tgid,
                                                   uint simdLane,
                                                   uint simdGroup) {
        device const uchar *chunk = input + params.inputOffset + ulong(gid) * 1024UL;
        ulong chunkCounter = params.baseChunkCounter + ulong(gid);
        uint cv[8];
        chunk_full_aligned_cv(chunk, chunkCounter, cv);

        reduce_simdgroup32_cv(cv, simdLane);

        if (simdLane == 0u) {
            uint scratchBase = simdGroup * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                tileScratch[scratchBase + wordIndex] = cv[wordIndex];
            }
        }

        threadgroup_barrier(mem_flags::mem_threadgroup);
        if (tid < 2u) {
            uint blockWords[16];
            uint wordBase = tid * 16u;
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = tileScratch[wordBase + wordIndex];
            }
            parent_cv(cv, blockWords);
            uint outWordBase = tid * 8u;
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                tileScratch[outWordBase + wordIndex] = cv[wordIndex];
            }
        }

        threadgroup_barrier(mem_flags::mem_threadgroup);
        if (tid == 0u) {
            uint blockWords[16];
            for (uint wordIndex = 0u; wordIndex < 16u; wordIndex++) {
                blockWords[wordIndex] = tileScratch[wordIndex];
            }
            parent_cv(cv, blockWords);
            device uint *out = reinterpret_cast<device uint *>(tileCVs + ulong(tgid) * 32UL);
            for (uint wordIndex = 0u; wordIndex < 8u; wordIndex++) {
                store32_aligned(out, wordIndex, cv[wordIndex]);
            }
        }
    }

    kernel void blake3_chunk_tile128_cvs(device const uchar *input [[buffer(0)]],
                                         device uchar *tileCVs [[buffer(1)]],
                                         constant BLAKE3ChunkParams &params [[buffer(2)]],
                                         threadgroup uint *tileScratch [[threadgroup(0)]],
                                         uint tid [[thread_position_in_threadgroup]],
                                         uint gid [[thread_position_in_grid]],
                                         uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_cvs(input, tileCVs, params, tileScratch, 128u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile256_cvs(device const uchar *input [[buffer(0)]],
                                         device uchar *tileCVs [[buffer(1)]],
                                         constant BLAKE3ChunkParams &params [[buffer(2)]],
                                         threadgroup uint *tileScratch [[threadgroup(0)]],
                                         uint tid [[thread_position_in_threadgroup]],
                                         uint gid [[thread_position_in_grid]],
                                         uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_cvs(input, tileCVs, params, tileScratch, 256u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile512_cvs(device const uchar *input [[buffer(0)]],
                                         device uchar *tileCVs [[buffer(1)]],
                                         constant BLAKE3ChunkParams &params [[buffer(2)]],
                                         threadgroup uint *tileScratch [[threadgroup(0)]],
                                         uint tid [[thread_position_in_threadgroup]],
                                         uint gid [[thread_position_in_grid]],
                                         uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_cvs(input, tileCVs, params, tileScratch, 512u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile1024_cvs(device const uchar *input [[buffer(0)]],
                                          device uchar *tileCVs [[buffer(1)]],
                                          constant BLAKE3ChunkParams &params [[buffer(2)]],
                                          threadgroup uint *tileScratch [[threadgroup(0)]],
                                          uint tid [[thread_position_in_threadgroup]],
                                          uint gid [[thread_position_in_grid]],
                                          uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_cvs(input, tileCVs, params, tileScratch, 1024u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile128_simdgroup_cvs(device const uchar *input [[buffer(0)]],
                                                   device uchar *tileCVs [[buffer(1)]],
                                                   constant BLAKE3ChunkParams &params [[buffer(2)]],
                                                   threadgroup uint *tileScratch [[threadgroup(0)]],
                                                   uint tid [[thread_position_in_threadgroup]],
                                                   uint gid [[thread_position_in_grid]],
                                                   uint tgid [[threadgroup_position_in_grid]],
                                                   uint simdLane [[thread_index_in_simdgroup]],
                                                   uint simdGroup [[simdgroup_index_in_threadgroup]]) {
        chunk_tile128_simdgroup_cvs(input, tileCVs, params, tileScratch, tid, gid, tgid, simdLane, simdGroup);
    }

    kernel void blake3_chunk_tile128_pingpong_cvs(device const uchar *input [[buffer(0)]],
                                                  device uchar *tileCVs [[buffer(1)]],
                                                  constant BLAKE3ChunkParams &params [[buffer(2)]],
                                                  threadgroup uint *tileScratch [[threadgroup(0)]],
                                                  uint tid [[thread_position_in_threadgroup]],
                                                  uint gid [[thread_position_in_grid]],
                                                  uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_pingpong_cvs(input, tileCVs, params, tileScratch, 128u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile256_pingpong_cvs(device const uchar *input [[buffer(0)]],
                                                  device uchar *tileCVs [[buffer(1)]],
                                                  constant BLAKE3ChunkParams &params [[buffer(2)]],
                                                  threadgroup uint *tileScratch [[threadgroup(0)]],
                                                  uint tid [[thread_position_in_threadgroup]],
                                                  uint gid [[thread_position_in_grid]],
                                                  uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_pingpong_cvs(input, tileCVs, params, tileScratch, 256u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile512_pingpong_cvs(device const uchar *input [[buffer(0)]],
                                                  device uchar *tileCVs [[buffer(1)]],
                                                  constant BLAKE3ChunkParams &params [[buffer(2)]],
                                                  threadgroup uint *tileScratch [[threadgroup(0)]],
                                                  uint tid [[thread_position_in_threadgroup]],
                                                  uint gid [[thread_position_in_grid]],
                                                  uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_pingpong_cvs(input, tileCVs, params, tileScratch, 512u, tid, gid, tgid);
    }

    kernel void blake3_chunk_tile1024_pingpong_cvs(device const uchar *input [[buffer(0)]],
                                                   device uchar *tileCVs [[buffer(1)]],
                                                   constant BLAKE3ChunkParams &params [[buffer(2)]],
                                                   threadgroup uint *tileScratch [[threadgroup(0)]],
                                                   uint tid [[thread_position_in_threadgroup]],
                                                   uint gid [[thread_position_in_grid]],
                                                   uint tgid [[threadgroup_position_in_grid]]) {
        chunk_tile_pingpong_cvs(input, tileCVs, params, tileScratch, 1024u, tid, gid, tgid);
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

    kernel void blake3_parent4_exact_cvs(device const uchar *inputCVs [[buffer(0)]],
                                         device uchar *parentCVs [[buffer(1)]],
                                         constant BLAKE3ParentParams &params [[buffer(2)]],
                                         uint gid [[thread_position_in_grid]]) {
        uint outputCount = params.inputCount / 4u;
        if (gid >= outputCount) {
            return;
        }

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
