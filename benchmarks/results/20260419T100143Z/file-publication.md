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
| 16.0 MiB | cpu | scalar | 0.95 | 0.90 | 1.03 | 1.03 | ok |
| 16.0 MiB | cpu | single-simd | 1.49 | 1.42 | 1.68 | 1.68 | ok |
| 16.0 MiB | cpu | parallel | 5.26 | 4.42 | 6.43 | 6.43 | ok |
| 16.0 MiB | official-c | one-shot | 1.80 | 1.51 | 1.93 | 1.93 | ok |
| 16.0 MiB | cpu | context-auto | 4.72 | 3.46 | 5.94 | 5.94 | ok |
| 16.0 MiB | blake3 | default-auto | 11.24 | 4.61 | 11.75 | 11.75 | ok |
| 16.0 MiB | cpu-file | read | 0.99 | 0.98 | 1.00 | 1.00 | ok |
| 16.0 MiB | cpu-file | mmap | 1.03 | 1.01 | 1.03 | 1.03 | ok |
| 16.0 MiB | cpu-file | mmap-parallel | 5.99 | 5.39 | 6.21 | 6.21 | ok |
| 16.0 MiB | metal-file | metal-mmap-gpu | 5.87 | 2.53 | 6.25 | 6.25 | ok |
| 16.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.95 | 1.70 | 4.31 | 4.31 | ok |
| 64.0 MiB | cpu | scalar | 1.06 | 0.96 | 1.08 | 1.08 | ok |
| 64.0 MiB | cpu | single-simd | 1.71 | 1.69 | 1.74 | 1.74 | ok |
| 64.0 MiB | cpu | parallel | 9.64 | 8.04 | 10.18 | 10.18 | ok |
| 64.0 MiB | official-c | one-shot | 2.13 | 2.13 | 2.15 | 2.15 | ok |
| 64.0 MiB | cpu | context-auto | 9.82 | 8.53 | 10.25 | 10.25 | ok |
| 64.0 MiB | blake3 | default-auto | 33.62 | 16.88 | 37.75 | 37.75 | ok |
| 64.0 MiB | cpu-file | read | 1.01 | 1.00 | 1.02 | 1.02 | ok |
| 64.0 MiB | cpu-file | mmap | 1.03 | 1.02 | 1.03 | 1.03 | ok |
| 64.0 MiB | cpu-file | mmap-parallel | 5.73 | 5.55 | 6.07 | 6.07 | ok |
| 64.0 MiB | metal-file | metal-mmap-gpu | 6.72 | 4.86 | 9.90 | 9.90 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.66 | 3.57 | 6.30 | 6.30 | ok |
| 256.0 MiB | cpu | scalar | 1.10 | 1.07 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.77 | 1.75 | 1.78 | 1.78 | ok |
| 256.0 MiB | cpu | parallel | 10.41 | 9.86 | 10.87 | 10.87 | ok |
| 256.0 MiB | official-c | one-shot | 2.19 | 2.14 | 2.20 | 2.20 | ok |
| 256.0 MiB | cpu | context-auto | 10.73 | 9.83 | 10.87 | 10.87 | ok |
| 256.0 MiB | blake3 | default-auto | 47.53 | 33.03 | 55.02 | 55.02 | ok |
| 256.0 MiB | cpu-file | read | 1.04 | 1.02 | 1.04 | 1.04 | ok |
| 256.0 MiB | cpu-file | mmap | 1.06 | 1.05 | 1.06 | 1.06 | ok |
| 256.0 MiB | cpu-file | mmap-parallel | 5.63 | 5.47 | 5.83 | 5.83 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 10.44 | 9.00 | 11.13 | 11.13 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 8.10 | 6.71 | 9.21 | 9.21 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.04 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.78 | 1.77 | 1.78 | 1.78 | ok |
| 512.0 MiB | cpu | parallel | 11.07 | 10.85 | 11.35 | 11.35 | ok |
| 512.0 MiB | official-c | one-shot | 2.19 | 2.19 | 2.19 | 2.19 | ok |
| 512.0 MiB | cpu | context-auto | 10.91 | 10.55 | 11.42 | 11.42 | ok |
| 512.0 MiB | blake3 | default-auto | 55.16 | 49.12 | 56.51 | 56.51 | ok |
| 512.0 MiB | cpu-file | read | 1.04 | 1.03 | 1.04 | 1.04 | ok |
| 512.0 MiB | cpu-file | mmap | 1.05 | 1.05 | 1.05 | 1.05 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 6.01 | 5.98 | 6.11 | 6.11 | ok |
| 512.0 MiB | metal-file | metal-mmap-gpu | 9.39 | 7.89 | 10.96 | 10.96 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 7.94 | 6.90 | 8.93 | 8.93 | ok |
| 1.0 GiB | cpu | scalar | 1.10 | 1.10 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.77 | 1.77 | 1.78 | 1.78 | ok |
| 1.0 GiB | cpu | parallel | 10.93 | 10.28 | 11.22 | 11.22 | ok |
| 1.0 GiB | official-c | one-shot | 2.19 | 2.18 | 2.20 | 2.20 | ok |
| 1.0 GiB | cpu | context-auto | 11.50 | 11.23 | 11.70 | 11.70 | ok |
| 1.0 GiB | blake3 | default-auto | 41.19 | 38.50 | 43.87 | 43.87 | ok |
| 1.0 GiB | cpu-file | read | 1.03 | 1.01 | 1.03 | 1.03 | ok |
| 1.0 GiB | cpu-file | mmap | 1.05 | 1.04 | 1.05 | 1.05 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 5.92 | 4.93 | 5.97 | 5.97 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 3.24 | 0.33 | 6.44 | 6.44 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 0.32 | 0.25 | 0.42 | 0.42 | ok |
jsonOutput=benchmarks/results/20260419T100143Z/file-publication.json
