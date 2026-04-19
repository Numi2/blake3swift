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

Each publication run writes Markdown tables and matching JSON reports with per-sample timings, then validates the JSON report before exiting.

Default publication sizes are `16 MiB`, `64 MiB`, `256 MiB`, `512 MiB`, and `1 GiB`.

External upstream CLI checks, such as `b3sum`, should be stored beside the publication run as separate artifacts. They include process startup and CLI file handling, so keep them out of the in-process benchmark tables.

## Sustained Runs

```sh
benchmarks/run-sustained.sh
```

Runs repeated `512 MiB` and `1 GiB` sustained Metal measurements. Defaults are intentionally moderate for development speed. Increase `DURATION_SECONDS` before publishing sustained claims.

## Metal Autotune

```sh
benchmarks/run-autotune.sh
```

Runs measured Metal gate and mode sweeps and writes validated recommendation JSON. By default it avoids file I/O so development runs stay quick. Set `AUTOTUNE_FILE_TILES=1` to include tiled Metal file tile-size sweeps.

## Environment Variables

- `SIZES`: comma-separated benchmark sizes. Default: `16m,64m,256m,512m,1g`.
- `ITERATIONS`: per-size sample count. Default: `8` for publication, `2` for smoke/sustained setup.
- `OUT_DIR`: output directory. Default: timestamped directory under `benchmarks/results/`.
- `CPU_WORKERS`: optional fixed CPU parallel worker count.
- `DURATION_SECONDS`: sustained run duration. Default: `30`.
- `SUSTAINED_MODE`: sustained Metal mode. Default: `resident`.
- `MEMORY_STATS`: set to `1` to include process RSS plus allocator bytes/block snapshots in benchmark output.
- `METAL_LIBRARY`: optional path to a precompiled `BLAKE3Metal.metallib`.
- `MINIMUM_GPU_BYTES`: optional `.automatic` Metal CPU/GPU gate for benchmark contexts.
- `METAL_TILE_SIZE`: optional tiled Metal file benchmark tile size.
- `BLAKE3_SWIFT_BACKEND`: optional default `BLAKE3.hash` backend policy: `auto`, `cpu`, or `metal`.
- `BLAKE3_SWIFT_METAL_MIN_BYTES`: optional byte threshold where default `BLAKE3.hash` may use Metal; accepts raw bytes or `k`, `m`, `g` suffixes.
- `BLAKE3_SWIFT_METAL_FUSED_TILE_CHUNKS`: optional fused Metal tile setting: `0`, `128`, `256`, `512`, or `1024`.
- `BLAKE3_SWIFT_METAL_FUSED_TILE_REDUCTION`: optional fused Metal tile reduction: `pingpong` or `inplace`.
- `AUTOTUNE_GATES`: comma-separated Metal automatic gate candidates for `run-autotune.sh`.
- `AUTOTUNE_MODES`: comma-separated Metal mode candidates for `run-autotune.sh`.
- `AUTOTUNE_FILE_TILES`: set to `1` to include tiled Metal file tile-size sweeps in `run-autotune.sh`.
- `AUTOTUNE_TILE_SIZES`: comma-separated tile candidates for `run-autotune.sh`.
- `METAL_GATE_BYTES_LIST`: optional space-separated gate sweep for `run-tuning-grid.sh`. Default: `16m`.
- `METAL_TILE_SIZES`: optional space-separated tile-size sweep for `run-tuning-grid.sh`.
- `JSON_OUTPUT`: optional JSON output path for `run-smoke.sh`.

Keep resident, end-to-end, file, staged, wrapped, private, and sustained outputs in separate tables.
Record whether a run used the runtime Metal source compiler or a packaged `.metallib`.
