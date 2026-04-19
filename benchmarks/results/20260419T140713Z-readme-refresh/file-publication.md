BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=67108864
metalModes=
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none
fileModes=read,mmap,mmap-parallel,metal-mmap,metal-tiled-mmap
file-read includes: timed file open, streaming read loop, CPU update/finalize, close; benchmark file creation excluded
file-mmap includes: timed file open/stat, mmap, bounded tiled CPU hash, finalize, munmap, close; benchmark file creation excluded
file-mmap-parallel includes: timed file open/stat, mmap, bounded tiled CPU parallel hash, finalize, munmap, close; benchmark file creation excluded
file-metal-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, GPU hash wait, digest read, munmap, close; benchmark file creation excluded
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.06 | 1.05 | 1.08 | 1.08 | ok |
| 16.0 MiB | cpu | single-simd | 1.73 | 1.62 | 1.76 | 1.76 | ok |
| 16.0 MiB | cpu | parallel | 8.53 | 6.07 | 9.21 | 9.21 | ok |
| 16.0 MiB | official-c | one-shot | 2.16 | 2.13 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 7.71 | 6.56 | 9.18 | 9.18 | ok |
| 16.0 MiB | blake3 | default-auto | 11.70 | 8.27 | 22.69 | 22.69 | ok |
| 16.0 MiB | cpu-file | read | 1.00 | 0.97 | 1.02 | 1.02 | ok |
| 16.0 MiB | cpu-file | mmap | 1.02 | 1.01 | 1.04 | 1.04 | ok |
| 16.0 MiB | cpu-file | mmap-parallel | 6.13 | 5.57 | 6.27 | 6.27 | ok |
| 16.0 MiB | metal-file | metal-mmap-gpu | 5.35 | 1.75 | 5.93 | 5.93 | ok |
| 16.0 MiB | metal-file | metal-tiled-mmap-gpu | 4.14 | 1.79 | 4.39 | 4.39 | ok |
| 64.0 MiB | cpu | scalar | 1.07 | 1.06 | 1.08 | 1.08 | ok |
| 64.0 MiB | cpu | single-simd | 1.72 | 1.71 | 1.72 | 1.72 | ok |
| 64.0 MiB | cpu | parallel | 9.33 | 8.86 | 10.36 | 10.36 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.14 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 10.21 | 9.52 | 10.38 | 10.38 | ok |
| 64.0 MiB | blake3 | default-auto | 31.86 | 11.59 | 34.99 | 34.99 | ok |
| 64.0 MiB | cpu-file | read | 1.02 | 1.02 | 1.03 | 1.03 | ok |
| 64.0 MiB | cpu-file | mmap | 1.05 | 1.04 | 1.05 | 1.05 | ok |
| 64.0 MiB | cpu-file | mmap-parallel | 6.00 | 5.63 | 6.25 | 6.25 | ok |
| 64.0 MiB | metal-file | metal-mmap-gpu | 5.22 | 4.67 | 7.11 | 7.11 | ok |
| 64.0 MiB | metal-file | metal-tiled-mmap-gpu | 5.65 | 3.54 | 6.27 | 6.27 | ok |
| 256.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 256.0 MiB | cpu | single-simd | 1.77 | 1.76 | 1.78 | 1.78 | ok |
| 256.0 MiB | cpu | parallel | 10.80 | 9.87 | 11.17 | 11.17 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 10.54 | 10.06 | 10.74 | 10.74 | ok |
| 256.0 MiB | blake3 | default-auto | 40.92 | 20.41 | 52.65 | 52.65 | ok |
| 256.0 MiB | cpu-file | read | 1.02 | 1.01 | 1.02 | 1.02 | ok |
| 256.0 MiB | cpu-file | mmap | 1.04 | 0.94 | 1.04 | 1.04 | ok |
| 256.0 MiB | cpu-file | mmap-parallel | 6.04 | 5.75 | 6.12 | 6.12 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 8.60 | 8.08 | 9.82 | 9.82 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 7.32 | 5.67 | 7.68 | 7.68 | ok |
| 512.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 512.0 MiB | cpu | single-simd | 1.77 | 1.77 | 1.78 | 1.78 | ok |
| 512.0 MiB | cpu | parallel | 11.21 | 10.76 | 11.53 | 11.53 | ok |
| 512.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 512.0 MiB | cpu | context-auto | 10.99 | 10.61 | 11.34 | 11.34 | ok |
| 512.0 MiB | blake3 | default-auto | 36.11 | 33.18 | 39.01 | 39.01 | ok |
| 512.0 MiB | cpu-file | read | 1.02 | 1.02 | 1.02 | 1.02 | ok |
| 512.0 MiB | cpu-file | mmap | 1.05 | 1.02 | 1.05 | 1.05 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 6.03 | 5.90 | 6.09 | 6.09 | ok |
| 512.0 MiB | metal-file | metal-mmap-gpu | 8.40 | 7.22 | 9.78 | 9.78 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 7.52 | 7.13 | 7.82 | 7.82 | ok |
| 1.0 GiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 1.0 GiB | cpu | single-simd | 1.77 | 1.76 | 1.78 | 1.78 | ok |
| 1.0 GiB | cpu | parallel | 11.47 | 11.16 | 11.88 | 11.88 | ok |
| 1.0 GiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 11.74 | 11.26 | 11.95 | 11.95 | ok |
| 1.0 GiB | blake3 | default-auto | 49.73 | 46.93 | 52.64 | 52.64 | ok |
| 1.0 GiB | cpu-file | read | 1.02 | 1.02 | 1.03 | 1.03 | ok |
| 1.0 GiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 5.95 | 5.91 | 5.97 | 5.97 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 1.70 | 0.44 | 7.32 | 7.32 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 0.37 | 0.30 | 0.49 | 0.49 | ok |
jsonOutput=benchmarks/results/20260419T140713Z-readme-refresh/file-publication.json
