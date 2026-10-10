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
| 256.0 MiB | cpu | parallel | 16.85 | 16.69 | 17.36 | 17.36 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.34 | 16.29 | 17.42 | 17.42 | ok |
| 256.0 MiB | blake3 | default-auto | 52.67 | 38.65 | 56.98 | 56.98 | ok |
| 256.0 MiB | metal | resident-auto | 90.08 | 54.85 | 95.14 | 95.14 | ok |
| 256.0 MiB | metal | resident-gpu | 92.53 | 71.82 | 94.24 | 94.24 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.27 | 16.78 | 17.43 | 17.43 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.37 | 17.03 | 17.42 | 17.42 | ok |
| 1.0 GiB | blake3 | default-auto | 67.10 | 64.95 | 69.18 | 69.18 | ok |
| 1.0 GiB | metal | resident-auto | 105.43 | 101.81 | 106.16 | 106.16 | ok |
| 1.0 GiB | metal | resident-gpu | 106.03 | 105.86 | 106.20 | 106.20 | ok |
jsonOutput=benchmarks/results/20261010T-m6-tile256-pingpong/metal-resident-r2.json
