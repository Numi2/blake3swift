# inplace128
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
| 256.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.17 | 1.17 | ok |
| 256.0 MiB | cpu | single-simd | 1.70 | 1.57 | 1.80 | 1.80 | ok |
| 256.0 MiB | cpu | parallel | 10.36 | 9.28 | 10.60 | 10.60 | ok |
| 256.0 MiB | official-c | one-shot | 2.22 | 2.18 | 2.25 | 2.25 | ok |
| 256.0 MiB | cpu | context-auto | 10.63 | 10.05 | 11.50 | 11.50 | ok |
| 256.0 MiB | blake3 | default-auto | 33.79 | 31.52 | 36.55 | 36.55 | ok |
| 256.0 MiB | metal | resident-auto | 47.34 | 40.38 | 49.69 | 49.69 | ok |
| 256.0 MiB | metal | resident-gpu | 54.39 | 45.26 | 62.05 | 62.05 | ok |
| 256.0 MiB | metal | staged-auto | 17.56 | 16.03 | 21.38 | 21.38 | ok |
| 256.0 MiB | metal | staged-gpu | 19.82 | 16.70 | 21.44 | 21.44 | ok |
| 256.0 MiB | metal | wrapped-auto | 36.89 | 34.29 | 38.58 | 38.58 | ok |
| 256.0 MiB | metal | wrapped-gpu | 35.61 | 33.23 | 38.98 | 38.98 | ok |
jsonOutput=/Users/home/MetalCryptography/blake3swift/benchmarks/results/20260421T-resident256-digest-tuning/inplace128.json
