# default
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
| 256.0 MiB | cpu | scalar | 1.19 | 1.17 | 1.19 | 1.19 | ok |
| 256.0 MiB | cpu | single-simd | 1.89 | 1.88 | 1.90 | 1.90 | ok |
| 256.0 MiB | cpu | parallel | 10.19 | 9.92 | 10.39 | 10.39 | ok |
| 256.0 MiB | official-c | one-shot | 2.28 | 2.28 | 2.30 | 2.30 | ok |
| 256.0 MiB | cpu | context-auto | 10.59 | 10.17 | 10.88 | 10.88 | ok |
| 256.0 MiB | blake3 | default-auto | 31.90 | 27.99 | 34.69 | 34.69 | ok |
| 256.0 MiB | metal | resident-auto | 44.59 | 40.73 | 49.48 | 49.48 | ok |
| 256.0 MiB | metal | resident-gpu | 46.45 | 32.04 | 55.03 | 55.03 | ok |
| 256.0 MiB | metal | staged-auto | 18.48 | 15.49 | 21.26 | 21.26 | ok |
| 256.0 MiB | metal | staged-gpu | 18.92 | 17.90 | 19.47 | 19.47 | ok |
| 256.0 MiB | metal | wrapped-auto | 32.62 | 29.30 | 36.15 | 36.15 | ok |
| 256.0 MiB | metal | wrapped-gpu | 33.07 | 28.72 | 34.01 | 34.01 | ok |
jsonOutput=/Users/home/MetalCryptography/blake3swift/benchmarks/results/20260421T-resident256-digest-tuning/default.json
