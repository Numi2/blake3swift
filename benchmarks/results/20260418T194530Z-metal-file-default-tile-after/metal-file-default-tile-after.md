BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=8388608
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=8388608
metalTileByteCount=67108864
metalModes=
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB
fileModes=metal-tiled-mmap
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 0.55 | 0.50 | 0.73 | 0.73 | ok |
| 64.0 MiB | cpu | single-simd | 0.96 | 0.93 | 1.04 | 1.04 | ok |
| 64.0 MiB | cpu | parallel | 4.58 | 4.08 | 6.17 | 6.17 | ok |
| 64.0 MiB | official-c | one-shot | 1.25 | 1.21 | 1.37 | 1.37 | ok |
| 64.0 MiB | cpu | context-auto | 4.88 | 4.85 | 7.62 | 7.62 | ok |
| 64.0 MiB | blake3 | default-auto | 19.34 | 12.84 | 20.44 | 20.44 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.13 | 2.82 | 3.22 | 3.22 | ok |
| 256.0 MiB | cpu | scalar | 0.49 | 0.48 | 0.50 | 0.50 | ok |
| 256.0 MiB | cpu | single-simd | 1.55 | 1.45 | 1.58 | 1.58 | ok |
| 256.0 MiB | cpu | parallel | 8.62 | 8.14 | 9.82 | 9.82 | ok |
| 256.0 MiB | official-c | one-shot | 1.86 | 1.82 | 1.90 | 1.90 | ok |
| 256.0 MiB | cpu | context-auto | 7.78 | 7.44 | 8.53 | 8.53 | ok |
| 256.0 MiB | blake3 | default-auto | 30.53 | 26.15 | 34.13 | 34.13 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.72 | 4.36 | 4.74 | 4.74 | ok |
| 512.0 MiB | cpu | scalar | 0.94 | 0.93 | 0.95 | 0.95 | ok |
| 512.0 MiB | cpu | single-simd | 1.58 | 1.56 | 1.59 | 1.59 | ok |
| 512.0 MiB | cpu | parallel | 9.14 | 8.64 | 9.64 | 9.64 | ok |
| 512.0 MiB | official-c | one-shot | 1.93 | 1.88 | 1.95 | 1.95 | ok |
| 512.0 MiB | cpu | context-auto | 8.92 | 8.47 | 9.17 | 9.17 | ok |
| 512.0 MiB | blake3 | default-auto | 34.22 | 32.14 | 37.33 | 37.33 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.43 | 2.95 | 5.30 | 5.30 | ok |
jsonOutput=benchmarks/results/20260418T194530Z-metal-file-default-tile-after/metal-file-default-tile-after.json
