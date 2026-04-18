BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB
cpuWorkers=10

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 64.0 MiB | cpu | parallel-10 | 9.91 | 8.31 | 10.14 | 10.14 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 10.15 | 8.39 | 10.33 | 10.33 | ok |
| 64.0 MiB | blake3 | default-auto | 22.36 | 16.63 | 31.67 | 31.67 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel-10 | 10.19 | 9.79 | 10.86 | 10.86 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.51 | 9.64 | 10.84 | 10.84 | ok |
| 256.0 MiB | blake3 | default-auto | 31.97 | 27.13 | 36.04 | 36.04 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.73 | 1.75 | 1.75 | ok |
| 512.0 MiB | cpu | parallel-10 | 10.63 | 10.33 | 10.92 | 10.92 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 10.90 | 10.21 | 11.15 | 11.15 | ok |
| 512.0 MiB | blake3 | default-auto | 32.78 | 29.26 | 37.91 | 37.91 | ok |
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/tuning-grid/cpu-workers-10.json
