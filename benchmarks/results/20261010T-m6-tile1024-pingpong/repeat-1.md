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
sizes=256.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel | 17.24 | 16.28 | 17.36 | 17.36 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.42 | 16.80 | 17.47 | 17.47 | ok |
| 256.0 MiB | blake3 | default-auto | 50.80 | 37.79 | 56.81 | 56.81 | ok |
| 256.0 MiB | metal | resident-auto | 85.58 | 56.61 | 93.46 | 93.46 | ok |
| 256.0 MiB | metal | resident-gpu | 86.46 | 78.76 | 93.14 | 93.14 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.32 | 16.97 | 17.46 | 17.46 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.33 | 17.11 | 17.42 | 17.42 | ok |
| 1.0 GiB | blake3 | default-auto | 67.36 | 64.89 | 70.66 | 70.66 | ok |
| 1.0 GiB | metal | resident-auto | 104.28 | 103.92 | 104.99 | 104.99 | ok |
| 1.0 GiB | metal | resident-gpu | 104.68 | 104.42 | 104.85 | 104.85 | ok |
jsonOutput=benchmarks/results/20261010T-m6-tile1024-pingpong/repeat-1.json
