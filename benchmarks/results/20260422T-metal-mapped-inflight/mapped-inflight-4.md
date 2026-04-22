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
| 256.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 11.85 | 11.76 | 11.89 | 11.89 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 11.85 | 11.83 | 12.12 | 12.12 | ok |
| 256.0 MiB | blake3 | default-auto | 26.98 | 25.71 | 27.57 | 27.57 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.79 | 5.51 | 5.79 | 5.79 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.77 | 1.77 | 1.77 | 1.77 | ok |
| 1.0 GiB | cpu | parallel | 12.19 | 12.09 | 12.20 | 12.20 | ok |
| 1.0 GiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 11.96 | 11.20 | 12.18 | 12.18 | ok |
| 1.0 GiB | blake3 | default-auto | 29.22 | 26.60 | 34.73 | 34.73 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 6.44 | 5.71 | 6.81 | 6.81 | ok |
jsonOutput=benchmarks/results/20260422T-metal-mapped-inflight/mapped-inflight-4.json
jsonValidation=ok path=benchmarks/results/20260422T-metal-mapped-inflight/mapped-inflight-4.json
