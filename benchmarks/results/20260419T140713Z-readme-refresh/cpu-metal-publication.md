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
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.16 | 1.13 | 1.17 | 1.17 | ok |
| 16.0 MiB | cpu | single-simd | 1.92 | 1.90 | 1.94 | 1.94 | ok |
| 16.0 MiB | cpu | parallel | 8.99 | 7.89 | 9.31 | 9.31 | ok |
| 16.0 MiB | official-c | one-shot | 2.40 | 2.32 | 2.41 | 2.41 | ok |
| 16.0 MiB | cpu | context-auto | 9.01 | 7.89 | 9.23 | 9.23 | ok |
| 16.0 MiB | blake3 | default-auto | 15.33 | 9.34 | 21.55 | 21.55 | ok |
| 16.0 MiB | metal | resident-auto | 18.89 | 11.75 | 26.04 | 26.04 | ok |
| 16.0 MiB | metal | resident-gpu | 19.41 | 7.61 | 25.00 | 25.00 | ok |
| 16.0 MiB | metal | private-gpu | 20.67 | 11.22 | 22.67 | 22.67 | ok |
| 16.0 MiB | metal | staged-auto | 12.35 | 8.77 | 14.51 | 14.51 | ok |
| 16.0 MiB | metal | staged-gpu | 14.36 | 6.54 | 16.32 | 16.32 | ok |
| 16.0 MiB | metal | wrapped-auto | 19.79 | 9.01 | 23.08 | 23.08 | ok |
| 16.0 MiB | metal | wrapped-gpu | 19.35 | 6.87 | 20.70 | 20.70 | ok |
| 16.0 MiB | metal | e2e-auto | 8.56 | 6.77 | 9.44 | 9.44 | ok |
| 16.0 MiB | metal | e2e-gpu | 8.38 | 3.90 | 8.95 | 8.95 | ok |
| 64.0 MiB | cpu | scalar | 1.15 | 1.13 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.87 | 1.39 | 1.88 | 1.88 | ok |
| 64.0 MiB | cpu | parallel | 9.37 | 8.22 | 10.09 | 10.09 | ok |
| 64.0 MiB | official-c | one-shot | 2.33 | 2.26 | 2.37 | 2.37 | ok |
| 64.0 MiB | cpu | context-auto | 9.94 | 8.87 | 10.22 | 10.22 | ok |
| 64.0 MiB | blake3 | default-auto | 24.61 | 14.24 | 34.54 | 34.54 | ok |
| 64.0 MiB | metal | resident-auto | 38.49 | 28.80 | 43.90 | 43.90 | ok |
| 64.0 MiB | metal | resident-gpu | 38.40 | 19.98 | 44.77 | 44.77 | ok |
| 64.0 MiB | metal | private-gpu | 46.17 | 23.88 | 50.91 | 50.91 | ok |
| 64.0 MiB | metal | staged-auto | 17.37 | 9.63 | 19.70 | 19.70 | ok |
| 64.0 MiB | metal | staged-gpu | 17.77 | 12.02 | 19.87 | 19.87 | ok |
| 64.0 MiB | metal | wrapped-auto | 30.56 | 17.38 | 35.20 | 35.20 | ok |
| 64.0 MiB | metal | wrapped-gpu | 33.81 | 18.32 | 35.70 | 35.70 | ok |
| 64.0 MiB | metal | e2e-auto | 10.76 | 8.02 | 12.33 | 12.33 | ok |
| 64.0 MiB | metal | e2e-gpu | 10.88 | 6.37 | 11.70 | 11.70 | ok |
| 256.0 MiB | cpu | scalar | 1.12 | 1.10 | 1.13 | 1.13 | ok |
| 256.0 MiB | cpu | single-simd | 1.89 | 1.88 | 1.89 | 1.89 | ok |
| 256.0 MiB | cpu | parallel | 10.80 | 10.19 | 10.96 | 10.96 | ok |
| 256.0 MiB | official-c | one-shot | 2.31 | 2.29 | 2.31 | 2.31 | ok |
| 256.0 MiB | cpu | context-auto | 10.64 | 10.21 | 11.00 | 11.00 | ok |
| 256.0 MiB | blake3 | default-auto | 41.79 | 19.91 | 53.43 | 53.43 | ok |
| 256.0 MiB | metal | resident-auto | 69.64 | 54.54 | 76.04 | 76.04 | ok |
| 256.0 MiB | metal | resident-gpu | 75.28 | 54.37 | 79.85 | 79.85 | ok |
| 256.0 MiB | metal | private-gpu | 62.35 | 51.68 | 72.29 | 72.29 | ok |
| 256.0 MiB | metal | staged-auto | 22.70 | 15.72 | 24.21 | 24.21 | ok |
| 256.0 MiB | metal | staged-gpu | 21.86 | 19.89 | 22.95 | 22.95 | ok |
| 256.0 MiB | metal | wrapped-auto | 51.37 | 40.09 | 53.16 | 53.16 | ok |
| 256.0 MiB | metal | wrapped-gpu | 42.93 | 41.29 | 50.89 | 50.89 | ok |
| 256.0 MiB | metal | e2e-auto | 11.82 | 10.98 | 12.11 | 12.11 | ok |
| 256.0 MiB | metal | e2e-gpu | 9.92 | 7.86 | 11.46 | 11.46 | ok |
| 512.0 MiB | cpu | scalar | 1.11 | 1.11 | 1.11 | 1.11 | ok |
| 512.0 MiB | cpu | single-simd | 1.87 | 1.86 | 1.88 | 1.88 | ok |
| 512.0 MiB | cpu | parallel | 11.08 | 10.89 | 11.53 | 11.53 | ok |
| 512.0 MiB | official-c | one-shot | 2.25 | 2.22 | 2.27 | 2.27 | ok |
| 512.0 MiB | cpu | context-auto | 11.13 | 10.66 | 11.41 | 11.41 | ok |
| 512.0 MiB | blake3 | default-auto | 37.00 | 34.93 | 37.98 | 37.98 | ok |
| 512.0 MiB | metal | resident-auto | 54.75 | 44.71 | 70.63 | 70.63 | ok |
| 512.0 MiB | metal | resident-gpu | 67.91 | 60.94 | 79.76 | 79.76 | ok |
| 512.0 MiB | metal | private-gpu | 64.44 | 62.62 | 71.64 | 71.64 | ok |
| 512.0 MiB | metal | staged-auto | 23.69 | 15.30 | 25.20 | 25.20 | ok |
| 512.0 MiB | metal | staged-gpu | 23.69 | 22.53 | 24.92 | 24.92 | ok |
| 512.0 MiB | metal | wrapped-auto | 48.59 | 46.26 | 55.81 | 55.81 | ok |
| 512.0 MiB | metal | wrapped-gpu | 48.94 | 45.99 | 53.09 | 53.09 | ok |
| 512.0 MiB | metal | e2e-auto | 12.80 | 12.09 | 13.39 | 13.39 | ok |
| 512.0 MiB | metal | e2e-gpu | 8.62 | 0.19 | 10.94 | 10.94 | ok |
| 1.0 GiB | cpu | scalar | 1.10 | 1.10 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.82 | 1.78 | 1.83 | 1.83 | ok |
| 1.0 GiB | cpu | parallel | 11.54 | 10.90 | 11.82 | 11.82 | ok |
| 1.0 GiB | official-c | one-shot | 2.21 | 2.19 | 2.22 | 2.22 | ok |
| 1.0 GiB | cpu | context-auto | 11.43 | 11.13 | 11.79 | 11.79 | ok |
| 1.0 GiB | blake3 | default-auto | 46.94 | 43.86 | 51.33 | 51.33 | ok |
| 1.0 GiB | metal | resident-auto | 71.31 | 70.03 | 80.22 | 80.22 | ok |
| 1.0 GiB | metal | resident-gpu | 73.18 | 68.68 | 84.97 | 84.97 | ok |
| 1.0 GiB | metal | private-gpu | 56.57 | 52.94 | 63.58 | 63.58 | ok |
| 1.0 GiB | metal | staged-auto | 20.73 | 14.98 | 24.13 | 24.13 | ok |
| 1.0 GiB | metal | staged-gpu | 22.61 | 21.46 | 24.08 | 24.08 | ok |
| 1.0 GiB | metal | wrapped-auto | 41.88 | 35.85 | 44.49 | 44.49 | ok |
| 1.0 GiB | metal | wrapped-gpu | 40.65 | 36.26 | 46.44 | 46.44 | ok |
| 1.0 GiB | metal | e2e-auto | 3.21 | 2.08 | 8.91 | 8.91 | ok |
| 1.0 GiB | metal | e2e-gpu | 2.02 | 0.19 | 4.12 | 4.12 | ok |
jsonOutput=benchmarks/results/20260419T140713Z-readme-refresh/cpu-metal-publication.json
