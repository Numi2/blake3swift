BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=8.0 MiB, 16.0 MiB, 32.0 MiB, 64.0 MiB, 256.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 8.0 MiB | cpu | scalar | 1.07 | 1.02 | 1.10 | 1.10 | ok |
| 8.0 MiB | cpu | single-simd | 1.74 | 1.64 | 1.77 | 1.77 | ok |
| 8.0 MiB | cpu | parallel | 7.42 | 6.04 | 8.10 | 8.10 | ok |
| 8.0 MiB | official-c | one-shot | 2.15 | 2.03 | 2.20 | 2.20 | ok |
| 8.0 MiB | cpu | context-auto | 7.05 | 6.06 | 8.27 | 8.27 | ok |
| 8.0 MiB | blake3 | default-auto | 7.49 | 5.47 | 8.18 | 8.18 | ok |
| 16.0 MiB | cpu | scalar | 1.08 | 1.07 | 1.09 | 1.09 | ok |
| 16.0 MiB | cpu | single-simd | 1.74 | 1.71 | 1.77 | 1.77 | ok |
| 16.0 MiB | cpu | parallel | 8.93 | 7.70 | 9.22 | 9.22 | ok |
| 16.0 MiB | official-c | one-shot | 2.17 | 2.14 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 8.86 | 7.69 | 9.16 | 9.16 | ok |
| 16.0 MiB | blake3 | default-auto | 8.17 | 7.27 | 9.29 | 9.29 | ok |
| 32.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 32.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 32.0 MiB | cpu | parallel | 9.39 | 8.02 | 9.89 | 9.89 | ok |
| 32.0 MiB | official-c | one-shot | 2.17 | 2.08 | 2.19 | 2.19 | ok |
| 32.0 MiB | cpu | context-auto | 9.34 | 8.17 | 9.85 | 9.85 | ok |
| 32.0 MiB | blake3 | default-auto | 22.41 | 8.19 | 26.80 | 26.80 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 0.82 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 10.03 | 8.34 | 10.24 | 10.24 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.76 | 8.35 | 10.18 | 10.18 | ok |
| 64.0 MiB | blake3 | default-auto | 23.84 | 9.76 | 27.71 | 27.71 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.04 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.44 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 10.16 | 9.32 | 10.58 | 10.58 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 9.96 | 9.65 | 10.53 | 10.53 | ok |
| 256.0 MiB | blake3 | default-auto | 29.87 | 13.67 | 35.23 | 35.23 | ok |
jsonOutput=benchmarks/results/20260418T193634Z-default-threshold-confirm/default-gate-32m.json
