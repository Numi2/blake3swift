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
| 256.0 MiB | cpu | scalar | 1.13 | 1.03 | 1.13 | 1.13 | ok |
| 256.0 MiB | cpu | single-simd | 1.72 | 1.72 | 1.72 | 1.72 | ok |
| 256.0 MiB | cpu | parallel | 10.74 | 10.37 | 10.91 | 10.91 | ok |
| 256.0 MiB | official-c | one-shot | 2.12 | 1.52 | 2.13 | 2.13 | ok |
| 256.0 MiB | cpu | context-auto | 10.95 | 10.33 | 11.37 | 11.37 | ok |
| 256.0 MiB | blake3 | default-auto | 11.66 | 11.39 | 21.21 | 21.21 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.83 | 4.73 | 5.06 | 5.06 | ok |
| 1.0 GiB | cpu | scalar | 1.13 | 1.13 | 1.13 | 1.13 | ok |
| 1.0 GiB | cpu | single-simd | 1.72 | 1.72 | 1.72 | 1.72 | ok |
| 1.0 GiB | cpu | parallel | 10.98 | 10.63 | 11.17 | 11.17 | ok |
| 1.0 GiB | official-c | one-shot | 2.12 | 2.12 | 2.13 | 2.13 | ok |
| 1.0 GiB | cpu | context-auto | 10.94 | 10.92 | 11.13 | 11.13 | ok |
| 1.0 GiB | blake3 | default-auto | 30.23 | 25.98 | 38.44 | 38.44 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 4.68 | 0.47 | 4.86 | 4.86 | ok |
jsonOutput=benchmarks/results/20260421T-local-file-pretouch-on/file-metal-tiled-mmap-r1.json
