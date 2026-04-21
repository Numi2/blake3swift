BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=resident
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.15 | 1.14 | 1.17 | 1.17 | ok |
| 16.0 MiB | cpu | single-simd | 1.75 | 1.73 | 1.75 | 1.75 | ok |
| 16.0 MiB | cpu | parallel | 8.91 | 7.73 | 9.02 | 9.02 | ok |
| 16.0 MiB | official-c | one-shot | 2.19 | 2.18 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 8.09 | 7.05 | 9.24 | 9.24 | ok |
| 16.0 MiB | blake3 | default-auto | 9.19 | 3.87 | 10.09 | 10.09 | ok |
| 16.0 MiB | metal | resident-auto | 9.99 | 4.02 | 13.44 | 13.44 | ok |
| 16.0 MiB | metal | resident-gpu | 9.98 | 9.26 | 11.35 | 11.35 | ok |
| 64.0 MiB | cpu | scalar | 1.15 | 1.14 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.74 | 1.73 | 1.74 | 1.74 | ok |
| 64.0 MiB | cpu | parallel | 9.76 | 9.27 | 10.26 | 10.26 | ok |
| 64.0 MiB | official-c | one-shot | 2.11 | 2.03 | 2.15 | 2.15 | ok |
| 64.0 MiB | cpu | context-auto | 9.44 | 9.15 | 10.27 | 10.27 | ok |
| 64.0 MiB | blake3 | default-auto | 19.48 | 14.58 | 32.06 | 32.06 | ok |
| 64.0 MiB | metal | resident-auto | 30.41 | 17.14 | 41.81 | 41.81 | ok |
| 64.0 MiB | metal | resident-gpu | 37.89 | 29.72 | 42.04 | 42.04 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.17 | 1.17 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.53 | 9.79 | 11.23 | 11.23 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.06 | 9.50 | 11.12 | 11.12 | ok |
| 256.0 MiB | blake3 | default-auto | 33.87 | 29.47 | 37.33 | 37.33 | ok |
| 256.0 MiB | metal | resident-auto | 51.77 | 45.38 | 56.11 | 56.11 | ok |
| 256.0 MiB | metal | resident-gpu | 44.94 | 41.31 | 55.67 | 55.67 | ok |
jsonOutput=benchmarks/results/20260421T-digest-fastpath-isolated/metal-resident.json
