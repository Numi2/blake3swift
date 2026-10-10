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
| 16.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.12 | 2.12 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.71 | 12.75 | 14.03 | 14.03 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.63 | 2.63 | ok |
| 16.0 MiB | cpu | context-auto | 14.16 | 13.99 | 14.36 | 14.36 | ok |
| 16.0 MiB | blake3 | default-auto | 16.09 | 13.59 | 16.57 | 16.57 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.52 | 1.48 | 1.54 | 1.54 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.18 | 2.13 | 2.19 | 2.19 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.25 | 3.20 | 3.37 | 3.37 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 8.37 | 8.07 | 11.73 | 11.73 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.50 | 3.44 | 3.65 | 3.65 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 30.40 | 18.54 | 31.41 | 31.41 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.87 | 3.79 | 4.10 | 4.10 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 22.58 | 19.73 | 41.07 | 41.07 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.85 | 3.77 | 3.89 | 3.89 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 40.50 | 23.38 | 44.97 | 44.97 | ok |
| 16.0 MiB | metal | resident-auto | 22.47 | 21.65 | 24.17 | 24.17 | ok |
| 16.0 MiB | metal | resident-gpu | 24.09 | 23.65 | 25.83 | 25.83 | ok |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 15.87 | 15.36 | 16.52 | 16.52 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 15.34 | 15.23 | 15.86 | 15.86 | ok |
| 64.0 MiB | blake3 | default-auto | 24.42 | 19.35 | 32.47 | 32.47 | ok |
| 64.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.55 | 1.54 | 1.58 | 1.58 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.27 | 2.24 | 2.30 | 2.30 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.69 | 3.68 | 3.72 | 3.72 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 17.13 | 15.52 | 18.78 | 18.78 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 4.19 | 4.01 | 4.27 | 4.27 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 30.64 | 19.99 | 37.41 | 37.41 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 4.28 | 4.16 | 4.44 | 4.44 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 21.89 | 19.86 | 25.57 | 25.57 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 4.25 | 4.14 | 4.51 | 4.51 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 29.02 | 20.77 | 34.24 | 34.24 | ok |
| 64.0 MiB | metal | resident-auto | 74.32 | 40.32 | 78.94 | 78.94 | ok |
| 64.0 MiB | metal | resident-gpu | 73.75 | 42.21 | 77.56 | 77.56 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/batch-groups-32-r1.json
