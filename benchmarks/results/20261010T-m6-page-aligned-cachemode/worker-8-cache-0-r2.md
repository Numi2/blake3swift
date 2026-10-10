BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=wrapped
pageAlignedWrappedInput=true
pageAlignedCopyWorkers=8
pageAlignedCopyWriteCombined=false
metalCommandTiming=false
metalCommandBackend=legacy
metalDigestPipelineWidthHint=true
metal-wrapped includes: timed page-aligned allocation, 8-worker copy, shared MTLBuffer wrapper, and hash; writeCombined=false
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.41 | 17.20 | 17.55 | 17.55 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.38 | 17.30 | 17.56 | 17.56 | ok |
| 1.0 GiB | blake3 | default-auto | 54.43 | 53.25 | 63.09 | 63.09 | ok |
| 1.0 GiB | metal | wrapped-auto | 31.67 | 25.26 | 33.20 | 33.20 | ok |
| 1.0 GiB | metal | wrapped-gpu | 32.06 | 31.81 | 32.32 | 32.32 | ok |
jsonOutput=/Users/numi/Work/blake3swift-perf-20261010/benchmarks/results/20261010T-m6-page-aligned-cachemode/worker-8-cache-0-r2.json
