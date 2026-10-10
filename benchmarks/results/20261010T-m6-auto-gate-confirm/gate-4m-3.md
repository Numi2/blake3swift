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
| 4.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 4.0 MiB | cpu | single-simd | 2.12 | 2.11 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.73 | 8.57 | 9.21 | 9.21 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.58 | 2.63 | 2.63 | ok |
| 4.0 MiB | cpu | context-auto | 8.95 | 8.60 | 9.03 | 9.03 | ok |
| 4.0 MiB | blake3 | default-auto | 10.94 | 10.62 | 12.90 | 12.90 | ok |
| 4.0 MiB | metal | resident-auto | 11.13 | 8.96 | 11.52 | 11.52 | ok |
| 4.0 MiB | metal | resident-gpu | 12.73 | 11.97 | 14.30 | 14.30 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.33 | 1.36 | 1.36 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.19 | 11.09 | 12.49 | 12.49 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.59 | 2.62 | 2.62 | ok |
| 8.0 MiB | cpu | context-auto | 12.02 | 11.10 | 12.40 | 12.40 | ok |
| 8.0 MiB | blake3 | default-auto | 15.40 | 13.01 | 18.44 | 18.44 | ok |
| 8.0 MiB | metal | resident-auto | 12.67 | 11.85 | 13.06 | 13.06 | ok |
| 8.0 MiB | metal | resident-gpu | 18.88 | 14.55 | 20.21 | 20.21 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 14.03 | 13.77 | 14.36 | 14.36 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.80 | 12.69 | 13.99 | 13.99 | ok |
| 16.0 MiB | blake3 | default-auto | 20.59 | 18.80 | 25.84 | 25.84 | ok |
| 16.0 MiB | metal | resident-auto | 25.89 | 23.38 | 47.94 | 47.94 | ok |
| 16.0 MiB | metal | resident-gpu | 24.00 | 23.21 | 46.89 | 46.89 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-confirm/gate-4m-3.json
