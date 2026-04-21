# inplace256
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
| 256.0 MiB | cpu | scalar | 1.15 | 0.98 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.78 | 1.74 | 1.80 | 1.80 | ok |
| 256.0 MiB | cpu | parallel | 8.00 | 7.80 | 8.28 | 8.28 | ok |
| 256.0 MiB | official-c | one-shot | 2.16 | 1.98 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.05 | 9.35 | 10.81 | 10.81 | ok |
| 256.0 MiB | blake3 | default-auto | 27.38 | 21.21 | 36.74 | 36.74 | ok |
| 256.0 MiB | metal | resident-auto | 36.77 | 32.02 | 44.54 | 44.54 | ok |
| 256.0 MiB | metal | resident-gpu | 31.59 | 26.60 | 44.52 | 44.52 | ok |
| 256.0 MiB | metal | staged-auto | 15.35 | 14.71 | 19.46 | 19.46 | ok |
| 256.0 MiB | metal | staged-gpu | 15.62 | 13.62 | 19.41 | 19.41 | ok |
| 256.0 MiB | metal | wrapped-auto | 25.78 | 21.96 | 34.61 | 34.61 | ok |
| 256.0 MiB | metal | wrapped-gpu | 26.89 | 22.13 | 36.17 | 36.17 | ok |
jsonOutput=/Users/home/MetalCryptography/blake3swift/benchmarks/results/20260421T-resident256-digest-tuning/inplace256.json
