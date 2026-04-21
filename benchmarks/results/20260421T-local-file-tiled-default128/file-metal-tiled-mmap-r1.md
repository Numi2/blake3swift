BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=
sizes=256.0 MiB, 1.0 GiB
cryptoKitModes=none
fileModes=metal-tiled-mmap
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.06 | 1.02 | 1.11 | 1.11 | ok |
| 256.0 MiB | cpu | single-simd | 1.70 | 1.53 | 1.72 | 1.72 | ok |
| 256.0 MiB | cpu | parallel | 10.76 | 10.52 | 10.82 | 10.82 | ok |
| 256.0 MiB | official-c | one-shot | 2.11 | 1.67 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | context-auto | 10.53 | 9.71 | 10.83 | 10.83 | ok |
| 256.0 MiB | blake3 | default-auto | 16.66 | 12.63 | 25.24 | 25.24 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.14 | 4.27 | 5.24 | 5.24 | ok |
| 1.0 GiB | cpu | scalar | 1.12 | 0.97 | 1.14 | 1.14 | ok |
| 1.0 GiB | cpu | single-simd | 1.73 | 1.40 | 1.73 | 1.73 | ok |
| 1.0 GiB | cpu | parallel | 11.13 | 10.80 | 11.63 | 11.63 | ok |
| 1.0 GiB | official-c | one-shot | 2.12 | 1.99 | 2.13 | 2.13 | ok |
| 1.0 GiB | cpu | context-auto | 11.05 | 10.90 | 11.32 | 11.32 | ok |
| 1.0 GiB | blake3 | default-auto | 32.41 | 27.79 | 34.57 | 34.57 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 6.11 | 5.94 | 6.76 | 6.76 | ok |
jsonOutput=benchmarks/results/20260421T-local-file-tiled-default128/file-metal-tiled-mmap-r1.json
