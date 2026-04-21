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
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.15 | 1.12 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.75 | 1.73 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 8.78 | 8.20 | 9.30 | 9.30 | ok |
| 16.0 MiB | official-c | one-shot | 2.18 | 2.13 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 7.72 | 7.70 | 7.76 | 7.76 | ok |
| 16.0 MiB | blake3 | default-auto | 14.57 | 8.48 | 18.67 | 18.67 | ok |
| 16.0 MiB | metal | wrapped-auto | 7.39 | 1.99 | 17.93 | 17.93 | ok |
| 16.0 MiB | metal | wrapped-gpu | 14.91 | 5.01 | 18.65 | 18.65 | ok |
| 64.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 10.08 | 9.73 | 10.36 | 10.36 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.87 | 8.91 | 10.27 | 10.27 | ok |
| 64.0 MiB | blake3 | default-auto | 25.00 | 14.24 | 37.13 | 37.13 | ok |
| 64.0 MiB | metal | wrapped-auto | 25.58 | 24.14 | 29.84 | 29.84 | ok |
| 64.0 MiB | metal | wrapped-gpu | 31.70 | 22.81 | 38.60 | 38.60 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.35 | 10.15 | 10.94 | 10.94 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.64 | 10.39 | 10.99 | 10.99 | ok |
| 256.0 MiB | blake3 | default-auto | 40.72 | 38.17 | 44.52 | 44.52 | ok |
| 256.0 MiB | metal | wrapped-auto | 41.86 | 34.04 | 45.78 | 45.78 | ok |
| 256.0 MiB | metal | wrapped-gpu | 40.25 | 36.67 | 46.29 | 46.29 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 11.12 | 10.64 | 11.35 | 11.35 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 512.0 MiB | cpu | context-auto | 11.24 | 10.65 | 11.49 | 11.49 | ok |
| 512.0 MiB | blake3 | default-auto | 42.87 | 41.42 | 47.93 | 47.93 | ok |
| 512.0 MiB | metal | wrapped-auto | 41.64 | 38.86 | 46.19 | 46.19 | ok |
| 512.0 MiB | metal | wrapped-gpu | 43.32 | 39.89 | 45.39 | 45.39 | ok |
| 1.0 GiB | cpu | scalar | 1.16 | 1.09 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 11.39 | 11.19 | 11.49 | 11.49 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.09 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 11.26 | 11.02 | 11.36 | 11.36 | ok |
| 1.0 GiB | blake3 | default-auto | 44.80 | 43.14 | 46.39 | 46.39 | ok |
| 1.0 GiB | metal | wrapped-auto | 43.79 | 42.05 | 44.78 | 44.78 | ok |
| 1.0 GiB | metal | wrapped-gpu | 42.63 | 40.35 | 43.49 | 43.49 | ok |
jsonOutput=benchmarks/results/20260421T-digest-inplace128-expanded/metal-wrapped.json
