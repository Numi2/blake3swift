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
| 16.0 MiB | cpu | scalar | 1.16 | 1.14 | 1.17 | 1.17 | ok |
| 16.0 MiB | cpu | single-simd | 1.84 | 1.80 | 1.86 | 1.86 | ok |
| 16.0 MiB | cpu | parallel | 9.78 | 9.06 | 10.37 | 10.37 | ok |
| 16.0 MiB | official-c | one-shot | 2.21 | 2.14 | 2.26 | 2.26 | ok |
| 16.0 MiB | cpu | context-auto | 10.34 | 8.73 | 10.53 | 10.53 | ok |
| 16.0 MiB | blake3 | default-auto | 9.99 | 3.63 | 15.96 | 15.96 | ok |
| 16.0 MiB | metal | staged-auto | 6.85 | 4.79 | 16.79 | 16.79 | ok |
| 16.0 MiB | metal | staged-gpu | 8.73 | 5.58 | 15.86 | 15.86 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.80 | 1.78 | 1.81 | 1.81 | ok |
| 64.0 MiB | cpu | parallel | 11.13 | 10.90 | 11.81 | 11.81 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.16 | 2.21 | 2.21 | ok |
| 64.0 MiB | cpu | context-auto | 11.16 | 10.87 | 11.38 | 11.38 | ok |
| 64.0 MiB | blake3 | default-auto | 24.17 | 17.48 | 30.96 | 30.96 | ok |
| 64.0 MiB | metal | staged-auto | 15.62 | 12.83 | 19.36 | 19.36 | ok |
| 64.0 MiB | metal | staged-gpu | 15.12 | 12.80 | 17.11 | 17.11 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.13 | 1.15 | 1.15 | ok |
| 256.0 MiB | cpu | single-simd | 1.77 | 1.76 | 1.78 | 1.78 | ok |
| 256.0 MiB | cpu | parallel | 11.70 | 11.58 | 11.92 | 11.92 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 11.72 | 11.63 | 11.87 | 11.87 | ok |
| 256.0 MiB | blake3 | default-auto | 30.55 | 27.16 | 34.10 | 34.10 | ok |
| 256.0 MiB | metal | staged-auto | 17.99 | 16.86 | 21.04 | 21.04 | ok |
| 256.0 MiB | metal | staged-gpu | 18.13 | 17.05 | 19.33 | 19.33 | ok |
jsonOutput=benchmarks/results/20260421T-full-suite-isolated-overhead/metal-staged-r1.json
