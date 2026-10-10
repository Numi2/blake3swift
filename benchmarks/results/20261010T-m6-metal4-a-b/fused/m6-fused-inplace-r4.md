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
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel | 17.31 | 16.26 | 17.40 | 17.40 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.07 | 16.75 | 17.30 | 17.30 | ok |
| 256.0 MiB | blake3 | default-auto | 57.42 | 48.19 | 59.26 | 59.26 | ok |
| 256.0 MiB | metal | resident-auto | 96.04 | 95.37 | 96.27 | 96.27 | ok |
| 256.0 MiB | metal | resident-gpu | 95.52 | 95.31 | 95.85 | 95.85 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.18 | 16.79 | 17.37 | 17.37 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.38 | 17.16 | 17.44 | 17.44 | ok |
| 1.0 GiB | blake3 | default-auto | 67.49 | 65.90 | 69.60 | 69.60 | ok |
| 1.0 GiB | metal | resident-auto | 103.99 | 100.88 | 104.32 | 104.32 | ok |
| 1.0 GiB | metal | resident-gpu | 104.51 | 104.46 | 104.58 | 104.58 | ok |
jsonOutput=/tmp/m6-fused-inplace-r4.json
