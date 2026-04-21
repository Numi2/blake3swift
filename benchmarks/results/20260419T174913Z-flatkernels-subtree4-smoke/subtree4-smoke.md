[0/1] Planning build
Building for production...
[0/3] Write sources
[1/3] Write swift-version--58304C5D6DBC2206.txt
[3/4] Compiling Blake3 BLAKE3.swift
[4/6] Compiling Blake3BenchmarkSupport BLAKE3OfficialC.swift
[5/7] Compiling Blake3Benchmark main.swift
[5/7] Write Objects.LinkFileList
[6/7] Linking blake3-bench
Build of product 'blake3-bench' complete! (24.90s)
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
| 64.0 KiB | cpu | scalar | 0.94 | 0.91 | 1.02 | 1.02 | ok |
| 64.0 KiB | cpu | single-simd | 1.62 | 1.61 | 1.62 | 1.62 | ok |
| 64.0 KiB | cpu | parallel | 1.61 | 1.61 | 1.61 | 1.61 | ok |
| 64.0 KiB | official-c | one-shot | 1.97 | 1.97 | 1.98 | 1.98 | ok |
| 64.0 KiB | cpu | context-auto | 1.60 | 1.13 | 1.60 | 1.60 | ok |
| 64.0 KiB | blake3 | default-auto | 1.66 | 1.65 | 1.67 | 1.67 | ok |
| 1.0 MiB | cpu | scalar | 1.07 | 1.06 | 1.08 | 1.08 | ok |
| 1.0 MiB | cpu | single-simd | 1.74 | 1.73 | 1.76 | 1.76 | ok |
| 1.0 MiB | cpu | parallel | 4.79 | 4.29 | 5.70 | 5.70 | ok |
| 1.0 MiB | official-c | one-shot | 2.23 | 2.18 | 2.24 | 2.24 | ok |
| 1.0 MiB | cpu | context-auto | 4.29 | 4.20 | 4.52 | 4.52 | ok |
| 1.0 MiB | blake3 | default-auto | 4.37 | 4.34 | 5.29 | 5.29 | ok |
| 16.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 16.0 MiB | cpu | single-simd | 1.79 | 1.78 | 1.82 | 1.82 | ok |
| 16.0 MiB | cpu | parallel | 8.82 | 7.44 | 9.15 | 9.15 | ok |
| 16.0 MiB | official-c | one-shot | 2.19 | 2.17 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 8.86 | 8.63 | 9.18 | 9.18 | ok |
| 16.0 MiB | blake3 | default-auto | 8.70 | 3.17 | 10.68 | 10.68 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.09 | 1.09 | ok |
| 64.0 MiB | cpu | single-simd | 1.77 | 1.76 | 1.79 | 1.79 | ok |
| 64.0 MiB | cpu | parallel | 9.89 | 8.91 | 10.25 | 10.25 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.16 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 10.06 | 8.43 | 10.26 | 10.26 | ok |
| 64.0 MiB | blake3 | default-auto | 13.23 | 8.83 | 24.29 | 24.29 | ok |
jsonOutput=benchmarks/results/20260419T174913Z-flatkernels-subtree4-smoke/subtree4-smoke.json
jsonValidation=ok path=benchmarks/results/20260419T174913Z-flatkernels-subtree4-smoke/subtree4-smoke.json
