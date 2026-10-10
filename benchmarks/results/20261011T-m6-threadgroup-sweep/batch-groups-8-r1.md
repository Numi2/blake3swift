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
| 16.0 MiB | cpu | scalar | 1.34 | 1.05 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.13 | 2.13 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.89 | 13.83 | 14.11 | 14.11 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.60 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.93 | 13.34 | 13.96 | 13.96 | ok |
| 16.0 MiB | blake3 | default-auto | 16.49 | 15.92 | 19.03 | 19.03 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.44 | 1.42 | 1.45 | 1.45 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.10 | 2.02 | 2.15 | 2.15 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.12 | 3.12 | 3.22 | 3.22 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 8.84 | 8.67 | 12.01 | 12.01 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.37 | 3.34 | 3.44 | 3.44 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 30.19 | 14.18 | 32.81 | 32.81 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.74 | 3.67 | 3.82 | 3.82 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 23.12 | 20.54 | 39.84 | 39.84 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.78 | 3.71 | 3.88 | 3.88 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 21.60 | 20.68 | 42.17 | 42.17 | ok |
| 16.0 MiB | metal | resident-auto | 27.13 | 22.59 | 28.84 | 28.84 | ok |
| 16.0 MiB | metal | resident-gpu | 25.28 | 23.91 | 26.21 | 26.21 | ok |
| 64.0 MiB | cpu | scalar | 1.33 | 1.33 | 1.34 | 1.34 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.10 | 2.15 | 2.15 | ok |
| 64.0 MiB | cpu | parallel | 15.43 | 15.25 | 15.88 | 15.88 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 15.37 | 15.12 | 15.92 | 15.92 | ok |
| 64.0 MiB | blake3 | default-auto | 27.70 | 17.56 | 31.52 | 31.52 | ok |
| 64.0 MiB | cpu | batch-one-chunk-64 | 0.42 | 0.42 | 0.42 | 0.42 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.58 | 1.58 | 1.60 | 1.60 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.25 | 2.22 | 2.30 | 2.30 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.70 | 3.69 | 3.73 | 3.73 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 17.69 | 16.18 | 19.70 | 19.70 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 4.19 | 4.03 | 4.37 | 4.37 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 25.39 | 18.75 | 35.28 | 35.28 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 4.38 | 4.05 | 4.42 | 4.42 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 33.48 | 20.57 | 35.65 | 35.65 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 4.29 | 4.27 | 4.50 | 4.50 | ok |
| 64.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 39.60 | 38.63 | 44.12 | 44.12 | ok |
| 64.0 MiB | metal | resident-auto | 55.59 | 30.31 | 75.83 | 75.83 | ok |
| 64.0 MiB | metal | resident-gpu | 55.30 | 30.80 | 80.44 | 80.44 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/batch-groups-8-r1.json
