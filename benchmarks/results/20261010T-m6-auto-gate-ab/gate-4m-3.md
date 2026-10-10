BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=resident
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=4.0 MiB, 8.0 MiB, 16.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 4.0 MiB | cpu | scalar | 1.35 | 1.33 | 1.35 | 1.35 | ok |
| 4.0 MiB | cpu | single-simd | 2.12 | 2.12 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.70 | 8.49 | 8.87 | 8.87 | ok |
| 4.0 MiB | official-c | one-shot | 2.61 | 2.58 | 2.62 | 2.62 | ok |
| 4.0 MiB | cpu | context-auto | 8.86 | 8.30 | 9.05 | 9.05 | ok |
| 4.0 MiB | blake3 | default-auto | 11.57 | 10.89 | 12.64 | 12.64 | ok |
| 4.0 MiB | metal | resident-auto | 10.45 | 10.23 | 11.52 | 11.52 | ok |
| 4.0 MiB | metal | resident-gpu | 12.30 | 11.62 | 12.41 | 12.41 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.17 | 11.49 | 12.38 | 12.38 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.59 | 2.63 | 2.63 | ok |
| 8.0 MiB | cpu | context-auto | 12.11 | 11.34 | 12.49 | 12.49 | ok |
| 8.0 MiB | blake3 | default-auto | 17.42 | 14.69 | 18.73 | 18.73 | ok |
| 8.0 MiB | metal | resident-auto | 12.72 | 10.11 | 13.68 | 13.68 | ok |
| 8.0 MiB | metal | resident-gpu | 18.72 | 16.61 | 19.62 | 19.62 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.11 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.95 | 13.10 | 14.14 | 14.14 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 14.04 | 13.25 | 14.34 | 14.34 | ok |
| 16.0 MiB | blake3 | default-auto | 21.36 | 20.23 | 30.61 | 30.61 | ok |
| 16.0 MiB | metal | resident-auto | 24.01 | 22.75 | 41.22 | 41.22 | ok |
| 16.0 MiB | metal | resident-gpu | 24.31 | 22.86 | 28.07 | 28.07 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-ab/gate-4m-3.json
