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
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.13 | 2.15 | 2.15 | ok |
| 1.0 GiB | cpu | parallel | 17.35 | 17.11 | 17.62 | 17.62 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.59 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.23 | 17.15 | 17.31 | 17.31 | ok |
| 1.0 GiB | blake3 | default-auto | 61.91 | 58.45 | 64.08 | 64.08 | ok |
| 1.0 GiB | metal | resident-auto | 104.00 | 101.65 | 104.45 | 104.45 | ok |
| 1.0 GiB | metal | resident-gpu | 104.19 | 102.98 | 104.52 | 104.52 | ok |
jsonOutput=/tmp/m6-pipeline-max/resident-auto-r2.json
