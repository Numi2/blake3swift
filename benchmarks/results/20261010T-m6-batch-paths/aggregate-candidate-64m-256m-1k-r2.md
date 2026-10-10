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
sizes=64.0 MiB, 256.0 MiB
operationModes=batch-one-chunk
batchOneChunkItemByteCount=1024
operation-batch-one-chunk includes: timed independent one-chunk BLAKE3 hashes over one resident buffer, aggregated for correctness
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 16.37 | 15.93 | 16.47 | 16.47 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 16.45 | 15.36 | 16.61 | 16.61 | ok |
| 64.0 MiB | blake3 | default-auto | 24.06 | 15.98 | 32.56 | 32.56 | ok |
| 64.0 MiB | cpu | batch-one-chunk-1024 | 1.26 | 1.26 | 1.26 | 1.26 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-gpu | 17.26 | 17.08 | 17.37 | 17.37 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-plan-gpu | 23.41 | 22.64 | 23.70 | 23.70 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-write-gpu | 32.39 | 29.91 | 33.51 | 33.51 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-gpu | 58.39 | 58.37 | 58.72 | 58.72 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-write-private-gpu | 36.14 | 35.89 | 37.31 | 37.31 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-private-gpu | 65.91 | 65.12 | 69.23 | 69.23 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-write-private-chained-gpu | 39.17 | 38.46 | 40.02 | 40.02 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-private-chained-gpu | 75.62 | 74.19 | 77.73 | 77.73 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-aggregate-api-gpu | 38.59 | 38.31 | 38.97 | 38.97 | ok |
| 64.0 MiB | metal | batch-one-chunk-1024-resident-plan-aggregate-api-gpu | 75.83 | 74.89 | 78.58 | 78.58 | ok |
| 64.0 MiB | metal | resident-auto | 58.23 | 40.85 | 80.60 | 80.60 | ok |
| 64.0 MiB | metal | resident-gpu | 71.50 | 40.59 | 82.07 | 82.07 | ok |
| 256.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel | 16.95 | 16.59 | 17.38 | 17.38 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.07 | 16.29 | 17.38 | 17.38 | ok |
| 256.0 MiB | blake3 | default-auto | 33.01 | 19.60 | 33.17 | 33.17 | ok |
| 256.0 MiB | cpu | batch-one-chunk-1024 | 1.26 | 1.26 | 1.26 | 1.26 | ok |
| 256.0 MiB | metal | batch-one-chunk-1024-resident-gpu | 19.97 | 19.75 | 20.27 | 20.27 | ok |
| 256.0 MiB | metal | batch-one-chunk-1024-resident-plan-gpu | 26.71 | 26.09 | 27.23 | 27.23 | ok |
| 256.0 MiB | metal | batch-one-chunk-1024-resident-write-gpu | 36.66 | 36.03 | 37.40 | 37.40 | ok |
| 256.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-gpu | 69.00 | 68.49 | 69.85 | 69.85 | ok |
| 256.0 MiB | metal | batch-one-chunk-1024-resident-write-private-gpu | 37.83 | 37.39 | 38.64 | 38.64 | ok |
| 256.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-private-gpu | 83.27 | 72.36 | 89.74 | 89.74 | ok |
| 256.0 MiB | metal | batch-one-chunk-1024-resident-write-private-chained-gpu | 39.32 | 38.78 | 39.40 | 39.40 | ok |
| 256.0 MiB | metal | batch-one-chunk-1024-resident-plan-write-private-chained-gpu | 85.60 | 84.28 | 94.61 | 94.61 | ok |
| 256.0 MiB | metal | batch-one-chunk-1024-resident-aggregate-api-gpu | 39.60 | 38.72 | 41.00 | 41.00 | ok |
| 256.0 MiB | metal | batch-one-chunk-1024-resident-plan-aggregate-api-gpu | 85.97 | 85.66 | 94.97 | 94.97 | ok |
| 256.0 MiB | metal | resident-auto | 100.31 | 91.91 | 101.10 | 101.10 | ok |
| 256.0 MiB | metal | resident-gpu | 92.17 | 85.65 | 100.86 | 100.86 | ok |
jsonOutput=perf-experiments/20261010T-m6-batch-paths/aggregate-candidate-64m-256m-1k-r2.json
