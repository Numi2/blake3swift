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
| 16.0 MiB | cpu | scalar | 1.08 | 1.08 | 1.09 | 1.09 | ok |
| 16.0 MiB | cpu | single-simd | 1.72 | 1.70 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 8.71 | 7.63 | 9.01 | 9.01 | ok |
| 16.0 MiB | official-c | one-shot | 2.16 | 2.11 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 8.43 | 7.61 | 9.07 | 9.07 | ok |
| 16.0 MiB | blake3 | default-auto | 8.32 | 6.24 | 8.97 | 8.97 | ok |
| 16.0 MiB | metal | resident-auto | 13.87 | 3.48 | 20.12 | 20.12 | ok |
| 16.0 MiB | metal | resident-gpu | 20.68 | 5.97 | 25.74 | 25.74 | ok |
| 16.0 MiB | metal | private-gpu | 15.57 | 10.66 | 22.01 | 22.01 | ok |
| 16.0 MiB | metal | e2e-auto | 6.97 | 4.67 | 7.24 | 7.24 | ok |
| 16.0 MiB | metal | e2e-gpu | 7.12 | 5.15 | 8.49 | 8.49 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 1.07 | 1.09 | 1.09 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.37 | 8.40 | 10.12 | 10.12 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.41 | 8.35 | 10.13 | 10.13 | ok |
| 64.0 MiB | blake3 | default-auto | 25.90 | 12.03 | 26.79 | 26.79 | ok |
| 64.0 MiB | metal | resident-auto | 32.87 | 15.01 | 39.64 | 39.64 | ok |
| 64.0 MiB | metal | resident-gpu | 29.28 | 20.27 | 39.15 | 39.15 | ok |
| 64.0 MiB | metal | private-gpu | 35.16 | 26.65 | 39.65 | 39.65 | ok |
| 64.0 MiB | metal | e2e-auto | 9.00 | 7.80 | 9.53 | 9.53 | ok |
| 64.0 MiB | metal | e2e-gpu | 8.71 | 7.63 | 9.29 | 9.29 | ok |
| 256.0 MiB | cpu | scalar | 1.08 | 1.05 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.69 | 1.43 | 1.74 | 1.74 | ok |
| 256.0 MiB | cpu | parallel | 9.18 | 8.41 | 10.12 | 10.12 | ok |
| 256.0 MiB | official-c | one-shot | 2.12 | 2.08 | 2.16 | 2.16 | ok |
| 256.0 MiB | cpu | context-auto | 9.87 | 9.64 | 10.30 | 10.30 | ok |
| 256.0 MiB | blake3 | default-auto | 30.87 | 28.79 | 33.30 | 33.30 | ok |
| 256.0 MiB | metal | resident-auto | 45.84 | 42.03 | 52.12 | 52.12 | ok |
| 256.0 MiB | metal | resident-gpu | 51.07 | 44.19 | 59.20 | 59.20 | ok |
| 256.0 MiB | metal | private-gpu | 50.39 | 36.94 | 65.62 | 65.62 | ok |
| 256.0 MiB | metal | e2e-auto | 9.15 | 6.78 | 9.56 | 9.56 | ok |
| 256.0 MiB | metal | e2e-gpu | 9.34 | 5.06 | 10.20 | 10.20 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.08 | 1.09 | 1.09 | ok |
| 512.0 MiB | cpu | single-simd | 1.74 | 1.71 | 1.75 | 1.75 | ok |
| 512.0 MiB | cpu | parallel | 10.41 | 10.15 | 10.60 | 10.60 | ok |
| 512.0 MiB | official-c | one-shot | 2.16 | 2.15 | 2.16 | 2.16 | ok |
| 512.0 MiB | cpu | context-auto | 10.28 | 9.32 | 10.71 | 10.71 | ok |
| 512.0 MiB | blake3 | default-auto | 30.37 | 28.91 | 32.01 | 32.01 | ok |
| 512.0 MiB | metal | resident-auto | 51.32 | 44.29 | 63.38 | 63.38 | ok |
| 512.0 MiB | metal | resident-gpu | 60.20 | 57.06 | 62.69 | 62.69 | ok |
| 512.0 MiB | metal | private-gpu | 60.74 | 50.24 | 70.52 | 70.52 | ok |
| 512.0 MiB | metal | e2e-auto | 10.40 | 9.91 | 10.75 | 10.75 | ok |
| 512.0 MiB | metal | e2e-gpu | 9.74 | 8.45 | 10.27 | 10.27 | ok |
| 1.0 GiB | cpu | scalar | 1.07 | 1.05 | 1.08 | 1.08 | ok |
| 1.0 GiB | cpu | single-simd | 1.70 | 1.66 | 1.74 | 1.74 | ok |
| 1.0 GiB | cpu | parallel | 10.01 | 8.56 | 10.87 | 10.87 | ok |
| 1.0 GiB | official-c | one-shot | 2.15 | 2.08 | 2.16 | 2.16 | ok |
| 1.0 GiB | cpu | context-auto | 10.56 | 9.95 | 10.82 | 10.82 | ok |
| 1.0 GiB | blake3 | default-auto | 34.81 | 30.13 | 37.53 | 37.53 | ok |
| 1.0 GiB | metal | resident-auto | 59.18 | 57.17 | 65.76 | 65.76 | ok |
| 1.0 GiB | metal | resident-gpu | 63.59 | 57.16 | 70.24 | 70.24 | ok |
| 1.0 GiB | metal | private-gpu | 73.71 | 60.48 | 76.33 | 76.33 | ok |
| 1.0 GiB | metal | e2e-auto | 9.00 | 8.36 | 9.57 | 9.57 | ok |
| 1.0 GiB | metal | e2e-gpu | 9.14 | 8.29 | 9.63 | 9.63 | ok |
jsonOutput=benchmarks/results/20260418T203340Z-chosen-publication/cpu-metal-publication.json
