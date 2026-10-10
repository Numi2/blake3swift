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
| 16.0 MiB | cpu | single-simd | 2.13 | 2.10 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.58 | 13.00 | 14.31 | 14.31 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.69 | 12.86 | 14.08 | 14.08 | ok |
| 16.0 MiB | blake3 | default-auto | 15.95 | 14.16 | 16.47 | 16.47 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.52 | 1.48 | 1.55 | 1.55 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.18 | 2.16 | 2.25 | 2.25 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.27 | 3.21 | 3.37 | 3.37 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 9.27 | 8.40 | 11.72 | 11.72 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.55 | 3.51 | 3.66 | 3.66 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 30.56 | 30.25 | 30.67 | 30.67 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.79 | 3.77 | 3.88 | 3.88 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 22.25 | 19.35 | 22.46 | 22.46 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.85 | 3.76 | 3.87 | 3.87 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 23.00 | 22.54 | 23.48 | 23.48 | ok |
| 16.0 MiB | metal | resident-auto | 23.82 | 22.07 | 24.92 | 24.92 | ok |
| 16.0 MiB | metal | resident-gpu | 24.73 | 22.82 | 25.67 | 25.67 | ok |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 16.42 | 15.86 | 16.45 | 16.45 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 15.35 | 15.30 | 15.67 | 15.67 | ok |
| 64.0 MiB | blake3 | default-auto | 23.70 | 12.50 | 32.24 | 32.24 | ok |
| 64.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.56 | 1.56 | 1.57 | 1.57 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.29 | 2.26 | 2.34 | 2.34 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.72 | 3.70 | 3.74 | 3.74 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 18.59 | 16.54 | 19.69 | 19.69 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 4.14 | 4.06 | 4.24 | 4.24 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 30.58 | 30.30 | 30.81 | 30.81 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 4.36 | 4.20 | 4.44 | 4.44 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 39.21 | 36.90 | 41.28 | 41.28 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 4.43 | 4.15 | 4.46 | 4.46 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 24.86 | 19.93 | 42.03 | 42.03 | ok |
| 64.0 MiB | metal | resident-auto | 43.37 | 42.38 | 79.94 | 79.94 | ok |
| 64.0 MiB | metal | resident-gpu | 70.45 | 40.13 | 78.29 | 78.29 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/batch-groups-16-r1.json
