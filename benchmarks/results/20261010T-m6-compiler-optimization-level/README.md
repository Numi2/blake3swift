# M6 Metal shader compiler optimization-level A/B

## Result

On the M6 Mac mini (`Mac18,5`, 16 GB, macOS 27.0, Swift 6.4), I compared runtime-source Metal compilation at the default optimization level with `MTLLibraryOptimizationLevel.size`. Each process hashed the same resident 1 GiB shared `MTLBuffer`, ran six timed iterations, and checked the digest. Three separate processes per setting passed correctness; thermal snapshots showed no warning.

| Runtime shader optimization | Per-process `resident-gpu` medians (GiB/s) | Median across processes |
| --- | --- | ---: |
| Default | 108.175, 108.357, 108.112 | 108.175 |
| Size | 108.209, 108.140, 108.494 | 108.209 |

The difference is **0.03%**, well within run variation. Keep the default compiler setting; the size option did not improve hashing throughput. The optional experiment switch was removed from production sources. `size-optimization-experiment.patch` preserves the exact temporary change, and all benchmark reports, JSON, validation output, provenance, and thermal snapshots are included here.

The first attempt to build the benchmark with the temporary switch failed because its new output string did not parse. That attempt produced no benchmark data. The source was corrected, rebuilt successfully on M6, and then the six accepted runs were collected; the initial failure is retained in `initial-build-failure.txt`.

## Apple documentation and hardware context

Apple documents `.default` as prioritizing runtime performance and `.size` as prioritizing smaller binaries. Apple also describes loop unrolling and inlining as compiler optimizations whose runtime effects depend on the shader, so the relevant question here was empirical throughput, not binary size. See [Metal library optimization levels](https://developer.apple.com/documentation/metal/mtllibraryoptimizationlevel) and [minimizing shader-library size](https://developer.apple.com/documentation/metal/minimizing-the-binary-size-of-a-shader-library).

Apple lists **153 GB/s** memory bandwidth for the M6 Mac mini’s 16 GB configuration; the 24 GB and 32 GB configurations list up to 170 GB/s. The 1 GiB resident M6 measurement of 108.175 GiB/s is about 116.2 GB/s. A one-read streaming ceiling from 153 GB/s would be about 142.5 GiB/s before accounting for the hash’s chaining-value traffic. This is a hardware-bound estimate, not proof that the kernel is memory-bound: the remote host lacks Xcode/Instruments GPU bandwidth and occupancy counters. See [Apple’s M6 Mac mini specifications](https://www.apple.com/mac-mini/specs/) and Apple’s [GPU bandwidth profiling guidance](https://developer.apple.com/documentation/xcode/measuring-the-gpus-use-of-memory-bandwidth).

The strongest archived M4 resident-GPU row is **83.245 GiB/s** in [`20260421T-digest-fastpath-mixed/mixed.json`](../20260421T-digest-fastpath-mixed/mixed.json); the current three-process M6 median is 108.175 GiB/s, or **1.30×**. A 10× result against that M4 GPU row would require 832.4 GiB/s, far above the M6’s published bandwidth. This does not change the requested target; it establishes that the target cannot be reached by tuning this single-stream resident path on this memory configuration. Continue pursuing the strongest achievable end-to-end result and keep execution classes and hardware ceilings explicit.

## Reproduction

Release build on M6:

```sh
swift build -c release --product blake3-bench
```

Default compiler run:

```sh
./.build/release/blake3-bench --sizes 1g --iterations 6 \
  --metal-modes resident --file-modes none --cryptokit-modes none
```

Size-optimized compiler run:

```sh
BLAKE3_SWIFT_METAL_OPTIMIZATION_LEVEL=size \
  ./.build/release/blake3-bench --sizes 1g --iterations 6 \
  --metal-modes resident --file-modes none --cryptokit-modes none
```

The exact temporary sources used for the run are identified in `provenance.txt`. No package tests were run.
