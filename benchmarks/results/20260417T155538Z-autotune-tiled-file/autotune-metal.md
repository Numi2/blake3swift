BLAKE3 Swift Metal autotune
metalDevice=Apple M4
metalLibrary=runtime-source
sizes=512.0 MiB, 1.0 GiB
iterations=2
gateCandidates=16.0 MiB
modeCandidates=resident
tileCandidates=8.0 MiB, 16.0 MiB, 32.0 MiB, 64.0 MiB

| Category | Candidate | Size | Parameter | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| cpu-baseline | context-auto | 512.0 MiB | n/a | 3.81 | 3.78 | 3.84 | 3.84 | ok |
| minimum-gpu-bytes | resident-auto | 512.0 MiB | 16.0 MiB | 48.98 | 41.81 | 56.15 | 56.15 | ok |
| metal-mode | resident-gpu | 512.0 MiB | n/a | 62.71 | 58.26 | 67.17 | 67.17 | ok |
| metal-file-tile | metal-tiled-mmap | 512.0 MiB | 8.0 MiB | 3.08 | 3.06 | 3.09 | 3.09 | ok |
| metal-file-tile | metal-tiled-mmap | 512.0 MiB | 16.0 MiB | 3.62 | 3.61 | 3.63 | 3.63 | ok |
| metal-file-tile | metal-tiled-mmap | 512.0 MiB | 32.0 MiB | 3.72 | 3.67 | 3.77 | 3.77 | ok |
| metal-file-tile | metal-tiled-mmap | 512.0 MiB | 64.0 MiB | 3.84 | 3.82 | 3.85 | 3.85 | ok |
| cpu-baseline | context-auto | 1.0 GiB | n/a | 3.61 | 3.48 | 3.73 | 3.73 | ok |
| minimum-gpu-bytes | resident-auto | 1.0 GiB | 16.0 MiB | 58.77 | 54.86 | 62.69 | 62.69 | ok |
| metal-mode | resident-gpu | 1.0 GiB | n/a | 62.52 | 62.24 | 62.81 | 62.81 | ok |
| metal-file-tile | metal-tiled-mmap | 1.0 GiB | 8.0 MiB | 3.20 | 3.20 | 3.20 | 3.20 | ok |
| metal-file-tile | metal-tiled-mmap | 1.0 GiB | 16.0 MiB | 3.71 | 3.53 | 3.88 | 3.88 | ok |
| metal-file-tile | metal-tiled-mmap | 1.0 GiB | 32.0 MiB | 4.00 | 3.97 | 4.02 | 4.02 | ok |
| metal-file-tile | metal-tiled-mmap | 1.0 GiB | 64.0 MiB | 4.33 | 4.08 | 4.57 | 4.57 | ok |

| Recommendation | Value | Score GiB/s | Rationale |
| --- | --- | ---: | --- |
| minimum_gpu_bytes | 16.0 MiB | 53.65 | Highest geometric mean resident-auto throughput across autotune sizes. |
| mode | resident-gpu | 62.62 | Highest geometric mean forced-GPU throughput across autotune sizes; compare timing class before publishing. |
| tile_bytes | 64.0 MiB | 4.07 | Highest geometric mean tiled Metal file throughput across autotune sizes. |
autotuneJsonOutput=benchmarks/results/20260417T155538Z-autotune-tiled-file/autotune-metal.json
