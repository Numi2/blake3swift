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
| 256.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel | 17.31 | 16.72 | 17.41 | 17.41 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.40 | 16.28 | 17.41 | 17.41 | ok |
| 256.0 MiB | blake3 | default-auto | 55.65 | 47.27 | 62.26 | 62.26 | ok |
| 256.0 MiB | metal | resident-auto | 95.34 | 94.44 | 95.90 | 95.90 | ok |
| 256.0 MiB | metal | resident-gpu | 95.49 | 88.37 | 96.12 | 96.12 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.31 | 16.77 | 17.39 | 17.39 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.18 | 16.96 | 17.50 | 17.50 | ok |
| 1.0 GiB | blake3 | default-auto | 67.39 | 64.99 | 69.38 | 69.38 | ok |
| 1.0 GiB | metal | resident-auto | 104.16 | 100.78 | 104.58 | 104.58 | ok |
| 1.0 GiB | metal | resident-gpu | 104.81 | 102.58 | 104.87 | 104.87 | ok |
jsonOutput=/tmp/m6-fused-inplace-r3.json
