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

### Changed

- Automatic CPU parallel hashing now prefers Darwin performance-core counts when available, falling back to active processor count elsewhere.
- Scalar chunk and parent hot loops avoid a few redundant block-load and parent-word setup checks.

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
