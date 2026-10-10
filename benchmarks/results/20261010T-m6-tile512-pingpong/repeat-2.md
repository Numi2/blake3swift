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
| 256.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel | 17.34 | 16.30 | 17.40 | 17.40 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.34 | 16.32 | 17.38 | 17.38 | ok |
| 256.0 MiB | blake3 | default-auto | 57.22 | 43.38 | 62.62 | 62.62 | ok |
| 256.0 MiB | metal | resident-auto | 95.11 | 94.66 | 95.55 | 95.55 | ok |
| 256.0 MiB | metal | resident-gpu | 94.55 | 93.74 | 95.20 | 95.20 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.23 | 17.12 | 17.31 | 17.31 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.35 | 17.24 | 17.37 | 17.37 | ok |
| 1.0 GiB | blake3 | default-auto | 68.41 | 67.48 | 70.99 | 70.99 | ok |
| 1.0 GiB | metal | resident-auto | 105.98 | 103.70 | 106.03 | 106.03 | ok |
| 1.0 GiB | metal | resident-gpu | 104.35 | 102.55 | 106.45 | 106.45 | ok |
jsonOutput=benchmarks/results/20261010T-m6-tile512-pingpong/repeat-2.json
