# Benchmark methodology

This project publishes two primary benchmark classes and four optimized diagnostic/application-path variants. The primary classes are `resident`, which reports hashing-engine throughput for input already in Metal-accessible storage, and `end-to-end`, which reports the fresh Swift-owned input path through a Metal hash. The `private` mode is a resident benchmark for preloaded `storageModePrivate` input. The `private-staged` mode measures a repeated Swift-owned upload path into reusable private GPU storage. The `staged` mode is the recommended repeated-call shared-buffer application path: Swift-owned bytes are copied into a reusable Metal buffer before hashing. The `wrapped` mode is a no-copy diagnostic bridge for existing Swift storage; useful, but not the headline claim.

## `metal-resident-*`

Resident timings measure hashing an existing `MTLBuffer`.

The timer starts immediately before `BLAKE3Metal.Context.hash(...)` is called with a pre-created input `MTLBuffer`, and it stops after the 32-byte digest has been read from the shared digest buffer and returned to Swift. This is the hashing-engine benchmark.

Included in each timed iteration:

- `BLAKE3Metal.Context.hash(...)`
- command buffer creation
- compute encoder creation
- command encoding for chunk, parent, and root kernels
- GPU execution
- `waitUntilCompleted()`
- reading the 32-byte digest from the shared digest buffer

Excluded from each timed iteration:

- Swift input allocation
- deterministic input filling
- `MTLBuffer` creation
- copying Swift bytes into the `MTLBuffer`
- Metal device/context creation
- Metal library and pipeline compilation
- first-use reusable scratch-buffer allocation

The benchmark performs one untimed warm-up call before measuring each result. That warm-up pays first-use workspace growth for the current size.

Resident numbers are useful for device-resident or already-staged data paths. They should not be presented as full Swift-bytes-to-digest throughput.

## `metal-private-*`

Private-resident timings measure hashing an existing `storageModePrivate` `MTLBuffer`.

The timer starts immediately before `BLAKE3Metal.Context.hash(...)` is called with a pre-created private input `MTLBuffer`, and it stops after the 32-byte digest has been read from the shared digest buffer and returned to Swift. The setup copy into private storage is excluded. This is a hashing-engine benchmark for data that is already resident in GPU-private storage.

Included in each timed iteration:

- `BLAKE3Metal.Context.hash(...)`
- command buffer creation
- compute encoder creation
- command encoding for chunk, parent, and root kernels
- GPU execution
- `waitUntilCompleted()`
- reading the 32-byte digest from the shared digest buffer

Excluded from each timed iteration:

- Swift input allocation
- deterministic input filling
- source shared `MTLBuffer` creation
- destination private `MTLBuffer` creation
- blit copy into private storage
- Metal device/context creation
- Metal library and pipeline compilation
- first-use reusable scratch-buffer allocation

Private-resident numbers should not be presented as full Swift-bytes-to-digest throughput. They are useful for GPU pipelines where data is already in private Metal storage.

## `metal-private-staged-*`

Private-staged timings measure hashing from an existing Swift byte array through reusable upload resources into private GPU storage.

The timer starts immediately before copying Swift bytes into a pre-created shared staging buffer, then includes a blit into a pre-created private `MTLBuffer`, the private-buffer hash, command-buffer completion, and digest extraction. The synchronous helper uses a single combined upload+hash command buffer for tuned 16 MiB inputs and the faster split upload-then-hash sequence for larger inputs. This is not a resident benchmark; it is a repeated-call application path for callers that want private-storage hashing without per-call buffer allocation.

Included in each timed iteration:

- copying the Swift byte array into a reusable shared staging buffer
- blit command encoding, execution, and completion
- all work included in the private-resident hash path

Excluded from each timed iteration:

- Swift input allocation
- deterministic input filling
- shared staging `MTLBuffer` creation
- private destination `MTLBuffer` creation
- Metal device/context creation
- Metal library and pipeline compilation
- first-use reusable scratch-buffer allocation

This mode should be reported separately from both `private` and `staged`. It answers whether private GPU storage is still worthwhile when Swift-owned input must be uploaded every call.

## Async Metal API

