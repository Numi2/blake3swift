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
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.12 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 14.13 | 12.64 | 14.23 | 14.23 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.89 | 13.01 | 14.26 | 14.26 | ok |
| 16.0 MiB | blake3 | default-auto | 28.27 | 14.70 | 29.79 | 29.79 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.41 | 0.41 | 0.41 | 0.41 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.49 | 1.47 | 1.53 | 1.53 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.14 | 2.03 | 2.24 | 2.24 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.27 | 3.12 | 3.42 | 3.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 10.97 | 9.96 | 12.77 | 12.77 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.64 | 3.41 | 3.94 | 3.94 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 31.56 | 17.02 | 33.58 | 33.58 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.82 | 3.77 | 4.01 | 4.01 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 39.02 | 22.90 | 45.40 | 45.40 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.81 | 3.75 | 4.03 | 4.03 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 40.86 | 22.89 | 42.80 | 42.80 | ok |
| 16.0 MiB | metal | resident-auto | 44.95 | 22.15 | 51.95 | 51.95 | ok |
| 16.0 MiB | metal | resident-gpu | 50.15 | 23.81 | 54.37 | 54.37 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/warm-batch-groups-4-r1.json
