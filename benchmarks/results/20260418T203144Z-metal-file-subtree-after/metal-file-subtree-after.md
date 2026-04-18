BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=67108864
metalModes=
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
fileModes=metal-tiled-mmap
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.12 | 1.11 | 1.12 | 1.12 | ok |
| 64.0 MiB | cpu | single-simd | 1.85 | 1.82 | 1.88 | 1.88 | ok |
| 64.0 MiB | cpu | parallel | 10.00 | 8.43 | 10.26 | 10.26 | ok |
| 64.0 MiB | official-c | one-shot | 2.26 | 2.24 | 2.27 | 2.27 | ok |
| 64.0 MiB | cpu | context-auto | 9.70 | 8.53 | 10.10 | 10.10 | ok |
| 64.0 MiB | blake3 | default-auto | 24.90 | 10.72 | 28.87 | 28.87 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.81 | 3.54 | 4.31 | 4.31 | ok |
| 256.0 MiB | cpu | scalar | 1.10 | 1.08 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.82 | 1.81 | 1.82 | 1.82 | ok |
| 256.0 MiB | cpu | parallel | 10.14 | 9.59 | 10.81 | 10.81 | ok |
| 256.0 MiB | official-c | one-shot | 2.21 | 1.31 | 2.22 | 2.22 | ok |
| 256.0 MiB | cpu | context-auto | 10.13 | 9.91 | 10.66 | 10.66 | ok |
| 256.0 MiB | blake3 | default-auto | 32.93 | 27.88 | 34.51 | 34.51 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.38 | 4.52 | 6.70 | 6.70 | ok |
| 512.0 MiB | cpu | scalar | 1.10 | 1.08 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.80 | 1.80 | 1.81 | 1.81 | ok |
| 512.0 MiB | cpu | parallel | 10.83 | 10.35 | 11.15 | 11.15 | ok |
| 512.0 MiB | official-c | one-shot | 2.19 | 2.02 | 2.21 | 2.21 | ok |
| 512.0 MiB | cpu | context-auto | 10.65 | 10.22 | 10.82 | 10.82 | ok |
| 512.0 MiB | blake3 | default-auto | 20.91 | 20.12 | 21.74 | 21.74 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 6.01 | 5.43 | 6.10 | 6.10 | ok |
| 1.0 GiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.79 | 1.79 | 1.80 | 1.80 | ok |
| 1.0 GiB | cpu | parallel | 11.10 | 10.83 | 11.51 | 11.51 | ok |
| 1.0 GiB | official-c | one-shot | 2.18 | 2.16 | 2.19 | 2.19 | ok |
| 1.0 GiB | cpu | context-auto | 10.83 | 10.51 | 11.12 | 11.12 | ok |
| 1.0 GiB | blake3 | default-auto | 29.72 | 27.49 | 32.38 | 32.38 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 6.12 | 5.43 | 6.99 | 6.99 | ok |
jsonOutput=benchmarks/results/20260418T203144Z-metal-file-subtree-after/metal-file-subtree-after.json
