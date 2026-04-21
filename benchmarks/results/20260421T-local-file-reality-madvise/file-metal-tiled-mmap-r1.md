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
| 256.0 MiB | cpu | single-simd | 1.74 | 1.74 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 11.81 | 11.51 | 11.96 | 11.96 | ok |
| 256.0 MiB | official-c | one-shot | 2.16 | 2.15 | 2.16 | 2.16 | ok |
| 256.0 MiB | cpu | context-auto | 11.82 | 11.61 | 11.84 | 11.84 | ok |
| 256.0 MiB | blake3 | default-auto | 27.19 | 22.16 | 30.32 | 30.32 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.03 | 5.00 | 5.40 | 5.40 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.14 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.74 | 1.74 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 11.95 | 11.89 | 12.16 | 12.16 | ok |
| 1.0 GiB | official-c | one-shot | 2.15 | 2.15 | 2.15 | 2.15 | ok |
| 1.0 GiB | cpu | context-auto | 12.02 | 11.98 | 12.12 | 12.12 | ok |
| 1.0 GiB | blake3 | default-auto | 31.30 | 29.41 | 31.65 | 31.65 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 6.01 | 5.24 | 6.49 | 6.49 | ok |
jsonOutput=benchmarks/results/20260421T-local-file-reality-madvise/file-metal-tiled-mmap-r1.json
