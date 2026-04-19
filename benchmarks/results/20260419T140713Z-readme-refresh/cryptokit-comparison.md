BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=10 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=16777216
officialCVersion=1.8.4
metalDevice=Apple M4
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalTileByteCount=67108864
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
| 16.0 MiB | cpu | scalar | 0.88 | 0.87 | 0.91 | 0.91 | ok |
| 16.0 MiB | cpu | single-simd | 1.46 | 1.39 | 1.60 | 1.60 | ok |
| 16.0 MiB | cpu | parallel | 5.28 | 3.94 | 5.51 | 5.51 | ok |
| 16.0 MiB | official-c | one-shot | 1.79 | 1.44 | 1.94 | 1.94 | ok |
| 16.0 MiB | cpu | context-auto | 5.92 | 4.93 | 6.96 | 6.96 | ok |
| 16.0 MiB | blake3 | default-auto | 11.34 | 4.47 | 12.26 | 12.26 | ok |
| 16.0 MiB | metal | resident-auto | 12.45 | 3.96 | 13.38 | 13.38 | ok |
| 16.0 MiB | metal | resident-gpu | 13.49 | 5.63 | 20.32 | 20.32 | ok |
| 16.0 MiB | metal | staged-auto | 8.39 | 2.81 | 12.48 | 12.48 | ok |
| 16.0 MiB | metal | staged-gpu | 9.62 | 3.84 | 13.29 | 13.29 | ok |
| 16.0 MiB | metal | wrapped-auto | 14.93 | 5.54 | 18.72 | 18.72 | ok |
| 16.0 MiB | metal | wrapped-gpu | 15.63 | 10.07 | 18.26 | 18.26 | ok |
| 16.0 MiB | metal | e2e-auto | 6.91 | 2.98 | 9.16 | 9.16 | ok |
| 16.0 MiB | metal | e2e-gpu | 8.18 | 3.17 | 8.92 | 8.92 | ok |
| 16.0 MiB | cryptokit | sha256 | 2.90 | 2.84 | 3.01 | 3.01 | ok |
| 64.0 MiB | cpu | scalar | 1.06 | 1.05 | 1.08 | 1.08 | ok |
| 64.0 MiB | cpu | single-simd | 1.70 | 1.70 | 1.72 | 1.72 | ok |
| 64.0 MiB | cpu | parallel | 8.79 | 7.68 | 9.95 | 9.95 | ok |
| 64.0 MiB | official-c | one-shot | 2.13 | 2.12 | 2.19 | 2.19 | ok |
| 64.0 MiB | cpu | context-auto | 9.15 | 8.29 | 10.00 | 10.00 | ok |
| 64.0 MiB | blake3 | default-auto | 30.11 | 13.37 | 34.45 | 34.45 | ok |
| 64.0 MiB | metal | resident-auto | 40.10 | 21.62 | 45.59 | 45.59 | ok |
| 64.0 MiB | metal | resident-gpu | 39.15 | 26.98 | 42.56 | 42.56 | ok |
| 64.0 MiB | metal | staged-auto | 17.70 | 13.09 | 20.13 | 20.13 | ok |
| 64.0 MiB | metal | staged-gpu | 17.27 | 10.19 | 18.60 | 18.60 | ok |
| 64.0 MiB | metal | wrapped-auto | 31.15 | 16.24 | 34.04 | 34.04 | ok |
| 64.0 MiB | metal | wrapped-gpu | 30.62 | 17.37 | 35.98 | 35.98 | ok |
| 64.0 MiB | metal | e2e-auto | 11.06 | 10.39 | 12.00 | 12.00 | ok |
| 64.0 MiB | metal | e2e-gpu | 11.12 | 10.46 | 11.78 | 11.78 | ok |
| 64.0 MiB | cryptokit | sha256 | 2.89 | 2.82 | 2.97 | 2.97 | ok |
| 256.0 MiB | cpu | scalar | 1.10 | 1.10 | 1.10 | 1.10 | ok |
| 256.0 MiB | cpu | single-simd | 1.77 | 1.77 | 1.77 | 1.77 | ok |
| 256.0 MiB | cpu | parallel | 10.52 | 9.92 | 10.89 | 10.89 | ok |
| 256.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.19 | 2.19 | ok |
| 256.0 MiB | cpu | context-auto | 10.56 | 10.36 | 10.82 | 10.82 | ok |
| 256.0 MiB | blake3 | default-auto | 42.33 | 23.63 | 51.13 | 51.13 | ok |
| 256.0 MiB | metal | resident-auto | 65.50 | 53.67 | 79.62 | 79.62 | ok |
| 256.0 MiB | metal | resident-gpu | 67.53 | 52.32 | 78.25 | 78.25 | ok |
| 256.0 MiB | metal | staged-auto | 21.67 | 16.15 | 22.66 | 22.66 | ok |
| 256.0 MiB | metal | staged-gpu | 22.27 | 19.87 | 23.21 | 23.21 | ok |
| 256.0 MiB | metal | wrapped-auto | 46.48 | 39.98 | 54.05 | 54.05 | ok |
| 256.0 MiB | metal | wrapped-gpu | 43.82 | 39.66 | 52.03 | 52.03 | ok |
| 256.0 MiB | metal | e2e-auto | 11.67 | 11.22 | 12.09 | 12.09 | ok |
| 256.0 MiB | metal | e2e-gpu | 10.08 | 7.93 | 11.27 | 11.27 | ok |
| 256.0 MiB | cryptokit | sha256 | 2.93 | 2.91 | 2.93 | 2.93 | ok |
| 512.0 MiB | cpu | scalar | 1.10 | 1.10 | 1.10 | 1.10 | ok |
| 512.0 MiB | cpu | single-simd | 1.77 | 1.76 | 1.77 | 1.77 | ok |
| 512.0 MiB | cpu | parallel | 11.22 | 10.97 | 11.72 | 11.72 | ok |
| 512.0 MiB | official-c | one-shot | 2.18 | 2.18 | 2.19 | 2.19 | ok |
| 512.0 MiB | cpu | context-auto | 11.01 | 10.48 | 11.42 | 11.42 | ok |
| 512.0 MiB | blake3 | default-auto | 48.86 | 37.44 | 53.73 | 53.73 | ok |
| 512.0 MiB | metal | resident-auto | 68.35 | 65.65 | 80.29 | 80.29 | ok |
| 512.0 MiB | metal | resident-gpu | 72.85 | 66.72 | 83.72 | 83.72 | ok |
| 512.0 MiB | metal | staged-auto | 23.26 | 15.10 | 23.79 | 23.79 | ok |
| 512.0 MiB | metal | staged-gpu | 24.08 | 22.68 | 24.62 | 24.62 | ok |
| 512.0 MiB | metal | wrapped-auto | 49.44 | 46.44 | 55.05 | 55.05 | ok |
| 512.0 MiB | metal | wrapped-gpu | 44.02 | 40.79 | 49.86 | 49.86 | ok |
| 512.0 MiB | metal | e2e-auto | 11.55 | 10.64 | 12.10 | 12.10 | ok |
| 512.0 MiB | metal | e2e-gpu | 9.75 | 8.84 | 10.74 | 10.74 | ok |
| 512.0 MiB | cryptokit | sha256 | 2.90 | 2.60 | 2.92 | 2.92 | ok |
| 1.0 GiB | cpu | scalar | 1.09 | 1.05 | 1.10 | 1.10 | ok |
| 1.0 GiB | cpu | single-simd | 1.75 | 1.72 | 1.76 | 1.76 | ok |
| 1.0 GiB | cpu | parallel | 11.48 | 11.27 | 11.75 | 11.75 | ok |
| 1.0 GiB | official-c | one-shot | 2.17 | 2.12 | 2.17 | 2.17 | ok |
| 1.0 GiB | cpu | context-auto | 11.19 | 9.90 | 11.49 | 11.49 | ok |
| 1.0 GiB | blake3 | default-auto | 49.73 | 46.09 | 53.18 | 53.18 | ok |
| 1.0 GiB | metal | resident-auto | 73.54 | 67.90 | 77.98 | 77.98 | ok |
| 1.0 GiB | metal | resident-gpu | 74.39 | 68.75 | 84.89 | 84.89 | ok |
| 1.0 GiB | metal | staged-auto | 19.58 | 11.19 | 22.11 | 22.11 | ok |
| 1.0 GiB | metal | staged-gpu | 20.84 | 17.37 | 22.74 | 22.74 | ok |
| 1.0 GiB | metal | wrapped-auto | 39.38 | 35.98 | 41.10 | 41.10 | ok |
| 1.0 GiB | metal | wrapped-gpu | 43.15 | 39.37 | 46.43 | 46.43 | ok |
| 1.0 GiB | metal | e2e-auto | 2.61 | 2.53 | 4.18 | 4.18 | ok |
| 1.0 GiB | metal | e2e-gpu | 2.62 | 1.43 | 3.23 | 3.23 | ok |
| 1.0 GiB | cryptokit | sha256 | 2.86 | 2.74 | 2.87 | 2.87 | ok |
jsonOutput=benchmarks/results/20260419T140713Z-readme-refresh/cryptokit-comparison.json
