BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=wrapped
pageAlignedWrappedInput=false
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.29 | 17.16 | 17.38 | 17.38 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.58 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.28 | 17.06 | 17.42 | 17.42 | ok |
| 1.0 GiB | blake3 | default-auto | 58.35 | 57.32 | 60.41 | 60.41 | ok |
| 1.0 GiB | metal | wrapped-auto | 58.42 | 56.04 | 60.85 | 60.85 | ok |
| 1.0 GiB | metal | wrapped-gpu | 58.73 | 57.15 | 60.15 | 60.15 | ok |
jsonOutput=/tmp/m6-page-aligned-normal/metal-wrapped-r1.json
