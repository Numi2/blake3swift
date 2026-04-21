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
| 64.0 MiB | cpu | scalar | 1.16 | 0.96 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.78 | 1.76 | 1.80 | 1.80 | ok |
| 64.0 MiB | cpu | parallel | 10.18 | 9.16 | 10.22 | 10.22 | ok |
| 64.0 MiB | official-c | one-shot | 2.19 | 2.19 | 2.20 | 2.20 | ok |
| 64.0 MiB | cpu | context-auto | 10.18 | 9.84 | 10.44 | 10.44 | ok |
| 64.0 MiB | blake3 | default-auto | 25.29 | 12.31 | 29.94 | 29.94 | ok |
| 64.0 MiB | metal | e2e-auto | 14.51 | 10.93 | 18.06 | 18.06 | ok |
| 64.0 MiB | metal | e2e-gpu | 17.71 | 13.04 | 18.11 | 18.11 | ok |
| 64.0 MiB | cryptokit | sha256 | 3.10 | 3.02 | 3.11 | 3.11 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.15 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.70 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 8.45 | 7.17 | 8.76 | 8.76 | ok |
| 256.0 MiB | official-c | one-shot | 2.15 | 2.13 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 8.99 | 8.42 | 9.25 | 9.25 | ok |
| 256.0 MiB | blake3 | default-auto | 32.66 | 25.62 | 36.14 | 36.14 | ok |
| 256.0 MiB | metal | e2e-auto | 15.23 | 14.51 | 16.71 | 16.71 | ok |
| 256.0 MiB | metal | e2e-gpu | 16.54 | 10.93 | 17.40 | 17.40 | ok |
| 256.0 MiB | cryptokit | sha256 | 2.80 | 2.78 | 2.85 | 2.85 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.11 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.76 | 1.74 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 11.34 | 10.98 | 11.67 | 11.67 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 11.09 | 11.07 | 11.54 | 11.54 | ok |
| 512.0 MiB | blake3 | default-auto | 31.30 | 30.56 | 31.94 | 31.94 | ok |
| 512.0 MiB | metal | e2e-auto | 16.69 | 15.08 | 17.76 | 17.76 | ok |
| 512.0 MiB | metal | e2e-gpu | 16.52 | 15.51 | 17.39 | 17.39 | ok |
| 512.0 MiB | cryptokit | sha256 | 2.90 | 2.88 | 2.91 | 2.91 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.14 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.62 | 1.42 | 1.74 | 1.74 | ok |
| 1.0 GiB | cpu | parallel | 10.03 | 8.54 | 11.28 | 11.28 | ok |
| 1.0 GiB | official-c | one-shot | 2.16 | 2.12 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 11.07 | 11.01 | 11.08 | 11.08 | ok |
| 1.0 GiB | blake3 | default-auto | 38.35 | 33.99 | 44.69 | 44.69 | ok |
| 1.0 GiB | metal | e2e-auto | 17.62 | 16.87 | 19.72 | 19.72 | ok |
| 1.0 GiB | metal | e2e-gpu | 17.78 | 16.17 | 20.31 | 20.31 | ok |
| 1.0 GiB | cryptokit | sha256 | 2.86 | 2.80 | 2.89 | 2.89 | ok |
jsonOutput=benchmarks/results/20260421T-size-aware-upload-record/size-aware-upload-record.json
jsonValidation=ok path=benchmarks/results/20260421T-size-aware-upload-record/size-aware-upload-record.json
