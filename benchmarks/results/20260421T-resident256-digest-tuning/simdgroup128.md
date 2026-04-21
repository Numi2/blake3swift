# simdgroup128
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
| 256.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.81 | 1.79 | 1.82 | 1.82 | ok |
| 256.0 MiB | cpu | parallel | 9.87 | 9.58 | 10.55 | 10.55 | ok |
| 256.0 MiB | official-c | one-shot | 2.22 | 2.20 | 2.23 | 2.23 | ok |
| 256.0 MiB | cpu | context-auto | 10.66 | 10.02 | 10.95 | 10.95 | ok |
| 256.0 MiB | blake3 | default-auto | 28.65 | 25.02 | 31.03 | 31.03 | ok |
| 256.0 MiB | metal | resident-auto | 42.22 | 35.81 | 55.10 | 55.10 | ok |
| 256.0 MiB | metal | resident-gpu | 44.59 | 40.56 | 51.00 | 51.00 | ok |
| 256.0 MiB | metal | staged-auto | 18.11 | 17.07 | 20.11 | 20.11 | ok |
| 256.0 MiB | metal | staged-gpu | 17.99 | 15.90 | 19.64 | 19.64 | ok |
| 256.0 MiB | metal | wrapped-auto | 31.11 | 28.84 | 35.46 | 35.46 | ok |
| 256.0 MiB | metal | wrapped-gpu | 32.24 | 29.04 | 34.96 | 34.96 | ok |
jsonOutput=/Users/home/MetalCryptography/blake3swift/benchmarks/results/20260421T-resident256-digest-tuning/simdgroup128.json
