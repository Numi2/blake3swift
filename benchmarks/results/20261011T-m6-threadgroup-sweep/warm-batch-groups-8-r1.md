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
| 16.0 MiB | cpu | scalar | 1.35 | 1.01 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.11 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.98 | 13.28 | 14.19 | 14.19 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 14.02 | 12.89 | 14.41 | 14.41 | ok |
| 16.0 MiB | blake3 | default-auto | 17.25 | 12.99 | 18.86 | 18.86 | ok |
| 16.0 MiB | cpu | batch-one-chunk-64 | 0.41 | 0.41 | 0.42 | 0.42 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-gpu | 1.43 | 1.40 | 1.45 | 1.45 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-gpu | 2.03 | 1.99 | 2.19 | 2.19 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-gpu | 3.24 | 3.10 | 3.37 | 3.37 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-gpu | 10.30 | 9.26 | 12.57 | 12.57 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-gpu | 3.78 | 3.56 | 3.90 | 3.90 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-gpu | 33.08 | 31.36 | 35.59 | 35.59 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-write-private-chained-gpu | 3.81 | 3.77 | 4.02 | 4.02 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-write-private-chained-gpu | 23.67 | 19.52 | 43.15 | 43.15 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-aggregate-api-gpu | 3.81 | 3.76 | 3.95 | 3.95 | ok |
| 16.0 MiB | metal | batch-one-chunk-64-resident-plan-aggregate-api-gpu | 23.46 | 20.34 | 42.05 | 42.05 | ok |
| 16.0 MiB | metal | resident-auto | 24.70 | 17.47 | 28.37 | 28.37 | ok |
| 16.0 MiB | metal | resident-gpu | 25.04 | 21.85 | 28.57 | 28.57 | ok |
jsonOutput=perf-experiments/20261011T-m6-threadgroup-sweep/warm-batch-groups-8-r1.json
