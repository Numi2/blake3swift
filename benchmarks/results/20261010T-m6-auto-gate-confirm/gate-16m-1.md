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
| 4.0 MiB | cpu | scalar | 1.13 | 0.97 | 1.31 | 1.31 | ok |
| 4.0 MiB | cpu | single-simd | 2.13 | 2.12 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.75 | 8.50 | 9.01 | 9.01 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.63 | 2.63 | ok |
| 4.0 MiB | cpu | context-auto | 8.75 | 8.57 | 8.89 | 8.89 | ok |
| 4.0 MiB | blake3 | default-auto | 8.78 | 8.58 | 9.10 | 9.10 | ok |
| 4.0 MiB | metal | resident-auto | 11.05 | 10.28 | 11.18 | 11.18 | ok |
| 4.0 MiB | metal | resident-gpu | 11.08 | 7.57 | 13.86 | 13.86 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.12 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.06 | 11.87 | 12.42 | 12.42 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 8.0 MiB | cpu | context-auto | 11.90 | 11.28 | 12.49 | 12.49 | ok |
| 8.0 MiB | blake3 | default-auto | 12.19 | 11.21 | 12.30 | 12.30 | ok |
| 8.0 MiB | metal | resident-auto | 13.23 | 12.03 | 13.47 | 13.47 | ok |
| 8.0 MiB | metal | resident-gpu | 15.96 | 11.96 | 18.53 | 18.53 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 14.18 | 13.95 | 14.36 | 14.36 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.82 | 13.09 | 14.12 | 14.12 | ok |
| 16.0 MiB | blake3 | default-auto | 19.34 | 18.62 | 21.89 | 21.89 | ok |
| 16.0 MiB | metal | resident-auto | 23.98 | 23.22 | 26.26 | 26.26 | ok |
| 16.0 MiB | metal | resident-gpu | 25.61 | 23.46 | 27.91 | 27.91 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-confirm/gate-16m-1.json
