BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=8388608
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=8.0 MiB, 16.0 MiB, 32.0 MiB, 64.0 MiB, 256.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 8.0 MiB | cpu | scalar | 1.05 | 0.45 | 1.10 | 1.10 | ok |
| 8.0 MiB | cpu | single-simd | 1.79 | 1.75 | 1.82 | 1.82 | ok |
| 8.0 MiB | cpu | parallel | 7.13 | 5.67 | 7.35 | 7.35 | ok |
| 8.0 MiB | official-c | one-shot | 2.20 | 2.10 | 2.23 | 2.23 | ok |
| 8.0 MiB | cpu | context-auto | 7.80 | 7.09 | 8.34 | 8.34 | ok |
| 8.0 MiB | blake3 | default-auto | 9.54 | 7.52 | 11.36 | 11.36 | ok |
| 16.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.11 | 1.11 | ok |
| 16.0 MiB | cpu | single-simd | 1.78 | 1.74 | 1.85 | 1.85 | ok |
| 16.0 MiB | cpu | parallel | 8.89 | 7.60 | 9.29 | 9.29 | ok |
| 16.0 MiB | official-c | one-shot | 2.20 | 2.14 | 2.21 | 2.21 | ok |
| 16.0 MiB | cpu | context-auto | 8.94 | 7.58 | 9.30 | 9.30 | ok |
| 16.0 MiB | blake3 | default-auto | 8.60 | 3.02 | 10.17 | 10.17 | ok |
| 32.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 32.0 MiB | cpu | single-simd | 1.78 | 1.75 | 1.80 | 1.80 | ok |
| 32.0 MiB | cpu | parallel | 9.36 | 8.06 | 9.93 | 9.93 | ok |
| 32.0 MiB | official-c | one-shot | 2.18 | 2.16 | 2.20 | 2.20 | ok |
| 32.0 MiB | cpu | context-auto | 9.54 | 8.06 | 9.98 | 9.98 | ok |
| 32.0 MiB | blake3 | default-auto | 19.75 | 12.38 | 24.00 | 24.00 | ok |
| 64.0 MiB | cpu | scalar | 1.08 | 1.08 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.77 | 1.75 | 1.78 | 1.78 | ok |
| 64.0 MiB | cpu | parallel | 10.02 | 8.56 | 10.25 | 10.25 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.99 | 8.31 | 10.56 | 10.56 | ok |
| 64.0 MiB | blake3 | default-auto | 29.24 | 18.37 | 32.50 | 32.50 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.77 | 1.77 | ok |
| 256.0 MiB | cpu | parallel | 10.14 | 9.80 | 10.69 | 10.69 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 9.90 | 8.37 | 10.56 | 10.56 | ok |
| 256.0 MiB | blake3 | default-auto | 34.56 | 16.49 | 41.37 | 41.37 | ok |
jsonOutput=benchmarks/results/20260418T193634Z-default-threshold-confirm/default-gate-8m.json
