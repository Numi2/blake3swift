BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=e2e
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
sizes=64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=sha256
cryptokit-sha256 includes: timed CryptoKit SHA256 init, update(bufferPointer:), and finalize over existing Swift bytes; cross-algorithm baseline, not BLAKE3 parity; emitted after BLAKE3 rows to avoid perturbing Metal timings

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.79 | 1.79 | 1.80 | 1.80 | ok |
| 64.0 MiB | cpu | parallel | 10.04 | 8.34 | 10.32 | 10.32 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.15 | 2.19 | 2.19 | ok |
| 64.0 MiB | cpu | context-auto | 9.65 | 8.90 | 10.13 | 10.13 | ok |
| 64.0 MiB | blake3 | default-auto | 26.04 | 11.91 | 32.48 | 32.48 | ok |
| 64.0 MiB | metal | e2e-auto | 13.25 | 9.16 | 17.75 | 17.75 | ok |
| 64.0 MiB | metal | e2e-gpu | 13.92 | 11.67 | 16.87 | 16.87 | ok |
| 64.0 MiB | cryptokit | sha256 | 3.02 | 2.96 | 3.10 | 3.10 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.14 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.77 | 1.77 | ok |
| 256.0 MiB | cpu | parallel | 10.27 | 9.74 | 10.39 | 10.39 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.42 | 7.92 | 10.60 | 10.60 | ok |
| 256.0 MiB | blake3 | default-auto | 30.69 | 26.76 | 32.61 | 32.61 | ok |
| 256.0 MiB | metal | e2e-auto | 16.11 | 15.67 | 18.18 | 18.18 | ok |
| 256.0 MiB | metal | e2e-gpu | 16.79 | 15.11 | 17.47 | 17.47 | ok |
| 256.0 MiB | cryptokit | sha256 | 2.94 | 2.93 | 2.95 | 2.95 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.11 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 10.73 | 10.37 | 11.07 | 11.07 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 11.18 | 10.23 | 11.54 | 11.54 | ok |
| 512.0 MiB | blake3 | default-auto | 33.70 | 32.91 | 34.16 | 34.16 | ok |
| 512.0 MiB | metal | e2e-auto | 16.37 | 15.86 | 18.23 | 18.23 | ok |
| 512.0 MiB | metal | e2e-gpu | 16.72 | 16.07 | 18.24 | 18.24 | ok |
| 512.0 MiB | cryptokit | sha256 | 2.91 | 2.90 | 2.93 | 2.93 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 1.0 GiB | cpu | parallel | 11.37 | 11.15 | 11.45 | 11.45 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 11.04 | 10.99 | 11.48 | 11.48 | ok |
| 1.0 GiB | blake3 | default-auto | 36.35 | 33.31 | 44.31 | 44.31 | ok |
| 1.0 GiB | metal | e2e-auto | 18.07 | 16.81 | 19.45 | 19.45 | ok |
| 1.0 GiB | metal | e2e-gpu | 18.57 | 16.85 | 19.26 | 19.26 | ok |
| 1.0 GiB | cryptokit | sha256 | 2.89 | 2.87 | 2.90 | 2.90 | ok |
jsonOutput=benchmarks/results/20260421T-page-aligned-upload-record/page-aligned-upload-record.json
jsonValidation=ok path=benchmarks/results/20260421T-page-aligned-upload-record/page-aligned-upload-record.json
