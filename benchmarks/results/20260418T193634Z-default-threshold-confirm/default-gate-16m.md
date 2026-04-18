BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=8.0 MiB, 16.0 MiB, 32.0 MiB, 64.0 MiB, 256.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 8.0 MiB | cpu | scalar | 1.07 | 1.04 | 1.10 | 1.10 | ok |
| 8.0 MiB | cpu | single-simd | 1.70 | 1.67 | 1.77 | 1.77 | ok |
| 8.0 MiB | cpu | parallel | 7.08 | 5.45 | 8.19 | 8.19 | ok |
| 8.0 MiB | official-c | one-shot | 2.14 | 2.07 | 2.20 | 2.20 | ok |
| 8.0 MiB | cpu | context-auto | 7.14 | 5.99 | 8.10 | 8.10 | ok |
| 8.0 MiB | blake3 | default-auto | 7.10 | 5.36 | 8.32 | 8.32 | ok |
| 16.0 MiB | cpu | scalar | 1.08 | 1.07 | 1.10 | 1.10 | ok |
| 16.0 MiB | cpu | single-simd | 1.74 | 1.71 | 1.77 | 1.77 | ok |
| 16.0 MiB | cpu | parallel | 8.87 | 7.30 | 9.23 | 9.23 | ok |
| 16.0 MiB | official-c | one-shot | 2.18 | 2.12 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 8.85 | 7.65 | 9.19 | 9.19 | ok |
| 16.0 MiB | blake3 | default-auto | 8.64 | 2.13 | 9.91 | 9.91 | ok |
| 32.0 MiB | cpu | scalar | 1.09 | 1.06 | 1.10 | 1.10 | ok |
| 32.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 32.0 MiB | cpu | parallel | 9.51 | 8.06 | 9.96 | 9.96 | ok |
| 32.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.19 | 2.19 | ok |
| 32.0 MiB | cpu | context-auto | 9.48 | 8.09 | 9.94 | 9.94 | ok |
| 32.0 MiB | blake3 | default-auto | 19.66 | 5.84 | 21.59 | 21.59 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.73 | 8.36 | 10.22 | 10.22 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.65 | 8.35 | 10.26 | 10.26 | ok |
| 64.0 MiB | blake3 | default-auto | 26.78 | 12.76 | 29.63 | 29.63 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.09 | 9.54 | 10.81 | 10.81 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.24 | 9.77 | 10.81 | 10.81 | ok |
| 256.0 MiB | blake3 | default-auto | 25.98 | 19.39 | 30.88 | 30.88 | ok |
jsonOutput=benchmarks/results/20260418T193634Z-default-threshold-confirm/default-gate-16m.json
