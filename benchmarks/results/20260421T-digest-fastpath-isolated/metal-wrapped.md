BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=wrapped
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.15 | 1.08 | 1.17 | 1.17 | ok |
| 16.0 MiB | cpu | single-simd | 1.75 | 1.73 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 9.21 | 7.62 | 9.34 | 9.34 | ok |
| 16.0 MiB | official-c | one-shot | 2.18 | 2.14 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 8.24 | 7.57 | 9.17 | 9.17 | ok |
| 16.0 MiB | blake3 | default-auto | 12.68 | 7.76 | 18.33 | 18.33 | ok |
| 16.0 MiB | metal | wrapped-auto | 15.47 | 8.54 | 20.55 | 20.55 | ok |
| 16.0 MiB | metal | wrapped-gpu | 15.96 | 13.58 | 19.24 | 19.24 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.12 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.74 | 1.72 | 1.75 | 1.75 | ok |
| 64.0 MiB | cpu | parallel | 9.98 | 8.83 | 10.36 | 10.36 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.77 | 8.88 | 10.30 | 10.30 | ok |
| 64.0 MiB | blake3 | default-auto | 27.08 | 16.90 | 32.10 | 32.10 | ok |
| 64.0 MiB | metal | wrapped-auto | 28.96 | 17.01 | 31.41 | 31.41 | ok |
| 64.0 MiB | metal | wrapped-gpu | 29.93 | 20.17 | 32.57 | 32.57 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.73 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.20 | 8.61 | 10.40 | 10.40 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.45 | 10.37 | 10.83 | 10.83 | ok |
| 256.0 MiB | blake3 | default-auto | 31.01 | 28.54 | 35.59 | 35.59 | ok |
| 256.0 MiB | metal | wrapped-auto | 32.29 | 28.16 | 35.48 | 35.48 | ok |
| 256.0 MiB | metal | wrapped-gpu | 30.85 | 27.84 | 34.39 | 34.39 | ok |
jsonOutput=benchmarks/results/20260421T-digest-fastpath-isolated/metal-wrapped.json
