BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=33554432
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=33554432
metalTileByteCount=16777216
metalModes=
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
fileModes=read,mmap,mmap-parallel,metal-mmap,metal-tiled-mmap
file-read includes: timed file open, streaming read loop, CPU update/finalize, close; benchmark file creation excluded
file-mmap includes: timed file open/stat, mmap, bounded tiled CPU hash, finalize, munmap, close; benchmark file creation excluded
file-mmap-parallel includes: timed file open/stat, mmap, bounded tiled CPU parallel hash, finalize, munmap, close; benchmark file creation excluded
file-metal-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, GPU hash wait, digest read, munmap, close; benchmark file creation excluded
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.52 | 8.79 | 10.07 | 10.07 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.22 | 8.37 | 10.26 | 10.26 | ok |
| 64.0 MiB | blake3 | default-auto | 24.42 | 16.04 | 28.99 | 28.99 | ok |
| 64.0 MiB | cpu-file | read | 1.01 | 1.01 | 1.01 | 1.01 | ok |
| 64.0 MiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 64.0 MiB | cpu-file | mmap-parallel | 5.64 | 5.49 | 5.86 | 5.86 | ok |
| 64.0 MiB | metal-file | metal-mmap-gpu | 3.99 | 3.20 | 4.22 | 4.22 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.92 | 3.38 | 4.24 | 4.24 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 0.99 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.18 | 9.77 | 10.58 | 10.58 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.03 | 9.62 | 10.91 | 10.91 | ok |
| 256.0 MiB | blake3 | default-auto | 28.43 | 26.15 | 37.70 | 37.70 | ok |
| 256.0 MiB | cpu-file | read | 1.01 | 1.01 | 1.01 | 1.01 | ok |
| 256.0 MiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 256.0 MiB | cpu-file | mmap-parallel | 5.82 | 5.70 | 5.92 | 5.92 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 6.94 | 5.89 | 7.48 | 7.48 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.22 | 3.63 | 4.83 | 4.83 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 512.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 10.57 | 10.02 | 10.83 | 10.83 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 512.0 MiB | cpu | context-auto | 10.36 | 9.51 | 10.90 | 10.90 | ok |
| 512.0 MiB | blake3 | default-auto | 27.67 | 24.95 | 28.99 | 28.99 | ok |
| 512.0 MiB | cpu-file | read | 1.01 | 1.01 | 1.01 | 1.01 | ok |
| 512.0 MiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 5.79 | 5.48 | 5.96 | 5.96 | ok |
| 512.0 MiB | metal-file | metal-mmap-gpu | 7.40 | 7.00 | 7.57 | 7.57 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.41 | 3.74 | 4.61 | 4.61 | ok |
| 1.0 GiB | cpu | scalar | 1.09 | 1.02 | 1.09 | 1.09 | ok |
| 1.0 GiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 1.0 GiB | cpu | parallel | 11.16 | 10.71 | 11.37 | 11.37 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.09 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 10.96 | 10.81 | 11.70 | 11.70 | ok |
| 1.0 GiB | blake3 | default-auto | 32.04 | 30.59 | 33.89 | 33.89 | ok |
| 1.0 GiB | cpu-file | read | 1.01 | 1.01 | 1.01 | 1.01 | ok |
| 1.0 GiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 5.75 | 5.72 | 5.84 | 5.84 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 7.60 | 6.85 | 8.03 | 8.03 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 3.39 | 3.08 | 3.75 | 3.75 | ok |
jsonOutput=benchmarks/results/20260418T193423Z-publication-private/file-publication.json
