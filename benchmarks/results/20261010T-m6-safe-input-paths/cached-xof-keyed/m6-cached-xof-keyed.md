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
sizes=64.0 MiB
operationModes=keyed,xof,keyed-xof
xofOutputByteCount=32
operation-keyed includes: timed BLAKE3 keyed hash over existing Swift bytes, plus matching Metal variants for requested Metal ownership modes
operation-xof includes: timed BLAKE3 XOF output over existing Swift bytes, with output length controlled by --xof-output-bytes
operation-keyed-xof includes: timed BLAKE3 keyed XOF output over existing Swift bytes, with output length controlled by --xof-output-bytes
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 64.0 MiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 64.0 MiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 64.0 MiB | cpu | parallel | 16.38 | 16.31 | 16.58 | 16.58 | ok |
| 64.0 MiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 64.0 MiB | cpu | context-auto | 16.28 | 15.28 | 16.55 | 16.55 | ok |
| 64.0 MiB | blake3 | default-auto | 23.09 | 15.46 | 23.15 | 23.15 | ok |
| 64.0 MiB | cpu | keyed | 17.03 | 15.23 | 17.05 | 17.05 | ok |
| 64.0 MiB | cpu | xof-32 | 10.10 | 9.98 | 10.12 | 10.12 | ok |
| 64.0 MiB | cpu | keyed-xof-32 | 9.84 | 9.83 | 10.07 | 10.07 | ok |
| 64.0 MiB | metal | keyed-wrapped-gpu | 23.44 | 23.37 | 23.54 | 23.54 | ok |
| 64.0 MiB | metal | xof-32-wrapped-gpu | 20.23 | 20.08 | 21.02 | 21.02 | ok |
| 64.0 MiB | metal | keyed-xof-32-wrapped-gpu | 19.46 | 19.20 | 20.29 | 20.29 | ok |
| 64.0 MiB | metal | wrapped-auto | 23.45 | 23.11 | 23.61 | 23.61 | ok |
| 64.0 MiB | metal | wrapped-gpu | 23.58 | 23.11 | 23.66 | 23.66 | ok |
jsonOutput=/tmp/m6-cached-xof-keyed.json