The async Metal API is an application-pipelining surface, not a separate benchmark claim by itself. `hashAsync` encodes and commits GPU work, then resumes through a Metal completion handler after the digest is available. It does not call `waitUntilCompleted()` on the caller's thread.

An async timing claim must define whether timing starts before buffer upload, before command encoding, or after data is already resident. The same resident, staged, private, private-staged, wrapped, and end-to-end classes still apply.

The async implementation uses a bounded reusable `BLAKE3Metal.AsyncWorkspace` for GPU scratch buffers. The default context keeps a three-resource pool, and callers that pipeline more aggressively can create a workspace with `makeAsyncWorkspace(maxPooledResources:preallocateForByteCount:)`. If in-flight work exceeds the pool, a transient scratch resource is used rather than sharing buffers unsafely. Staging and private-buffer async helpers keep their wrapper reserved until completion so callers do not accidentally reuse the buffer while the GPU command is still reading it.

`BLAKE3Metal.Context.makeAsyncPipeline(inputCapacity:inFlightCount:policy:usesPrivateBuffers:)` is the reusable application API for repeated async jobs. It preallocates one staging buffer per in-flight slot plus a matching async workspace pool. In shared-staging mode, timing for `pipeline.hash(input:)` includes waiting for a free pipeline slot, copying Swift-owned bytes into the slot's shared `MTLBuffer`, command encoding, GPU execution, digest readback, and completion-handler resume. In private-buffer mode, the pipeline also preallocates one private input buffer per slot; `pipeline.hash(input:)` includes the shared staging copy, asynchronous blit into private storage, the private-buffer hash command, digest readback, and completion-handler resume. Pipeline creation, Metal context creation, first pipeline compilation, and preallocation are excluded from per-job timings unless a benchmark explicitly creates the pipeline inside the timed region.

## `BLAKE3File.Strategy.metalMemoryMapped`

The Metal mapped-file path is an application path, not a resident-buffer benchmark. It opens a regular file, memory maps it, wraps the mapped pages in a shared `MTLBuffer` with `makeBuffer(bytesNoCopy:length:options:deallocator:)`, then hashes that buffer through the normal Metal context. `--file-modes metal-mmap` timing includes file open/stat, `mmap`, Metal buffer wrapper creation, command encoding, GPU execution, wait, digest read, `munmap`, and close. It excludes benchmark file creation and does not read the file into a Swift byte array.

CPU `read`, `memoryMapped`, and `memoryMappedParallel` file benchmark modes are enabled with `--file-modes read,mmap,mmap-parallel`. `read` timing includes file open, streaming read loop, CPU update/finalize, and close. The mapped modes include open/stat, `mmap`, bounded tiled hashing, digest finalization, `munmap`, and close. They exclude benchmark file creation and full-file Swift byte-array allocation.

`BLAKE3File.hashAsync` is an application API, not a separate benchmark class. CPU file strategies run on a detached task and include the same work as their synchronous strategy plus task scheduling overhead. `metalMemoryMapped` keeps the mapping alive until the asynchronous Metal hash completes, so its timing still belongs to the Metal mapped-file class above.

## `BLAKE3File.Strategy.metalTiledMemoryMapped`

The tiled Metal mapped-file path is the canonical tree-contract path for large files. It memory maps the file, wraps the mapping in one shared `MTLBuffer`, processes complete non-final chunks through Metal into a reusable shared chunk-CV buffer, pushes those CVs into the Swift CV stack, and keeps the final BLAKE3 chunk as the root current chunk. Timing includes file open/stat, `mmap`, Metal buffer wrapper creation, tiled chunk-CV dispatches, GPU execution, chunk-CV readback from shared memory, CPU CV-stack reduction, final digest extraction, `munmap`, and close. It excludes benchmark file creation and does not combine independent tile digests.

The async tiled variant uses the same timing class and tree contract. `BLAKE3File.hashAsync(..., strategy: .metalTiledMemoryMapped)` keeps the mapping alive until every async chunk-CV command has completed, uses Metal completion handlers instead of caller-thread waits for tile kernels, and checks cancellation between tile commands and before finalization.

## `metal-e2e-*`

