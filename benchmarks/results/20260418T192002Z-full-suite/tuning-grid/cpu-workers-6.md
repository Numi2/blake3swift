BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB
cpuWorkers=6

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.07 | 1.05 | 1.09 | 1.09 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 64.0 MiB | cpu | parallel-6 | 7.11 | 7.07 | 7.16 | 7.16 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 9.60 | 8.84 | 10.15 | 10.15 | ok |
| 64.0 MiB | blake3 | default-auto | 24.11 | 16.76 | 32.84 | 32.84 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.55 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel-6 | 7.81 | 7.39 | 8.26 | 8.26 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.57 | 10.32 | 10.94 | 10.94 | ok |
| 256.0 MiB | blake3 | default-auto | 33.09 | 29.26 | 36.37 | 36.37 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.73 | 1.75 | 1.75 | ok |
| 512.0 MiB | cpu | parallel-6 | 8.25 | 7.86 | 8.32 | 8.32 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 11.02 | 10.19 | 11.41 | 11.41 | ok |
| 512.0 MiB | blake3 | default-auto | 34.99 | 31.41 | 38.00 | 38.00 | ok |
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/tuning-grid/cpu-workers-6.json
