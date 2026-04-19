BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=67108864
metalModes=
sizes=256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=none
fileModes=read,mmap-parallel,metal-mmap,metal-tiled-mmap,metal-staged-read
file-read includes: timed file open, streaming read loop, CPU update/finalize, close; benchmark file creation excluded
file-mmap-parallel includes: timed file open/stat, mmap, bounded tiled CPU parallel hash, finalize, munmap, close; benchmark file creation excluded
file-metal-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, GPU hash wait, digest read, munmap, close; benchmark file creation excluded
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded
file-metal-staged-read includes: timed file open/stat, bounded read directly into a shared Metal staging buffer, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.10 | 0.94 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.79 | 1.79 | 1.79 | 1.79 | ok |
| 256.0 MiB | cpu | parallel | 10.37 | 10.22 | 10.70 | 10.70 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.16 | 2.19 | 2.19 | ok |
| 256.0 MiB | cpu | context-auto | 10.23 | 9.83 | 10.56 | 10.56 | ok |
| 256.0 MiB | blake3 | default-auto | 37.92 | 31.58 | 53.84 | 53.84 | ok |
| 256.0 MiB | cpu-file | read | 1.03 | 1.03 | 1.03 | 1.03 | ok |
| 256.0 MiB | cpu-file | mmap-parallel | 6.05 | 3.76 | 6.19 | 6.19 | ok |
| 256.0 MiB | metal-file | metal-mmap-gpu | 9.91 | 9.74 | 10.26 | 10.26 | ok |
| 256.0 MiB | metal-file | metal-tiled-mmap-gpu | 6.24 | 5.44 | 6.43 | 6.43 | ok |
| 256.0 MiB | metal-file | metal-staged-read-gpu | 4.47 | 4.27 | 6.52 | 6.52 | ok |
| 512.0 MiB | cpu | scalar | 1.10 | 1.10 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.78 | 1.75 | 1.79 | 1.79 | ok |
| 512.0 MiB | cpu | parallel | 11.20 | 10.82 | 11.54 | 11.54 | ok |
| 512.0 MiB | official-c | one-shot | 2.19 | 2.08 | 2.20 | 2.20 | ok |
| 512.0 MiB | cpu | context-auto | 11.41 | 11.19 | 11.76 | 11.76 | ok |
| 512.0 MiB | blake3 | default-auto | 55.85 | 53.74 | 57.05 | 57.05 | ok |
| 512.0 MiB | cpu-file | read | 1.03 | 1.03 | 1.03 | 1.03 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 6.10 | 6.05 | 6.15 | 6.15 | ok |
| 512.0 MiB | metal-file | metal-mmap-gpu | 8.64 | 7.61 | 8.95 | 8.95 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 7.83 | 7.72 | 7.90 | 7.90 | ok |
| 512.0 MiB | metal-file | metal-staged-read-gpu | 8.69 | 8.43 | 9.33 | 9.33 | ok |
| 1.0 GiB | cpu | scalar | 1.10 | 1.10 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.78 | 1.68 | 1.79 | 1.79 | ok |
| 1.0 GiB | cpu | parallel | 11.73 | 10.92 | 12.00 | 12.00 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.17 | 2.19 | 2.19 | ok |
| 1.0 GiB | cpu | context-auto | 11.37 | 11.28 | 11.55 | 11.55 | ok |
| 1.0 GiB | blake3 | default-auto | 33.69 | 25.93 | 36.34 | 36.34 | ok |
| 1.0 GiB | cpu-file | read | 1.01 | 0.99 | 1.02 | 1.02 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 5.79 | 5.68 | 5.83 | 5.83 | ok |
| 1.0 GiB | metal-file | metal-mmap-gpu | 3.35 | 0.60 | 4.81 | 4.81 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 3.74 | 0.74 | 4.59 | 4.59 | ok |
| 1.0 GiB | metal-file | metal-staged-read-gpu | 2.12 | 2.01 | 2.19 | 2.19 | ok |
jsonOutput=benchmarks/results/20260419T145459Z-final-file-staged-read/file-final.json
