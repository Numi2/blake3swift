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
| 256.0 MiB | cpu | parallel | 17.02 | 16.66 | 17.17 | 17.17 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.28 | 16.28 | 17.39 | 17.39 | ok |
| 256.0 MiB | blake3 | default-auto | 56.69 | 38.39 | 61.94 | 61.94 | ok |
| 256.0 MiB | metal | resident-auto | 94.53 | 58.97 | 95.13 | 95.13 | ok |
| 256.0 MiB | metal | resident-gpu | 93.90 | 93.16 | 94.98 | 94.98 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.28 | 16.67 | 17.52 | 17.52 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.34 | 17.13 | 17.37 | 17.37 | ok |
| 1.0 GiB | blake3 | default-auto | 67.08 | 66.17 | 69.36 | 69.36 | ok |
| 1.0 GiB | metal | resident-auto | 104.33 | 101.21 | 104.54 | 104.54 | ok |
| 1.0 GiB | metal | resident-gpu | 104.49 | 101.36 | 104.62 | 104.62 | ok |
jsonOutput=benchmarks/results/20261010T-m6-tile1024-pingpong/repeat-2.json
