# nofused
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
| 256.0 MiB | cpu | scalar | 1.15 | 1.10 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.78 | 1.77 | 1.79 | 1.79 | ok |
| 256.0 MiB | cpu | parallel | 10.24 | 9.79 | 10.30 | 10.30 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.20 | 2.20 | ok |
| 256.0 MiB | cpu | context-auto | 10.38 | 10.05 | 10.69 | 10.69 | ok |
| 256.0 MiB | blake3 | default-auto | 30.38 | 20.64 | 31.71 | 31.71 | ok |
| 256.0 MiB | metal | resident-auto | 48.51 | 32.32 | 50.29 | 50.29 | ok |
| 256.0 MiB | metal | resident-gpu | 41.61 | 25.16 | 54.20 | 54.20 | ok |
| 256.0 MiB | metal | staged-auto | 16.77 | 15.46 | 17.78 | 17.78 | ok |
| 256.0 MiB | metal | staged-gpu | 16.43 | 15.26 | 18.06 | 18.06 | ok |
| 256.0 MiB | metal | wrapped-auto | 30.35 | 27.75 | 32.76 | 32.76 | ok |
| 256.0 MiB | metal | wrapped-gpu | 29.40 | 22.30 | 32.84 | 32.84 | ok |
jsonOutput=/Users/home/MetalCryptography/blake3swift/benchmarks/results/20260421T-resident256-digest-tuning/nofused.json
