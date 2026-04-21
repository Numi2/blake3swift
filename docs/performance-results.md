# Performance Results

This file records candidate public performance data after sustained measurements have been collected. Treat these numbers as hardware-specific observations, not universal guarantees.

## Measurement Rules

- Keep resident, staged, wrapped, private, end-to-end, file, and sustained timing classes separate.
- Report median, min, p95, max, and correctness for sweep rows.
- Report average, median, min, p95, max, first-quarter, last-quarter, iteration count, and correctness for sustained rows.
- Keep raw Markdown output, JSON reports, and `environment.txt` from `benchmarks/run-publication.sh` or `benchmarks/run-sustained.sh` with release artifacts.
- Record whether Metal rows used `runtime-source` or a packaged `.metallib`.
- Do not present a single best sample as sustained throughput.

## April 21, 2026 CPU One-Shot Reusable-Context Follow-Up

This pass stopped chasing the strict `single-simd` apples-to-apples CPU baseline and instead targeted the fastest Swift CPU one-shot execution model already exposed by the library: the parallel tree path.

Code change:

- `BLAKE3.hashCPU(_:)` now reuses a per-thread unkeyed `BLAKE3.Context` instead of rebuilding the parallel scheduler and chaining-value workspace on every call.
- `BLAKE3.hashParallel(_:maxWorkers:)` now uses the same per-thread reusable-context strategy, keyed by normalized worker count, so explicit worker-count calls no longer pay one-shot scheduler/workspace setup on each hash.

Focused benchmark commands:

```sh
./.build/release/blake3-bench --sizes 64m,256m,1g --iterations 5 --metal-modes none --cryptokit-modes none
./.build/release/blake3-bench --sizes 64m,256m,1g --iterations 5 --metal-modes none --cryptokit-modes none --cpu-workers 10
```

Representative validated medians from the same code state:

| Input | CPU parallel | CPU context-auto | CPU parallel-10 |
| --- | ---: | ---: | ---: |
| 64 MiB | 10.16 | 10.30 | 10.05 |
| 256 MiB | 10.72 | 10.53 | 9.97 |
| 1 GiB | 11.62 | 11.14 | 11.67 |

Interpretation:

- The public Swift CPU fast path is now firmly back in the `10+ GiB/s` band at `64 MiB` and `256 MiB`, and in the mid-`11 GiB/s` band at `1 GiB`, without changing the hashing algorithm or correctness surface.
- On this local M4, `10` workers remained the best explicit worker count for large inputs after rerunning the sweep cleanly; lower worker counts lost too much at `256 MiB` and `1 GiB`.
- The improvement is durable enough to keep in code, but it did not beat the existing promoted README CPU-parallel rows across all sizes cleanly enough to justify a README table rewrite from this run alone.

Follow-up refinement:

- The internal one-shot reuse path now uses a private thread-local scheduler/workspace holder instead of routing through the public `BLAKE3.Context` object, so the fast path no longer pays `Context`'s `NSLock` overhead when there is no cross-thread sharing.

Focused validation command:

```sh
./.build/release/blake3-bench --sizes 256m,512m,1g --iterations 5 --metal-modes none --cryptokit-modes none --cpu-workers 10
```

Validated medians from that follow-up:

| Input | CPU parallel-10 |
| --- | ---: |
| 256 MiB | 10.62 |
| 512 MiB | 11.45 |
| 1 GiB | 11.72 |

This follow-up kept the large-input row above the previous promoted `1 GiB` CPU-parallel README number and improved the `512 MiB` band as well, but `256 MiB` still did not clear the existing published median, so the README remained unchanged.

Rejected follow-ups from the same CPU track:

- Raising `parallelParentMinCount` from `4_096` to `16_384` regressed the medium and large parallel rows. A focused `256 MiB`, `512 MiB`, `1 GiB` `parallel-10` rerun fell to 9.42/10.85/11.38 GiB/s, so the higher cutoff was reverted.
- Slight worker oversubscription did not help. In a 7-iteration `256 MiB`, `512 MiB`, `1 GiB` sweep, `parallel-11` landed at 9.24/10.93/10.89 GiB/s and `parallel-12` at 9.68/10.18/11.58 GiB/s, both weaker overall than `parallel-10`.

## April 21, 2026 CPU Parallel Task Partition Promotion

Promoted artifact:

```sh
benchmarks/results/20260421T-cpu-parallel-task-partition
```

This follow-up keeps the lock-free thread-local CPU fast path and changes the internal CPU parallel scheduler shape: chunk-CV generation and parent reduction now split work into more tasks than workers, with minimum per-task work sizes, instead of handing one fixed range to each worker. On local Apple silicon this improves the medium and large CPU-parallel rows without changing the BLAKE3 tree shape or correctness contract.

