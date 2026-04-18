BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB
cpuWorkers=4

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 0.93 | 0.90 | 0.93 | 0.93 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 64.0 MiB | cpu | parallel-4 | 6.43 | 5.72 | 6.52 | 6.52 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.88 | 8.43 | 10.18 | 10.18 | ok |
| 64.0 MiB | blake3 | default-auto | 29.61 | 15.03 | 31.50 | 31.50 | ok |
| 256.0 MiB | cpu | scalar | 1.01 | 0.98 | 1.02 | 1.02 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel-4 | 5.96 | 5.88 | 6.37 | 6.37 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 9.95 | 8.48 | 10.95 | 10.95 | ok |
| 256.0 MiB | blake3 | default-auto | 31.64 | 26.98 | 35.98 | 35.98 | ok |
| 512.0 MiB | cpu | scalar | 1.06 | 1.04 | 1.07 | 1.07 | ok |
| 512.0 MiB | cpu | single-simd | 1.74 | 1.73 | 1.75 | 1.75 | ok |
| 512.0 MiB | cpu | parallel-4 | 6.20 | 6.12 | 6.59 | 6.59 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 10.59 | 10.42 | 11.04 | 11.04 | ok |
| 512.0 MiB | blake3 | default-auto | 32.90 | 31.57 | 36.35 | 36.35 | ok |
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/tuning-grid/cpu-workers-4.json
