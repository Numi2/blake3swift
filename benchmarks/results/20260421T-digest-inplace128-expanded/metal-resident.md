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
| 16.0 MiB | cpu | scalar | 1.13 | 1.04 | 1.17 | 1.17 | ok |
| 16.0 MiB | cpu | single-simd | 1.82 | 1.81 | 1.85 | 1.85 | ok |
| 16.0 MiB | cpu | parallel | 8.90 | 7.90 | 9.01 | 9.01 | ok |
| 16.0 MiB | official-c | one-shot | 2.26 | 2.23 | 2.30 | 2.30 | ok |
| 16.0 MiB | cpu | context-auto | 7.74 | 7.26 | 8.06 | 8.06 | ok |
| 16.0 MiB | blake3 | default-auto | 8.27 | 2.76 | 17.76 | 17.76 | ok |
| 16.0 MiB | metal | resident-auto | 10.22 | 7.17 | 21.08 | 21.08 | ok |
| 16.0 MiB | metal | resident-gpu | 12.89 | 8.33 | 19.77 | 19.77 | ok |
| 64.0 MiB | cpu | scalar | 1.17 | 1.17 | 1.17 | 1.17 | ok |
| 64.0 MiB | cpu | single-simd | 1.81 | 1.79 | 1.85 | 1.85 | ok |
| 64.0 MiB | cpu | parallel | 9.08 | 8.50 | 9.88 | 9.88 | ok |
| 64.0 MiB | official-c | one-shot | 2.24 | 2.19 | 2.25 | 2.25 | ok |
| 64.0 MiB | cpu | context-auto | 9.02 | 8.90 | 10.20 | 10.20 | ok |
| 64.0 MiB | blake3 | default-auto | 26.57 | 6.30 | 37.51 | 37.51 | ok |
| 64.0 MiB | metal | resident-auto | 27.03 | 26.72 | 43.49 | 43.49 | ok |
| 64.0 MiB | metal | resident-gpu | 35.99 | 14.89 | 59.13 | 59.13 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.12 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.82 | 1.82 | 1.82 | 1.82 | ok |
| 256.0 MiB | cpu | parallel | 10.38 | 9.99 | 10.47 | 10.47 | ok |
| 256.0 MiB | official-c | one-shot | 2.10 | 1.82 | 2.16 | 2.16 | ok |
| 256.0 MiB | cpu | context-auto | 10.09 | 9.15 | 10.37 | 10.37 | ok |
| 256.0 MiB | blake3 | default-auto | 37.86 | 35.04 | 46.41 | 46.41 | ok |
| 256.0 MiB | metal | resident-auto | 60.87 | 49.36 | 73.72 | 73.72 | ok |
| 256.0 MiB | metal | resident-gpu | 71.87 | 47.67 | 76.65 | 76.65 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.78 | 1.77 | 1.78 | 1.78 | ok |
| 512.0 MiB | cpu | parallel | 10.81 | 10.66 | 10.93 | 10.93 | ok |
| 512.0 MiB | official-c | one-shot | 2.16 | 1.99 | 2.18 | 2.18 | ok |
| 512.0 MiB | cpu | context-auto | 11.15 | 10.16 | 11.18 | 11.18 | ok |
| 512.0 MiB | blake3 | default-auto | 39.33 | 36.59 | 41.18 | 41.18 | ok |
| 512.0 MiB | metal | resident-auto | 63.91 | 49.85 | 74.98 | 74.98 | ok |
| 512.0 MiB | metal | resident-gpu | 50.49 | 45.61 | 62.55 | 62.55 | ok |
| 1.0 GiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.78 | 1.77 | 1.78 | 1.78 | ok |
| 1.0 GiB | cpu | parallel | 11.47 | 11.08 | 11.69 | 11.69 | ok |
| 1.0 GiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 11.43 | 10.91 | 11.72 | 11.72 | ok |
| 1.0 GiB | blake3 | default-auto | 42.74 | 38.97 | 49.03 | 49.03 | ok |
| 1.0 GiB | metal | resident-auto | 66.49 | 55.35 | 79.78 | 79.78 | ok |
| 1.0 GiB | metal | resident-gpu | 73.38 | 67.93 | 81.89 | 81.89 | ok |
jsonOutput=benchmarks/results/20260421T-digest-inplace128-expanded/metal-resident.json
