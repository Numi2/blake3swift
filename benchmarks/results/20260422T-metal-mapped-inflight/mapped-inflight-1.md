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
| 256.0 MiB | cpu | single-simd | 1.82 | 1.80 | 1.82 | 1.82 | ok |
| 256.0 MiB | cpu | parallel | 11.79 | 11.71 | 12.07 | 12.07 | ok |
| 256.0 MiB | official-c | one-shot | 2.21 | 2.20 | 2.21 | 2.21 | ok |
| 256.0 MiB | cpu | context-auto | 11.84 | 11.70 | 11.95 | 11.95 | ok |
| 256.0 MiB | blake3 | default-auto | 28.10 | 26.71 | 31.17 | 31.17 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.59 | 5.13 | 5.68 | 5.68 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.15 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.78 | 1.77 | 1.78 | 1.78 | ok |
| 1.0 GiB | cpu | parallel | 12.20 | 12.13 | 12.22 | 12.22 | ok |
| 1.0 GiB | official-c | one-shot | 2.18 | 2.18 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 12.10 | 12.08 | 12.15 | 12.15 | ok |
| 1.0 GiB | blake3 | default-auto | 31.81 | 29.55 | 34.68 | 34.68 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 6.62 | 6.05 | 6.84 | 6.84 | ok |
jsonOutput=benchmarks/results/20260422T-metal-mapped-inflight/mapped-inflight-1.json
jsonValidation=ok path=benchmarks/results/20260422T-metal-mapped-inflight/mapped-inflight-1.json
