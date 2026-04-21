Building for production...
[0/11] Write sources
[3/11] Write swift-version--58304C5D6DBC2206.txt
[4/12] Compiling CBLAKE3 cblake3_bridge.c
[5/12] Compiling CBLAKE3 blake3_dispatch.c
[6/12] Compiling CBLAKE3 blake3.c
[7/12] Compiling CBLAKE3 blake3_portable.c
[8/12] Compiling CBLAKE3 blake3_neon_wrapper.c
[10/12] Compiling Blake3 BLAKE3.swift
[11/13] Compiling Blake3BenchmarkSupport BLAKE3OfficialC.swift
[12/14] Compiling Blake3Benchmark main.swift
[12/14] Write Objects.LinkFileList
[13/14] Linking blake3-bench
Build of product 'blake3-bench' complete! (27.66s)
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
| 64.0 KiB | cpu | scalar | 1.02 | 1.02 | 1.10 | 1.10 | ok |
| 64.0 KiB | cpu | single-simd | 1.61 | 1.40 | 1.63 | 1.63 | ok |
| 64.0 KiB | cpu | parallel | 1.61 | 1.50 | 1.62 | 1.62 | ok |
| 64.0 KiB | official-c | one-shot | 2.02 | 2.01 | 2.02 | 2.02 | ok |
| 64.0 KiB | cpu | context-auto | 1.60 | 1.04 | 1.61 | 1.61 | ok |
| 64.0 KiB | blake3 | default-auto | 1.60 | 1.60 | 1.61 | 1.61 | ok |
| 1.0 MiB | cpu | scalar | 1.05 | 1.00 | 1.05 | 1.05 | ok |
| 1.0 MiB | cpu | single-simd | 1.70 | 1.51 | 1.71 | 1.71 | ok |
| 1.0 MiB | cpu | parallel | 5.46 | 5.25 | 5.78 | 5.78 | ok |
| 1.0 MiB | official-c | one-shot | 2.17 | 2.08 | 2.20 | 2.20 | ok |
| 1.0 MiB | cpu | context-auto | 5.51 | 5.38 | 5.85 | 5.85 | ok |
| 1.0 MiB | blake3 | default-auto | 5.96 | 5.93 | 6.01 | 6.01 | ok |
| 16.0 MiB | cpu | scalar | 1.09 | 1.08 | 1.10 | 1.10 | ok |
| 16.0 MiB | cpu | single-simd | 1.77 | 1.74 | 1.79 | 1.79 | ok |
| 16.0 MiB | cpu | parallel | 8.90 | 7.64 | 8.98 | 8.98 | ok |
| 16.0 MiB | official-c | one-shot | 2.15 | 2.13 | 2.19 | 2.19 | ok |
| 16.0 MiB | cpu | context-auto | 8.46 | 7.62 | 9.04 | 9.04 | ok |
| 16.0 MiB | blake3 | default-auto | 8.61 | 6.39 | 11.26 | 11.26 | ok |
| 64.0 MiB | cpu | scalar | 1.09 | 1.09 | 1.10 | 1.10 | ok |
| 64.0 MiB | cpu | single-simd | 1.77 | 1.77 | 1.78 | 1.78 | ok |
| 64.0 MiB | cpu | parallel | 10.06 | 9.20 | 10.18 | 10.18 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.17 | 2.19 | 2.19 | ok |
| 64.0 MiB | cpu | context-auto | 10.03 | 9.83 | 10.21 | 10.21 | ok |
| 64.0 MiB | blake3 | default-auto | 13.73 | 9.13 | 27.68 | 27.68 | ok |
jsonOutput=benchmarks/results/20260419T175020Z-flatkernels-nosubtree4-smoke/nosubtree4-smoke.json
jsonValidation=ok path=benchmarks/results/20260419T175020Z-flatkernels-nosubtree4-smoke/nosubtree4-smoke.json
