# M6 safe Swift-input path

## Result

On the M6 Mac mini (`Mac18,5`, 16 GB, macOS 27.0, Swift 6.4), the public Swift-input GPU path now reuses a shared Metal buffer owned by `BLAKE3Metal.Context`. It copies each input into that buffer, submits the hash, and waits for completion. The context grows this allocation when it sees a larger GPU input and retains the largest allocation for its lifetime.

The final six-iteration 1 GiB run measured **33.63 GiB/s** for both `wrapped-auto` and `wrapped-gpu`; every output row was correct and the before/after thermal snapshots recorded no thermal or performance warning. Two earlier isolated repeats of the cached path measured 34.10 and 34.38 GiB/s (`wrapped-auto`). The final source-identical library had a clean M6 release build before the final benchmark.

Final run artifacts: [Markdown report](final-cached-public/m6-final-cached-public.md), [JSON](final-cached-public/m6-final-cached-public.json), [provenance](final-cached-public/provenance.txt), and thermal snapshots in the same folder.

| 1 GiB path | Repeat medians (GiB/s) | Correctness | Notes |
| --- | ---: | --- | --- |
| Fresh aligned allocation + copy, before reuse | 32.16, 32.47 | all rows correct | Two isolated repeats; source `00894e9d…`, benchmark `22146245…` |
| Reusable public `Context.hash(input:)` | 34.10, 34.38; final run 33.63 | all rows correct | Two isolated repeats plus final six-iteration run; source `a12df53d…`, benchmark `47f760ad…` in the final run |
| Caller-provided reusable staging buffer | 34.78, 34.69 | all rows correct | Two isolated repeats; confirms reusable staging is the faster upload shape |
| `MTLDevice.makeBuffer(bytes:length:options:)` copy control | 9.00 | all rows correct | Six iterations, highly variable and slower; retained as a negative control |

The public cached path improves the two-repeat uncached median by about **6%**. The final public-input result remains below the resident-buffer result because it includes the CPU copy. For context, the latest three-process M6 resident-buffer median is 108.175 GiB/s; it excludes that input copy and is a separate metric.

| Input size | Public `wrapped-auto` (GiB/s) | CPU parallel (GiB/s) | Correctness |
| --- | ---: | ---: | --- |
| 16 MiB | 17.17 | 13.96 | all rows correct |
| 64 MiB | 27.79 | 16.46 | all rows correct |
| 256 MiB | 32.61 | 17.23 | all rows correct |

The 16 MiB automatic-GPU threshold remains a reasonable measured crossover: a separate ten-iteration threshold run reported 22.69 GiB/s at 16 MiB versus 13.83 GiB/s CPU parallel. The 4 MiB and 8 MiB public automatic path stayed on CPU. The smaller-size measurements vary more than the 1 GiB resident case, so the threshold is supported as a practical crossover, not as a precisely located optimum.

Keyed digest, XOF, and keyed-XOF benchmark rows at 64 MiB all matched their CPU reference digests. The output XOF path now uses an owned Metal buffer and copies the completed result back into the returned Swift array.

## Apple API findings

- Apple requires `makeBuffer(bytesNoCopy:length:options:deallocator:)` to receive a page-aligned pointer and a length that produces a page-aligned region; the allocation must also lie within one VM region. The M6 Swift array pointers tested were 32 bytes past a 16 KiB page boundary. A 1 GiB page-window attempt failed the VM-region guard. The old 67.25 GiB/s direct wrapper result is therefore preserved as an **unsupported measurement**, not accepted performance.
- `makeBuffer(bytes:length:options:)` is Apple’s copying initializer. Its 1 GiB M6 control was much slower than writing to a reusable shared buffer, so the product path does not use it.
- Shared storage is appropriate here because the CPU writes the input and the GPU reads it on Apple silicon. Write-combined storage did not show a consistent win in the isolated cache-mode measurements and was removed from the product allocation path.
- Apple’s threadgroup and occupancy guidance informed the earlier sweeps in this repository. Those sweeps found no repeatable large gain from threadgroup hints or Metal 4 submission. Instruments, `xctrace`, and performance-counter sampling beyond GPU timestamps are unavailable on this remote host, so this run does not claim an occupancy or bandwidth diagnosis.

## Comparison with prior hardware and goal status

The strongest archived 1 GiB **resident GPU** row in the repository is 83.245 GiB/s on the earlier M4; the current M6 three-process median is 108.175 GiB/s, about 1.30×. The strongest archived 1 GiB **CPU parallel** row on M4 is 12.38 GiB/s; M6 measured about 17.3 GiB/s on that same CPU path, about 1.40×. These are different source revisions but matching benchmark paths. Neither comparison reaches the requested 10× target. The M4 end-to-end path and this M6 cached-input path have different allocation/reuse behavior, so their numbers are not presented as a same-path speedup. See [the M6 compiler-level A/B and bandwidth feasibility note](../20261010T-m6-compiler-optimization-level/README.md).

## Reproduction and provenance

Final M6 command:

```sh
swift build -c release --product blake3-bench
./.build/release/blake3-bench --sizes 1g --iterations 6 --metal-modes wrapped \
  --cryptokit-modes none --file-modes none --json-output m6-final.json
```

The exact source files built for the final run have matching local and M6 SHA-256 hashes:

| File | SHA-256 |
| --- | --- |
| `Sources/Blake3/BLAKE3Metal.swift` | `a12df53d7e9701f97d626877816e9993da41717926fcb73b6d433240fc8c2915` |
| `Sources/Blake3Benchmark/main.swift` | `47f760adb5caa53883271639377c6381970fe12c6e415f06838d8e3f0f1ca78e` |
| `Sources/Blake3/BLAKE3MetalKernel.swift` | `710b7182afc6615ff5b478593be273eab7934392af5436dfd41c0652e49ef9d1` |

Raw JSON, Markdown output, and thermal snapshots are kept in the sibling result folders. The isolated repeated runs use `run-isolated-overhead.sh`; their `environment.txt` records hardware, Swift version, settings, and repeat count. The release build completed with Command Line Tools linker search-path warnings, and no package tests were run.

Apple documentation: [no-copy buffer requirements](https://developer.apple.com/documentation/metal/mtldevice/makebuffer%28bytesnocopy%3Alength%3Aoptions%3Adeallocator%3A%29), [copying buffer initializer](https://developer.apple.com/documentation/metal/mtldevice/makebuffer%28bytes%3Alength%3Aoptions%3A%29), [storage modes](https://developer.apple.com/documentation/metal/setting-resource-storage-modes), and [write-combined cache mode](https://developer.apple.com/documentation/metal/mtlcpucachemode/writecombined).
