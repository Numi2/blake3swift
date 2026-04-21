BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=134217728
metalModes=
sizes=256.0 MiB, 1.0 GiB
cryptoKitModes=none
fileModes=metal-tiled-mmap
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.14 | 1.12 | 1.14 | 1.14 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.74 | 1.77 | 1.77 | ok |
| 256.0 MiB | cpu | parallel | 10.74 | 10.34 | 11.00 | 11.00 | ok |
| 256.0 MiB | official-c | one-shot | 2.13 | 1.58 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.28 | 7.57 | 10.56 | 10.56 | ok |
| 256.0 MiB | blake3 | default-auto | 13.63 | 11.60 | 23.00 | 23.00 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.28 | 5.10 | 5.58 | 5.58 | ok |
| 1.0 GiB | cpu | scalar | 1.13 | 1.13 | 1.13 | 1.13 | ok |
| 1.0 GiB | cpu | single-simd | 1.73 | 1.69 | 1.73 | 1.73 | ok |
| 1.0 GiB | cpu | parallel | 11.05 | 10.99 | 11.20 | 11.20 | ok |
| 1.0 GiB | official-c | one-shot | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | context-auto | 11.02 | 4.14 | 11.12 | 11.12 | ok |
| 1.0 GiB | blake3 | default-auto | 31.78 | 31.38 | 36.41 | 36.41 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 5.87 | 0.47 | 6.23 | 6.23 | ok |
jsonOutput=benchmarks/results/20260421T-local-file-tiled-128m/file-metal-tiled-mmap-r1.json