End-to-end Metal timings measure hashing from an existing Swift byte array into a fresh shared `MTLBuffer`.

The timer starts immediately before creating the per-iteration shared `MTLBuffer` with `makeBuffer(bytes:length:options:)`, and it stops after the digest has been read and returned to Swift. This is the steady-state application-path benchmark for Swift-owned input. It includes per-call Metal buffer setup and byte copy, but it does not include cold process startup, Metal device discovery, library compilation, pipeline creation, or the first scratch-buffer allocation.

Included in each timed iteration:

- shared `MTLBuffer` allocation
- copying the Swift byte array into that Metal buffer through `makeBuffer(bytes:length:options:)`
- all work included in the resident hash path

Excluded from each timed iteration:

- Swift input allocation
- deterministic input filling
- Metal device/context creation
- Metal library and pipeline compilation
- first-use reusable scratch-buffer allocation

On Apple Silicon, `storageModeShared` uses unified memory rather than a PCIe device transfer. The end-to-end mode still includes the host-side buffer allocation and byte copy into Metal-owned shared storage.

## `metal-staged-*`

Staged timings measure hashing from an existing Swift byte array into a reusable shared `MTLBuffer` created before the timed loop.

The timer starts immediately before copying Swift bytes into the reusable staging buffer, and it stops after the digest has been read and returned to Swift. This is the optimized repeated-call application-path benchmark for Swift-owned input. It includes the byte copy and all resident hash work, but excludes per-call input-buffer allocation.

Included in each timed iteration:

- copying the Swift byte array into a reusable shared `MTLBuffer`
- all work included in the resident hash path

Excluded from each timed iteration:

- Swift input allocation
- deterministic input filling
- staging `MTLBuffer` creation
- Metal device/context creation
- Metal library and pipeline compilation
- first-use reusable scratch-buffer allocation

This mode follows Apple's Metal guidance to create persistent objects early and reuse buffers instead of allocating resources in a hot loop.

## `metal-wrapped-*`

Wrapped timings measure hashing from an existing Swift byte array through `BLAKE3Metal.Context.hash(input:policy:)`, which uses `makeBuffer(bytesNoCopy:length:options:deallocator:)` for the synchronous call.

The timer starts immediately before creating the no-copy `MTLBuffer` wrapper and stops after the digest has been read and returned to Swift. This mode estimates a Swift-owned, no-copy application path on Apple Silicon unified memory.

Included in each timed iteration:

- creating a no-copy `MTLBuffer` wrapper over the existing Swift byte-array storage
- all work included in the resident hash path

Excluded from each timed iteration:

- Swift input allocation
- deterministic input filling
- copying Swift bytes into Metal-owned storage
- Metal device/context creation
- Metal library and pipeline compilation
- first-use reusable scratch-buffer allocation

The wrapped mode is only valid while the Swift storage stays alive and immobile for the full GPU operation. The public synchronous no-copy API keeps the Swift storage alive and waits for GPU completion before the `withUnsafeBytes` scope ends. This mode is useful for estimating an existing-memory no-copy path on Apple Silicon, but it is distinct from both resident Metal-owned buffers and copy-based end-to-end setup.

## Commands

CPU-only Swift backend sweep:

```sh
swift run -c release blake3-bench --sizes 1m,16m,64m --iterations 8 --metal-modes none
```

CPU worker tuning sweep:

```sh
swift run -c release blake3-bench --sizes 1m,16m,64m --iterations 8 --metal-modes none --cpu-workers 8
```

When `--cpu-workers` is omitted, automatic CPU parallelism uses the library default: `ProcessInfo.processInfo.activeProcessorCount`. Publication runs should record the emitted `defaultParallelWorkers` value and pin `--cpu-workers` when comparing CPU scheduler changes.

The one-shot CPU row switches from the bounded streaming stack to the SIMD chunk/parent reducer at 16 KiB. Automatic CPU parallelism starts at 96 KiB on the current Apple Silicon tuning pass.

The `context-auto` row uses `BLAKE3.Context`, which reuses chaining-value workspace and a persistent CPU worker pool across iterations. Compare `parallel` against `context-auto` to see the cost of one-shot scheduling/allocation versus repeated-hash reuse.

