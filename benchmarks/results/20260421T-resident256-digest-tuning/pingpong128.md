# pingpong128
BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=resident,wrapped,staged
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-staged includes: pre-created shared staging MTLBuffer; timed Swift-byte copy into staging buffer plus hash
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=256.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.83 | 1.81 | 1.84 | 1.84 | ok |
| 256.0 MiB | cpu | parallel | 10.64 | 10.31 | 10.81 | 10.81 | ok |
| 256.0 MiB | official-c | one-shot | 2.22 | 2.21 | 2.24 | 2.24 | ok |
| 256.0 MiB | cpu | context-auto | 10.25 | 9.80 | 10.62 | 10.62 | ok |
| 256.0 MiB | blake3 | default-auto | 32.39 | 30.42 | 36.72 | 36.72 | ok |
| 256.0 MiB | metal | resident-auto | 47.03 | 40.24 | 57.48 | 57.48 | ok |
| 256.0 MiB | metal | resident-gpu | 48.79 | 44.47 | 54.61 | 54.61 | ok |
| 256.0 MiB | metal | staged-auto | 19.34 | 17.37 | 20.14 | 20.14 | ok |
| 256.0 MiB | metal | staged-gpu | 17.61 | 16.60 | 19.81 | 19.81 | ok |
| 256.0 MiB | metal | wrapped-auto | 33.82 | 28.73 | 40.60 | 40.60 | ok |
| 256.0 MiB | metal | wrapped-gpu | 34.12 | 32.96 | 36.46 | 36.46 | ok |
jsonOutput=/Users/home/MetalCryptography/blake3swift/benchmarks/results/20260421T-resident256-digest-tuning/pingpong128.json
