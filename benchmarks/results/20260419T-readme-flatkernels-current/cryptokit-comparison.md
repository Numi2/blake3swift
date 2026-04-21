BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=67108864
metalStagedReadTileByteCount=33554432
metalModes=resident,staged,wrapped,e2e
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
metal-staged includes: pre-created shared staging MTLBuffer; timed Swift-byte copy into staging buffer plus hash
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
metal-e2e includes: timed shared MTLBuffer allocation/copy from Swift bytes plus hash
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=sha256
cryptokit-sha256 includes: timed CryptoKit SHA256 init, update(bufferPointer:), and finalize over existing Swift bytes; cross-algorithm baseline, not BLAKE3 parity; emitted after BLAKE3 rows to avoid perturbing Metal timings

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.08 | 1.03 | 1.08 | 1.08 | ok |
| 16.0 MiB | cpu | single-simd | 1.67 | 1.66 | 1.69 | 1.69 | ok |
| 16.0 MiB | cpu | parallel | 7.94 | 7.57 | 8.70 | 8.70 | ok |
| 16.0 MiB | official-c | one-shot | 2.08 | 2.05 | 2.11 | 2.11 | ok |
| 16.0 MiB | cpu | context-auto | 8.18 | 8.09 | 8.58 | 8.58 | ok |
| 16.0 MiB | blake3 | default-auto | 11.71 | 10.66 | 11.85 | 11.85 | ok |
| 16.0 MiB | metal | resident-auto | 9.17 | 4.57 | 13.18 | 13.18 | ok |
| 16.0 MiB | metal | resident-gpu | 12.04 | 11.49 | 12.68 | 12.68 | ok |
| 16.0 MiB | metal | staged-auto | 14.22 | 7.11 | 15.19 | 15.19 | ok |
| 16.0 MiB | metal | staged-gpu | 13.74 | 10.38 | 16.21 | 16.21 | ok |
| 16.0 MiB | metal | wrapped-auto | 22.22 | 21.93 | 23.26 | 23.26 | ok |
| 16.0 MiB | metal | wrapped-gpu | 23.03 | 22.20 | 23.35 | 23.35 | ok |
| 16.0 MiB | metal | e2e-auto | 8.87 | 8.42 | 9.85 | 9.85 | ok |
| 16.0 MiB | metal | e2e-gpu | 8.57 | 5.12 | 9.88 | 9.88 | ok |
| 16.0 MiB | cryptokit | sha256 | 2.78 | 2.77 | 2.80 | 2.80 | ok |
| 64.0 MiB | cpu | scalar | 1.15 | 1.14 | 1.16 | 1.16 | ok |
| 64.0 MiB | cpu | single-simd | 1.75 | 1.75 | 1.75 | 1.75 | ok |
| 64.0 MiB | cpu | parallel | 10.15 | 10.12 | 10.16 | 10.16 | ok |
| 64.0 MiB | official-c | one-shot | 2.16 | 2.11 | 2.17 | 2.17 | ok |
| 64.0 MiB | cpu | context-auto | 10.10 | 8.64 | 10.25 | 10.25 | ok |
| 64.0 MiB | blake3 | default-auto | 14.17 | 7.52 | 22.01 | 22.01 | ok |
| 64.0 MiB | metal | resident-auto | 37.53 | 29.45 | 40.96 | 40.96 | ok |
| 64.0 MiB | metal | resident-gpu | 36.32 | 20.16 | 41.92 | 41.92 | ok |
| 64.0 MiB | metal | staged-auto | 14.79 | 12.10 | 16.40 | 16.40 | ok |
| 64.0 MiB | metal | staged-gpu | 14.95 | 10.99 | 16.00 | 16.00 | ok |
| 64.0 MiB | metal | wrapped-auto | 29.80 | 21.17 | 33.09 | 33.09 | ok |
| 64.0 MiB | metal | wrapped-gpu | 25.14 | 19.55 | 32.96 | 32.96 | ok |
| 64.0 MiB | metal | e2e-auto | 9.30 | 7.30 | 10.00 | 10.00 | ok |
| 64.0 MiB | metal | e2e-gpu | 9.38 | 7.40 | 10.18 | 10.18 | ok |
| 64.0 MiB | cryptokit | sha256 | 2.90 | 2.87 | 2.92 | 2.92 | ok |
| 256.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 10.72 | 10.56 | 10.75 | 10.75 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 10.70 | 10.17 | 10.89 | 10.89 | ok |
| 256.0 MiB | blake3 | default-auto | 33.73 | 32.59 | 40.21 | 40.21 | ok |
| 256.0 MiB | metal | resident-auto | 43.62 | 39.83 | 47.06 | 47.06 | ok |
| 256.0 MiB | metal | resident-gpu | 52.86 | 44.15 | 60.61 | 60.61 | ok |
| 256.0 MiB | metal | staged-auto | 20.59 | 14.15 | 22.85 | 22.85 | ok |
| 256.0 MiB | metal | staged-gpu | 20.92 | 19.11 | 21.80 | 21.80 | ok |
| 256.0 MiB | metal | wrapped-auto | 45.80 | 44.58 | 48.14 | 48.14 | ok |
| 256.0 MiB | metal | wrapped-gpu | 44.53 | 43.46 | 45.95 | 45.95 | ok |
| 256.0 MiB | metal | e2e-auto | 11.80 | 11.26 | 12.19 | 12.19 | ok |
| 256.0 MiB | metal | e2e-gpu | 11.32 | 10.40 | 12.40 | 12.40 | ok |
| 256.0 MiB | cryptokit | sha256 | 2.94 | 2.93 | 2.95 | 2.95 | ok |
| 512.0 MiB | cpu | scalar | 1.16 | 1.16 | 1.16 | 1.16 | ok |
| 512.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.76 | 1.76 | ok |
| 512.0 MiB | cpu | parallel | 10.93 | 10.82 | 11.18 | 11.18 | ok |
| 512.0 MiB | official-c | one-shot | 2.17 | 2.16 | 2.17 | 2.17 | ok |
| 512.0 MiB | cpu | context-auto | 11.10 | 10.85 | 11.45 | 11.45 | ok |
| 512.0 MiB | blake3 | default-auto | 36.92 | 35.10 | 40.26 | 40.26 | ok |
| 512.0 MiB | metal | resident-auto | 48.45 | 39.34 | 54.25 | 54.25 | ok |
| 512.0 MiB | metal | resident-gpu | 58.79 | 56.63 | 67.17 | 67.17 | ok |
| 512.0 MiB | metal | staged-auto | 21.62 | 16.27 | 22.84 | 22.84 | ok |
| 512.0 MiB | metal | staged-gpu | 21.19 | 20.59 | 21.64 | 21.64 | ok |
| 512.0 MiB | metal | wrapped-auto | 52.02 | 48.28 | 55.22 | 55.22 | ok |
| 512.0 MiB | metal | wrapped-gpu | 48.35 | 44.81 | 55.53 | 55.53 | ok |
| 512.0 MiB | metal | e2e-auto | 12.72 | 12.53 | 12.89 | 12.89 | ok |
| 512.0 MiB | metal | e2e-gpu | 12.00 | 11.15 | 12.84 | 12.84 | ok |
| 512.0 MiB | cryptokit | sha256 | 2.92 | 2.91 | 2.93 | 2.93 | ok |
| 1.0 GiB | cpu | scalar | 1.12 | 1.11 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.76 | 1.75 | 1.76 | 1.76 | ok |
| 1.0 GiB | cpu | parallel | 11.46 | 10.91 | 11.78 | 11.78 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.17 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 11.53 | 10.98 | 11.71 | 11.71 | ok |
| 1.0 GiB | blake3 | default-auto | 53.23 | 48.12 | 54.96 | 54.96 | ok |
| 1.0 GiB | metal | resident-auto | 74.85 | 70.24 | 78.10 | 78.10 | ok |
| 1.0 GiB | metal | resident-gpu | 72.81 | 69.99 | 78.59 | 78.59 | ok |
| 1.0 GiB | metal | staged-auto | 24.58 | 17.13 | 24.98 | 24.98 | ok |
| 1.0 GiB | metal | staged-gpu | 24.09 | 23.55 | 24.41 | 24.41 | ok |
| 1.0 GiB | metal | wrapped-auto | 52.72 | 49.79 | 53.77 | 53.77 | ok |
| 1.0 GiB | metal | wrapped-gpu | 49.39 | 47.07 | 50.61 | 50.61 | ok |
| 1.0 GiB | metal | e2e-auto | 11.00 | 0.29 | 11.91 | 11.91 | ok |
| 1.0 GiB | metal | e2e-gpu | 3.02 | 1.72 | 3.72 | 3.72 | ok |
| 1.0 GiB | cryptokit | sha256 | 2.87 | 2.73 | 2.89 | 2.89 | ok |
jsonOutput=benchmarks/results/20260419T-readme-flatkernels-current/cryptokit-comparison.json
