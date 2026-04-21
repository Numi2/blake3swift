BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.17 | 1.16 | 1.17 | 1.17 | ok |
| 16.0 MiB | cpu | single-simd | 1.84 | 1.81 | 1.85 | 1.85 | ok |
| 16.0 MiB | cpu | parallel | 10.39 | 10.32 | 10.43 | 10.43 | ok |
| 16.0 MiB | official-c | one-shot | 2.27 | 2.26 | 2.28 | 2.28 | ok |
| 16.0 MiB | cpu | context-auto | 10.04 | 9.92 | 10.33 | 10.33 | ok |
| 16.0 MiB | blake3 | default-auto | 9.30 | 8.50 | 9.57 | 9.57 | ok |
| 64.0 MiB | cpu | scalar | 1.17 | 1.17 | 1.17 | 1.17 | ok |
| 64.0 MiB | cpu | single-simd | 1.80 | 1.80 | 1.85 | 1.85 | ok |
| 64.0 MiB | cpu | parallel | 10.83 | 10.54 | 11.64 | 11.64 | ok |
| 64.0 MiB | official-c | one-shot | 2.24 | 2.23 | 2.24 | 2.24 | ok |
| 64.0 MiB | cpu | context-auto | 11.79 | 11.49 | 11.89 | 11.89 | ok |
| 64.0 MiB | blake3 | default-auto | 14.62 | 9.88 | 15.32 | 15.32 | ok |
| 256.0 MiB | cpu | scalar | 1.17 | 1.17 | 1.17 | 1.17 | ok |
| 256.0 MiB | cpu | single-simd | 1.80 | 1.79 | 1.81 | 1.81 | ok |
| 256.0 MiB | cpu | parallel | 12.38 | 11.85 | 12.58 | 12.58 | ok |
| 256.0 MiB | official-c | one-shot | 2.21 | 2.20 | 2.22 | 2.22 | ok |
| 256.0 MiB | cpu | context-auto | 12.20 | 12.07 | 12.34 | 12.34 | ok |
| 256.0 MiB | blake3 | default-auto | 46.19 | 36.94 | 55.92 | 55.92 | ok |
| 512.0 MiB | cpu | scalar | 1.17 | 1.16 | 1.17 | 1.17 | ok |
| 512.0 MiB | cpu | single-simd | 1.79 | 1.77 | 1.80 | 1.80 | ok |
| 512.0 MiB | cpu | parallel | 12.42 | 12.00 | 12.56 | 12.56 | ok |
| 512.0 MiB | official-c | one-shot | 2.20 | 2.19 | 2.20 | 2.20 | ok |
| 512.0 MiB | cpu | context-auto | 12.34 | 12.32 | 12.44 | 12.44 | ok |
| 512.0 MiB | blake3 | default-auto | 58.27 | 54.64 | 58.50 | 58.50 | ok |
| 1.0 GiB | cpu | scalar | 1.17 | 1.16 | 1.17 | 1.17 | ok |
| 1.0 GiB | cpu | single-simd | 1.79 | 1.78 | 1.79 | 1.79 | ok |
| 1.0 GiB | cpu | parallel | 12.38 | 12.23 | 12.47 | 12.47 | ok |
| 1.0 GiB | official-c | one-shot | 2.20 | 2.20 | 2.20 | 2.20 | ok |
| 1.0 GiB | cpu | context-auto | 12.30 | 12.20 | 12.54 | 12.54 | ok |
| 1.0 GiB | blake3 | default-auto | 59.40 | 58.34 | 60.03 | 60.03 | ok |
jsonOutput=benchmarks/results/20260421T-cpu-parallel-parent-cutoff-2048/report.json
