BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=8388608
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=8388608
metalTileByteCount=16777216
metalModes=resident,private
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-private includes: pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read
sizes=8.0 MiB, 16.0 MiB, 32.0 MiB, 64.0 MiB, 256.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 8.0 MiB | cpu | scalar | 1.09 | 1.07 | 1.10 | 1.10 | ok |
| 8.0 MiB | cpu | single-simd | 1.76 | 1.73 | 1.82 | 1.82 | ok |
| 8.0 MiB | cpu | parallel | 7.22 | 7.08 | 8.09 | 8.09 | ok |
| 8.0 MiB | official-c | one-shot | 2.18 | 2.14 | 2.20 | 2.20 | ok |
| 8.0 MiB | cpu | context-auto | 7.94 | 6.51 | 8.21 | 8.21 | ok |
| 8.0 MiB | blake3 | default-auto | 6.05 | 4.23 | 6.75 | 6.75 | ok |
| 8.0 MiB | metal | resident-auto | 6.09 | 1.25 | 6.43 | 6.43 | ok |
| 8.0 MiB | metal | resident-gpu | 14.85 | 3.30 | 17.11 | 17.11 | ok |
| 8.0 MiB | metal | private-gpu | 12.10 | 6.25 | 14.69 | 14.69 | ok |
| 16.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 16.0 MiB | cpu | single-simd | 1.76 | 1.73 | 1.78 | 1.78 | ok |
| 16.0 MiB | cpu | parallel | 8.72 | 7.29 | 9.16 | 9.16 | ok |
| 16.0 MiB | official-c | one-shot | 2.19 | 2.15 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 8.83 | 7.70 | 9.19 | 9.19 | ok |
| 16.0 MiB | blake3 | default-auto | 8.91 | 2.10 | 9.76 | 9.76 | ok |
| 16.0 MiB | metal | resident-auto | 9.25 | 2.96 | 15.16 | 15.16 | ok |
| 16.0 MiB | metal | resident-gpu | 14.08 | 5.87 | 17.28 | 17.28 | ok |
| 16.0 MiB | metal | private-gpu | 15.91 | 4.87 | 17.15 | 17.15 | ok |
| 32.0 MiB | cpu | scalar | 1.09 | 1.08 | 1.10 | 1.10 | ok |
| 32.0 MiB | cpu | single-simd | 1.76 | 1.74 | 1.77 | 1.77 | ok |
| 32.0 MiB | cpu | parallel | 9.42 | 7.75 | 9.92 | 9.92 | ok |
| 32.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.19 | 2.19 | ok |
| 32.0 MiB | cpu | context-auto | 9.23 | 7.89 | 9.86 | 9.86 | ok |
| 32.0 MiB | blake3 | default-auto | 20.97 | 10.36 | 23.91 | 23.91 | ok |
| 32.0 MiB | metal | resident-auto | 26.72 | 11.17 | 30.60 | 30.60 | ok |
| 32.0 MiB | metal | resident-gpu | 25.72 | 11.08 | 31.73 | 31.73 | ok |
| 32.0 MiB | metal | private-gpu | 28.59 | 10.99 | 30.54 | 30.54 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 1.07 | 1.09 | 1.09 | ok |
| 64.0 MiB | cpu | single-simd | 1.76 | 1.74 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.91 | 8.57 | 10.25 | 10.25 | ok |
| 64.0 MiB | official-c | one-shot | 2.16 | 2.11 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.93 | 8.49 | 10.23 | 10.23 | ok |
| 64.0 MiB | blake3 | default-auto | 13.85 | 7.76 | 22.29 | 22.29 | ok |
| 64.0 MiB | metal | resident-auto | 29.16 | 13.31 | 34.39 | 34.39 | ok |
| 64.0 MiB | metal | resident-gpu | 30.92 | 17.16 | 39.68 | 39.68 | ok |
| 64.0 MiB | metal | private-gpu | 35.84 | 18.11 | 37.85 | 37.85 | ok |
| 256.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.07 | 9.37 | 10.91 | 10.91 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.22 | 9.64 | 10.81 | 10.81 | ok |
| 256.0 MiB | blake3 | default-auto | 36.53 | 26.91 | 41.15 | 41.15 | ok |
| 256.0 MiB | metal | resident-auto | 59.47 | 50.75 | 69.99 | 69.99 | ok |
| 256.0 MiB | metal | resident-gpu | 58.95 | 51.08 | 65.40 | 65.40 | ok |
| 256.0 MiB | metal | private-gpu | 57.58 | 50.79 | 67.34 | 67.34 | ok |
jsonOutput=benchmarks/results/20260418T193818Z-default-gate-8m-after/default-gate-8m-after.json
