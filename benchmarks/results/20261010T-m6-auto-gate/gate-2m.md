BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=2097152
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
| 1.0 MiB | cpu | scalar | 1.34 | 1.33 | 1.35 | 1.35 | ok |
| 1.0 MiB | cpu | single-simd | 2.12 | 2.02 | 2.13 | 2.13 | ok |
| 1.0 MiB | cpu | parallel | 5.75 | 5.40 | 5.96 | 5.96 | ok |
| 1.0 MiB | official-c | one-shot | 2.62 | 2.59 | 2.63 | 2.63 | ok |
| 1.0 MiB | cpu | context-auto | 5.70 | 5.35 | 6.12 | 6.12 | ok |
| 1.0 MiB | blake3 | default-auto | 6.00 | 5.63 | 6.37 | 6.37 | ok |
| 1.0 MiB | metal | resident-auto | 8.09 | 3.25 | 8.37 | 8.37 | ok |
| 1.0 MiB | metal | resident-gpu | 2.21 | 1.59 | 3.28 | 3.28 | ok |
| 4.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 4.0 MiB | cpu | single-simd | 2.14 | 2.11 | 2.14 | 2.14 | ok |
| 4.0 MiB | cpu | parallel | 10.01 | 9.87 | 10.23 | 10.23 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.58 | 2.63 | 2.63 | ok |
| 4.0 MiB | cpu | context-auto | 8.81 | 8.51 | 9.11 | 9.11 | ok |
| 4.0 MiB | blake3 | default-auto | 11.93 | 11.12 | 12.61 | 12.61 | ok |
| 4.0 MiB | metal | resident-auto | 10.42 | 9.11 | 11.27 | 11.27 | ok |
| 4.0 MiB | metal | resident-gpu | 12.39 | 11.64 | 12.96 | 12.96 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.12 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.07 | 11.79 | 12.51 | 12.51 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 8.0 MiB | cpu | context-auto | 11.94 | 11.14 | 12.49 | 12.49 | ok |
| 8.0 MiB | blake3 | default-auto | 16.48 | 13.81 | 17.62 | 17.62 | ok |
| 8.0 MiB | metal | resident-auto | 12.80 | 11.22 | 13.07 | 13.07 | ok |
| 8.0 MiB | metal | resident-gpu | 19.07 | 17.28 | 19.67 | 19.67 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 14.00 | 13.13 | 14.33 | 14.33 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.63 | 2.63 | ok |
| 16.0 MiB | cpu | context-auto | 14.09 | 13.85 | 14.22 | 14.22 | ok |
| 16.0 MiB | blake3 | default-auto | 19.67 | 19.15 | 24.14 | 24.14 | ok |
| 16.0 MiB | metal | resident-auto | 24.23 | 23.20 | 28.59 | 28.59 | ok |
| 16.0 MiB | metal | resident-gpu | 24.08 | 23.47 | 24.88 | 24.88 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate/gate-2m.json
