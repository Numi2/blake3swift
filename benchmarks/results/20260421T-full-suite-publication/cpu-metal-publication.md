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
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.16 | 1.14 | 1.19 | 1.19 | ok |
| 16.0 MiB | cpu | single-simd | 1.88 | 1.82 | 1.92 | 1.92 | ok |
| 16.0 MiB | cpu | parallel | 9.90 | 8.40 | 10.04 | 10.04 | ok |
| 16.0 MiB | official-c | one-shot | 2.34 | 2.23 | 2.38 | 2.38 | ok |
| 16.0 MiB | cpu | context-auto | 10.00 | 8.59 | 10.48 | 10.48 | ok |
| 16.0 MiB | blake3 | default-auto | 15.41 | 6.45 | 20.52 | 20.52 | ok |
| 16.0 MiB | metal | resident-auto | 20.46 | 2.82 | 27.03 | 27.03 | ok |
| 16.0 MiB | metal | resident-gpu | 21.24 | 5.85 | 25.82 | 25.82 | ok |
| 16.0 MiB | metal | private-gpu | 21.97 | 14.77 | 25.50 | 25.50 | ok |
| 16.0 MiB | metal | staged-auto | 11.63 | 2.77 | 15.73 | 15.73 | ok |
| 16.0 MiB | metal | staged-gpu | 11.13 | 2.73 | 15.84 | 15.84 | ok |
| 16.0 MiB | metal | wrapped-auto | 17.06 | 13.23 | 19.70 | 19.70 | ok |
| 16.0 MiB | metal | wrapped-gpu | 16.87 | 7.40 | 18.91 | 18.91 | ok |
| 16.0 MiB | metal | e2e-auto | 11.12 | 3.21 | 12.72 | 12.72 | ok |
| 16.0 MiB | metal | e2e-gpu | 11.11 | 2.57 | 13.18 | 13.18 | ok |
| 64.0 MiB | cpu | scalar | 1.19 | 1.16 | 1.20 | 1.20 | ok |
| 64.0 MiB | cpu | single-simd | 1.87 | 1.85 | 1.88 | 1.88 | ok |
| 64.0 MiB | cpu | parallel | 10.97 | 10.79 | 11.42 | 11.42 | ok |
| 64.0 MiB | official-c | one-shot | 2.25 | 2.23 | 2.29 | 2.29 | ok |
| 64.0 MiB | cpu | context-auto | 11.04 | 10.54 | 11.59 | 11.59 | ok |
| 64.0 MiB | blake3 | default-auto | 27.56 | 10.69 | 37.04 | 37.04 | ok |
| 64.0 MiB | metal | resident-auto | 32.46 | 12.62 | 53.40 | 53.40 | ok |
| 64.0 MiB | metal | resident-gpu | 36.89 | 12.03 | 54.32 | 54.32 | ok |
| 64.0 MiB | metal | private-gpu | 24.34 | 9.21 | 54.19 | 54.19 | ok |
| 64.0 MiB | metal | staged-auto | 14.79 | 7.49 | 20.62 | 20.62 | ok |
| 64.0 MiB | metal | staged-gpu | 16.42 | 8.56 | 20.47 | 20.47 | ok |
| 64.0 MiB | metal | wrapped-auto | 24.15 | 10.34 | 36.02 | 36.02 | ok |
| 64.0 MiB | metal | wrapped-gpu | 18.22 | 9.00 | 35.74 | 35.74 | ok |
| 64.0 MiB | metal | e2e-auto | 13.22 | 7.28 | 16.86 | 16.86 | ok |
| 64.0 MiB | metal | e2e-gpu | 13.28 | 6.71 | 18.51 | 18.51 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.00 | 1.17 | 1.17 | ok |
| 256.0 MiB | cpu | single-simd | 1.82 | 1.80 | 1.84 | 1.84 | ok |
| 256.0 MiB | cpu | parallel | 11.48 | 11.26 | 11.70 | 11.70 | ok |
| 256.0 MiB | official-c | one-shot | 2.23 | 2.20 | 2.24 | 2.24 | ok |
| 256.0 MiB | cpu | context-auto | 11.53 | 11.40 | 11.71 | 11.71 | ok |
| 256.0 MiB | blake3 | default-auto | 34.55 | 24.21 | 42.55 | 42.55 | ok |
| 256.0 MiB | metal | resident-auto | 61.91 | 22.15 | 74.41 | 74.41 | ok |
| 256.0 MiB | metal | resident-gpu | 42.58 | 31.54 | 76.85 | 76.85 | ok |
| 256.0 MiB | metal | private-gpu | 53.47 | 29.10 | 67.14 | 67.14 | ok |
| 256.0 MiB | metal | staged-auto | 20.73 | 15.49 | 21.43 | 21.43 | ok |
| 256.0 MiB | metal | staged-gpu | 20.94 | 14.73 | 22.08 | 22.08 | ok |
| 256.0 MiB | metal | wrapped-auto | 26.06 | 23.50 | 38.65 | 38.65 | ok |
| 256.0 MiB | metal | wrapped-gpu | 40.36 | 22.77 | 43.89 | 43.89 | ok |
| 256.0 MiB | metal | e2e-auto | 15.43 | 14.78 | 18.37 | 18.37 | ok |
| 256.0 MiB | metal | e2e-gpu | 16.37 | 15.09 | 18.23 | 18.23 | ok |
| 512.0 MiB | cpu | scalar | 1.15 | 1.09 | 1.15 | 1.15 | ok |
| 512.0 MiB | cpu | single-simd | 1.76 | 1.66 | 1.81 | 1.81 | ok |
| 512.0 MiB | cpu | parallel | 11.11 | 10.65 | 11.71 | 11.71 | ok |
| 512.0 MiB | official-c | one-shot | 2.10 | 1.15 | 2.16 | 2.16 | ok |
| 512.0 MiB | cpu | context-auto | 11.44 | 11.13 | 11.66 | 11.66 | ok |
| 512.0 MiB | blake3 | default-auto | 37.15 | 32.84 | 43.71 | 43.71 | ok |
| 512.0 MiB | metal | resident-auto | 63.23 | 47.08 | 75.02 | 75.02 | ok |
| 512.0 MiB | metal | resident-gpu | 65.63 | 60.84 | 68.90 | 68.90 | ok |
| 512.0 MiB | metal | private-gpu | 59.09 | 46.44 | 64.35 | 64.35 | ok |
| 512.0 MiB | metal | staged-auto | 22.37 | 17.39 | 22.88 | 22.88 | ok |
| 512.0 MiB | metal | staged-gpu | 20.60 | 18.76 | 23.60 | 23.60 | ok |
| 512.0 MiB | metal | wrapped-auto | 37.51 | 30.99 | 44.74 | 44.74 | ok |
| 512.0 MiB | metal | wrapped-gpu | 37.52 | 35.49 | 45.79 | 45.79 | ok |
| 512.0 MiB | metal | e2e-auto | 18.81 | 17.25 | 19.23 | 19.23 | ok |
| 512.0 MiB | metal | e2e-gpu | 18.66 | 18.16 | 18.86 | 18.86 | ok |
| 1.0 GiB | cpu | scalar | 1.11 | 1.10 | 1.13 | 1.13 | ok |
| 1.0 GiB | cpu | single-simd | 1.66 | 1.63 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 10.44 | 9.01 | 11.13 | 11.13 | ok |
| 1.0 GiB | official-c | one-shot | 2.09 | 1.68 | 2.13 | 2.13 | ok |
| 1.0 GiB | cpu | context-auto | 11.20 | 9.78 | 11.61 | 11.61 | ok |
| 1.0 GiB | blake3 | default-auto | 32.75 | 27.84 | 39.35 | 39.35 | ok |
| 1.0 GiB | metal | resident-auto | 65.21 | 61.70 | 75.47 | 75.47 | ok |
| 1.0 GiB | metal | resident-gpu | 63.78 | 56.63 | 67.65 | 67.65 | ok |
| 1.0 GiB | metal | private-gpu | 59.22 | 52.45 | 64.13 | 64.13 | ok |
| 1.0 GiB | metal | staged-auto | 19.83 | 16.36 | 21.87 | 21.87 | ok |
| 1.0 GiB | metal | staged-gpu | 21.39 | 18.80 | 23.93 | 23.93 | ok |
| 1.0 GiB | metal | wrapped-auto | 35.77 | 29.05 | 41.42 | 41.42 | ok |
| 1.0 GiB | metal | wrapped-gpu | 33.89 | 29.29 | 36.95 | 36.95 | ok |
| 1.0 GiB | metal | e2e-auto | 15.47 | 10.73 | 17.60 | 17.60 | ok |
| 1.0 GiB | metal | e2e-gpu | 16.28 | 14.74 | 17.80 | 17.80 | ok |
jsonOutput=benchmarks/results/20260421T-full-suite-publication/cpu-metal-publication.json
