BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=8388608
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=8388608
metalTileByteCount=67108864
metalModes=
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
fileModes=metal-tiled-mmap
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 0.94 | 0.92 | 0.97 | 0.97 | ok |
| 64.0 MiB | cpu | single-simd | 1.57 | 1.51 | 1.60 | 1.60 | ok |
| 64.0 MiB | cpu | parallel | 7.29 | 7.03 | 7.94 | 7.94 | ok |
| 64.0 MiB | official-c | one-shot | 1.91 | 1.80 | 1.95 | 1.95 | ok |
| 64.0 MiB | cpu | context-auto | 7.17 | 7.12 | 7.81 | 7.81 | ok |
| 64.0 MiB | blake3 | default-auto | 16.09 | 8.00 | 20.13 | 20.13 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.70 | 3.46 | 4.36 | 4.36 | ok |
| 256.0 MiB | cpu | scalar | 0.72 | 0.50 | 0.98 | 0.98 | ok |
| 256.0 MiB | cpu | single-simd | 1.50 | 0.82 | 1.59 | 1.59 | ok |
| 256.0 MiB | cpu | parallel | 8.13 | 7.79 | 8.49 | 8.49 | ok |
| 256.0 MiB | official-c | one-shot | 1.97 | 1.95 | 1.98 | 1.98 | ok |
| 256.0 MiB | cpu | context-auto | 8.05 | 7.57 | 9.83 | 9.83 | ok |
| 256.0 MiB | blake3 | default-auto | 33.42 | 29.00 | 38.22 | 38.22 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.68 | 4.33 | 4.94 | 4.94 | ok |
| 512.0 MiB | cpu | scalar | 0.98 | 0.58 | 1.00 | 1.00 | ok |
| 512.0 MiB | cpu | single-simd | 0.98 | 0.94 | 1.32 | 1.32 | ok |
| 512.0 MiB | cpu | parallel | 5.15 | 5.01 | 5.66 | 5.66 | ok |
| 512.0 MiB | official-c | one-shot | 1.95 | 1.91 | 1.96 | 1.96 | ok |
| 512.0 MiB | cpu | context-auto | 9.13 | 8.65 | 9.58 | 9.58 | ok |
| 512.0 MiB | blake3 | default-auto | 33.29 | 33.03 | 34.91 | 34.91 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.29 | 4.27 | 4.34 | 4.34 | ok |
| 1.0 GiB | cpu | scalar | 1.00 | 0.98 | 1.01 | 1.01 | ok |
| 1.0 GiB | cpu | single-simd | 1.66 | 1.65 | 1.66 | 1.66 | ok |
| 1.0 GiB | cpu | parallel | 9.65 | 8.88 | 9.93 | 9.93 | ok |
| 1.0 GiB | official-c | one-shot | 2.04 | 2.02 | 2.05 | 2.05 | ok |
| 1.0 GiB | cpu | context-auto | 9.69 | 9.46 | 9.85 | 9.85 | ok |
| 1.0 GiB | blake3 | default-auto | 37.57 | 36.06 | 42.16 | 42.16 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 4.30 | 4.28 | 4.40 | 4.40 | ok |
jsonOutput=benchmarks/results/20260418T194218Z-metal-file-tile-sweep/metal-tiled-tile-64m.json
