BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=wrapped
pageAlignedWrappedInput=false
pageAlignedCopyWorkers=1
pageAlignedCopyWriteCombined=false
metalCommandTiming=false
metalCommandBackend=legacy
metalDigestPipelineWidthHint=true
metal-wrapped includes: timed Swift input route with page-aligned shared-buffer allocation/copy, hash command submission, and completion
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.28 | 17.25 | 17.68 | 17.68 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.35 | 17.15 | 17.45 | 17.45 | ok |
| 1.0 GiB | blake3 | default-auto | 28.03 | 17.13 | 29.54 | 29.54 | ok |
| 1.0 GiB | metal | wrapped-auto | 29.02 | 23.24 | 29.94 | 29.94 | ok |
| 1.0 GiB | metal | wrapped-gpu | 28.82 | 25.86 | 29.24 | 29.24 | ok |
jsonOutput=/tmp/m6-public-aligned.json
