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
| 64.0 MiB | cpu | scalar | 1.15 | 1.11 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 64.0 MiB | cpu | parallel | 9.63 | 8.71 | 10.12 | 10.12 | ok |
| 64.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.18 | 2.18 | ok |
| 64.0 MiB | cpu | context-auto | 9.81 | 9.41 | 10.24 | 10.24 | ok |
| 64.0 MiB | blake3 | default-auto | 29.30 | 12.65 | 31.40 | 31.40 | ok |
| 64.0 MiB | metal | e2e-auto | 14.95 | 9.24 | 17.55 | 17.55 | ok |
| 64.0 MiB | metal | e2e-gpu | 16.96 | 15.26 | 18.05 | 18.05 | ok |
| 64.0 MiB | cryptokit | sha256 | 2.85 | 2.84 | 2.89 | 2.89 | ok |
| 256.0 MiB | cpu | scalar | 1.15 | 1.11 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.75 | 1.73 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.54 | 10.06 | 10.84 | 10.84 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.00 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.18 | 9.72 | 10.22 | 10.22 | ok |
| 256.0 MiB | blake3 | default-auto | 30.95 | 24.98 | 33.21 | 33.21 | ok |
| 256.0 MiB | metal | e2e-auto | 16.08 | 14.36 | 17.43 | 17.43 | ok |
| 256.0 MiB | metal | e2e-gpu | 16.78 | 13.37 | 18.47 | 18.47 | ok |
| 256.0 MiB | cryptokit | sha256 | 2.87 | 2.73 | 2.87 | 2.87 | ok |
| 512.0 MiB | cpu | scalar | 1.15 | 1.13 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 10.73 | 9.88 | 10.93 | 10.93 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.09 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 10.76 | 10.23 | 10.92 | 10.92 | ok |
| 512.0 MiB | blake3 | default-auto | 31.56 | 26.68 | 32.09 | 32.09 | ok |
| 512.0 MiB | metal | e2e-auto | 16.07 | 14.90 | 17.85 | 17.85 | ok |
| 512.0 MiB | metal | e2e-gpu | 17.09 | 15.41 | 18.30 | 18.30 | ok |
| 512.0 MiB | cryptokit | sha256 | 2.87 | 2.87 | 2.87 | 2.87 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.12 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 10.54 | 9.85 | 11.11 | 11.11 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.14 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 9.74 | 8.34 | 11.28 | 11.28 | ok |
| 1.0 GiB | blake3 | default-auto | 38.64 | 26.32 | 39.91 | 39.91 | ok |
| 1.0 GiB | metal | e2e-auto | 18.43 | 18.00 | 18.90 | 18.90 | ok |
| 1.0 GiB | metal | e2e-gpu | 18.88 | 16.31 | 19.41 | 19.41 | ok |
| 1.0 GiB | cryptokit | sha256 | 2.86 | 2.81 | 2.87 | 2.87 | ok |
jsonOutput=benchmarks/results/20260421T-untracked-owned-upload-record/untracked-owned-upload-record.json
jsonValidation=ok path=benchmarks/results/20260421T-untracked-owned-upload-record/untracked-owned-upload-record.json
