# Benchmark Fixtures

These scripts wrap the `blake3-bench` executable with reproducible command lines. They do not create release claims by themselves; raw output must be kept with hardware, OS, Swift, commit, power, and thermal notes.

## Quick Smoke

```sh
benchmarks/run-smoke.sh
```

Runs a short correctness/perf sanity pass at `1 MiB` and `16 MiB`.

## Publication Sweep

```sh
benchmarks/run-publication.sh
```

Collects separate output files for:

- CPU scalar, CPU serial SIMD, CPU parallel, and reusable CPU context rows.
- Metal resident and end-to-end rows.
- CPU file and Metal file strategy rows.

Default publication sizes are `16 MiB`, `64 MiB`, `256 MiB`, `512 MiB`, and `1 GiB`.

## Sustained Runs

```sh
benchmarks/run-sustained.sh
```

Runs repeated `512 MiB` and `1 GiB` sustained Metal measurements. Defaults are intentionally moderate for development speed. Increase `DURATION_SECONDS` before publishing sustained claims.

## Environment Variables

- `SIZES`: comma-separated benchmark sizes. Default: `16m,64m,256m,512m,1g`.
- `ITERATIONS`: per-size sample count. Default: `8` for publication, `2` for smoke/sustained setup.
- `OUT_DIR`: output directory. Default: timestamped directory under `benchmarks/results/`.
- `CPU_WORKERS`: optional fixed CPU parallel worker count.
- `DURATION_SECONDS`: sustained run duration. Default: `30`.
- `SUSTAINED_MODE`: sustained Metal mode. Default: `resident`.
- `MEMORY_STATS`: set to `1` to include process RSS snapshots in benchmark output.

Keep resident, end-to-end, file, staged, wrapped, private, and sustained outputs in separate tables.
