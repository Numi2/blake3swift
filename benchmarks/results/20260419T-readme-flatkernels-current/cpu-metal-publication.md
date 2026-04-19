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
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.79 | 1.78 | 1.80 | 1.80 | ok |
| 16.0 MiB | cpu | parallel | 8.72 | 7.75 | 9.29 | 9.29 | ok |
| 16.0 MiB | official-c | one-shot | 2.23 | 2.19 | 2.24 | 2.24 | ok |
| 16.0 MiB | cpu | context-auto | 9.15 | 8.34 | 9.31 | 9.31 | ok |
| 16.0 MiB | blake3 | default-auto | 9.65 | 2.69 | 10.35 | 10.35 | ok |
| 16.0 MiB | metal | resident-auto | 12.89 | 8.05 | 15.42 | 15.42 | ok |
| 16.0 MiB | metal | resident-gpu | 8.97 | 2.92 | 10.33 | 10.33 | ok |
| 16.0 MiB | metal | private-gpu | 10.13 | 2.80 | 11.02 | 11.02 | ok |
| 16.0 MiB | metal | staged-auto | 7.92 | 6.67 | 8.82 | 8.82 | ok |
| 16.0 MiB | metal | staged-gpu | 10.20 | 7.01 | 11.72 | 11.72 | ok |
| 16.0 MiB | metal | wrapped-auto | 8.03 | 3.26 | 10.31 | 10.31 | ok |
| 16.0 MiB | metal | wrapped-gpu | 11.22 | 9.20 | 13.08 | 13.08 | ok |
| 16.0 MiB | metal | e2e-auto | 5.97 | 2.62 | 6.67 | 6.67 | ok |
| 16.0 MiB | metal | e2e-gpu | 5.48 | 2.65 | 6.42 | 6.42 | ok |
| 64.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.77 | 1.76 | 1.81 | 1.81 | ok |
| 64.0 MiB | cpu | parallel | 9.91 | 8.98 | 10.25 | 10.25 | ok |
| 64.0 MiB | official-c | one-shot | 2.19 | 2.16 | 2.19 | 2.19 | ok |
| 64.0 MiB | cpu | context-auto | 9.92 | 9.58 | 10.16 | 10.16 | ok |
| 64.0 MiB | blake3 | default-auto | 17.86 | 13.41 | 33.28 | 33.28 | ok |
| 64.0 MiB | metal | resident-auto | 31.58 | 29.69 | 41.48 | 41.48 | ok |
| 64.0 MiB | metal | resident-gpu | 33.38 | 28.91 | 37.49 | 37.49 | ok |
| 64.0 MiB | metal | private-gpu | 40.52 | 38.17 | 42.07 | 42.07 | ok |
| 64.0 MiB | metal | staged-auto | 12.84 | 10.52 | 17.49 | 17.49 | ok |
| 64.0 MiB | metal | staged-gpu | 13.95 | 11.38 | 16.61 | 16.61 | ok |
| 64.0 MiB | metal | wrapped-auto | 28.31 | 16.93 | 30.69 | 30.69 | ok |
| 64.0 MiB | metal | wrapped-gpu | 30.31 | 27.43 | 33.79 | 33.79 | ok |
| 64.0 MiB | metal | e2e-auto | 7.98 | 7.00 | 9.20 | 9.20 | ok |
| 64.0 MiB | metal | e2e-gpu | 9.31 | 8.90 | 9.44 | 9.44 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.80 | 1.78 | 1.80 | 1.80 | ok |
| 256.0 MiB | cpu | parallel | 10.78 | 10.66 | 10.85 | 10.85 | ok |
| 256.0 MiB | official-c | one-shot | 2.20 | 2.19 | 2.20 | 2.20 | ok |
| 256.0 MiB | cpu | context-auto | 10.61 | 10.27 | 10.79 | 10.79 | ok |
| 256.0 MiB | blake3 | default-auto | 33.21 | 26.20 | 40.95 | 40.95 | ok |
| 256.0 MiB | metal | resident-auto | 39.47 | 34.47 | 48.80 | 48.80 | ok |
| 256.0 MiB | metal | resident-gpu | 51.90 | 36.23 | 60.62 | 60.62 | ok |
| 256.0 MiB | metal | private-gpu | 57.43 | 48.09 | 61.34 | 61.34 | ok |
| 256.0 MiB | metal | staged-auto | 19.84 | 15.59 | 23.10 | 23.10 | ok |
| 256.0 MiB | metal | staged-gpu | 19.91 | 18.45 | 21.62 | 21.62 | ok |
| 256.0 MiB | metal | wrapped-auto | 45.98 | 44.28 | 47.89 | 47.89 | ok |
| 256.0 MiB | metal | wrapped-gpu | 45.50 | 42.28 | 47.07 | 47.07 | ok |
| 256.0 MiB | metal | e2e-auto | 10.90 | 10.40 | 11.38 | 11.38 | ok |
| 256.0 MiB | metal | e2e-gpu | 11.03 | 10.19 | 11.80 | 11.80 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.79 | 1.78 | 1.80 | 1.80 | ok |
| 512.0 MiB | cpu | parallel | 11.12 | 11.11 | 11.25 | 11.25 | ok |
| 512.0 MiB | official-c | one-shot | 2.19 | 2.19 | 2.19 | 2.19 | ok |
| 512.0 MiB | cpu | context-auto | 11.00 | 10.39 | 11.23 | 11.23 | ok |
| 512.0 MiB | blake3 | default-auto | 35.22 | 34.25 | 38.60 | 38.60 | ok |
| 512.0 MiB | metal | resident-auto | 47.23 | 40.09 | 55.30 | 55.30 | ok |
| 512.0 MiB | metal | resident-gpu | 60.80 | 53.03 | 72.84 | 72.84 | ok |
| 512.0 MiB | metal | private-gpu | 64.90 | 56.56 | 73.04 | 73.04 | ok |
| 512.0 MiB | metal | staged-auto | 22.62 | 15.34 | 22.84 | 22.84 | ok |
| 512.0 MiB | metal | staged-gpu | 23.05 | 22.25 | 23.45 | 23.45 | ok |
| 512.0 MiB | metal | wrapped-auto | 51.66 | 47.72 | 53.54 | 53.54 | ok |
| 512.0 MiB | metal | wrapped-gpu | 51.01 | 47.56 | 54.57 | 54.57 | ok |
| 512.0 MiB | metal | e2e-auto | 9.99 | 9.39 | 10.21 | 10.21 | ok |
| 512.0 MiB | metal | e2e-gpu | 6.31 | 0.58 | 7.33 | 7.33 | ok |
| 1.0 GiB | cpu | scalar | 1.16 | 1.12 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.80 | 1.79 | 1.80 | 1.80 | ok |
| 1.0 GiB | cpu | parallel | 11.52 | 10.91 | 11.61 | 11.61 | ok |
| 1.0 GiB | official-c | one-shot | 2.19 | 2.17 | 2.19 | 2.19 | ok |
| 1.0 GiB | cpu | context-auto | 11.58 | 11.39 | 11.77 | 11.77 | ok |
| 1.0 GiB | blake3 | default-auto | 41.87 | 40.72 | 45.10 | 45.10 | ok |
| 1.0 GiB | metal | resident-auto | 56.67 | 53.64 | 60.74 | 60.74 | ok |
| 1.0 GiB | metal | resident-gpu | 63.15 | 60.89 | 74.69 | 74.69 | ok |
| 1.0 GiB | metal | private-gpu | 59.21 | 54.34 | 62.30 | 62.30 | ok |
| 1.0 GiB | metal | staged-auto | 23.88 | 16.67 | 24.84 | 24.84 | ok |
| 1.0 GiB | metal | staged-gpu | 23.95 | 23.41 | 24.45 | 24.45 | ok |
| 1.0 GiB | metal | wrapped-auto | 40.64 | 39.38 | 42.24 | 42.24 | ok |
| 1.0 GiB | metal | wrapped-gpu | 34.00 | 22.49 | 34.64 | 34.64 | ok |
| 1.0 GiB | metal | e2e-auto | 4.78 | 4.55 | 6.68 | 6.68 | ok |
| 1.0 GiB | metal | e2e-gpu | 2.22 | 1.94 | 3.88 | 3.88 | ok |
jsonOutput=benchmarks/results/20260419T-readme-flatkernels-current/cpu-metal-publication.json
