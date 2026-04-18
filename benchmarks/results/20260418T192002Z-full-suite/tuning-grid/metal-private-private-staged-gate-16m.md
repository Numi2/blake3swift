BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=16777216
metalModes=private,private-staged
metal-private includes: pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read
metal-private-staged includes: pre-created shared staging and private MTLBuffers; timed Swift-byte copy into staging, private upload/hash command completion, digest read
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 64.0 MiB | cpu | parallel | 9.90 | 8.49 | 10.21 | 10.21 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.66 | 8.48 | 10.26 | 10.26 | ok |
| 64.0 MiB | blake3 | default-auto | 26.62 | 14.59 | 31.57 | 31.57 | ok |
| 64.0 MiB | metal | private-gpu | 37.09 | 17.67 | 40.39 | 40.39 | ok |
| 64.0 MiB | metal | private-staged-gpu | 9.00 | 6.44 | 11.29 | 11.29 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 10.19 | 9.95 | 10.31 | 10.31 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.10 | 9.57 | 10.24 | 10.24 | ok |
| 256.0 MiB | blake3 | default-auto | 31.85 | 26.45 | 35.79 | 35.79 | ok |
| 256.0 MiB | metal | private-gpu | 41.88 | 35.69 | 50.92 | 50.92 | ok |
| 256.0 MiB | metal | private-staged-gpu | 10.28 | 9.18 | 10.60 | 10.60 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 512.0 MiB | cpu | parallel | 10.75 | 10.66 | 10.98 | 10.98 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 10.63 | 10.08 | 11.28 | 11.28 | ok |
| 512.0 MiB | blake3 | default-auto | 34.60 | 32.25 | 38.04 | 38.04 | ok |
| 512.0 MiB | metal | private-gpu | 51.95 | 43.30 | 58.89 | 58.89 | ok |
| 512.0 MiB | metal | private-staged-gpu | 12.64 | 9.65 | 13.08 | 13.08 | ok |
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/tuning-grid/metal-private-private-staged-gate-16m.json
