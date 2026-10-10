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
| 256.0 MiB | cpu | parallel | 16.19 | 16.03 | 16.90 | 16.90 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.38 | 16.77 | 17.47 | 17.47 | ok |
| 256.0 MiB | blake3 | default-auto | 52.84 | 51.55 | 57.81 | 57.81 | ok |
| 256.0 MiB | metal | resident-auto | 87.40 | 80.71 | 95.32 | 95.32 | ok |
| 256.0 MiB | metal | resident-gpu | 87.78 | 80.72 | 95.80 | 95.80 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.16 | 17.09 | 17.64 | 17.64 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.32 | 17.07 | 17.34 | 17.34 | ok |
| 1.0 GiB | blake3 | default-auto | 66.71 | 65.81 | 69.26 | 69.26 | ok |
| 1.0 GiB | metal | resident-auto | 105.63 | 104.30 | 106.26 | 106.26 | ok |
| 1.0 GiB | metal | resident-gpu | 106.23 | 106.06 | 106.40 | 106.40 | ok |
jsonOutput=benchmarks/results/20261010T-m6-tile256-pingpong/metal-resident-r1.json
