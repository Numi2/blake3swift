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
| 4.0 MiB | cpu | single-simd | 2.12 | 2.11 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.70 | 8.59 | 8.80 | 8.80 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.58 | 2.63 | 2.63 | ok |
| 4.0 MiB | cpu | context-auto | 8.77 | 8.19 | 9.09 | 9.09 | ok |
| 4.0 MiB | blake3 | default-auto | 11.45 | 10.11 | 11.92 | 11.92 | ok |
| 4.0 MiB | metal | resident-auto | 10.51 | 10.34 | 10.63 | 10.63 | ok |
| 4.0 MiB | metal | resident-gpu | 12.00 | 11.56 | 12.75 | 12.75 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.25 | 11.90 | 12.55 | 12.55 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.59 | 2.63 | 2.63 | ok |
| 8.0 MiB | cpu | context-auto | 12.11 | 11.85 | 12.35 | 12.35 | ok |
| 8.0 MiB | blake3 | default-auto | 15.64 | 14.15 | 17.93 | 17.93 | ok |
| 8.0 MiB | metal | resident-auto | 12.97 | 12.17 | 13.54 | 13.54 | ok |
| 8.0 MiB | metal | resident-gpu | 18.47 | 17.38 | 19.65 | 19.65 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 14.01 | 13.73 | 14.22 | 14.22 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 14.02 | 13.67 | 14.19 | 14.19 | ok |
| 16.0 MiB | blake3 | default-auto | 18.77 | 18.33 | 20.33 | 20.33 | ok |
| 16.0 MiB | metal | resident-auto | 23.70 | 23.31 | 25.41 | 25.41 | ok |
| 16.0 MiB | metal | resident-gpu | 24.89 | 23.41 | 27.01 | 27.01 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-confirm/gate-4m-2.json
