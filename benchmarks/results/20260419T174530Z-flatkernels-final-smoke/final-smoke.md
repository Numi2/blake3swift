[0/1] Planning build
Building for production...
[0/3] Write sources
[1/3] Write swift-version--58304C5D6DBC2206.txt
[3/4] Compiling Blake3 BLAKE3.swift
[3/5] Write Objects.LinkFileList
[4/5] Linking blake3-bench
Build of product 'blake3-bench' complete! (19.07s)
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
| 64.0 KiB | cpu | scalar | 1.21 | 1.12 | 1.21 | 1.21 | ok |
| 64.0 KiB | cpu | single-simd | 1.78 | 1.64 | 1.78 | 1.78 | ok |
| 64.0 KiB | cpu | parallel | 1.77 | 1.77 | 1.78 | 1.78 | ok |
| 64.0 KiB | official-c | one-shot | 2.20 | 1.83 | 2.20 | 2.20 | ok |
| 64.0 KiB | cpu | context-auto | 1.60 | 1.03 | 1.74 | 1.74 | ok |
| 64.0 KiB | blake3 | default-auto | 1.90 | 1.90 | 1.91 | 1.91 | ok |
| 64.0 KiB | cpu-file | read | 0.43 | 0.43 | 0.45 | 0.45 | ok |
| 64.0 KiB | cpu-file | mmap | 0.81 | 0.80 | 0.82 | 0.82 | ok |
| 1.0 MiB | cpu | scalar | 0.99 | 0.95 | 1.11 | 1.11 | ok |
| 1.0 MiB | cpu | single-simd | 1.68 | 1.50 | 1.72 | 1.72 | ok |
| 1.0 MiB | cpu | parallel | 5.76 | 5.57 | 5.81 | 5.81 | ok |
| 1.0 MiB | official-c | one-shot | 2.21 | 2.20 | 2.34 | 2.34 | ok |
| 1.0 MiB | cpu | context-auto | 5.90 | 5.74 | 5.96 | 5.96 | ok |
| 1.0 MiB | blake3 | default-auto | 5.72 | 1.72 | 5.92 | 5.92 | ok |
| 1.0 MiB | cpu-file | read | 1.42 | 1.34 | 2.33 | 2.33 | ok |
| 1.0 MiB | cpu-file | mmap | 1.04 | 1.04 | 1.05 | 1.05 | ok |
| 16.0 MiB | cpu | scalar | 1.09 | 1.07 | 1.09 | 1.09 | ok |
| 16.0 MiB | cpu | single-simd | 1.73 | 1.71 | 1.74 | 1.74 | ok |
| 16.0 MiB | cpu | parallel | 9.07 | 7.99 | 9.17 | 9.17 | ok |
| 16.0 MiB | official-c | one-shot | 2.19 | 2.10 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 9.00 | 8.29 | 9.04 | 9.04 | ok |
| 16.0 MiB | blake3 | default-auto | 5.77 | 4.21 | 11.09 | 11.09 | ok |
| 16.0 MiB | cpu-file | read | 4.34 | 4.03 | 4.53 | 4.53 | ok |
| 16.0 MiB | cpu-file | mmap | 1.04 | 1.04 | 1.04 | 1.04 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 64.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 64.0 MiB | cpu | parallel | 9.96 | 9.69 | 10.08 | 10.08 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 10.16 | 9.90 | 10.42 | 10.42 | ok |
| 64.0 MiB | blake3 | default-auto | 12.76 | 8.27 | 22.79 | 22.79 | ok |
| 64.0 MiB | cpu-file | read | 5.22 | 4.44 | 5.42 | 5.42 | ok |
| 64.0 MiB | cpu-file | mmap | 1.05 | 1.05 | 1.05 | 1.05 | ok |
jsonOutput=benchmarks/results/20260419T174530Z-flatkernels-final-smoke/final-smoke.json
jsonValidation=ok path=benchmarks/results/20260419T174530Z-flatkernels-final-smoke/final-smoke.json
