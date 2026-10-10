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
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.13 | 2.12 | 2.13 | 2.13 | ok |
| 16.0 MiB | cpu | parallel | 13.86 | 12.94 | 14.07 | 14.07 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.63 | 2.63 | ok |
| 16.0 MiB | cpu | context-auto | 13.85 | 13.74 | 13.92 | 13.92 | ok |
| 16.0 MiB | blake3 | default-auto | 16.11 | 13.32 | 18.05 | 18.05 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.49 | 1.48 | 1.52 | 1.52 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.12 | 2.02 | 2.22 | 2.22 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.21 | 3.19 | 3.25 | 3.25 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 10.53 | 8.89 | 14.42 | 14.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.62 | 3.48 | 3.75 | 3.75 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 30.32 | 19.46 | 30.99 | 30.99 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.84 | 3.77 | 3.93 | 3.93 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 22.23 | 21.09 | 23.70 | 23.70 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.78 | 3.77 | 3.99 | 3.99 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 22.44 | 20.26 | 22.60 | 22.60 | ok |
| 16.0 MiB | metal | resident-auto | 23.18 | 22.21 | 24.10 | 24.10 | ok |
| 16.0 MiB | metal | resident-gpu | 23.66 | 22.83 | 23.81 | 23.81 | ok |
| 64.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 15.75 | 14.95 | 16.50 | 16.50 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 15.24 | 15.19 | 15.36 | 15.36 | ok |
| 64.0 MiB | blake3 | default-auto | 23.39 | 18.90 | 33.18 | 33.18 | ok |
| 64.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.54 | 1.53 | 1.58 | 1.58 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.27 | 2.23 | 2.28 | 2.28 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.72 | 3.70 | 3.73 | 3.73 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 18.28 | 14.88 | 19.73 | 19.73 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 4.16 | 4.09 | 4.23 | 4.23 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 30.91 | 27.90 | 36.23 | 36.23 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 4.34 | 4.17 | 4.51 | 4.51 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 39.10 | 27.37 | 45.50 | 45.50 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 4.26 | 4.11 | 4.52 | 4.52 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 34.43 | 22.00 | 35.49 | 35.49 | ok |
| 64.0 MiB | metal | resident-auto | 42.66 | 39.36 | 78.66 | 78.66 | ok |
| 64.0 MiB | metal | resident-gpu | 44.98 | 40.31 | 76.82 | 76.82 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/batch-groups-32-r2.json
