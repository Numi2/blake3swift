BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=67108864
metalModes=
sizes=512.0 MiB, 1.0 GiB
cryptoKitModes=none
fileModes=mmap-parallel,metal-tiled-mmap,metal-staged-read
file-mmap-parallel includes: timed file open/stat, mmap, bounded tiled CPU parallel hash, finalize, munmap, close; benchmark file creation excluded
file-metal-tiled-mmap includes: timed file open/stat, mmap, no-copy Metal buffer wrapper, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, munmap, close; benchmark file creation excluded
file-metal-staged-read includes: timed file open/stat, bounded read directly into a shared Metal staging buffer, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 512.0 MiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.83 | 1.80 | 1.84 | 1.84 | ok |
| 512.0 MiB | cpu | parallel | 10.88 | 10.77 | 10.91 | 10.91 | ok |
| 512.0 MiB | official-c | one-shot | 2.27 | 2.24 | 2.27 | 2.27 | ok |
| 512.0 MiB | cpu | context-auto | 11.05 | 10.75 | 11.29 | 11.29 | ok |
| 512.0 MiB | blake3 | default-auto | 57.29 | 51.86 | 58.15 | 58.15 | ok |
| 512.0 MiB | cpu-file | mmap-parallel | 5.83 | 5.81 | 5.87 | 5.87 | ok |
| 512.0 MiB | metal-file | metal-tiled-mmap-gpu | 8.00 | 6.82 | 8.21 | 8.21 | ok |
| 512.0 MiB | metal-file | metal-staged-read-gpu | 9.79 | 8.77 | 9.84 | 9.84 | ok |
| 1.0 GiB | cpu | scalar | 1.10 | 1.09 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.82 | 1.73 | 1.82 | 1.82 | ok |
| 1.0 GiB | cpu | parallel | 10.98 | 10.97 | 11.14 | 11.14 | ok |
| 1.0 GiB | official-c | one-shot | 2.20 | 2.20 | 2.22 | 2.22 | ok |
| 1.0 GiB | cpu | context-auto | 10.74 | 10.67 | 11.38 | 11.38 | ok |
| 1.0 GiB | blake3 | default-auto | 54.82 | 54.11 | 55.55 | 55.55 | ok |
| 1.0 GiB | cpu-file | mmap-parallel | 5.87 | 5.87 | 5.95 | 5.95 | ok |
| 1.0 GiB | metal-file | metal-tiled-mmap-gpu | 7.77 | 6.65 | 8.81 | 8.81 | ok |
| 1.0 GiB | metal-file | metal-staged-read-gpu | 10.00 | 9.80 | 10.05 | 10.05 | ok |
jsonOutput=benchmarks/results/20260419T145223Z-subtree-file-check/subtree-file-check.json
