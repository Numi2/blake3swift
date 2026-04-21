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
| 16.0 MiB | cpu | scalar | 1.14 | 1.13 | 1.15 | 1.15 | ok |
| 16.0 MiB | cpu | single-simd | 1.71 | 1.47 | 1.74 | 1.74 | ok |
| 16.0 MiB | cpu | parallel | 9.72 | 8.25 | 9.79 | 9.79 | ok |
| 16.0 MiB | official-c | one-shot | 2.16 | 2.12 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 9.74 | 8.53 | 9.84 | 9.84 | ok |
| 16.0 MiB | blake3 | default-auto | 9.23 | 7.31 | 11.00 | 11.00 | ok |
| 64.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.73 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 10.83 | 10.55 | 10.87 | 10.87 | ok |
| 64.0 MiB | official-c | one-shot | 2.16 | 2.16 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 10.86 | 10.43 | 10.98 | 10.98 | ok |
| 64.0 MiB | blake3 | default-auto | 22.01 | 12.41 | 28.75 | 28.75 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.15 | 1.15 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 11.30 | 11.13 | 11.42 | 11.42 | ok |
| 256.0 MiB | official-c | one-shot | 2.15 | 2.15 | 2.16 | 2.16 | ok |
| 256.0 MiB | cpu | context-auto | 11.27 | 11.05 | 11.35 | 11.35 | ok |
| 256.0 MiB | blake3 | default-auto | 41.18 | 30.01 | 50.24 | 50.24 | ok |
| 512.0 MiB | cpu | scalar | 1.13 | 1.12 | 1.15 | 1.15 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 512.0 MiB | cpu | parallel | 11.52 | 11.21 | 11.61 | 11.61 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 11.54 | 11.29 | 12.02 | 12.02 | ok |
| 512.0 MiB | blake3 | default-auto | 47.84 | 34.45 | 48.50 | 48.50 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.15 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 11.57 | 11.40 | 12.03 | 12.03 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 11.75 | 11.67 | 11.81 | 11.81 | ok |
| 1.0 GiB | blake3 | default-auto | 47.13 | 44.84 | 51.85 | 51.85 | ok |
jsonOutput=benchmarks/results/20260421T-cpu-parallel-task-partition/report.json
