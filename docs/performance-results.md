# Performance Results

This file records candidate public performance data after sustained measurements have been collected. Treat these numbers as hardware-specific observations, not universal guarantees.

## Measurement Rules

- Keep resident, staged, wrapped, private, end-to-end, file, and sustained timing classes separate.
- Report median, min, p95, max, and correctness for sweep rows.
- Report average, median, min, p95, max, first-quarter, last-quarter, iteration count, and correctness for sustained rows.
- Keep raw Markdown output, JSON reports, and `environment.txt` from `benchmarks/run-publication.sh` or `benchmarks/run-sustained.sh` with release artifacts.
- Record whether Metal rows used `runtime-source` or a packaged `.metallib`.
- Do not present a single best sample as sustained throughput.

## April 19, 2026 Fused Tile Overhead-Focused Run

Current focused copy/no-copy overhead artifact:

```sh
benchmarks/results/20260419T100143Z-overhead-focused
```

Environment: Apple M4, Mac16,12, 10 active CPUs, macOS 26.5 build 25F5042g, Swift 6.3, runtime Metal source, working tree dirty with the fused-tile changes in this branch.

The table reports median GiB/s from validated JSON. The `staged-gpu` row includes copying Swift bytes into a reused shared Metal buffer plus hashing. The `wrapped-gpu` row includes no-copy Metal buffer wrapping plus hashing. Repeated allocation/copy `e2e` rows are preserved in the artifact but are allocator-sensitive and are not used as the headline overhead claim.

| Input | Official C one-shot | Swift CPU parallel | Default `BLAKE3.hash` | Metal staged GPU | Metal wrapped GPU | Metal resident GPU |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 256 MiB | 2.28 | 10.58 | 42.96 | 24.08 | 55.62 | 68.26 |
| 512 MiB | 2.24 | 11.18 | 51.09 | 25.84 | 55.19 | 80.53 |
| 1 GiB | 2.20 | 11.33 | 54.18 | 24.76 | 54.05 | 76.80 |

Subsequent ping-pong fused-tile sanity artifact:

```sh
benchmarks/results/20260419T105700Z-pingpong-rested-sanity
```

This targeted confirmation uses the new default `128`-chunk double-scratch ping-pong fused tile reduction. It is not a replacement publication table because an immediate full all-size rerun was thermally contaminated, but the validated rested sanity check kept the large overhead modes in the expected band: 512 MiB resident/staged/wrapped medians of 75.08/23.79/47.77 GiB/s and 1 GiB resident/staged/wrapped medians of 71.25/23.68/43.28 GiB/s.

A later ping-pong cleanup writes the final tile CV directly to the output buffer instead of copying it back through scratch memory. Correctness and JSON smoke validation passed, but the available same-session timing run was throttled across CPU and GPU baselines and was not promoted as a new headline table.

Follow-up experiments kept out of the default:

- The original in-place `BLAKE3_SWIFT_METAL_FUSED_TILE_CHUNKS=128` and `256` settings were close, but the 128-chunk ping-pong reduction had the better overall 256 MiB to 1 GiB overhead-mode geometric mean and is now the default.
- `512` and `1024` fused tiles are correct and available as tuning options, but were weaker in the no-copy wrapped path on the local M4.
- A CPU-finalize-after-fused-tiles prototype did not beat the all-GPU finalization path.
- Lowering the 4-way parent reduction threshold from 32K CVs to 1K CVs regressed large-buffer throughput.
- Re-testing lower 4-way parent reduction thresholds after the ping-pong tile change still did not produce a durable overhead-mode win; the 32K-CV threshold remains.
- Adding `madvise` read-ahead hints to mmap file hashing regressed the local Metal file benchmark and was removed.
- Explicit unroll pragmas in the full-chunk Metal loop regressed large-buffer throughput and were removed.
- Root8/root16 one-dispatch final digest kernels were correct, but not a durable win across staged/wrapped overhead modes, so the root2/3/4 path remains.

A full all-mode/file fixture was also generated at `benchmarks/results/20260419T100143Z`. Its JSON validated, but late 1 GiB `e2e` and file rows were noisy after all large modes ran back-to-back.

## April 19, 2026 Head Publication Run

Prior full publication artifact:

```sh
OUT_DIR=benchmarks/results/20260419T074508Z-head-publication benchmarks/run-publication.sh
```

Environment: Apple M4, Mac16,12, 10 active CPUs, macOS 26.5 build 25F5042g, Swift 6.3, runtime Metal source, commit `a210ae4ed0f1124cfd88b99e47a5ec9ca1555943`.

The table reports median GiB/s from validated JSON. The official C row is the vendored in-process one-shot comparator. The best resident/private Metal row excludes Swift input allocation and upload, and should not be compared as a full bytes-to-digest path.

