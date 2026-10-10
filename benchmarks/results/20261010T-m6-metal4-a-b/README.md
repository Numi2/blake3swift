# M6 Metal 4 command path comparison

## Scope

This is an opt-in backend experiment on the Apple M6 Mac mini (Mac18,5), macOS 27.0, Swift 6.4. It compares the existing `MTLCommandQueue` path with `MTL4CommandQueue` for the same BLAKE3 kernels. Inputs were hashed from pre-created shared `MTLBuffer`s and from Swift-owned bytes wrapped with `makeBuffer(bytesNoCopy:)`. Every accepted benchmark row passed digest comparison.

Build and smoke commands:

```sh
swift build -c release --product blake3-bench
BLAKE3_SWIFT_METAL_BACKEND=metal4 .build/release/blake3-bench \
  --sizes 16m --iterations 1 --metal-modes resident \
  --file-modes none --cryptokit-modes none
```

The MTL4 path is selected only when `BLAKE3_SWIFT_METAL_BACKEND=metal4`; it currently covers unkeyed digest hashing. The normal legacy path remains the default.

## Matched results

Each resident row used six 1 GiB iterations. Results are medians from two separately launched runs per backend.

| Input path | Legacy runs (GiB/s) | Metal 4 runs (GiB/s) | Paired median difference | Correct |
| --- | ---: | ---: | ---: | --- |
| Pre-created resident shared buffer | 105.60, 105.95 | 106.11, 105.17 | -0.13% | Yes |
| Swift bytes, no-copy wrapper | 59.72, 62.28 | 60.78, 59.58 | -1.35% | Yes |

The MTL4 path produced no repeatable throughput gain in these classes. It remains opt-in for further profiling and should not be selected as the default from these results.

A final guarded-build correctness smoke used only three 1 GiB iterations and reported 86.60 GiB/s for `resident-gpu`. A follow-up six-iteration run on the same final build measured 105.13 GiB/s for MTL4 and 104.88 GiB/s for legacy; every row was correct, and `pmset -g therm` reported no thermal or performance warning before or after. These later checks are preserved under `development/` and excluded from the planned two-pair headline comparison. The short smoke is an observed outlier; its cause was not established.

The same-build fused-reduction follow-up compared `pingpong` and `inplace` at 256 MiB and 1 GiB over two alternating pairs. In the stable second pair, 256 MiB resident GPU medians were 95.23 GiB/s (`pingpong`) and 95.52 GiB/s (`inplace`); 1 GiB medians were 104.66 and 104.51 GiB/s. That difference is within run variation, so the default reduction strategy stays unchanged.

## Apple documentation findings

- Apple describes Metal 4 command queues as reducing CPU runtime and memory overhead, and supports grouped command-buffer commits: [Understanding the Metal 4 core API](https://developer.apple.com/documentation/metal/understanding-the-metal-4-core-api), [MTL4CommandQueue](https://developer.apple.com/documentation/metal/mtl4commandqueue).
- Metal 4 argument tables snapshot bindings at dispatch. This implementation binds GPU addresses and attaches an explicit residency set: [MTL4ArgumentTable](https://developer.apple.com/documentation/metal/mtl4argumenttable), [Simplifying GPU resource management with residency sets](https://developer.apple.com/documentation/metal/simplifying-resource-management-with-residency-sets).
- The reduction kernels have dispatch-to-dispatch dependencies. The MTL4 encoder therefore adds an intra-pass dispatch barrier between each dependent dispatch: [Synchronizing stages within a pass](https://developer.apple.com/documentation/metal/synchronizing-stages-within-a-pass).
- Apple's timing properties distinguish CPU scheduling (`kernelStartTime` through `kernelEndTime`) from GPU execution (`GPUStartTime` through `GPUEndTime`): [kernelStartTime](https://developer.apple.com/documentation/metal/mtlcommandbuffer/kernelstarttime), [GPUStartTime](https://developer.apple.com/documentation/metal/mtlcommandbuffer/gpustarttime), [GPUEndTime](https://developer.apple.com/documentation/metal/mtlcommandbuffer/gpuendtime). The earlier command-timing record shows both intervals are material on this M6, but they overlap; do not add them as serial wall time.

## Limits and next measurement

The M6 exposes timestamp sampling at stage boundaries, but the runtime probe found only the `GPUTimestamp` counter set. Xcode, Instruments, and the `xctrace` utility are unavailable on the host (`xcode-select` points to Command Line Tools). The benchmark cannot yet distinguish shader occupancy, arithmetic limits, and actual memory-bandwidth saturation. Apple's [GPU memory-bandwidth guide](https://developer.apple.com/documentation/xcode/measuring-the-gpus-use-of-memory-bandwidth) recommends Instruments counters for that distinction.

The MTL4 API is available on this M6 and the 16 MiB and 1 GiB unkeyed digest paths passed correctness checks. Keyed hashing and XOF are not routed through this experimental backend.

The 10x target is not met. On the same 1 GiB resident-GPU metric, the earlier M4 best in the repository is 68.99 GiB/s and the M6's clean three-run median is 107.69 GiB/s (about 1.56x). These historical results use different source revisions. The M6 CPU-parallel result is 17.27 GiB/s versus the earlier M4 result of 3.78 GiB/s (about 4.57x); neither same-class comparison establishes 10x.

## Preserved development evidence

- `development/initial-digest-mismatch-summary.txt` records the first MTL4 reduction attempt's missing-barrier digest mismatch and correction. The original stderr was not retained, so this is a work-log summary rather than a raw diagnostic.
- `development/first-type-erased-ab-*.md` and JSON preserve the early A/B pair in which the experimental existential adapter slowed the legacy path. That pair is confounded and excluded from the accepted comparison above; generic specialization removed that extra dispatch cost.
- `development/` also contains the final 16 MiB correctness smoke and successful M6 release-build log.
- `development/m6-metal4-final-guard-1g.*` and `m6-guard-recheck-*` preserve the short final-build smoke, six-iteration follow-up runs, and thermal-status snapshots.
- `resident/`, `wrapped/`, and `fused/` contain the raw JSON and Markdown reports used for the tables.
- [The earlier command-buffer timing probe and M6 counter availability](../20261010T-m6-command-buffer-timing/command-timing.md).
- `provenance.txt` records the host/toolchain and SHA-256 hashes of the exact source files built on M6.
