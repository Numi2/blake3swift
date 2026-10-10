metal-command-timing path=BLAKE3 Swift no-copy input policy=gpu bytes=1073741824 schedule_s=0.015697541666668258 gpu_s=0.014343541666676174 input_gib_per_gpu_s=69.71778820312305
metal-command-timing path=BLAKE3 Swift no-copy input policy=automatic bytes=1073741824 schedule_s=0.007057916666781239 gpu_s=0.010155124999982945 input_gib_per_gpu_s=98.47244617881901
metal-command-timing path=BLAKE3 Swift no-copy input policy=gpu bytes=1073741824 schedule_s=0.006772749999981897 gpu_s=0.010525874999984808 input_gib_per_gpu_s=95.00397829172807
metal-command-timing path=BLAKE3 Swift no-copy input policy=gpu bytes=1073741824 schedule_s=0.007269541666573787 gpu_s=0.010913291666838631 input_gib_per_gpu_s=91.6313822197772
metal-command-timing path=BLAKE3 Swift no-copy input policy=automatic bytes=1073741824 schedule_s=0.009724874999847088 gpu_s=0.01077766666730895 input_gib_per_gpu_s=92.78446168995201
metal-command-timing path=BLAKE3 Swift no-copy input policy=gpu bytes=1073741824 schedule_s=0.00950087499950314 gpu_s=0.010988416666805279 input_gib_per_gpu_s=91.00492184837539
metal-command-timing path=BLAKE3 Swift no-copy input policy=gpu bytes=1073741824 schedule_s=0.00955199999953038 gpu_s=0.011008916667378799 input_gib_per_gpu_s=90.83545912952196
metal-command-timing path=BLAKE3 Swift no-copy input policy=automatic bytes=1073741824 schedule_s=0.009135833332948096 gpu_s=0.010590374999992491 input_gib_per_gpu_s=94.42536265247539
metal-command-timing path=BLAKE3 Swift no-copy input policy=gpu bytes=1073741824 schedule_s=0.006964375000279688 gpu_s=0.009882750000542728 input_gib_per_gpu_s=101.18641065949086
metal-command-timing path=BLAKE3 Swift no-copy input policy=gpu bytes=1073741824 schedule_s=0.007256249999954889 gpu_s=0.009772500000508444 input_gib_per_gpu_s=102.32796111005085
metal-command-timing path=BLAKE3 Swift no-copy input policy=automatic bytes=1073741824 schedule_s=0.007184749999396445 gpu_s=0.010105333332830924 input_gib_per_gpu_s=98.95764613237735
metal-command-timing path=BLAKE3 Swift no-copy input policy=gpu bytes=1073741824 schedule_s=0.006665625000096043 gpu_s=0.009784000000763626 input_gib_per_gpu_s=102.2076860100114
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
metalCommandTiming=true
metal-wrapped includes: timed no-copy MTLBuffer wrapper over existing Swift bytes plus hash
headlineRows=default-auto and overlapping metal timing modes run in interleaved ping-pong order
overheadAcceptance=prefer benchmarks/run-isolated-overhead.sh for resident/private/staged/wrapped tuning; mixed rows are secondary when upload paths change
sizes=1.0 GiB
cryptoKitModes=none

| Size | Backend | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 1.0 GiB | cpu | scalar | 1.35 | 1.35 | 1.35 | 1.35 | ok |
| 1.0 GiB | cpu | single-simd | 2.14 | 2.14 | 2.14 | 2.14 | ok |
| 1.0 GiB | cpu | parallel | 17.41 | 17.28 | 17.48 | 17.48 | ok |
| 1.0 GiB | official-c | one-shot | 2.62 | 2.62 | 2.62 | 2.62 | ok |
| 1.0 GiB | cpu | context-auto | 17.13 | 16.94 | 17.51 | 17.51 | ok |
| 1.0 GiB | blake3 | default-auto | 57.92 | 54.30 | 58.54 | 58.54 | ok |
| 1.0 GiB | metal | wrapped-auto | 49.68 | 47.88 | 57.11 | 57.11 | ok |
| 1.0 GiB | metal | wrapped-gpu | 48.10 | 48.07 | 59.98 | 59.98 | ok |
jsonOutput=/tmp/m6-command-timing-validated.json
