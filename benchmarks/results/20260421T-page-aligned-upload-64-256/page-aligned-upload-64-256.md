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
sizes=64.0 MiB, 256.0 MiB
cryptoKitModes=sha256
cryptokit-sha256 includes: timed CryptoKit SHA256 init, update(bufferPointer:), and finalize over existing Swift bytes; cross-algorithm baseline, not BLAKE3 parity; emitted after BLAKE3 rows to avoid perturbing Metal timings

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.16 | 1.15 | 1.17 | 1.17 | ok |
| 64.0 MiB | cpu | single-simd | 1.83 | 1.81 | 1.84 | 1.84 | ok |
| 64.0 MiB | cpu | parallel | 10.25 | 9.32 | 10.35 | 10.35 | ok |
| 64.0 MiB | official-c | one-shot | 2.22 | 2.18 | 2.24 | 2.24 | ok |
| 64.0 MiB | cpu | context-auto | 9.95 | 8.57 | 10.24 | 10.24 | ok |
| 64.0 MiB | blake3 | default-auto | 19.25 | 10.85 | 31.05 | 31.05 | ok |
| 64.0 MiB | metal | e2e-auto | 12.19 | 9.48 | 16.95 | 16.95 | ok |
| 64.0 MiB | metal | e2e-gpu | 14.01 | 9.24 | 16.13 | 16.13 | ok |
| 64.0 MiB | cryptokit | sha256 | 3.09 | 3.04 | 3.12 | 3.12 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.14 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.78 | 1.62 | 1.79 | 1.79 | ok |
| 256.0 MiB | cpu | parallel | 10.46 | 10.29 | 10.62 | 10.62 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.19 | 2.19 | ok |
| 256.0 MiB | cpu | context-auto | 10.27 | 9.78 | 10.46 | 10.46 | ok |
| 256.0 MiB | blake3 | default-auto | 34.08 | 31.97 | 36.39 | 36.39 | ok |
| 256.0 MiB | metal | e2e-auto | 16.93 | 16.37 | 17.12 | 17.12 | ok |
| 256.0 MiB | metal | e2e-gpu | 17.45 | 16.42 | 18.03 | 18.03 | ok |
| 256.0 MiB | cryptokit | sha256 | 3.01 | 3.00 | 3.04 | 3.04 | ok |
jsonOutput=benchmarks/results/20260421T-page-aligned-upload-64-256/page-aligned-upload-64-256.json
jsonValidation=ok path=benchmarks/results/20260421T-page-aligned-upload-64-256/page-aligned-upload-64-256.json
