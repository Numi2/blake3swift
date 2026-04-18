# Security Review Notes

This is a repository-grounded review checklist for cryptographic integration risk. It is not a third-party audit.

## Current Positive Controls

- Digest equality uses `constantTimeEquals` and does not early-exit on the first differing byte.
- Keyed hashing enforces exactly 32-byte keys.
- Key-derivation contexts are encoded as UTF-8 bytes without lossy conversion.
- Streaming finalization does not consume the hasher, so callers can derive fixed digests and XOF output from the same state intentionally.
- File mappings are scoped to the hash operation and are unmapped after CPU or Metal work completes.
- Metal file strategies fall back to CPU by default unless the caller disables fallback.
- Synchronous no-copy Metal hashing keeps Swift-owned input alive until GPU completion before returning.
- Synchronous private-staged Metal hashing keeps staging and private buffers locked until upload and hash completion.
- Tests cover official vectors, keyed hash, key derivation, XOF, streaming boundaries, file paths, and Metal-vs-CPU parity where Metal is available.

## Residual Risks To Review Before `1.0.0`

- Key material is not actively zeroized after use; Swift value semantics and optimizer behavior make reliable zeroization non-trivial.
- Custom Metal kernels need continued differential testing against CPU for unaligned ranges, tails, exact chunk boundaries, and large trees.
- Unsafe pointer use is performance-critical and should be reviewed after each scalar, SIMD, or Metal hot-loop change.
- Parallel CPU scheduling defaults to the active processor count, and reusable contexts serialize access to their persistent worker pool; cross-machine validation is still required.
- This package does not provide password hashing, authenticated encryption, message authentication protocol design, or misuse-resistant key management.

## Release Gate

Before a production/commercial license release, run:

- Official vector tests.
- Differential boundary tests for `0`, `1`, `63`, `64`, `65`, `1023`, `1024`, `1025`, subtree powers, and unaligned ranges.
- Metal-vs-CPU parity on every Metal strategy.
- File hashing parity for read, mapped, mapped parallel, Metal mapped, and tiled Metal mapped paths.
- Review of public docs so benchmark numbers are not confused across timing classes.
