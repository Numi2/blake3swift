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
| 512.0 MiB | cpu | scalar | 1.06 | 1.06 | 1.06 | 1.06 | ok |
| 512.0 MiB | cpu | single-simd | 1.06 | 1.05 | 1.08 | 1.08 | ok |
| 512.0 MiB | cpu | parallel | 3.67 | 3.52 | 3.81 | 3.81 | ok |
| 512.0 MiB | cpu | context-auto | 4.05 | 3.94 | 4.15 | 4.15 | ok |
| 512.0 MiB | metal | resident-auto | 51.46 | 42.92 | 60.00 | 60.00 | ok |
| 512.0 MiB | metal | resident-gpu | 64.54 | 62.76 | 66.32 | 66.32 | ok |
512.0 MiB  sustained-resident-gpu 120.0 s  avg    54.97 GiB/s  min    28.39  median    55.78  p95    69.00  max    75.71  first25%    62.29  last25%    50.20  n 13194  correct ok
| 1.0 GiB | cpu | scalar | 0.81 | 0.80 | 0.81 | 0.81 | ok |
| 1.0 GiB | cpu | single-simd | 0.78 | 0.73 | 0.83 | 0.83 | ok |
| 1.0 GiB | cpu | parallel | 2.89 | 2.78 | 3.00 | 3.00 | ok |
| 1.0 GiB | cpu | context-auto | 2.55 | 2.53 | 2.57 | 2.57 | ok |
| 1.0 GiB | metal | resident-auto | 61.39 | 59.55 | 63.23 | 63.23 | ok |
| 1.0 GiB | metal | resident-gpu | 54.44 | 54.37 | 54.52 | 54.52 | ok |
1.0 GiB  sustained-resident-gpu 120.0 s  avg    45.36 GiB/s  min     4.37  median    48.03  p95    54.06  max    68.46  first25%    47.77  last25%    45.08  n 5444  correct ok

| Size | Memory Phase | RSS | Allocator In Use | Allocator Blocks |
| --- | --- | ---: | ---: | ---: |
| 512.0 MiB | before-input | 14.5 MiB | 0.8 MiB | 5231 |
| 512.0 MiB | after-input | 526.6 MiB | 512.8 MiB | 5233 |
| 512.0 MiB | after-size | 976.9 MiB | 539.3 MiB | 18817 |
| 1.0 GiB | before-input | 977.0 MiB | 3.2 MiB | 18792 |
| 1.0 GiB | after-input | 1489.0 MiB | 1027.2 MiB | 18734 |
| 1.0 GiB | after-size | 1034.8 MiB | 1076.1 MiB | 24300 |
jsonOutput=benchmarks/results/20260417T155605Z-sustained-resident-120s/sustained-resident.json
