# Apple M6 one-chunk batch and aggregate-path performance

This experiment measured the independent one-chunk batch path and its repeated-plan command pipelines on the M6 Mac mini. It followed Apple's profiling guidance by checking available GPU counters and by keeping throughput and correctness evidence separate from a hardware bottleneck diagnosis.

## Machine and source

- Apple M6 Mac mini, Mac18,5, 16 GB unified memory, macOS 27.0, Swift 6.4, 12 active CPUs.
- Metal library: runtime source. Benchmark binary SHA-256: `b00a4fc1626c742cf709339a3e3d0afbdf46a315e6e1953aabb643bbebfe6797`.
- Product sources matched the current checkout: `BLAKE3Metal.swift` `a12df53d7e9701f97d626877816e9993da41717926fcb73b6d433240fc8c2915`, `BLAKE3MetalKernel.swift` `710b7182afc6615ff5b478593be273eab7934392af5436dfd41c0652e49ef9d1`, and benchmark `main.swift` `47f760adb5caa53883271639377c6381970fe12c6e415f06838d8e3f0f1ca78e`.
- The initial pipeline-width sweep did not change product source. A later aggregate-path follow-up added a cached private output buffer and routed eligible public aggregate calls through the existing write-and-chain path. All aggregate JSON reports validated and every row reported correct digests. Thermal and memory snapshots are retained next to the reports; no thermal or performance warning was recorded.

## Results

The 64 MiB workload used 1 KiB messages and five interleaved samples per width. The best tested candidate was width 32. The table compares the non-pipelined and width-32 candidate from the same run; the pipeline figures also show the stability-adjusted rate `min(full median, first-half median, last-half median)`.

| Output path | One plan call GiB/s | Width 32 median GiB/s | Width 32 stability-adjusted GiB/s | Stability-adjusted gain |
| --- | ---: | ---: | ---: | ---: |
| Shared plan write | 35.40 | 101.98 | 100.92 | 2.85× |
| Private plan write | 67.47 | 102.42 | 101.54 | 1.50× |
| Private plan write plus chained output hash | 79.54 | 97.93 | 97.93 | 1.23× |

The 16 MiB workload used 64-byte messages. Three interleaved sweeps compared widths up to 48. For private plan writes, widths 44 and 48 settled around 110–111 GiB/s; width 44 was the highest single-run stability-adjusted candidate at 111.20 GiB/s. A repeat measured 110.40 GiB/s stability-adjusted at width 44 and 110.46 at width 48, so the data supports a broad plateau, not a distinct width-44 optimum. The chained output-hash path plateaued near 65 GiB/s by widths 24–32 and did not improve at wider widths.

For the same 16 MiB, 64-byte-message batch, the original public `hashOneChunkBatchDigestBytes(plan:)` path measured 11.50 and 11.49 GiB/s in the initial runs. The serial CPU batch reference measured 0.420 and 0.417 GiB/s, a 27.4–27.6× GPU/CPU ratio for the same aggregate digest. The plan and resident input buffer are prepared outside the timed call, so these rows exclude plan construction and input upload. No archived M4 result uses this workload.

### Aggregate-path follow-up

The old public plan path fused per-message hashing with the final aggregate hash and measured 9.665 GiB/s in a seven-sample isolated baseline. The follow-up reuses a private Metal output buffer of up to 32 MiB per context, writes per-message digests, and hashes that output with the existing chained GPU path. The new plan API row measured 23.369 GiB/s median (21.926 minimum, 41.876 p95) on the same 16 MiB workload. Two earlier seven-sample candidate runs measured 24.884 and 23.074 GiB/s medians; they used the old benchmark row name `plan-fused-aggregate`, although the candidate implementation already took the chained route. Against the highest pre-change M6 measurement of 11.50 GiB/s, the consistent gain is 2.03×; against the isolated 9.665 GiB/s baseline it is 2.42×. A high outlier in each seven-sample candidate run raises p95, so the medians and minima are the useful comparison.

The serial CPU batch reference stayed near 0.418 GiB/s, putting the new plan API at 55.9× that reference on this M6. This is the same batch operation on one device, not a cross-hardware result. A 64 MiB input with 64-byte messages produces a 32 MiB digest buffer at the cache limit and measured 39.173 GiB/s; there is no matched old-code run for that size. For 1 KiB messages, the new plan API measured 73.342 and 75.827 GiB/s across two 64 MiB runs, versus the previous 58.070 GiB/s result (1.26–1.31×). Two 256 MiB candidate runs measured 94.369 and 85.972 GiB/s; no matching earlier M6 or M4 baseline is available for that size.