Optional RSS snapshots:

```sh
swift run -c release blake3-bench --sizes 16m,64m --iterations 4 --metal-modes resident,e2e --memory-stats
```

`--memory-stats` prints process resident memory and Darwin allocator bytes/block counts before input allocation, after input allocation, and after each size. RSS is operating-system resident memory; allocator bytes and blocks come from `malloc_zone_statistics`. Treat both as benchmark-process diagnostics, not exact per-call allocation counts.

Machine-readable benchmark report:

```sh
swift run -c release blake3-bench --sizes 16m,64m --iterations 4 --metal-modes resident,e2e --json-output benchmarks/results/local.json
```

`--json-output` writes schema version, command line, environment metadata, requested sizes, per-row raw nanosecond samples, throughput statistics, correctness, sustained summaries, and optional memory samples. Treat the JSON as the comparison artifact; Markdown tables are for quick review.

Validate a JSON report before publishing it:

```sh
swift run -c release blake3-bench --validate-json benchmarks/results/local.json
```

The fixture scripts run this validation automatically. Validation fails for malformed reports, failed correctness rows, missing scalar baselines, empty sample sets, nonfinite throughput values, invalid digest strings, missing sustained rows when sustained timing was requested, or missing memory samples when `--memory-stats` was requested.

Precompiled Metal library run:

```sh
swift run -c release blake3-bench --sizes 16m,64m --iterations 4 --metal-library /path/to/BLAKE3Metal.metallib --metal-modes resident,e2e
```

`--metal-library` uses `BLAKE3Metal.LibrarySource.metallib` for resident, staged, private, end-to-end, and Metal file modes. When omitted, the benchmark uses the runtime Metal source compiler. Publication artifacts should record the emitted `metalLibrary` value.

Metal gate and tiled-file tuning knobs:

```sh
swift run -c release blake3-bench --sizes 1m,16m,64m --metal-modes resident,staged,e2e --minimum-gpu-bytes 16m
swift run -c release blake3-bench --sizes 512m,1g --metal-modes none --file-modes metal-tiled-mmap --metal-tile-size 64m
```

`--minimum-gpu-bytes` changes the benchmark context's `.automatic` CPU/GPU gate and is recorded as `metal_minimum_gpu_byte_count` in JSON output. It does not affect explicit `*-gpu` rows. `--metal-tile-size` changes the tiled Metal mapped-file tile size and is recorded as `metal_tile_byte_count`.

Metal autotune command:

```sh
swift run -c release blake3-bench \
  --autotune-metal \
  --autotune-sizes 16m,64m \
  --autotune-iterations 3 \
  --autotune-gates 1m,4m,16m,64m \
  --autotune-metal-modes resident,staged,private-staged,e2e,private \
  --autotune-output benchmarks/results/autotune-metal.json
```

`--autotune-metal` runs correctness-checked measured sweeps and emits recommendations based on geometric mean throughput across requested sizes. It currently recommends `minimum_gpu_bytes` and the fastest measured Metal mode for the selected timing classes. Add `--autotune-file-tiles --autotune-tile-sizes 8m,16m,32m,64m` when tiled file tile-size recommendations are needed. Validate the emitted report with:

```sh
swift run -c release blake3-bench --validate-autotune-json benchmarks/results/autotune-metal.json
```

Autotune recommendations are device, OS, Swift, power, thermal, and Metal-library-source specific. They are inputs to constant selection, not release claims by themselves.

Primary publication sweep:

```sh
swift run -c release blake3-bench --sizes 16m,64m,256m,512m,1g --iterations 8 --metal-modes resident,e2e
```

Resident plus staged plus wrapped plus end-to-end diagnostic sweep:

```sh
swift run -c release blake3-bench --sizes 16m,64m,256m,512m,1g --iterations 8 --metal-modes resident,staged,wrapped,e2e
```

Private upload diagnostic sweep:

```sh
swift run -c release blake3-bench --sizes 16m,64m,256m,512m,1g --iterations 8 --metal-modes private,private-staged
```

File application-path sweep:

