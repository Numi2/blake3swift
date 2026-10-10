# M6 Metal threadgroup tuning

## Scope and result

This records a measured compiler hint for the digest-only Metal pipelines, an Apple-documented pipeline thread limit experiment, and a SIMD-group-size sweep on the Apple M6 Mac mini (Mac18,5, macOS 27.0, Swift 6.4). All accepted benchmark JSON rows passed digest verification.

Setting `threadGroupSizeIsMultipleOfThreadExecutionWidth` to `true` is retained for the digest-only pipelines. Across four 1 GiB resident-buffer runs it improved the median of run medians by 0.85%; across four private-buffer runs it improved that statistic by 1.51%. Per-iteration distributions overlap, so treat this as a small, noisy improvement. Wrapped-buffer results did not establish a gain.

The optional `maxTotalThreadsPerThreadgroup` experiment did not show a repeatable improvement over Metal's automatic setting across resident and private input paths. Its temporary runtime control was removed. The threadgroup-size sweeps also did not find a generally faster setting.

The 10x target remains unmet. On the same 1 GiB resident-GPU metric, the strongest archived M4 row is 83.245 GiB/s and the latest M6 three-process median is 108.175 GiB/s, about 1.30x. Those results came from different source revisions. The strongest archived M4 CPU-parallel row was 12.38 GiB/s; M6 reached about 17.3 GiB/s, about 1.40x, which is a separate execution class. The M6's published 16 GB memory-bandwidth figure makes a 10x resident streaming result physically out of reach; see [the compiler A/B and bandwidth feasibility note](../20261010T-m6-compiler-optimization-level/README.md).

## Apple guidance applied

