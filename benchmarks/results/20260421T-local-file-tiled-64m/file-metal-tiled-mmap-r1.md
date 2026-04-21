BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=67108864
metalModes=
sizes=256.0 MiB, 1.0 GiB
cryptoKitModes=none
fileModes=metal-tiled-mmap
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.14 | 1.14 | 1.15 | 1.15 | ok |
| 256.0 MiB | cpu | single-simd | 1.74 | 1.47 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.86 | 10.64 | 11.44 | 11.44 | ok |
| 256.0 MiB | official-c | one-shot | 2.08 | 1.39 | 2.13 | 2.13 | ok |
| 256.0 MiB | cpu | context-auto | 11.60 | 11.44 | 11.74 | 11.74 | ok |
| 256.0 MiB | blake3 | default-auto | 29.35 | 29.00 | 37.59 | 37.59 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.78 | 4.70 | 5.59 | 5.59 | ok |
| 1.0 GiB | cpu | scalar | 1.13 | 1.13 | 1.14 | 1.14 | ok |
| 1.0 GiB | cpu | single-simd | 1.70 | 1.33 | 1.73 | 1.73 | ok |
| 1.0 GiB | cpu | parallel | 11.09 | 10.98 | 11.56 | 11.56 | ok |
| 1.0 GiB | official-c | one-shot | 2.14 | 1.59 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | context-auto | 11.49 | 10.87 | 11.82 | 11.82 | ok |
| 1.0 GiB | blake3 | default-auto | 44.67 | 29.96 | 46.20 | 46.20 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 4.31 | 0.47 | 4.94 | 4.94 | ok |
jsonOutput=benchmarks/results/20260421T-local-file-tiled-64m/file-metal-tiled-mmap-r1.json
