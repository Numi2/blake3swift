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
| 256.0 MiB | cpu | parallel | 17.34 | 16.53 | 17.46 | 17.46 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.53 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.25 | 16.65 | 17.48 | 17.48 | ok |
| 256.0 MiB | blake3 | default-auto | 49.28 | 46.44 | 50.68 | 50.68 | ok |
| 256.0 MiB | metal | resident-auto | 79.13 | 77.56 | 92.13 | 92.13 | ok |
| 256.0 MiB | metal | resident-gpu | 79.33 | 77.50 | 92.52 | 92.52 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.27 | 17.05 | 17.32 | 17.32 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.23 | 16.89 | 17.29 | 17.29 | ok |
| 1.0 GiB | blake3 | default-auto | 68.93 | 67.87 | 71.45 | 71.45 | ok |
| 1.0 GiB | metal | resident-auto | 105.54 | 102.72 | 106.29 | 106.29 | ok |
| 1.0 GiB | metal | resident-gpu | 106.17 | 106.11 | 106.26 | 106.26 | ok |
jsonOutput=benchmarks/results/20261010T-m6-tile512-pingpong/repeat-1.json
