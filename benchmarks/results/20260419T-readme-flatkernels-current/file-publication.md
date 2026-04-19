BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none
fileModes=read,mmap,mmap-parallel,metal-mmap,metal-tiled-mmap,metal-staged-read
file-read includes: timed file open/stat, two-buffer bounded read loop, overlapped CPU subtree reductions for regular files, finalize, close; benchmark file creation excluded
file-mmap includes: timed file open/stat, mmap, bounded tiled CPU hash, finalize, munmap, close; benchmark file creation excluded
file-mmap-parallel includes: timed file open/stat, mmap, direct CPU parallel tree hash up to the one-shot cap, bounded tiled fallback above it, finalize, munmap, close; benchmark file creation excluded
file-metal-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, GPU hash wait, digest read, munmap, close; benchmark file creation excluded
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded
file-metal-staged-read includes: timed file open/stat, bounded read directly into shared Metal staging buffers, async tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.11 | 0.91 | 1.13 | 1.13 | ok |
| 16.0 MiB | cpu | single-simd | 1.73 | 1.68 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 8.95 | 7.62 | 9.25 | 9.25 | ok |
| 16.0 MiB | official-c | one-shot | 2.17 | 2.14 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 9.11 | 8.70 | 9.23 | 9.23 | ok |
| 16.0 MiB | blake3 | default-auto | 9.85 | 4.29 | 10.47 | 10.47 | ok |
| 16.0 MiB | cpu-file | read | 4.31 | 3.96 | 4.48 | 4.48 | ok |
| 16.0 MiB | cpu-file | mmap | 1.10 | 1.10 | 1.12 | 1.12 | ok |
| 16.0 MiB | cpu-file | mmap-parallel | 7.79 | 6.93 | 8.43 | 8.43 | ok |
| 16.0 MiB | metal-file | metal-mmap-gpu | 6.07 | 3.78 | 7.57 | 7.57 | ok |
| 16.0 MiB | metal-file | metal-tiled-mmap-gpu | 1.68 | 1.26 | 1.88 | 1.88 | ok |
| 16.0 MiB | metal-file | metal-staged-read-gpu | 2.76 | 1.87 | 3.76 | 3.76 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.75 | 1.75 | ok |
| 64.0 MiB | cpu | parallel | 10.10 | 9.26 | 10.24 | 10.24 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 9.76 | 9.27 | 10.26 | 10.26 | ok |
| 64.0 MiB | blake3 | default-auto | 14.17 | 7.92 | 18.36 | 18.36 | ok |
| 64.0 MiB | cpu-file | read | 5.00 | 4.57 | 5.30 | 5.30 | ok |
| 64.0 MiB | cpu-file | mmap | 1.11 | 1.10 | 1.11 | 1.11 | ok |
| 64.0 MiB | cpu-file | mmap-parallel | 8.34 | 7.68 | 8.83 | 8.83 | ok |
| 64.0 MiB | metal-file | metal-mmap-gpu | 5.91 | 4.73 | 7.19 | 7.19 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 2.67 | 2.51 | 2.99 | 2.99 | ok |
| 64.0 MiB | metal-file | metal-staged-read-gpu | 3.76 | 3.76 | 4.04 | 4.04 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.74 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.67 | 10.23 | 11.30 | 11.30 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.15 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.44 | 10.31 | 11.10 | 11.10 | ok |
| 256.0 MiB | blake3 | default-auto | 35.98 | 31.53 | 41.15 | 41.15 | ok |
| 256.0 MiB | cpu-file | read | 7.00 | 6.91 | 7.04 | 7.04 | ok |
| 256.0 MiB | cpu-file | mmap | 1.11 | 1.10 | 1.11 | 1.11 | ok |
| 256.0 MiB | cpu-file | mmap-parallel | 9.26 | 8.08 | 9.69 | 9.69 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 9.08 | 6.74 | 10.06 | 10.06 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 6.42 | 5.47 | 6.75 | 6.75 | ok |
| 256.0 MiB | metal-file | metal-staged-read-gpu | 9.63 | 8.81 | 10.01 | 10.01 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.77 | 1.77 | ok |
| 512.0 MiB | cpu | parallel | 11.12 | 10.98 | 11.25 | 11.25 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 11.02 | 10.91 | 11.28 | 11.28 | ok |
| 512.0 MiB | blake3 | default-auto | 48.39 | 35.51 | 54.38 | 54.38 | ok |
| 512.0 MiB | cpu-file | read | 7.53 | 7.52 | 7.54 | 7.54 | ok |
| 512.0 MiB | cpu-file | mmap | 1.10 | 1.10 | 1.11 | 1.11 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 9.63 | 8.93 | 9.67 | 9.67 | ok |
| 512.0 MiB | metal-file | metal-mmap-gpu | 9.25 | 8.39 | 9.63 | 9.63 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.77 | 5.64 | 6.24 | 6.24 | ok |
| 512.0 MiB | metal-file | metal-staged-read-gpu | 10.09 | 9.94 | 10.93 | 10.93 | ok |
| 1.0 GiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.76 | 1.75 | 1.77 | 1.77 | ok |
| 1.0 GiB | cpu | parallel | 11.57 | 11.21 | 12.02 | 12.02 | ok |
| 1.0 GiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 11.60 | 11.27 | 11.85 | 11.85 | ok |
| 1.0 GiB | blake3 | default-auto | 31.08 | 26.14 | 35.18 | 35.18 | ok |
| 1.0 GiB | cpu-file | read | 7.69 | 7.60 | 7.89 | 7.89 | ok |
| 1.0 GiB | cpu-file | mmap | 1.11 | 1.11 | 1.11 | 1.11 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 10.05 | 9.99 | 10.21 | 10.21 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 3.03 | 0.59 | 7.30 | 7.30 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 4.12 | 0.96 | 4.24 | 4.24 | ok |
| 1.0 GiB | metal-file | metal-staged-read-gpu | 2.25 | 1.77 | 2.29 | 2.29 | ok |
jsonOutput=benchmarks/results/20260419T-readme-flatkernels-current/file-publication.json
