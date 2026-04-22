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
| 256.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.78 | 1.77 | 1.78 | 1.78 | ok |
| 256.0 MiB | cpu | parallel | 11.94 | 11.75 | 12.06 | 12.06 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 11.71 | 11.57 | 12.07 | 12.07 | ok |
| 256.0 MiB | blake3 | default-auto | 27.38 | 27.11 | 32.30 | 32.30 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.94 | 5.90 | 6.51 | 6.51 | ok |
| 1.0 GiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.77 | 1.77 | 1.77 | 1.77 | ok |
| 1.0 GiB | cpu | parallel | 12.10 | 11.89 | 12.16 | 12.16 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 12.12 | 12.12 | 12.18 | 12.18 | ok |
| 1.0 GiB | blake3 | default-auto | 33.45 | 27.04 | 34.16 | 34.16 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 6.73 | 5.84 | 7.04 | 7.04 | ok |
jsonOutput=benchmarks/results/20260422T-metal-mapped-subtree-collapse/default.json
jsonValidation=ok path=benchmarks/results/20260422T-metal-mapped-subtree-collapse/default.json
