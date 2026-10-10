BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=8388608
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
| 1.0 MiB | cpu | scalar | 0.96 | 0.90 | 1.00 | 1.00 | ok |
| 1.0 MiB | cpu | single-simd | 1.64 | 1.61 | 1.74 | 1.74 | ok |
| 1.0 MiB | cpu | parallel | 5.37 | 5.00 | 5.56 | 5.56 | ok |
| 1.0 MiB | official-c | one-shot | 2.24 | 2.13 | 2.24 | 2.24 | ok |
| 1.0 MiB | cpu | context-auto | 5.63 | 5.29 | 5.77 | 5.77 | ok |
| 1.0 MiB | blake3 | default-auto | 5.49 | 4.98 | 5.92 | 5.92 | ok |
| 1.0 MiB | metal | resident-auto | 7.70 | 6.72 | 8.06 | 8.06 | ok |
| 1.0 MiB | metal | resident-gpu | 3.63 | 3.40 | 4.02 | 4.02 | ok |
| 4.0 MiB | cpu | scalar | 1.33 | 1.20 | 1.35 | 1.35 | ok |
| 4.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 4.0 MiB | cpu | parallel | 10.03 | 9.52 | 10.52 | 10.52 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 4.0 MiB | cpu | context-auto | 8.97 | 8.59 | 9.16 | 9.16 | ok |
| 4.0 MiB | blake3 | default-auto | 8.88 | 8.40 | 9.00 | 9.00 | ok |
| 4.0 MiB | metal | resident-auto | 10.69 | 10.21 | 11.32 | 11.32 | ok |
| 4.0 MiB | metal | resident-gpu | 10.30 | 7.63 | 13.11 | 13.11 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.13 | 2.13 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 11.62 | 11.51 | 12.12 | 12.12 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.63 | 2.63 | ok |
| 8.0 MiB | cpu | context-auto | 12.26 | 11.54 | 12.54 | 12.54 | ok |
| 8.0 MiB | blake3 | default-auto | 16.93 | 15.41 | 17.86 | 17.86 | ok |
| 8.0 MiB | metal | resident-auto | 12.85 | 12.64 | 13.66 | 13.66 | ok |
| 8.0 MiB | metal | resident-gpu | 19.98 | 18.25 | 21.16 | 21.16 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.83 | 13.43 | 14.02 | 14.02 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.81 | 13.39 | 14.07 | 14.07 | ok |
| 16.0 MiB | blake3 | default-auto | 19.97 | 19.70 | 20.91 | 20.91 | ok |
| 16.0 MiB | metal | resident-auto | 24.30 | 23.34 | 27.50 | 27.50 | ok |
| 16.0 MiB | metal | resident-gpu | 25.10 | 24.35 | 28.45 | 28.45 | ok |
jsonOutput=benchmarks/results/20261010T-m6-auto-gate/gate-8m.json
