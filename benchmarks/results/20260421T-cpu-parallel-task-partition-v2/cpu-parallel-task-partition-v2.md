# CPU Parallel Task Partition V2

Date: 2026-04-21

Command:

```sh
./.build/release/blake3-bench \
  --sizes 16m,64m,256m,512m,1g \
  --iterations 5 \
  --metal-modes none \
  --cryptokit-modes none \
  --json-output benchmarks/results/20260421T-cpu-parallel-task-partition-v2/report.json
./.build/release/blake3-bench \
  --validate-json benchmarks/results/20260421T-cpu-parallel-task-partition-v2/report.json
```

Summary:

- This follow-up keeps the promoted CPU task-partition design and retunes the constants to `parallelTasksPerWorker = 8` with `parallelChunkMinItemsPerTask = 16` and `parallelParentMinItemsPerTask = 16`.
- The retune improves the promoted Swift CPU-parallel path again, especially in the `256 MiB` to `1 GiB` band, while keeping the apples-to-apples serial baseline in its usual range.

Validated median GiB/s:

| Input | Official C one-shot | Swift scalar | Swift SIMD4 | Swift CPU parallel | CPU context-auto | Swift `BLAKE3.hash(input)` |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 2.18 | 1.14 | 1.73 | 10.06 | 10.03 | 9.70 |
| 64 MiB | 2.18 | 1.15 | 1.77 | 11.30 | 11.30 | 17.62 |
| 256 MiB | 2.17 | 1.15 | 1.76 | 11.82 | 11.88 | 45.93 |
| 512 MiB | 2.17 | 1.15 | 1.75 | 12.08 | 12.06 | 51.50 |
| 1 GiB | 2.17 | 1.15 | 1.76 | 12.05 | 12.01 | 34.30 |

Notes:

- `report.json` validated successfully.
- `output.md` preserves the raw benchmark table emitted by the benchmark harness.
- The public automatic row remained noisier than the CPU-parallel row because it still mixes CPU and automatic Metal dispatch behavior by size, so this artifact is promoted primarily for the CPU-parallel and CPU-context rows.
