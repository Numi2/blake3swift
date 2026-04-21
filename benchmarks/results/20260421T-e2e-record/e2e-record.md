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
| 64.0 MiB | cpu | scalar | 1.18 | 1.01 | 1.20 | 1.20 | ok |
| 64.0 MiB | cpu | single-simd | 1.91 | 1.88 | 1.91 | 1.91 | ok |
| 64.0 MiB | cpu | parallel | 10.19 | 9.33 | 10.42 | 10.42 | ok |
| 64.0 MiB | official-c | one-shot | 2.29 | 2.26 | 2.34 | 2.34 | ok |
| 64.0 MiB | cpu | context-auto | 9.76 | 9.43 | 10.57 | 10.57 | ok |
| 64.0 MiB | blake3 | default-auto | 30.65 | 24.38 | 32.32 | 32.32 | ok |
| 64.0 MiB | metal | e2e-auto | 16.04 | 14.84 | 16.95 | 16.95 | ok |
| 64.0 MiB | metal | e2e-gpu | 17.69 | 11.71 | 18.27 | 18.27 | ok |
| 64.0 MiB | cryptokit | sha256 | 3.13 | 3.11 | 3.13 | 3.13 | ok |
| 256.0 MiB | cpu | scalar | 1.18 | 1.17 | 1.18 | 1.18 | ok |
| 256.0 MiB | cpu | single-simd | 1.88 | 1.86 | 1.89 | 1.89 | ok |
| 256.0 MiB | cpu | parallel | 10.93 | 10.38 | 11.16 | 11.16 | ok |
| 256.0 MiB | official-c | one-shot | 2.26 | 2.25 | 2.27 | 2.27 | ok |
| 256.0 MiB | cpu | context-auto | 10.61 | 10.13 | 10.91 | 10.91 | ok |
| 256.0 MiB | blake3 | default-auto | 28.37 | 26.19 | 34.56 | 34.56 | ok |
| 256.0 MiB | metal | e2e-auto | 15.51 | 14.62 | 17.77 | 17.77 | ok |
| 256.0 MiB | metal | e2e-gpu | 15.48 | 15.18 | 18.48 | 18.48 | ok |
| 256.0 MiB | cryptokit | sha256 | 3.12 | 3.11 | 3.12 | 3.12 | ok |
| 512.0 MiB | cpu | scalar | 1.17 | 1.15 | 1.17 | 1.17 | ok |
| 512.0 MiB | cpu | single-simd | 1.84 | 1.82 | 1.84 | 1.84 | ok |
| 512.0 MiB | cpu | parallel | 11.72 | 11.16 | 11.78 | 11.78 | ok |
| 512.0 MiB | official-c | one-shot | 2.22 | 2.21 | 2.23 | 2.23 | ok |
| 512.0 MiB | cpu | context-auto | 11.17 | 10.91 | 11.49 | 11.49 | ok |
| 512.0 MiB | blake3 | default-auto | 30.44 | 23.19 | 39.55 | 39.55 | ok |
| 512.0 MiB | metal | e2e-auto | 16.20 | 14.34 | 18.43 | 18.43 | ok |
| 512.0 MiB | metal | e2e-gpu | 16.34 | 15.03 | 20.12 | 20.12 | ok |
| 512.0 MiB | cryptokit | sha256 | 3.11 | 2.88 | 3.11 | 3.11 | ok |
| 1.0 GiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 1.0 GiB | cpu | single-simd | 1.80 | 1.78 | 1.80 | 1.80 | ok |
| 1.0 GiB | cpu | parallel | 11.89 | 11.31 | 11.97 | 11.97 | ok |
| 1.0 GiB | official-c | one-shot | 2.19 | 2.18 | 2.20 | 2.20 | ok |
| 1.0 GiB | cpu | context-auto | 11.66 | 11.52 | 12.00 | 12.00 | ok |
| 1.0 GiB | blake3 | default-auto | 39.80 | 33.22 | 40.84 | 40.84 | ok |
| 1.0 GiB | metal | e2e-auto | 18.63 | 16.88 | 19.10 | 19.10 | ok |
| 1.0 GiB | metal | e2e-gpu | 18.56 | 18.12 | 19.80 | 19.80 | ok |
| 1.0 GiB | cryptokit | sha256 | 3.06 | 3.04 | 3.07 | 3.07 | ok |
jsonOutput=benchmarks/results/20260421T-e2e-record/e2e-record.json
jsonValidation=ok path=benchmarks/results/20260421T-e2e-record/e2e-record.json