```sh
swift run -c release blake3-bench --sizes 16m,64m,256m,512m,1g --iterations 4 --metal-modes none --file-modes read,mmap,mmap-parallel,metal-mmap
```

Shared versus private resident sweep:

```sh
swift run -c release blake3-bench --sizes 512m,1g --iterations 8 --metal-modes resident,private
```

Sustained resident GPU run:

```sh
swift run -c release blake3-bench --sizes 512m,1g --iterations 4 --sustained-seconds 120 --sustained-mode resident --sustained-policy gpu
```

Sustained end-to-end GPU run:

```sh
swift run -c release blake3-bench --sizes 512m --iterations 4 --metal-modes e2e --sustained-seconds 120 --sustained-mode e2e --sustained-policy gpu
```

Sustained output reports total average throughput, per-iteration min/median/p95/max, and first-quarter versus last-quarter average throughput. A stable last-quarter value is more meaningful than a single best sample.

Sustained staged GPU run:

```sh
swift run -c release blake3-bench --sizes 512m --iterations 4 --metal-modes staged --sustained-seconds 60 --sustained-mode staged --sustained-policy gpu
```

Sustained wrapped GPU run:

```sh
swift run -c release blake3-bench --sizes 512m --iterations 4 --metal-modes wrapped --sustained-seconds 60 --sustained-mode wrapped --sustained-policy gpu
```

Sustained private-resident GPU run:

```sh
swift run -c release blake3-bench --sizes 1g --iterations 4 --metal-modes private --sustained-seconds 30 --sustained-mode private --sustained-policy gpu
```

## Current Apple M4 observations

Best clean full diagnostic sweep measured on April 17, 2026 with an Apple M4 using:

```sh
swift run -c release blake3-bench --sizes 16m,64m,256m,512m,1g --iterations 8 --metal-modes resident,staged,wrapped,e2e
```

The benchmark output table has these columns:

- size
- backend
- mode
- median GiB/s
- min GiB/s
- p95 GiB/s
- max GiB/s
- correctness status

Primary publication table from:

```sh
swift run -c release blake3-bench --sizes 16m,64m,256m,512m,1g --iterations 8 --metal-modes resident,staged,wrapped,e2e
```

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16 MiB | CPU | serial | 2.15 | 2.07 | 2.17 | 2.17 | ok |
| 16 MiB | CPU | parallel | 8.15 | 6.19 | 11.64 | 11.64 | ok |
| 16 MiB | Metal | resident-gpu | 18.46 | 7.40 | 23.31 | 23.31 | ok |
| 16 MiB | Metal | staged-gpu | 13.18 | 7.65 | 16.34 | 16.34 | ok |
| 16 MiB | Metal | e2e-gpu | 7.99 | 5.89 | 8.74 | 8.74 | ok |
| 64 MiB | CPU | serial | 2.16 | 2.15 | 2.17 | 2.17 | ok |
| 64 MiB | CPU | parallel | 11.53 | 10.85 | 12.94 | 12.94 | ok |
| 64 MiB | Metal | resident-gpu | 36.05 | 25.64 | 50.43 | 50.43 | ok |
| 64 MiB | Metal | staged-gpu | 19.36 | 16.42 | 21.13 | 21.13 | ok |
| 64 MiB | Metal | e2e-gpu | 10.05 | 9.15 | 11.05 | 11.05 | ok |
| 256 MiB | CPU | serial | 2.15 | 2.09 | 2.15 | 2.15 | ok |
| 256 MiB | CPU | parallel | 12.70 | 11.92 | 13.26 | 13.26 | ok |
| 256 MiB | Metal | resident-gpu | 57.15 | 44.99 | 62.41 | 62.41 | ok |
| 256 MiB | Metal | staged-gpu | 20.14 | 18.60 | 22.87 | 22.87 | ok |
| 256 MiB | Metal | e2e-gpu | 10.70 | 10.34 | 10.97 | 10.97 | ok |
| 512 MiB | CPU | serial | 2.15 | 2.10 | 2.15 | 2.15 | ok |
| 512 MiB | CPU | parallel | 10.67 | 7.57 | 13.15 | 13.15 | ok |
| 512 MiB | Metal | resident-gpu | 58.21 | 53.24 | 67.16 | 67.16 | ok |
| 512 MiB | Metal | staged-gpu | 24.55 | 23.18 | 25.36 | 25.36 | ok |
| 512 MiB | Metal | e2e-gpu | 9.08 | 8.83 | 9.55 | 9.55 | ok |
| 1 GiB | CPU | serial | 2.16 | 2.14 | 2.17 | 2.17 | ok |
| 1 GiB | CPU | parallel | 14.20 | 14.01 | 14.47 | 14.47 | ok |
| 1 GiB | Metal | resident-gpu | 63.25 | 61.47 | 66.66 | 66.66 | ok |
| 1 GiB | Metal | staged-gpu | 22.88 | 22.59 | 23.49 | 23.49 | ok |
| 1 GiB | Metal | e2e-gpu | 8.68 | 4.11 | 10.05 | 10.05 | ok |

