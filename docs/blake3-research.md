# BLAKE3 Research Notes for a Swift Port

These notes are based on the official BLAKE3 Rust repository tag `1.8.4`
(`b97a24f`, released 2026-03-30), the C2SP BLAKE3 specification, and the
upstream test vector set.

## Primary Sources

- [C2SP BLAKE3 specification](https://c2sp.org/BLAKE3)
- [Official BLAKE3 repository](https://github.com/BLAKE3-team/BLAKE3)
- [Rust reference implementation](https://github.com/BLAKE3-team/BLAKE3/blob/1.8.4/reference_impl/reference_impl.rs)
- [Production Rust crate source](https://github.com/BLAKE3-team/BLAKE3/blob/1.8.4/src/lib.rs)
- [Portable Rust compression function](https://github.com/BLAKE3-team/BLAKE3/blob/1.8.4/src/portable.rs)
- [Official test vectors](https://github.com/BLAKE3-team/BLAKE3/blob/1.8.4/test_vectors/test_vectors.json)

## What BLAKE3 Provides

BLAKE3 is a cryptographic hash framework with one core algorithm and multiple
modes:

- `hash`: unkeyed general-purpose hashing.
- `keyed_hash`: 32-byte-key PRF/MAC mode.
- `derive_key`: KDF mode using a context string plus key material.
- XOF output: any of the above can produce more than 32 bytes.

It is not a password hashing algorithm. Passwords need a dedicated password hash
or password-based KDF such as Argon2.

## Core Parameters

These are fixed by the spec and Rust implementation:

- `OUT_LEN = 32`
- `KEY_LEN = 32`
- `BLOCK_LEN = 64`
- `CHUNK_LEN = 1024`
- `MAX_DEPTH = 54`, because `2^54 * 1024 = 2^64`
- Word type: `UInt32`
- Byte order: little endian

Flags:

- `CHUNK_START = 1 << 0`
- `CHUNK_END = 1 << 1`
- `PARENT = 1 << 2`
- `ROOT = 1 << 3`
- `KEYED_HASH = 1 << 4`
- `DERIVE_KEY_CONTEXT = 1 << 5`
- `DERIVE_KEY_MATERIAL = 1 << 6`

IV words:

```text
6A09E667 BB67AE85 3C6EF372 A54FF53A
510E527F 9B05688C 1F83D9AB 5BE0CD19
```

Message permutation:

```text
2, 6, 3, 10, 7, 0, 4, 13, 1, 11, 12, 5, 9, 14, 15, 8
```

## Compression Function

The portable Rust implementation is the best Swift porting source. The
compression state is 16 `UInt32` words:

- `state[0...7]`: current chaining value.
- `state[8...11]`: `IV[0...3]`.
- `state[12]`: low 32 bits of the 64-bit counter.
- `state[13]`: high 32 bits of the counter.
- `state[14]`: block length, from `0...64`.
- `state[15]`: flags.

Each compression performs 7 rounds. Each round applies 8 `G` calls with wrapping
32-bit addition, XOR, and right rotations by 16, 12, 8, and 7 bits.

After the rounds:

- Chaining value output is the first 8 words after feed-forward.
- Root/XOF output uses all 16 words serialized as little-endian bytes.

Swift implementation detail: every addition must use `&+`; normal `+` is wrong
in debug builds and conceptually wrong for this primitive.

## Tree Mode

BLAKE3 input is split into 1024-byte chunks. Each full chunk has 16 blocks of 64
bytes. The counter used for every block in a chunk is the chunk index, not the
block index.

Chunk rules:

- First block in each chunk sets `CHUNK_START`.
- Last block in each chunk sets `CHUNK_END`.
- A one-block chunk sets both.
- A short block is zero-padded, but `block_len` remains the actual byte count.
- Empty input is represented as an empty final chunk.

Parent node rules:

- A parent block is the 64-byte concatenation of left and right 32-byte child
  chaining values.
- Parent compression uses the mode key as the input chaining value.
- Parent counter is always zero.
- Parent block length is always 64.
- Parent flags include `PARENT` and the current mode flag.
- Parent nodes never use `CHUNK_START` or `CHUNK_END`.

For a first Swift implementation, use the 374-line Rust reference implementation
algorithm rather than the production crate's optimized lazy merging. The
reference approach keeps a fixed chaining-value stack and merges completed
subtrees when a chunk is finalized:

1. Hash chunk bytes into a chunk chaining value.
2. When total completed chunks has trailing zero bits, pop left siblings and
   merge them with the new right child.
3. Push the resulting chaining value.
4. At finalize, start with the current chunk output and fold stack entries from
   right to left until the root output remains.

The production Rust crate is useful later for optimization. It uses SIMD
dispatch, `rayon`, mmap helpers, a byte-oriented chaining-value stack, and lazy
merging to avoid compressing a node that may become the root.

## Mode Handling

Unkeyed hash:

- Key words are the IV.
- No mode flag.

Keyed hash:

- Caller supplies exactly 32 key bytes.
- Interpret as 8 little-endian words.
- Set `KEYED_HASH` for chunk and parent compressions.

Key derivation:

- Phase 1 hashes the UTF-8 context string using IV and `DERIVE_KEY_CONTEXT`.
- The first 32 output bytes become the context key.
- Phase 2 hashes key material using the context key and `DERIVE_KEY_MATERIAL`.

## Swift API Shape

Recommended initial public surface:

```swift
public struct Blake3Hash: Equatable, Sendable {
    public static let byteCount = 32
    public let bytes: [UInt8]
    public func constantTimeEquals(_ other: Blake3Hash) -> Bool
}

public struct Blake3 {
    public static func hash(_ input: some ContiguousBytes) -> Blake3Hash
    public static func keyedHash(key: some ContiguousBytes, input: some ContiguousBytes) throws -> Blake3Hash
    public static func deriveKey(context: String, material: some ContiguousBytes) -> [UInt8]
}

public struct Blake3Hasher {
    public init()
    public init(key: some ContiguousBytes) throws
    public init(deriveKeyContext context: String)
    public mutating func update(_ input: some ContiguousBytes)
    public func finalize() -> Blake3Hash
    public func finalizeXOF() -> Blake3OutputReader
}
```

Internal types should mirror the reference implementation:

- `ChunkState`
- `Output`
- `Blake3OutputReader`
- `parentOutput`
- `parentCV`
- `compress`
- little-endian load/store helpers

Use fixed-size arrays where practical. If Swift ergonomics make fixed arrays
too noisy, use `[UInt32]`/`[UInt8]` internally but assert exact sizes at
construction boundaries. Later performance work can move hot paths to
`ContiguousArray`, `withUnsafeBytes`, and platform-specific vector code.

## Validation Strategy

Use the official `test_vectors.json` as a test resource. It covers:

- hash, keyed hash, and derive-key modes
- default 32-byte output as the prefix of extended output
- boundary lengths around 64-byte blocks and 1024-byte chunks
- large inputs through 100 chunks

The official vector input is generated by repeating byte values modulo 251:

```swift
for i in 0..<input.count {
    input[i] = UInt8(i % 251)
}
```

Minimum test set for the Swift port:

- Compression function self-check against known upstream portable output.
- All official test vector cases.
- Incremental updates with varied split points: 0, 1, 2, 63, 64, 65, 1023,
  1024, 1025, and random-ish splits.
- XOF reads in one call, repeated aligned 64-byte calls, and repeated partial
  calls.
- Key length rejection for keyed mode.
- Empty input.
- Exact block, exact chunk, and chunk-plus-one inputs.
- `deriveKey` with the official context string.

## Porting Pitfalls

- Use wrapping arithmetic (`&+`) and `UInt32.rotateRight`.
- Preserve little-endian parsing and serialization exactly.
- Do not mark a completed chunk as root while more input might arrive.
- Do not set `ROOT` until final output generation.
- Do not set `CHUNK_START`/`CHUNK_END` on parent nodes.
- Parent nodes use counter 0, not a chunk counter.
- XOF output blocks are 64 bytes; the XOF counter increments once per 64-byte
  output block.
- The default 32-byte hash is the prefix of any longer XOF output.
- Swift `Equatable` is not constant-time. Provide a separate constant-time
  comparison API for MAC use.
- Zeroizing secrets in Swift is difficult to guarantee; document this if keyed
  hashing is exposed for sensitive keys.

## Implementation Order

1. Create a SwiftPM library package with test target.
2. Implement constants, flags, little-endian helpers, `G`, round, permutation,
   and compression.
3. Implement `Output` and XOF byte extraction.
4. Implement `ChunkState`.
5. Implement `Hasher` using the reference implementation's chaining-value
   stack.
6. Add one-shot `hash`, `keyedHash`, and `deriveKey` APIs.
7. Import and run official test vectors.
8. Add ergonomics: `Data` conveniences, hex encoding/decoding, and
   constant-time equality.
9. Profile scalar Swift.
10. Consider optimized backends: Swift SIMD/Accelerate-style vectorization,
    Apple Silicon NEON via C/assembly bridge, or FFI to the upstream C backend.
