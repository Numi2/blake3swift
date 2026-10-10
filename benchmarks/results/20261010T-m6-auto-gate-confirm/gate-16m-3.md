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
| 4.0 MiB | cpu | parallel | 8.95 | 8.31 | 9.15 | 9.15 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.56 | 2.62 | 2.62 | ok |
| 4.0 MiB | cpu | context-auto | 8.95 | 8.62 | 9.24 | 9.24 | ok |
| 4.0 MiB | blake3 | default-auto | 8.90 | 8.68 | 9.23 | 9.23 | ok |
| 4.0 MiB | metal | resident-auto | 10.94 | 10.57 | 11.31 | 11.31 | ok |
| 4.0 MiB | metal | resident-gpu | 10.02 | 7.22 | 13.06 | 13.06 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.12 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.17 | 11.85 | 12.43 | 12.43 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 8.0 MiB | cpu | context-auto | 11.97 | 10.92 | 12.35 | 12.35 | ok |
| 8.0 MiB | blake3 | default-auto | 12.10 | 11.51 | 12.43 | 12.43 | ok |
| 8.0 MiB | metal | resident-auto | 13.14 | 12.32 | 13.53 | 13.53 | ok |
| 8.0 MiB | metal | resident-gpu | 15.45 | 10.24 | 20.87 | 20.87 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.98 | 13.09 | 14.12 | 14.12 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.59 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.41 | 13.24 | 14.02 | 14.02 | ok |
| 16.0 MiB | blake3 | default-auto | 19.59 | 18.65 | 20.54 | 20.54 | ok |
| 16.0 MiB | metal | resident-auto | 23.59 | 22.96 | 26.59 | 26.59 | ok |
| 16.0 MiB | metal | resident-gpu | 23.94 | 23.09 | 25.62 | 25.62 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-confirm/gate-16m-3.json
