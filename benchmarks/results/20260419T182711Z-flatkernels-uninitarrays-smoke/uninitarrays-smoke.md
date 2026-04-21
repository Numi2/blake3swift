[0/1] Planning build
Building for production...
[0/3] Write sources
[1/3] Write swift-version--58304C5D6DBC2206.txt
[3/4] Compiling Blake3 BLAKE3.swift
[3/5] Write Objects.LinkFileList
[4/5] Linking blake3-bench
Build of product 'blake3-bench' complete! (146.34s)
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

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 KiB | cpu | scalar | 1.11 | 1.01 | 1.11 | 1.11 | ok |
| 64.0 KiB | cpu | single-simd | 1.63 | 1.56 | 1.66 | 1.66 | ok |
| 64.0 KiB | cpu | parallel | 1.64 | 1.41 | 1.65 | 1.65 | ok |
| 64.0 KiB | official-c | one-shot | 2.09 | 2.08 | 2.10 | 2.10 | ok |
| 64.0 KiB | cpu | context-auto | 1.64 | 1.30 | 1.64 | 1.64 | ok |
| 64.0 KiB | blake3 | default-auto | 1.65 | 1.64 | 1.66 | 1.66 | ok |
| 1.0 MiB | cpu | scalar | 1.11 | 1.09 | 1.13 | 1.13 | ok |
| 1.0 MiB | cpu | single-simd | 1.72 | 1.68 | 1.73 | 1.73 | ok |
| 1.0 MiB | cpu | parallel | 5.36 | 4.91 | 5.55 | 5.55 | ok |
| 1.0 MiB | official-c | one-shot | 2.22 | 2.11 | 2.23 | 2.23 | ok |
| 1.0 MiB | cpu | context-auto | 5.49 | 5.35 | 5.95 | 5.95 | ok |
| 1.0 MiB | blake3 | default-auto | 5.51 | 4.82 | 5.97 | 5.97 | ok |
| 16.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.77 | 1.77 | 1.78 | 1.78 | ok |
| 16.0 MiB | cpu | parallel | 9.09 | 8.75 | 9.25 | 9.25 | ok |
| 16.0 MiB | official-c | one-shot | 2.18 | 2.16 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 9.08 | 7.69 | 9.17 | 9.17 | ok |
| 16.0 MiB | blake3 | default-auto | 8.40 | 7.76 | 9.50 | 9.50 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.77 | 1.75 | 1.77 | 1.77 | ok |
| 64.0 MiB | cpu | parallel | 10.11 | 8.86 | 10.27 | 10.27 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 10.25 | 9.86 | 10.38 | 10.38 | ok |
| 64.0 MiB | blake3 | default-auto | 14.00 | 9.10 | 25.49 | 25.49 | ok |
jsonOutput=benchmarks/results/20260419T182711Z-flatkernels-uninitarrays-smoke/uninitarrays-smoke.json
jsonValidation=ok path=benchmarks/results/20260419T182711Z-flatkernels-uninitarrays-smoke/uninitarrays-smoke.json
