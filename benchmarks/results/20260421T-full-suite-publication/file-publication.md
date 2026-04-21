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
file-metal-staged-read includes: timed file open/stat, bounded reads directly into shared Metal staging buffers, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.13 | 1.04 | 1.14 | 1.14 | ok |
| 16.0 MiB | cpu | single-simd | 1.71 | 1.68 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 9.87 | 9.02 | 10.24 | 10.24 | ok |
| 16.0 MiB | official-c | one-shot | 2.15 | 2.09 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 9.63 | 7.79 | 10.64 | 10.64 | ok |
| 16.0 MiB | blake3 | default-auto | 17.57 | 8.66 | 19.09 | 19.09 | ok |
| 16.0 MiB | cpu-file | read | 4.76 | 4.14 | 4.85 | 4.85 | ok |
| 16.0 MiB | cpu-file | mmap | 1.09 | 1.08 | 1.09 | 1.09 | ok |
| 16.0 MiB | cpu-file | mmap-parallel | 8.70 | 6.95 | 9.17 | 9.17 | ok |
| 16.0 MiB | metal-file | metal-mmap-gpu | 4.76 | 1.18 | 5.15 | 5.15 | ok |
| 16.0 MiB | metal-file | metal-tiled-mmap-gpu | 1.72 | 1.35 | 2.53 | 2.53 | ok |
| 16.0 MiB | metal-file | metal-staged-read-gpu | 3.19 | 2.10 | 3.49 | 3.49 | ok |
| 64.0 MiB | cpu | scalar | 1.13 | 1.10 | 1.14 | 1.14 | ok |
| 64.0 MiB | cpu | single-simd | 1.70 | 1.66 | 1.73 | 1.73 | ok |
| 64.0 MiB | cpu | parallel | 10.91 | 10.82 | 11.61 | 11.61 | ok |
| 64.0 MiB | official-c | one-shot | 2.14 | 2.09 | 2.16 | 2.16 | ok |
| 64.0 MiB | cpu | context-auto | 10.92 | 9.83 | 11.28 | 11.28 | ok |
| 64.0 MiB | blake3 | default-auto | 20.87 | 10.42 | 25.04 | 25.04 | ok |
| 64.0 MiB | cpu-file | read | 5.41 | 4.82 | 5.58 | 5.58 | ok |
| 64.0 MiB | cpu-file | mmap | 1.04 | 0.92 | 1.08 | 1.08 | ok |
| 64.0 MiB | cpu-file | mmap-parallel | 8.32 | 7.60 | 9.02 | 9.02 | ok |
| 64.0 MiB | metal-file | metal-mmap-gpu | 3.82 | 3.57 | 4.27 | 4.27 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.65 | 3.42 | 3.95 | 3.95 | ok |
| 64.0 MiB | metal-file | metal-staged-read-gpu | 3.84 | 3.64 | 5.66 | 5.66 | ok |
| 256.0 MiB | cpu | scalar | 1.14 | 0.75 | 1.15 | 1.15 | ok |
| 256.0 MiB | cpu | single-simd | 1.74 | 1.73 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 11.67 | 11.46 | 11.99 | 11.99 | ok |
| 256.0 MiB | official-c | one-shot | 2.16 | 2.16 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 11.73 | 11.61 | 11.95 | 11.95 | ok |
| 256.0 MiB | blake3 | default-auto | 20.74 | 12.73 | 24.29 | 24.29 | ok |
| 256.0 MiB | cpu-file | read | 8.16 | 8.01 | 8.21 | 8.21 | ok |
| 256.0 MiB | cpu-file | mmap | 1.10 | 1.00 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu-file | mmap-parallel | 9.80 | 9.66 | 10.01 | 10.01 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 8.51 | 8.15 | 9.40 | 9.40 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.22 | 3.87 | 6.16 | 6.16 | ok |
| 256.0 MiB | metal-file | metal-staged-read-gpu | 6.90 | 4.91 | 7.65 | 7.65 | ok |
| 512.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.15 | 1.15 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.68 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 11.97 | 7.82 | 12.08 | 12.08 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.18 | 2.18 | ok |
| 512.0 MiB | cpu | context-auto | 11.93 | 11.77 | 12.02 | 12.02 | ok |
| 512.0 MiB | blake3 | default-auto | 28.29 | 21.60 | 31.22 | 31.22 | ok |
| 512.0 MiB | cpu-file | read | 8.81 | 8.53 | 8.88 | 8.88 | ok |
| 512.0 MiB | cpu-file | mmap | 1.09 | 1.03 | 1.09 | 1.09 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 9.67 | 9.50 | 9.85 | 9.85 | ok |
| 512.0 MiB | metal-file | metal-mmap-gpu | 4.56 | 0.51 | 5.56 | 5.56 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 3.52 | 2.26 | 6.99 | 6.99 | ok |
| 512.0 MiB | metal-file | metal-staged-read-gpu | 8.60 | 7.29 | 9.43 | 9.43 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.11 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 11.95 | 11.34 | 12.15 | 12.15 | ok |
| 1.0 GiB | official-c | one-shot | 2.16 | 2.16 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 11.92 | 11.02 | 12.08 | 12.08 | ok |
| 1.0 GiB | blake3 | default-auto | 32.74 | 31.14 | 33.25 | 33.25 | ok |
| 1.0 GiB | cpu-file | read | 8.87 | 6.52 | 9.12 | 9.12 | ok |
| 1.0 GiB | cpu-file | mmap | 1.08 | 1.08 | 1.08 | 1.08 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 9.69 | 9.46 | 9.73 | 9.73 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 3.74 | 0.99 | 4.92 | 4.92 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 0.37 | 0.31 | 0.44 | 0.44 | ok |
| 1.0 GiB | metal-file | metal-staged-read-gpu | 1.41 | 1.12 | 1.62 | 1.62 | ok |
jsonOutput=benchmarks/results/20260421T-full-suite-publication/file-publication.json
