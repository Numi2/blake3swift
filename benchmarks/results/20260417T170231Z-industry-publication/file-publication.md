BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=4 hasherBytes=8
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
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
| 16.0 MiB | cpu | single-simd | 1.10 | 1.10 | 1.11 | 1.11 | ok |
| 16.0 MiB | cpu | parallel | 4.09 | 3.93 | 4.12 | 4.12 | ok |
| 16.0 MiB | cpu | context-auto | 4.10 | 3.91 | 4.11 | 4.11 | ok |
| 16.0 MiB | cpu-file | read | 1.03 | 1.03 | 1.03 | 1.03 | ok |
| 16.0 MiB | cpu-file | mmap | 1.05 | 1.04 | 1.05 | 1.05 | ok |
| 16.0 MiB | cpu-file | mmap-parallel | 3.44 | 3.29 | 3.46 | 3.46 | ok |
| 16.0 MiB | metal-file | metal-mmap-gpu | 3.09 | 1.21 | 3.21 | 3.21 | ok |
| 16.0 MiB | metal-file | metal-tiled-mmap-gpu | 2.03 | 1.39 | 2.71 | 2.71 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 1.08 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.10 | 1.10 | 1.11 | 1.11 | ok |
| 64.0 MiB | cpu | parallel | 4.21 | 4.17 | 4.25 | 4.25 | ok |
| 64.0 MiB | cpu | context-auto | 4.21 | 4.18 | 4.26 | 4.26 | ok |
| 64.0 MiB | cpu-file | read | 1.02 | 1.02 | 1.02 | 1.02 | ok |
| 64.0 MiB | cpu-file | mmap | 1.05 | 1.04 | 1.05 | 1.05 | ok |
| 64.0 MiB | cpu-file | mmap-parallel | 3.34 | 3.32 | 3.37 | 3.37 | ok |
| 64.0 MiB | metal-file | metal-mmap-gpu | 3.75 | 3.62 | 3.94 | 3.94 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 2.87 | 2.16 | 3.10 | 3.10 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.10 | 1.10 | 1.11 | 1.11 | ok |
| 256.0 MiB | cpu | parallel | 4.27 | 4.26 | 4.28 | 4.28 | ok |
| 256.0 MiB | cpu | context-auto | 4.27 | 4.26 | 4.28 | 4.28 | ok |
| 256.0 MiB | cpu-file | read | 1.02 | 1.02 | 1.02 | 1.02 | ok |
| 256.0 MiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 256.0 MiB | cpu-file | mmap-parallel | 3.34 | 3.33 | 3.35 | 3.35 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 7.02 | 6.22 | 8.05 | 8.05 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.16 | 3.95 | 4.44 | 4.44 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.11 | 1.11 | 1.12 | 1.12 | ok |
| 512.0 MiB | cpu | parallel | 4.19 | 4.01 | 4.26 | 4.26 | ok |
| 512.0 MiB | cpu | context-auto | 4.27 | 4.15 | 4.28 | 4.28 | ok |
| 512.0 MiB | cpu-file | read | 1.02 | 1.02 | 1.02 | 1.02 | ok |
| 512.0 MiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 3.34 | 3.32 | 3.34 | 3.34 | ok |
| 512.0 MiB | metal-file | metal-mmap-gpu | 7.23 | 6.42 | 7.62 | 7.62 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.45 | 4.31 | 4.62 | 4.62 | ok |
| 1.0 GiB | cpu | scalar | 1.09 | 1.06 | 1.09 | 1.09 | ok |
| 1.0 GiB | cpu | single-simd | 1.12 | 1.11 | 1.12 | 1.12 | ok |
| 1.0 GiB | cpu | parallel | 4.28 | 4.26 | 4.29 | 4.29 | ok |
| 1.0 GiB | cpu | context-auto | 4.27 | 3.91 | 4.29 | 4.29 | ok |
| 1.0 GiB | cpu-file | read | 1.02 | 1.02 | 1.02 | 1.02 | ok |
| 1.0 GiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 3.34 | 3.23 | 3.34 | 3.34 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 8.08 | 7.43 | 8.44 | 8.44 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 4.89 | 4.75 | 4.97 | 4.97 | ok |

| Size | Memory Phase | RSS | Allocator In Use | Allocator Blocks |
| --- | --- | ---: | ---: | ---: |
| 16.0 MiB | before-input | 14.5 MiB | 0.8 MiB | 5228 |
| 16.0 MiB | after-input | 30.6 MiB | 16.8 MiB | 5230 |
| 16.0 MiB | after-size | 37.5 MiB | 17.9 MiB | 5751 |
| 64.0 MiB | before-input | 37.5 MiB | 1.1 MiB | 5745 |
| 64.0 MiB | after-input | 101.4 MiB | 65.1 MiB | 5664 |
| 64.0 MiB | after-size | 108.8 MiB | 68.2 MiB | 5924 |
| 256.0 MiB | before-input | 108.8 MiB | 1.2 MiB | 5918 |
| 256.0 MiB | after-input | 364.8 MiB | 257.1 MiB | 5833 |
| 256.0 MiB | after-size | 373.6 MiB | 277.3 MiB | 6190 |
| 512.0 MiB | before-input | 373.6 MiB | 1.2 MiB | 6181 |
| 512.0 MiB | after-input | 885.6 MiB | 513.2 MiB | 6099 |
| 512.0 MiB | after-size | 572.2 MiB | 537.3 MiB | 6592 |
| 1.0 GiB | before-input | 572.2 MiB | 1.3 MiB | 6583 |
| 1.0 GiB | after-input | 1596.2 MiB | 1025.3 MiB | 6501 |
| 1.0 GiB | after-size | 1113.0 MiB | 1073.5 MiB | 7294 |
jsonOutput=benchmarks/results/20260417T170231Z-industry-publication/file-publication.json
