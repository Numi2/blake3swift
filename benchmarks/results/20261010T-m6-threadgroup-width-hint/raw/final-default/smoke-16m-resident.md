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
metalDigestPipelineWidthHint=true
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 0.98 | 0.98 | 0.98 | 0.98 | ok |
| 16.0 MiB | cpu | single-simd | 2.01 | 2.01 | 2.01 | 2.01 | ok |
| 16.0 MiB | cpu | parallel | 13.51 | 13.51 | 13.51 | 13.51 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.85 | 13.85 | 13.85 | 13.85 | ok |
| 16.0 MiB | blake3 | default-auto | 21.02 | 21.02 | 21.02 | 21.02 | ok |
| 16.0 MiB | metal | resident-auto | 25.00 | 25.00 | 25.00 | 25.00 | ok |
| 16.0 MiB | metal | resident-gpu | 25.10 | 25.10 | 25.10 | 25.10 | ok |
jsonOutput=/tmp/m6-final-thread-hint/smoke-16m-resident.json
