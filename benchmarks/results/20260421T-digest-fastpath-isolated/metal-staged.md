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
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.15 | 1.05 | 1.17 | 1.17 | ok |
| 16.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.77 | 1.77 | ok |
| 16.0 MiB | cpu | parallel | 8.65 | 7.75 | 9.28 | 9.28 | ok |
| 16.0 MiB | official-c | one-shot | 2.19 | 2.17 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 9.05 | 7.79 | 9.31 | 9.31 | ok |
| 16.0 MiB | blake3 | default-auto | 13.23 | 13.18 | 18.59 | 18.59 | ok |
| 16.0 MiB | metal | staged-auto | 11.24 | 10.21 | 15.33 | 15.33 | ok |
| 16.0 MiB | metal | staged-gpu | 11.14 | 5.94 | 15.43 | 15.43 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.11 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.93 | 8.30 | 10.26 | 10.26 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 10.06 | 8.97 | 10.26 | 10.26 | ok |
| 64.0 MiB | blake3 | default-auto | 25.15 | 6.85 | 29.79 | 29.79 | ok |
| 64.0 MiB | metal | staged-auto | 17.47 | 10.93 | 18.28 | 18.28 | ok |
| 64.0 MiB | metal | staged-gpu | 14.92 | 12.20 | 18.52 | 18.52 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.14 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.71 | 1.56 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 10.49 | 10.03 | 10.75 | 10.75 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.15 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.47 | 9.84 | 10.96 | 10.96 | ok |
| 256.0 MiB | blake3 | default-auto | 31.07 | 27.74 | 34.91 | 34.91 | ok |
| 256.0 MiB | metal | staged-auto | 18.76 | 17.66 | 20.57 | 20.57 | ok |
| 256.0 MiB | metal | staged-gpu | 18.10 | 16.81 | 19.14 | 19.14 | ok |
jsonOutput=benchmarks/results/20260421T-digest-fastpath-isolated/metal-staged.json