Wrapped diagnostic results from the same run:

| Size | Wrapped GPU median | Wrapped GPU min | Wrapped GPU p95 | Wrapped GPU max |
| ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 17.80 GiB/s | 16.25 GiB/s | 18.87 GiB/s | 18.87 GiB/s |
| 64 MiB | 34.46 GiB/s | 23.33 GiB/s | 35.66 GiB/s | 35.66 GiB/s |
| 256 MiB | 34.38 GiB/s | 31.91 GiB/s | 39.56 GiB/s | 39.56 GiB/s |
| 512 MiB | 36.71 GiB/s | 34.87 GiB/s | 38.18 GiB/s | 38.18 GiB/s |
| 1 GiB | 37.11 GiB/s | 36.51 GiB/s | 38.43 GiB/s | 38.43 GiB/s |

The resident number is the pre-created shared-buffer hash path. The staged number includes copying Swift bytes into a reusable Metal-owned shared buffer before hashing. The wrapped number includes creating a no-copy Metal wrapper over existing Swift storage. The end-to-end number includes allocating a fresh shared `MTLBuffer` and copying from the Swift byte array each iteration. Because this is Apple Silicon unified memory, this is not a PCIe transfer benchmark, but the allocation and copy are real host-side work.

The Metal context also reuses a shared parameter buffer for chunk and parent dispatch parameters. Each dispatch in a command buffer gets a distinct 256-byte parameter slot, avoiding `setBytes` copies while preventing later dispatches from seeing mutated parameter data.

A lower 16-CV parent reduction threshold was tested at 64K chunks after adding the 1 GiB sweep. It regressed the 256 MiB and 1 GiB resident paths, so the gate remains at 512K chunks.

A broad 4-SIMD-group dispatch gate at 256K grid threads was also tested and rejected because it hurt 512 MiB resident throughput. The retained dispatch rule applies 4 SIMD-groups per threadgroup only at grids of at least 1,048,576 threads, matching the first chunk pass for a 1 GiB input. Smaller grids keep the prior 8-SIMD-group threadgroup shape.

The final tree step now uses fused `root3` and `root4` kernels. These combine the last 3-CV or 4-CV parent reduction and root digest into one Metal dispatch, preserving the BLAKE3 tree shape while removing the separate final parent pass for those terminal states.

A 4-CV parent reducer was added as a middle tier between binary parent reduction and the 16-CV wide reducer. It reduces 4 CVs to 1 CV in a single thread, which preserves the exact BLAKE3 tree while replacing two binary reduction dispatches with one dispatch. The retained gate is 32K CVs: a 16K-CV gate was tested and rejected because it hurt 16-32 MiB workloads, while the 32K gate keeps 16 MiB on the binary path and lets 32 MiB and larger workloads use the 4-CV path. This reducer is tail-aware: for 4N+1, 4N+2, and 4N+3 CV counts, it emits the same carried or partially reduced tail that two binary parent passes would have emitted.

A separate tail-aware 16-CV reducer was added for large tree levels that are not multiples of 16. Exact multiples still use the original `parent16` kernel. Non-multiple large levels use the tail-aware variant, which reduces each full 16-CV group and reduces the remaining 1-15 CV tail inside one thread, matching four binary parent passes. This targets file-like sizes such as 512 MiB + 3 KiB or 1 GiB + 3 KiB without risking the exact 512 MiB/1 GiB hot path.

