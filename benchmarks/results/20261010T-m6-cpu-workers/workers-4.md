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
cpuWorkers=4

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel-4 | 6.85 | 6.79 | 7.45 | 7.45 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.28 | 16.44 | 17.34 | 17.34 | ok |
| 256.0 MiB | blake3 | default-auto | 69.32 | 42.82 | 69.48 | 69.48 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel-4 | 7.54 | 7.15 | 7.56 | 7.56 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.36 | 17.24 | 17.46 | 17.46 | ok |
| 1.0 GiB | blake3 | default-auto | 78.11 | 76.44 | 78.35 | 78.35 | ok |
jsonOutput=benchmarks/results/20261010T-m6-cpu-workers/workers-4.json
