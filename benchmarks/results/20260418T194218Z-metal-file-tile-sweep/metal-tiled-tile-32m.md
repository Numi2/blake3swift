BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=8388608
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=8388608
metalTileByteCount=33554432
metalModes=
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
fileModes=metal-tiled-mmap
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 0.59 | 0.52 | 0.63 | 0.63 | ok |
| 64.0 MiB | cpu | single-simd | 1.06 | 0.98 | 1.33 | 1.33 | ok |
| 64.0 MiB | cpu | parallel | 8.36 | 6.75 | 9.90 | 9.90 | ok |
| 64.0 MiB | official-c | one-shot | 2.00 | 1.91 | 2.05 | 2.05 | ok |
| 64.0 MiB | cpu | context-auto | 7.88 | 7.50 | 8.15 | 8.15 | ok |
| 64.0 MiB | blake3 | default-auto | 30.85 | 14.97 | 33.16 | 33.16 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.84 | 3.65 | 4.03 | 4.03 | ok |
| 256.0 MiB | cpu | scalar | 1.05 | 1.04 | 1.06 | 1.06 | ok |
| 256.0 MiB | cpu | single-simd | 1.54 | 1.31 | 1.71 | 1.71 | ok |
| 256.0 MiB | cpu | parallel | 8.77 | 7.69 | 9.20 | 9.20 | ok |
| 256.0 MiB | official-c | one-shot | 2.08 | 2.06 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | context-auto | 8.71 | 8.43 | 9.17 | 9.17 | ok |
| 256.0 MiB | blake3 | default-auto | 20.19 | 15.55 | 24.48 | 24.48 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.57 | 4.10 | 4.58 | 4.58 | ok |
| 512.0 MiB | cpu | scalar | 0.95 | 0.57 | 1.03 | 1.03 | ok |
| 512.0 MiB | cpu | single-simd | 1.19 | 0.89 | 1.38 | 1.38 | ok |
| 512.0 MiB | cpu | parallel | 5.37 | 3.74 | 5.69 | 5.69 | ok |
| 512.0 MiB | official-c | one-shot | 1.41 | 1.08 | 2.00 | 2.00 | ok |
| 512.0 MiB | cpu | context-auto | 8.62 | 6.85 | 9.24 | 9.24 | ok |
| 512.0 MiB | blake3 | default-auto | 33.96 | 31.56 | 37.45 | 37.45 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.47 | 4.22 | 4.72 | 4.72 | ok |
| 1.0 GiB | cpu | scalar | 0.76 | 0.60 | 0.98 | 0.98 | ok |
| 1.0 GiB | cpu | single-simd | 1.33 | 0.92 | 1.63 | 1.63 | ok |
| 1.0 GiB | cpu | parallel | 7.20 | 5.51 | 9.36 | 9.36 | ok |
| 1.0 GiB | official-c | one-shot | 1.43 | 1.04 | 1.98 | 1.98 | ok |
| 1.0 GiB | cpu | context-auto | 5.49 | 4.98 | 8.93 | 8.93 | ok |
| 1.0 GiB | blake3 | default-auto | 30.15 | 27.44 | 33.93 | 33.93 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 3.45 | 3.22 | 4.45 | 4.45 | ok |
jsonOutput=benchmarks/results/20260418T194218Z-metal-file-tile-sweep/metal-tiled-tile-32m.json
