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
| 4.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 4.0 MiB | cpu | single-simd | 2.12 | 2.12 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.76 | 8.32 | 8.95 | 8.95 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.59 | 2.63 | 2.63 | ok |
| 4.0 MiB | cpu | context-auto | 8.65 | 8.24 | 9.05 | 9.05 | ok |
| 4.0 MiB | blake3 | default-auto | 12.48 | 11.48 | 13.13 | 13.13 | ok |
| 4.0 MiB | metal | resident-auto | 10.54 | 9.08 | 10.95 | 10.95 | ok |
| 4.0 MiB | metal | resident-gpu | 12.90 | 12.19 | 14.59 | 14.59 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.11 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.17 | 11.57 | 12.31 | 12.31 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 8.0 MiB | cpu | context-auto | 12.01 | 11.09 | 12.26 | 12.26 | ok |
| 8.0 MiB | blake3 | default-auto | 16.78 | 15.20 | 18.23 | 18.23 | ok |
| 8.0 MiB | metal | resident-auto | 13.04 | 12.03 | 13.45 | 13.45 | ok |
| 8.0 MiB | metal | resident-gpu | 19.42 | 17.78 | 19.65 | 19.65 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.12 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.96 | 13.54 | 14.13 | 14.13 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.70 | 12.98 | 14.20 | 14.20 | ok |
| 16.0 MiB | blake3 | default-auto | 23.82 | 20.51 | 27.31 | 27.31 | ok |
| 16.0 MiB | metal | resident-auto | 29.89 | 23.26 | 47.25 | 47.25 | ok |
| 16.0 MiB | metal | resident-gpu | 33.68 | 23.00 | 45.68 | 45.68 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-ab/gate-4m-1.json
