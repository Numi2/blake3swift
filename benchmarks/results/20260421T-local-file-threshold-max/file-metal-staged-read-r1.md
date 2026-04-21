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
fileModes=metal-staged-read
file-metal-staged-read includes: timed file open/stat, bounded reads directly into shared Metal staging buffers, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.15 | 1.15 | ok |
| 256.0 MiB | cpu | single-simd | 1.74 | 1.74 | 1.74 | 1.74 | ok |
| 256.0 MiB | cpu | parallel | 11.75 | 11.48 | 11.82 | 11.82 | ok |
| 256.0 MiB | official-c | one-shot | 2.15 | 2.15 | 2.15 | 2.15 | ok |
| 256.0 MiB | cpu | context-auto | 11.80 | 11.73 | 11.89 | 11.89 | ok |
| 256.0 MiB | blake3 | default-auto | 22.31 | 16.30 | 27.24 | 27.24 | ok |
| 256.0 MiB | metal-file | metal-staged-read-gpu | 9.88 | 9.49 | 10.07 | 10.07 | ok |
| 1.0 GiB | cpu | scalar | 1.14 | 1.14 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.74 | 1.74 | 1.74 | 1.74 | ok |
| 1.0 GiB | cpu | parallel | 12.02 | 11.88 | 12.14 | 12.14 | ok |
| 1.0 GiB | official-c | one-shot | 2.15 | 2.15 | 2.15 | 2.15 | ok |
| 1.0 GiB | cpu | context-auto | 12.01 | 11.91 | 12.11 | 12.11 | ok |
| 1.0 GiB | blake3 | default-auto | 46.89 | 44.13 | 48.54 | 48.54 | ok |
| 1.0 GiB | metal-file | metal-staged-read-gpu | 11.93 | 11.66 | 12.23 | 12.23 | ok |
jsonOutput=benchmarks/results/20260421T-local-file-threshold-max/file-metal-staged-read-r1.json
