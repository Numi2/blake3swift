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
| 16.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.11 | 1.11 | ok |
| 16.0 MiB | cpu | single-simd | 1.85 | 1.82 | 1.87 | 1.87 | ok |
| 16.0 MiB | cpu | parallel | 8.85 | 7.52 | 9.25 | 9.25 | ok |
| 16.0 MiB | official-c | one-shot | 2.27 | 2.20 | 2.35 | 2.35 | ok |
| 16.0 MiB | cpu | context-auto | 8.83 | 7.38 | 9.25 | 9.25 | ok |
| 16.0 MiB | blake3 | default-auto | 7.86 | 2.09 | 8.78 | 8.78 | ok |
| 16.0 MiB | metal | resident-auto | 20.96 | 6.84 | 24.41 | 24.41 | ok |
| 16.0 MiB | metal | resident-gpu | 17.88 | 9.02 | 24.60 | 24.60 | ok |
| 16.0 MiB | metal | private-gpu | 17.11 | 6.84 | 24.10 | 24.10 | ok |
| 16.0 MiB | metal | e2e-auto | 6.72 | 4.03 | 8.14 | 8.14 | ok |
| 16.0 MiB | metal | e2e-gpu | 6.77 | 4.84 | 7.91 | 7.91 | ok |
| 64.0 MiB | cpu | scalar | 1.11 | 1.10 | 1.12 | 1.12 | ok |
| 64.0 MiB | cpu | single-simd | 1.83 | 1.79 | 1.84 | 1.84 | ok |
| 64.0 MiB | cpu | parallel | 9.22 | 7.70 | 10.13 | 10.13 | ok |
| 64.0 MiB | official-c | one-shot | 2.22 | 2.20 | 2.25 | 2.25 | ok |
| 64.0 MiB | cpu | context-auto | 9.60 | 9.08 | 10.25 | 10.25 | ok |
| 64.0 MiB | blake3 | default-auto | 14.95 | 7.99 | 25.77 | 25.77 | ok |
| 64.0 MiB | metal | resident-auto | 37.31 | 20.82 | 43.69 | 43.69 | ok |
| 64.0 MiB | metal | resident-gpu | 38.25 | 21.63 | 44.10 | 44.10 | ok |
| 64.0 MiB | metal | private-gpu | 34.11 | 19.87 | 45.70 | 45.70 | ok |
| 64.0 MiB | metal | e2e-auto | 8.02 | 7.50 | 9.12 | 9.12 | ok |
| 64.0 MiB | metal | e2e-gpu | 8.62 | 7.74 | 9.16 | 9.16 | ok |
| 256.0 MiB | cpu | scalar | 1.10 | 1.10 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.82 | 1.81 | 1.83 | 1.83 | ok |
| 256.0 MiB | cpu | parallel | 10.25 | 9.80 | 10.48 | 10.48 | ok |
| 256.0 MiB | official-c | one-shot | 2.20 | 2.07 | 2.21 | 2.21 | ok |
| 256.0 MiB | cpu | context-auto | 10.30 | 7.09 | 10.89 | 10.89 | ok |
| 256.0 MiB | blake3 | default-auto | 32.77 | 18.53 | 37.33 | 37.33 | ok |
| 256.0 MiB | metal | resident-auto | 59.99 | 52.08 | 62.81 | 62.81 | ok |
| 256.0 MiB | metal | resident-gpu | 53.83 | 48.56 | 63.32 | 63.32 | ok |
| 256.0 MiB | metal | private-gpu | 59.70 | 51.40 | 64.18 | 64.18 | ok |
| 256.0 MiB | metal | e2e-auto | 10.12 | 9.30 | 10.88 | 10.88 | ok |
| 256.0 MiB | metal | e2e-gpu | 10.70 | 10.15 | 10.99 | 10.99 | ok |
| 512.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.79 | 1.77 | 1.80 | 1.80 | ok |
| 512.0 MiB | cpu | parallel | 10.70 | 10.28 | 11.19 | 11.19 | ok |
| 512.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.19 | 2.19 | ok |
| 512.0 MiB | cpu | context-auto | 10.69 | 10.28 | 11.09 | 11.09 | ok |
| 512.0 MiB | blake3 | default-auto | 31.06 | 28.58 | 34.28 | 34.28 | ok |
| 512.0 MiB | metal | resident-auto | 51.16 | 49.40 | 64.22 | 64.22 | ok |
| 512.0 MiB | metal | resident-gpu | 61.50 | 53.97 | 65.80 | 65.80 | ok |
| 512.0 MiB | metal | private-gpu | 59.49 | 52.11 | 69.09 | 69.09 | ok |
| 512.0 MiB | metal | e2e-auto | 10.78 | 9.42 | 11.17 | 11.17 | ok |
| 512.0 MiB | metal | e2e-gpu | 10.52 | 8.23 | 10.93 | 10.93 | ok |
| 1.0 GiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.76 | 1.73 | 1.77 | 1.77 | ok |
| 1.0 GiB | cpu | parallel | 11.22 | 10.82 | 11.55 | 11.55 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.09 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 10.96 | 9.75 | 11.19 | 11.19 | ok |
| 1.0 GiB | blake3 | default-auto | 34.56 | 28.21 | 37.38 | 37.38 | ok |
| 1.0 GiB | metal | resident-auto | 67.63 | 60.74 | 74.29 | 74.29 | ok |
| 1.0 GiB | metal | resident-gpu | 67.24 | 58.75 | 72.54 | 72.54 | ok |
| 1.0 GiB | metal | private-gpu | 65.35 | 62.25 | 74.78 | 74.78 | ok |
| 1.0 GiB | metal | e2e-auto | 9.91 | 8.96 | 10.65 | 10.65 | ok |
| 1.0 GiB | metal | e2e-gpu | 10.06 | 9.54 | 10.86 | 10.86 | ok |
jsonOutput=benchmarks/results/20260419T074508Z-head-publication/cpu-metal-publication.json
