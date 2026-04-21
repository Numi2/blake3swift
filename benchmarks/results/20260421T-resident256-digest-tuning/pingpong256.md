# pingpong256
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
| 256.0 MiB | cpu | single-simd | 1.80 | 1.76 | 1.82 | 1.82 | ok |
| 256.0 MiB | cpu | parallel | 10.65 | 10.32 | 10.94 | 10.94 | ok |
| 256.0 MiB | official-c | one-shot | 2.21 | 2.19 | 2.22 | 2.22 | ok |
| 256.0 MiB | cpu | context-auto | 10.60 | 10.30 | 10.98 | 10.98 | ok |
| 256.0 MiB | blake3 | default-auto | 35.14 | 26.62 | 44.94 | 44.94 | ok |
| 256.0 MiB | metal | resident-auto | 52.79 | 35.30 | 77.53 | 77.53 | ok |
| 256.0 MiB | metal | resident-gpu | 54.22 | 46.08 | 66.74 | 66.74 | ok |
| 256.0 MiB | metal | staged-auto | 18.69 | 16.50 | 23.54 | 23.54 | ok |
| 256.0 MiB | metal | staged-gpu | 17.41 | 16.00 | 23.56 | 23.56 | ok |
| 256.0 MiB | metal | wrapped-auto | 31.56 | 27.76 | 49.04 | 49.04 | ok |
| 256.0 MiB | metal | wrapped-gpu | 30.43 | 26.94 | 42.76 | 42.76 | ok |
jsonOutput=/Users/home/MetalCryptography/blake3swift/benchmarks/results/20260421T-resident256-digest-tuning/pingpong256.json
