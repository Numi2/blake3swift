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
| 16.0 MiB | cpu | scalar | 1.15 | 0.97 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.75 | 1.71 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 10.06 | 8.42 | 10.46 | 10.46 | ok |
| 16.0 MiB | official-c | one-shot | 2.17 | 2.14 | 2.18 | 2.18 | ok |
| 16.0 MiB | cpu | context-auto | 10.39 | 9.69 | 10.58 | 10.58 | ok |
| 16.0 MiB | blake3 | default-auto | 14.41 | 5.40 | 21.01 | 21.01 | ok |
| 16.0 MiB | metal | resident-auto | 8.83 | 3.19 | 23.47 | 23.47 | ok |
| 16.0 MiB | metal | resident-gpu | 12.55 | 9.81 | 20.16 | 20.16 | ok |
| 64.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.77 | 1.77 | ok |
| 64.0 MiB | cpu | parallel | 11.28 | 10.93 | 11.83 | 11.83 | ok |
| 64.0 MiB | official-c | one-shot | 2.15 | 2.06 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 9.47 | 8.43 | 10.26 | 10.26 | ok |
| 64.0 MiB | blake3 | default-auto | 30.18 | 18.90 | 36.54 | 36.54 | ok |
| 64.0 MiB | metal | resident-auto | 42.92 | 16.23 | 54.66 | 54.66 | ok |
| 64.0 MiB | metal | resident-gpu | 42.99 | 20.88 | 55.16 | 55.16 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.12 | 1.15 | 1.15 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.74 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 11.56 | 11.41 | 11.67 | 11.67 | ok |
| 256.0 MiB | official-c | one-shot | 2.16 | 2.15 | 2.16 | 2.16 | ok |
| 256.0 MiB | cpu | context-auto | 11.76 | 11.68 | 11.93 | 11.93 | ok |
| 256.0 MiB | blake3 | default-auto | 44.20 | 37.29 | 46.24 | 46.24 | ok |
| 256.0 MiB | metal | resident-auto | 59.58 | 47.70 | 74.73 | 74.73 | ok |
| 256.0 MiB | metal | resident-gpu | 63.67 | 45.56 | 80.17 | 80.17 | ok |
jsonOutput=benchmarks/results/20260421T-full-suite-isolated-overhead/metal-resident-r1.json