The context creates the cached buffer lazily and retains it while the context lives. The benchmark performs an untimed warm-up, so reported values are steady-state and exclude first-call buffer allocation. Results above the 32 MiB cache limit or after an allocation failure retain the existing fused fallback. Apple documents that each `makeBuffer(length:options:)` call creates a new allocation and that private storage is GPU-only; this supports the reuse and storage choice, but does not explain the speedup by itself ([`MTLBuffer`](https://developer.apple.com/documentation/metal/mtlbuffer), [resource fundamentals](https://developer.apple.com/documentation/metal/resource-fundamentals)).

The single 1 GiB resident-GPU headline remains the comparable cross-machine reference: the best validated M6 median in the archive is 108.748 GiB/s, versus 83.245 GiB/s on M4, or 1.31×. This comparison uses the same benchmark timing class but archived runs, not a same-build paired experiment. This batch experiment is a separate workload; there is no prior M4 result for these one-chunk batch pipeline rows.

## Interpretation and limits

`OneChunkBatchWritePipeline` is marked `@_spi(Benchmark)`. Each candidate replays one stable input plan into multiple output buffers and reports throughput per in-flight replay. This measures repeated-plan steady-state throughput, not single-call latency and not a stream of distinct input buffers. Reuse of the same input can improve cache behavior. The width sweep is useful for selecting the next implementation experiment, but it does not establish an application-level speedup or justify changing a public default. The separate 55.9× result uses the public aggregate API once per sample and has matching CPU/GPU semantics.

Apple recommends measuring actual GPU memory bandwidth and occupancy, and correlating those counters before diagnosing a limiter ([bandwidth guidance](https://developer.apple.com/documentation/xcode/measuring-the-gpus-use-of-memory-bandwidth), [occupancy guidance](https://developer.apple.com/documentation/xcode/finding-your-metal-apps-gpu-occupancy), [Metal GPU counters](https://developer.apple.com/documentation/metal/gpu-counters-and-counter-sample-buffers)). Apple describes occupancy as a counter to interpret alongside other measurements, not as an isolated optimization target ([occupancy guidance](https://developer.apple.com/documentation/xcode/finding-your-metal-apps-gpu-occupancy)). The M6 runtime probe in [`counter-capabilities.txt`](../20261010T-m6-vector-loads/counter-capabilities.txt) exposed only the `GPUTimestamp` counter set; Xcode, Instruments, and `xctrace` are unavailable on the host ([availability record](../20261010T-m6-vector-loads/instrumentation-availability.txt)). These throughput measurements therefore do not prove whether the remaining limit is shader occupancy, arithmetic, cache, or external-memory bandwidth.

Apple lists 153 GB/s memory bandwidth for the M6 Mac mini's 16 GB configuration ([technical specifications](https://www.apple.com/mac-mini/specs/)). The 1 GiB resident result is about 116.7 GB/s. That ceiling leaves only about 1.31× theoretical headroom for the same one-read byte-throughput metric; it cannot reach 10× by tuning that path alone. The comparable archived M4 1 GiB resident result is 83.245 GiB/s, so the M6 uplift remains 1.31×. The new batch workload exceeds 10× against its serial CPU reference on M6, but has no matched M4 result yet and does not establish a 10× cross-hardware gain.

## Artifacts

- `pipeline-width-r1.json`: 64 MiB, 1 KiB messages, widths 4–32.
- `pipeline-width-64b-r1.json` through `pipeline-width-64b-r3.json`: 16 MiB, 64-byte messages, interleaved width sweeps and repeat confirmation.
- `batch-16m-item-1k-r1.json` and `batch-64m-item-1k-r1.json`: non-pipeline batch-path baselines.
- `aggregate-baseline-16m-64b-r1.json`, `aggregate-candidate-16m-64b-r1.json`, and `aggregate-candidate-16m-64b-r2.json`: isolated old-code baseline and repeated candidate runs. The candidate's legacy mode label says `fused-aggregate`; after the source change that row timed the public API's chained implementation.
- `aggregate-candidate-16m-64m-64b-r1.json` and `aggregate-candidate-64m-256m-1k-r2.json`: candidate runs with the corrected `aggregate-api` mode label, including the 32 MiB cache-boundary input.
- `aggregate-candidate-64m-256m-1k-r1.json`: earlier candidate size sweep; its 64 MiB row is directly comparable with `batch-64m-item-1k-r1.json`.
- `aggregate-candidate-provenance.txt`, `validation-aggregate-final.txt`, and the `thermal-*-aggregate-*.txt` snapshots: final source and binary hashes, validation output, and host state around the aggregate follow-up.
- `environment.txt`, validation logs, source/binary hashes, and before/after thermal and memory snapshots preserve provenance.