- Apple defines `threadExecutionWidth` as the number of threads a GPU executes simultaneously and advises deriving group sizes from that value and the pipeline's maximum. The digest dispatch helper uses whole multiples of the execution width; the fused-tile path checks divisibility before dispatch. See [thread execution width](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate/threadexecutionwidth) and [calculating threadgroup and grid sizes](https://developer.apple.com/documentation/metal/calculating-threadgroup-and-grid-sizes).
- Apple says the `threadGroupSizeIsMultipleOfThreadExecutionWidth` descriptor flag can enable additional optimizations when the guarantee is true. The invariant was checked against the digest dispatch paths, then measured before making the flag the default for those pipelines. See [the descriptor property](https://developer.apple.com/documentation/metal/mtlcomputepipelinedescriptor/threadgroupsizeismultipleofthreadexecutionwidth).
- Apple describes `maxTotalThreadsPerThreadgroup` as a dispatch limit. A value of zero lets Metal choose automatically; an overly restrictive value may lower the pipeline limit and hurt runtime performance. Apple also presents the property as a per-device occupancy tuning control, with profiling required. See [the pipeline descriptor property](https://developer.apple.com/documentation/metal/mtlcomputepipelinedescriptor/maxtotalthreadsperthreadgroup) and [WWDC23: Optimize GPU renderers with Metal](https://developer.apple.com/videos/play/wwdc2023/10127/).
- Apple cautions that occupancy by itself does not diagnose a problem: low occupancy can follow from resource limits or small dispatches, and high occupancy can still involve cache contention. It recommends correlating occupancy with limiter counters and bandwidth. See [finding GPU occupancy](https://developer.apple.com/documentation/xcode/finding-your-metal-apps-gpu-occupancy) and [measuring GPU memory bandwidth](https://developer.apple.com/documentation/xcode/measuring-the-gpus-use-of-memory-bandwidth).

The M6 exposes only `GPUTimestamp` counters in the available runtime. The host has Command Line Tools but no Xcode, Instruments, `xctrace`, or `metal` utility. This work therefore cannot identify whether the remaining ceiling is arithmetic, occupancy, or memory bandwidth. The full counter workflow Apple documents is the next high-value measurement.

The full-chunk digest path reads each input chunk and emits chaining values needed by the reduction. No obvious redundant input pass emerged from source review. Further algorithm or layout changes should follow counter evidence rather than another unprofiled dispatch-size guess.

## Final clean-source verification

After removing the experimental maximum-thread control, the M6 release build was restored to the exact default-on hint source hashes below and rebuilt successfully. All benchmark rows passed digest verification: 16 MiB resident-GPU 25.095 GiB/s, 1 GiB resident-GPU 107.340 GiB/s, 1 GiB private-GPU 92.016 GiB/s, and 1 GiB wrapped-GPU 59.596 GiB/s. Three immediate private-path repeats measured 97.728, 97.061, and 97.556 GiB/s. `pmset -g therm` reported no thermal or performance warning before or after; the low 92.016 result remains unexplained. Build and raw output are in `raw/final-default/`.

## Thread-width hint comparison

Each cell lists the per-run median GiB/s for six 1 GiB iterations. “Run median” below means the median across process-level medians.

| Path | Without hint | With hint | Change in run median |
| --- | --- | --- | ---: |
| Resident GPU | 106.917, 105.224, 105.610, 107.307 | 107.091, 107.250, 106.251, 107.323 | +0.85% |
| Private GPU | 92.843, 95.650, 95.566, 97.514 | 97.057, 97.045, 95.015, 97.516 | +1.51% |
| Wrapped GPU | 58.697, 60.053 | 59.472, 59.785 | +0.43% |
| Wrapped automatic | 58.826, 59.462 | 58.068, 58.952 | -1.07% |

The resident per-iteration medians overlap and their mean difference is below 0.5%. Later private-path checks included 96.917, 96.673, 95.451, 97.728, 97.061, and 97.556 GiB/s, plus low results of 91.20 and 92.016 GiB/s. The three latest repeats had a median of 97.556 GiB/s; the low results' cause was not established. These values are retained under `raw/` and are not presented as a stable large gain.

## Maximum-threads experiment

The temporary build set `MTLComputePipelineDescriptor.maxTotalThreadsPerThreadgroup` to 128, 256, or 512 for the digest pipeline states, or left it at the automatic default. Each setting used two separately launched six-iteration 1 GiB runs per input path. The stdout file for each run records the setting, and every JSON row has `correct=true`.

| Path | Automatic | 128 | 256 | 512 |
| --- | ---: | ---: | ---: | ---: |
| Resident GPU | 106.774, 107.412 | 107.059, 107.170 | 107.107, 105.082 | 107.127, 107.166 |
| Private GPU | 92.874, 98.031 | 97.629, 96.907 | 97.426, 97.773 | 97.584, 96.790 |

Resident throughput is effectively unchanged. Private-path process medians vary; the later automatic run exceeds the fixed-limit runs, so the apparent advantage from the low first automatic run is not repeatable evidence. Keep Metal's automatic limit. These measurements are retained in `raw/pipeline-max/`; the temporary source and build log are identified there by SHA-256.

The 16 MiB smoke used the 128-thread setting and all eight benchmark rows were correct. The first full setting sweep is retained in `raw/pipeline-max-stale-source/` but excluded: remote source hashes proved the multi-file copy had not transferred the experiment code, so those runs only measured the default pipeline.

## SIMD-group sweep

The valid large-grid, non-fused sweep changed the target from one to sixteen SIMD groups per threadgroup. Each value had two 1 GiB resident-GPU runs; all digests were correct.

| SIMD groups | Run medians (GiB/s) |
| ---: | ---: |
| 1 | 97.245, 97.666 |
| 2 | 97.637, 98.041 |
| 4 | 97.353, 93.155 |
| 8 | 83.965, 96.978 |
| 16 | 95.687, 96.937 |

Variation obscures any winner. In a separate private-input comparison, four groups beat two in the observed runs, but the result was not broad enough to change the resident default. The first sweep had a malformed multi-value environment setting and was interrupted; its raw record remains excluded under `raw/m6-gridgroups-1 2 4 8 16-r1/`.

## Build provenance

The accepted width-hint and SIMD-group runs used release source SHA-256 values:

| File | SHA-256 |
| --- | --- |
| `Sources/Blake3/BLAKE3Metal.swift` | `f1e2399d5fdd2a180ff0b561f13c70390b64f97d503c96cca963244ceec0e89b` |
| `Sources/Blake3/BLAKE3MetalKernel.swift` | `710b7182afc6615ff5b478593be273eab7934392af5436dfd41c0652e49ef9d1` |
| `Sources/Blake3Benchmark/main.swift` | `d06ffdc2c931de188e21dc41b61c824477135c0a8de54656fb270b7f41e77977` |

The temporary maximum-threads build used kernel SHA-256 `39cded7a6d4ade4d172dc92ea4c8083c5b67072aa5a94958b6c9ff4ee22e8ccd` and benchmark SHA-256 `012ea9da36d50240e3813d14549cdb909679547fd3f9d9eee0e9914e8ffd6e2e`. The build log and raw JSON/Markdown outputs are retained beside that experiment.
