BLAKE3 Swift benchmark
backend=swift-simd4 simdDegree=4 parallelSIMDDegree=4 defaultParallelWorkers=12 hasherBytes=8 defaultBackendPolicy=automatic defaultMetalMinimumBytes=4194304
officialCVersion=1.8.4
metalDevice=Apple M6
metalLibrary=runtime-source
metalMinimumGPUByteCount=16777216
metalMappedTileByteCount=134217728
metalStagedReadTileByteCount=33554432
metalModes=wrapped,device-copy
pageAlignedWrappedInput=false
pageAlignedCopyWorkers=1
pageAlignedCopyWriteCombined=false
metalCommandTiming=false
metalCommandBackend=legacy
metalDigestPipelineWidthHint=true
metal-wrapped includes: timed Swift input route with page-aligned shared-buffer allocation/copy, hash command submission, and completion
metal-device-copy includes: timed MTLDevice.makeBuffer(bytes:length:options:) copy from Swift input, GPU hash, and completion
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.35 | 17.18 | 17.48 | 17.48 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.28 | 17.08 | 17.42 | 17.42 | ok |
| 1.0 GiB | blake3 | default-auto | 28.55 | 13.07 | 30.04 | 30.04 | ok |
| 1.0 GiB | metal | wrapped-auto | 27.61 | 26.42 | 29.00 | 29.00 | ok |
| 1.0 GiB | metal | wrapped-gpu | 27.12 | 14.33 | 29.20 | 29.20 | ok |
| 1.0 GiB | metal | device-copy-auto | 14.77 | 6.67 | 15.01 | 15.01 | ok |
| 1.0 GiB | metal | device-copy-gpu | 9.00 | 1.07 | 15.29 | 15.29 | ok |
jsonOutput=/tmp/m6-copy-api-ab.json
