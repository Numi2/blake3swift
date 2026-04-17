BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=4 hasherBytes=8
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=16777216
metalModes=resident,staged,wrapped,e2e,private,private-staged
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-private includes: pre-created private MTLBuffer; setup copy excluded; timed hash includes command encoding, GPU execution, wait, digest read
metal-private-staged includes: pre-created shared staging and private MTLBuffers; timed Swift-byte copy into staging, blit into private storage, private hash, waits, digest read
metal-staged includes: pre-created shared staging MTLBuffer; timed Swift-byte copy into staging buffer plus hash
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
memoryStats=rss,allocator

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 16.0 MiB | cpu | single-simd | 1.17 | 1.14 | 1.19 | 1.19 | ok |
| 16.0 MiB | cpu | parallel | 4.10 | 3.88 | 4.11 | 4.11 | ok |
| 16.0 MiB | cpu | context-auto | 4.09 | 3.90 | 4.12 | 4.12 | ok |
| 16.0 MiB | metal | resident-auto | 9.44 | 2.73 | 10.15 | 10.15 | ok |
| 16.0 MiB | metal | resident-gpu | 9.90 | 3.28 | 14.74 | 14.74 | ok |
| 16.0 MiB | metal | private-gpu | 23.74 | 12.53 | 30.31 | 30.31 | ok |
| 16.0 MiB | metal | private-staged-gpu | 8.00 | 5.82 | 9.99 | 9.99 | ok |
| 16.0 MiB | metal | staged-auto | 15.28 | 7.81 | 17.28 | 17.28 | ok |
| 16.0 MiB | metal | staged-gpu | 15.61 | 10.28 | 17.39 | 17.39 | ok |
| 16.0 MiB | metal | wrapped-auto | 18.65 | 8.95 | 21.34 | 21.34 | ok |
| 16.0 MiB | metal | wrapped-gpu | 19.03 | 16.11 | 21.44 | 21.44 | ok |
| 16.0 MiB | metal | e2e-auto | 9.40 | 6.47 | 10.11 | 10.11 | ok |
| 16.0 MiB | metal | e2e-gpu | 9.20 | 7.18 | 10.07 | 10.07 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.16 | 1.13 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | parallel | 4.23 | 4.21 | 4.27 | 4.27 | ok |
| 64.0 MiB | cpu | context-auto | 4.21 | 3.54 | 4.25 | 4.25 | ok |
| 64.0 MiB | metal | resident-auto | 27.96 | 8.00 | 49.54 | 49.54 | ok |
| 64.0 MiB | metal | resident-gpu | 35.27 | 27.47 | 53.66 | 53.66 | ok |
| 64.0 MiB | metal | private-gpu | 49.65 | 24.26 | 51.47 | 51.47 | ok |
| 64.0 MiB | metal | private-staged-gpu | 11.35 | 9.13 | 12.80 | 12.80 | ok |
| 64.0 MiB | metal | staged-auto | 19.35 | 16.07 | 21.39 | 21.39 | ok |
| 64.0 MiB | metal | staged-gpu | 19.88 | 12.89 | 21.26 | 21.26 | ok |
| 64.0 MiB | metal | wrapped-auto | 33.87 | 21.35 | 37.98 | 37.98 | ok |
| 64.0 MiB | metal | wrapped-gpu | 35.46 | 20.84 | 36.59 | 36.59 | ok |
| 64.0 MiB | metal | e2e-auto | 11.36 | 9.87 | 11.81 | 11.81 | ok |
| 64.0 MiB | metal | e2e-gpu | 11.36 | 10.10 | 11.93 | 11.93 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.13 | 1.12 | 1.13 | 1.13 | ok |
| 256.0 MiB | cpu | parallel | 4.27 | 4.26 | 4.28 | 4.28 | ok |
| 256.0 MiB | cpu | context-auto | 4.27 | 4.27 | 4.28 | 4.28 | ok |
| 256.0 MiB | metal | resident-auto | 60.93 | 48.67 | 69.53 | 69.53 | ok |
| 256.0 MiB | metal | resident-gpu | 68.96 | 50.62 | 69.34 | 69.34 | ok |
| 256.0 MiB | metal | private-gpu | 68.44 | 50.63 | 69.98 | 69.98 | ok |
| 256.0 MiB | metal | private-staged-gpu | 15.02 | 14.42 | 15.27 | 15.27 | ok |
| 256.0 MiB | metal | staged-auto | 22.37 | 21.58 | 24.89 | 24.89 | ok |
| 256.0 MiB | metal | staged-gpu | 23.81 | 22.03 | 24.98 | 24.98 | ok |
| 256.0 MiB | metal | wrapped-auto | 42.07 | 35.36 | 43.09 | 43.09 | ok |
| 256.0 MiB | metal | wrapped-gpu | 42.14 | 34.86 | 42.82 | 42.82 | ok |
| 256.0 MiB | metal | e2e-auto | 11.76 | 11.29 | 12.57 | 12.57 | ok |
| 256.0 MiB | metal | e2e-gpu | 11.09 | 10.55 | 11.80 | 11.80 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.06 | 1.09 | 1.09 | ok |
| 512.0 MiB | cpu | single-simd | 1.12 | 1.10 | 1.12 | 1.12 | ok |
| 512.0 MiB | cpu | parallel | 4.23 | 4.18 | 4.26 | 4.26 | ok |
| 512.0 MiB | cpu | context-auto | 4.27 | 4.24 | 4.28 | 4.28 | ok |
| 512.0 MiB | metal | resident-auto | 69.02 | 51.50 | 75.38 | 75.38 | ok |
| 512.0 MiB | metal | resident-gpu | 74.75 | 62.89 | 75.97 | 75.97 | ok |
| 512.0 MiB | metal | private-gpu | 69.42 | 62.31 | 75.63 | 75.63 | ok |
| 512.0 MiB | metal | private-staged-gpu | 14.59 | 12.25 | 15.03 | 15.03 | ok |
| 512.0 MiB | metal | staged-auto | 22.19 | 14.80 | 24.48 | 24.48 | ok |
| 512.0 MiB | metal | staged-gpu | 24.04 | 23.38 | 25.17 | 25.17 | ok |
| 512.0 MiB | metal | wrapped-auto | 43.14 | 39.08 | 45.80 | 45.80 | ok |
| 512.0 MiB | metal | wrapped-gpu | 40.92 | 35.72 | 43.63 | 43.63 | ok |
| 512.0 MiB | metal | e2e-auto | 10.10 | 5.30 | 10.64 | 10.64 | ok |
| 512.0 MiB | metal | e2e-gpu | 9.81 | 9.56 | 10.42 | 10.42 | ok |
| 1.0 GiB | cpu | scalar | 1.08 | 1.05 | 1.09 | 1.09 | ok |
| 1.0 GiB | cpu | single-simd | 1.10 | 1.09 | 1.11 | 1.11 | ok |
| 1.0 GiB | cpu | parallel | 4.28 | 4.21 | 4.28 | 4.28 | ok |
| 1.0 GiB | cpu | context-auto | 4.23 | 4.19 | 4.26 | 4.26 | ok |
| 1.0 GiB | metal | resident-auto | 71.03 | 67.34 | 77.72 | 77.72 | ok |
| 1.0 GiB | metal | resident-gpu | 70.75 | 65.92 | 77.50 | 77.50 | ok |
| 1.0 GiB | metal | private-gpu | 69.68 | 62.22 | 76.63 | 76.63 | ok |
| 1.0 GiB | metal | private-staged-gpu | 14.24 | 11.38 | 15.19 | 15.19 | ok |
| 1.0 GiB | metal | staged-auto | 24.46 | 16.87 | 24.81 | 24.81 | ok |
| 1.0 GiB | metal | staged-gpu | 22.13 | 21.12 | 23.42 | 23.42 | ok |
| 1.0 GiB | metal | wrapped-auto | 28.00 | 23.80 | 35.07 | 35.07 | ok |
| 1.0 GiB | metal | wrapped-gpu | 35.64 | 28.20 | 38.83 | 38.83 | ok |
| 1.0 GiB | metal | e2e-auto | 6.86 | 2.58 | 10.05 | 10.05 | ok |
| 1.0 GiB | metal | e2e-gpu | 9.32 | 8.89 | 10.14 | 10.14 | ok |

