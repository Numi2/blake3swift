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
| 256.0 MiB | cpu | parallel | 17.22 | 16.30 | 17.32 | 17.32 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.24 | 16.27 | 17.38 | 17.38 | ok |
| 256.0 MiB | blake3 | default-auto | 53.51 | 38.66 | 58.20 | 58.20 | ok |
| 256.0 MiB | metal | resident-auto | 92.47 | 57.58 | 96.21 | 96.21 | ok |
| 256.0 MiB | metal | resident-gpu | 92.62 | 77.75 | 95.45 | 95.45 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.34 | 17.15 | 17.40 | 17.40 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.21 | 16.98 | 17.50 | 17.50 | ok |
| 1.0 GiB | blake3 | default-auto | 67.21 | 63.70 | 67.82 | 67.82 | ok |
| 1.0 GiB | metal | resident-auto | 106.09 | 104.70 | 106.70 | 106.70 | ok |
| 1.0 GiB | metal | resident-gpu | 103.33 | 102.35 | 106.92 | 106.92 | ok |
jsonOutput=benchmarks/results/20261010T-m6-tile-default/metal-resident-r2.json
