BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=wrapped
pageAlignedWrappedInput=false
pageAlignedCopyWorkers=1
pageAlignedCopyWriteCombined=false
metalCommandTiming=false
metalCommandBackend=legacy
metalDigestPipelineWidthHint=true
metal-wrapped includes: timed Swift input route with page-aligned shared-buffer allocation/copy, hash command submission, and completion
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=16.0 MiB, 64.0 MiB, 256.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 16.0 MiB | cpu | scalar | 1.35 | 1.19 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.13 | 2.13 | 2.14 | 2.14 | ok |
| 16.0 MiB | cpu | parallel | 13.96 | 12.61 | 14.11 | 14.11 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 16.0 MiB | cpu | context-auto | 14.02 | 13.19 | 14.12 | 14.12 | ok |
| 16.0 MiB | blake3 | default-auto | 16.83 | 12.47 | 19.43 | 19.43 | ok |
| 16.0 MiB | metal | wrapped-auto | 17.17 | 16.44 | 19.01 | 19.01 | ok |
| 16.0 MiB | metal | wrapped-gpu | 19.22 | 16.76 | 20.34 | 20.34 | ok |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 16.46 | 15.93 | 16.60 | 16.60 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 16.49 | 15.37 | 16.58 | 16.58 | ok |
| 64.0 MiB | blake3 | default-auto | 26.48 | 15.22 | 30.39 | 30.39 | ok |
| 64.0 MiB | metal | wrapped-auto | 27.79 | 23.31 | 30.93 | 30.93 | ok |
| 64.0 MiB | metal | wrapped-gpu | 29.03 | 23.49 | 30.86 | 30.86 | ok |
| 256.0 MiB | cpu | scalar | 1.35 | 1.31 | 1.35 | 1.35 | ok |
| 256.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 256.0 MiB | cpu | parallel | 17.23 | 17.02 | 17.41 | 17.41 | ok |
| 256.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 256.0 MiB | cpu | context-auto | 17.19 | 16.31 | 17.46 | 17.46 | ok |
| 256.0 MiB | blake3 | default-auto | 32.63 | 25.49 | 32.70 | 32.70 | ok |
| 256.0 MiB | metal | wrapped-auto | 32.61 | 31.11 | 32.85 | 32.85 | ok |
| 256.0 MiB | metal | wrapped-gpu | 32.62 | 31.42 | 32.78 | 32.78 | ok |
jsonOutput=/tmp/m6-cached-public-multisize.json
