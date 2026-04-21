BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=staged
metal-staged includes: pre-created shared staging MTLBuffer; timed Swift-byte copy into staging buffer plus hash
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.15 | 1.13 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.75 | 1.71 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 8.36 | 7.71 | 9.14 | 9.14 | ok |
| 16.0 MiB | official-c | one-shot | 2.17 | 2.15 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 8.51 | 7.76 | 9.36 | 9.36 | ok |
| 16.0 MiB | blake3 | default-auto | 17.71 | 13.91 | 20.12 | 20.12 | ok |
| 16.0 MiB | metal | staged-auto | 10.85 | 10.63 | 18.62 | 18.62 | ok |
| 16.0 MiB | metal | staged-gpu | 10.07 | 8.41 | 18.83 | 18.83 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.77 | 1.76 | 1.78 | 1.78 | ok |
| 64.0 MiB | cpu | parallel | 10.28 | 9.02 | 10.36 | 10.36 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.08 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 9.90 | 9.07 | 10.35 | 10.35 | ok |
| 64.0 MiB | blake3 | default-auto | 23.60 | 14.11 | 29.81 | 29.81 | ok |
| 64.0 MiB | metal | staged-auto | 16.62 | 10.79 | 18.24 | 18.24 | ok |
| 64.0 MiB | metal | staged-gpu | 14.48 | 9.17 | 18.81 | 18.81 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.77 | 1.77 | 1.78 | 1.78 | ok |
| 256.0 MiB | cpu | parallel | 10.37 | 10.18 | 10.89 | 10.89 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.19 | 2.19 | ok |
| 256.0 MiB | cpu | context-auto | 10.49 | 10.19 | 10.89 | 10.89 | ok |
| 256.0 MiB | blake3 | default-auto | 17.58 | 14.08 | 18.45 | 18.45 | ok |
| 256.0 MiB | metal | staged-auto | 14.71 | 13.22 | 15.22 | 15.22 | ok |
| 256.0 MiB | metal | staged-gpu | 14.83 | 13.57 | 15.81 | 15.81 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.78 | 1.78 | 1.79 | 1.79 | ok |
| 512.0 MiB | cpu | parallel | 10.97 | 10.90 | 11.00 | 11.00 | ok |
| 512.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.19 | 2.19 | ok |
| 512.0 MiB | cpu | context-auto | 11.05 | 6.47 | 11.26 | 11.26 | ok |
| 512.0 MiB | blake3 | default-auto | 29.01 | 16.57 | 37.20 | 37.20 | ok |
| 512.0 MiB | metal | staged-auto | 18.75 | 12.31 | 19.01 | 19.01 | ok |
| 512.0 MiB | metal | staged-gpu | 17.07 | 14.74 | 19.20 | 19.20 | ok |
| 1.0 GiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.78 | 1.73 | 1.78 | 1.78 | ok |
| 1.0 GiB | cpu | parallel | 11.46 | 10.94 | 11.57 | 11.57 | ok |
| 1.0 GiB | official-c | one-shot | 2.18 | 2.18 | 2.19 | 2.19 | ok |
| 1.0 GiB | cpu | context-auto | 11.30 | 10.91 | 11.69 | 11.69 | ok |
| 1.0 GiB | blake3 | default-auto | 38.59 | 36.34 | 45.45 | 45.45 | ok |
| 1.0 GiB | metal | staged-auto | 21.41 | 19.61 | 23.43 | 23.43 | ok |
| 1.0 GiB | metal | staged-gpu | 20.90 | 20.39 | 22.59 | 22.59 | ok |
jsonOutput=benchmarks/results/20260421T-digest-default-expanded/metal-staged.json
