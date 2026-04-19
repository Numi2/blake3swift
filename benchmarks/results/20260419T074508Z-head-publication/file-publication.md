BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=67108864
metalModes=
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
fileModes=read,mmap,mmap-parallel,metal-mmap,metal-tiled-mmap
file-read includes: timed file open, streaming read loop, CPU update/finalize, close; benchmark file creation excluded
file-mmap includes: timed file open/stat, mmap, bounded tiled CPU hash, finalize, munmap, close; benchmark file creation excluded
file-mmap-parallel includes: timed file open/stat, mmap, bounded tiled CPU parallel hash, finalize, munmap, close; benchmark file creation excluded
file-metal-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, GPU hash wait, digest read, munmap, close; benchmark file creation excluded
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 16.0 MiB | cpu | single-simd | 1.74 | 1.71 | 1.77 | 1.77 | ok |
| 16.0 MiB | cpu | parallel | 8.84 | 7.54 | 9.17 | 9.17 | ok |
| 16.0 MiB | official-c | one-shot | 2.18 | 2.13 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 8.36 | 6.88 | 9.23 | 9.23 | ok |
| 16.0 MiB | blake3 | default-auto | 8.39 | 3.06 | 9.22 | 9.22 | ok |
| 16.0 MiB | cpu-file | read | 1.02 | 1.01 | 1.02 | 1.02 | ok |
| 16.0 MiB | cpu-file | mmap | 1.05 | 1.04 | 1.05 | 1.05 | ok |
| 16.0 MiB | cpu-file | mmap-parallel | 6.10 | 5.13 | 6.30 | 6.30 | ok |
| 16.0 MiB | metal-file | metal-mmap-gpu | 4.26 | 1.15 | 5.70 | 5.70 | ok |
| 16.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.83 | 1.61 | 4.48 | 4.48 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.92 | 8.37 | 10.24 | 10.24 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.19 | 2.19 | ok |
| 64.0 MiB | cpu | context-auto | 9.49 | 7.64 | 10.18 | 10.18 | ok |
| 64.0 MiB | blake3 | default-auto | 23.15 | 10.94 | 30.51 | 30.51 | ok |
| 64.0 MiB | cpu-file | read | 1.02 | 1.01 | 1.02 | 1.02 | ok |
| 64.0 MiB | cpu-file | mmap | 1.04 | 1.04 | 1.05 | 1.05 | ok |
| 64.0 MiB | cpu-file | mmap-parallel | 5.73 | 5.50 | 5.88 | 5.88 | ok |
| 64.0 MiB | metal-file | metal-mmap-gpu | 7.10 | 3.48 | 7.95 | 7.95 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.83 | 3.08 | 4.66 | 4.66 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.48 | 9.74 | 10.92 | 10.92 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.11 | 8.51 | 10.69 | 10.69 | ok |
| 256.0 MiB | blake3 | default-auto | 36.44 | 28.25 | 42.63 | 42.63 | ok |
| 256.0 MiB | cpu-file | read | 1.02 | 1.02 | 1.02 | 1.02 | ok |
| 256.0 MiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 256.0 MiB | cpu-file | mmap-parallel | 5.86 | 5.70 | 5.90 | 5.90 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 7.35 | 6.25 | 8.03 | 8.03 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.28 | 5.08 | 6.64 | 6.64 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 512.0 MiB | cpu | parallel | 10.88 | 10.66 | 11.05 | 11.05 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.12 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 10.90 | 10.45 | 11.06 | 11.06 | ok |
| 512.0 MiB | blake3 | default-auto | 37.84 | 35.53 | 41.04 | 41.04 | ok |
| 512.0 MiB | cpu-file | read | 1.02 | 1.02 | 1.02 | 1.02 | ok |
| 512.0 MiB | cpu-file | mmap | 1.04 | 0.96 | 1.04 | 1.04 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 5.80 | 5.68 | 5.85 | 5.85 | ok |
| 512.0 MiB | metal-file | metal-mmap-gpu | 7.32 | 6.66 | 7.99 | 7.99 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 6.26 | 5.88 | 6.94 | 6.94 | ok |
| 1.0 GiB | cpu | scalar | 1.09 | 1.08 | 1.09 | 1.09 | ok |
| 1.0 GiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 11.26 | 10.79 | 11.38 | 11.38 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 11.12 | 10.74 | 11.35 | 11.35 | ok |
| 1.0 GiB | blake3 | default-auto | 39.84 | 38.54 | 41.44 | 41.44 | ok |
| 1.0 GiB | cpu-file | read | 1.02 | 1.02 | 1.02 | 1.02 | ok |
| 1.0 GiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 5.81 | 5.76 | 5.88 | 5.88 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 8.27 | 6.93 | 8.35 | 8.35 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 6.81 | 6.46 | 7.37 | 7.37 | ok |
jsonOutput=benchmarks/results/20260419T074508Z-head-publication/file-publication.json
