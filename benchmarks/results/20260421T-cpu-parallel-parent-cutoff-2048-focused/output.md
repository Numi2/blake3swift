BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none
cpuWorkers=10

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.17 | 1.16 | 1.18 | 1.18 | ok |
| 64.0 MiB | cpu | single-simd | 1.86 | 1.85 | 1.89 | 1.89 | ok |
| 64.0 MiB | cpu | parallel-10 | 11.77 | 11.37 | 11.85 | 11.85 | ok |
| 64.0 MiB | official-c | one-shot | 2.23 | 2.20 | 2.24 | 2.24 | ok |
| 64.0 MiB | cpu | context-auto | 11.71 | 11.10 | 11.92 | 11.92 | ok |
| 64.0 MiB | blake3 | default-auto | 14.68 | 9.08 | 14.81 | 14.81 | ok |
| 256.0 MiB | cpu | scalar | 1.17 | 1.16 | 1.17 | 1.17 | ok |
| 256.0 MiB | cpu | single-simd | 1.81 | 1.80 | 1.83 | 1.83 | ok |
| 256.0 MiB | cpu | parallel-10 | 12.10 | 11.80 | 12.48 | 12.48 | ok |
| 256.0 MiB | official-c | one-shot | 2.22 | 2.20 | 2.23 | 2.23 | ok |
| 256.0 MiB | cpu | context-auto | 12.27 | 11.96 | 12.46 | 12.46 | ok |
| 256.0 MiB | blake3 | default-auto | 40.01 | 17.13 | 40.78 | 40.78 | ok |
| 512.0 MiB | cpu | scalar | 1.17 | 1.16 | 1.17 | 1.17 | ok |
| 512.0 MiB | cpu | single-simd | 1.80 | 1.79 | 1.81 | 1.81 | ok |
| 512.0 MiB | cpu | parallel-10 | 12.27 | 12.22 | 12.49 | 12.49 | ok |
| 512.0 MiB | official-c | one-shot | 2.20 | 2.19 | 2.21 | 2.21 | ok |
| 512.0 MiB | cpu | context-auto | 12.29 | 12.19 | 12.46 | 12.46 | ok |
| 512.0 MiB | blake3 | default-auto | 58.10 | 53.30 | 58.85 | 58.85 | ok |
| 1.0 GiB | cpu | scalar | 1.17 | 1.16 | 1.17 | 1.17 | ok |
| 1.0 GiB | cpu | single-simd | 1.79 | 1.78 | 1.80 | 1.80 | ok |
| 1.0 GiB | cpu | parallel-10 | 12.34 | 11.71 | 12.43 | 12.43 | ok |
| 1.0 GiB | official-c | one-shot | 2.20 | 2.19 | 2.20 | 2.20 | ok |
| 1.0 GiB | cpu | context-auto | 12.27 | 12.15 | 12.32 | 12.32 | ok |
| 1.0 GiB | blake3 | default-auto | 59.38 | 57.73 | 59.56 | 59.56 | ok |
jsonOutput=benchmarks/results/20260421T-cpu-parallel-parent-cutoff-2048-focused/report.json
