# Apple M6 contiguous 64-byte batch aggregate path

This experiment removes per-range plan discovery from the common case where a caller hashes adjacent 64-byte messages in one resident Metal buffer, then hashes the concatenated message digests. The new overload accepts the first byte offset and block count directly and reuses a one-entry Metal plan. It uses the existing BLAKE3 batch and aggregate kernels.

## M6 results

The old range-array API was measured on the same M6 with a seven-sample release run. The first optimization that skipped redundant alignment checks on contiguous 64-byte ranges raised that API to 16–17 GiB/s. The new direct overload avoids walking the ranges array and reaches the prepared-plan path's throughput.

| Input | Old range API baseline | Range API after alignment reuse | Direct API runs, median / minimum (GiB/s) | Direct API gain over old baseline |
| ---: | ---: | ---: | --- | ---: |
| 16 MiB | 4.10 | 16.51–16.96 | 41.49 / 38.30; 42.38 / 38.60; 42.72 / 38.74 | 10.1–10.4× |
| 64 MiB | 4.34 | 16.23–16.47 | 51.38 / 51.04; 52.70 / 51.81; 51.45 / 51.04 | 11.8–12.1× |

Within the same final M6 process, the direct API and the prebuilt-plan API were statistically similar: 42.72 versus 41.06 GiB/s at 16 MiB, and 51.45 versus 51.37 GiB/s at 64 MiB. Every batch row returned the expected digest. The three direct-API JSON reports and the 96-byte irregular-range check pass `blake3-bench --validate-json`.

A final 15-sample validation after the Apple-doc-guided follow-up measured 44.36 GiB/s (40.45 minimum) at 16 MiB and 54.53 GiB/s (51.68 minimum) at 64 MiB. Against the original M6 range-array baseline of 4.10 and 4.34 GiB/s, those final medians are 10.8× and 12.6× for the same resident aggregate operation. Every row was correct and the JSON validated.

The 16 MiB range-array baseline used seven timed samples; the direct API runs used seven, fifteen, and fifteen timed samples. The benchmark performs one untimed warm-up before each row. Inputs and the context's private output buffer are resident and reused, so these are steady-state operation measurements, not upload or first-call latency.

## What changed

- The 64-byte overload validates its base offset and block count in constant time, then uses the existing contiguous-block GPU kernel.
- A context keeps one shared entry buffer and one parameter buffer for synchronous contiguous batch calls. A separate lock protects them until the command buffer completes.
- The range-array implementation still supports arbitrary ranges. For contiguous 64-byte ranges, it checks alignment once because later message starts advance by 64 bytes; it retains per-range alignment checks after the ranges cease to be contiguous.
- Two earlier candidates that only compacted the entry descriptor or reused metadata buffers did not improve the range-array row. Those reports remain here. The measured range-array gain appeared after eliminating the repeated `MTLBuffer.contents()` alignment query; the direct overload removes the remaining range scan.

## Scope and limits

This is a 10×-plus M6 gain over the old convenience API for this specific batch operation. It is not a 10× cross-hardware result: the archived M4 reports have no matched 64-byte batch aggregate row, and the M4 host was running unrelated high-CPU jobs during this experiment. A matched M4 run is still required for the cross-hardware comparison. The historical 1 GiB resident-hash row is a different workload and is not used in this ratio.

Apple recommends aligning threadgroups to each pipeline's `threadExecutionWidth` and respecting its maximum size; this change leaves dispatch sizing alone. Apple also recommends correlating occupancy, bandwidth, and limiter counters rather than inferring the bottleneck from throughput alone ([threadgroup sizing](https://developer.apple.com/documentation/metal/calculating-threadgroup-and-grid-sizes), [GPU occupancy](https://developer.apple.com/documentation/xcode/finding-your-metal-apps-gpu-occupancy), [GPU memory bandwidth](https://developer.apple.com/documentation/xcode/measuring-the-gpus-use-of-memory-bandwidth)). On M6, `/usr/bin/xctrace` is present but requires full Xcode; the active developer directory is Command Line Tools, so Instruments GPU counters remain unavailable.

## Apple-doc-guided alternatives

Apple says Metal 4's unified compute encoder can reduce host overhead by combining work that would otherwise use multiple encoders and passes ([Metal 4 compute encoder](https://developer.apple.com/documentation/metal/mtl4computecommandencoder), [Apple sample](https://developer.apple.com/documentation/metal/combining-blit-and-compute-operations-in-a-single-pass)). I tried the aggregate batch dispatch and its output-tree hash in one Metal 4 encoder. The 15-sample M6 medians for the direct API were 42.48 versus 42.90 GiB/s at 16 MiB, and 49.17 versus 51.27 GiB/s at 64 MiB for Metal 4 versus the legacy encoder. All digests were correct, but the run showed no durable improvement, so the product path stays on the existing encoder.

The Metal 4 prototype's source and binary checksums were not captured before that temporary branch was rebuilt; treat those two comparison reports as exploratory measurements rather than source-pinned qualification. The fused chunk-CV comparison below has source and binary hashes recorded.

Apple also recommends reducing unnecessary GPU reads and writes ([memory bandwidth guidance](https://developer.apple.com/documentation/xcode/measuring-the-gpus-use-of-memory-bandwidth)). I tested the existing chunk-CV kernel as the first aggregate stage so it could avoid materializing every intermediate message digest. In a seven-sample paired M6 comparison, direct-API medians fell from 41.34 to 11.44 GiB/s at 16 MiB and from 52.83 to 13.06 GiB/s at 64 MiB. The candidate returned correct digests but was 3.6–4.1× slower; it was discarded. The timing alone does not explain why, and the available M6 counters cannot separate occupancy from bandwidth or instruction limits.

The first Metal 4 prototype double-ended its compute encoder and crashed. A crash report identified the second `endEncoding()` call; the prototype was fixed, then the paired results above were collected. The failed smoke and corrected run are recorded in `metal4-smoke-failure.txt` and the JSON reports.

## Artifacts

- `baseline-current.json`: original range-array API, before this change.
- `compact-descriptor.json` and `cached-metadata.json`: candidates that did not improve the convenience row.
- `skip-align.json`: range-array path after alignment-check reuse.
- `contiguous-r1.json`, `contiguous-r2.json`, `contiguous-r3.json`: direct API and same-process comparison rows; all digests are correct.
- `final-direct-r1.json`: final source, 15-sample validation of the contiguous API.
- `generic-96b.json`: irregular-size range path correctness check.
- `metal4-r1.json` and `metal3-r1.json`: 15-sample unified-versus-legacy encoder comparison.
- `metal4-smoke-one-sample.json`: one-sample Metal 4 smoke report; not used for the comparison.
- `fused-chunk-cv-r1.json` and `legacy-paired-r1.json`: seven-sample fused-versus-staged aggregate comparison.
- `metal4-smoke-failure.txt`: initial Metal 4 smoke failure and diagnosis.
- `provenance.txt`: source, binary, device, and benchmark command provenance.
- `m4-availability.txt`: M4 load snapshots taken while deciding whether a matched run was safe.
