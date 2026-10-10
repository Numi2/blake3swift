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
batchOneChunkItemByteCount=64
operation-batch-one-chunk includes: timed independent one-chunk BLAKE3 hashes over one resident buffer, aggregated for correctness
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.35 | 1.33 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.12 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.24 | 12.54 | 14.12 | 14.12 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.58 | 2.63 | 2.63 | ok |
| 16.0 MiB | cpu | context-auto | 13.74 | 12.41 | 14.24 | 14.24 | ok |
| 16.0 MiB | blake3 | default-auto | 16.32 | 13.74 | 29.87 | 29.87 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.41 | 0.41 | 0.41 | 0.41 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.45 | 1.42 | 1.54 | 1.54 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.04 | 1.96 | 2.09 | 2.09 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.31 | 3.19 | 3.44 | 3.44 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 10.57 | 9.67 | 12.45 | 12.45 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.79 | 3.58 | 3.95 | 3.95 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 32.77 | 28.36 | 34.05 | 34.05 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.82 | 3.75 | 4.06 | 4.06 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 38.00 | 20.13 | 42.84 | 42.84 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.86 | 3.79 | 4.41 | 4.41 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 23.25 | 20.44 | 43.73 | 43.73 | ok |
| 16.0 MiB | metal | resident-auto | 23.73 | 22.53 | 49.93 | 49.93 | ok |
| 16.0 MiB | metal | resident-gpu | 24.59 | 23.02 | 52.26 | 52.26 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/warm-batch-groups-4-r2.json
