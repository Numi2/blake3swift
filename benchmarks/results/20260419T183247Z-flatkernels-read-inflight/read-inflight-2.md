BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB
cryptoKitModes=none
fileModes=read
file-read includes: timed file open/stat, two-buffer bounded read loop, overlapped CPU subtree reductions for regular files, finalize, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.17 | 1.17 | ok |
| 16.0 MiB | cpu | single-simd | 1.83 | 1.80 | 1.90 | 1.90 | ok |
| 16.0 MiB | cpu | parallel | 8.46 | 7.93 | 9.07 | 9.07 | ok |
| 16.0 MiB | official-c | one-shot | 2.25 | 2.18 | 2.29 | 2.29 | ok |
| 16.0 MiB | cpu | context-auto | 9.12 | 7.73 | 9.27 | 9.27 | ok |
| 16.0 MiB | blake3 | default-auto | 15.95 | 11.75 | 19.17 | 19.17 | ok |
| 16.0 MiB | cpu-file | read | 4.03 | 3.90 | 4.41 | 4.41 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.78 | 1.75 | 1.82 | 1.82 | ok |
| 64.0 MiB | cpu | parallel | 9.68 | 9.20 | 10.19 | 10.19 | ok |
| 64.0 MiB | official-c | one-shot | 2.22 | 2.18 | 2.24 | 2.24 | ok |
| 64.0 MiB | cpu | context-auto | 10.15 | 9.48 | 10.31 | 10.31 | ok |
| 64.0 MiB | blake3 | default-auto | 13.12 | 8.48 | 15.08 | 15.08 | ok |
| 64.0 MiB | cpu-file | read | 5.11 | 4.54 | 5.41 | 5.41 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.14 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.78 | 1.78 | 1.79 | 1.79 | ok |
| 256.0 MiB | cpu | parallel | 10.82 | 10.78 | 10.84 | 10.84 | ok |
| 256.0 MiB | official-c | one-shot | 2.19 | 2.18 | 2.20 | 2.20 | ok |
| 256.0 MiB | cpu | context-auto | 10.45 | 10.37 | 10.68 | 10.68 | ok |
| 256.0 MiB | blake3 | default-auto | 31.90 | 19.42 | 38.40 | 38.40 | ok |
| 256.0 MiB | cpu-file | read | 6.74 | 6.50 | 7.05 | 7.05 | ok |
jsonOutput=benchmarks/results/20260419T183247Z-flatkernels-read-inflight/read-inflight-2.json
