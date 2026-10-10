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
| 1.0 GiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.12 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.20 | 17.09 | 17.33 | 17.33 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.40 | 17.22 | 17.52 | 17.52 | ok |
| 1.0 GiB | blake3 | default-auto | 54.38 | 54.18 | 62.80 | 62.80 | ok |
| 1.0 GiB | metal | wrapped-auto | 29.39 | 28.68 | 30.22 | 30.22 | ok |
| 1.0 GiB | metal | wrapped-gpu | 29.74 | 29.58 | 29.90 | 29.90 | ok |
jsonOutput=/tmp/m6-page-aligned-copy/metal-wrapped-r3.json
