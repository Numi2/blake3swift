BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
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
| 4.0 MiB | cpu | parallel | 8.69 | 8.37 | 8.94 | 8.94 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.58 | 2.62 | 2.62 | ok |
| 4.0 MiB | cpu | context-auto | 8.77 | 8.43 | 8.98 | 8.98 | ok |
| 4.0 MiB | blake3 | default-auto | 8.87 | 8.44 | 9.23 | 9.23 | ok |
| 4.0 MiB | metal | resident-auto | 11.11 | 10.48 | 11.50 | 11.50 | ok |
| 4.0 MiB | metal | resident-gpu | 10.03 | 7.24 | 13.22 | 13.22 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.33 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.12 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.07 | 11.45 | 12.33 | 12.33 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 8.0 MiB | cpu | context-auto | 11.08 | 10.87 | 12.32 | 12.32 | ok |
| 8.0 MiB | blake3 | default-auto | 12.01 | 10.81 | 12.47 | 12.47 | ok |
| 8.0 MiB | metal | resident-auto | 13.11 | 12.72 | 13.66 | 13.66 | ok |
| 8.0 MiB | metal | resident-gpu | 15.23 | 12.30 | 18.74 | 18.74 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.33 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.90 | 12.86 | 14.07 | 14.07 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 14.06 | 13.79 | 14.28 | 14.28 | ok |
| 16.0 MiB | blake3 | default-auto | 21.04 | 20.34 | 32.83 | 32.83 | ok |
| 16.0 MiB | metal | resident-auto | 24.29 | 23.07 | 57.78 | 57.78 | ok |
| 16.0 MiB | metal | resident-gpu | 24.95 | 23.61 | 46.71 | 46.71 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-ab/gate-16m-2.json
