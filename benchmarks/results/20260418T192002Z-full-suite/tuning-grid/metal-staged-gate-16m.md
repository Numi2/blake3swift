BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=16777216
metalModes=staged
metal-staged includes: pre-created shared staging MTLBuffer; timed Swift-byte copy into staging buffer plus hash
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 8.22 | 7.88 | 9.91 | 9.91 | ok |
| 64.0 MiB | official-c | one-shot | 2.16 | 2.15 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 9.88 | 8.37 | 10.18 | 10.18 | ok |
| 64.0 MiB | blake3 | default-auto | 22.96 | 15.22 | 28.91 | 28.91 | ok |
| 64.0 MiB | metal | staged-auto | 15.44 | 14.96 | 16.11 | 16.11 | ok |
| 64.0 MiB | metal | staged-gpu | 14.65 | 14.32 | 15.89 | 15.89 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.07 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 10.03 | 8.77 | 10.65 | 10.65 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 9.96 | 8.33 | 10.29 | 10.29 | ok |
| 256.0 MiB | blake3 | default-auto | 33.88 | 29.74 | 37.54 | 37.54 | ok |
| 256.0 MiB | metal | staged-auto | 18.02 | 13.98 | 20.86 | 20.86 | ok |
| 256.0 MiB | metal | staged-gpu | 18.74 | 17.62 | 19.80 | 19.80 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 10.82 | 10.46 | 10.99 | 10.99 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 10.77 | 10.55 | 11.38 | 11.38 | ok |
| 512.0 MiB | blake3 | default-auto | 33.69 | 31.48 | 37.70 | 37.70 | ok |
| 512.0 MiB | metal | staged-auto | 16.66 | 11.44 | 21.23 | 21.23 | ok |
| 512.0 MiB | metal | staged-gpu | 17.47 | 15.61 | 18.02 | 18.02 | ok |
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/tuning-grid/metal-staged-gate-16m.json
