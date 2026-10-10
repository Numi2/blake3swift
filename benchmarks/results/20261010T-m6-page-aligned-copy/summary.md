# M6 page-aligned input experiment

Three repeats per mode, 1 GiB input, four iterations per repeat, runtime Metal source. Both modes passed digest comparison. The page-aligned route times allocation, a full input copy, no-copy buffer wrapping, and GPU hashing together.

| Input route | Wrapped GPU median across repeats (GiB/s) | Repeat medians (GiB/s) |
| --- | ---: | --- |
| Existing Swift array, direct no-copy wrapper | 58.57 | 58.73, 53.03, 58.57 |
| Page-aligned allocation + copy + no-copy wrapper | 29.73 | 25.45, 29.73, 29.74 |

Page alignment alone does not provide a performance win when the route must first copy the input. It cuts end-to-end throughput by roughly half in these runs. This does not isolate the cost of address alignment from the copy, and it does not establish that the existing unaligned Swift allocation satisfies Apple’s documented `bytesNoCopy` contract.

The opt-in benchmark route is controlled by `BLAKE3_SWIFT_METAL_PAGE_ALIGNED_WRAPPED_INPUT=1`. It is off by default. Raw JSON, text reports, environment, and thermal snapshots are retained in `normal/` and `page-aligned-copy/`.
