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
| 16.0 MiB | cpu | scalar | 1.13 | 0.99 | 1.15 | 1.15 | ok |
| 16.0 MiB | cpu | single-simd | 1.73 | 1.71 | 1.75 | 1.75 | ok |
| 16.0 MiB | cpu | parallel | 9.10 | 7.46 | 9.25 | 9.25 | ok |
| 16.0 MiB | official-c | one-shot | 2.17 | 2.12 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 8.93 | 7.40 | 9.26 | 9.26 | ok |
| 16.0 MiB | blake3 | default-auto | 10.45 | 8.19 | 12.99 | 12.99 | ok |
| 16.0 MiB | metal | private-gpu | 11.30 | 9.46 | 12.57 | 12.57 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.13 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 64.0 MiB | cpu | parallel | 9.81 | 8.99 | 10.25 | 10.25 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.76 | 9.53 | 10.36 | 10.36 | ok |
| 64.0 MiB | blake3 | default-auto | 22.51 | 6.74 | 30.03 | 30.03 | ok |
| 64.0 MiB | metal | private-gpu | 38.15 | 17.17 | 41.15 | 41.15 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.17 | 9.83 | 10.81 | 10.81 | ok |
| 256.0 MiB | official-c | one-shot | 2.16 | 2.14 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.51 | 10.23 | 11.23 | 11.23 | ok |
| 256.0 MiB | blake3 | default-auto | 41.05 | 30.31 | 47.01 | 47.01 | ok |
| 256.0 MiB | metal | private-gpu | 57.92 | 49.91 | 65.86 | 65.86 | ok |
jsonOutput=benchmarks/results/20260421T-digest-fastpath-isolated/metal-private.json
