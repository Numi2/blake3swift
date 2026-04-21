BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.14 | 1.14 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.73 | 1.69 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 10.06 | 9.60 | 10.36 | 10.36 | ok |
| 16.0 MiB | official-c | one-shot | 2.18 | 2.14 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 10.03 | 8.58 | 10.24 | 10.24 | ok |
| 16.0 MiB | blake3 | default-auto | 9.70 | 8.22 | 10.23 | 10.23 | ok |
| 64.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.77 | 1.75 | 1.78 | 1.78 | ok |
| 64.0 MiB | cpu | parallel | 11.30 | 11.19 | 11.81 | 11.81 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 11.30 | 10.99 | 11.79 | 11.79 | ok |
| 64.0 MiB | blake3 | default-auto | 17.62 | 7.40 | 30.87 | 30.87 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 11.82 | 11.71 | 12.06 | 12.06 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 11.88 | 11.64 | 11.91 | 11.91 | ok |
| 256.0 MiB | blake3 | default-auto | 45.93 | 19.54 | 50.82 | 50.82 | ok |
| 512.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.15 | 1.15 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 12.08 | 12.05 | 12.23 | 12.23 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 12.06 | 11.90 | 12.30 | 12.30 | ok |
| 512.0 MiB | blake3 | default-auto | 51.50 | 34.80 | 53.67 | 53.67 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.15 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 1.0 GiB | cpu | parallel | 12.05 | 11.88 | 12.24 | 12.24 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 12.01 | 11.87 | 12.14 | 12.14 | ok |
| 1.0 GiB | blake3 | default-auto | 34.30 | 26.48 | 36.51 | 36.51 | ok |
jsonOutput=benchmarks/results/20260421T-cpu-parallel-task-partition-v2/report.json
