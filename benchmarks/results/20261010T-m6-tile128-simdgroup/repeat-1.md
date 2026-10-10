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
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.24 | 16.94 | 17.36 | 17.36 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.27 | 16.88 | 17.50 | 17.50 | ok |
| 1.0 GiB | blake3 | default-auto | 59.04 | 56.43 | 65.54 | 65.54 | ok |
| 1.0 GiB | metal | resident-auto | 106.09 | 103.07 | 106.32 | 106.32 | ok |
| 1.0 GiB | metal | resident-gpu | 106.35 | 103.28 | 107.08 | 107.08 | ok |
jsonOutput=benchmarks/results/20261010T-m6-tile128-simdgroup/repeat-1.json
