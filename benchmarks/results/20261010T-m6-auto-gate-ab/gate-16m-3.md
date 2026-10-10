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
| 4.0 MiB | cpu | parallel | 8.70 | 8.61 | 8.88 | 8.88 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.58 | 2.62 | 2.62 | ok |
| 4.0 MiB | cpu | context-auto | 8.86 | 8.46 | 9.14 | 9.14 | ok |
| 4.0 MiB | blake3 | default-auto | 8.69 | 8.30 | 9.02 | 9.02 | ok |
| 4.0 MiB | metal | resident-auto | 11.10 | 10.43 | 11.29 | 11.29 | ok |
| 4.0 MiB | metal | resident-gpu | 9.83 | 7.19 | 13.65 | 13.65 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.33 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 11.99 | 11.38 | 12.30 | 12.30 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 8.0 MiB | cpu | context-auto | 11.92 | 11.41 | 12.24 | 12.24 | ok |
| 8.0 MiB | blake3 | default-auto | 11.29 | 10.57 | 11.91 | 11.91 | ok |
| 8.0 MiB | metal | resident-auto | 13.09 | 12.18 | 13.43 | 13.43 | ok |
| 8.0 MiB | metal | resident-gpu | 15.66 | 12.14 | 18.95 | 18.95 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.99 | 13.06 | 14.42 | 14.42 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 14.07 | 13.91 | 14.20 | 14.20 | ok |
| 16.0 MiB | blake3 | default-auto | 20.43 | 20.16 | 22.19 | 22.19 | ok |
| 16.0 MiB | metal | resident-auto | 23.39 | 22.89 | 24.45 | 24.45 | ok |
| 16.0 MiB | metal | resident-gpu | 24.27 | 22.98 | 26.03 | 26.03 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-ab/gate-16m-3.json
