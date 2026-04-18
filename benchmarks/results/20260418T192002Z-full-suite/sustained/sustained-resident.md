BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=resident
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
sizes=512.0 MiB, 1.0 GiB

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 512.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 512.0 MiB | cpu | parallel | 10.72 | 10.55 | 10.89 | 10.89 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 10.86 | 10.36 | 11.35 | 11.35 | ok |
| 512.0 MiB | blake3 | default-auto | 37.39 | 37.32 | 37.45 | 37.45 | ok |
| 512.0 MiB | metal | resident-auto | 46.76 | 43.84 | 49.69 | 49.69 | ok |
| 512.0 MiB | metal | resident-gpu | 59.75 | 53.94 | 65.56 | 65.56 | ok |
512.0 MiB  sustained-resident-gpu 30.0 s  avg    63.59 GiB/s  min    45.41  median    62.93  p95    73.23  max    76.24  first25%    65.24  last25%    63.04  n 3816  correct ok
| 1.0 GiB | cpu | scalar | 1.06 | 1.05 | 1.08 | 1.08 | ok |
| 1.0 GiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 10.84 | 10.65 | 11.04 | 11.04 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 11.20 | 11.17 | 11.24 | 11.24 | ok |
| 1.0 GiB | blake3 | default-auto | 38.65 | 37.66 | 39.64 | 39.64 | ok |
| 1.0 GiB | metal | resident-auto | 65.99 | 64.35 | 67.62 | 67.62 | ok |
| 1.0 GiB | metal | resident-gpu | 65.76 | 65.68 | 65.84 | 65.84 | ok |
1.0 GiB  sustained-resident-gpu 30.0 s  avg    64.26 GiB/s  min    54.29  median    64.17  p95    68.28  max    75.54  first25%    66.08  last25%    62.52  n 1928  correct ok
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/sustained/sustained-resident.json
