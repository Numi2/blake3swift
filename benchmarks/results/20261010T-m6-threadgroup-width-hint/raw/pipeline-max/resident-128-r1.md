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
metalDigestPipelineMaxThreadsPerThreadgroup=128
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.19 | 16.87 | 17.42 | 17.42 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.25 | 16.34 | 17.52 | 17.52 | ok |
| 1.0 GiB | blake3 | default-auto | 66.02 | 61.92 | 66.85 | 66.85 | ok |
| 1.0 GiB | metal | resident-auto | 107.07 | 104.52 | 107.49 | 107.49 | ok |
| 1.0 GiB | metal | resident-gpu | 107.06 | 106.04 | 107.59 | 107.59 | ok |
jsonOutput=/tmp/m6-pipeline-max-verified/resident-128-r1.json
