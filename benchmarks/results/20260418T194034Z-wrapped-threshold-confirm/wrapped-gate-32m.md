BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=wrapped
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
sizes=4.0 MiB, 8.0 MiB, 12.0 MiB, 16.0 MiB, 24.0 MiB, 32.0 MiB, 64.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 4.0 MiB | cpu | scalar | 1.10 | 1.08 | 1.11 | 1.11 | ok |
| 4.0 MiB | cpu | single-simd | 1.77 | 1.73 | 1.83 | 1.83 | ok |
| 4.0 MiB | cpu | parallel | 6.78 | 5.88 | 7.11 | 7.11 | ok |
| 4.0 MiB | official-c | one-shot | 2.21 | 2.13 | 2.30 | 2.30 | ok |
| 4.0 MiB | cpu | context-auto | 6.84 | 6.27 | 7.20 | 7.20 | ok |
| 4.0 MiB | blake3 | default-auto | 6.37 | 6.12 | 7.06 | 7.06 | ok |
| 4.0 MiB | metal | wrapped-auto | 6.75 | 6.05 | 6.98 | 6.98 | ok |
| 4.0 MiB | metal | wrapped-gpu | 4.18 | 0.64 | 5.06 | 5.06 | ok |
| 8.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.11 | 1.11 | ok |
| 8.0 MiB | cpu | single-simd | 1.80 | 1.77 | 1.85 | 1.85 | ok |
| 8.0 MiB | cpu | parallel | 8.05 | 7.17 | 8.26 | 8.26 | ok |
| 8.0 MiB | official-c | one-shot | 2.18 | 2.07 | 2.20 | 2.20 | ok |
| 8.0 MiB | cpu | context-auto | 8.06 | 6.90 | 8.31 | 8.31 | ok |
| 8.0 MiB | blake3 | default-auto | 8.01 | 6.98 | 8.22 | 8.22 | ok |
| 8.0 MiB | metal | wrapped-auto | 8.02 | 6.92 | 8.22 | 8.22 | ok |
| 8.0 MiB | metal | wrapped-gpu | 5.84 | 1.34 | 6.84 | 6.84 | ok |
| 12.0 MiB | cpu | scalar | 1.10 | 1.08 | 1.10 | 1.10 | ok |
| 12.0 MiB | cpu | single-simd | 1.79 | 1.75 | 1.84 | 1.84 | ok |
| 12.0 MiB | cpu | parallel | 8.24 | 7.18 | 8.51 | 8.51 | ok |
| 12.0 MiB | official-c | one-shot | 2.19 | 2.15 | 2.23 | 2.23 | ok |
| 12.0 MiB | cpu | context-auto | 7.32 | 6.26 | 8.47 | 8.47 | ok |
| 12.0 MiB | blake3 | default-auto | 8.27 | 7.14 | 8.50 | 8.50 | ok |
| 12.0 MiB | metal | wrapped-auto | 8.02 | 6.89 | 8.39 | 8.39 | ok |
| 12.0 MiB | metal | wrapped-gpu | 8.33 | 1.69 | 10.19 | 10.19 | ok |
| 16.0 MiB | cpu | scalar | 1.09 | 0.65 | 1.10 | 1.10 | ok |
| 16.0 MiB | cpu | single-simd | 1.77 | 1.75 | 1.83 | 1.83 | ok |
| 16.0 MiB | cpu | parallel | 9.16 | 7.68 | 9.34 | 9.34 | ok |
| 16.0 MiB | official-c | one-shot | 2.19 | 2.15 | 2.22 | 2.22 | ok |
| 16.0 MiB | cpu | context-auto | 9.04 | 6.90 | 9.25 | 9.25 | ok |
| 16.0 MiB | blake3 | default-auto | 8.99 | 7.74 | 9.20 | 9.20 | ok |
| 16.0 MiB | metal | wrapped-auto | 8.98 | 7.35 | 9.29 | 9.29 | ok |
| 16.0 MiB | metal | wrapped-gpu | 14.50 | 2.22 | 23.61 | 23.61 | ok |
| 24.0 MiB | cpu | scalar | 1.09 | 1.03 | 1.10 | 1.10 | ok |
| 24.0 MiB | cpu | single-simd | 1.62 | 1.22 | 1.74 | 1.74 | ok |
| 24.0 MiB | cpu | parallel | 7.05 | 3.91 | 8.64 | 8.64 | ok |
| 24.0 MiB | official-c | one-shot | 2.11 | 2.03 | 2.16 | 2.16 | ok |
| 24.0 MiB | cpu | context-auto | 7.68 | 6.58 | 8.34 | 8.34 | ok |
| 24.0 MiB | blake3 | default-auto | 7.43 | 5.73 | 8.59 | 8.59 | ok |
| 24.0 MiB | metal | wrapped-auto | 7.47 | 6.11 | 8.70 | 8.70 | ok |
| 24.0 MiB | metal | wrapped-gpu | 21.68 | 4.33 | 23.95 | 23.95 | ok |
| 32.0 MiB | cpu | scalar | 1.07 | 1.03 | 1.08 | 1.08 | ok |
| 32.0 MiB | cpu | single-simd | 1.76 | 1.73 | 1.77 | 1.77 | ok |
| 32.0 MiB | cpu | parallel | 9.31 | 8.01 | 9.90 | 9.90 | ok |
| 32.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.19 | 2.19 | ok |
| 32.0 MiB | cpu | context-auto | 9.57 | 8.08 | 9.91 | 9.91 | ok |
| 32.0 MiB | blake3 | default-auto | 23.68 | 4.88 | 26.52 | 26.52 | ok |
| 32.0 MiB | metal | wrapped-auto | 22.71 | 10.41 | 25.39 | 25.39 | ok |
| 32.0 MiB | metal | wrapped-gpu | 22.44 | 9.95 | 25.07 | 25.07 | ok |
| 64.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.79 | 1.79 | ok |
| 64.0 MiB | cpu | parallel | 9.44 | 7.89 | 10.31 | 10.31 | ok |
| 64.0 MiB | official-c | one-shot | 2.19 | 2.17 | 2.19 | 2.19 | ok |
| 64.0 MiB | cpu | context-auto | 9.49 | 8.11 | 10.34 | 10.34 | ok |
| 64.0 MiB | blake3 | default-auto | 28.78 | 9.12 | 30.98 | 30.98 | ok |
| 64.0 MiB | metal | wrapped-auto | 27.92 | 15.74 | 29.83 | 29.83 | ok |
| 64.0 MiB | metal | wrapped-gpu | 23.60 | 15.63 | 28.91 | 28.91 | ok |
jsonOutput=benchmarks/results/20260418T194034Z-wrapped-threshold-confirm/wrapped-gate-32m.json
