BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=16777216
metalModes=e2e
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.80 | 8.69 | 10.17 | 10.17 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.73 | 8.52 | 10.55 | 10.55 | ok |
| 64.0 MiB | blake3 | default-auto | 14.65 | 7.25 | 15.87 | 15.87 | ok |
| 64.0 MiB | metal | e2e-auto | 7.15 | 4.54 | 8.02 | 8.02 | ok |
| 64.0 MiB | metal | e2e-gpu | 7.50 | 6.68 | 7.88 | 7.88 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.15 | 10.05 | 10.29 | 10.29 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 9.91 | 9.17 | 10.42 | 10.42 | ok |
| 256.0 MiB | blake3 | default-auto | 31.53 | 27.32 | 36.16 | 36.16 | ok |
| 256.0 MiB | metal | e2e-auto | 10.14 | 7.76 | 10.48 | 10.48 | ok |
| 256.0 MiB | metal | e2e-gpu | 9.17 | 7.94 | 9.97 | 9.97 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.08 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 512.0 MiB | cpu | parallel | 10.79 | 10.71 | 10.98 | 10.98 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 10.79 | 10.46 | 10.94 | 10.94 | ok |
| 512.0 MiB | blake3 | default-auto | 33.23 | 31.45 | 37.42 | 37.42 | ok |
| 512.0 MiB | metal | e2e-auto | 9.71 | 7.82 | 10.39 | 10.39 | ok |
| 512.0 MiB | metal | e2e-gpu | 9.14 | 8.57 | 10.36 | 10.36 | ok |
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/tuning-grid/metal-e2e-gate-16m.json
