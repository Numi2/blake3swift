BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=8388608
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=8388608
metalTileByteCount=16777216
metalModes=
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
fileModes=metal-tiled-mmap
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.08 | 1.06 | 1.08 | 1.08 | ok |
| 64.0 MiB | cpu | single-simd | 1.73 | 1.72 | 1.73 | 1.73 | ok |
| 64.0 MiB | cpu | parallel | 8.32 | 7.99 | 8.34 | 8.34 | ok |
| 64.0 MiB | official-c | one-shot | 2.14 | 2.13 | 2.15 | 2.15 | ok |
| 64.0 MiB | cpu | context-auto | 8.29 | 8.02 | 9.59 | 9.59 | ok |
| 64.0 MiB | blake3 | default-auto | 32.48 | 15.47 | 32.62 | 32.62 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.75 | 3.56 | 4.07 | 4.07 | ok |
| 256.0 MiB | cpu | scalar | 1.08 | 1.06 | 1.08 | 1.08 | ok |
| 256.0 MiB | cpu | single-simd | 1.73 | 1.72 | 1.73 | 1.73 | ok |
| 256.0 MiB | cpu | parallel | 8.85 | 8.38 | 9.33 | 9.33 | ok |
| 256.0 MiB | official-c | one-shot | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | context-auto | 8.81 | 8.51 | 9.56 | 9.56 | ok |
| 256.0 MiB | blake3 | default-auto | 31.25 | 30.61 | 36.22 | 36.22 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.05 | 3.07 | 4.55 | 4.55 | ok |
| 512.0 MiB | cpu | scalar | 1.08 | 1.07 | 1.08 | 1.08 | ok |
| 512.0 MiB | cpu | single-simd | 1.73 | 1.72 | 1.73 | 1.73 | ok |
| 512.0 MiB | cpu | parallel | 9.75 | 9.20 | 9.84 | 9.84 | ok |
| 512.0 MiB | official-c | one-shot | 2.14 | 2.12 | 2.14 | 2.14 | ok |
| 512.0 MiB | cpu | context-auto | 9.53 | 7.61 | 10.13 | 10.13 | ok |
| 512.0 MiB | blake3 | default-auto | 25.50 | 21.64 | 27.68 | 27.68 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.81 | 2.36 | 3.92 | 3.92 | ok |
| 1.0 GiB | cpu | scalar | 1.08 | 1.07 | 1.08 | 1.08 | ok |
| 1.0 GiB | cpu | single-simd | 1.72 | 1.72 | 1.73 | 1.73 | ok |
| 1.0 GiB | cpu | parallel | 10.09 | 9.67 | 10.18 | 10.18 | ok |
| 1.0 GiB | official-c | one-shot | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | context-auto | 5.55 | 5.21 | 5.69 | 5.69 | ok |
| 1.0 GiB | blake3 | default-auto | 28.57 | 24.89 | 30.12 | 30.12 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 3.96 | 3.77 | 4.48 | 4.48 | ok |
jsonOutput=benchmarks/results/20260418T194218Z-metal-file-tile-sweep/metal-tiled-tile-16m.json
