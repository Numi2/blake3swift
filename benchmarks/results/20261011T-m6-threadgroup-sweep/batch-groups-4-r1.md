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
| 16.0 MiB | cpu | parallel | 13.94 | 12.37 | 14.15 | 14.15 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 14.06 | 13.13 | 14.51 | 14.51 | ok |
| 16.0 MiB | blake3 | default-auto | 16.63 | 14.11 | 18.03 | 18.03 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.52 | 1.49 | 1.55 | 1.55 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.18 | 2.15 | 2.20 | 2.20 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.21 | 3.19 | 3.25 | 3.25 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 8.90 | 8.60 | 12.92 | 12.92 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.58 | 3.41 | 3.73 | 3.73 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 31.44 | 14.69 | 32.79 | 32.79 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 4.04 | 3.86 | 4.10 | 4.10 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 37.91 | 22.52 | 43.17 | 43.17 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.88 | 3.77 | 3.99 | 3.99 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 41.35 | 23.93 | 43.55 | 43.55 | ok |
| 16.0 MiB | metal | resident-auto | 24.97 | 22.70 | 26.70 | 26.70 | ok |
| 16.0 MiB | metal | resident-gpu | 25.61 | 24.33 | 27.14 | 27.14 | ok |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 16.48 | 15.88 | 16.56 | 16.56 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 15.33 | 15.08 | 15.95 | 15.95 | ok |
| 64.0 MiB | blake3 | default-auto | 31.71 | 13.15 | 32.25 | 32.25 | ok |
| 64.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.58 | 1.53 | 1.59 | 1.59 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.27 | 2.24 | 2.32 | 2.32 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.73 | 3.68 | 3.79 | 3.79 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 17.35 | 13.84 | 19.72 | 19.72 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 4.18 | 3.99 | 4.39 | 4.39 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 27.42 | 17.51 | 42.84 | 42.84 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 4.39 | 4.19 | 4.54 | 4.54 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 36.78 | 35.73 | 37.49 | 37.49 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 4.37 | 4.31 | 4.46 | 4.46 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 36.80 | 33.36 | 42.34 | 42.34 | ok |
| 64.0 MiB | metal | resident-auto | 76.18 | 41.50 | 79.19 | 79.19 | ok |
| 64.0 MiB | metal | resident-gpu | 77.52 | 42.23 | 77.93 | 77.93 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/batch-groups-4-r1.json