Validated median GiB/s from `report.json`:

| Input | Official C one-shot | Swift scalar | Swift SIMD4 | Swift CPU parallel | CPU context-auto | Swift `BLAKE3.hash(input)` |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 2.16 | 1.14 | 1.71 | 9.72 | 9.74 | 9.23 |
| 64 MiB | 2.16 | 1.15 | 1.75 | 10.83 | 10.86 | 22.01 |
| 256 MiB | 2.15 | 1.15 | 1.75 | 11.30 | 11.27 | 41.18 |
| 512 MiB | 2.17 | 1.13 | 1.75 | 11.52 | 11.54 | 47.84 |
| 1 GiB | 2.17 | 1.15 | 1.75 | 11.57 | 11.75 | 47.13 |

Interpretation:

- `Swift CPU parallel` now clears the prior published CPU-parallel medians across the whole promoted size set.
- `Swift BLAKE3.hash(input)` improved materially at and above the 64 MiB threshold because the stronger CPU-parallel path feeds the automatic dispatcher before Metal takes over the larger sizes.
- The serial apples-to-apples baseline stayed in the same `~1.7` to `1.8 GiB/s` band, so this promotion is about the real Swift fast path, not a change in the fairness baseline.
- An early version of this experiment accidentally allowed the `maxWorkers == 1` path to split into parallel tasks; that bug was fixed before the promoted artifact was recorded.

## April 21, 2026 CPU Parallel Task Partition Retune

Promoted follow-up artifact:

```sh
benchmarks/results/20260421T-cpu-parallel-task-partition-v2
```

This retune keeps the same task-partition architecture but changes the constants to `parallelTasksPerWorker = 8` and `parallelChunkMinItemsPerTask = parallelParentMinItemsPerTask = 16`. On the local M4 that produced another clean step up in the CPU-parallel path while keeping the serial apples-to-apples baseline stable.

Validated median GiB/s from `report.json`:

| Input | Official C one-shot | Swift scalar | Swift SIMD4 | Swift CPU parallel | CPU context-auto | Swift `BLAKE3.hash(input)` |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 2.18 | 1.14 | 1.73 | 10.06 | 10.03 | 9.70 |
| 64 MiB | 2.18 | 1.15 | 1.77 | 11.30 | 11.30 | 17.62 |
| 256 MiB | 2.17 | 1.15 | 1.76 | 11.82 | 11.88 | 45.93 |
| 512 MiB | 2.17 | 1.15 | 1.75 | 12.08 | 12.06 | 51.50 |
| 1 GiB | 2.17 | 1.15 | 1.76 | 12.05 | 12.01 | 34.30 |

Interpretation:

- `Swift CPU parallel` now clears `12 GiB/s` at `512 MiB` and remains just above `12 GiB/s` at `1 GiB`, while materially improving the stubborn `256 MiB` row to `11.82 GiB/s`.
- `CPU context-auto` stays in essentially the same high band, which is what we want because the internal one-shot fast path and the explicit reusable-context path are now structurally similar.
- The public automatic path improved at `256 MiB` and `512 MiB`, but it remained noisier and more timing-class-sensitive at `64 MiB` and `1 GiB`, so this retune is promoted mainly as a CPU-parallel result rather than a blanket replacement for every default-auto README row.

## April 21, 2026 CPU Parallel Parent Cutoff 2048

Promoted broad artifact:

```sh
benchmarks/results/20260421T-cpu-parallel-parent-cutoff-2048
```

Focused confirmation artifact:

```sh
benchmarks/results/20260421T-cpu-parallel-parent-cutoff-2048-focused
```

This follow-up keeps the promoted task-partition retune but lowers `parallelParentMinCount` from `4_096` to `2_048`, letting parent reduction remain parallel slightly deeper into the tree. On the local M4 that raised the medium and large CPU rows again without changing the serial one-shot SIMD path or the hashing contract.

Validated median GiB/s from the broad `report.json`:

| Input | Official C one-shot | Swift scalar | Swift SIMD4 | Swift CPU parallel | CPU context-auto | Swift `BLAKE3.hash(input)` |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 16 MiB | 2.27 | 1.17 | 1.84 | 10.39 | 10.04 | 9.30 |
| 64 MiB | 2.24 | 1.17 | 1.80 | 10.83 | 11.79 | 14.62 |
| 256 MiB | 2.21 | 1.17 | 1.80 | 12.38 | 12.20 | 46.19 |
| 512 MiB | 2.20 | 1.17 | 1.79 | 12.42 | 12.34 | 58.27 |
| 1 GiB | 2.20 | 1.17 | 1.79 | 12.38 | 12.30 | 59.40 |

