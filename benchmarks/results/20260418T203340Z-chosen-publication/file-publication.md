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
| 16.0 MiB | cpu | scalar | 1.09 | 1.03 | 1.10 | 1.10 | ok |
| 16.0 MiB | cpu | single-simd | 1.68 | 1.64 | 1.71 | 1.71 | ok |
| 16.0 MiB | cpu | parallel | 7.19 | 6.36 | 7.71 | 7.71 | ok |
| 16.0 MiB | official-c | one-shot | 1.92 | 1.63 | 2.07 | 2.07 | ok |
| 16.0 MiB | cpu | context-auto | 7.30 | 5.23 | 7.71 | 7.71 | ok |
| 16.0 MiB | blake3 | default-auto | 14.89 | 7.20 | 20.27 | 20.27 | ok |
| 16.0 MiB | cpu-file | read | 0.98 | 0.35 | 1.01 | 1.01 | ok |
| 16.0 MiB | cpu-file | mmap | 1.03 | 0.99 | 1.03 | 1.03 | ok |
| 16.0 MiB | cpu-file | mmap-parallel | 5.85 | 4.99 | 6.00 | 6.00 | ok |
| 16.0 MiB | metal-file | metal-mmap-gpu | 4.24 | 1.22 | 4.77 | 4.77 | ok |
| 16.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.81 | 2.06 | 4.41 | 4.41 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 1.07 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.70 | 1.69 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.50 | 8.29 | 10.21 | 10.21 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 9.11 | 8.36 | 10.20 | 10.20 | ok |
| 64.0 MiB | blake3 | default-auto | 10.55 | 8.60 | 12.51 | 12.51 | ok |
| 64.0 MiB | cpu-file | read | 1.02 | 1.01 | 1.02 | 1.02 | ok |
| 64.0 MiB | cpu-file | mmap | 1.04 | 1.04 | 1.05 | 1.05 | ok |
| 64.0 MiB | cpu-file | mmap-parallel | 5.75 | 5.52 | 5.94 | 5.94 | ok |
| 64.0 MiB | metal-file | metal-mmap-gpu | 3.88 | 3.66 | 4.28 | 4.28 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.08 | 3.70 | 5.35 | 5.35 | ok |
| 256.0 MiB | cpu | scalar | 1.02 | 0.90 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 9.29 | 8.02 | 10.23 | 10.23 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.16 | 2.19 | 2.19 | ok |
| 256.0 MiB | cpu | context-auto | 10.00 | 9.43 | 10.60 | 10.60 | ok |
| 256.0 MiB | blake3 | default-auto | 36.34 | 18.83 | 40.93 | 40.93 | ok |
| 256.0 MiB | cpu-file | read | 1.02 | 1.02 | 1.02 | 1.02 | ok |
| 256.0 MiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 256.0 MiB | cpu-file | mmap-parallel | 5.72 | 5.59 | 5.82 | 5.82 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 7.63 | 7.38 | 8.41 | 8.41 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.50 | 4.84 | 6.66 | 6.66 | ok |
| 512.0 MiB | cpu | scalar | 1.07 | 1.03 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 10.63 | 9.98 | 11.15 | 11.15 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 512.0 MiB | cpu | context-auto | 10.43 | 9.81 | 10.80 | 10.80 | ok |
| 512.0 MiB | blake3 | default-auto | 38.49 | 34.09 | 43.45 | 43.45 | ok |
| 512.0 MiB | cpu-file | read | 1.01 | 0.97 | 1.02 | 1.02 | ok |
| 512.0 MiB | cpu-file | mmap | 1.04 | 1.02 | 1.04 | 1.04 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 5.73 | 5.40 | 5.81 | 5.81 | ok |
| 512.0 MiB | metal-file | metal-mmap-gpu | 7.16 | 6.68 | 7.56 | 7.56 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 6.08 | 5.68 | 6.68 | 6.68 | ok |
| 1.0 GiB | cpu | scalar | 1.09 | 1.05 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.75 | 1.63 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 10.09 | 8.91 | 11.30 | 11.30 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.10 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 10.32 | 9.69 | 11.14 | 11.14 | ok |
| 1.0 GiB | blake3 | default-auto | 36.78 | 31.75 | 38.16 | 38.16 | ok |
| 1.0 GiB | cpu-file | read | 1.01 | 0.98 | 1.02 | 1.02 | ok |
| 1.0 GiB | cpu-file | mmap | 1.04 | 1.00 | 1.04 | 1.04 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 5.66 | 5.33 | 5.79 | 5.79 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 7.74 | 7.24 | 8.57 | 8.57 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 6.88 | 6.71 | 6.94 | 6.94 | ok |
jsonOutput=benchmarks/results/20260418T203340Z-chosen-publication/file-publication.json
