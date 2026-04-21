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
| 16.0 MiB | cpu | scalar | 1.15 | 1.13 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.74 | 1.73 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 9.25 | 7.61 | 9.33 | 9.33 | ok |
| 16.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 8.74 | 8.00 | 9.35 | 9.35 | ok |
| 16.0 MiB | blake3 | default-auto | 10.17 | 8.84 | 11.19 | 11.19 | ok |
| 16.0 MiB | cpu-file | read | 4.03 | 3.89 | 4.40 | 4.40 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.84 | 8.43 | 10.37 | 10.37 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 10.18 | 9.62 | 10.30 | 10.30 | ok |
| 64.0 MiB | blake3 | default-auto | 15.42 | 8.11 | 29.71 | 29.71 | ok |
| 64.0 MiB | cpu-file | read | 5.04 | 4.52 | 5.43 | 5.43 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.77 | 1.76 | 1.77 | 1.77 | ok |
| 256.0 MiB | cpu | parallel | 10.50 | 10.19 | 10.81 | 10.81 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.14 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.58 | 10.13 | 10.79 | 10.79 | ok |
| 256.0 MiB | blake3 | default-auto | 39.02 | 29.29 | 52.38 | 52.38 | ok |
| 256.0 MiB | cpu-file | read | 7.09 | 6.74 | 7.14 | 7.14 | ok |
jsonOutput=benchmarks/results/20260419T183247Z-flatkernels-read-inflight/read-inflight-4.json
