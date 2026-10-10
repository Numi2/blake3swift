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
sizes=16.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.33 | 1.33 | 1.33 | 1.33 | ok |
| 16.0 MiB | cpu | single-simd | 2.12 | 2.12 | 2.12 | 2.12 | ok |
| 16.0 MiB | cpu | parallel | 13.10 | 13.10 | 13.10 | 13.10 | ok |
| 16.0 MiB | official-c | one-shot | 2.60 | 2.60 | 2.60 | 2.60 | ok |
| 16.0 MiB | cpu | context-auto | 13.89 | 13.89 | 13.89 | 13.89 | ok |
| 16.0 MiB | blake3 | default-auto | 20.60 | 20.60 | 20.60 | 20.60 | ok |
| 16.0 MiB | metal | resident-auto | 23.90 | 23.90 | 23.90 | 23.90 | ok |
| 16.0 MiB | metal | resident-gpu | 26.70 | 26.70 | 26.70 | 26.70 | ok |
jsonOutput=/tmp/m6-pipeline-max-verified/smoke-128.json
