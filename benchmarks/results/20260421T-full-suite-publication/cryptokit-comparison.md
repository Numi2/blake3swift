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
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB, 512.0 MiB, 1.0 GiB
cryptoKitModes=sha256
cryptokit-sha256 includes: timed CryptoKit SHA256 init, update(bufferPointer:), and finalize over existing Swift bytes; cross-algorithm baseline, not BLAKE3 parity; emitted after BLAKE3 rows to avoid perturbing Metal timings

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 0.92 | 0.88 | 1.01 | 1.01 | ok |
| 16.0 MiB | cpu | single-simd | 1.45 | 1.37 | 1.59 | 1.59 | ok |
| 16.0 MiB | cpu | parallel | 6.04 | 4.29 | 7.54 | 7.54 | ok |
| 16.0 MiB | official-c | one-shot | 1.78 | 1.73 | 2.05 | 2.05 | ok |
| 16.0 MiB | cpu | context-auto | 9.76 | 8.84 | 10.42 | 10.42 | ok |
| 16.0 MiB | blake3 | default-auto | 20.17 | 14.47 | 21.87 | 21.87 | ok |
| 16.0 MiB | metal | resident-auto | 26.69 | 9.61 | 28.33 | 28.33 | ok |
| 16.0 MiB | metal | resident-gpu | 24.05 | 7.58 | 27.81 | 27.81 | ok |
| 16.0 MiB | metal | staged-auto | 14.67 | 9.98 | 16.61 | 16.61 | ok |
| 16.0 MiB | metal | staged-gpu | 13.87 | 6.89 | 16.57 | 16.57 | ok |
| 16.0 MiB | metal | wrapped-auto | 17.44 | 7.53 | 21.61 | 21.61 | ok |
| 16.0 MiB | metal | wrapped-gpu | 16.31 | 8.39 | 22.41 | 22.41 | ok |
| 16.0 MiB | metal | e2e-auto | 11.75 | 7.20 | 14.56 | 14.56 | ok |
| 16.0 MiB | metal | e2e-gpu | 13.97 | 9.77 | 15.29 | 15.29 | ok |
| 16.0 MiB | cryptokit | sha256 | 2.79 | 2.71 | 2.82 | 2.82 | ok |
| 64.0 MiB | cpu | scalar | 1.11 | 1.09 | 1.12 | 1.12 | ok |
| 64.0 MiB | cpu | single-simd | 1.65 | 1.64 | 1.69 | 1.69 | ok |
| 64.0 MiB | cpu | parallel | 9.67 | 9.00 | 10.80 | 10.80 | ok |
| 64.0 MiB | official-c | one-shot | 2.11 | 2.08 | 2.15 | 2.15 | ok |
| 64.0 MiB | cpu | context-auto | 10.70 | 9.63 | 11.11 | 11.11 | ok |
| 64.0 MiB | blake3 | default-auto | 27.45 | 22.68 | 32.51 | 32.51 | ok |
| 64.0 MiB | metal | resident-auto | 37.55 | 19.81 | 44.80 | 44.80 | ok |
| 64.0 MiB | metal | resident-gpu | 38.16 | 14.85 | 45.34 | 45.34 | ok |
| 64.0 MiB | metal | staged-auto | 16.34 | 12.53 | 18.79 | 18.79 | ok |
| 64.0 MiB | metal | staged-gpu | 17.79 | 15.02 | 20.02 | 20.02 | ok |
| 64.0 MiB | metal | wrapped-auto | 25.90 | 17.43 | 33.00 | 33.00 | ok |
| 64.0 MiB | metal | wrapped-gpu | 28.70 | 17.14 | 33.17 | 33.17 | ok |
| 64.0 MiB | metal | e2e-auto | 14.93 | 12.65 | 18.22 | 18.22 | ok |
| 64.0 MiB | metal | e2e-gpu | 16.33 | 10.29 | 18.59 | 18.59 | ok |
| 64.0 MiB | cryptokit | sha256 | 2.80 | 2.79 | 2.83 | 2.83 | ok |
| 256.0 MiB | cpu | scalar | 1.14 | 1.12 | 1.16 | 1.16 | ok |
| 256.0 MiB | cpu | single-simd | 1.76 | 1.76 | 1.76 | 1.76 | ok |
| 256.0 MiB | cpu | parallel | 11.63 | 11.41 | 11.71 | 11.71 | ok |
| 256.0 MiB | official-c | one-shot | 2.17 | 2.14 | 2.17 | 2.17 | ok |
| 256.0 MiB | cpu | context-auto | 11.44 | 10.53 | 11.78 | 11.78 | ok |
| 256.0 MiB | blake3 | default-auto | 35.81 | 31.33 | 36.98 | 36.98 | ok |
| 256.0 MiB | metal | resident-auto | 46.88 | 32.84 | 56.13 | 56.13 | ok |
| 256.0 MiB | metal | resident-gpu | 45.33 | 34.80 | 59.21 | 59.21 | ok |
| 256.0 MiB | metal | staged-auto | 16.76 | 14.70 | 19.88 | 19.88 | ok |
| 256.0 MiB | metal | staged-gpu | 16.08 | 14.18 | 19.59 | 19.59 | ok |
| 256.0 MiB | metal | wrapped-auto | 33.80 | 27.58 | 44.74 | 44.74 | ok |
| 256.0 MiB | metal | wrapped-gpu | 31.67 | 28.41 | 34.85 | 34.85 | ok |
| 256.0 MiB | metal | e2e-auto | 15.18 | 13.40 | 17.45 | 17.45 | ok |
| 256.0 MiB | metal | e2e-gpu | 16.77 | 14.61 | 19.09 | 19.09 | ok |
| 256.0 MiB | cryptokit | sha256 | 2.84 | 2.83 | 2.86 | 2.86 | ok |
| 512.0 MiB | cpu | scalar | 1.15 | 1.14 | 1.15 | 1.15 | ok |
| 512.0 MiB | cpu | single-simd | 1.73 | 1.71 | 1.74 | 1.74 | ok |
| 512.0 MiB | cpu | parallel | 11.87 | 11.05 | 12.05 | 12.05 | ok |
| 512.0 MiB | official-c | one-shot | 2.15 | 2.09 | 2.16 | 2.16 | ok |
| 512.0 MiB | cpu | context-auto | 11.54 | 10.48 | 11.73 | 11.73 | ok |
| 512.0 MiB | blake3 | default-auto | 44.31 | 35.47 | 49.56 | 49.56 | ok |
| 512.0 MiB | metal | resident-auto | 59.65 | 46.69 | 70.94 | 70.94 | ok |
| 512.0 MiB | metal | resident-gpu | 67.04 | 45.35 | 81.17 | 81.17 | ok |
| 512.0 MiB | metal | staged-auto | 23.11 | 20.96 | 24.79 | 24.79 | ok |
| 512.0 MiB | metal | staged-gpu | 22.37 | 20.84 | 23.29 | 23.29 | ok |
| 512.0 MiB | metal | wrapped-auto | 43.84 | 38.70 | 48.03 | 48.03 | ok |
| 512.0 MiB | metal | wrapped-gpu | 43.53 | 39.17 | 50.95 | 50.95 | ok |
| 512.0 MiB | metal | e2e-auto | 19.43 | 18.71 | 20.18 | 20.18 | ok |
| 512.0 MiB | metal | e2e-gpu | 19.78 | 18.66 | 20.20 | 20.20 | ok |
| 512.0 MiB | cryptokit | sha256 | 2.85 | 2.79 | 2.86 | 2.86 | ok |
| 1.0 GiB | cpu | scalar | 1.15 | 1.14 | 1.15 | 1.15 | ok |
| 1.0 GiB | cpu | single-simd | 1.74 | 1.74 | 1.75 | 1.75 | ok |
| 1.0 GiB | cpu | parallel | 11.84 | 11.41 | 11.98 | 11.98 | ok |
| 1.0 GiB | official-c | one-shot | 2.15 | 2.11 | 2.16 | 2.16 | ok |
| 1.0 GiB | cpu | context-auto | 11.84 | 11.65 | 11.96 | 11.96 | ok |
| 1.0 GiB | blake3 | default-auto | 46.92 | 43.90 | 52.31 | 52.31 | ok |
| 1.0 GiB | metal | resident-auto | 67.14 | 63.87 | 71.44 | 71.44 | ok |
| 1.0 GiB | metal | resident-gpu | 70.57 | 55.96 | 78.87 | 78.87 | ok |
| 1.0 GiB | metal | staged-auto | 22.83 | 21.68 | 23.87 | 23.87 | ok |
| 1.0 GiB | metal | staged-gpu | 23.24 | 22.74 | 23.99 | 23.99 | ok |
| 1.0 GiB | metal | wrapped-auto | 45.81 | 33.63 | 50.49 | 50.49 | ok |
| 1.0 GiB | metal | wrapped-gpu | 44.07 | 37.89 | 49.98 | 49.98 | ok |
| 1.0 GiB | metal | e2e-auto | 19.55 | 17.82 | 19.89 | 19.89 | ok |
| 1.0 GiB | metal | e2e-gpu | 19.74 | 19.37 | 20.55 | 20.55 | ok |
| 1.0 GiB | cryptokit | sha256 | 2.84 | 2.79 | 2.85 | 2.85 | ok |
jsonOutput=benchmarks/results/20260421T-full-suite-publication/cryptokit-comparison.json