Focused confirmation median GiB/s from the large-size `report.json`:

| Input | Official C one-shot | Swift scalar | Swift SIMD4 | Swift CPU parallel-10 | CPU context-auto | Swift `BLAKE3.hash(input)` |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 64 MiB | 2.23 | 1.17 | 1.86 | 11.77 | 11.71 | 14.68 |
| 256 MiB | 2.22 | 1.17 | 1.81 | 12.10 | 12.27 | 40.01 |
| 512 MiB | 2.20 | 1.17 | 1.80 | 12.27 | 12.29 | 58.10 |
| 1 GiB | 2.20 | 1.17 | 1.79 | 12.34 | 12.27 | 59.38 |

Interpretation:

- Lowering the parent-reduction parallel cutoff is a durable CPU win. The broad run clears `12 GiB/s` from `256 MiB` upward, and the focused follow-up confirms that the large-input band remains in the `12.1` to `12.3 GiB/s` range while recovering `64 MiB` to `11.77 GiB/s`.
- The serial apples-to-apples Swift baseline also moved up slightly in this code state, with `single-simd` now landing around `1.79` to `1.86 GiB/s`, still well below the multi-threaded fast path but stronger than the earlier same-day broad runs.
- The public automatic row remains too sensitive to run order and automatic CPU/GPU dispatch to promote as a clean replacement for the README default-auto reference, so this promotion is scoped to the CPU-parallel and CPU-context rows.

## April 21, 2026 Digest-Only Metal Fast Path Recovery

Primary overhead-recovery artifact:

```sh
benchmarks/results/20260421T-digest-fastpath-isolated
```

This change set restores a dedicated digest-only Metal kernel family for plain unkeyed 32-byte digests while leaving keyed hashing, derive-key material, XOF, and batch APIs on the generalized kernel family. It also promotes `benchmarks/run-isolated-overhead.sh` to the primary acceptance harness for `resident`, `private`, `staged`, and `wrapped` tuning so the upload-heavy `default-auto` and `e2e` rows do not dominate the thermal/order profile.

The same patch also fixes the small private-buffer edge case for sub-chunk GPU validation by routing that case through the existing one-chunk batch kernel instead of falling back to a CPU path that cannot read private storage.

Promoted overhead recovery claims from the isolated harness are intentionally narrow. The strongest corroborated wins were the 64 MiB forced-GPU rows, compared below against the earlier weak `flatkernels` branch-comparison artifact:

| Input | Metal resident GPU | Metal private GPU | Metal staged GPU | Metal wrapped GPU |
| --- | ---: | ---: | ---: | ---: |
| 64 MiB old weak row | 25.07 | 21.30 | 10.26 | 15.65 |
| 64 MiB isolated recovery | 37.89 | 38.15 | 14.92 | 29.93 |

Supporting isolated medians from the same artifact were:

| Input | Metal resident GPU | Metal private GPU | Metal staged GPU | Metal wrapped GPU |
| --- | ---: | ---: | ---: | ---: |
| 16 MiB | 9.98 | 11.30 | 11.14 | 15.96 |
| 64 MiB | 37.89 | 38.15 | 14.92 | 29.93 |
| 256 MiB | 44.94 | 57.92 | 18.10 | 30.85 |

Interpretation:

- The dedicated digest-only split is the promoted change, and the isolated harness is the promoted primary acceptance method for these overhead modes.
- The strongest benchmark claims are the 64 MiB `resident-gpu`, `private-gpu`, `staged-gpu`, and `wrapped-gpu` recoveries, because those rows improved materially and remained directionally consistent across same-day reruns.
- The 16 MiB rows improved in the isolated artifact, but they remained more variance-sensitive and are kept as supporting data rather than headline claims.
- `resident-gpu` at 256 MiB remained the noisiest row across same-day repeats and is not promoted as a durable win.

Secondary sanity artifacts:

```sh
benchmarks/results/20260421T-digest-fastpath-secondary
benchmarks/results/20260421T-digest-fastpath-secondary/e2e.json
```

The mixed overhead rerun under `overhead-mixed.json` is kept as a cross-check only. It supported the same overall direction for the 64 MiB recovery rows, while `resident-gpu` at 256 MiB landed at 47.60 GiB/s and remained too noisy to promote as a stable win. The focused `e2e` sanity rerun measured 15.35/20.40 GiB/s for `e2e-auto` and 15.39/20.26 GiB/s for `e2e-gpu` at 512 MiB/1 GiB, keeping the large upload path in the same high-teens to low-20s band.

