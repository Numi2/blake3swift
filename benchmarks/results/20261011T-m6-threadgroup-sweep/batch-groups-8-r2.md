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
| 16.0 MiB | cpu | single-simd | 2.13 | 2.12 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 14.01 | 12.98 | 14.10 | 14.10 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 14.02 | 13.96 | 14.21 | 14.21 | ok |
| 16.0 MiB | blake3 | default-auto | 16.23 | 13.92 | 17.36 | 17.36 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.46 | 1.43 | 1.49 | 1.49 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.03 | 2.00 | 2.21 | 2.21 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.18 | 3.15 | 3.20 | 3.20 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 9.12 | 8.35 | 9.89 | 9.89 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.52 | 3.50 | 3.69 | 3.69 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 31.64 | 20.01 | 32.19 | 32.19 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.82 | 3.78 | 3.83 | 3.83 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 22.98 | 22.49 | 23.61 | 23.61 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.81 | 3.78 | 3.89 | 3.89 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 23.24 | 22.76 | 23.77 | 23.77 | ok |
| 16.0 MiB | metal | resident-auto | 23.56 | 21.89 | 25.54 | 25.54 | ok |
| 16.0 MiB | metal | resident-gpu | 22.82 | 22.43 | 23.66 | 23.66 | ok |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 15.93 | 15.69 | 16.58 | 16.58 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 15.38 | 15.22 | 15.60 | 15.60 | ok |
| 64.0 MiB | blake3 | default-auto | 23.41 | 17.43 | 32.72 | 32.72 | ok |
| 64.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.41 | 0.42 | 0.42 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.54 | 1.54 | 1.57 | 1.57 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.30 | 2.27 | 2.32 | 2.32 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.69 | 3.66 | 3.71 | 3.71 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 17.84 | 15.41 | 19.60 | 19.60 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 4.15 | 3.99 | 4.18 | 4.18 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 35.39 | 32.35 | 38.04 | 38.04 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 4.32 | 4.19 | 4.49 | 4.49 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 38.81 | 35.39 | 42.12 | 42.12 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 4.26 | 4.18 | 4.49 | 4.49 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 28.96 | 24.61 | 35.91 | 35.91 | ok |
| 64.0 MiB | metal | resident-auto | 46.81 | 42.24 | 80.22 | 80.22 | ok |
| 64.0 MiB | metal | resident-gpu | 74.73 | 39.95 | 78.24 | 78.24 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/batch-groups-8-r2.json
