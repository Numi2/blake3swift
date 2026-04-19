BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=67108864
metalModes=resident,private,staged,wrapped,e2e
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-private includes: pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read
metal-staged includes: pre-created shared staging MTLBuffer; timed Swift-byte copy into staging buffer plus hash
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.11 | 1.11 | ok |
| 16.0 MiB | cpu | single-simd | 1.83 | 1.81 | 1.90 | 1.90 | ok |
| 16.0 MiB | cpu | parallel | 9.08 | 7.84 | 9.27 | 9.27 | ok |
| 16.0 MiB | official-c | one-shot | 2.25 | 2.23 | 2.30 | 2.30 | ok |
| 16.0 MiB | cpu | context-auto | 7.76 | 7.36 | 7.84 | 7.84 | ok |
| 16.0 MiB | blake3 | default-auto | 9.29 | 8.37 | 10.92 | 10.92 | ok |
| 16.0 MiB | metal | resident-auto | 9.65 | 2.72 | 10.49 | 10.49 | ok |
| 16.0 MiB | metal | resident-gpu | 14.00 | 8.56 | 29.42 | 29.42 | ok |
| 16.0 MiB | metal | private-gpu | 26.45 | 13.52 | 32.17 | 32.17 | ok |
| 16.0 MiB | metal | staged-auto | 15.14 | 7.72 | 17.02 | 17.02 | ok |
| 16.0 MiB | metal | staged-gpu | 15.31 | 9.81 | 16.65 | 16.65 | ok |
| 16.0 MiB | metal | wrapped-auto | 20.37 | 8.84 | 22.61 | 22.61 | ok |
| 16.0 MiB | metal | wrapped-gpu | 20.84 | 12.65 | 24.11 | 24.11 | ok |
| 16.0 MiB | metal | e2e-auto | 9.94 | 8.04 | 10.65 | 10.65 | ok |
| 16.0 MiB | metal | e2e-gpu | 10.11 | 9.23 | 10.59 | 10.59 | ok |
| 64.0 MiB | cpu | scalar | 1.11 | 1.10 | 1.11 | 1.11 | ok |
| 64.0 MiB | cpu | single-simd | 1.85 | 1.82 | 1.86 | 1.86 | ok |
| 64.0 MiB | cpu | parallel | 10.13 | 9.06 | 10.34 | 10.34 | ok |
| 64.0 MiB | official-c | one-shot | 2.24 | 2.22 | 2.26 | 2.26 | ok |
| 64.0 MiB | cpu | context-auto | 10.17 | 8.60 | 10.46 | 10.46 | ok |
| 64.0 MiB | blake3 | default-auto | 16.00 | 8.04 | 44.38 | 44.38 | ok |
| 64.0 MiB | metal | resident-auto | 51.97 | 37.52 | 56.56 | 56.56 | ok |
| 64.0 MiB | metal | resident-gpu | 46.87 | 35.39 | 57.44 | 57.44 | ok |
| 64.0 MiB | metal | private-gpu | 54.34 | 53.00 | 58.80 | 58.80 | ok |
| 64.0 MiB | metal | staged-auto | 21.10 | 16.67 | 23.62 | 23.62 | ok |
| 64.0 MiB | metal | staged-gpu | 20.72 | 14.05 | 23.07 | 23.07 | ok |
| 64.0 MiB | metal | wrapped-auto | 44.55 | 34.30 | 45.14 | 45.14 | ok |
| 64.0 MiB | metal | wrapped-gpu | 44.76 | 39.00 | 45.57 | 45.57 | ok |
| 64.0 MiB | metal | e2e-auto | 13.14 | 10.62 | 13.86 | 13.86 | ok |
| 64.0 MiB | metal | e2e-gpu | 13.01 | 10.56 | 13.54 | 13.54 | ok |
| 256.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.11 | 1.11 | ok |
| 256.0 MiB | cpu | single-simd | 1.84 | 1.82 | 1.84 | 1.84 | ok |
| 256.0 MiB | cpu | parallel | 10.51 | 9.90 | 11.12 | 11.12 | ok |
| 256.0 MiB | official-c | one-shot | 2.23 | 2.22 | 2.25 | 2.25 | ok |
| 256.0 MiB | cpu | context-auto | 10.52 | 9.80 | 10.73 | 10.73 | ok |
| 256.0 MiB | blake3 | default-auto | 54.98 | 35.10 | 55.73 | 55.73 | ok |
| 256.0 MiB | metal | resident-auto | 69.84 | 55.19 | 78.25 | 78.25 | ok |
| 256.0 MiB | metal | resident-gpu | 76.50 | 57.22 | 78.23 | 78.23 | ok |
| 256.0 MiB | metal | private-gpu | 70.48 | 53.45 | 71.87 | 71.87 | ok |
| 256.0 MiB | metal | staged-auto | 24.96 | 20.03 | 26.36 | 26.36 | ok |
| 256.0 MiB | metal | staged-gpu | 23.24 | 22.26 | 26.17 | 26.17 | ok |
| 256.0 MiB | metal | wrapped-auto | 55.22 | 43.48 | 55.78 | 55.78 | ok |
| 256.0 MiB | metal | wrapped-gpu | 54.42 | 43.42 | 55.46 | 55.46 | ok |
| 256.0 MiB | metal | e2e-auto | 13.35 | 10.03 | 13.61 | 13.61 | ok |
| 256.0 MiB | metal | e2e-gpu | 12.19 | 8.41 | 13.70 | 13.70 | ok |
| 512.0 MiB | cpu | scalar | 1.10 | 1.06 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.81 | 1.79 | 1.82 | 1.82 | ok |
| 512.0 MiB | cpu | parallel | 10.74 | 10.17 | 11.09 | 11.09 | ok |
| 512.0 MiB | official-c | one-shot | 2.22 | 2.21 | 2.23 | 2.23 | ok |
| 512.0 MiB | cpu | context-auto | 11.04 | 10.52 | 11.43 | 11.43 | ok |
| 512.0 MiB | blake3 | default-auto | 53.42 | 45.56 | 57.92 | 57.92 | ok |
| 512.0 MiB | metal | resident-auto | 75.76 | 64.32 | 84.63 | 84.63 | ok |
| 512.0 MiB | metal | resident-gpu | 80.25 | 68.11 | 83.42 | 83.42 | ok |
| 512.0 MiB | metal | private-gpu | 66.89 | 62.56 | 77.11 | 77.11 | ok |
| 512.0 MiB | metal | staged-auto | 25.48 | 18.31 | 26.03 | 26.03 | ok |
| 512.0 MiB | metal | staged-gpu | 25.70 | 24.50 | 26.58 | 26.58 | ok |
| 512.0 MiB | metal | wrapped-auto | 57.40 | 50.49 | 57.92 | 57.92 | ok |
| 512.0 MiB | metal | wrapped-gpu | 57.37 | 50.22 | 58.36 | 58.36 | ok |
| 512.0 MiB | metal | e2e-auto | 11.98 | 5.81 | 13.67 | 13.67 | ok |
| 512.0 MiB | metal | e2e-gpu | 5.19 | 0.18 | 6.82 | 6.82 | ok |
| 1.0 GiB | cpu | scalar | 1.10 | 1.10 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.81 | 1.79 | 1.82 | 1.82 | ok |
| 1.0 GiB | cpu | parallel | 11.29 | 10.74 | 11.76 | 11.76 | ok |
| 1.0 GiB | official-c | one-shot | 2.20 | 2.19 | 2.21 | 2.21 | ok |
| 1.0 GiB | cpu | context-auto | 11.34 | 10.64 | 11.56 | 11.56 | ok |
| 1.0 GiB | blake3 | default-auto | 46.61 | 41.51 | 49.92 | 49.92 | ok |
| 1.0 GiB | metal | resident-auto | 69.13 | 62.84 | 79.34 | 79.34 | ok |
| 1.0 GiB | metal | resident-gpu | 71.73 | 65.56 | 81.41 | 81.41 | ok |
| 1.0 GiB | metal | private-gpu | 54.07 | 45.06 | 57.06 | 57.06 | ok |
| 1.0 GiB | metal | staged-auto | 21.97 | 12.09 | 23.24 | 23.24 | ok |
| 1.0 GiB | metal | staged-gpu | 23.49 | 22.37 | 25.82 | 25.82 | ok |
| 1.0 GiB | metal | wrapped-auto | 44.10 | 41.04 | 48.79 | 48.79 | ok |
| 1.0 GiB | metal | wrapped-gpu | 43.44 | 42.03 | 48.02 | 48.02 | ok |
| 1.0 GiB | metal | e2e-auto | 2.87 | 1.71 | 11.92 | 11.92 | ok |
| 1.0 GiB | metal | e2e-gpu | 0.98 | 0.23 | 2.07 | 2.07 | ok |
jsonOutput=benchmarks/results/20260419T100143Z/cpu-metal-publication.json