## April 21, 2026 Digest-Only Fused-Tile Follow-Up

Follow-up tuning artifacts:

```sh
benchmarks/results/20260421T-resident256-digest-tuning
benchmarks/results/20260421T-digest-default-expanded
benchmarks/results/20260421T-digest-inplace128-expanded
benchmarks/results/20260421T-digest-inplace128-e2e
benchmarks/results/20260421T-digest-resident-wrapped-confirm
```

After the digest-only split, a second pass tested whether the digest family should also move from the default `128`-chunk ping-pong fused-tile reducer to the older `128`-chunk in-place reducer.

What looked promising:

- The quick 256 MiB sweep under `20260421T-resident256-digest-tuning` favored `inplace128` for `resident` and `wrapped`.
- The expanded isolated run under `20260421T-digest-inplace128-expanded` raised several digest-only rows, including `resident-gpu` 256 MiB from 50.58 to 71.87 GiB/s, `staged-gpu` 256 MiB from 14.83 to 18.32 GiB/s, and `wrapped-gpu` 256 MiB from 34.82 to 40.25 GiB/s versus the matching `20260421T-digest-default-expanded` control.
- The focused `e2e` sanity pass under `20260421T-digest-inplace128-e2e` stayed in band, measuring 20.72 GiB/s at 512 MiB and 19.87 GiB/s at 1 GiB for `e2e-gpu`.

Why it was not promoted:

- The direct interleaved `resident,wrapped` confirmation under `20260421T-digest-resident-wrapped-confirm` did not hold the wrapped win. `wrapped-gpu` fell from 40.24 to 30.09 GiB/s at 64 MiB and from 47.30 to 44.03 GiB/s at 256 MiB when the candidate was rerun in the tighter A/B setup.
- `resident-gpu` remained favorable in that confirm, but the wrapped regressions were large enough that the retune did not meet the bar for a new default.

Conclusion: the digest-only kernel split is the durable recovery, but `BLAKE3_SWIFT_METAL_FUSED_TILE_REDUCTION=inplace` remains an opt-in experiment rather than the new default. The branch keeps the `128`-chunk ping-pong reducer as the shipped setting.

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

An experimental 128-chunk `simdgroup` fused tile reducer keeps the first 32-way reductions in SIMD-group lane shuffles and only uses 128 B of threadgroup memory for four intermediate CVs. Focused A/B JSON validated correctly, but the cleaner matching pass still favored ping-pong by about 5% geometric mean across staged and wrapped 512 MiB/1 GiB overhead modes, so `simdgroup` stays opt-in rather than replacing the default.

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

## April 19, 2026 Staged Metal File Read Prototype

Artifact:

```sh
benchmarks/results/20260419T145223Z-subtree-file-check
```

This run adds `BLAKE3File.Strategy.metalStagedRead`, which reads bounded file tiles directly into a shared Metal staging buffer instead of wrapping mmap pages for first-touch GPU access. It also reuses cached Metal contexts for file paths and decomposes large final complete-chunk prefixes into GPU subtree reductions, avoiding the old path where exact-size final tiles pulled tens or hundreds of thousands of CVs back for CPU merging.

Focused validated medians, default 64 MiB Metal tile:

| File input | CPU mmap parallel | Metal tiled mmap GPU | Metal staged read GPU |
| --- | ---: | ---: | ---: |
| 512 MiB | 5.83 | 8.00 | 9.79 |
| 1 GiB | 5.87 | 7.77 | 10.00 |

This is still a reality-check path, not a headline resident-GPU claim. A subsequent all-file-mode run at `benchmarks/results/20260419T145459Z-final-file-staged-read` validated correctness but showed severe late-run 1 GiB thermal/order degradation, with `metal-staged-read-gpu` falling to 2.12 GiB/s when it ran after the other file modes. A staged-read-only rerun immediately afterward recovered only to 6.73 GiB/s at 1 GiB, so publication-quality file claims still need rested, isolated runs and sustained thermal reporting.

Follow-up staged-read overlap experiment: `BLAKE3_SWIFT_METAL_STAGED_READ_INFLIGHT=2` now uses two bounded shared Metal buffers so the next tile's file read can overlap the previous tile's GPU reduction. In same-session validated staged-read-only JSON under `/tmp/blake3swift-staged-read-overlap`, the one-buffer 512 MiB/1 GiB medians were 7.72/8.26 GiB/s and the two-buffer medians were 10.02/10.66 GiB/s, a 1.29x geometric-mean improvement.

