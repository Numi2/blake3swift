BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=16777216
metalModes=wrapped
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
sizes=4.0 MiB, 8.0 MiB, 12.0 MiB, 16.0 MiB, 24.0 MiB, 32.0 MiB, 64.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 4.0 MiB | cpu | scalar | 1.10 | 1.07 | 1.11 | 1.11 | ok |
| 4.0 MiB | cpu | single-simd | 1.80 | 1.72 | 1.84 | 1.84 | ok |
| 4.0 MiB | cpu | parallel | 6.86 | 6.38 | 7.13 | 7.13 | ok |
| 4.0 MiB | official-c | one-shot | 2.21 | 2.14 | 2.28 | 2.28 | ok |
| 4.0 MiB | cpu | context-auto | 6.35 | 5.59 | 7.25 | 7.25 | ok |
| 4.0 MiB | blake3 | default-auto | 6.79 | 6.32 | 7.24 | 7.24 | ok |
| 4.0 MiB | metal | wrapped-auto | 6.86 | 6.29 | 7.10 | 7.10 | ok |
| 4.0 MiB | metal | wrapped-gpu | 3.92 | 0.64 | 5.02 | 5.02 | ok |
| 8.0 MiB | cpu | scalar | 1.10 | 1.08 | 1.11 | 1.11 | ok |
| 8.0 MiB | cpu | single-simd | 1.82 | 1.72 | 1.88 | 1.88 | ok |
| 8.0 MiB | cpu | parallel | 8.05 | 5.96 | 8.32 | 8.32 | ok |
| 8.0 MiB | official-c | one-shot | 2.23 | 2.12 | 2.28 | 2.28 | ok |
| 8.0 MiB | cpu | context-auto | 7.87 | 6.94 | 8.35 | 8.35 | ok |
| 8.0 MiB | blake3 | default-auto | 8.11 | 7.25 | 8.30 | 8.30 | ok |
| 8.0 MiB | metal | wrapped-auto | 7.71 | 5.68 | 8.27 | 8.27 | ok |
| 8.0 MiB | metal | wrapped-gpu | 6.28 | 1.16 | 7.02 | 7.02 | ok |
| 12.0 MiB | cpu | scalar | 1.10 | 1.08 | 1.11 | 1.11 | ok |
| 12.0 MiB | cpu | single-simd | 1.80 | 1.77 | 1.88 | 1.88 | ok |
| 12.0 MiB | cpu | parallel | 8.36 | 6.98 | 8.56 | 8.56 | ok |
| 12.0 MiB | official-c | one-shot | 2.21 | 2.13 | 2.32 | 2.32 | ok |
| 12.0 MiB | cpu | context-auto | 7.72 | 6.41 | 8.67 | 8.67 | ok |
| 12.0 MiB | blake3 | default-auto | 8.16 | 7.20 | 8.39 | 8.39 | ok |
| 12.0 MiB | metal | wrapped-auto | 8.25 | 6.85 | 8.41 | 8.41 | ok |
| 12.0 MiB | metal | wrapped-gpu | 8.10 | 1.82 | 10.86 | 10.86 | ok |
| 16.0 MiB | cpu | scalar | 1.10 | 1.08 | 1.11 | 1.11 | ok |
| 16.0 MiB | cpu | single-simd | 1.80 | 1.75 | 1.85 | 1.85 | ok |
| 16.0 MiB | cpu | parallel | 9.01 | 7.24 | 9.32 | 9.32 | ok |
| 16.0 MiB | official-c | one-shot | 2.21 | 2.14 | 2.27 | 2.27 | ok |
| 16.0 MiB | cpu | context-auto | 8.62 | 7.30 | 9.31 | 9.31 | ok |
| 16.0 MiB | blake3 | default-auto | 8.88 | 2.09 | 19.42 | 19.42 | ok |
| 16.0 MiB | metal | wrapped-auto | 16.39 | 6.68 | 19.73 | 19.73 | ok |
| 16.0 MiB | metal | wrapped-gpu | 15.51 | 6.87 | 18.34 | 18.34 | ok |
| 24.0 MiB | cpu | scalar | 1.10 | 1.10 | 1.11 | 1.11 | ok |
| 24.0 MiB | cpu | single-simd | 1.80 | 1.78 | 1.87 | 1.87 | ok |
| 24.0 MiB | cpu | parallel | 9.34 | 7.74 | 9.57 | 9.57 | ok |
| 24.0 MiB | official-c | one-shot | 2.20 | 2.18 | 2.25 | 2.25 | ok |
| 24.0 MiB | cpu | context-auto | 9.30 | 7.69 | 9.47 | 9.47 | ok |
| 24.0 MiB | blake3 | default-auto | 13.34 | 3.46 | 26.85 | 26.85 | ok |
| 24.0 MiB | metal | wrapped-auto | 24.07 | 10.74 | 27.45 | 27.45 | ok |
| 24.0 MiB | metal | wrapped-gpu | 24.87 | 10.33 | 27.39 | 27.39 | ok |
| 32.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 32.0 MiB | cpu | single-simd | 1.80 | 1.78 | 1.84 | 1.84 | ok |
| 32.0 MiB | cpu | parallel | 9.60 | 8.04 | 9.98 | 9.98 | ok |
| 32.0 MiB | official-c | one-shot | 2.20 | 2.18 | 2.27 | 2.27 | ok |
| 32.0 MiB | cpu | context-auto | 9.47 | 8.00 | 9.86 | 9.86 | ok |
| 32.0 MiB | blake3 | default-auto | 11.73 | 4.39 | 13.27 | 13.27 | ok |
| 32.0 MiB | metal | wrapped-auto | 16.43 | 7.32 | 22.38 | 22.38 | ok |
| 32.0 MiB | metal | wrapped-gpu | 12.51 | 4.39 | 19.53 | 19.53 | ok |
| 64.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.82 | 1.79 | 1.83 | 1.83 | ok |
| 64.0 MiB | cpu | parallel | 9.79 | 8.02 | 10.35 | 10.35 | ok |
| 64.0 MiB | official-c | one-shot | 2.20 | 2.19 | 2.24 | 2.24 | ok |
| 64.0 MiB | cpu | context-auto | 10.08 | 8.41 | 10.32 | 10.32 | ok |
| 64.0 MiB | blake3 | default-auto | 31.80 | 14.30 | 37.46 | 37.46 | ok |
| 64.0 MiB | metal | wrapped-auto | 33.74 | 19.16 | 37.20 | 37.20 | ok |
| 64.0 MiB | metal | wrapped-gpu | 34.82 | 21.24 | 36.12 | 36.12 | ok |
jsonOutput=benchmarks/results/20260418T194034Z-wrapped-threshold-confirm/wrapped-gate-16m.json
