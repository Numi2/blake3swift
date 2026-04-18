BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=8388608
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=8388608
metalTileByteCount=16777216
metalModes=wrapped
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
sizes=4.0 MiB, 8.0 MiB, 12.0 MiB, 16.0 MiB, 24.0 MiB, 32.0 MiB, 64.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 4.0 MiB | cpu | scalar | 1.13 | 1.11 | 1.19 | 1.19 | ok |
| 4.0 MiB | cpu | single-simd | 1.92 | 1.77 | 1.94 | 1.94 | ok |
| 4.0 MiB | cpu | parallel | 6.84 | 6.43 | 7.22 | 7.22 | ok |
| 4.0 MiB | official-c | one-shot | 2.38 | 2.23 | 2.40 | 2.40 | ok |
| 4.0 MiB | cpu | context-auto | 7.00 | 6.30 | 7.23 | 7.23 | ok |
| 4.0 MiB | blake3 | default-auto | 6.63 | 6.06 | 7.18 | 7.18 | ok |
| 4.0 MiB | metal | wrapped-auto | 6.48 | 6.09 | 7.13 | 7.13 | ok |
| 4.0 MiB | metal | wrapped-gpu | 3.92 | 0.76 | 4.98 | 4.98 | ok |
| 8.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.17 | 1.17 | ok |
| 8.0 MiB | cpu | single-simd | 1.91 | 1.80 | 1.94 | 1.94 | ok |
| 8.0 MiB | cpu | parallel | 8.11 | 7.01 | 8.27 | 8.27 | ok |
| 8.0 MiB | official-c | one-shot | 2.34 | 2.24 | 2.40 | 2.40 | ok |
| 8.0 MiB | cpu | context-auto | 8.14 | 7.22 | 8.46 | 8.46 | ok |
| 8.0 MiB | blake3 | default-auto | 6.04 | 1.40 | 7.12 | 7.12 | ok |
| 8.0 MiB | metal | wrapped-auto | 15.86 | 3.92 | 17.79 | 17.79 | ok |
| 8.0 MiB | metal | wrapped-gpu | 15.18 | 7.30 | 16.08 | 16.08 | ok |
| 12.0 MiB | cpu | scalar | 1.11 | 1.09 | 1.13 | 1.13 | ok |
| 12.0 MiB | cpu | single-simd | 1.89 | 1.83 | 1.94 | 1.94 | ok |
| 12.0 MiB | cpu | parallel | 8.32 | 7.36 | 8.62 | 8.62 | ok |
| 12.0 MiB | official-c | one-shot | 2.31 | 2.22 | 2.36 | 2.36 | ok |
| 12.0 MiB | cpu | context-auto | 8.39 | 7.24 | 8.56 | 8.56 | ok |
| 12.0 MiB | blake3 | default-auto | 7.91 | 2.07 | 21.98 | 21.98 | ok |
| 12.0 MiB | metal | wrapped-auto | 16.49 | 5.83 | 20.49 | 20.49 | ok |
| 12.0 MiB | metal | wrapped-gpu | 19.03 | 5.68 | 20.81 | 20.81 | ok |
| 16.0 MiB | cpu | scalar | 1.11 | 1.10 | 1.13 | 1.13 | ok |
| 16.0 MiB | cpu | single-simd | 1.85 | 1.77 | 1.94 | 1.94 | ok |
| 16.0 MiB | cpu | parallel | 9.03 | 7.75 | 9.31 | 9.31 | ok |
| 16.0 MiB | official-c | one-shot | 2.24 | 2.20 | 2.32 | 2.32 | ok |
| 16.0 MiB | cpu | context-auto | 8.90 | 7.79 | 9.35 | 9.35 | ok |
| 16.0 MiB | blake3 | default-auto | 9.30 | 2.58 | 17.01 | 17.01 | ok |
| 16.0 MiB | metal | wrapped-auto | 14.66 | 5.37 | 17.13 | 17.13 | ok |
| 16.0 MiB | metal | wrapped-gpu | 16.49 | 6.81 | 19.34 | 19.34 | ok |
| 24.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.11 | 1.11 | ok |
| 24.0 MiB | cpu | single-simd | 1.84 | 1.80 | 1.89 | 1.89 | ok |
| 24.0 MiB | cpu | parallel | 9.18 | 7.69 | 9.52 | 9.52 | ok |
| 24.0 MiB | official-c | one-shot | 2.26 | 2.22 | 2.31 | 2.31 | ok |
| 24.0 MiB | cpu | context-auto | 9.29 | 7.60 | 9.57 | 9.57 | ok |
| 24.0 MiB | blake3 | default-auto | 20.92 | 3.28 | 29.71 | 29.71 | ok |
| 24.0 MiB | metal | wrapped-auto | 22.90 | 11.05 | 27.44 | 27.44 | ok |
| 24.0 MiB | metal | wrapped-gpu | 25.03 | 12.52 | 27.52 | 27.52 | ok |
| 32.0 MiB | cpu | scalar | 1.11 | 1.08 | 1.11 | 1.11 | ok |
| 32.0 MiB | cpu | single-simd | 1.85 | 1.81 | 1.88 | 1.88 | ok |
| 32.0 MiB | cpu | parallel | 9.19 | 8.08 | 9.90 | 9.90 | ok |
| 32.0 MiB | official-c | one-shot | 2.25 | 2.22 | 2.28 | 2.28 | ok |
| 32.0 MiB | cpu | context-auto | 9.45 | 8.14 | 10.00 | 10.00 | ok |
| 32.0 MiB | blake3 | default-auto | 12.64 | 4.08 | 31.06 | 31.06 | ok |
| 32.0 MiB | metal | wrapped-auto | 27.53 | 17.82 | 31.04 | 31.04 | ok |
| 32.0 MiB | metal | wrapped-gpu | 27.71 | 16.39 | 32.04 | 32.04 | ok |
| 64.0 MiB | cpu | scalar | 1.10 | 1.10 | 1.11 | 1.11 | ok |
| 64.0 MiB | cpu | single-simd | 1.84 | 1.79 | 1.86 | 1.86 | ok |
| 64.0 MiB | cpu | parallel | 10.12 | 8.37 | 10.44 | 10.44 | ok |
| 64.0 MiB | official-c | one-shot | 2.21 | 1.49 | 2.25 | 2.25 | ok |
| 64.0 MiB | cpu | context-auto | 9.80 | 7.97 | 10.32 | 10.32 | ok |
| 64.0 MiB | blake3 | default-auto | 30.51 | 12.30 | 32.01 | 32.01 | ok |
| 64.0 MiB | metal | wrapped-auto | 27.45 | 18.85 | 31.33 | 31.33 | ok |
| 64.0 MiB | metal | wrapped-gpu | 27.00 | 15.17 | 29.21 | 29.21 | ok |
jsonOutput=benchmarks/results/20260418T194034Z-wrapped-threshold-confirm/wrapped-gate-8m.json