Follow-up CPU file experiment: for mapped files up to 2 GiB, `memoryMappedParallel` now hashes the mapped region with the direct one-shot parallel tree instead of feeding the streaming hasher in 16 MiB tiles. The bounded regular-file `read` path now reads 64 MiB tiles and reduces complete tile prefixes into CPU subtree CVs before pushing the canonical stack, avoiding per-chunk stack pushes. In same-session JSON under `/tmp/blake3swift-file-next`, the first combined CPU-subtree file-row run measured 6.16/6.20 GiB/s for 512 MiB/1 GiB `read`, 9.88/9.51 GiB/s for `mmap-parallel`, 9.03/8.98 GiB/s for tiled Metal mmap, and 11.07/11.42 GiB/s for staged-read Metal.

Follow-up CPU read overlap experiment: regular-file `read` now uses two bounded read buffers by default and a reusable serial CPU tile worker so the next `read(2)` can overlap the previous tile's subtree reduction. In validated same-session JSON at `/tmp/blake3swift-file-next/read-overlap-reused-workspace.json`, the 512 MiB/1 GiB read medians improved to 7.48/7.75 GiB/s. Forcing `BLAKE3_SWIFT_READ_INFLIGHT=1` measured 5.68/5.68 GiB/s in `/tmp/blake3swift-file-next/read-overlap-disabled-control.json`, confirming that the overlap, not benchmark noise, is the primary win. A 128 MiB read-tile experiment was slower at 7.28/7.64 GiB/s and was reverted to the 64 MiB default. `madvise(MADV_SEQUENTIAL|MADV_WILLNEED)` and `MADV_SEQUENTIAL`-only mmap experiments regressed one or more target file rows, especially Metal tiled-mmap, and were removed.

Follow-up isolated file harness and staged tile experiment: `benchmarks/run-file-reality.sh` now runs each file mode in a separate process, validates every JSON report, and captures thermal snapshots around each mode. The isolated sweep at `/tmp/blake3swift-file-reality-isolated` measured 7.55/7.68 GiB/s for `read`, 9.17/9.75 GiB/s for `mmap-parallel`, 7.85/6.97 GiB/s for tiled Metal mmap, and 10.03/9.39 GiB/s for staged-read Metal using the old 64 MiB staged default. A staged tile sweep found 32 MiB to be the better default: confirmation repeats under `/tmp/blake3swift-file-reality-staged-confirm-32m` measured 10.80/9.87 and 10.12/11.34 GiB/s for 512 MiB/1 GiB, while `/tmp/blake3swift-file-reality-staged-confirm-64m` measured 9.89/10.57 and 10.21/10.27 GiB/s. `BLAKE3File.Strategy.metalStagedRead` now defaults to 32 MiB. The staged path also uses a staged-only 32K-chunk decomposition threshold so the default exact-size final prefix uses one GPU chunk-CV pass plus CPU stack merge instead of many tiny subtree commands. Two repeats under `/tmp/blake3swift-file-reality-final-cv-threshold32k` measured 11.37/10.99 and 11.24/10.76 GiB/s for 512 MiB/1 GiB. The final all-file isolated pass at `/tmp/blake3swift-file-reality-final-code` measured 7.50/7.69 GiB/s for `read`, 9.08/9.57 GiB/s for `mmap-parallel`, 6.79/8.48 GiB/s for tiled Metal mmap, and 10.49/10.30 GiB/s for staged-read Metal.

Follow-up async staged-read pipeline experiment: staged-read now launches tile reductions through Metal's async workspace and leases separate staging and chunk-CV buffers per in-flight slot, then drains completed tile CVs in file order. Two-repeat isolated staged-read runs showed `BLAKE3_SWIFT_METAL_STAGED_READ_INFLIGHT=2` at 10.09/10.56 and 10.23/10.51 GiB/s for 512 MiB/1 GiB, `=3` at 11.15/11.51 and 10.17/11.25 GiB/s, and `=4` at 10.75/11.52 and 10.85/11.48 GiB/s. The default staged-read in-flight count is now 4 because it gave the most stable 1 GiB row while keeping the 512 MiB row ahead of the prior default. The final implementation also creates a staged-read-specific async workspace with four preallocated resource leases, avoiding transient scratch allocation in the timed path. A final-code staged-only repeat under `/tmp/blake3swift-file-reality-async-workspace-default4` measured 10.44/11.58 and 10.15/11.27 GiB/s, and the final-code all-file isolated pass under `/tmp/blake3swift-file-reality-async-workspace-default4-all` measured 7.53/7.71 GiB/s for `read`, 9.41/9.42 GiB/s for `mmap-parallel`, 7.37/9.60 GiB/s for tiled Metal mmap, and 11.80/11.99 GiB/s for staged-read Metal.

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