Speculative optimizations tested:

- `root8`/`root16` tail-fusion kernels: promising in some focused samples, but median behavior was inconsistent and could drag down 64-256 MiB runs.
- an exact 8-CV parent reducer: correct, but rejected after a same-session control showed it regressed the important 64-512 MiB resident/private cases versus the existing 4-CV/16-CV reducer mix.
- a dedicated aligned full-chunk kernel: retained for aligned full-chunk ranges up to 64 MiB, where it improves medium resident/private samples; larger ranges continue using the generic full-chunk kernel because large resident sweeps were less stable with the specialized variant.
- a combined private-staged upload+hash command buffer: retained through 16 MiB, where it beat the split path in same-session checks; 64 MiB and larger inputs keep the split upload-then-hash sequence because it measured faster on the M4 validation host.
- a fused chunk-pair first parent pass: it produced correct tree-shaped output, but making each GPU thread hash two chunks plus one parent reduced occupancy enough that the unfused path remained better at 256 MiB and 1 GiB in the same-session control run.

The benchmark size formatter now preserves close tail sizes, for example `32 MiB + 3 KiB` and `1 GiB + 3 KiB`, instead of collapsing them into the same rounded MiB/GiB label. Use exact byte sizes when benchmarking tail behavior.

A separate resident/e2e sweep in the same session observed a 512 MiB resident GPU best sample of 71.24 GiB/s. Treat that as a peak resident result, not a sustained or copy-inclusive result.

Post-fusion resident validation from:

```sh
swift run -c release blake3-bench --sizes 16m,64m,256m,512m,1g --iterations 8 --metal-modes resident
```

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16 MiB | Metal | resident-gpu | 18.07 | 5.15 | 22.78 | 22.78 | ok |
| 64 MiB | Metal | resident-gpu | 36.87 | 25.03 | 45.20 | 45.20 | ok |
| 256 MiB | Metal | resident-gpu | 56.58 | 50.73 | 64.51 | 64.51 | ok |
| 512 MiB | Metal | resident-gpu | 55.60 | 51.64 | 61.91 | 61.91 | ok |
| 1 GiB | Metal | resident-gpu | 64.67 | 57.51 | 70.28 | 70.28 | ok |

The same resident-only run reported 1 GiB `resident-auto` at 68.74 GiB/s median with a 72.21 GiB/s max sample. The forced-GPU and automatic policy rows are both correct; publication should prefer forced-GPU when making a GPU-specific claim.

Shared versus private resident check:

```sh
swift run -c release blake3-bench --sizes 512m,1g --iterations 8 --metal-modes resident,private
```

Observed result:

| Size | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| 512 MiB | resident-gpu | 56.52 | 47.43 | 63.42 | 63.42 | ok |
| 512 MiB | private-gpu | 59.18 | 52.76 | 62.28 | 62.28 | ok |
| 1 GiB | resident-gpu | 66.01 | 57.17 | 72.34 | 72.34 | ok |
| 1 GiB | private-gpu | 68.02 | 61.51 | 74.34 | 74.34 | ok |

Sustained resident GPU check:

```sh
swift run -c release blake3-bench --sizes 512m --iterations 4 --sustained-seconds 120 --sustained-mode resident --sustained-policy gpu
```

Observed result:

- 512 MiB resident GPU for 120.0 seconds: average 35.35 GiB/s, median 45.35 GiB/s, max 74.53 GiB/s, first-quarter average 43.48 GiB/s, last-quarter average 40.13 GiB/s.

Post-fusion 30-second sustained resident GPU check:

```sh
swift run -c release blake3-bench --sizes 512m,1g --iterations 2 --metal-modes resident --sustained-seconds 30 --sustained-mode resident --sustained-policy gpu
```

Observed result:

