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
sizes=4.0 MiB, 8.0 MiB, 16.0 MiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 4.0 MiB | cpu | scalar | 1.08 | 0.88 | 1.31 | 1.31 | ok |
| 4.0 MiB | cpu | single-simd | 2.13 | 2.12 | 2.13 | 2.13 | ok |
| 4.0 MiB | cpu | parallel | 8.76 | 8.49 | 9.19 | 9.19 | ok |
| 4.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 4.0 MiB | cpu | context-auto | 8.92 | 8.61 | 9.22 | 9.22 | ok |
| 4.0 MiB | blake3 | default-auto | 11.47 | 8.74 | 12.24 | 12.24 | ok |
| 4.0 MiB | metal | wrapped-auto | 10.49 | 10.32 | 11.20 | 11.20 | ok |
| 4.0 MiB | metal | wrapped-gpu | 11.43 | 11.02 | 11.89 | 11.89 | ok |
| 8.0 MiB | cpu | scalar | 1.35 | 1.33 | 1.35 | 1.35 | ok |
| 8.0 MiB | cpu | single-simd | 2.14 | 2.12 | 2.14 | 2.14 | ok |
| 8.0 MiB | cpu | parallel | 12.00 | 11.07 | 12.24 | 12.24 | ok |
| 8.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.62 | 2.62 | ok |
| 8.0 MiB | cpu | context-auto | 11.99 | 11.05 | 12.60 | 12.60 | ok |
| 8.0 MiB | blake3 | default-auto | 16.25 | 12.38 | 17.14 | 17.14 | ok |
| 8.0 MiB | metal | wrapped-auto | 12.89 | 11.75 | 13.08 | 13.08 | ok |
| 8.0 MiB | metal | wrapped-gpu | 16.34 | 13.60 | 17.29 | 17.29 | ok |
| 16.0 MiB | cpu | scalar | 1.35 | 1.34 | 1.35 | 1.35 | ok |
| 16.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.15 | 2.15 | ok |
| 16.0 MiB | cpu | parallel | 13.83 | 13.06 | 14.22 | 14.22 | ok |
| 16.0 MiB | official-c | one-shot | 2.62 | 2.61 | 2.63 | 2.63 | ok |
| 16.0 MiB | cpu | context-auto | 14.05 | 13.08 | 14.14 | 14.14 | ok |
| 16.0 MiB | blake3 | default-auto | 20.77 | 13.39 | 23.78 | 23.78 | ok |
| 16.0 MiB | metal | wrapped-auto | 22.69 | 15.90 | 25.65 | 25.65 | ok |
| 16.0 MiB | metal | wrapped-gpu | 22.65 | 16.90 | 25.64 | 25.64 | ok |
jsonOutput=/tmp/m6-cached-public-threshold.json
