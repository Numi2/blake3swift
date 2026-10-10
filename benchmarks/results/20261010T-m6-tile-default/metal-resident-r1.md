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
| 256.0 MiB | cpu | single-simd | 2.14 | 2.12 | 2.15 | 2.15 | ok |
| 256.0 MiB | cpu | parallel | 16.69 | 16.16 | 16.76 | 16.76 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 16.29 | 16.13 | 16.98 | 16.98 | ok |
| 256.0 MiB | blake3 | default-auto | 52.58 | 48.65 | 57.57 | 57.57 | ok |
| 256.0 MiB | metal | resident-auto | 92.19 | 72.70 | 94.18 | 94.18 | ok |
| 256.0 MiB | metal | resident-gpu | 92.77 | 72.28 | 93.36 | 93.36 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.33 | 17.12 | 17.48 | 17.48 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.31 | 17.01 | 17.33 | 17.33 | ok |
| 1.0 GiB | blake3 | default-auto | 65.73 | 62.94 | 67.49 | 67.49 | ok |
| 1.0 GiB | metal | resident-auto | 104.21 | 102.36 | 106.74 | 106.74 | ok |
| 1.0 GiB | metal | resident-gpu | 106.48 | 104.67 | 106.64 | 106.64 | ok |
jsonOutput=benchmarks/results/20261010T-m6-tile-default/metal-resident-r1.json
