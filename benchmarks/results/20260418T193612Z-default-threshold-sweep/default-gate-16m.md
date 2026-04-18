BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=4.0 MiB, 8.0 MiB, 16.0 MiB, 32.0 MiB, 64.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 4.0 MiB | cpu | scalar | 1.07 | 1.02 | 1.11 | 1.11 | ok |
| 4.0 MiB | cpu | single-simd | 1.76 | 1.63 | 1.76 | 1.76 | ok |
| 4.0 MiB | cpu | parallel | 6.22 | 5.96 | 6.85 | 6.85 | ok |
| 4.0 MiB | official-c | one-shot | 2.17 | 1.98 | 2.20 | 2.20 | ok |
| 4.0 MiB | cpu | context-auto | 6.07 | 5.73 | 6.92 | 6.92 | ok |
| 4.0 MiB | blake3 | default-auto | 6.31 | 5.26 | 6.85 | 6.85 | ok |
| 8.0 MiB | cpu | scalar | 1.07 | 1.04 | 1.11 | 1.11 | ok |
| 8.0 MiB | cpu | single-simd | 1.73 | 1.67 | 1.77 | 1.77 | ok |
| 8.0 MiB | cpu | parallel | 7.07 | 5.37 | 8.10 | 8.10 | ok |
| 8.0 MiB | official-c | one-shot | 2.16 | 2.03 | 2.20 | 2.20 | ok |
| 8.0 MiB | cpu | context-auto | 7.12 | 6.31 | 8.25 | 8.25 | ok |
| 8.0 MiB | blake3 | default-auto | 7.59 | 6.13 | 8.23 | 8.23 | ok |
| 16.0 MiB | cpu | scalar | 1.08 | 1.07 | 1.09 | 1.09 | ok |
| 16.0 MiB | cpu | single-simd | 1.74 | 1.70 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 8.84 | 7.10 | 9.26 | 9.26 | ok |
| 16.0 MiB | official-c | one-shot | 2.15 | 2.11 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 8.76 | 6.93 | 9.29 | 9.29 | ok |
| 16.0 MiB | blake3 | default-auto | 15.66 | 5.86 | 17.79 | 17.79 | ok |
| 32.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 32.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 32.0 MiB | cpu | parallel | 8.93 | 8.07 | 9.71 | 9.71 | ok |
| 32.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 32.0 MiB | cpu | context-auto | 9.51 | 8.09 | 9.81 | 9.81 | ok |
| 32.0 MiB | blake3 | default-auto | 22.51 | 11.99 | 25.53 | 25.53 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 10.05 | 8.51 | 10.30 | 10.30 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.71 | 8.32 | 10.18 | 10.18 | ok |
| 64.0 MiB | blake3 | default-auto | 24.57 | 11.61 | 29.17 | 29.17 | ok |
jsonOutput=benchmarks/results/20260418T193612Z-default-threshold-sweep/default-gate-16m.json
