# BLAKE3Swift Industry Benchmark Summary

Date: 2026-04-17
Commit: d3fd271fda4054b9ded3d5f5aa9f02d3bc7e8a49
Host: Apple M4, Mac16,12, 4 performance cores, 10 active CPUs
OS: macOS 26.5 build 25F5042g
Swift: Apple Swift 6.3, target arm64-apple-macosx26.0
Metal: Apple M4, runtime-source library compilation

## Scope

This pass used release builds, raw sample JSON, median/min/p95/max reporting, correctness checks on every measured row, JSON validation after each benchmark, and 120-second sustained resident GPU windows for large inputs.

Correctness gate before benchmarking:

```sh
swift test && swift build -c release
```

Result: 30 XCTest cases passed with 0 failures, then the release build completed.

Primary benchmark commands:

```sh
OUT_DIR=benchmarks/results/20260417T170231Z-industry-publication MEMORY_STATS=1 benchmarks/run-publication.sh

swift run -c release blake3-bench \
  --sizes 16m,64m,256m,512m,1g \
  --iterations 8 \
  --metal-modes resident,staged,wrapped,e2e,private,private-staged \
  --file-modes none \
  --memory-stats \
  --json-output benchmarks/results/20260417T170451Z-industry-metal-diagnostics/metal-diagnostics.json

OUT_DIR=benchmarks/results/20260417T170549Z-industry-sustained-resident-120s \
  SIZES=512m,1g ITERATIONS=2 DURATION_SECONDS=120 \
  SUSTAINED_MODE=resident SUSTAINED_POLICY=gpu MEMORY_STATS=1 \
  benchmarks/run-sustained.sh
```

## Publication Sweep

The table reports median GiB/s. Full raw samples, min, p95, max, digests, and memory snapshots are in the JSON artifacts.

| Size | CPU scalar | CPU parallel | CPU context | Metal resident GPU | Metal end-to-end GPU |
| --- | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 1.08 | 4.08 | 4.06 | 20.60 | 6.75 |
| 64 MiB | 1.08 | 4.10 | 4.13 | 44.80 | 8.95 |
| 256 MiB | 1.08 | 4.22 | 4.21 | 53.64 | 9.67 |
| 512 MiB | 1.08 | 4.22 | 4.21 | 55.44 | 10.04 |
| 1 GiB | 1.08 | 3.78 | 3.86 | 68.99 | 9.86 |

All publication rows were correct and `cpu-metal-publication.json` validated successfully.

## Metal Diagnostic Sweep

These are separate timing classes and should not be collapsed into a single claim. The table reports median GiB/s for the large sizes.

| Size | Resident GPU | Private GPU | Staged GPU | Private staged GPU | Wrapped GPU | End-to-end GPU |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 512 MiB | 74.75 | 69.42 | 24.04 | 14.59 | 40.92 | 9.81 |
| 1 GiB | 70.75 | 69.68 | 22.13 | 14.24 | 35.64 | 9.32 |

All diagnostic rows were correct and `metal-diagnostics.json` validated successfully.

## File Sweep

The table reports median GiB/s. File timings include open/stat, read or mmap, selected hash strategy, digest extraction, and cleanup. Benchmark file creation is excluded.

| Size | Read | mmap | mmap parallel | Metal mmap GPU | Metal tiled mmap GPU |
| --- | ---: | ---: | ---: | ---: | ---: |
| 256 MiB | 1.02 | 1.04 | 3.34 | 7.02 | 4.16 |
| 512 MiB | 1.02 | 1.04 | 3.34 | 7.23 | 4.45 |
| 1 GiB | 1.02 | 1.04 | 3.34 | 8.08 | 4.89 |

All file rows were correct and `file-publication.json` validated successfully.

## Sustained Resident GPU

The sustained pass used 120-second windows and reports GiB/s.

| Size | Avg | Median | Min | P95 | Max | First 25% | Last 25% | Iterations | Correct |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 512 MiB | 62.62 | 62.43 | 23.64 | 72.37 | 76.36 | 64.46 | 63.04 | 15029 | ok |
| 1 GiB | 52.64 | 53.21 | 34.10 | 63.34 | 72.05 | 55.77 | 52.57 | 6318 | ok |

The sustained JSON validated successfully.

## Interpretation

CPU throughput is stable near 1.08 GiB/s scalar and near 4.2 GiB/s for the parallel/context paths on this M4. Metal resident/private paths are the high-throughput engine paths, reaching roughly 69-75 GiB/s in the large diagnostic sweep. Swift-owned end-to-end Metal input is much lower, roughly 9-12 GiB/s, because it includes per-call shared buffer allocation/copy. File hashing is bounded by the full file path: mmap-parallel reaches about 3.34 GiB/s at large sizes, Metal mmap reaches about 8.08 GiB/s at 1 GiB, and tiled Metal mmap reaches about 4.89 GiB/s at 1 GiB.

The 120-second resident GPU run stayed correct, but 1 GiB sustained throughput dropped from a 55.77 GiB/s first-quarter average to 52.57 GiB/s in the last quarter. Publish sustained numbers separately from short resident samples.

## Artifacts

- Publication environment: `benchmarks/results/20260417T170231Z-industry-publication/environment.txt`
- CPU/Metal publication: `benchmarks/results/20260417T170231Z-industry-publication/cpu-metal-publication.md`
- CPU/Metal raw samples: `benchmarks/results/20260417T170231Z-industry-publication/cpu-metal-publication.json`
- File publication: `benchmarks/results/20260417T170231Z-industry-publication/file-publication.md`
- File raw samples: `benchmarks/results/20260417T170231Z-industry-publication/file-publication.json`
- Metal diagnostic environment: `benchmarks/results/20260417T170451Z-industry-metal-diagnostics/environment.txt`
- Metal diagnostics: `benchmarks/results/20260417T170451Z-industry-metal-diagnostics/metal-diagnostics.md`
- Metal diagnostic raw samples: `benchmarks/results/20260417T170451Z-industry-metal-diagnostics/metal-diagnostics.json`
- Sustained environment: `benchmarks/results/20260417T170549Z-industry-sustained-resident-120s/environment.txt`
- Sustained output: `benchmarks/results/20260417T170549Z-industry-sustained-resident-120s/sustained-resident.md`
- Sustained raw samples: `benchmarks/results/20260417T170549Z-industry-sustained-resident-120s/sustained-resident.json`

