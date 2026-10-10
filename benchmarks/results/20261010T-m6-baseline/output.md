BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=resident,staged,wrapped,e2e
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-staged includes: pre-created shared staging MTLBuffer; timed Swift-byte copy into staging buffer plus hash
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.35 | 1.24 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.13 | 2.13 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.94 | 12.42 | 14.06 | 14.06 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 13.89 | 13.07 | 14.14 | 14.14 | ok |
| 16.0 MiB | blake3 | default-auto | 19.10 | 18.46 | 20.16 | 20.16 | ok |
| 16.0 MiB | metal | resident-auto | 23.42 | 23.28 | 24.35 | 24.35 | ok |
| 16.0 MiB | metal | resident-gpu | 24.31 | 22.99 | 25.07 | 25.07 | ok |
| 16.0 MiB | metal | staged-auto | 17.43 | 16.35 | 17.87 | 17.87 | ok |
| 16.0 MiB | metal | staged-gpu | 17.54 | 16.95 | 17.89 | 17.89 | ok |
| 16.0 MiB | metal | wrapped-auto | 19.48 | 17.92 | 21.11 | 21.11 | ok |
| 16.0 MiB | metal | wrapped-gpu | 18.47 | 18.02 | 19.38 | 19.38 | ok |
| 16.0 MiB | metal | e2e-auto | 15.66 | 15.60 | 16.01 | 16.01 | ok |
| 16.0 MiB | metal | e2e-gpu | 16.23 | 15.90 | 17.47 | 17.47 | ok |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 16.52 | 16.00 | 16.60 | 16.60 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 16.42 | 15.73 | 16.57 | 16.57 | ok |
| 64.0 MiB | blake3 | default-auto | 47.59 | 45.53 | 49.83 | 49.83 | ok |
| 64.0 MiB | metal | resident-auto | 74.77 | 72.00 | 80.95 | 80.95 | ok |
| 64.0 MiB | metal | resident-gpu | 75.15 | 71.93 | 77.03 | 77.03 | ok |
| 64.0 MiB | metal | staged-auto | 31.88 | 30.95 | 32.23 | 32.23 | ok |
| 64.0 MiB | metal | staged-gpu | 32.29 | 31.05 | 32.82 | 32.82 | ok |
| 64.0 MiB | metal | wrapped-auto | 46.59 | 44.09 | 56.51 | 56.51 | ok |
| 64.0 MiB | metal | wrapped-gpu | 46.02 | 44.40 | 46.49 | 46.49 | ok |
| 64.0 MiB | metal | e2e-auto | 25.97 | 24.84 | 26.30 | 26.30 | ok |
| 64.0 MiB | metal | e2e-gpu | 25.81 | 24.47 | 27.19 | 27.19 | ok |
| 256.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel | 17.19 | 16.47 | 17.44 | 17.44 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.35 | 16.68 | 17.40 | 17.40 | ok |
| 256.0 MiB | blake3 | default-auto | 56.31 | 54.72 | 57.53 | 57.53 | ok |
| 256.0 MiB | metal | resident-auto | 88.09 | 87.41 | 89.07 | 89.07 | ok |
| 256.0 MiB | metal | resident-gpu | 89.02 | 87.87 | 89.12 | 89.12 | ok |
| 256.0 MiB | metal | staged-auto | 33.37 | 31.71 | 33.40 | 33.40 | ok |
| 256.0 MiB | metal | staged-gpu | 33.25 | 32.88 | 33.45 | 33.45 | ok |
| 256.0 MiB | metal | wrapped-auto | 56.16 | 55.11 | 64.16 | 64.16 | ok |
| 256.0 MiB | metal | wrapped-gpu | 57.34 | 52.95 | 57.70 | 57.70 | ok |
| 256.0 MiB | metal | e2e-auto | 28.69 | 28.24 | 29.68 | 29.68 | ok |
| 256.0 MiB | metal | e2e-gpu | 29.70 | 29.12 | 30.02 | 30.02 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.26 | 16.87 | 17.27 | 17.27 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.22 | 17.18 | 17.49 | 17.49 | ok |
| 1.0 GiB | blake3 | default-auto | 64.40 | 48.99 | 67.09 | 67.09 | ok |
| 1.0 GiB | metal | resident-auto | 102.93 | 101.05 | 105.20 | 105.20 | ok |
| 1.0 GiB | metal | resident-gpu | 104.00 | 102.93 | 105.18 | 105.18 | ok |
| 1.0 GiB | metal | staged-auto | 34.19 | 33.98 | 34.44 | 34.44 | ok |
| 1.0 GiB | metal | staged-gpu | 34.07 | 33.74 | 34.54 | 34.54 | ok |
| 1.0 GiB | metal | wrapped-auto | 66.76 | 61.36 | 70.33 | 70.33 | ok |
| 1.0 GiB | metal | wrapped-gpu | 66.81 | 61.39 | 70.41 | 70.41 | ok |
| 1.0 GiB | metal | e2e-auto | 28.46 | 27.26 | 28.82 | 28.82 | ok |
| 1.0 GiB | metal | e2e-gpu | 28.34 | 28.20 | 28.49 | 28.49 | ok |
jsonOutput=benchmarks/results/20261010T-m6-baseline/report.json
