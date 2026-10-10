BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=resident
pageAlignedWrappedInput=false
metalCommandTiming=false
metalCommandBackend=legacy
metal-resident includes: pre-created shared MTLBuffer; timed hash includes command encoding, GPU execution, wait, digest read
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=256.0 MiB, 1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 256.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel | 17.28 | 17.10 | 17.38 | 17.38 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.08 | 17.03 | 17.43 | 17.43 | ok |
| 256.0 MiB | blake3 | default-auto | 56.62 | 51.15 | 62.68 | 62.68 | ok |
| 256.0 MiB | metal | resident-auto | 96.11 | 95.35 | 96.34 | 96.34 | ok |
| 256.0 MiB | metal | resident-gpu | 95.23 | 94.88 | 95.82 | 95.82 | ok |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.26 | 16.36 | 17.45 | 17.45 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.07 | 16.95 | 17.23 | 17.23 | ok |
| 1.0 GiB | blake3 | default-auto | 68.14 | 65.67 | 69.98 | 69.98 | ok |
| 1.0 GiB | metal | resident-auto | 104.53 | 100.61 | 104.75 | 104.75 | ok |
| 1.0 GiB | metal | resident-gpu | 104.66 | 104.49 | 104.78 | 104.78 | ok |
jsonOutput=/tmp/m6-fused-pingpong-r4.json
