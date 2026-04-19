[0/1] Planning build
Building for production...
[0/3] Write sources
[1/3] Write swift-version--58304C5D6DBC2206.txt
[3/4] Compiling Blake3 BLAKE3.swift
[3/5] Write Objects.LinkFileList
[4/5] Linking blake3-bench
Build of product 'blake3-bench' complete! (134.26s)
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
| 64.0 KiB | cpu | scalar | 1.07 | 0.96 | 1.08 | 1.08 | ok |
| 64.0 KiB | cpu | single-simd | 1.62 | 1.51 | 1.62 | 1.62 | ok |
| 64.0 KiB | cpu | parallel | 1.61 | 1.26 | 1.61 | 1.61 | ok |
| 64.0 KiB | official-c | one-shot | 1.86 | 1.59 | 2.02 | 2.02 | ok |
| 64.0 KiB | cpu | context-auto | 1.60 | 1.26 | 1.61 | 1.61 | ok |
| 64.0 KiB | blake3 | default-auto | 1.61 | 1.60 | 1.61 | 1.61 | ok |
| 1.0 MiB | cpu | scalar | 1.09 | 1.07 | 1.11 | 1.11 | ok |
| 1.0 MiB | cpu | single-simd | 1.71 | 1.68 | 1.71 | 1.71 | ok |
| 1.0 MiB | cpu | parallel | 4.41 | 4.23 | 5.65 | 5.65 | ok |
| 1.0 MiB | official-c | one-shot | 2.15 | 2.13 | 2.16 | 2.16 | ok |
| 1.0 MiB | cpu | context-auto | 4.39 | 4.33 | 4.64 | 4.64 | ok |
| 1.0 MiB | blake3 | default-auto | 4.53 | 4.16 | 5.30 | 5.30 | ok |
| 16.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 16.0 MiB | cpu | single-simd | 1.77 | 1.75 | 1.79 | 1.79 | ok |
| 16.0 MiB | cpu | parallel | 8.95 | 8.47 | 9.13 | 9.13 | ok |
| 16.0 MiB | official-c | one-shot | 2.19 | 2.17 | 2.20 | 2.20 | ok |
| 16.0 MiB | cpu | context-auto | 9.02 | 7.82 | 9.24 | 9.24 | ok |
| 16.0 MiB | blake3 | default-auto | 9.62 | 2.84 | 10.30 | 10.30 | ok |
| 64.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.77 | 1.77 | ok |
| 64.0 MiB | cpu | parallel | 9.68 | 9.23 | 10.35 | 10.35 | ok |
| 64.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.19 | 2.19 | ok |
| 64.0 MiB | cpu | context-auto | 10.06 | 8.96 | 10.20 | 10.20 | ok |
| 64.0 MiB | blake3 | default-auto | 23.94 | 14.69 | 44.83 | 44.83 | ok |
jsonOutput=benchmarks/results/20260419T175703Z-flatkernels-unrolledchunk-smoke/unrolledchunk-smoke.json
jsonValidation=ok path=benchmarks/results/20260419T175703Z-flatkernels-unrolledchunk-smoke/unrolledchunk-smoke.json
