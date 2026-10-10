# M6 Apple Metal performance research

## Scope

This note combines the M6 isolated-input-path and wrapped-tile benchmark records with the relevant Apple Metal documentation. These are software throughput measurements on one Mac18,5 (Apple M6, macOS 27.0, Swift 6.4); they are not a cross-device 10x result.

## Measured results

At 1 GiB, the median across the three isolated repeats was 107.39 GiB/s for a pre-created resident shared `MTLBuffer` and 63.58 GiB/s for a no-copy wrapper over Swift bytes. This is about a 1.69x difference. The wrapped result includes creation of the wrapper and hash completion; resident mode excludes buffer creation and population.

The 128-, 256-, and 512-chunk wrapped tile variants cluster around 58–59 GiB/s across the two recorded repeats. The 1024-chunk variant was slower (56.59 and 58.23 GiB/s). The in-place 128-chunk variant was also around 58–59 GiB/s. All recorded rows passed digest comparison. No tile setting is a demonstrated improvement over the current configuration.

Reports and environment records are in this directory; the isolated input comparison is in [the adjacent input-path record](../20261010T-m6-isolated-input-path/summary.md).

## Apple documentation and implications

- [Metal `makeBuffer(bytesNoCopy:length:options:deallocator:)`](https://developer.apple.com/documentation/metal/mtldevice/makebuffer%28bytesnocopy%3Alength%3Aoptions%3Adeallocator%3A%29) specifies a page-aligned starting pointer, a page-aligned covered region, and memory contained in one virtual-memory region. A live M6 probe using 4 MiB, 256 MiB, and 1 GiB Swift arrays observed an address 32 bytes past a page boundary; Metal accepted each wrapper and `buffer.contents()` equaled the original pointer. This runtime observation does not establish that the usage meets the API’s documented alignment contract on other systems or OS versions.
- [Choosing a resource storage mode for Apple GPUs](https://developer.apple.com/documentation/metal/choosing-a-resource-storage-mode-for-apple-gpus) describes shared resources as CPU/GPU accessible system memory, and private resources as GPU-only resources. It recommends shared storage when data is populated on the CPU and accessed frequently by the GPU. This supports the current shared mode for Swift-owned inputs. It does not explain the measured 1.69x gap between a wrapped allocation and a pre-created Metal buffer.
- [Measuring the GPU’s use of memory bandwidth](https://developer.apple.com/documentation/xcode/measuring-the-gpus-use-of-memory-bandwidth) recommends Instruments and the Metal debugger Performance timeline bandwidth counters to check actual GPU reads and writes.
- [Apple GPU performance counters](https://developer.apple.com/documentation/xcode/analyzing-apple-gpu-performance-using-counter-statistics) expose per-pass measurements, including memory bandwidth and utilization/limiter counters. These would distinguish a memory bottleneck from shader execution limits. Xcode, Instruments, and `xctrace` are not installed on the M6 host, so the current throughput runs cannot make that distinction.
- [`MTLComputePipelineState.threadExecutionWidth`](https://developer.apple.com/documentation/metal/mtlcomputepipelinestate/threadexecutionwidth) recommends threadgroup sizes that are multiples of the pipeline’s execution width. The implementation already derives normal dispatch width from each pipeline’s `threadExecutionWidth`; fused tile configurations also reject widths that are not multiples of it. This makes speculative threadgroup changes a poor next step without GPU counters.

## Next experiment

First, capture a supported GPU performance trace on the M6 host, or install/use a matching Apple profiling tool there. Inspect the hash and tree-reduction passes for measured bandwidth and limiter counters. Separately benchmark a documented page-aligned input allocation against the existing Swift-array wrapper, including the allocation/copy cost in end-to-end timing; only then decide whether to change the public input path. Keep the resident-buffer result separate because its input allocation and population are outside the timed interval.
