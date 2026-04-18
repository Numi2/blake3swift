BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB
cpuWorkers=8

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel-8 | 8.97 | 8.74 | 9.28 | 9.28 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 9.77 | 8.50 | 10.16 | 10.16 | ok |
| 64.0 MiB | blake3 | default-auto | 22.68 | 15.12 | 30.96 | 30.96 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.08 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.72 | 1.55 | 1.73 | 1.73 | ok |
| 256.0 MiB | cpu | parallel-8 | 9.04 | 8.65 | 9.41 | 9.41 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.15 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.12 | 9.43 | 10.56 | 10.56 | ok |
| 256.0 MiB | blake3 | default-auto | 32.12 | 28.13 | 35.41 | 35.41 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 512.0 MiB | cpu | parallel-8 | 9.94 | 9.90 | 10.43 | 10.43 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 10.76 | 10.61 | 11.10 | 11.10 | ok |
| 512.0 MiB | blake3 | default-auto | 35.31 | 32.10 | 37.64 | 37.64 | ok |
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/tuning-grid/cpu-workers-8.json
