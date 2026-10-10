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
| 16.0 MiB | cpu | single-simd | 2.13 | 2.12 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.34 | 12.54 | 13.83 | 13.83 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.94 | 13.66 | 14.21 | 14.21 | ok |
| 16.0 MiB | blake3 | default-auto | 15.93 | 13.67 | 16.77 | 16.77 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.41 | 0.41 | 0.42 | 0.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.51 | 1.51 | 1.52 | 1.52 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.15 | 2.04 | 2.17 | 2.17 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.20 | 3.19 | 3.25 | 3.25 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 8.83 | 8.21 | 11.47 | 11.47 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.67 | 3.48 | 3.96 | 3.96 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 31.64 | 19.55 | 32.32 | 32.32 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.83 | 3.79 | 3.87 | 3.87 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 23.15 | 22.80 | 23.88 | 23.88 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.83 | 3.78 | 3.87 | 3.87 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 41.80 | 23.52 | 44.27 | 44.27 | ok |
| 16.0 MiB | metal | resident-auto | 23.28 | 21.57 | 23.45 | 23.45 | ok |
| 16.0 MiB | metal | resident-gpu | 23.57 | 22.69 | 23.83 | 23.83 | ok |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.13 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 15.36 | 15.21 | 15.94 | 15.94 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 15.30 | 15.12 | 15.83 | 15.83 | ok |
| 64.0 MiB | blake3 | default-auto | 23.40 | 19.78 | 32.20 | 32.20 | ok |
| 64.0 MiB | cpu | batch-one-chunk-64 | 0.41 | 0.41 | 0.42 | 0.42 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.53 | 1.52 | 1.56 | 1.56 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.22 | 2.21 | 2.29 | 2.29 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.71 | 3.69 | 3.76 | 3.76 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 16.86 | 16.53 | 20.26 | 20.26 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 4.15 | 3.95 | 4.16 | 4.16 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 30.57 | 23.50 | 31.22 | 31.22 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 4.28 | 4.14 | 4.44 | 4.44 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 42.35 | 38.22 | 47.45 | 47.45 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 4.39 | 4.11 | 4.46 | 4.46 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 25.31 | 20.08 | 43.05 | 43.05 | ok |
| 64.0 MiB | metal | resident-auto | 41.57 | 40.39 | 79.44 | 79.44 | ok |
| 64.0 MiB | metal | resident-gpu | 54.13 | 40.72 | 81.49 | 81.49 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/batch-groups-4-r2.json
