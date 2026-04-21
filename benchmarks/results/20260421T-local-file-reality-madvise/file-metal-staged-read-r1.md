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
| 256.0 MiB | cpu | scalar | 1.15 | 1.14 | 1.15 | 1.15 | ok |
| 256.0 MiB | cpu | single-simd | 1.74 | 1.73 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 11.69 | 11.41 | 11.80 | 11.80 | ok |
| 256.0 MiB | official-c | one-shot | 2.14 | 2.13 | 2.15 | 2.15 | ok |
| 256.0 MiB | cpu | context-auto | 11.67 | 11.61 | 11.74 | 11.74 | ok |
| 256.0 MiB | blake3 | default-auto | 32.10 | 31.07 | 33.97 | 33.97 | ok |
| 256.0 MiB | metal-file | metal-staged-read-gpu | 9.92 | 8.97 | 10.19 | 10.19 | ok |
| 1.0 GiB | cpu | scalar | 1.14 | 1.13 | 1.14 | 1.14 | ok |
| 1.0 GiB | cpu | single-simd | 1.74 | 1.74 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 12.00 | 11.90 | 12.11 | 12.11 | ok |
| 1.0 GiB | official-c | one-shot | 2.15 | 2.15 | 2.15 | 2.15 | ok |
| 1.0 GiB | cpu | context-auto | 11.89 | 11.86 | 11.92 | 11.92 | ok |
| 1.0 GiB | blake3 | default-auto | 45.11 | 43.78 | 46.51 | 46.51 | ok |
| 1.0 GiB | metal-file | metal-staged-read-gpu | 12.04 | 12.03 | 12.06 | 12.06 | ok |
jsonOutput=benchmarks/results/20260421T-local-file-reality-madvise/file-metal-staged-read-r1.json
