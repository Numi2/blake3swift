BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
fileModes=read,mmap,mmap-parallel,metal-mmap,metal-tiled-mmap
file-read includes: timed file open, streaming read loop, CPU update/finalize, close; benchmark file creation excluded
file-mmap includes: timed file open/stat, mmap, bounded tiled CPU hash, finalize, munmap, close; benchmark file creation excluded
file-mmap-parallel includes: timed file open/stat, mmap, bounded tiled CPU parallel hash, finalize, munmap, close; benchmark file creation excluded
file-metal-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, GPU hash wait, digest read, munmap, close; benchmark file creation excluded
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded
memoryStats=rss,allocator

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.09 | 1.08 | 1.10 | 1.10 | ok |
| 16.0 MiB | cpu | single-simd | 1.76 | 1.72 | 1.77 | 1.77 | ok |
| 16.0 MiB | cpu | parallel | 7.96 | 7.49 | 9.05 | 9.05 | ok |
| 16.0 MiB | official-c | one-shot | 2.18 | 2.13 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 8.90 | 7.76 | 9.24 | 9.24 | ok |
| 16.0 MiB | blake3 | default-auto | 8.63 | 7.65 | 9.15 | 9.15 | ok |
| 16.0 MiB | cpu-file | read | 1.02 | 1.01 | 1.03 | 1.03 | ok |
| 16.0 MiB | cpu-file | mmap | 1.05 | 1.03 | 1.05 | 1.05 | ok |
| 16.0 MiB | cpu-file | mmap-parallel | 6.15 | 5.54 | 6.43 | 6.43 | ok |
| 16.0 MiB | metal-file | metal-mmap-gpu | 3.15 | 1.32 | 4.30 | 4.30 | ok |
| 16.0 MiB | metal-file | metal-tiled-mmap-gpu | 2.28 | 1.15 | 2.99 | 2.99 | ok |
| 64.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.77 | 1.77 | ok |
| 64.0 MiB | cpu | parallel | 9.84 | 9.10 | 10.31 | 10.31 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.19 | 2.19 | ok |
| 64.0 MiB | cpu | context-auto | 9.97 | 8.55 | 10.32 | 10.32 | ok |
| 64.0 MiB | blake3 | default-auto | 29.52 | 7.15 | 35.14 | 35.14 | ok |
| 64.0 MiB | cpu-file | read | 1.02 | 1.02 | 1.03 | 1.03 | ok |
| 64.0 MiB | cpu-file | mmap | 1.05 | 1.04 | 1.05 | 1.05 | ok |
| 64.0 MiB | cpu-file | mmap-parallel | 5.89 | 5.27 | 6.17 | 6.17 | ok |
| 64.0 MiB | metal-file | metal-mmap-gpu | 3.95 | 2.39 | 4.34 | 4.34 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.68 | 3.40 | 3.83 | 3.83 | ok |
| 256.0 MiB | cpu | scalar | 1.10 | 1.10 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.77 | 1.77 | 1.78 | 1.78 | ok |
| 256.0 MiB | cpu | parallel | 10.45 | 10.12 | 10.91 | 10.91 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.19 | 2.19 | ok |
| 256.0 MiB | cpu | context-auto | 10.22 | 9.57 | 10.86 | 10.86 | ok |
| 256.0 MiB | blake3 | default-auto | 41.19 | 30.23 | 43.35 | 43.35 | ok |
| 256.0 MiB | cpu-file | read | 1.02 | 1.02 | 1.02 | 1.02 | ok |
| 256.0 MiB | cpu-file | mmap | 1.05 | 1.04 | 1.05 | 1.05 | ok |
| 256.0 MiB | cpu-file | mmap-parallel | 5.93 | 5.80 | 6.02 | 6.02 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 7.37 | 5.12 | 8.72 | 8.72 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.38 | 3.90 | 4.66 | 4.66 | ok |
| 512.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.78 | 1.77 | 1.79 | 1.79 | ok |
| 512.0 MiB | cpu | parallel | 11.02 | 10.38 | 11.18 | 11.18 | ok |
| 512.0 MiB | official-c | one-shot | 2.19 | 2.18 | 2.19 | 2.19 | ok |
| 512.0 MiB | cpu | context-auto | 10.80 | 6.47 | 11.17 | 11.17 | ok |
| 512.0 MiB | blake3 | default-auto | 34.52 | 29.75 | 42.80 | 42.80 | ok |
| 512.0 MiB | cpu-file | read | 1.02 | 1.02 | 1.03 | 1.03 | ok |
| 512.0 MiB | cpu-file | mmap | 1.05 | 1.04 | 1.05 | 1.05 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 5.87 | 5.77 | 5.94 | 5.94 | ok |
| 512.0 MiB | metal-file | metal-mmap-gpu | 7.20 | 5.47 | 8.77 | 8.77 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.54 | 4.11 | 4.62 | 4.62 | ok |
| 1.0 GiB | cpu | scalar | 1.09 | 1.08 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.76 | 1.74 | 1.76 | 1.76 | ok |
| 1.0 GiB | cpu | parallel | 10.91 | 10.57 | 11.38 | 11.38 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 11.08 | 10.64 | 11.38 | 11.38 | ok |
| 1.0 GiB | blake3 | default-auto | 29.40 | 27.46 | 34.00 | 34.00 | ok |
| 1.0 GiB | cpu-file | read | 1.02 | 1.02 | 1.02 | 1.02 | ok |
| 1.0 GiB | cpu-file | mmap | 1.04 | 1.01 | 1.04 | 1.04 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 5.75 | 5.66 | 5.81 | 5.81 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 7.73 | 6.11 | 8.59 | 8.59 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 2.77 | 2.68 | 2.85 | 2.85 | ok |

| Size | Memory Phase | RSS | Allocator In Use | Allocator Blocks |
| --- | --- | ---: | ---: | ---: |
| 16.0 MiB | before-input | 15.1 MiB | 0.8 MiB | 5413 |
| 16.0 MiB | after-input | 31.1 MiB | 16.8 MiB | 5415 |
| 16.0 MiB | after-size | 38.8 MiB | 18.1 MiB | 6200 |
| 64.0 MiB | before-input | 38.8 MiB | 1.3 MiB | 6185 |
| 64.0 MiB | after-input | 102.7 MiB | 65.2 MiB | 6019 |
| 64.0 MiB | after-size | 94.0 MiB | 68.4 MiB | 6447 |
| 256.0 MiB | before-input | 94.0 MiB | 1.4 MiB | 6426 |
| 256.0 MiB | after-input | 349.9 MiB | 257.3 MiB | 6261 |
| 256.0 MiB | after-size | 300.8 MiB | 269.5 MiB | 6726 |
| 512.0 MiB | before-input | 300.8 MiB | 1.4 MiB | 6717 |
| 512.0 MiB | after-input | 812.7 MiB | 513.4 MiB | 6539 |
| 512.0 MiB | after-size | 573.6 MiB | 537.6 MiB | 7153 |
| 1.0 GiB | before-input | 573.6 MiB | 1.5 MiB | 7130 |
| 1.0 GiB | after-input | 1597.5 MiB | 1025.4 MiB | 6967 |
| 1.0 GiB | after-size | 1114.5 MiB | 1073.7 MiB | 7866 |
jsonOutput=benchmarks/results/20260418T192002Z-full-suite/publication/file-publication.json
