# Apple M6 Follow-up Tuning

Target: Apple M6 Mac mini (`Mac18,5`), 12 active CPUs, 16 GB unified memory; macOS 27.0; Swift 6.4; runtime-source Metal kernels. Release baseline: `db97ce7` (`Tune automatic Metal threshold for M6`). The host had no recorded thermal or performance warning. See `cpu.txt`, `macos.txt`, `swift.txt`, `thermal.txt`, and `sha256.txt` for captured metadata.

## Automatic CPU / Metal Gate

The M6 one-shot default was tested at 2 MiB and 4 MiB gates in interleaved order (2, 4, 2, 4). Each run used:

```sh
BLAKE3_SWIFT_METAL_MIN_BYTES=<2097152-or-4194304> \
  .build/release/blake3-bench \
  --sizes=2m,3m,4m,8m --iterations=12 \
  --metal-modes=off --file-modes=off --operation-modes=off \
  --cryptokit-modes=off --json-output=<report.json>
```

The benchmark's `default-auto` row exercises public `BLAKE3.hash`. All emitted digests in the four JSON reports were checked and marked correct. Full Markdown and JSON outputs are retained as `gate-<threshold>-run-<n>.md` and `.json`.

## CPU Task Count Sweep

At 12 CPU workers and 256 MiB input, `parallelTasksPerWorker` was compiled at 1, 2, 4, 8, and 16. Each used a three-iteration release benchmark with `BLAKE3_SWIFT_METAL_MIN_BYTES=2147483647`, `--metal-modes=off`, and other optional timing modes disabled. The `parallel-12` median GiB/s results, in candidate order, were 15.44, 15.59, 16.87, 17.37, and 17.19. Every output row had a correct digest. Build logs are retained as `m6-build-*.log`; the checkout was restored to 8 and rebuilt (`m6-build-restored.log`).

This sequential sweep had run-order variability; the narrow difference between 4, 8, and 16 tasks per worker is inconclusive. No scheduler change was selected.
