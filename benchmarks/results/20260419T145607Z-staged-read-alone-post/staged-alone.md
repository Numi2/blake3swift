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
fileModes=metal-staged-read
file-metal-staged-read includes: timed file open/stat, bounded read directly into a shared Metal staging buffer, tiled GPU chunk-CV dispatches, CPU CV-stack merge, digest read, close; benchmark file creation excluded

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 512.0 MiB | cpu | scalar | 1.09 | 1.06 | 1.09 | 1.09 | ok |
| 512.0 MiB | cpu | single-simd | 1.79 | 1.78 | 1.80 | 1.80 | ok |
| 512.0 MiB | cpu | parallel | 10.81 | 10.04 | 11.56 | 11.56 | ok |
| 512.0 MiB | official-c | one-shot | 2.19 | 2.18 | 2.19 | 2.19 | ok |
| 512.0 MiB | cpu | context-auto | 10.67 | 10.03 | 11.09 | 11.09 | ok |
| 512.0 MiB | blake3 | default-auto | 37.85 | 36.78 | 38.88 | 38.88 | ok |
| 512.0 MiB | metal-file | metal-staged-read-gpu | 6.08 | 4.99 | 7.43 | 7.43 | ok |
| 1.0 GiB | cpu | scalar | 1.09 | 1.08 | 1.09 | 1.09 | ok |
| 1.0 GiB | cpu | single-simd | 1.75 | 1.71 | 1.76 | 1.76 | ok |
| 1.0 GiB | cpu | parallel | 10.67 | 10.42 | 10.78 | 10.78 | ok |
| 1.0 GiB | official-c | one-shot | 2.16 | 2.14 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 11.32 | 9.49 | 11.40 | 11.40 | ok |
| 1.0 GiB | blake3 | default-auto | 50.28 | 49.00 | 53.64 | 53.64 | ok |
| 1.0 GiB | metal-file | metal-staged-read-gpu | 6.73 | 6.43 | 8.55 | 8.55 | ok |
jsonOutput=benchmarks/results/20260419T145607Z-staged-read-alone-post/staged-alone.json
