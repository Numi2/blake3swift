BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=
sizes=256.0 MiB, 1.0 GiB
cryptoKitModes=none
cpuWorkers=10

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel-10 | 15.18 | 14.79 | 15.29 | 15.29 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.19 | 16.98 | 17.39 | 17.39 | ok |
| 256.0 MiB | blake3 | default-auto | 58.36 | 45.15 | 64.90 | 64.90 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel-10 | 15.30 | 15.05 | 15.41 | 15.41 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.36 | 17.33 | 17.50 | 17.50 | ok |
| 1.0 GiB | blake3 | default-auto | 78.57 | 76.83 | 78.95 | 78.95 | ok |
jsonOutput=benchmarks/results/20261010T-m6-cpu-workers/workers-10.json
