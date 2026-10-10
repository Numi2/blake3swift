BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=private
pageAlignedWrappedInput=false
metalCommandTiming=false
metalCommandBackend=legacy
metalLargeGridSIMDGroups=4
metalThreadgroupWidthHint=true
metal-private includes: pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.39 | 17.22 | 17.55 | 17.55 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.28 | 17.01 | 17.51 | 17.51 | ok |
| 1.0 GiB | blake3 | default-auto | 54.27 | 43.33 | 59.51 | 59.51 | ok |
| 1.0 GiB | metal | private-gpu | 95.01 | 92.18 | 97.10 | 97.10 | ok |
jsonOutput=/tmp/m6-threadgroup-hint-private-hinted-r3/report.json
