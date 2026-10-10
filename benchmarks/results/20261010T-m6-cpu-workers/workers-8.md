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
cpuWorkers=8

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel-8 | 12.61 | 12.15 | 12.72 | 12.72 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.56 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 16.92 | 16.64 | 17.04 | 17.04 | ok |
| 256.0 MiB | blake3 | default-auto | 61.47 | 42.26 | 69.67 | 69.67 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel-8 | 12.85 | 12.72 | 12.87 | 12.87 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.14 | 16.95 | 17.52 | 17.52 | ok |
| 1.0 GiB | blake3 | default-auto | 78.45 | 76.75 | 78.70 | 78.70 | ok |
jsonOutput=benchmarks/results/20261010T-m6-cpu-workers/workers-8.json
