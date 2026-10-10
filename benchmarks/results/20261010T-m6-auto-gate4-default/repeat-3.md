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
| 4.0 MiB | cpu | scalar | 1.35 | 1.32 | 1.35 | 1.35 | ok |
| 4.0 MiB | cpu | single-simd | 2.12 | 2.12 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.63 | 8.23 | 9.09 | 9.09 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.58 | 2.63 | 2.63 | ok |
| 4.0 MiB | cpu | context-auto | 8.78 | 8.17 | 9.22 | 9.22 | ok |
| 4.0 MiB | blake3 | default-auto | 11.86 | 10.73 | 12.59 | 12.59 | ok |
| 4.0 MiB | metal | resident-auto | 10.57 | 10.02 | 11.26 | 11.26 | ok |
| 4.0 MiB | metal | resident-gpu | 12.94 | 12.47 | 14.49 | 14.49 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.13 | 2.12 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.11 | 11.83 | 12.62 | 12.62 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 8.0 MiB | cpu | context-auto | 11.97 | 10.95 | 12.37 | 12.37 | ok |
| 8.0 MiB | blake3 | default-auto | 16.65 | 15.00 | 17.76 | 17.76 | ok |
| 8.0 MiB | metal | resident-auto | 12.79 | 12.18 | 13.39 | 13.39 | ok |
| 8.0 MiB | metal | resident-gpu | 18.56 | 17.34 | 19.74 | 19.74 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.92 | 13.55 | 14.19 | 14.19 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.90 | 13.28 | 14.54 | 14.54 | ok |
| 16.0 MiB | blake3 | default-auto | 19.16 | 18.08 | 28.36 | 28.36 | ok |
| 16.0 MiB | metal | resident-auto | 24.51 | 23.62 | 36.64 | 36.64 | ok |
| 16.0 MiB | metal | resident-gpu | 25.14 | 23.74 | 27.95 | 27.95 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate4-default/repeat-3.json
