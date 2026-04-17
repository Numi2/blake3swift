BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=4 hasherBytes=8
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=16777216
metalModes=resident,e2e
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
memoryStats=rss,allocator

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.08 | 1.05 | 1.09 | 1.09 | ok |
| 16.0 MiB | cpu | single-simd | 1.11 | 1.09 | 1.13 | 1.13 | ok |
| 16.0 MiB | cpu | parallel | 4.08 | 3.77 | 4.11 | 4.11 | ok |
| 16.0 MiB | cpu | context-auto | 4.06 | 3.62 | 4.11 | 4.11 | ok |
| 16.0 MiB | metal | resident-auto | 7.91 | 2.58 | 9.95 | 9.95 | ok |
| 16.0 MiB | metal | resident-gpu | 20.60 | 6.65 | 23.49 | 23.49 | ok |
| 16.0 MiB | metal | e2e-auto | 6.71 | 5.24 | 8.54 | 8.54 | ok |
| 16.0 MiB | metal | e2e-gpu | 6.75 | 5.18 | 8.20 | 8.20 | ok |
| 64.0 MiB | cpu | scalar | 1.08 | 1.07 | 1.08 | 1.08 | ok |
| 64.0 MiB | cpu | single-simd | 1.10 | 1.09 | 1.11 | 1.11 | ok |
| 64.0 MiB | cpu | parallel | 4.10 | 4.01 | 4.15 | 4.15 | ok |
| 64.0 MiB | cpu | context-auto | 4.13 | 3.63 | 4.24 | 4.24 | ok |
| 64.0 MiB | metal | resident-auto | 18.18 | 8.89 | 38.30 | 38.30 | ok |
| 64.0 MiB | metal | resident-gpu | 44.80 | 26.83 | 51.91 | 51.91 | ok |
| 64.0 MiB | metal | e2e-auto | 8.54 | 7.08 | 9.37 | 9.37 | ok |
| 64.0 MiB | metal | e2e-gpu | 8.95 | 8.26 | 9.61 | 9.61 | ok |
| 256.0 MiB | cpu | scalar | 1.08 | 0.91 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.11 | 1.10 | 1.11 | 1.11 | ok |
| 256.0 MiB | cpu | parallel | 4.22 | 4.19 | 4.24 | 4.24 | ok |
| 256.0 MiB | cpu | context-auto | 4.21 | 4.19 | 4.24 | 4.24 | ok |
| 256.0 MiB | metal | resident-auto | 42.97 | 33.56 | 52.97 | 52.97 | ok |
| 256.0 MiB | metal | resident-gpu | 53.64 | 49.33 | 61.24 | 61.24 | ok |
| 256.0 MiB | metal | e2e-auto | 8.94 | 6.48 | 9.74 | 9.74 | ok |
| 256.0 MiB | metal | e2e-gpu | 9.67 | 9.32 | 10.17 | 10.17 | ok |
| 512.0 MiB | cpu | scalar | 1.08 | 1.04 | 1.09 | 1.09 | ok |
| 512.0 MiB | cpu | single-simd | 1.10 | 1.10 | 1.11 | 1.11 | ok |
| 512.0 MiB | cpu | parallel | 4.22 | 4.18 | 4.24 | 4.24 | ok |
| 512.0 MiB | cpu | context-auto | 4.21 | 4.16 | 4.25 | 4.25 | ok |
| 512.0 MiB | metal | resident-auto | 44.27 | 28.35 | 52.79 | 52.79 | ok |
| 512.0 MiB | metal | resident-gpu | 55.44 | 44.74 | 66.86 | 66.86 | ok |
| 512.0 MiB | metal | e2e-auto | 10.03 | 6.15 | 10.44 | 10.44 | ok |
| 512.0 MiB | metal | e2e-gpu | 10.04 | 9.69 | 10.53 | 10.53 | ok |
| 1.0 GiB | cpu | scalar | 1.08 | 0.97 | 1.09 | 1.09 | ok |
| 1.0 GiB | cpu | single-simd | 1.08 | 1.01 | 1.11 | 1.11 | ok |
| 1.0 GiB | cpu | parallel | 3.78 | 3.43 | 4.03 | 4.03 | ok |
| 1.0 GiB | cpu | context-auto | 3.86 | 3.71 | 4.06 | 4.06 | ok |
| 1.0 GiB | metal | resident-auto | 65.44 | 51.32 | 70.08 | 70.08 | ok |
| 1.0 GiB | metal | resident-gpu | 68.99 | 53.90 | 77.49 | 77.49 | ok |
| 1.0 GiB | metal | e2e-auto | 8.88 | 5.22 | 9.30 | 9.30 | ok |
| 1.0 GiB | metal | e2e-gpu | 9.86 | 9.05 | 10.50 | 10.50 | ok |

| Size | Memory Phase | RSS | Allocator In Use | Allocator Blocks |
| --- | --- | ---: | ---: | ---: |
| 16.0 MiB | before-input | 14.5 MiB | 0.8 MiB | 5228 |
| 16.0 MiB | after-input | 30.6 MiB | 16.8 MiB | 5230 |
| 16.0 MiB | after-size | 64.2 MiB | 17.8 MiB | 5596 |
| 64.0 MiB | before-input | 64.2 MiB | 1.0 MiB | 5582 |
| 64.0 MiB | after-input | 128.2 MiB | 65.0 MiB | 5514 |
| 64.0 MiB | after-size | 227.3 MiB | 68.1 MiB | 5661 |
| 256.0 MiB | before-input | 227.3 MiB | 1.0 MiB | 5641 |
| 256.0 MiB | after-input | 355.3 MiB | 257.0 MiB | 5573 |
| 256.0 MiB | after-size | 871.4 MiB | 277.1 MiB | 5720 |
| 512.0 MiB | before-input | 871.4 MiB | 1.1 MiB | 5715 |
| 512.0 MiB | after-input | 1383.4 MiB | 513.0 MiB | 5632 |
| 512.0 MiB | after-size | 1903.5 MiB | 537.1 MiB | 5774 |
| 1.0 GiB | before-input | 1903.5 MiB | 1.1 MiB | 5766 |
| 1.0 GiB | after-input | 1903.5 MiB | 1025.0 MiB | 5686 |
| 1.0 GiB | after-size | 2141.9 MiB | 1105.1 MiB | 5824 |
jsonOutput=benchmarks/results/20260417T170231Z-industry-publication/cpu-metal-publication.json
