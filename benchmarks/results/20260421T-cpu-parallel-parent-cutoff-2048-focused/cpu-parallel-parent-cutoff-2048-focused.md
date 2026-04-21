# CPU Parallel Parent Cutoff 2048 Focused

Date: 2026-04-21

Command:

```sh
./.build/release/blake3-bench \
  --sizes 64m,256m,512m,1g \
  --iterations 7 \
  --metal-modes none \
  --cryptokit-modes none \
  --cpu-workers 10 \
  --json-output benchmarks/results/20260421T-cpu-parallel-parent-cutoff-2048-focused/report.json
./.build/release/blake3-bench \
  --validate-json benchmarks/results/20260421T-cpu-parallel-parent-cutoff-2048-focused/report.json
```

Summary:

- This focused follow-up reruns the lowered `parallelParentMinCount = 2_048` configuration on the larger CPU publication sizes with an explicit `10` workers and more iterations.
- It confirms that the new parent-reduction cutoff is a real large-input CPU win and recovers the `64 MiB` CPU-parallel row that stayed noisy in the broad sweep.

Validated median GiB/s:

| Input | Official C one-shot | Swift scalar | Swift SIMD4 | Swift CPU parallel-10 | CPU context-auto | Swift `BLAKE3.hash(input)` |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 64 MiB | 2.23 | 1.17 | 1.86 | 11.77 | 11.71 | 14.68 |
| 256 MiB | 2.22 | 1.17 | 1.81 | 12.10 | 12.27 | 40.01 |
| 512 MiB | 2.20 | 1.17 | 1.80 | 12.27 | 12.29 | 58.10 |
| 1 GiB | 2.20 | 1.17 | 1.79 | 12.34 | 12.27 | 59.38 |

Notes:

- `report.json` validated successfully.
- `output.md` preserves the raw benchmark table emitted by the benchmark harness.
- The public automatic row remained much noisier than the explicit CPU-parallel row, so this focused artifact is promoted for CPU scheduler claims rather than as a new all-purpose default-auto reference.
