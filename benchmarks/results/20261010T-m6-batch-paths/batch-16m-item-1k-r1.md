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
sizes=16.0 MiB
operationModes=batch-one-chunk
batchOneChunkItemByteCount=1024
operation-batch-one-chunk includes: timed independent one-chunk BLAKE3 hashes over one resident buffer, aggregated for correctness
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.29 | 1.15 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.13 | 2.13 | 2.13 | 2.13 | ok |
| 16.0 MiB | cpu | parallel | 13.86 | 12.93 | 14.03 | 14.03 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 14.00 | 14.00 | 14.04 | 14.04 | ok |
| 16.0 MiB | blake3 | default-auto | 15.85 | 13.35 | 15.85 | 15.85 | ok |
| 16.0 MiB | cpu | batch-one-chunk-1024 | 1.25 | 1.25 | 1.25 | 1.25 | ok |
| 16.0 MiB | metal | batch-one-chunk-1024-resident-gpu | 12.26 | 12.15 | 12.76 | 12.76 | ok |
| 16.0 MiB | metal | batch-one-chunk-1024-resident-plan-gpu | 16.15 | 14.57 | 16.17 | 16.17 | ok |
| 16.0 MiB | metal | batch-one-chunk-1024-resident-write-gpu | 17.45 | 17.42 | 17.58 | 17.58 | ok |
| 16.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-gpu | 24.00 | 22.45 | 28.39 | 28.39 | ok |
| 16.0 MiB | metal | batch-one-chunk-1024-resident-write-private-gpu | 15.57 | 15.00 | 16.48 | 16.48 | ok |
| 16.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-private-gpu | 18.25 | 17.65 | 20.94 | 20.94 | ok |
| 16.0 MiB | metal | batch-one-chunk-1024-resident-write-private-chained-gpu | 16.59 | 16.13 | 17.08 | 17.08 | ok |
| 16.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-private-chained-gpu | 21.80 | 21.04 | 22.30 | 22.30 | ok |
| 16.0 MiB | metal | batch-one-chunk-1024-resident-fused-aggregate-gpu | 14.14 | 14.07 | 14.16 | 14.16 | ok |
| 16.0 MiB | metal | batch-one-chunk-1024-resident-plan-fused-aggregate-gpu | 18.76 | 17.61 | 19.11 | 19.11 | ok |
| 16.0 MiB | metal | resident-auto | 25.13 | 21.79 | 28.15 | 28.15 | ok |
| 16.0 MiB | metal | resident-gpu | 26.28 | 24.44 | 27.21 | 27.21 | ok |
jsonOutput=/Users/numi/Work/blake3swift-perf-20261010/perf-experiments/20261010T-m6-batch-paths/batch-16m-item-1k-r1.json