| Size | Memory Phase | RSS | Allocator In Use | Allocator Blocks |
| --- | --- | ---: | ---: | ---: |
| 16.0 MiB | before-input | 14.5 MiB | 0.8 MiB | 5227 |
| 16.0 MiB | after-input | 30.5 MiB | 16.8 MiB | 5229 |
| 16.0 MiB | after-size | 96.5 MiB | 17.9 MiB | 5718 |
| 64.0 MiB | before-input | 96.5 MiB | 1.1 MiB | 5701 |
| 64.0 MiB | after-input | 160.5 MiB | 65.1 MiB | 5639 |
| 64.0 MiB | after-size | 387.6 MiB | 68.2 MiB | 5873 |
| 256.0 MiB | before-input | 387.6 MiB | 1.1 MiB | 5865 |
| 256.0 MiB | after-input | 643.6 MiB | 257.1 MiB | 5785 |
| 256.0 MiB | after-size | 1543.7 MiB | 277.2 MiB | 6018 |
| 512.0 MiB | before-input | 1543.7 MiB | 1.2 MiB | 6013 |
| 512.0 MiB | after-input | 1543.7 MiB | 513.1 MiB | 5930 |
| 512.0 MiB | after-size | 3087.8 MiB | 537.2 MiB | 6155 |
| 1.0 GiB | before-input | 3087.8 MiB | 1.2 MiB | 6149 |
| 1.0 GiB | after-input | 4111.7 MiB | 1025.2 MiB | 6067 |
| 1.0 GiB | after-size | 3148.7 MiB | 1105.3 MiB | 6293 |
jsonOutput=benchmarks/results/20260417T170451Z-industry-metal-diagnostics/metal-diagnostics.json
