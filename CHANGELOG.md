# Changelog

This project uses semantic versioning for public releases. Until `1.0.0`, source and API compatibility may change between minor versions.

## Unreleased

### Added

- Proprietary source-available license and commercial-use boundary.
- Release process, API stability notes, benchmark fixture scripts, example package, and security review notes.
- Fast differential tests for awkward BLAKE3 block, chunk, and subtree boundaries.
- Reusable CPU parallel scheduler inside `BLAKE3.Context`.
- Optional benchmark RSS snapshots with `--memory-stats`.
- Focused file-strategy differential tests across small and subtree-adjacent boundaries.
- Precompiled Metal library loading via `BLAKE3Metal.LibrarySource.metallib` and benchmark `--metal-library`.
- Persistent CPU worker pool inside `BLAKE3.Context` for repeated parallel hashes.
- Machine-readable benchmark reports via `blake3-bench --json-output`.
- Strict benchmark report validation via `blake3-bench --validate-json`.
- Benchmark tuning controls for Metal automatic GPU gates and tiled Metal file tile size.
- Benchmark memory snapshots now include Darwin allocator bytes and block counts alongside RSS.
- Metal autotuning command and fixture script for measured gate, mode, and optional tiled-file tile recommendations.

### Changed

- Automatic CPU parallel hashing now prefers Darwin performance-core counts when available, falling back to active processor count elsewhere.
- Reusable CPU contexts no longer submit per-worker GCD async jobs on each parallel hash.
- Scalar chunk and parent hot loops avoid a few redundant block-load and parent-word setup checks, and full block loads now use direct unaligned SIMD loads.
- Scalar compression now keeps the 16-word state in direct local words instead of rebinding through an unsafe pointer for indexed round updates.
- SIMD4 full-chunk block loading now uses contiguous block loads before transposing lanes, reducing per-word address arithmetic in the hot loop.

## Release Notes Template

Use this structure for GitHub releases:

```md
# BLAKE3Swift vX.Y.Z

## License

This is proprietary source-available software. Production, commercial, hosted, redistributed, or revenue-connected use requires a separate commercial license.

## API Stability

State whether this release is pre-1.0 experimental, source-stable, or includes breaking changes.

## Highlights

- ...

## Correctness

- Official BLAKE3 vectors:
- Differential boundary tests:
- Metal-vs-CPU parity:

## Performance

- Hardware:
- OS:
- Swift:
- Commands:
- Timing classes:
- Sustained thermal window:

## Migration Notes

- ...

## Known Limitations

- ...
```
