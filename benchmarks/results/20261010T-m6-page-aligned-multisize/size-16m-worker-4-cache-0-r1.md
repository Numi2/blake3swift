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
pageAlignedCopyWriteCombined=false
metalCommandTiming=false
metalCommandBackend=legacy
metalDigestPipelineWidthHint=true
metal-wrapped includes: timed page-aligned allocation, 4-worker copy, shared MTLBuffer wrapper, and hash; writeCombined=false
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.35 | 1.09 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.13 | 2.13 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.94 | 12.60 | 14.23 | 14.23 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.27 | 12.63 | 14.13 | 14.13 | ok |
| 16.0 MiB | blake3 | default-auto | 21.74 | 17.51 | 23.09 | 23.09 | ok |
| 16.0 MiB | metal | wrapped-auto | 17.75 | 11.96 | 18.33 | 18.33 | ok |
| 16.0 MiB | metal | wrapped-gpu | 17.49 | 15.54 | 18.27 | 18.27 | ok |
jsonOutput=/Users/numi/Work/blake3swift-perf-20261010/benchmarks/results/20261010T-m6-page-aligned-multisize/size-16m-worker-4-cache-0-r1.json
