BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=resident
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.16 | 1.14 | 1.18 | 1.18 | ok |
| 16.0 MiB | cpu | single-simd | 1.84 | 1.81 | 1.91 | 1.91 | ok |
| 16.0 MiB | cpu | parallel | 7.80 | 7.66 | 7.92 | 7.92 | ok |
| 16.0 MiB | official-c | one-shot | 2.31 | 2.26 | 2.32 | 2.32 | ok |
| 16.0 MiB | cpu | context-auto | 8.96 | 7.78 | 9.27 | 9.27 | ok |
| 16.0 MiB | blake3 | default-auto | 9.03 | 4.82 | 9.51 | 9.51 | ok |
| 16.0 MiB | metal | resident-auto | 11.26 | 8.13 | 11.84 | 11.84 | ok |
| 16.0 MiB | metal | resident-gpu | 9.42 | 4.25 | 10.22 | 10.22 | ok |
| 64.0 MiB | cpu | scalar | 1.17 | 1.16 | 1.17 | 1.17 | ok |
| 64.0 MiB | cpu | single-simd | 1.87 | 1.85 | 1.87 | 1.87 | ok |
| 64.0 MiB | cpu | parallel | 10.33 | 9.74 | 10.39 | 10.39 | ok |
| 64.0 MiB | official-c | one-shot | 2.26 | 2.22 | 2.29 | 2.29 | ok |
| 64.0 MiB | cpu | context-auto | 9.96 | 8.92 | 10.39 | 10.39 | ok |
| 64.0 MiB | blake3 | default-auto | 26.15 | 10.88 | 31.02 | 31.02 | ok |
| 64.0 MiB | metal | resident-auto | 39.20 | 13.03 | 42.00 | 42.00 | ok |
| 64.0 MiB | metal | resident-gpu | 34.80 | 13.45 | 40.70 | 40.70 | ok |
| 256.0 MiB | cpu | scalar | 1.17 | 1.17 | 1.17 | 1.17 | ok |
| 256.0 MiB | cpu | single-simd | 1.84 | 1.61 | 1.84 | 1.84 | ok |
| 256.0 MiB | cpu | parallel | 10.64 | 10.38 | 11.06 | 11.06 | ok |
| 256.0 MiB | official-c | one-shot | 2.23 | 2.22 | 2.23 | 2.23 | ok |
| 256.0 MiB | cpu | context-auto | 10.50 | 10.21 | 10.75 | 10.75 | ok |
| 256.0 MiB | blake3 | default-auto | 38.45 | 34.88 | 40.39 | 40.39 | ok |
| 256.0 MiB | metal | resident-auto | 54.83 | 48.38 | 61.00 | 61.00 | ok |
| 256.0 MiB | metal | resident-gpu | 50.58 | 42.24 | 52.95 | 52.95 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.81 | 1.81 | 1.81 | 1.81 | ok |
| 512.0 MiB | cpu | parallel | 10.80 | 10.22 | 11.08 | 11.08 | ok |
| 512.0 MiB | official-c | one-shot | 2.22 | 2.20 | 2.22 | 2.22 | ok |
| 512.0 MiB | cpu | context-auto | 11.14 | 10.41 | 11.49 | 11.49 | ok |
| 512.0 MiB | blake3 | default-auto | 37.48 | 35.39 | 40.98 | 40.98 | ok |
| 512.0 MiB | metal | resident-auto | 56.91 | 51.13 | 59.32 | 59.32 | ok |
| 512.0 MiB | metal | resident-gpu | 63.27 | 49.54 | 68.79 | 68.79 | ok |
| 1.0 GiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.80 | 1.74 | 1.80 | 1.80 | ok |
| 1.0 GiB | cpu | parallel | 11.41 | 11.14 | 11.63 | 11.63 | ok |
| 1.0 GiB | official-c | one-shot | 2.19 | 2.19 | 2.20 | 2.20 | ok |
| 1.0 GiB | cpu | context-auto | 11.28 | 11.14 | 11.58 | 11.58 | ok |
| 1.0 GiB | blake3 | default-auto | 44.42 | 34.03 | 47.04 | 47.04 | ok |
| 1.0 GiB | metal | resident-auto | 72.65 | 54.32 | 82.71 | 82.71 | ok |
| 1.0 GiB | metal | resident-gpu | 68.77 | 58.29 | 77.14 | 77.14 | ok |
jsonOutput=benchmarks/results/20260421T-digest-default-expanded/metal-resident.json
