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
| 4.0 MiB | cpu | scalar | 1.34 | 1.33 | 1.35 | 1.35 | ok |
| 4.0 MiB | cpu | single-simd | 2.13 | 2.11 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.80 | 8.57 | 8.98 | 8.98 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.63 | 2.63 | ok |
| 4.0 MiB | cpu | context-auto | 8.92 | 8.67 | 9.17 | 9.17 | ok |
| 4.0 MiB | blake3 | default-auto | 11.45 | 10.80 | 11.72 | 11.72 | ok |
| 4.0 MiB | metal | resident-auto | 10.49 | 10.19 | 11.13 | 11.13 | ok |
| 4.0 MiB | metal | resident-gpu | 13.27 | 12.04 | 14.20 | 14.20 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.11 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.04 | 11.55 | 12.33 | 12.33 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.63 | 2.63 | ok |
| 8.0 MiB | cpu | context-auto | 11.75 | 11.04 | 12.28 | 12.28 | ok |
| 8.0 MiB | blake3 | default-auto | 17.15 | 16.47 | 18.42 | 18.42 | ok |
| 8.0 MiB | metal | resident-auto | 12.92 | 11.71 | 13.52 | 13.52 | ok |
| 8.0 MiB | metal | resident-gpu | 18.98 | 13.68 | 20.08 | 20.08 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.93 | 13.45 | 14.21 | 14.21 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.59 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.94 | 12.79 | 14.29 | 14.29 | ok |
| 16.0 MiB | blake3 | default-auto | 20.78 | 19.32 | 23.96 | 23.96 | ok |
| 16.0 MiB | metal | resident-auto | 23.96 | 23.14 | 28.22 | 28.22 | ok |
| 16.0 MiB | metal | resident-gpu | 25.03 | 22.90 | 27.49 | 27.49 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-ab/gate-4m-2.json
