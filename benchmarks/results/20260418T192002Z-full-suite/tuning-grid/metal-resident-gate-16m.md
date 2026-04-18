BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=16777216
metalModes=resident
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 64.0 MiB | cpu | parallel | 10.23 | 8.66 | 10.47 | 10.47 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 9.64 | 9.00 | 10.27 | 10.27 | ok |
| 64.0 MiB | blake3 | default-auto | 8.79 | 6.82 | 14.48 | 14.48 | ok |
| 64.0 MiB | metal | resident-auto | 11.21 | 7.39 | 19.15 | 19.15 | ok |
| 64.0 MiB | metal | resident-gpu | 18.54 | 10.15 | 26.36 | 26.36 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 10.26 | 9.60 | 10.78 | 10.78 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.34 | 9.82 | 10.57 | 10.57 | ok |
| 256.0 MiB | blake3 | default-auto | 28.96 | 26.39 | 35.77 | 35.77 | ok |
| 256.0 MiB | metal | resident-auto | 43.79 | 40.76 | 50.76 | 50.76 | ok |
| 256.0 MiB | metal | resident-gpu | 56.80 | 44.24 | 59.00 | 59.00 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.08 | 1.09 | 1.09 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 512.0 MiB | cpu | parallel | 10.69 | 10.13 | 11.02 | 11.02 | ok |
| 512.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.18 | 2.18 | ok |
| 512.0 MiB | cpu | context-auto | 10.43 | 10.17 | 11.40 | 11.40 | ok |
| 512.0 MiB | blake3 | default-auto | 38.90 | 36.87 | 41.08 | 41.08 | ok |
| 512.0 MiB | metal | resident-auto | 63.69 | 56.84 | 69.71 | 69.71 | ok |
| 512.0 MiB | metal | resident-gpu | 62.33 | 61.87 | 65.39 | 65.39 | ok |
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/tuning-grid/metal-resident-gate-16m.json
