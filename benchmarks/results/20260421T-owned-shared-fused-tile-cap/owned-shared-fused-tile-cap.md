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
| 64.0 MiB | cpu | scalar | 1.14 | 1.07 | 1.15 | 1.15 | ok |
| 64.0 MiB | cpu | single-simd | 1.64 | 1.49 | 1.69 | 1.69 | ok |
| 64.0 MiB | cpu | parallel | 9.59 | 9.33 | 10.26 | 10.26 | ok |
| 64.0 MiB | official-c | one-shot | 2.14 | 2.11 | 2.15 | 2.15 | ok |
| 64.0 MiB | cpu | context-auto | 9.55 | 8.61 | 10.14 | 10.14 | ok |
| 64.0 MiB | blake3 | default-auto | 22.95 | 12.56 | 32.76 | 32.76 | ok |
| 64.0 MiB | metal | e2e-auto | 13.99 | 13.10 | 14.21 | 14.21 | ok |
| 64.0 MiB | metal | e2e-gpu | 16.30 | 11.06 | 17.45 | 17.45 | ok |
| 64.0 MiB | cryptokit | sha256 | 2.82 | 2.73 | 2.85 | 2.85 | ok |
| 256.0 MiB | cpu | scalar | 1.13 | 1.07 | 1.15 | 1.15 | ok |
| 256.0 MiB | cpu | single-simd | 1.69 | 1.65 | 1.75 | 1.75 | ok |
| 256.0 MiB | cpu | parallel | 8.36 | 7.65 | 9.55 | 9.55 | ok |
| 256.0 MiB | official-c | one-shot | 2.10 | 1.95 | 2.15 | 2.15 | ok |
| 256.0 MiB | cpu | context-auto | 9.83 | 9.30 | 10.56 | 10.56 | ok |
| 256.0 MiB | blake3 | default-auto | 28.64 | 20.82 | 31.51 | 31.51 | ok |
| 256.0 MiB | metal | e2e-auto | 16.45 | 12.59 | 16.87 | 16.87 | ok |
| 256.0 MiB | metal | e2e-gpu | 16.30 | 15.23 | 17.20 | 17.20 | ok |
| 256.0 MiB | cryptokit | sha256 | 2.82 | 2.79 | 2.86 | 2.86 | ok |
| 512.0 MiB | cpu | scalar | 1.12 | 1.07 | 1.15 | 1.15 | ok |
| 512.0 MiB | cpu | single-simd | 1.74 | 1.72 | 1.74 | 1.74 | ok |
| 512.0 MiB | cpu | parallel | 8.78 | 8.68 | 9.92 | 9.92 | ok |
| 512.0 MiB | official-c | one-shot | 2.13 | 2.00 | 2.16 | 2.16 | ok |
| 512.0 MiB | cpu | context-auto | 11.09 | 10.68 | 11.32 | 11.32 | ok |
| 512.0 MiB | blake3 | default-auto | 27.44 | 25.28 | 30.72 | 30.72 | ok |
| 512.0 MiB | metal | e2e-auto | 16.22 | 15.41 | 16.38 | 16.38 | ok |
| 512.0 MiB | metal | e2e-gpu | 16.49 | 14.86 | 17.69 | 17.69 | ok |
| 512.0 MiB | cryptokit | sha256 | 2.84 | 2.65 | 2.85 | 2.85 | ok |
| 1.0 GiB | cpu | scalar | 1.14 | 1.09 | 1.14 | 1.14 | ok |
| 1.0 GiB | cpu | single-simd | 1.73 | 1.67 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 10.96 | 10.85 | 11.07 | 11.07 | ok |
| 1.0 GiB | official-c | one-shot | 2.15 | 2.15 | 2.16 | 2.16 | ok |
| 1.0 GiB | cpu | context-auto | 10.82 | 9.48 | 11.22 | 11.22 | ok |
| 1.0 GiB | blake3 | default-auto | 39.00 | 36.01 | 43.91 | 43.91 | ok |
| 1.0 GiB | metal | e2e-auto | 19.35 | 19.12 | 19.90 | 19.90 | ok |
| 1.0 GiB | metal | e2e-gpu | 19.93 | 18.21 | 20.01 | 20.01 | ok |
| 1.0 GiB | cryptokit | sha256 | 2.85 | 2.76 | 2.86 | 2.86 | ok |
jsonOutput=benchmarks/results/20260421T-owned-shared-fused-tile-cap/owned-shared-fused-tile-cap.json
jsonValidation=ok path=benchmarks/results/20260421T-owned-shared-fused-tile-cap/owned-shared-fused-tile-cap.json
