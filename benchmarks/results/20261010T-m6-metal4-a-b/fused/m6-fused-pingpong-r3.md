BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=resident
pageAlignedWrappedInput=false
metalCommandTiming=false
metalCommandBackend=legacy
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=256.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.35 | 1.33 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel | 17.31 | 17.07 | 17.41 | 17.41 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.44 | 16.35 | 17.47 | 17.47 | ok |
| 256.0 MiB | blake3 | default-auto | 50.01 | 47.90 | 53.15 | 53.15 | ok |
| 256.0 MiB | metal | resident-auto | 84.05 | 83.09 | 94.58 | 94.58 | ok |
| 256.0 MiB | metal | resident-gpu | 83.99 | 83.49 | 94.18 | 94.18 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.17 | 17.01 | 17.20 | 17.20 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.40 | 17.14 | 17.45 | 17.45 | ok |
| 1.0 GiB | blake3 | default-auto | 68.34 | 65.60 | 69.80 | 69.80 | ok |
| 1.0 GiB | metal | resident-auto | 104.49 | 103.89 | 104.54 | 104.54 | ok |
| 1.0 GiB | metal | resident-gpu | 104.53 | 104.46 | 104.73 | 104.73 | ok |
jsonOutput=/tmp/m6-fused-pingpong-r3.json