| Input | Official C one-shot | Swift CPU parallel | Default `BLAKE3.hash` | Metal end-to-end GPU | Best resident/private Metal row |
| --- | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 2.27 | 8.85 | 7.86 | 6.77 | 17.88 |
| 64 MiB | 2.22 | 9.22 | 14.95 | 8.62 | 38.25 |
| 256 MiB | 2.20 | 10.25 | 32.77 | 10.70 | 59.70 |
| 512 MiB | 2.18 | 10.70 | 31.06 | 10.52 | 61.50 |
| 1 GiB | 2.17 | 11.22 | 34.56 | 10.06 | 67.24 |

File-path timings from the same artifact:

| File input | CPU mmap parallel | Metal mmap GPU | Metal tiled mmap GPU |
| --- | ---: | ---: | ---: |
| 256 MiB | 5.86 | 7.35 | 5.28 |
| 512 MiB | 5.80 | 7.32 | 6.26 |
| 1 GiB | 5.81 | 8.27 | 6.81 |

External upstream CLI sanity check from `upstream-b3sum.txt` in the same artifact directory. This timing includes `b3sum` process startup, file open/mapping or reading, hashing, and stdout suppression, so it is not the same timing class as resident Metal:

| Command | 1 GiB warm-file median GiB/s |
| --- | ---: |
| `b3sum 1.8.4` default threading | 11.98 |
| `b3sum 1.8.4 --num-threads 1` | 1.89 |
| `b3sum 1.8.4 --no-mmap` | 1.91 |

## April 18, 2026 Default Dispatcher Check

Development check after enabling automatic large-input Metal dispatch for `BLAKE3.hash` and adding the 512-chunk fused shared-memory tile kernel:

```sh
swift run -c release blake3-bench \
  --sizes 16m,64m,256m \
  --iterations 5 \
  --metal-modes resident,wrapped,private \
  --file-modes none
```

This is a focused engineering check, not a publication run. The table reports median GiB/s.

| Size | CPU serial SIMD | CPU parallel | CPU context | `BLAKE3.hash` default | Metal wrapped GPU | Metal resident GPU | Metal private GPU |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 1.73 | 8.11 | 7.87 | 9.16 | 13.20 | 13.94 | 8.08 |
| 64 MiB | 1.72 | 8.79 | 9.20 | 21.74 | 24.45 | 31.84 | 41.32 |
| 256 MiB | 1.75 | 9.82 | 10.30 | 34.00 | 35.81 | 58.15 | 58.08 |

Interpretation: default one-shot hashing now tracks the no-copy Metal path for large unkeyed inputs and remains correct against the scalar digest. Private buffers skip the fused tile kernel by default because local M4 measurements favored the previous reduction path for private resident inputs.

## Apple M4 Candidate Sweep

Measured April 17, 2026 on Apple M4 from:

```sh
swift run -c release blake3-bench --sizes 16m,64m,256m,512m,1g --iterations 8 --metal-modes resident,staged,wrapped,e2e
```

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16 MiB | CPU | serial SIMD | 2.15 | 2.07 | 2.17 | 2.17 | ok |
| 16 MiB | CPU | parallel | 8.15 | 6.19 | 11.64 | 11.64 | ok |
| 16 MiB | Metal | resident GPU | 18.46 | 7.40 | 23.31 | 23.31 | ok |
| 16 MiB | Metal | end-to-end GPU | 7.99 | 5.89 | 8.74 | 8.74 | ok |
| 64 MiB | CPU | serial SIMD | 2.16 | 2.15 | 2.17 | 2.17 | ok |
| 64 MiB | CPU | parallel | 11.53 | 10.85 | 12.94 | 12.94 | ok |
| 64 MiB | Metal | resident GPU | 36.05 | 25.64 | 50.43 | 50.43 | ok |
| 64 MiB | Metal | end-to-end GPU | 10.05 | 9.15 | 11.05 | 11.05 | ok |
| 256 MiB | CPU | serial SIMD | 2.15 | 2.09 | 2.15 | 2.15 | ok |
| 256 MiB | CPU | parallel | 12.70 | 11.92 | 13.26 | 13.26 | ok |
| 256 MiB | Metal | resident GPU | 57.15 | 44.99 | 62.41 | 62.41 | ok |
| 256 MiB | Metal | end-to-end GPU | 10.70 | 10.34 | 10.97 | 10.97 | ok |
| 512 MiB | CPU | serial SIMD | 2.15 | 2.10 | 2.15 | 2.15 | ok |
| 512 MiB | CPU | parallel | 10.67 | 7.57 | 13.15 | 13.15 | ok |
| 512 MiB | Metal | resident GPU | 58.21 | 53.24 | 67.16 | 67.16 | ok |
| 512 MiB | Metal | end-to-end GPU | 9.08 | 8.83 | 9.55 | 9.55 | ok |
| 1 GiB | CPU | serial SIMD | 2.16 | 2.14 | 2.17 | 2.17 | ok |
| 1 GiB | CPU | parallel | 14.20 | 14.01 | 14.47 | 14.47 | ok |
| 1 GiB | Metal | resident GPU | 63.25 | 61.47 | 66.66 | 66.66 | ok |
| 1 GiB | Metal | end-to-end GPU | 8.68 | 4.11 | 10.05 | 10.05 | ok |

