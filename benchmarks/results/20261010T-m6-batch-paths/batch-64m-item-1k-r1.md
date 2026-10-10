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
pageAlignedCopyWorkers=1
pageAlignedCopyWriteCombined=false
metalCommandTiming=false
metalCommandBackend=legacy
metalDigestPipelineWidthHint=true
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=64.0 MiB
operationModes=batch-one-chunk
batchOneChunkItemByteCount=1024
operation-batch-one-chunk includes: timed independent one-chunk BLAKE3 hashes over one resident buffer, aggregated for correctness
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 16.43 | 15.30 | 16.60 | 16.60 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 16.50 | 16.48 | 16.54 | 16.54 | ok |
| 64.0 MiB | blake3 | default-auto | 23.54 | 11.25 | 23.78 | 23.78 | ok |
| 64.0 MiB | cpu | batch-one-chunk-1024 | 1.26 | 1.26 | 1.26 | 1.26 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-gpu | 13.21 | 12.99 | 13.44 | 13.44 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-plan-gpu | 15.96 | 15.66 | 16.52 | 16.52 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-write-gpu | 20.31 | 19.59 | 23.42 | 23.42 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-gpu | 35.78 | 27.69 | 37.02 | 37.02 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-write-private-gpu | 24.48 | 20.80 | 26.19 | 26.19 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-private-gpu | 53.20 | 51.06 | 56.12 | 56.12 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-write-private-chained-gpu | 28.54 | 27.79 | 29.53 | 29.53 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-private-chained-gpu | 65.68 | 61.13 | 72.74 | 72.74 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-fused-aggregate-gpu | 29.14 | 28.96 | 29.35 | 29.35 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-plan-fused-aggregate-gpu | 58.07 | 57.53 | 61.16 | 61.16 | ok |
| 64.0 MiB | metal | resident-auto | 40.79 | 40.09 | 41.97 | 41.97 | ok |
| 64.0 MiB | metal | resident-gpu | 41.89 | 40.54 | 43.35 | 43.35 | ok |
jsonOutput=/Users/numi/Work/blake3swift-perf-20261010/perf-experiments/20261010T-m6-batch-paths/batch-64m-item-1k-r1.json
