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
| 16.0 MiB | cpu | scalar | 1.17 | 1.15 | 1.18 | 1.18 | ok |
| 16.0 MiB | cpu | single-simd | 1.85 | 1.83 | 1.90 | 1.90 | ok |
| 16.0 MiB | cpu | parallel | 9.98 | 8.71 | 10.58 | 10.58 | ok |
| 16.0 MiB | official-c | one-shot | 2.24 | 2.24 | 2.30 | 2.30 | ok |
| 16.0 MiB | cpu | context-auto | 10.07 | 9.54 | 10.41 | 10.41 | ok |
| 16.0 MiB | blake3 | default-auto | 13.32 | 3.10 | 19.66 | 19.66 | ok |
| 16.0 MiB | metal | wrapped-auto | 11.07 | 5.59 | 16.03 | 16.03 | ok |
| 16.0 MiB | metal | wrapped-gpu | 9.56 | 8.63 | 14.40 | 14.40 | ok |
| 64.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.81 | 1.80 | 1.83 | 1.83 | ok |
| 64.0 MiB | cpu | parallel | 11.12 | 10.91 | 11.78 | 11.78 | ok |
| 64.0 MiB | official-c | one-shot | 2.19 | 2.13 | 2.22 | 2.22 | ok |
| 64.0 MiB | cpu | context-auto | 11.16 | 11.02 | 11.73 | 11.73 | ok |
| 64.0 MiB | blake3 | default-auto | 25.79 | 20.31 | 28.72 | 28.72 | ok |
| 64.0 MiB | metal | wrapped-auto | 27.38 | 18.21 | 32.21 | 32.21 | ok |
| 64.0 MiB | metal | wrapped-gpu | 29.84 | 26.25 | 32.24 | 32.24 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.10 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.77 | 1.77 | 1.79 | 1.79 | ok |
| 256.0 MiB | cpu | parallel | 11.71 | 11.60 | 11.77 | 11.77 | ok |
| 256.0 MiB | official-c | one-shot | 2.16 | 2.15 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 11.27 | 10.41 | 11.67 | 11.67 | ok |
| 256.0 MiB | blake3 | default-auto | 31.39 | 28.83 | 31.78 | 31.78 | ok |
| 256.0 MiB | metal | wrapped-auto | 29.03 | 27.87 | 33.21 | 33.21 | ok |
| 256.0 MiB | metal | wrapped-gpu | 29.22 | 27.89 | 30.79 | 30.79 | ok |
jsonOutput=benchmarks/results/20260421T-full-suite-isolated-overhead/metal-wrapped-r1.json
