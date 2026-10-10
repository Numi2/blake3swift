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
| 16.0 MiB | cpu | parallel | 13.81 | 12.56 | 14.06 | 14.06 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.88 | 13.62 | 14.04 | 14.04 | ok |
| 16.0 MiB | blake3 | default-auto | 11.98 | 11.41 | 12.60 | 12.60 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.47 | 1.46 | 1.49 | 1.49 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.03 | 2.02 | 2.06 | 2.06 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.20 | 3.13 | 3.33 | 3.33 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 9.19 | 8.63 | 11.19 | 11.19 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.47 | 3.41 | 3.70 | 3.70 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 29.91 | 20.03 | 33.24 | 33.24 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.80 | 3.79 | 3.94 | 3.94 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 40.20 | 22.46 | 43.62 | 43.62 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.80 | 3.75 | 3.94 | 3.94 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 22.03 | 19.59 | 22.62 | 22.62 | ok |
| 16.0 MiB | metal | resident-auto | 14.36 | 12.46 | 21.80 | 21.80 | ok |
| 16.0 MiB | metal | resident-gpu | 18.98 | 13.40 | 25.41 | 25.41 | ok |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.11 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 16.15 | 15.26 | 16.67 | 16.67 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 15.26 | 15.14 | 15.60 | 15.60 | ok |
| 64.0 MiB | blake3 | default-auto | 31.23 | 19.64 | 31.91 | 31.91 | ok |
| 64.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.57 | 1.53 | 1.57 | 1.57 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.29 | 2.25 | 2.30 | 2.30 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.69 | 3.65 | 3.74 | 3.74 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 14.57 | 14.48 | 18.84 | 18.84 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 4.14 | 4.12 | 4.28 | 4.28 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 23.85 | 22.39 | 26.72 | 26.72 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 4.31 | 4.17 | 4.50 | 4.50 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 20.56 | 19.47 | 40.35 | 40.35 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 4.27 | 4.12 | 4.51 | 4.51 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 29.40 | 29.02 | 36.19 | 36.19 | ok |
| 64.0 MiB | metal | resident-auto | 69.18 | 40.78 | 74.98 | 74.98 | ok |
| 64.0 MiB | metal | resident-gpu | 68.60 | 39.24 | 76.00 | 76.00 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/batch-groups-16-r2.json
