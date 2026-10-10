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
sizes=1.0 MiB, 4.0 MiB, 8.0 MiB, 16.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 MiB | cpu | scalar | 1.34 | 1.33 | 1.35 | 1.35 | ok |
| 1.0 MiB | cpu | single-simd | 2.10 | 1.99 | 2.12 | 2.12 | ok |
| 1.0 MiB | cpu | parallel | 5.89 | 5.69 | 6.52 | 6.52 | ok |
| 1.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.63 | 2.63 | ok |
| 1.0 MiB | cpu | context-auto | 5.83 | 5.64 | 5.91 | 5.91 | ok |
| 1.0 MiB | blake3 | default-auto | 5.87 | 4.78 | 6.25 | 6.25 | ok |
| 1.0 MiB | metal | resident-auto | 8.08 | 2.85 | 8.46 | 8.46 | ok |
| 1.0 MiB | metal | resident-gpu | 2.83 | 2.08 | 3.40 | 3.40 | ok |
| 4.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 4.0 MiB | cpu | single-simd | 2.14 | 2.12 | 2.14 | 2.14 | ok |
| 4.0 MiB | cpu | parallel | 10.06 | 9.79 | 10.28 | 10.28 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.58 | 2.62 | 2.62 | ok |
| 4.0 MiB | cpu | context-auto | 8.90 | 8.60 | 9.11 | 9.11 | ok |
| 4.0 MiB | blake3 | default-auto | 11.50 | 11.22 | 12.26 | 12.26 | ok |
| 4.0 MiB | metal | resident-auto | 10.43 | 10.30 | 11.14 | 11.14 | ok |
| 4.0 MiB | metal | resident-gpu | 12.27 | 11.95 | 13.90 | 13.90 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.13 | 2.13 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 10.89 | 10.39 | 11.16 | 11.16 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.59 | 2.63 | 2.63 | ok |
| 8.0 MiB | cpu | context-auto | 10.86 | 10.39 | 12.45 | 12.45 | ok |
| 8.0 MiB | blake3 | default-auto | 16.08 | 14.86 | 19.14 | 19.14 | ok |
| 8.0 MiB | metal | resident-auto | 12.99 | 12.23 | 13.51 | 13.51 | ok |
| 8.0 MiB | metal | resident-gpu | 18.79 | 18.19 | 21.14 | 21.14 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.94 | 13.70 | 14.09 | 14.09 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.67 | 13.33 | 14.25 | 14.25 | ok |
| 16.0 MiB | blake3 | default-auto | 20.07 | 18.74 | 21.39 | 21.39 | ok |
| 16.0 MiB | metal | resident-auto | 24.92 | 22.95 | 26.12 | 26.12 | ok |
| 16.0 MiB | metal | resident-gpu | 24.09 | 23.41 | 26.53 | 26.53 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate/gate-4m.json
