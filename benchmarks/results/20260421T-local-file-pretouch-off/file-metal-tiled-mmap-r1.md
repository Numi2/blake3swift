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
| 256.0 MiB | cpu | scalar | 1.13 | 1.13 | 1.13 | 1.13 | ok |
| 256.0 MiB | cpu | single-simd | 1.71 | 1.41 | 1.72 | 1.72 | ok |
| 256.0 MiB | cpu | parallel | 10.85 | 10.47 | 10.97 | 10.97 | ok |
| 256.0 MiB | official-c | one-shot | 2.05 | 1.45 | 2.12 | 2.12 | ok |
| 256.0 MiB | cpu | context-auto | 11.46 | 11.24 | 11.61 | 11.61 | ok |
| 256.0 MiB | blake3 | default-auto | 22.97 | 15.51 | 23.88 | 23.88 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.09 | 4.83 | 5.66 | 5.66 | ok |
| 1.0 GiB | cpu | scalar | 1.13 | 1.13 | 1.13 | 1.13 | ok |
| 1.0 GiB | cpu | single-simd | 1.72 | 1.33 | 1.72 | 1.72 | ok |
| 1.0 GiB | cpu | parallel | 11.02 | 10.88 | 11.30 | 11.30 | ok |
| 1.0 GiB | official-c | one-shot | 2.12 | 1.52 | 2.12 | 2.12 | ok |
| 1.0 GiB | cpu | context-auto | 11.21 | 10.35 | 11.62 | 11.62 | ok |
| 1.0 GiB | blake3 | default-auto | 41.26 | 39.15 | 42.67 | 42.67 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 4.08 | 0.50 | 4.30 | 4.30 | ok |
jsonOutput=benchmarks/results/20260421T-local-file-pretouch-off/file-metal-tiled-mmap-r1.json
