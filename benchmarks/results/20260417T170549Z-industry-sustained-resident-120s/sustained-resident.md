BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=4 hasherBytes=8
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=16777216
metalModes=resident
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
sizes=512.0 MiB, 1.0 GiB
memoryStats=rss,allocator

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 512.0 MiB | cpu | scalar | 1.07 | 1.07 | 1.08 | 1.08 | ok |
| 512.0 MiB | cpu | single-simd | 1.07 | 1.07 | 1.07 | 1.07 | ok |
| 512.0 MiB | cpu | parallel | 4.23 | 4.23 | 4.23 | 4.23 | ok |
| 512.0 MiB | cpu | context-auto | 4.20 | 4.18 | 4.22 | 4.22 | ok |
| 512.0 MiB | metal | resident-auto | 58.81 | 52.73 | 64.88 | 64.88 | ok |
| 512.0 MiB | metal | resident-gpu | 64.78 | 64.56 | 64.99 | 64.99 | ok |
512.0 MiB  sustained-resident-gpu 120.0 s  avg    62.62 GiB/s  min    23.64  median    62.43  p95    72.37  max    76.36  first25%    64.46  last25%    63.04  n 15029  correct ok
| 1.0 GiB | cpu | scalar | 0.93 | 0.85 | 1.01 | 1.01 | ok |
| 1.0 GiB | cpu | single-simd | 1.07 | 1.04 | 1.09 | 1.09 | ok |
| 1.0 GiB | cpu | parallel | 3.34 | 3.04 | 3.64 | 3.64 | ok |
| 1.0 GiB | cpu | context-auto | 3.57 | 3.53 | 3.62 | 3.62 | ok |
| 1.0 GiB | metal | resident-auto | 65.42 | 64.47 | 66.36 | 66.36 | ok |
| 1.0 GiB | metal | resident-gpu | 68.44 | 68.41 | 68.48 | 68.48 | ok |
1.0 GiB  sustained-resident-gpu 120.0 s  avg    52.64 GiB/s  min    34.10  median    53.21  p95    63.34  max    72.05  first25%    55.77  last25%    52.57  n 6318  correct ok

| Size | Memory Phase | RSS | Allocator In Use | Allocator Blocks |
| --- | --- | ---: | ---: | ---: |
| 512.0 MiB | before-input | 14.5 MiB | 0.8 MiB | 5230 |
| 512.0 MiB | after-input | 526.6 MiB | 512.8 MiB | 5232 |
| 512.0 MiB | after-size | 1066.5 MiB | 539.6 MiB | 20649 |
| 1.0 GiB | before-input | 1066.5 MiB | 3.5 MiB | 20624 |
| 1.0 GiB | after-input | 1578.6 MiB | 1027.5 MiB | 20566 |
| 1.0 GiB | after-size | 2635.9 MiB | 1076.6 MiB | 27010 |
jsonOutput=benchmarks/results/20260417T170549Z-industry-sustained-resident-120s/sustained-resident.json
