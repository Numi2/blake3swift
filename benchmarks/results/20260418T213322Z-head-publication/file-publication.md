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
| 16.0 MiB | cpu | scalar | 0.86 | 0.85 | 0.89 | 0.89 | ok |
| 16.0 MiB | cpu | single-simd | 1.43 | 1.21 | 1.53 | 1.53 | ok |
| 16.0 MiB | cpu | parallel | 6.76 | 5.63 | 7.37 | 7.37 | ok |
| 16.0 MiB | official-c | one-shot | 1.74 | 1.30 | 2.06 | 2.06 | ok |
| 16.0 MiB | cpu | context-auto | 6.29 | 4.76 | 6.82 | 6.82 | ok |
| 16.0 MiB | blake3 | default-auto | 17.71 | 5.82 | 20.74 | 20.74 | ok |
| 16.0 MiB | cpu-file | read | 0.81 | 0.76 | 0.86 | 0.86 | ok |
| 16.0 MiB | cpu-file | mmap | 0.83 | 0.78 | 0.88 | 0.88 | ok |
| 16.0 MiB | cpu-file | mmap-parallel | 5.10 | 4.36 | 5.50 | 5.50 | ok |
| 16.0 MiB | metal-file | metal-mmap-gpu | 1.99 | 0.74 | 6.80 | 6.80 | ok |
| 16.0 MiB | metal-file | metal-tiled-mmap-gpu | 2.55 | 1.63 | 2.79 | 2.79 | ok |
| 64.0 MiB | cpu | scalar | 0.56 | 0.46 | 0.82 | 0.82 | ok |
| 64.0 MiB | cpu | single-simd | 1.51 | 1.49 | 1.57 | 1.57 | ok |
| 64.0 MiB | cpu | parallel | 7.32 | 6.18 | 8.48 | 8.48 | ok |
| 64.0 MiB | official-c | one-shot | 1.90 | 1.71 | 1.94 | 1.94 | ok |
| 64.0 MiB | cpu | context-auto | 7.22 | 6.38 | 8.47 | 8.47 | ok |
| 64.0 MiB | blake3 | default-auto | 13.73 | 7.66 | 30.59 | 30.59 | ok |
| 64.0 MiB | cpu-file | read | 0.88 | 0.87 | 0.92 | 0.92 | ok |
| 64.0 MiB | cpu-file | mmap | 0.91 | 0.87 | 0.94 | 0.94 | ok |
| 64.0 MiB | cpu-file | mmap-parallel | 4.88 | 4.57 | 5.13 | 5.13 | ok |
| 64.0 MiB | metal-file | metal-mmap-gpu | 5.44 | 3.75 | 6.98 | 6.98 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.94 | 3.41 | 4.68 | 4.68 | ok |
| 256.0 MiB | cpu | scalar | 0.90 | 0.57 | 0.94 | 0.94 | ok |
| 256.0 MiB | cpu | single-simd | 1.59 | 1.52 | 1.60 | 1.60 | ok |
| 256.0 MiB | cpu | parallel | 8.13 | 7.57 | 9.23 | 9.23 | ok |
| 256.0 MiB | official-c | one-shot | 1.92 | 1.78 | 1.98 | 1.98 | ok |
| 256.0 MiB | cpu | context-auto | 7.88 | 7.34 | 9.10 | 9.10 | ok |
| 256.0 MiB | blake3 | default-auto | 26.23 | 22.60 | 31.73 | 31.73 | ok |
| 256.0 MiB | cpu-file | read | 0.76 | 0.50 | 0.90 | 0.90 | ok |
| 256.0 MiB | cpu-file | mmap | 0.66 | 0.50 | 0.88 | 0.88 | ok |
| 256.0 MiB | cpu-file | mmap-parallel | 2.49 | 1.50 | 2.70 | 2.70 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 6.72 | 5.37 | 7.21 | 7.21 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.76 | 3.21 | 5.54 | 5.54 | ok |
| 512.0 MiB | cpu | scalar | 0.89 | 0.40 | 0.94 | 0.94 | ok |
| 512.0 MiB | cpu | single-simd | 1.19 | 0.86 | 1.53 | 1.53 | ok |
| 512.0 MiB | cpu | parallel | 8.10 | 6.52 | 9.25 | 9.25 | ok |
| 512.0 MiB | official-c | one-shot | 1.47 | 1.25 | 1.86 | 1.86 | ok |
| 512.0 MiB | cpu | context-auto | 7.86 | 6.92 | 8.91 | 8.91 | ok |
| 512.0 MiB | blake3 | default-auto | 37.26 | 34.84 | 40.55 | 40.55 | ok |
| 512.0 MiB | cpu-file | read | 0.61 | 0.51 | 0.86 | 0.86 | ok |
| 512.0 MiB | cpu-file | mmap | 0.72 | 0.54 | 0.87 | 0.87 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 4.47 | 4.32 | 4.60 | 4.60 | ok |
| 512.0 MiB | metal-file | metal-mmap-gpu | 7.12 | 5.79 | 7.46 | 7.46 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 6.03 | 5.68 | 6.57 | 6.57 | ok |
| 1.0 GiB | cpu | scalar | 0.88 | 0.57 | 0.94 | 0.94 | ok |
| 1.0 GiB | cpu | single-simd | 1.56 | 1.54 | 1.58 | 1.58 | ok |
| 1.0 GiB | cpu | parallel | 9.35 | 8.89 | 9.68 | 9.68 | ok |
| 1.0 GiB | official-c | one-shot | 1.90 | 1.82 | 1.92 | 1.92 | ok |
| 1.0 GiB | cpu | context-auto | 9.16 | 8.80 | 9.40 | 9.40 | ok |
| 1.0 GiB | blake3 | default-auto | 37.74 | 36.07 | 40.20 | 40.20 | ok |
| 1.0 GiB | cpu-file | read | 0.89 | 0.59 | 0.91 | 0.91 | ok |
| 1.0 GiB | cpu-file | mmap | 0.62 | 0.53 | 0.91 | 0.91 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 4.24 | 2.27 | 4.47 | 4.47 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 7.53 | 6.52 | 8.35 | 8.35 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 6.60 | 4.46 | 7.17 | 7.17 | ok |
jsonOutput=benchmarks/results/20260418T213322Z-head-publication/file-publication.json
