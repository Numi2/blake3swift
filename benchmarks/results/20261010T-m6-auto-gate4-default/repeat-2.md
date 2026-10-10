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
| 4.0 MiB | cpu | scalar | 1.18 | 1.03 | 1.31 | 1.31 | ok |
| 4.0 MiB | cpu | single-simd | 2.12 | 2.11 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.80 | 8.56 | 8.87 | 8.87 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.63 | 2.63 | ok |
| 4.0 MiB | cpu | context-auto | 8.81 | 8.62 | 9.13 | 9.13 | ok |
| 4.0 MiB | blake3 | default-auto | 11.29 | 10.90 | 11.70 | 11.70 | ok |
| 4.0 MiB | metal | resident-auto | 10.69 | 10.11 | 11.36 | 11.36 | ok |
| 4.0 MiB | metal | resident-gpu | 12.58 | 11.99 | 13.91 | 13.91 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.13 | 2.13 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.08 | 11.52 | 12.38 | 12.38 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.59 | 2.63 | 2.63 | ok |
| 8.0 MiB | cpu | context-auto | 12.08 | 11.39 | 12.44 | 12.44 | ok |
| 8.0 MiB | blake3 | default-auto | 16.19 | 14.10 | 17.87 | 17.87 | ok |
| 8.0 MiB | metal | resident-auto | 12.78 | 12.21 | 13.05 | 13.05 | ok |
| 8.0 MiB | metal | resident-gpu | 19.42 | 16.21 | 21.52 | 21.52 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.93 | 12.75 | 14.27 | 14.27 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.63 | 2.63 | ok |
| 16.0 MiB | cpu | context-auto | 13.85 | 12.98 | 14.06 | 14.06 | ok |
| 16.0 MiB | blake3 | default-auto | 19.70 | 18.62 | 20.66 | 20.66 | ok |
| 16.0 MiB | metal | resident-auto | 25.23 | 23.23 | 27.00 | 27.00 | ok |
| 16.0 MiB | metal | resident-gpu | 24.47 | 23.43 | 26.10 | 26.10 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate4-default/repeat-2.json
