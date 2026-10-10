# M6 aligned `uint4` input-load experiment

## Result

I tested whether reading each 64-byte BLAKE3 block through four aligned `uint4` loads would improve the full-chunk Metal kernel. The candidate checked the input address alignment before selecting that kernel and kept the generic path for private or unaligned buffers.

The candidate built and passed the benchmark digest checks, but its throughput was indistinguishable from the parent revision:

| Source | Per-process 1 GiB `resident-gpu` medians (GiB/s) | Median across processes |
| --- | --- | ---: |
| Parent revision | 108.748, 108.511, 108.406 | 108.511 |
| Aligned `uint4` candidate | 107.409, 108.617, 108.524 | 108.524 |

The difference is **+0.012%**. Candidate process medians varied by 1.21 GiB/s, so this is no demonstrated improvement. Each process used the same release benchmark source, a pre-created resident shared `MTLBuffer`, 1 GiB input, six timed iterations, and the Apple M6 Mac mini. All six JSON reports validated; every benchmark row reported a correct digest. Thermal snapshots recorded no warning.

The candidate is not retained in the library. The exact patch is `experiment.patch`; the candidate only measured the shared resident path. Its guard also sent private buffers to the generic full-chunk kernel, and private mode was not part of this comparison.

## Apple documentation and profiling access

Apple defines `MTLDataType.uint4` as four 32-bit unsigned values. That defines the vector shape, but doesn’t promise faster loads; the M6 measurements above did not show a gain. See [Apple’s `MTLDataType.uint4` documentation](https://developer.apple.com/documentation/metal/mtldatatype/uint4).

Apple recommends using GPU bandwidth and occupancy counters to identify and correlate bottlenecks. The [bandwidth guide](https://developer.apple.com/documentation/xcode/measuring-the-gpus-use-of-memory-bandwidth) and [occupancy guide](https://developer.apple.com/documentation/xcode/finding-your-metal-apps-gpu-occupancy) describe those measurements. Apple’s [Metal counter API](https://developer.apple.com/documentation/metal/gpu-counters-and-counter-sample-buffers) exposes supported counter sets through `MTLDevice.counterSets` and samples them into counter buffers.

The M6 probe in `counter-capabilities.txt` found stage-boundary sampling support, but the device exposed only the `timestamp` set with `GPUTimestamp`; draw- and blit-boundary sampling were unavailable. The remote machine has Command Line Tools but no `xctrace` or Instruments executable (`instrumentation-availability.txt`). This run therefore establishes end-to-end throughput and correctness, but does not diagnose bandwidth or occupancy as the limiting factor.

Apple lists 153 GB/s memory bandwidth for the M6 Mac mini’s 16 GB configuration in [its specifications](https://www.apple.com/mac-mini/specs/). A one-read streaming ceiling is about 142.5 GiB/s, while 10× the archived M4 1 GiB resident-GPU result of 83.245 GiB/s would require about 832.4 GiB/s. This makes the 10× target unattainable for this single-stream resident metric on this hardware; it is a bandwidth ceiling estimate, not a diagnosis of the current kernel’s bottleneck.

## Reproduction

Release build on the M6:

```sh
swift build -c release
```

Each parent and candidate process used:

```sh
./.build/release/blake3-bench --sizes 1g --iterations 6 \
  --metal-modes resident --file-modes none --cryptokit-modes none \
  --json-output <report.json>
```

Raw Markdown and JSON reports, validation output, thermal snapshots, source hashes, counter probe, and the exact candidate patch are retained beside this file. No package tests were run.
