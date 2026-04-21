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
| 16.0 MiB | cpu | scalar | 1.14 | 1.13 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.74 | 1.74 | 1.77 | 1.77 | ok |
| 16.0 MiB | cpu | parallel | 9.02 | 6.79 | 9.34 | 9.34 | ok |
| 16.0 MiB | official-c | one-shot | 2.17 | 2.15 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 9.12 | 7.63 | 9.22 | 9.22 | ok |
| 16.0 MiB | blake3 | default-auto | 12.54 | 7.32 | 20.02 | 20.02 | ok |
| 16.0 MiB | metal | staged-auto | 10.27 | 10.10 | 18.79 | 18.79 | ok |
| 16.0 MiB | metal | staged-gpu | 18.06 | 17.48 | 18.48 | 18.48 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.66 | 8.21 | 9.93 | 9.93 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.14 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.60 | 9.03 | 10.16 | 10.16 | ok |
| 64.0 MiB | blake3 | default-auto | 13.79 | 7.15 | 22.83 | 22.83 | ok |
| 64.0 MiB | metal | staged-auto | 12.77 | 10.73 | 13.54 | 13.54 | ok |
| 64.0 MiB | metal | staged-gpu | 12.27 | 8.31 | 14.57 | 14.57 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.48 | 10.01 | 10.77 | 10.77 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.01 | 9.91 | 10.24 | 10.24 | ok |
| 256.0 MiB | blake3 | default-auto | 28.11 | 25.19 | 30.43 | 30.43 | ok |
| 256.0 MiB | metal | staged-auto | 19.92 | 17.31 | 20.51 | 20.51 | ok |
| 256.0 MiB | metal | staged-gpu | 18.32 | 17.42 | 19.04 | 19.04 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 11.18 | 10.87 | 11.34 | 11.34 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 512.0 MiB | cpu | context-auto | 10.41 | 9.91 | 10.93 | 10.93 | ok |
| 512.0 MiB | blake3 | default-auto | 31.83 | 29.00 | 32.85 | 32.85 | ok |
| 512.0 MiB | metal | staged-auto | 18.85 | 18.29 | 19.48 | 19.48 | ok |
| 512.0 MiB | metal | staged-gpu | 18.57 | 17.74 | 20.47 | 20.47 | ok |
| 1.0 GiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.76 | 1.76 | 1.77 | 1.77 | ok |
| 1.0 GiB | cpu | parallel | 11.43 | 11.38 | 11.66 | 11.66 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 11.32 | 10.99 | 11.62 | 11.62 | ok |
| 1.0 GiB | blake3 | default-auto | 43.70 | 41.00 | 47.77 | 47.77 | ok |
| 1.0 GiB | metal | staged-auto | 22.95 | 22.04 | 23.82 | 23.82 | ok |
| 1.0 GiB | metal | staged-gpu | 23.34 | 22.61 | 23.65 | 23.65 | ok |
jsonOutput=benchmarks/results/20260421T-digest-inplace128-expanded/metal-staged.json
