BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=8388608
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=4.0 MiB, 8.0 MiB, 16.0 MiB, 32.0 MiB, 64.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 4.0 MiB | cpu | scalar | 1.07 | 1.01 | 1.11 | 1.11 | ok |
| 4.0 MiB | cpu | single-simd | 1.73 | 1.62 | 1.76 | 1.76 | ok |
| 4.0 MiB | cpu | parallel | 6.09 | 4.93 | 6.58 | 6.58 | ok |
| 4.0 MiB | official-c | one-shot | 2.16 | 2.01 | 2.20 | 2.20 | ok |
| 4.0 MiB | cpu | context-auto | 6.21 | 6.13 | 6.93 | 6.93 | ok |
| 4.0 MiB | blake3 | default-auto | 6.59 | 5.39 | 6.93 | 6.93 | ok |
| 8.0 MiB | cpu | scalar | 1.07 | 1.05 | 1.11 | 1.11 | ok |
| 8.0 MiB | cpu | single-simd | 1.74 | 1.63 | 1.78 | 1.78 | ok |
| 8.0 MiB | cpu | parallel | 7.07 | 5.88 | 8.11 | 8.11 | ok |
| 8.0 MiB | official-c | one-shot | 2.17 | 2.06 | 2.20 | 2.20 | ok |
| 8.0 MiB | cpu | context-auto | 7.11 | 6.05 | 8.09 | 8.09 | ok |
| 8.0 MiB | blake3 | default-auto | 11.65 | 4.53 | 13.41 | 13.41 | ok |
| 16.0 MiB | cpu | scalar | 1.08 | 1.07 | 1.09 | 1.09 | ok |
| 16.0 MiB | cpu | single-simd | 1.74 | 1.69 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 7.98 | 6.99 | 9.19 | 9.19 | ok |
| 16.0 MiB | official-c | one-shot | 2.17 | 2.10 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 8.92 | 7.03 | 9.26 | 9.26 | ok |
| 16.0 MiB | blake3 | default-auto | 16.22 | 13.18 | 18.91 | 18.91 | ok |
| 32.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 32.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.78 | 1.78 | ok |
| 32.0 MiB | cpu | parallel | 9.69 | 8.11 | 9.83 | 9.83 | ok |
| 32.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.19 | 2.19 | ok |
| 32.0 MiB | cpu | context-auto | 9.53 | 8.05 | 9.74 | 9.74 | ok |
| 32.0 MiB | blake3 | default-auto | 23.05 | 21.69 | 26.55 | 26.55 | ok |
| 64.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.76 | 1.74 | 1.77 | 1.77 | ok |
| 64.0 MiB | cpu | parallel | 9.91 | 8.31 | 10.24 | 10.24 | ok |
| 64.0 MiB | official-c | one-shot | 2.19 | 2.18 | 2.19 | 2.19 | ok |
| 64.0 MiB | cpu | context-auto | 10.02 | 8.41 | 10.18 | 10.18 | ok |
| 64.0 MiB | blake3 | default-auto | 28.99 | 16.15 | 32.56 | 32.56 | ok |
jsonOutput=benchmarks/results/20260418T193612Z-default-threshold-sweep/default-gate-8m.json
