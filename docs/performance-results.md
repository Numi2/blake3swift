# Performance Results

This file records candidate public performance data after sustained measurements have been collected. Treat these numbers as hardware-specific observations, not universal guarantees.

## Measurement Rules

- Keep resident, staged, wrapped, private, end-to-end, file, and sustained timing classes separate.
- Report median, min, p95, max, and correctness for sweep rows.
- Report average, median, min, p95, max, first-quarter, last-quarter, iteration count, and correctness for sustained rows.
- Keep raw benchmark output and `environment.txt` from `benchmarks/run-publication.sh` or `benchmarks/run-sustained.sh` with release artifacts.
- Do not present a single best sample as sustained throughput.

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

## File Publication Status

File timing rows must be regenerated with:

```sh
benchmarks/run-publication.sh
```

Publish file tables only from raw `file-publication.md` output. File modes include file open/stat, mapping or read loop, selected hashing strategy, digest extraction, cleanup, and correctness. Benchmark fixture file creation is excluded from timed rows.
