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
sizes=16.0 MiB, 64.0 MiB
operationModes=batch-one-chunk
batchOneChunkItemByteCount=64
operation-batch-one-chunk includes: timed independent one-chunk BLAKE3 hashes over one resident buffer, aggregated for correctness
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.33 | 1.03 | 1.34 | 1.34 | ok |
| 16.0 MiB | cpu | single-simd | 2.13 | 2.10 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.18 | 12.45 | 13.94 | 13.94 | ok |
| 16.0 MiB | official-c | one-shot | 2.58 | 2.54 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.30 | 13.03 | 13.90 | 13.90 | ok |
| 16.0 MiB | blake3 | default-auto | 13.82 | 8.24 | 18.00 | 18.00 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.45 | 1.41 | 1.48 | 1.48 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.04 | 2.02 | 2.06 | 2.06 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.26 | 3.16 | 3.31 | 3.31 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 10.51 | 9.24 | 12.31 | 12.31 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.58 | 3.48 | 3.69 | 3.69 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 29.81 | 19.38 | 32.25 | 32.25 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.82 | 3.80 | 3.94 | 3.94 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 23.43 | 22.34 | 42.28 | 42.28 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.87 | 3.79 | 4.04 | 4.04 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 23.37 | 21.93 | 41.88 | 41.88 | ok |
| 16.0 MiB | metal | resident-auto | 15.68 | 12.66 | 24.04 | 24.04 | ok |
| 16.0 MiB | metal | resident-gpu | 23.60 | 14.12 | 27.84 | 27.84 | ok |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 16.54 | 16.02 | 16.68 | 16.68 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 16.42 | 15.08 | 16.58 | 16.58 | ok |
| 64.0 MiB | blake3 | default-auto | 32.27 | 17.94 | 33.14 | 33.14 | ok |
| 64.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.58 | 1.55 | 1.59 | 1.59 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.26 | 2.25 | 2.32 | 2.32 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.73 | 3.71 | 3.76 | 3.76 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 18.19 | 14.03 | 19.92 | 19.92 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 4.17 | 4.09 | 4.29 | 4.29 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 45.13 | 36.16 | 47.68 | 47.68 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 4.38 | 4.15 | 4.44 | 4.44 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 34.72 | 21.40 | 41.96 | 41.96 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 4.36 | 4.25 | 4.49 | 4.49 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 39.17 | 37.62 | 50.72 | 50.72 | ok |
| 64.0 MiB | metal | resident-auto | 79.12 | 39.48 | 82.81 | 82.81 | ok |
| 64.0 MiB | metal | resident-gpu | 79.24 | 41.10 | 83.97 | 83.97 | ok |
jsonOutput=perf-experiments/20261010T-m6-batch-paths/aggregate-candidate-16m-64m-64b-r1.json
