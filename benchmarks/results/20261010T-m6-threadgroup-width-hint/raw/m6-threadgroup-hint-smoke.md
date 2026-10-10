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
metalLargeGridSIMDGroups=default
metalThreadgroupWidthHint=true
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.00 | 1.00 | 1.00 | 1.00 | ok |
| 16.0 MiB | cpu | single-simd | 2.00 | 2.00 | 2.00 | 2.00 | ok |
| 16.0 MiB | cpu | parallel | 12.56 | 12.56 | 12.56 | 12.56 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.57 | 13.57 | 13.57 | 13.57 | ok |
| 16.0 MiB | blake3 | default-auto | 18.32 | 18.32 | 18.32 | 18.32 | ok |
| 16.0 MiB | metal | resident-auto | 22.52 | 22.52 | 22.52 | 22.52 | ok |
| 16.0 MiB | metal | resident-gpu | 22.93 | 22.93 | 22.93 | 22.93 | ok |
jsonOutput=/tmp/m6-threadgroup-hint-smoke.json
