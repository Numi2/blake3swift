BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=wrapped
pageAlignedWrappedInput=true
metal-wrapped includes: timed page-aligned allocation and copy, no-copy MTLBuffer wrapper, and hash
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.41 | 17.20 | 17.50 | 17.50 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.40 | 17.37 | 17.46 | 17.46 | ok |
| 1.0 GiB | blake3 | default-auto | 51.69 | 44.35 | 59.43 | 59.43 | ok |
| 1.0 GiB | metal | wrapped-auto | 25.33 | 21.20 | 25.90 | 25.90 | ok |
| 1.0 GiB | metal | wrapped-gpu | 25.45 | 25.40 | 25.79 | 25.79 | ok |
jsonOutput=/tmp/m6-page-aligned-copy/metal-wrapped-r1.json
