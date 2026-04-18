BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=16777216
metalModes=resident,e2e
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.07 | 1.06 | 1.09 | 1.09 | ok |
| 16.0 MiB | cpu | single-simd | 1.70 | 1.67 | 1.75 | 1.75 | ok |
| 16.0 MiB | cpu | parallel | 7.67 | 6.46 | 7.74 | 7.74 | ok |
| 16.0 MiB | cpu | context-auto | 7.63 | 7.20 | 7.71 | 7.71 | ok |
| 16.0 MiB | blake3 | default-auto | 9.88 | 5.35 | 10.43 | 10.43 | ok |
| 16.0 MiB | metal | resident-auto | 11.50 | 6.49 | 12.13 | 12.13 | ok |
| 16.0 MiB | metal | resident-gpu | 15.12 | 4.60 | 18.69 | 18.69 | ok |
| 16.0 MiB | metal | e2e-auto | 6.79 | 5.89 | 8.00 | 8.00 | ok |
| 16.0 MiB | metal | e2e-gpu | 7.37 | 4.58 | 7.96 | 7.96 | ok |
| 64.0 MiB | cpu | scalar | 1.07 | 1.05 | 1.08 | 1.08 | ok |
| 64.0 MiB | cpu | single-simd | 1.72 | 1.66 | 1.72 | 1.72 | ok |
| 64.0 MiB | cpu | parallel | 8.29 | 7.73 | 9.51 | 9.51 | ok |
| 64.0 MiB | cpu | context-auto | 8.32 | 7.97 | 9.86 | 9.86 | ok |
| 64.0 MiB | blake3 | default-auto | 17.16 | 10.16 | 23.55 | 23.55 | ok |
| 64.0 MiB | metal | resident-auto | 38.40 | 25.35 | 46.02 | 46.02 | ok |
| 64.0 MiB | metal | resident-gpu | 38.83 | 29.26 | 45.93 | 45.93 | ok |
| 64.0 MiB | metal | e2e-auto | 9.73 | 7.33 | 10.45 | 10.45 | ok |
| 64.0 MiB | metal | e2e-gpu | 9.00 | 8.37 | 10.12 | 10.12 | ok |
| 256.0 MiB | cpu | scalar | 0.99 | 0.58 | 1.07 | 1.07 | ok |
| 256.0 MiB | cpu | single-simd | 1.71 | 1.71 | 1.72 | 1.72 | ok |
| 256.0 MiB | cpu | parallel | 8.84 | 7.89 | 9.94 | 9.94 | ok |
| 256.0 MiB | cpu | context-auto | 9.22 | 8.16 | 10.07 | 10.07 | ok |
| 256.0 MiB | blake3 | default-auto | 34.21 | 18.52 | 38.65 | 38.65 | ok |
| 256.0 MiB | metal | resident-auto | 62.58 | 50.73 | 69.91 | 69.91 | ok |
| 256.0 MiB | metal | resident-gpu | 66.42 | 43.14 | 74.20 | 74.20 | ok |
| 256.0 MiB | metal | e2e-auto | 6.70 | 4.00 | 9.29 | 9.29 | ok |
| 256.0 MiB | metal | e2e-gpu | 6.32 | 5.35 | 8.00 | 8.00 | ok |
jsonOutput=benchmarks/results/20260418T115925Z-after-optimize/cpu-metal-after.json
