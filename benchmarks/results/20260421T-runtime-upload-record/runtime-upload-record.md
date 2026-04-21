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
sizes=512.0 MiB, 1.0 GiB
cryptoKitModes=sha256
cryptokit-sha256 includes: timed CryptoKit SHA256 init, update(bufferPointer:), and finalize over existing Swift bytes; cross-algorithm baseline, not BLAKE3 parity; emitted after BLAKE3 rows to avoid perturbing Metal timings

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 512.0 MiB | cpu | scalar | 1.15 | 1.14 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.72 | 1.63 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 10.86 | 8.08 | 11.11 | 11.11 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.12 | 2.18 | 2.18 | ok |
| 512.0 MiB | cpu | context-auto | 10.63 | 9.34 | 11.10 | 11.10 | ok |
| 512.0 MiB | blake3 | default-auto | 27.66 | 22.27 | 30.92 | 30.92 | ok |
| 512.0 MiB | metal | e2e-auto | 14.56 | 13.46 | 16.30 | 16.30 | ok |
| 512.0 MiB | metal | e2e-gpu | 13.73 | 13.44 | 16.52 | 16.52 | ok |
| 512.0 MiB | cryptokit | sha256 | 2.88 | 2.84 | 2.88 | 2.88 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.14 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.74 | 1.69 | 1.76 | 1.76 | ok |
| 1.0 GiB | cpu | parallel | 11.41 | 10.71 | 11.45 | 11.45 | ok |
| 1.0 GiB | official-c | one-shot | 2.16 | 2.15 | 2.18 | 2.18 | ok |
| 1.0 GiB | cpu | context-auto | 11.12 | 10.89 | 11.38 | 11.38 | ok |
| 1.0 GiB | blake3 | default-auto | 38.96 | 36.29 | 43.03 | 43.03 | ok |
| 1.0 GiB | metal | e2e-auto | 17.73 | 17.56 | 19.33 | 19.33 | ok |
| 1.0 GiB | metal | e2e-gpu | 18.65 | 18.10 | 18.89 | 18.89 | ok |
| 1.0 GiB | cryptokit | sha256 | 2.87 | 2.83 | 2.87 | 2.87 | ok |
jsonOutput=benchmarks/results/20260421T-runtime-upload-record/runtime-upload-record.json
jsonValidation=ok path=benchmarks/results/20260421T-runtime-upload-record/runtime-upload-record.json
