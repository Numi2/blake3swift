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
sizes=256.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel | 17.12 | 16.87 | 17.39 | 17.39 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.15 | 16.66 | 17.38 | 17.38 | ok |
| 256.0 MiB | blake3 | default-auto | 44.69 | 34.79 | 54.33 | 54.33 | ok |
| 256.0 MiB | metal | wrapped-auto | 25.30 | 21.88 | 27.92 | 27.92 | ok |
| 256.0 MiB | metal | wrapped-gpu | 25.08 | 22.88 | 27.86 | 27.86 | ok |
jsonOutput=/Users/numi/Work/blake3swift-perf-20261010/benchmarks/results/20261010T-m6-page-aligned-multisize/size-256m-worker-4-cache-0-r1.json
