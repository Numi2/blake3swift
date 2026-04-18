BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=16777216
metalModes=private
metal-private includes: pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.31 | 9.06 | 10.21 | 10.21 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 10.15 | 8.90 | 10.24 | 10.24 | ok |
| 64.0 MiB | blake3 | default-auto | 24.90 | 20.05 | 29.41 | 29.41 | ok |
| 64.0 MiB | metal | private-gpu | 34.77 | 21.25 | 40.56 | 40.56 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.31 | 10.15 | 10.52 | 10.52 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 9.96 | 9.76 | 10.25 | 10.25 | ok |
| 256.0 MiB | blake3 | default-auto | 32.57 | 29.55 | 35.67 | 35.67 | ok |
| 256.0 MiB | metal | private-gpu | 43.70 | 36.00 | 50.23 | 50.23 | ok |
| 512.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.71 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 10.32 | 10.21 | 10.64 | 10.64 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 512.0 MiB | cpu | context-auto | 10.72 | 10.40 | 10.90 | 10.90 | ok |
| 512.0 MiB | blake3 | default-auto | 39.08 | 37.96 | 41.48 | 41.48 | ok |
| 512.0 MiB | metal | private-gpu | 65.40 | 55.37 | 71.32 | 71.32 | ok |
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/tuning-grid/metal-private-gate-16m.json
