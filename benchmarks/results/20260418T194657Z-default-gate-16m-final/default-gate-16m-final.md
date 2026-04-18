BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=67108864
metalModes=wrapped
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
sizes=8.0 MiB, 16.0 MiB, 24.0 MiB, 32.0 MiB, 64.0 MiB, 256.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 8.0 MiB | cpu | scalar | 0.98 | 0.96 | 0.99 | 0.99 | ok |
| 8.0 MiB | cpu | single-simd | 1.57 | 1.52 | 1.59 | 1.59 | ok |
| 8.0 MiB | cpu | parallel | 6.53 | 6.35 | 6.59 | 6.59 | ok |
| 8.0 MiB | official-c | one-shot | 1.97 | 1.85 | 1.97 | 1.97 | ok |
| 8.0 MiB | cpu | context-auto | 6.51 | 5.69 | 6.57 | 6.57 | ok |
| 8.0 MiB | blake3 | default-auto | 6.49 | 5.37 | 6.63 | 6.63 | ok |
| 8.0 MiB | metal | wrapped-auto | 6.51 | 5.70 | 6.56 | 6.56 | ok |
| 8.0 MiB | metal | wrapped-gpu | 12.03 | 9.56 | 13.34 | 13.34 | ok |
| 16.0 MiB | cpu | scalar | 0.98 | 0.98 | 0.98 | 0.98 | ok |
| 16.0 MiB | cpu | single-simd | 1.56 | 1.55 | 1.59 | 1.59 | ok |
| 16.0 MiB | cpu | parallel | 7.09 | 6.75 | 7.14 | 7.14 | ok |
| 16.0 MiB | official-c | one-shot | 1.91 | 1.85 | 1.97 | 1.97 | ok |
| 16.0 MiB | cpu | context-auto | 6.83 | 5.85 | 6.86 | 6.86 | ok |
| 16.0 MiB | blake3 | default-auto | 10.79 | 2.75 | 12.67 | 12.67 | ok |
| 16.0 MiB | metal | wrapped-auto | 19.07 | 7.64 | 20.22 | 20.22 | ok |
| 16.0 MiB | metal | wrapped-gpu | 19.05 | 14.06 | 20.57 | 20.57 | ok |
| 24.0 MiB | cpu | scalar | 0.94 | 0.92 | 0.95 | 0.95 | ok |
| 24.0 MiB | cpu | single-simd | 1.50 | 1.49 | 1.51 | 1.51 | ok |
| 24.0 MiB | cpu | parallel | 6.83 | 6.24 | 7.19 | 7.19 | ok |
| 24.0 MiB | official-c | one-shot | 1.78 | 1.76 | 1.86 | 1.86 | ok |
| 24.0 MiB | cpu | context-auto | 6.49 | 6.29 | 6.52 | 6.52 | ok |
| 24.0 MiB | blake3 | default-auto | 22.68 | 13.36 | 23.59 | 23.59 | ok |
| 24.0 MiB | metal | wrapped-auto | 21.05 | 7.86 | 22.73 | 22.73 | ok |
| 24.0 MiB | metal | wrapped-gpu | 20.72 | 12.28 | 22.50 | 22.50 | ok |
| 32.0 MiB | cpu | scalar | 0.89 | 0.88 | 0.92 | 0.92 | ok |
| 32.0 MiB | cpu | single-simd | 1.40 | 1.33 | 1.43 | 1.43 | ok |
| 32.0 MiB | cpu | parallel | 6.22 | 5.93 | 6.39 | 6.39 | ok |
| 32.0 MiB | official-c | one-shot | 1.66 | 1.63 | 1.67 | 1.67 | ok |
| 32.0 MiB | cpu | context-auto | 6.21 | 5.92 | 7.52 | 7.52 | ok |
| 32.0 MiB | blake3 | default-auto | 24.15 | 9.25 | 25.65 | 25.65 | ok |
| 32.0 MiB | metal | wrapped-auto | 23.12 | 9.62 | 24.58 | 24.58 | ok |
| 32.0 MiB | metal | wrapped-gpu | 24.29 | 10.45 | 25.42 | 25.42 | ok |
| 64.0 MiB | cpu | scalar | 0.84 | 0.84 | 0.89 | 0.89 | ok |
| 64.0 MiB | cpu | single-simd | 1.40 | 1.35 | 1.41 | 1.41 | ok |
| 64.0 MiB | cpu | parallel | 6.31 | 5.81 | 6.54 | 6.54 | ok |
| 64.0 MiB | official-c | one-shot | 1.66 | 1.54 | 1.67 | 1.67 | ok |
| 64.0 MiB | cpu | context-auto | 6.08 | 5.86 | 7.41 | 7.41 | ok |
| 64.0 MiB | blake3 | default-auto | 19.29 | 8.51 | 21.60 | 21.60 | ok |
| 64.0 MiB | metal | wrapped-auto | 19.26 | 14.10 | 23.56 | 23.56 | ok |
| 64.0 MiB | metal | wrapped-gpu | 20.83 | 11.42 | 24.03 | 24.03 | ok |
| 256.0 MiB | cpu | scalar | 0.89 | 0.84 | 0.92 | 0.92 | ok |
| 256.0 MiB | cpu | single-simd | 1.44 | 1.43 | 1.46 | 1.46 | ok |
| 256.0 MiB | cpu | parallel | 7.37 | 6.79 | 8.44 | 8.44 | ok |
| 256.0 MiB | official-c | one-shot | 1.18 | 0.81 | 1.67 | 1.67 | ok |
| 256.0 MiB | cpu | context-auto | 7.27 | 5.15 | 8.20 | 8.20 | ok |
| 256.0 MiB | blake3 | default-auto | 27.76 | 24.40 | 31.59 | 31.59 | ok |
| 256.0 MiB | metal | wrapped-auto | 28.04 | 22.56 | 30.14 | 30.14 | ok |
| 256.0 MiB | metal | wrapped-gpu | 26.39 | 19.63 | 29.83 | 29.83 | ok |
jsonOutput=benchmarks/results/20260418T194657Z-default-gate-16m-final/default-gate-16m-final.json
