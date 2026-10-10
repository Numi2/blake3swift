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
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.31 | 17.22 | 17.42 | 17.42 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.24 | 16.98 | 17.39 | 17.39 | ok |
| 1.0 GiB | blake3 | default-auto | 63.00 | 61.85 | 65.86 | 65.86 | ok |
| 1.0 GiB | metal | resident-auto | 105.26 | 103.12 | 105.71 | 105.71 | ok |
| 1.0 GiB | metal | resident-gpu | 105.60 | 105.40 | 105.77 | 105.77 | ok |
jsonOutput=/tmp/m6-legacy-r2.json
