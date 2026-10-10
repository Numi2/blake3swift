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
sizes=1.0 MiB, 4.0 MiB, 8.0 MiB, 16.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 MiB | cpu | scalar | 0.90 | 0.90 | 0.93 | 0.93 | ok |
| 1.0 MiB | cpu | single-simd | 1.53 | 1.50 | 1.63 | 1.63 | ok |
| 1.0 MiB | cpu | parallel | 5.09 | 4.83 | 5.30 | 5.30 | ok |
| 1.0 MiB | official-c | one-shot | 2.15 | 2.07 | 2.15 | 2.15 | ok |
| 1.0 MiB | cpu | context-auto | 5.57 | 5.30 | 5.73 | 5.73 | ok |
| 1.0 MiB | blake3 | default-auto | 5.65 | 5.36 | 5.85 | 5.85 | ok |
| 1.0 MiB | metal | resident-auto | 7.50 | 6.50 | 7.90 | 7.90 | ok |
| 1.0 MiB | metal | resident-gpu | 3.75 | 3.46 | 4.07 | 4.07 | ok |
| 4.0 MiB | cpu | scalar | 1.29 | 1.17 | 1.35 | 1.35 | ok |
| 4.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 4.0 MiB | cpu | parallel | 10.07 | 9.74 | 10.46 | 10.46 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 4.0 MiB | cpu | context-auto | 8.81 | 8.67 | 9.25 | 9.25 | ok |
| 4.0 MiB | blake3 | default-auto | 8.85 | 8.14 | 9.25 | 9.25 | ok |
| 4.0 MiB | metal | resident-auto | 11.00 | 10.34 | 11.32 | 11.32 | ok |
| 4.0 MiB | metal | resident-gpu | 10.97 | 8.06 | 12.89 | 12.89 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 11.97 | 11.29 | 12.18 | 12.18 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 8.0 MiB | cpu | context-auto | 12.12 | 10.68 | 12.47 | 12.47 | ok |
| 8.0 MiB | blake3 | default-auto | 12.18 | 11.68 | 12.28 | 12.28 | ok |
| 8.0 MiB | metal | resident-auto | 13.12 | 11.80 | 13.67 | 13.67 | ok |
| 8.0 MiB | metal | resident-gpu | 17.69 | 13.45 | 21.25 | 21.25 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.85 | 13.27 | 14.02 | 14.02 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.79 | 13.05 | 14.21 | 14.21 | ok |
| 16.0 MiB | blake3 | default-auto | 19.98 | 19.36 | 31.68 | 31.68 | ok |
| 16.0 MiB | metal | resident-auto | 24.85 | 23.71 | 45.41 | 45.41 | ok |
| 16.0 MiB | metal | resident-gpu | 23.92 | 23.54 | 29.79 | 29.79 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate/gate16m.json
