BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=wrapped,staged
pageAlignedWrappedInput=false
pageAlignedCopyWorkers=1
pageAlignedCopyWriteCombined=false
metalCommandTiming=false
metalCommandBackend=legacy
metalDigestPipelineWidthHint=true
metal-staged includes: pre-created shared staging MTLBuffer; timed Swift-byte copy into staging buffer plus hash
metal-wrapped includes: timed Swift input route with page-aligned shared-buffer allocation/copy, hash command submission, and completion
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.36 | 17.23 | 17.38 | 17.38 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.30 | 17.21 | 17.46 | 17.46 | ok |
| 1.0 GiB | blake3 | default-auto | 32.15 | 31.95 | 32.69 | 32.69 | ok |
| 1.0 GiB | metal | staged-auto | 34.78 | 34.41 | 34.95 | 34.95 | ok |
| 1.0 GiB | metal | staged-gpu | 34.66 | 34.43 | 34.93 | 34.93 | ok |
| 1.0 GiB | metal | wrapped-auto | 31.97 | 31.26 | 32.49 | 32.49 | ok |
| 1.0 GiB | metal | wrapped-gpu | 32.23 | 32.05 | 32.71 | 32.71 | ok |
jsonOutput=/tmp/m6-reusable-staging-ab.json
