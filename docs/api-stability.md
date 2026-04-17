# API Stability

BLAKE3Swift is pre-`1.0.0`. Public APIs are usable for evaluation, benchmarking, and integration trials, but source stability is not guaranteed until a `1.0.0` release tag says so explicitly.

## Current Stability Levels

| Surface | Status | Notes |
| --- | --- | --- |
| `BLAKE3.hash`, `keyedHash`, `deriveKey` | Candidate stable | Names and return types are expected to survive `1.0.0`. |
| `BLAKE3.Hasher` and `OutputReader` | Candidate stable | Copy-on-write behavior and non-consuming finalize are intended API guarantees. |
| `BLAKE3.Context` | Experimental stable | Reusable workspace and scheduler semantics are intended, but scheduler tuning may change before `1.0.0`. |
| `BLAKE3File` | Experimental | Strategy names and fallback behavior may change as tiled file work evolves. |
| `BLAKE3Metal` | Experimental | Resident, staged, private, async, and tiled APIs may change as kernels and packaging are specialized. |
| `BLAKE3Metal.LibrarySource` | Experimental stable | Runtime source and packaged `.metallib` loading are intended production packaging surfaces. |
| Benchmark executable | Experimental | Human-readable tables may change. JSON reports carry `schema_version: 1` and should be versioned on breaking format changes. |
| Autotune report | Experimental | `--autotune-metal` JSON carries `schema_version: 1`; recommendations are device-local measurements, not stable API promises. |

## Concurrency And Ownership

- Value types such as `BLAKE3.Digest` can be passed across concurrency domains.
- `BLAKE3.Hasher` should be mutated by one task at a time. Copies are isolated through copy-on-write storage.
- `BLAKE3.Context` and `BLAKE3Metal.Context` are shareable, but protect reusable workspace with internal synchronization. Use separate contexts for independent callers that must execute concurrently.
- `BLAKE3.Context(maxWorkers:)` pins the reusable CPU scheduler worker pool for repeated hashes and benchmark reproducibility.
- Raw buffer inputs only need to live for the duration of synchronous calls.
- Async Metal calls require buffers to remain valid until the async call completes.
- File async APIs keep memory mappings alive until CPU or GPU work has completed.

## Performance Claims

Resident, end-to-end, staged, wrapped, private, file, and sustained timings are separate API stories. Documentation and release notes must identify which timing class a number belongs to.

## Package Boundaries

The root library product contains only the `Blake3` target. Benchmark code lives in the `Blake3Benchmark` executable target, and runnable examples live in `Examples/` as a separate package. Keep future tuning tools and publication fixtures out of the library target unless they are required by the public hashing API.

## Compatibility

The primary optimization target is Apple silicon. CPU-only operation should remain available on macOS hosts without Metal. Public releases should note whether validation covered M1, M2, M3, M4, and Intel/macOS CPU-only systems.