- 512 MiB resident GPU for 30.0 seconds: average 43.20 GiB/s, median 45.03 GiB/s, p95 50.10 GiB/s, max 71.43 GiB/s, first-quarter average 42.94 GiB/s, last-quarter average 44.57 GiB/s.
- 1 GiB resident GPU for 30.0 seconds: average 48.49 GiB/s, median 49.91 GiB/s, p95 52.92 GiB/s, max 72.48 GiB/s, first-quarter average 47.49 GiB/s, last-quarter average 48.95 GiB/s.

Sustained end-to-end GPU check:

```sh
swift run -c release blake3-bench --sizes 512m --iterations 4 --metal-modes e2e --sustained-seconds 60 --sustained-mode e2e --sustained-policy gpu
```

Observed result:

- 512 MiB end-to-end GPU for 60.0 seconds: average 6.27 GiB/s, median 6.60 GiB/s, max 9.36 GiB/s, first-quarter average 7.24 GiB/s, last-quarter average 5.97 GiB/s.

Sustained staged GPU check:

```sh
swift run -c release blake3-bench --sizes 512m --iterations 4 --metal-modes staged --sustained-seconds 60 --sustained-mode staged --sustained-policy gpu
```

Observed result:

- 512 MiB staged GPU for 60.0 seconds: average 18.30 GiB/s, median 18.45 GiB/s, p95 20.86 GiB/s, max 25.03 GiB/s, first-quarter average 17.83 GiB/s, last-quarter average 18.55 GiB/s.

After adding reusable Metal parameter buffers:

- 512 MiB staged GPU for 60.0 seconds: average 19.05 GiB/s, median 18.91 GiB/s, p95 23.68 GiB/s, max 25.69 GiB/s, first-quarter average 18.81 GiB/s, last-quarter average 20.15 GiB/s.

Sustained wrapped GPU check:

```sh
swift run -c release blake3-bench --sizes 512m --iterations 4 --metal-modes wrapped --sustained-seconds 60 --sustained-mode wrapped --sustained-policy gpu
```

Observed result:

- 512 MiB wrapped GPU for 60.0 seconds: average 26.35 GiB/s, median 26.68 GiB/s, max 41.18 GiB/s, first-quarter average 27.22 GiB/s, last-quarter average 24.15 GiB/s.

Sustained private-resident GPU check:

```sh
swift run -c release blake3-bench --sizes 1g --iterations 4 --metal-modes private --sustained-seconds 30 --sustained-mode private --sustained-policy gpu
```

Observed result:

- 1 GiB private-resident GPU for 30.0 seconds: average 66.64 GiB/s, median 66.57 GiB/s, p95 73.51 GiB/s, max 75.93 GiB/s, first-quarter average 66.02 GiB/s, last-quarter average 66.74 GiB/s.

Conclusion: the 70+ GiB/s results are real peak resident-buffer results, not full Swift-bytes-to-digest results. Shared-buffer sustained resident behavior does not hold at the peak rate; the latest 30-second post-fusion shared-resident run settled at 44.57 GiB/s last-quarter average for 512 MiB and 48.95 GiB/s last-quarter average for 1 GiB. The private-resident path is stronger for already-private GPU data, with the latest 1 GiB private-resident sustained run holding a 66.74 GiB/s last-quarter average and reaching a 75.93 GiB/s max sample. The staged path removes per-call Metal input allocation and raised the 512 MiB Swift-owned copy-plus-hash median to 24.55 GiB/s in the best clean full sweep, versus 9.08 GiB/s for fresh copy-based end-to-end. Fresh copy-based end-to-end throughput is still dominated by shared-buffer allocation/copy and remains around 6-10 GiB/s for large inputs.

## Research notes

- The official BLAKE3 implementation describes BLAKE3 as highly parallelizable across threads and SIMD lanes because it is a Merkle tree internally: https://github.com/BLAKE3-team/BLAKE3
- Apple's Metal best practices recommend creating persistent objects early, reusing command queues and pipeline states, and allocating resource storage up front rather than creating new resources in the hot loop: https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/PersistentObjects.html
- Apple's Metal buffer documentation distinguishes `makeBuffer(bytes:)`, which copies into a new storage allocation, from `makeBuffer(bytesNoCopy:)`, which wraps existing storage without allocating new storage: https://developer-rno.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Mem-Obj/Mem-Obj.html
