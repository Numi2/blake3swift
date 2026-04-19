[0/1] Planning build
Building for production...
[0/2] Write swift-version--58304C5D6DBC2206.txt
Build of product 'blake3-bench' complete! (0.13s)
BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=
sizes=64.0 KiB, 1.0 MiB, 16.0 MiB, 64.0 MiB
cryptoKitModes=none
fileModes=mmap,read
file-mmap includes: timed file open/stat, mmap, bounded tiled CPU hash, finalize, munmap, close; benchmark file creation excluded
file-read includes: timed file open/stat, two-buffer bounded read loop, overlapped CPU subtree reductions for regular files, finalize, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 KiB | cpu | scalar | 1.02 | 0.91 | 1.02 | 1.02 | ok |
| 64.0 KiB | cpu | single-simd | 1.63 | 1.60 | 1.63 | 1.63 | ok |
| 64.0 KiB | cpu | parallel | 1.62 | 1.62 | 1.62 | 1.62 | ok |
| 64.0 KiB | official-c | one-shot | 2.01 | 1.67 | 2.02 | 2.02 | ok |
| 64.0 KiB | cpu | context-auto | 1.44 | 1.17 | 1.50 | 1.50 | ok |
| 64.0 KiB | blake3 | default-auto | 1.66 | 1.65 | 1.66 | 1.66 | ok |
| 64.0 KiB | cpu-file | read | 0.47 | 0.42 | 0.54 | 0.54 | ok |
| 64.0 KiB | cpu-file | mmap | 0.80 | 0.75 | 0.82 | 0.82 | ok |
| 1.0 MiB | cpu | scalar | 1.07 | 1.05 | 1.07 | 1.07 | ok |
| 1.0 MiB | cpu | single-simd | 1.70 | 1.68 | 1.72 | 1.72 | ok |
| 1.0 MiB | cpu | parallel | 5.95 | 5.95 | 5.99 | 5.99 | ok |
| 1.0 MiB | official-c | one-shot | 2.16 | 2.11 | 2.19 | 2.19 | ok |
| 1.0 MiB | cpu | context-auto | 4.57 | 4.57 | 4.58 | 4.58 | ok |
| 1.0 MiB | blake3 | default-auto | 4.66 | 4.37 | 5.35 | 5.35 | ok |
| 1.0 MiB | cpu-file | read | 2.52 | 2.30 | 2.55 | 2.55 | ok |
| 1.0 MiB | cpu-file | mmap | 1.03 | 1.01 | 1.05 | 1.05 | ok |
| 16.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.17 | 1.17 | ok |
| 16.0 MiB | cpu | single-simd | 1.91 | 1.90 | 1.92 | 1.92 | ok |
| 16.0 MiB | cpu | parallel | 8.87 | 7.94 | 9.10 | 9.10 | ok |
| 16.0 MiB | official-c | one-shot | 2.36 | 2.29 | 2.39 | 2.39 | ok |
| 16.0 MiB | cpu | context-auto | 9.15 | 8.76 | 9.23 | 9.23 | ok |
| 16.0 MiB | blake3 | default-auto | 9.52 | 8.82 | 9.60 | 9.60 | ok |
| 16.0 MiB | cpu-file | read | 4.30 | 3.60 | 4.70 | 4.70 | ok |
| 16.0 MiB | cpu-file | mmap | 1.11 | 1.10 | 1.11 | 1.11 | ok |
| 64.0 MiB | cpu | scalar | 1.14 | 1.13 | 1.15 | 1.15 | ok |
| 64.0 MiB | cpu | single-simd | 1.90 | 1.90 | 1.91 | 1.91 | ok |
| 64.0 MiB | cpu | parallel | 10.10 | 8.47 | 10.25 | 10.25 | ok |
| 64.0 MiB | official-c | one-shot | 2.36 | 2.35 | 2.38 | 2.38 | ok |
| 64.0 MiB | cpu | context-auto | 10.18 | 9.23 | 10.24 | 10.24 | ok |
| 64.0 MiB | blake3 | default-auto | 12.64 | 10.91 | 13.08 | 13.08 | ok |
| 64.0 MiB | cpu-file | read | 4.84 | 4.82 | 4.90 | 4.90 | ok |
| 64.0 MiB | cpu-file | mmap | 1.09 | 1.07 | 1.09 | 1.09 | ok |
jsonOutput=benchmarks/results/20260419T173204Z-flatkernels-baseline/baseline.json
jsonValidation=ok path=benchmarks/results/20260419T173204Z-flatkernels-baseline/baseline.json