Staged and wrapped rows are diagnostic application-path data, not resident or end-to-end claims:

| Size | Staged GPU Median GiB/s | Wrapped GPU Median GiB/s |
| --- | ---: | ---: |
| 16 MiB | 13.18 | 17.80 |
| 64 MiB | 19.36 | 34.46 |
| 256 MiB | 20.14 | 34.38 |
| 512 MiB | 24.55 | 36.71 |
| 1 GiB | 22.88 | 37.11 |

## Sustained Apple M4 Candidate Runs

120-second resident GPU run from `benchmarks/results/20260417T155605Z-sustained-resident-120s`:

```sh
SIZES=512m,1g ITERATIONS=2 DURATION_SECONDS=120 SUSTAINED_MODE=resident SUSTAINED_POLICY=gpu MEMORY_STATS=1 benchmarks/run-sustained.sh
```

| Size | Mode | Duration | Average GiB/s | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | First 25% GiB/s | Last 25% GiB/s | Iterations | Correct |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 512 MiB | resident GPU | 120 s | 54.97 | 55.78 | 28.39 | 69.00 | 75.71 | 62.29 | 50.20 | 13194 | ok |
| 1 GiB | resident GPU | 120 s | 45.36 | 48.03 | 4.37 | 54.06 | 68.46 | 47.77 | 45.08 | 5444 | ok |

Post-fusion 30-second sustained resident GPU check:

```sh
swift run -c release blake3-bench --sizes 512m,1g --iterations 2 --metal-modes resident --sustained-seconds 30 --sustained-mode resident --sustained-policy gpu
```

| Size | Mode | Duration | Average GiB/s | Median GiB/s | P95 GiB/s | Max GiB/s | First 25% GiB/s | Last 25% GiB/s | Correct |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 512 MiB | resident GPU | 30 s | 43.20 | 45.03 | 50.10 | 71.43 | 42.94 | 44.57 | ok |
| 1 GiB | resident GPU | 30 s | 48.49 | 49.91 | 52.92 | 72.48 | 47.49 | 48.95 | ok |

Private-resident 1 GiB sustained check:

```sh
swift run -c release blake3-bench --sizes 1g --iterations 4 --metal-modes private --sustained-seconds 30 --sustained-mode private --sustained-policy gpu
```

| Size | Mode | Duration | Average GiB/s | Median GiB/s | P95 GiB/s | Max GiB/s | First 25% GiB/s | Last 25% GiB/s | Correct |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1 GiB | private resident GPU | 30 s | 66.64 | 66.57 | 73.51 | 75.93 | 66.02 | 66.74 | ok |

## Apple M4 Autotune Runs

Default autotune artifact: `benchmarks/results/20260417T155523Z-autotune-default`.

| Category | Recommendation | Score GiB/s | Notes |
| --- | --- | ---: | --- |
| `minimum_gpu_bytes` | 4 MiB | 24.18 | Best geometric mean across 16 MiB and 64 MiB resident-auto measurements. |
| `mode` | private-gpu | 28.27 | Fastest forced-GPU timing class in this sweep; resident private-buffer data, not end-to-end throughput. |

Tiled-file autotune artifact: `benchmarks/results/20260417T155538Z-autotune-tiled-file`.

| Category | Recommendation | Score GiB/s | Notes |
| --- | --- | ---: | --- |
| `minimum_gpu_bytes` | 16 MiB | 53.65 | Best geometric mean across 512 MiB and 1 GiB resident-auto measurements. |
| `mode` | resident-gpu | 62.62 | Fastest forced-GPU timing class in this large-input sweep. |
| `tile_bytes` | 64 MiB | 4.07 | Best measured tiled Metal file tile size across 512 MiB and 1 GiB. |

## File Publication Status

File timing rows must be regenerated with:

```sh
benchmarks/run-publication.sh
```

Publish file tables only from raw `file-publication.md` output. File modes include file open/stat, mapping or read loop, selected hashing strategy, digest extraction, cleanup, and correctness. Benchmark fixture file creation is excluded from timed rows.
