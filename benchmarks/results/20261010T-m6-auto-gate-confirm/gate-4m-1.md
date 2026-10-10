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
| 4.0 MiB | cpu | single-simd | 2.13 | 2.10 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.80 | 8.51 | 8.97 | 8.97 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.57 | 2.63 | 2.63 | ok |
| 4.0 MiB | cpu | context-auto | 8.88 | 8.50 | 9.16 | 9.16 | ok |
| 4.0 MiB | blake3 | default-auto | 11.33 | 10.43 | 12.38 | 12.38 | ok |
| 4.0 MiB | metal | resident-auto | 10.60 | 10.31 | 11.34 | 11.34 | ok |
| 4.0 MiB | metal | resident-gpu | 12.30 | 11.64 | 13.31 | 13.31 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.30 | 11.91 | 12.52 | 12.52 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.63 | 2.63 | ok |
| 8.0 MiB | cpu | context-auto | 11.86 | 11.14 | 12.24 | 12.24 | ok |
| 8.0 MiB | blake3 | default-auto | 16.47 | 13.01 | 18.20 | 18.20 | ok |
| 8.0 MiB | metal | resident-auto | 12.88 | 11.48 | 13.29 | 13.29 | ok |
| 8.0 MiB | metal | resident-gpu | 19.80 | 18.19 | 22.02 | 22.02 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.96 | 13.14 | 14.14 | 14.14 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.63 | 2.63 | ok |
| 16.0 MiB | cpu | context-auto | 13.78 | 13.19 | 14.20 | 14.20 | ok |
| 16.0 MiB | blake3 | default-auto | 27.00 | 18.98 | 28.36 | 28.36 | ok |
| 16.0 MiB | metal | resident-auto | 46.70 | 23.34 | 52.13 | 52.13 | ok |
| 16.0 MiB | metal | resident-gpu | 43.34 | 23.51 | 53.82 | 53.82 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate-confirm/gate-4m-1.json
