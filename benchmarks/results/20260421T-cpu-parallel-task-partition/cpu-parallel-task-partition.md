# CPU Parallel Task Partition

Date: 2026-04-21

Command:

```sh
./.build/release/blake3-bench \
  --sizes 16m,64m,256m,512m,1g \
  --iterations 5 \
  --metal-modes none \
  --cryptokit-modes none \
  --json-output benchmarks/results/20260421T-cpu-parallel-task-partition/report.json
./.build/release/blake3-bench \
  --validate-json benchmarks/results/20260421T-cpu-parallel-task-partition/report.json
```

Summary:

- This artifact promotes finer-grained CPU task partitioning for chunk-CV generation and parent reduction instead of assigning one fixed range per worker.
- The change improves the promoted Swift CPU-parallel path and the default Swift `BLAKE3.hash(input)` path without changing the apples-to-apples serial SIMD baseline materially.

Validated median GiB/s:

| Input | Official C one-shot | Swift scalar | Swift SIMD4 | Swift CPU parallel | CPU context-auto | Swift `BLAKE3.hash(input)` |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 2.16 | 1.14 | 1.71 | 9.72 | 9.74 | 9.23 |
| 64 MiB | 2.16 | 1.15 | 1.75 | 10.83 | 10.86 | 22.01 |
| 256 MiB | 2.15 | 1.15 | 1.75 | 11.30 | 11.27 | 41.18 |
| 512 MiB | 2.17 | 1.13 | 1.75 | 11.52 | 11.54 | 47.84 |
| 1 GiB | 2.17 | 1.15 | 1.75 | 11.57 | 11.75 | 47.13 |

Notes:

- `report.json` validated successfully.
- `output.md` preserves the raw benchmark table emitted by the benchmark harness.
