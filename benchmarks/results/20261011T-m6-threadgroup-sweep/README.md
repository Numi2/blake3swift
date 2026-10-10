# Apple M6 batch threadgroup sweep

This experiment varies the target number of SIMD groups per threadgroup in the Metal batch aggregate path. Apple advises aligning the threadgroup size to `threadExecutionWidth` and respecting each pipeline's own `maxTotalThreadsPerThreadgroup`; the existing dispatch helper already enforces both ([threadgroup and grid sizing](https://developer.apple.com/documentation/metal/calculating-threadgroup-and-grid-sizes), [`threadExecutionWidth`](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate/threadexecutionwidth)). The sweep tests target counts of 4, 8, 16, and 32 groups. The pipeline limit can clamp a requested count.

## Method

- Device: Apple M6 Mac mini (Mac18,5), 16 GB, macOS 27.0, Swift 6.4.
- Workloads: 16 MiB and 64 MiB resident buffers split into 64-byte messages; the plan and resident input were prepared outside the timed call.
- Each setting ran in two five-sample release processes. The second round reversed the candidate order.
- A follow-up used 15 samples per process for 16 MiB, alternating 8/4 then 4/8 groups. The benchmark includes one untimed warm-up before those samples.
- All JSON reports passed `blake3-bench --validate-json`; every row returned the expected digest. Snapshots recorded no thermal or performance warning. Memory free percentage was 40% around the first sweep.
- The runtime source and release binary hashes are retained in `provenance.txt` and `provenance-warm.txt`. `dispatch-override.patch` records the temporary M6-only sweep hook applied to the source at commit `848f38d`; the M6 scratch source was restored to that published source and rebuilt after collection.

## Results

Throughput is GiB/s. The 16 MiB workload has 262,144 messages; the 64 MiB workload has 1,048,576.

| SIMD groups | 16 MiB medians, runs 1 / 2 | 16 MiB minima, runs 1 / 2 | 64 MiB medians, runs 1 / 2 |
| ---: | ---: | ---: | ---: |
| 4 | 41.35 / 41.80 | 23.93 / 23.52 | 36.80 / 25.31 |
| 8 (existing default below 1M threads) | 21.60 / 23.24 | 20.68 / 22.76 | 39.61 / 28.96 |
| 16 | 23.00 / 22.03 | 22.54 / 19.59 | 24.86 / 29.40 |
| 32 | 40.50 / 22.44 | 23.38 / 20.26 | 29.02 / 34.43 |

The longer 16 MiB runs did not resolve the spread:

| SIMD groups | 15-sample median, run 1 / 2 | Minimum, run 1 / 2 |
| ---: | ---: | ---: |
| 4 | 40.86 / 23.25 | 22.89 / 20.44 |
| 8 | 23.46 / 38.76 | 20.34 / 22.68 |

Within-run sample speeds switched between roughly 20–25 and 38–44 GiB/s for both settings. The direction of the median change reversed between repeat processes, and the slow minima overlapped. The data does not establish that a threadgroup count caused the faster intervals. The dispatch default remains unchanged.

## Limits and next comparison

The M6 runtime exposes only GPU timestamps in the available counter probe; Xcode, Instruments, and `xctrace` are unavailable on that host. Apple recommends correlating occupancy with other GPU measurements, so this timing sweep cannot identify why the rates switch ([GPU occupancy guidance](https://developer.apple.com/documentation/xcode/finding-your-metal-apps-gpu-occupancy), [GPU bandwidth guidance](https://developer.apple.com/documentation/xcode/measuring-the-gpus-use-of-memory-bandwidth)).

The archived M4 reports do not contain this exact public aggregate workload. The M4 was also running a sustained multiworker Python job during the follow-up, so this experiment adds no cross-hardware result. A matched M4 run is still required before claiming a 10× gain over earlier hardware.
