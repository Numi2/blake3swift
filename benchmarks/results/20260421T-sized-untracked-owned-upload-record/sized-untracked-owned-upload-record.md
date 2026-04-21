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
| 64.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.70 | 1.33 | 1.74 | 1.74 | ok |
| 64.0 MiB | cpu | parallel | 9.89 | 9.01 | 10.30 | 10.30 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.14 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.56 | 8.80 | 10.26 | 10.26 | ok |
| 64.0 MiB | blake3 | default-auto | 27.86 | 20.56 | 31.64 | 31.64 | ok |
| 64.0 MiB | metal | e2e-auto | 16.67 | 13.91 | 17.35 | 17.35 | ok |
| 64.0 MiB | metal | e2e-gpu | 17.67 | 14.99 | 18.11 | 18.11 | ok |
| 64.0 MiB | cryptokit | sha256 | 2.87 | 2.84 | 2.99 | 2.99 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.13 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.09 | 9.87 | 10.64 | 10.64 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.14 | 2.18 | 2.18 | ok |
| 256.0 MiB | cpu | context-auto | 9.99 | 9.64 | 10.06 | 10.06 | ok |
| 256.0 MiB | blake3 | default-auto | 29.98 | 23.48 | 34.88 | 34.88 | ok |
| 256.0 MiB | metal | e2e-auto | 16.07 | 14.16 | 17.11 | 17.11 | ok |
| 256.0 MiB | metal | e2e-gpu | 15.57 | 14.92 | 17.98 | 17.98 | ok |
| 256.0 MiB | cryptokit | sha256 | 2.91 | 2.88 | 2.93 | 2.93 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.10 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.75 | 1.72 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 10.64 | 9.65 | 10.91 | 10.91 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.13 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 10.66 | 10.37 | 10.82 | 10.82 | ok |
| 512.0 MiB | blake3 | default-auto | 29.39 | 27.57 | 33.56 | 33.56 | ok |
| 512.0 MiB | metal | e2e-auto | 16.69 | 16.38 | 18.16 | 18.16 | ok |
| 512.0 MiB | metal | e2e-gpu | 17.00 | 14.75 | 18.47 | 18.47 | ok |
| 512.0 MiB | cryptokit | sha256 | 2.87 | 2.75 | 2.88 | 2.88 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.12 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.73 | 1.62 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 11.08 | 10.19 | 11.49 | 11.49 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.14 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 10.71 | 10.02 | 10.97 | 10.97 | ok |
| 1.0 GiB | blake3 | default-auto | 34.66 | 31.03 | 43.44 | 43.44 | ok |
| 1.0 GiB | metal | e2e-auto | 17.76 | 17.32 | 19.36 | 19.36 | ok |
| 1.0 GiB | metal | e2e-gpu | 18.45 | 17.39 | 19.36 | 19.36 | ok |
| 1.0 GiB | cryptokit | sha256 | 2.78 | 2.66 | 2.87 | 2.87 | ok |
jsonOutput=benchmarks/results/20260421T-sized-untracked-owned-upload-record/sized-untracked-owned-upload-record.json
jsonValidation=ok path=benchmarks/results/20260421T-sized-untracked-owned-upload-record/sized-untracked-owned-upload-record.json
