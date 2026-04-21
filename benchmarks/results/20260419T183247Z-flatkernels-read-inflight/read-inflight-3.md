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
| 16.0 MiB | cpu | scalar | 1.13 | 1.11 | 1.13 | 1.13 | ok |
| 16.0 MiB | cpu | single-simd | 1.73 | 1.71 | 1.77 | 1.77 | ok |
| 16.0 MiB | cpu | parallel | 8.11 | 6.88 | 9.04 | 9.04 | ok |
| 16.0 MiB | official-c | one-shot | 2.12 | 2.06 | 2.18 | 2.18 | ok |
| 16.0 MiB | cpu | context-auto | 9.09 | 8.11 | 9.36 | 9.36 | ok |
| 16.0 MiB | blake3 | default-auto | 6.90 | 6.00 | 10.44 | 10.44 | ok |
| 16.0 MiB | cpu-file | read | 3.80 | 3.41 | 4.44 | 4.44 | ok |
| 64.0 MiB | cpu | scalar | 1.14 | 1.14 | 1.15 | 1.15 | ok |
| 64.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.88 | 9.42 | 9.99 | 9.99 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 10.11 | 10.07 | 10.28 | 10.28 | ok |
| 64.0 MiB | blake3 | default-auto | 16.21 | 6.84 | 28.76 | 28.76 | ok |
| 64.0 MiB | cpu-file | read | 5.03 | 4.68 | 5.34 | 5.34 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.09 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.77 | 1.76 | 1.77 | 1.77 | ok |
| 256.0 MiB | cpu | parallel | 10.76 | 10.24 | 11.03 | 11.03 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.71 | 9.99 | 10.81 | 10.81 | ok |
| 256.0 MiB | blake3 | default-auto | 40.63 | 25.55 | 50.51 | 50.51 | ok |
| 256.0 MiB | cpu-file | read | 7.06 | 7.03 | 7.11 | 7.11 | ok |
jsonOutput=benchmarks/results/20260419T183247Z-flatkernels-read-inflight/read-inflight-3.json
