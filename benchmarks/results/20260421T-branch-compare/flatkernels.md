BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=resident,private,staged,wrapped,e2e
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-private includes: pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read
metal-staged includes: pre-created shared staging MTLBuffer; timed Swift-byte copy into staging buffer plus hash
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.15 | 1.08 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.73 | 1.72 | 1.77 | 1.77 | ok |
| 16.0 MiB | cpu | parallel | 8.20 | 7.21 | 9.25 | 9.25 | ok |
| 16.0 MiB | official-c | one-shot | 2.19 | 2.14 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 7.97 | 7.70 | 9.29 | 9.29 | ok |
| 16.0 MiB | blake3 | default-auto | 8.50 | 7.54 | 10.06 | 10.06 | ok |
| 16.0 MiB | metal | resident-auto | 7.33 | 2.35 | 12.92 | 12.92 | ok |
| 16.0 MiB | metal | resident-gpu | 8.94 | 4.09 | 14.39 | 14.39 | ok |
| 16.0 MiB | metal | private-gpu | 9.03 | 7.13 | 13.30 | 13.30 | ok |
| 16.0 MiB | metal | staged-auto | 6.62 | 1.79 | 8.38 | 8.38 | ok |
| 16.0 MiB | metal | staged-gpu | 6.91 | 4.63 | 8.09 | 8.09 | ok |
| 16.0 MiB | metal | wrapped-auto | 8.58 | 4.03 | 9.45 | 9.45 | ok |
| 16.0 MiB | metal | wrapped-gpu | 9.09 | 2.15 | 9.90 | 9.90 | ok |
| 16.0 MiB | metal | e2e-auto | 5.80 | 2.11 | 7.65 | 7.65 | ok |
| 16.0 MiB | metal | e2e-gpu | 6.58 | 1.77 | 7.63 | 7.63 | ok |
| 64.0 MiB | cpu | scalar | 1.14 | 1.06 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.69 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 8.15 | 6.94 | 8.36 | 8.36 | ok |
| 64.0 MiB | official-c | one-shot | 2.14 | 2.12 | 2.16 | 2.16 | ok |
| 64.0 MiB | cpu | context-auto | 8.99 | 8.44 | 10.32 | 10.32 | ok |
| 64.0 MiB | blake3 | default-auto | 17.02 | 14.97 | 20.94 | 20.94 | ok |
| 64.0 MiB | metal | resident-auto | 17.31 | 8.91 | 25.00 | 25.00 | ok |
| 64.0 MiB | metal | resident-gpu | 25.07 | 17.05 | 29.03 | 29.03 | ok |
| 64.0 MiB | metal | private-gpu | 21.30 | 12.65 | 30.21 | 30.21 | ok |
| 64.0 MiB | metal | staged-auto | 10.15 | 7.34 | 13.22 | 13.22 | ok |
| 64.0 MiB | metal | staged-gpu | 10.26 | 7.85 | 11.77 | 11.77 | ok |
| 64.0 MiB | metal | wrapped-auto | 15.97 | 11.05 | 18.15 | 18.15 | ok |
| 64.0 MiB | metal | wrapped-gpu | 15.65 | 12.57 | 18.86 | 18.86 | ok |
| 64.0 MiB | metal | e2e-auto | 10.34 | 5.66 | 11.58 | 11.58 | ok |
| 64.0 MiB | metal | e2e-gpu | 8.55 | 3.64 | 11.62 | 11.62 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.13 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.73 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 9.82 | 9.41 | 10.64 | 10.64 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.04 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.16 | 9.80 | 10.53 | 10.53 | ok |
| 256.0 MiB | blake3 | default-auto | 33.66 | 26.45 | 41.07 | 41.07 | ok |
| 256.0 MiB | metal | resident-auto | 57.48 | 37.07 | 67.71 | 67.71 | ok |
| 256.0 MiB | metal | resident-gpu | 46.98 | 43.66 | 54.33 | 54.33 | ok |
| 256.0 MiB | metal | private-gpu | 49.85 | 35.73 | 53.95 | 53.95 | ok |
| 256.0 MiB | metal | staged-auto | 19.05 | 17.75 | 24.80 | 24.80 | ok |
| 256.0 MiB | metal | staged-gpu | 19.07 | 16.47 | 21.18 | 21.18 | ok |
| 256.0 MiB | metal | wrapped-auto | 35.17 | 26.43 | 36.58 | 36.58 | ok |
| 256.0 MiB | metal | wrapped-gpu | 33.56 | 27.14 | 40.76 | 40.76 | ok |
| 256.0 MiB | metal | e2e-auto | 15.88 | 14.29 | 20.05 | 20.05 | ok |
| 256.0 MiB | metal | e2e-gpu | 15.28 | 14.98 | 18.91 | 18.91 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.09 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.76 | 1.73 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 10.01 | 9.06 | 11.43 | 11.43 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.14 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 10.67 | 9.23 | 10.95 | 10.95 | ok |
| 512.0 MiB | blake3 | default-auto | 38.39 | 29.16 | 40.96 | 40.96 | ok |
| 512.0 MiB | metal | resident-auto | 52.82 | 43.30 | 74.44 | 74.44 | ok |
| 512.0 MiB | metal | resident-gpu | 62.45 | 41.44 | 74.53 | 74.53 | ok |
| 512.0 MiB | metal | private-gpu | 53.24 | 47.77 | 73.40 | 73.40 | ok |
| 512.0 MiB | metal | staged-auto | 21.97 | 18.78 | 22.46 | 22.46 | ok |
| 512.0 MiB | metal | staged-gpu | 21.33 | 19.57 | 24.05 | 24.05 | ok |
| 512.0 MiB | metal | wrapped-auto | 38.50 | 29.45 | 48.35 | 48.35 | ok |
| 512.0 MiB | metal | wrapped-gpu | 37.83 | 30.82 | 42.82 | 42.82 | ok |
| 512.0 MiB | metal | e2e-auto | 17.24 | 15.80 | 18.60 | 18.60 | ok |
| 512.0 MiB | metal | e2e-gpu | 18.52 | 16.41 | 19.88 | 19.88 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.14 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.74 | 1.69 | 1.76 | 1.76 | ok |
| 1.0 GiB | cpu | parallel | 11.12 | 9.92 | 11.64 | 11.64 | ok |
| 1.0 GiB | official-c | one-shot | 2.15 | 2.07 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 11.15 | 9.61 | 11.48 | 11.48 | ok |
| 1.0 GiB | blake3 | default-auto | 41.89 | 37.89 | 44.71 | 44.71 | ok |
| 1.0 GiB | metal | resident-auto | 69.85 | 63.48 | 77.48 | 77.48 | ok |
| 1.0 GiB | metal | resident-gpu | 69.62 | 55.06 | 77.13 | 77.13 | ok |
| 1.0 GiB | metal | private-gpu | 65.59 | 49.19 | 71.40 | 71.40 | ok |
| 1.0 GiB | metal | staged-auto | 22.81 | 20.92 | 24.47 | 24.47 | ok |
| 1.0 GiB | metal | staged-gpu | 23.10 | 20.81 | 23.43 | 23.43 | ok |
| 1.0 GiB | metal | wrapped-auto | 44.34 | 43.20 | 48.38 | 48.38 | ok |
| 1.0 GiB | metal | wrapped-gpu | 42.19 | 39.48 | 45.80 | 45.80 | ok |
| 1.0 GiB | metal | e2e-auto | 18.99 | 16.47 | 19.94 | 19.94 | ok |
| 1.0 GiB | metal | e2e-gpu | 19.43 | 18.92 | 19.71 | 19.71 | ok |
jsonOutput=benchmarks/results/20260421T-branch-compare/flatkernels.json
