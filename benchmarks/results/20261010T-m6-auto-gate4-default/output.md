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
sizes=1.0 MiB, 4.0 MiB, 8.0 MiB, 16.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 MiB | cpu | scalar | 0.73 | 0.65 | 0.82 | 0.82 | ok |
| 1.0 MiB | cpu | single-simd | 1.30 | 1.28 | 1.30 | 1.30 | ok |
| 1.0 MiB | cpu | parallel | 5.71 | 5.32 | 6.01 | 6.01 | ok |
| 1.0 MiB | official-c | one-shot | 1.84 | 1.75 | 1.90 | 1.90 | ok |
| 1.0 MiB | cpu | context-auto | 5.91 | 4.74 | 6.05 | 6.05 | ok |
| 1.0 MiB | blake3 | default-auto | 4.93 | 4.57 | 5.24 | 5.24 | ok |
| 1.0 MiB | metal | resident-auto | 6.30 | 5.83 | 6.58 | 6.58 | ok |
| 1.0 MiB | metal | resident-gpu | 2.34 | 2.25 | 2.57 | 2.57 | ok |
| 4.0 MiB | cpu | scalar | 1.19 | 1.03 | 1.31 | 1.31 | ok |
| 4.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 4.0 MiB | cpu | parallel | 10.06 | 9.64 | 10.46 | 10.46 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 4.0 MiB | cpu | context-auto | 8.94 | 8.68 | 9.13 | 9.13 | ok |
| 4.0 MiB | blake3 | default-auto | 11.06 | 10.58 | 11.99 | 11.99 | ok |
| 4.0 MiB | metal | resident-auto | 10.44 | 8.64 | 11.23 | 11.23 | ok |
| 4.0 MiB | metal | resident-gpu | 12.36 | 11.79 | 13.47 | 13.47 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.01 | 11.62 | 12.38 | 12.38 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.63 | 2.63 | ok |
| 8.0 MiB | cpu | context-auto | 11.90 | 10.82 | 12.12 | 12.12 | ok |
| 8.0 MiB | blake3 | default-auto | 15.91 | 13.17 | 17.31 | 17.31 | ok |
| 8.0 MiB | metal | resident-auto | 12.56 | 12.51 | 13.34 | 13.34 | ok |
| 8.0 MiB | metal | resident-gpu | 18.82 | 16.37 | 19.72 | 19.72 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.10 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.37 | 13.01 | 14.21 | 14.21 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.73 | 13.14 | 14.15 | 14.15 | ok |
| 16.0 MiB | blake3 | default-auto | 18.70 | 18.32 | 21.65 | 21.65 | ok |
| 16.0 MiB | metal | resident-auto | 22.91 | 22.29 | 27.19 | 27.19 | ok |
| 16.0 MiB | metal | resident-gpu | 23.91 | 23.28 | 24.97 | 24.97 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.22 | 16.98 | 17.43 | 17.43 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.34 | 17.01 | 17.45 | 17.45 | ok |
| 1.0 GiB | blake3 | default-auto | 65.79 | 64.84 | 68.65 | 68.65 | ok |
| 1.0 GiB | metal | resident-auto | 106.17 | 103.11 | 107.04 | 107.04 | ok |
| 1.0 GiB | metal | resident-gpu | 106.78 | 104.80 | 107.03 | 107.03 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate4-default/report.json
