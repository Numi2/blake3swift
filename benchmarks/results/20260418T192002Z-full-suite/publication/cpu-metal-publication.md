BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=resident,e2e
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
memoryStats=rss,allocator

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 16.0 MiB | cpu | single-simd | 1.78 | 1.75 | 1.82 | 1.82 | ok |
| 16.0 MiB | cpu | parallel | 9.00 | 7.50 | 9.12 | 9.12 | ok |
| 16.0 MiB | official-c | one-shot | 2.17 | 2.13 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 8.86 | 7.40 | 9.18 | 9.18 | ok |
| 16.0 MiB | blake3 | default-auto | 8.91 | 7.47 | 9.21 | 9.21 | ok |
| 16.0 MiB | metal | resident-auto | 8.89 | 7.83 | 9.13 | 9.13 | ok |
| 16.0 MiB | metal | resident-gpu | 9.31 | 2.40 | 10.86 | 10.86 | ok |
| 16.0 MiB | metal | e2e-auto | 5.43 | 4.83 | 5.61 | 5.61 | ok |
| 16.0 MiB | metal | e2e-gpu | 5.19 | 1.94 | 5.86 | 5.86 | ok |
| 64.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.78 | 1.76 | 1.81 | 1.81 | ok |
| 64.0 MiB | cpu | parallel | 10.08 | 8.43 | 10.26 | 10.26 | ok |
| 64.0 MiB | official-c | one-shot | 2.19 | 2.18 | 2.21 | 2.21 | ok |
| 64.0 MiB | cpu | context-auto | 9.71 | 8.33 | 10.03 | 10.03 | ok |
| 64.0 MiB | blake3 | default-auto | 12.63 | 6.66 | 27.71 | 27.71 | ok |
| 64.0 MiB | metal | resident-auto | 40.91 | 18.88 | 43.79 | 43.79 | ok |
| 64.0 MiB | metal | resident-gpu | 42.95 | 19.12 | 44.04 | 44.04 | ok |
| 64.0 MiB | metal | e2e-auto | 6.89 | 4.90 | 7.24 | 7.24 | ok |
| 64.0 MiB | metal | e2e-gpu | 7.51 | 6.11 | 8.51 | 8.51 | ok |
| 256.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.79 | 1.77 | 1.79 | 1.79 | ok |
| 256.0 MiB | cpu | parallel | 10.28 | 9.44 | 10.58 | 10.58 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 1.89 | 2.20 | 2.20 | ok |
| 256.0 MiB | cpu | context-auto | 10.18 | 9.73 | 10.61 | 10.61 | ok |
| 256.0 MiB | blake3 | default-auto | 29.20 | 17.80 | 32.27 | 32.27 | ok |
| 256.0 MiB | metal | resident-auto | 48.09 | 35.10 | 51.27 | 51.27 | ok |
| 256.0 MiB | metal | resident-gpu | 58.10 | 45.97 | 67.34 | 67.34 | ok |
| 256.0 MiB | metal | e2e-auto | 8.63 | 4.60 | 9.63 | 9.63 | ok |
| 256.0 MiB | metal | e2e-gpu | 8.24 | 6.81 | 9.42 | 9.42 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.03 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.78 | 1.78 | 1.78 | 1.78 | ok |
| 512.0 MiB | cpu | parallel | 10.83 | 10.15 | 11.06 | 11.06 | ok |
| 512.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.19 | 2.19 | ok |
| 512.0 MiB | cpu | context-auto | 10.83 | 10.28 | 11.35 | 11.35 | ok |
| 512.0 MiB | blake3 | default-auto | 28.53 | 25.33 | 29.86 | 29.86 | ok |
| 512.0 MiB | metal | resident-auto | 54.83 | 35.10 | 62.70 | 62.70 | ok |
| 512.0 MiB | metal | resident-gpu | 62.98 | 55.65 | 73.54 | 73.54 | ok |
| 512.0 MiB | metal | e2e-auto | 8.88 | 4.20 | 9.64 | 9.64 | ok |
| 512.0 MiB | metal | e2e-gpu | 7.50 | 6.75 | 9.15 | 9.15 | ok |
| 1.0 GiB | cpu | scalar | 1.10 | 1.08 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.78 | 1.77 | 1.78 | 1.78 | ok |
| 1.0 GiB | cpu | parallel | 11.28 | 10.89 | 11.72 | 11.72 | ok |
| 1.0 GiB | official-c | one-shot | 2.18 | 2.18 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 11.13 | 10.57 | 11.52 | 11.52 | ok |
| 1.0 GiB | blake3 | default-auto | 30.28 | 28.26 | 31.53 | 31.53 | ok |
| 1.0 GiB | metal | resident-auto | 63.51 | 53.03 | 64.40 | 64.40 | ok |
| 1.0 GiB | metal | resident-gpu | 66.69 | 62.29 | 70.08 | 70.08 | ok |
| 1.0 GiB | metal | e2e-auto | 8.34 | 3.12 | 9.66 | 9.66 | ok |
| 1.0 GiB | metal | e2e-gpu | 9.92 | 9.04 | 11.01 | 11.01 | ok |

| Size | Memory Phase | RSS | Allocator In Use | Allocator Blocks |
| --- | --- | ---: | ---: | ---: |
| 16.0 MiB | before-input | 15.1 MiB | 0.8 MiB | 5415 |
| 16.0 MiB | after-input | 31.2 MiB | 16.8 MiB | 5417 |
| 16.0 MiB | after-size | 210.2 MiB | 18.0 MiB | 6064 |
| 64.0 MiB | before-input | 210.2 MiB | 1.2 MiB | 6058 |
| 64.0 MiB | after-input | 274.1 MiB | 65.2 MiB | 5890 |
| 64.0 MiB | after-size | 388.6 MiB | 68.3 MiB | 6197 |
| 256.0 MiB | before-input | 388.6 MiB | 1.3 MiB | 6185 |
| 256.0 MiB | after-input | 516.5 MiB | 257.2 MiB | 6014 |
| 256.0 MiB | after-size | 1032.6 MiB | 277.3 MiB | 6266 |
| 512.0 MiB | before-input | 1032.6 MiB | 1.3 MiB | 6242 |
| 512.0 MiB | after-input | 1384.7 MiB | 513.2 MiB | 6083 |
| 512.0 MiB | after-size | 1399.2 MiB | 537.3 MiB | 6333 |
| 1.0 GiB | before-input | 1399.2 MiB | 1.3 MiB | 6312 |
| 1.0 GiB | after-input | 2423.2 MiB | 1025.2 MiB | 6150 |
| 1.0 GiB | after-size | 2156.6 MiB | 1105.3 MiB | 6404 |
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/publication/cpu-metal-publication.json
