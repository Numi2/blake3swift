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
| 16.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.74 | 1.73 | 1.77 | 1.77 | ok |
| 16.0 MiB | cpu | parallel | 8.83 | 7.73 | 9.23 | 9.23 | ok |
| 16.0 MiB | official-c | one-shot | 2.18 | 2.16 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 7.87 | 6.93 | 9.20 | 9.20 | ok |
| 16.0 MiB | blake3 | default-auto | 11.14 | 10.06 | 15.90 | 15.90 | ok |
| 16.0 MiB | metal | wrapped-auto | 13.01 | 10.04 | 14.30 | 14.30 | ok |
| 16.0 MiB | metal | wrapped-gpu | 11.75 | 7.52 | 12.09 | 12.09 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.77 | 1.77 | ok |
| 64.0 MiB | cpu | parallel | 10.12 | 9.08 | 10.26 | 10.26 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 10.06 | 8.27 | 10.35 | 10.35 | ok |
| 64.0 MiB | blake3 | default-auto | 27.87 | 10.39 | 32.03 | 32.03 | ok |
| 64.0 MiB | metal | wrapped-auto | 26.01 | 14.60 | 31.50 | 31.50 | ok |
| 64.0 MiB | metal | wrapped-gpu | 30.45 | 17.31 | 31.28 | 31.28 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.14 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.77 | 1.77 | ok |
| 256.0 MiB | cpu | parallel | 10.49 | 9.56 | 10.60 | 10.60 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.59 | 10.40 | 11.32 | 11.32 | ok |
| 256.0 MiB | blake3 | default-auto | 34.32 | 31.54 | 37.78 | 37.78 | ok |
| 256.0 MiB | metal | wrapped-auto | 33.67 | 32.56 | 34.28 | 34.28 | ok |
| 256.0 MiB | metal | wrapped-gpu | 34.82 | 32.86 | 36.57 | 36.57 | ok |
| 512.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.77 | 1.77 | 1.77 | 1.77 | ok |
| 512.0 MiB | cpu | parallel | 11.09 | 10.79 | 11.23 | 11.23 | ok |
| 512.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 512.0 MiB | cpu | context-auto | 10.89 | 10.40 | 11.18 | 11.18 | ok |
| 512.0 MiB | blake3 | default-auto | 34.79 | 33.93 | 36.33 | 36.33 | ok |
| 512.0 MiB | metal | wrapped-auto | 34.85 | 33.44 | 36.85 | 36.85 | ok |
| 512.0 MiB | metal | wrapped-gpu | 34.63 | 34.02 | 35.53 | 35.53 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.13 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.77 | 1.77 | 1.77 | 1.77 | ok |
| 1.0 GiB | cpu | parallel | 11.43 | 11.34 | 11.46 | 11.46 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.14 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 11.62 | 11.06 | 11.73 | 11.73 | ok |
| 1.0 GiB | blake3 | default-auto | 46.05 | 36.77 | 48.81 | 48.81 | ok |
| 1.0 GiB | metal | wrapped-auto | 42.12 | 36.24 | 48.55 | 48.55 | ok |
| 1.0 GiB | metal | wrapped-gpu | 42.00 | 35.49 | 50.16 | 50.16 | ok |
jsonOutput=benchmarks/results/20260421T-digest-default-expanded/metal-wrapped.json
