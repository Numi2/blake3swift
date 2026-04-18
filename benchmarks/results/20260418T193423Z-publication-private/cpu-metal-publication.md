BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=resident,private,e2e
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-private includes: pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 0.79 | 0.69 | 1.06 | 1.06 | ok |
| 64.0 MiB | cpu | single-simd | 1.76 | 1.67 | 1.82 | 1.82 | ok |
| 64.0 MiB | cpu | parallel | 8.92 | 7.06 | 10.02 | 10.02 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.13 | 2.20 | 2.20 | ok |
| 64.0 MiB | cpu | context-auto | 9.21 | 7.96 | 9.90 | 9.90 | ok |
| 64.0 MiB | blake3 | default-auto | 18.41 | 5.61 | 25.74 | 25.74 | ok |
| 64.0 MiB | metal | resident-auto | 35.81 | 21.65 | 42.09 | 42.09 | ok |
| 64.0 MiB | metal | resident-gpu | 40.30 | 21.52 | 43.73 | 43.73 | ok |
| 64.0 MiB | metal | private-gpu | 35.80 | 19.47 | 43.45 | 43.45 | ok |
| 64.0 MiB | metal | e2e-auto | 8.71 | 7.99 | 10.21 | 10.21 | ok |
| 64.0 MiB | metal | e2e-gpu | 8.22 | 7.90 | 9.63 | 9.63 | ok |
| 256.0 MiB | cpu | scalar | 1.10 | 1.10 | 1.11 | 1.11 | ok |
| 256.0 MiB | cpu | single-simd | 1.83 | 1.82 | 1.84 | 1.84 | ok |
| 256.0 MiB | cpu | parallel | 10.28 | 9.75 | 10.69 | 10.69 | ok |
| 256.0 MiB | official-c | one-shot | 2.22 | 2.19 | 2.23 | 2.23 | ok |
| 256.0 MiB | cpu | context-auto | 10.37 | 9.85 | 10.54 | 10.54 | ok |
| 256.0 MiB | blake3 | default-auto | 30.59 | 18.97 | 31.90 | 31.90 | ok |
| 256.0 MiB | metal | resident-auto | 48.33 | 38.91 | 53.90 | 53.90 | ok |
| 256.0 MiB | metal | resident-gpu | 57.38 | 49.10 | 66.63 | 66.63 | ok |
| 256.0 MiB | metal | private-gpu | 64.21 | 59.10 | 69.48 | 69.48 | ok |
| 256.0 MiB | metal | e2e-auto | 9.60 | 9.05 | 9.97 | 9.97 | ok |
| 256.0 MiB | metal | e2e-gpu | 9.71 | 5.21 | 9.86 | 9.86 | ok |
| 512.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.81 | 1.80 | 1.81 | 1.81 | ok |
| 512.0 MiB | cpu | parallel | 10.73 | 10.19 | 11.27 | 11.27 | ok |
| 512.0 MiB | official-c | one-shot | 2.20 | 2.19 | 2.21 | 2.21 | ok |
| 512.0 MiB | cpu | context-auto | 10.65 | 10.08 | 11.40 | 11.40 | ok |
| 512.0 MiB | blake3 | default-auto | 28.20 | 24.93 | 30.73 | 30.73 | ok |
| 512.0 MiB | metal | resident-auto | 44.23 | 34.94 | 62.80 | 62.80 | ok |
| 512.0 MiB | metal | resident-gpu | 57.72 | 52.64 | 62.05 | 62.05 | ok |
| 512.0 MiB | metal | private-gpu | 51.10 | 43.29 | 59.79 | 59.79 | ok |
| 512.0 MiB | metal | e2e-auto | 9.78 | 8.77 | 9.95 | 9.95 | ok |
| 512.0 MiB | metal | e2e-gpu | 9.59 | 9.36 | 10.01 | 10.01 | ok |
| 1.0 GiB | cpu | scalar | 1.08 | 1.01 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.77 | 1.70 | 1.78 | 1.78 | ok |
| 1.0 GiB | cpu | parallel | 11.32 | 10.86 | 11.56 | 11.56 | ok |
| 1.0 GiB | official-c | one-shot | 2.18 | 2.18 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 11.01 | 10.55 | 11.41 | 11.41 | ok |
| 1.0 GiB | blake3 | default-auto | 34.14 | 32.70 | 37.34 | 37.34 | ok |
| 1.0 GiB | metal | resident-auto | 62.64 | 60.92 | 69.75 | 69.75 | ok |
| 1.0 GiB | metal | resident-gpu | 64.08 | 50.63 | 70.05 | 70.05 | ok |
| 1.0 GiB | metal | private-gpu | 64.03 | 59.58 | 66.25 | 66.25 | ok |
| 1.0 GiB | metal | e2e-auto | 10.13 | 8.75 | 10.52 | 10.52 | ok |
| 1.0 GiB | metal | e2e-gpu | 10.31 | 9.67 | 10.82 | 10.82 | ok |
jsonOutput=benchmarks/results/20260418T193423Z-publication-private/cpu-metal-publication.json
