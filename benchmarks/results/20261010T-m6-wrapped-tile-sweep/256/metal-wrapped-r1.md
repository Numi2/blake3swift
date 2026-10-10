BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=wrapped
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.28 | 16.93 | 17.36 | 17.36 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.43 | 17.36 | 17.52 | 17.52 | ok |
| 1.0 GiB | blake3 | default-auto | 58.64 | 58.43 | 59.31 | 59.31 | ok |
| 1.0 GiB | metal | wrapped-auto | 58.57 | 57.84 | 60.83 | 60.83 | ok |
| 1.0 GiB | metal | wrapped-gpu | 59.06 | 57.84 | 60.03 | 60.03 | ok |
jsonOutput=/tmp/m6-wrapped-tile-256/metal-wrapped-r1.json
