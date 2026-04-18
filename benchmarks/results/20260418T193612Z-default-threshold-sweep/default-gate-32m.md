BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=4.0 MiB, 8.0 MiB, 16.0 MiB, 32.0 MiB, 64.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 4.0 MiB | cpu | scalar | 1.06 | 0.92 | 1.10 | 1.10 | ok |
| 4.0 MiB | cpu | single-simd | 1.74 | 1.59 | 1.76 | 1.76 | ok |
| 4.0 MiB | cpu | parallel | 6.26 | 6.17 | 6.85 | 6.85 | ok |
| 4.0 MiB | official-c | one-shot | 2.18 | 2.08 | 2.20 | 2.20 | ok |
| 4.0 MiB | cpu | context-auto | 6.09 | 5.74 | 6.77 | 6.77 | ok |
| 4.0 MiB | blake3 | default-auto | 6.44 | 6.17 | 7.01 | 7.01 | ok |
| 8.0 MiB | cpu | scalar | 1.08 | 1.04 | 1.10 | 1.10 | ok |
| 8.0 MiB | cpu | single-simd | 1.71 | 1.65 | 1.76 | 1.76 | ok |
| 8.0 MiB | cpu | parallel | 7.49 | 6.68 | 8.13 | 8.13 | ok |
| 8.0 MiB | official-c | one-shot | 2.16 | 2.06 | 2.19 | 2.19 | ok |
| 8.0 MiB | cpu | context-auto | 7.10 | 6.33 | 8.17 | 8.17 | ok |
| 8.0 MiB | blake3 | default-auto | 7.40 | 7.03 | 8.05 | 8.05 | ok |
| 16.0 MiB | cpu | scalar | 1.08 | 1.07 | 1.09 | 1.09 | ok |
| 16.0 MiB | cpu | single-simd | 1.73 | 1.69 | 1.77 | 1.77 | ok |
| 16.0 MiB | cpu | parallel | 9.02 | 6.94 | 9.15 | 9.15 | ok |
| 16.0 MiB | official-c | one-shot | 2.17 | 2.10 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 8.91 | 7.73 | 9.23 | 9.23 | ok |
| 16.0 MiB | blake3 | default-auto | 8.80 | 6.93 | 9.18 | 9.18 | ok |
| 32.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 32.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.77 | 1.77 | ok |
| 32.0 MiB | cpu | parallel | 9.32 | 7.57 | 9.84 | 9.84 | ok |
| 32.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.20 | 2.20 | ok |
| 32.0 MiB | cpu | context-auto | 9.20 | 7.75 | 9.77 | 9.77 | ok |
| 32.0 MiB | blake3 | default-auto | 20.94 | 8.97 | 22.78 | 22.78 | ok |
| 64.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.90 | 8.66 | 10.25 | 10.25 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.98 | 8.63 | 10.35 | 10.35 | ok |
| 64.0 MiB | blake3 | default-auto | 26.47 | 20.33 | 30.79 | 30.79 | ok |
jsonOutput=benchmarks/results/20260418T193612Z-default-threshold-sweep/default-gate-32m.json
