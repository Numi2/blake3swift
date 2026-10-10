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
pageAlignedCopyWorkers=4
pageAlignedCopyWriteCombined=true
metalCommandTiming=false
metalCommandBackend=legacy
metalDigestPipelineWidthHint=true
metal-wrapped includes: timed page-aligned allocation, 4-worker copy, shared MTLBuffer wrapper, and hash; writeCombined=true
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=64.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 16.47 | 15.95 | 16.59 | 16.59 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 16.51 | 15.92 | 16.61 | 16.61 | ok |
| 64.0 MiB | blake3 | default-auto | 29.67 | 28.86 | 34.12 | 34.12 | ok |
| 64.0 MiB | metal | wrapped-auto | 18.92 | 16.95 | 21.06 | 21.06 | ok |
| 64.0 MiB | metal | wrapped-gpu | 20.28 | 16.48 | 21.89 | 21.89 | ok |
jsonOutput=/Users/numi/Work/blake3swift-perf-20261010/benchmarks/results/20261010T-m6-page-aligned-multisize/size-64m-worker-4-cache-1-r2.json
