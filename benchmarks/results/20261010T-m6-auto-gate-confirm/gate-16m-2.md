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
| 4.0 MiB | cpu | scalar | 1.34 | 1.33 | 1.35 | 1.35 | ok |
| 4.0 MiB | cpu | single-simd | 2.12 | 2.11 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.79 | 8.28 | 9.21 | 9.21 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.59 | 2.63 | 2.63 | ok |
| 4.0 MiB | cpu | context-auto | 8.84 | 8.70 | 9.05 | 9.05 | ok |
| 4.0 MiB | blake3 | default-auto | 8.84 | 8.44 | 9.11 | 9.11 | ok |
| 4.0 MiB | metal | resident-auto | 10.51 | 10.31 | 11.38 | 11.38 | ok |
| 4.0 MiB | metal | resident-gpu | 9.19 | 7.16 | 12.52 | 12.52 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.12 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.12 | 11.42 | 12.55 | 12.55 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.63 | 2.63 | ok |
| 8.0 MiB | cpu | context-auto | 12.19 | 11.36 | 12.32 | 12.32 | ok |
| 8.0 MiB | blake3 | default-auto | 11.77 | 10.61 | 12.25 | 12.25 | ok |
| 8.0 MiB | metal | resident-auto | 13.26 | 12.88 | 13.75 | 13.75 | ok |
| 8.0 MiB | metal | resident-gpu | 16.49 | 10.86 | 20.58 | 20.58 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.91 | 13.48 | 14.20 | 14.20 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.63 | 2.63 | ok |
| 16.0 MiB | cpu | context-auto | 13.96 | 13.71 | 14.15 | 14.15 | ok |
| 16.0 MiB | blake3 | default-auto | 20.78 | 19.06 | 29.28 | 29.28 | ok |
| 16.0 MiB | metal | resident-auto | 25.61 | 22.69 | 54.43 | 54.43 | ok |
| 16.0 MiB | metal | resident-gpu | 25.15 | 23.44 | 55.27 | 55.27 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-confirm/gate-16m-2.json
