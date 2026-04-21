BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=
sizes=256.0 MiB, 1.0 GiB
cryptoKitModes=none
fileModes=metal-tiled-mmap
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.15 | 1.15 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 11.78 | 11.71 | 11.80 | 11.80 | ok |
| 256.0 MiB | official-c | one-shot | 2.15 | 2.15 | 2.15 | 2.15 | ok |
| 256.0 MiB | cpu | context-auto | 11.74 | 11.66 | 11.86 | 11.86 | ok |
| 256.0 MiB | blake3 | default-auto | 22.75 | 22.23 | 25.05 | 25.05 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.92 | 5.68 | 6.30 | 6.30 | ok |
| 1.0 GiB | cpu | scalar | 1.14 | 1.14 | 1.14 | 1.14 | ok |
| 1.0 GiB | cpu | single-simd | 1.74 | 1.71 | 1.74 | 1.74 | ok |
| 1.0 GiB | cpu | parallel | 11.84 | 11.76 | 12.09 | 12.09 | ok |
| 1.0 GiB | official-c | one-shot | 2.15 | 2.15 | 2.16 | 2.16 | ok |
| 1.0 GiB | cpu | context-auto | 11.97 | 11.70 | 12.04 | 12.04 | ok |
| 1.0 GiB | blake3 | default-auto | 34.57 | 31.74 | 36.67 | 36.67 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 6.26 | 5.67 | 6.88 | 6.88 | ok |
jsonOutput=benchmarks/results/20260421T-local-file-threshold-max/file-metal-tiled-mmap-r1.json
