# BLAKE3Swift Examples

This directory is a standalone Swift package that depends on the local `Blake3` product from the repository root. It is intended for API smoke testing and copyable integration snippets, not throughput measurement.

Run commands from the repository root:

```bash
swift run --package-path Examples Blake3Examples help
swift run --package-path Examples Blake3Examples all
```

Use `-c release` for a more realistic runtime profile:

```bash
swift run -c release --package-path Examples Blake3Examples one-shot
```

## Commands

| Command | What it covers |
| --- | --- |
| `backend-info` | Default backend policy, CPU backend name, worker count, Metal threshold, and Metal device availability. |
| `one-shot` | `BLAKE3.hash`, `BLAKE3.hashCPU`, and `BLAKE3.hashSerial` on a small input. |
| `streaming` | Incremental `BLAKE3.Hasher` updates and finalization. |
| `keyed` | Keyed 32-byte digest generation. |
| `derive-key` | BLAKE3 key derivation with a context string and 64-byte output. |
| `xof` | Extendable output through `finalizeXOF()`. |
| `context` | Reusing `BLAKE3.Context` for repeated CPU hashes. |
| `file [path]` | CPU memory-mapped parallel file hashing. Without a path, the example creates a temporary deterministic input file. |
| `metal-resident` | Resident shared `MTLBuffer` hashing through `BLAKE3Metal.Context`. |
| `async-pipeline` | Reusable async Metal pipeline hashing with private buffers. |
| `tiled-file [path]` | Tiled Metal memory-mapped file hashing. Without a path, the example creates a temporary deterministic input file. |
| `all` | Runs the full sample set, skipping Metal commands when no Metal device is available. |

Examples that accept a file path:

```bash
swift run --package-path Examples Blake3Examples file README.md
swift run --package-path Examples Blake3Examples tiled-file /path/to/large-input.bin
```

Metal examples print CPU parity checks beside the Metal digest. If a machine has no Metal device, those commands exit successfully after printing a skip message.

For benchmark-quality numbers, use the root benchmark executable and scripts documented in `../benchmarks/README.md`.
