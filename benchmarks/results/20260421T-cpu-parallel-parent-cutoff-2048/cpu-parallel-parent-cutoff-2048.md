# CPU Parallel Parent Cutoff 2048

Date: 2026-04-21

Command:

```sh
./.build/release/blake3-bench \
  --sizes 16m,64m,256m,512m,1g \
  --iterations 5 \
  --metal-modes none \
  --cryptokit-modes none \
  --json-output benchmarks/results/20260421T-cpu-parallel-parent-cutoff-2048/report.json
./.build/release/blake3-bench \
  --validate-json benchmarks/results/20260421T-cpu-parallel-parent-cutoff-2048/report.json
```

Summary:

- This follow-up keeps the promoted CPU task-partition retune and lowers `parallelParentMinCount` from `4_096` to `2_048`, allowing parent reduction to stay parallel slightly deeper into the tree.
- On the local M4, that change improved the `256 MiB` to `1 GiB` CPU-parallel and CPU-context rows again while keeping the apples-to-apples serial CPU baseline in its usual band.

Validated median GiB/s:

| Input | Official C one-shot | Swift scalar | Swift SIMD4 | Swift CPU parallel | CPU context-auto | Swift `BLAKE3.hash(input)` |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 2.27 | 1.17 | 1.84 | 10.39 | 10.04 | 9.30 |
| 64 MiB | 2.24 | 1.17 | 1.80 | 10.83 | 11.79 | 14.62 |
| 256 MiB | 2.21 | 1.17 | 1.80 | 12.38 | 12.20 | 46.19 |
| 512 MiB | 2.20 | 1.17 | 1.79 | 12.42 | 12.34 | 58.27 |
| 1 GiB | 2.20 | 1.17 | 1.79 | 12.38 | 12.30 | 59.40 |

Notes:

- `report.json` validated successfully.
- `output.md` preserves the raw benchmark table emitted by the benchmark harness.
- The `64 MiB` CPU-parallel row remained weaker than the later focused rerun, so the broad artifact is best treated as the all-size reference rather than the final promoted large-input CPU-parallel table.
