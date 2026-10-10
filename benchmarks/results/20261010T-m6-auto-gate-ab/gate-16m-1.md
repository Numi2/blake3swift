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
| 4.0 MiB | cpu | scalar | 1.18 | 1.02 | 1.31 | 1.31 | ok |
| 4.0 MiB | cpu | single-simd | 2.12 | 2.11 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.71 | 8.31 | 8.96 | 8.96 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.63 | 2.63 | ok |
| 4.0 MiB | cpu | context-auto | 8.76 | 8.30 | 9.00 | 9.00 | ok |
| 4.0 MiB | blake3 | default-auto | 8.84 | 8.29 | 9.06 | 9.06 | ok |
| 4.0 MiB | metal | resident-auto | 10.98 | 9.03 | 11.35 | 11.35 | ok |
| 4.0 MiB | metal | resident-gpu | 9.43 | 7.14 | 13.02 | 13.02 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 11.26 | 10.16 | 12.28 | 12.28 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 8.0 MiB | cpu | context-auto | 10.88 | 10.56 | 11.57 | 11.57 | ok |
| 8.0 MiB | blake3 | default-auto | 11.86 | 10.78 | 12.20 | 12.20 | ok |
| 8.0 MiB | metal | resident-auto | 13.11 | 12.19 | 13.65 | 13.65 | ok |
| 8.0 MiB | metal | resident-gpu | 15.00 | 12.42 | 20.06 | 20.06 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 14.05 | 13.55 | 14.20 | 14.20 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.81 | 13.65 | 14.07 | 14.07 | ok |
| 16.0 MiB | blake3 | default-auto | 21.07 | 20.35 | 22.03 | 22.03 | ok |
| 16.0 MiB | metal | resident-auto | 23.07 | 22.31 | 24.68 | 24.68 | ok |
| 16.0 MiB | metal | resident-gpu | 23.69 | 22.90 | 26.17 | 26.17 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-ab/gate-16m-1.json
