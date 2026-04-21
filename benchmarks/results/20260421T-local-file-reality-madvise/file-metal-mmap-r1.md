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
fileModes=metal-mmap
file-metal-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, GPU hash wait, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.14 | 1.12 | 1.15 | 1.15 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 11.65 | 11.45 | 11.76 | 11.76 | ok |
| 256.0 MiB | official-c | one-shot | 2.16 | 2.16 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 11.77 | 11.65 | 11.90 | 11.90 | ok |
| 256.0 MiB | blake3 | default-auto | 30.11 | 27.88 | 31.84 | 31.84 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 7.04 | 6.09 | 7.09 | 7.09 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.14 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.75 | 1.71 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 11.93 | 11.85 | 12.02 | 12.02 | ok |
| 1.0 GiB | official-c | one-shot | 2.16 | 2.16 | 2.16 | 2.16 | ok |
| 1.0 GiB | cpu | context-auto | 12.03 | 11.92 | 12.06 | 12.06 | ok |
| 1.0 GiB | blake3 | default-auto | 36.92 | 36.50 | 39.05 | 39.05 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 7.01 | 6.37 | 7.08 | 7.08 | ok |
jsonOutput=benchmarks/results/20260421T-local-file-reality-madvise/file-metal-mmap-r1.json
