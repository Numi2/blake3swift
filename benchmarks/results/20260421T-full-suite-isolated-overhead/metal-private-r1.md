BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=private
metal-private includes: pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.14 | 1.12 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.79 | 1.77 | 1.84 | 1.84 | ok |
| 16.0 MiB | cpu | parallel | 10.05 | 8.76 | 10.47 | 10.47 | ok |
| 16.0 MiB | official-c | one-shot | 2.19 | 2.15 | 2.23 | 2.23 | ok |
| 16.0 MiB | cpu | context-auto | 9.43 | 8.55 | 10.58 | 10.58 | ok |
| 16.0 MiB | blake3 | default-auto | 8.04 | 4.66 | 15.54 | 15.54 | ok |
| 16.0 MiB | metal | private-gpu | 9.29 | 3.45 | 22.04 | 22.04 | ok |
| 64.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.78 | 1.75 | 1.79 | 1.79 | ok |
| 64.0 MiB | cpu | parallel | 11.13 | 10.94 | 11.61 | 11.61 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.16 | 2.19 | 2.19 | ok |
| 64.0 MiB | cpu | context-auto | 11.14 | 10.97 | 11.52 | 11.52 | ok |
| 64.0 MiB | blake3 | default-auto | 24.97 | 8.57 | 36.70 | 36.70 | ok |
| 64.0 MiB | metal | private-gpu | 35.90 | 12.87 | 54.01 | 54.01 | ok |
| 256.0 MiB | cpu | scalar | 1.14 | 1.14 | 1.15 | 1.15 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 11.54 | 10.85 | 11.80 | 11.80 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 11.63 | 11.52 | 11.82 | 11.82 | ok |
| 256.0 MiB | blake3 | default-auto | 40.45 | 31.90 | 45.09 | 45.09 | ok |
| 256.0 MiB | metal | private-gpu | 57.21 | 52.07 | 58.54 | 58.54 | ok |
jsonOutput=benchmarks/results/20260421T-full-suite-isolated-overhead/metal-private-r1.json
