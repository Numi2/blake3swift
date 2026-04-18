BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=67108864
metalModes=resident,private,e2e
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-private includes: pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.03 | 0.96 | 1.06 | 1.06 | ok |
| 16.0 MiB | cpu | single-simd | 1.67 | 1.56 | 1.72 | 1.72 | ok |
| 16.0 MiB | cpu | parallel | 5.04 | 4.81 | 6.44 | 6.44 | ok |
| 16.0 MiB | official-c | one-shot | 2.10 | 1.62 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | context-auto | 6.45 | 5.67 | 7.62 | 7.62 | ok |
| 16.0 MiB | blake3 | default-auto | 9.86 | 4.24 | 11.52 | 11.52 | ok |
| 16.0 MiB | metal | resident-auto | 24.93 | 14.72 | 27.40 | 27.40 | ok |
| 16.0 MiB | metal | resident-gpu | 21.24 | 7.02 | 27.26 | 27.26 | ok |
| 16.0 MiB | metal | private-gpu | 25.21 | 8.04 | 26.12 | 26.12 | ok |
| 16.0 MiB | metal | e2e-auto | 8.13 | 4.96 | 8.81 | 8.81 | ok |
| 16.0 MiB | metal | e2e-gpu | 7.92 | 5.29 | 8.72 | 8.72 | ok |
| 64.0 MiB | cpu | scalar | 1.06 | 1.05 | 1.07 | 1.07 | ok |
| 64.0 MiB | cpu | single-simd | 1.64 | 1.45 | 1.69 | 1.69 | ok |
| 64.0 MiB | cpu | parallel | 5.53 | 3.16 | 6.66 | 6.66 | ok |
| 64.0 MiB | official-c | one-shot | 2.01 | 1.96 | 2.10 | 2.10 | ok |
| 64.0 MiB | cpu | context-auto | 7.32 | 5.06 | 8.01 | 8.01 | ok |
| 64.0 MiB | blake3 | default-auto | 24.56 | 12.09 | 30.84 | 30.84 | ok |
| 64.0 MiB | metal | resident-auto | 45.12 | 29.53 | 46.77 | 46.77 | ok |
| 64.0 MiB | metal | resident-gpu | 42.51 | 29.48 | 45.19 | 45.19 | ok |
| 64.0 MiB | metal | private-gpu | 42.79 | 17.44 | 46.59 | 46.59 | ok |
| 64.0 MiB | metal | e2e-auto | 8.67 | 6.66 | 9.97 | 9.97 | ok |
| 64.0 MiB | metal | e2e-gpu | 8.41 | 5.87 | 9.36 | 9.36 | ok |
| 256.0 MiB | cpu | scalar | 1.07 | 0.99 | 1.08 | 1.08 | ok |
| 256.0 MiB | cpu | single-simd | 1.71 | 1.54 | 1.73 | 1.73 | ok |
| 256.0 MiB | cpu | parallel | 8.26 | 7.38 | 8.88 | 8.88 | ok |
| 256.0 MiB | official-c | one-shot | 1.40 | 1.28 | 2.03 | 2.03 | ok |
| 256.0 MiB | cpu | context-auto | 4.74 | 2.17 | 7.95 | 7.95 | ok |
| 256.0 MiB | blake3 | default-auto | 14.11 | 10.95 | 19.92 | 19.92 | ok |
| 256.0 MiB | metal | resident-auto | 37.03 | 25.85 | 43.18 | 43.18 | ok |
| 256.0 MiB | metal | resident-gpu | 53.16 | 45.27 | 58.92 | 58.92 | ok |
| 256.0 MiB | metal | private-gpu | 57.81 | 44.42 | 66.39 | 66.39 | ok |
| 256.0 MiB | metal | e2e-auto | 7.07 | 5.68 | 7.89 | 7.89 | ok |
| 256.0 MiB | metal | e2e-gpu | 8.61 | 6.16 | 9.50 | 9.50 | ok |
| 512.0 MiB | cpu | scalar | 0.62 | 0.51 | 0.84 | 0.84 | ok |
| 512.0 MiB | cpu | single-simd | 1.66 | 0.90 | 1.72 | 1.72 | ok |
| 512.0 MiB | cpu | parallel | 7.55 | 4.26 | 8.93 | 8.93 | ok |
| 512.0 MiB | official-c | one-shot | 2.03 | 1.90 | 2.06 | 2.06 | ok |
| 512.0 MiB | cpu | context-auto | 8.97 | 8.53 | 9.68 | 9.68 | ok |
| 512.0 MiB | blake3 | default-auto | 30.47 | 23.94 | 31.76 | 31.76 | ok |
| 512.0 MiB | metal | resident-auto | 53.06 | 44.54 | 65.58 | 65.58 | ok |
| 512.0 MiB | metal | resident-gpu | 65.12 | 59.44 | 67.98 | 67.98 | ok |
| 512.0 MiB | metal | private-gpu | 64.63 | 59.15 | 65.73 | 65.73 | ok |
| 512.0 MiB | metal | e2e-auto | 10.16 | 10.02 | 10.49 | 10.49 | ok |
| 512.0 MiB | metal | e2e-gpu | 10.28 | 8.93 | 10.63 | 10.63 | ok |
| 1.0 GiB | cpu | scalar | 1.00 | 0.98 | 1.02 | 1.02 | ok |
| 1.0 GiB | cpu | single-simd | 1.61 | 1.12 | 1.67 | 1.67 | ok |
| 1.0 GiB | cpu | parallel | 9.16 | 6.84 | 9.67 | 9.67 | ok |
| 1.0 GiB | official-c | one-shot | 1.99 | 1.96 | 2.03 | 2.03 | ok |
| 1.0 GiB | cpu | context-auto | 9.35 | 6.84 | 9.63 | 9.63 | ok |
| 1.0 GiB | blake3 | default-auto | 33.78 | 33.03 | 36.19 | 36.19 | ok |
| 1.0 GiB | metal | resident-auto | 66.20 | 58.14 | 76.07 | 76.07 | ok |
| 1.0 GiB | metal | resident-gpu | 67.43 | 59.84 | 72.91 | 72.91 | ok |
| 1.0 GiB | metal | private-gpu | 65.52 | 60.21 | 72.70 | 72.70 | ok |
| 1.0 GiB | metal | e2e-auto | 9.94 | 9.67 | 10.08 | 10.08 | ok |
| 1.0 GiB | metal | e2e-gpu | 9.57 | 8.50 | 10.26 | 10.26 | ok |
jsonOutput=benchmarks/results/20260418T213322Z-head-publication/cpu-metal-publication.json
