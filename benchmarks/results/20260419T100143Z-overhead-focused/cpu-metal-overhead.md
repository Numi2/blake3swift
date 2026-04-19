BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=67108864
metalModes=resident,staged,wrapped,e2e
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-staged includes: pre-created shared staging MTLBuffer; timed Swift-byte copy into staging buffer plus hash
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
sizes=256.0 MiB, 512.0 MiB, 1.0 GiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.12 | 1.01 | 1.13 | 1.13 | ok |
| 256.0 MiB | cpu | single-simd | 1.87 | 1.86 | 1.89 | 1.89 | ok |
| 256.0 MiB | cpu | parallel | 10.58 | 10.23 | 11.03 | 11.03 | ok |
| 256.0 MiB | official-c | one-shot | 2.28 | 2.27 | 2.30 | 2.30 | ok |
| 256.0 MiB | cpu | context-auto | 10.39 | 10.36 | 10.92 | 10.92 | ok |
| 256.0 MiB | blake3 | default-auto | 42.96 | 33.69 | 54.46 | 54.46 | ok |
| 256.0 MiB | metal | resident-auto | 68.69 | 56.90 | 78.57 | 78.57 | ok |
| 256.0 MiB | metal | resident-gpu | 68.26 | 56.69 | 75.71 | 75.71 | ok |
| 256.0 MiB | metal | staged-auto | 24.47 | 20.52 | 26.04 | 26.04 | ok |
| 256.0 MiB | metal | staged-gpu | 24.08 | 22.97 | 24.77 | 24.77 | ok |
| 256.0 MiB | metal | wrapped-auto | 55.27 | 50.22 | 56.29 | 56.29 | ok |
| 256.0 MiB | metal | wrapped-gpu | 55.62 | 44.57 | 56.33 | 56.33 | ok |
| 256.0 MiB | metal | e2e-auto | 13.00 | 11.69 | 13.62 | 13.62 | ok |
| 256.0 MiB | metal | e2e-gpu | 12.81 | 12.12 | 13.02 | 13.02 | ok |
| 512.0 MiB | cpu | scalar | 1.11 | 1.11 | 1.11 | 1.11 | ok |
| 512.0 MiB | cpu | single-simd | 1.85 | 1.85 | 1.85 | 1.85 | ok |
| 512.0 MiB | cpu | parallel | 11.18 | 10.36 | 11.50 | 11.50 | ok |
| 512.0 MiB | official-c | one-shot | 2.24 | 2.23 | 2.25 | 2.25 | ok |
| 512.0 MiB | cpu | context-auto | 10.65 | 10.22 | 11.30 | 11.30 | ok |
| 512.0 MiB | blake3 | default-auto | 51.09 | 49.01 | 57.67 | 57.67 | ok |
| 512.0 MiB | metal | resident-auto | 76.18 | 63.71 | 83.67 | 83.67 | ok |
| 512.0 MiB | metal | resident-gpu | 80.53 | 69.72 | 84.23 | 84.23 | ok |
| 512.0 MiB | metal | staged-auto | 25.13 | 18.97 | 26.73 | 26.73 | ok |
| 512.0 MiB | metal | staged-gpu | 25.84 | 24.73 | 26.52 | 26.52 | ok |
| 512.0 MiB | metal | wrapped-auto | 51.17 | 48.36 | 57.61 | 57.61 | ok |
| 512.0 MiB | metal | wrapped-gpu | 55.19 | 48.21 | 56.43 | 56.43 | ok |
| 512.0 MiB | metal | e2e-auto | 13.37 | 12.59 | 13.48 | 13.48 | ok |
| 512.0 MiB | metal | e2e-gpu | 12.34 | 10.75 | 13.06 | 13.06 | ok |
| 1.0 GiB | cpu | scalar | 1.10 | 1.10 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.82 | 1.76 | 1.82 | 1.82 | ok |
| 1.0 GiB | cpu | parallel | 11.33 | 11.03 | 11.52 | 11.52 | ok |
| 1.0 GiB | official-c | one-shot | 2.20 | 2.09 | 2.21 | 2.21 | ok |
| 1.0 GiB | cpu | context-auto | 11.29 | 11.25 | 11.48 | 11.48 | ok |
| 1.0 GiB | blake3 | default-auto | 54.18 | 51.12 | 58.46 | 58.46 | ok |
| 1.0 GiB | metal | resident-auto | 75.24 | 71.34 | 82.84 | 82.84 | ok |
| 1.0 GiB | metal | resident-gpu | 76.80 | 70.01 | 77.59 | 77.59 | ok |
| 1.0 GiB | metal | staged-auto | 26.09 | 19.19 | 26.99 | 26.99 | ok |
| 1.0 GiB | metal | staged-gpu | 24.76 | 23.71 | 26.37 | 26.37 | ok |
| 1.0 GiB | metal | wrapped-auto | 54.63 | 53.15 | 54.85 | 54.85 | ok |
| 1.0 GiB | metal | wrapped-gpu | 54.05 | 49.52 | 54.70 | 54.70 | ok |
| 1.0 GiB | metal | e2e-auto | 3.31 | 0.39 | 5.62 | 5.62 | ok |
| 1.0 GiB | metal | e2e-gpu | 2.06 | 1.36 | 2.85 | 2.85 | ok |
jsonOutput=benchmarks/results/20260419T100143Z-overhead-focused/cpu-metal-overhead.json
