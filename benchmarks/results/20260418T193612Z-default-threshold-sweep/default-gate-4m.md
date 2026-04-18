BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=4.0 MiB, 8.0 MiB, 16.0 MiB, 32.0 MiB, 64.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 4.0 MiB | cpu | scalar | 1.09 | 1.04 | 1.10 | 1.10 | ok |
| 4.0 MiB | cpu | single-simd | 1.78 | 1.60 | 1.81 | 1.81 | ok |
| 4.0 MiB | cpu | parallel | 5.85 | 3.99 | 6.36 | 6.36 | ok |
| 4.0 MiB | official-c | one-shot | 2.17 | 2.02 | 2.26 | 2.26 | ok |
| 4.0 MiB | cpu | context-auto | 6.01 | 2.69 | 6.24 | 6.24 | ok |
| 4.0 MiB | blake3 | default-auto | 3.09 | 0.76 | 4.27 | 4.27 | ok |
| 8.0 MiB | cpu | scalar | 1.09 | 0.90 | 1.10 | 1.10 | ok |
| 8.0 MiB | cpu | single-simd | 1.78 | 1.71 | 1.79 | 1.79 | ok |
| 8.0 MiB | cpu | parallel | 8.16 | 7.39 | 8.22 | 8.22 | ok |
| 8.0 MiB | official-c | one-shot | 2.21 | 2.11 | 2.28 | 2.28 | ok |
| 8.0 MiB | cpu | context-auto | 7.40 | 6.98 | 8.43 | 8.43 | ok |
| 8.0 MiB | blake3 | default-auto | 9.57 | 6.59 | 13.52 | 13.52 | ok |
| 16.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.11 | 1.11 | ok |
| 16.0 MiB | cpu | single-simd | 1.78 | 1.73 | 1.84 | 1.84 | ok |
| 16.0 MiB | cpu | parallel | 8.86 | 7.32 | 9.33 | 9.33 | ok |
| 16.0 MiB | official-c | one-shot | 2.19 | 2.13 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 9.05 | 7.54 | 9.23 | 9.23 | ok |
| 16.0 MiB | blake3 | default-auto | 15.15 | 9.68 | 17.81 | 17.81 | ok |
| 32.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 32.0 MiB | cpu | single-simd | 1.78 | 1.75 | 1.80 | 1.80 | ok |
| 32.0 MiB | cpu | parallel | 9.51 | 8.02 | 9.74 | 9.74 | ok |
| 32.0 MiB | official-c | one-shot | 2.19 | 2.17 | 2.19 | 2.19 | ok |
| 32.0 MiB | cpu | context-auto | 9.28 | 8.02 | 9.90 | 9.90 | ok |
| 32.0 MiB | blake3 | default-auto | 20.44 | 15.34 | 23.82 | 23.82 | ok |
| 64.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.77 | 1.76 | 1.78 | 1.78 | ok |
| 64.0 MiB | cpu | parallel | 8.85 | 8.01 | 10.21 | 10.21 | ok |
| 64.0 MiB | official-c | one-shot | 2.15 | 2.14 | 2.16 | 2.16 | ok |
| 64.0 MiB | cpu | context-auto | 9.13 | 8.37 | 10.19 | 10.19 | ok |
| 64.0 MiB | blake3 | default-auto | 20.07 | 7.49 | 26.06 | 26.06 | ok |
jsonOutput=benchmarks/results/20260418T193612Z-default-threshold-sweep/default-gate-4m.json
