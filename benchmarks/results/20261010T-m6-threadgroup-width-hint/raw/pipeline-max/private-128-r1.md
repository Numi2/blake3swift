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
metalDigestPipelineWidthHint=true
metalDigestPipelineMaxThreadsPerThreadgroup=128
metal-private includes: pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 16.37 | 16.34 | 16.66 | 16.66 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.59 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.34 | 17.09 | 17.54 | 17.54 | ok |
| 1.0 GiB | blake3 | default-auto | 59.70 | 58.12 | 64.16 | 64.16 | ok |
| 1.0 GiB | metal | private-gpu | 97.63 | 97.42 | 98.02 | 98.02 | ok |
jsonOutput=/tmp/m6-pipeline-max-verified/private-128-r1.json
