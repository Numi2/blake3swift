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
sizes=16.0 MiB
operationModes=batch-one-chunk
batchOneChunkItemByteCount=64
operation-batch-one-chunk includes: timed independent one-chunk BLAKE3 hashes over one resident buffer, aggregated for correctness
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.08 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.22 | 12.85 | 14.12 | 14.12 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.63 | 2.63 | ok |
| 16.0 MiB | cpu | context-auto | 13.41 | 12.72 | 14.26 | 14.26 | ok |
| 16.0 MiB | blake3 | default-auto | 28.36 | 14.08 | 29.91 | 29.91 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.41 | 0.41 | 0.42 | 0.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.51 | 1.48 | 1.53 | 1.53 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.13 | 2.00 | 2.20 | 2.20 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.26 | 3.18 | 3.42 | 3.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 10.25 | 8.66 | 12.46 | 12.46 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.58 | 3.46 | 3.70 | 3.70 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 31.91 | 30.21 | 34.11 | 34.11 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.80 | 3.77 | 4.01 | 4.01 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 22.95 | 22.13 | 46.16 | 46.16 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.82 | 3.79 | 4.01 | 4.01 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 38.76 | 22.68 | 43.52 | 43.52 | ok |
| 16.0 MiB | metal | resident-auto | 42.60 | 21.27 | 52.60 | 52.60 | ok |
| 16.0 MiB | metal | resident-gpu | 28.41 | 22.51 | 52.87 | 52.87 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/warm-batch-groups-8-r2.json
