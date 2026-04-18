BLAKE3 Swift Metal autotune
metalDevice=Apple M4
metalLibrary=runtime-source
sizes=16.0 MiB, 64.0 MiB
iterations=3
gateCandidates=1.0 MiB, 4.0 MiB, 16.0 MiB, 64.0 MiB
modeCandidates=resident,staged,private-staged,e2e,private
tileCandidates=8.0 MiB, 16.0 MiB, 32.0 MiB, 64.0 MiB

| Category | Candidate | Size | Parameter | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| cpu-baseline | context-auto | 16.0 MiB | n/a | 9.11 | 9.01 | 9.16 | 9.16 | ok |
| minimum-gpu-bytes | resident-auto | 16.0 MiB | 1.0 MiB | 8.21 | 8.15 | 8.86 | 8.86 | ok |
| minimum-gpu-bytes | resident-auto | 16.0 MiB | 4.0 MiB | 20.73 | 20.11 | 22.13 | 22.13 | ok |
| minimum-gpu-bytes | resident-auto | 16.0 MiB | 16.0 MiB | 18.98 | 11.97 | 20.58 | 20.58 | ok |
| minimum-gpu-bytes | resident-auto | 16.0 MiB | 64.0 MiB | 8.69 | 7.66 | 9.14 | 9.14 | ok |
| metal-mode | resident-gpu | 16.0 MiB | n/a | 19.87 | 19.63 | 20.84 | 20.84 | ok |
| metal-mode | staged-gpu | 16.0 MiB | n/a | 9.25 | 8.23 | 9.35 | 9.35 | ok |
| metal-mode | private-staged-gpu | 16.0 MiB | n/a | 8.32 | 7.71 | 9.22 | 9.22 | ok |
| metal-mode | e2e-gpu | 16.0 MiB | n/a | 7.12 | 6.88 | 7.45 | 7.45 | ok |
| metal-mode | private-gpu | 16.0 MiB | n/a | 21.72 | 20.18 | 22.20 | 22.20 | ok |
| metal-file-tile | metal-tiled-mmap | 16.0 MiB | 8.0 MiB | 3.61 | 1.79 | 3.94 | 3.94 | ok |
| metal-file-tile | metal-tiled-mmap | 16.0 MiB | 16.0 MiB | 4.56 | 1.86 | 4.58 | 4.58 | ok |
| metal-file-tile | metal-tiled-mmap | 16.0 MiB | 32.0 MiB | 4.51 | 1.65 | 4.65 | 4.65 | ok |
| metal-file-tile | metal-tiled-mmap | 16.0 MiB | 64.0 MiB | 4.02 | 1.87 | 4.43 | 4.43 | ok |
| cpu-baseline | context-auto | 64.0 MiB | n/a | 10.16 | 9.00 | 10.21 | 10.21 | ok |
| minimum-gpu-bytes | resident-auto | 64.0 MiB | 1.0 MiB | 22.60 | 19.38 | 23.24 | 23.24 | ok |
| minimum-gpu-bytes | resident-auto | 64.0 MiB | 4.0 MiB | 23.18 | 19.48 | 27.20 | 27.20 | ok |
| minimum-gpu-bytes | resident-auto | 64.0 MiB | 16.0 MiB | 22.94 | 9.10 | 27.75 | 27.75 | ok |
| minimum-gpu-bytes | resident-auto | 64.0 MiB | 64.0 MiB | 22.65 | 12.32 | 27.09 | 27.09 | ok |
| metal-mode | resident-gpu | 64.0 MiB | n/a | 19.77 | 13.27 | 26.86 | 26.86 | ok |
| metal-mode | staged-gpu | 64.0 MiB | n/a | 10.99 | 8.12 | 11.16 | 11.16 | ok |
| metal-mode | private-staged-gpu | 64.0 MiB | n/a | 5.48 | 5.26 | 6.30 | 6.30 | ok |
| metal-mode | e2e-gpu | 64.0 MiB | n/a | 6.86 | 6.86 | 7.32 | 7.32 | ok |
| metal-mode | private-gpu | 64.0 MiB | n/a | 16.75 | 7.20 | 25.14 | 25.14 | ok |
| metal-file-tile | metal-tiled-mmap | 64.0 MiB | 8.0 MiB | 2.19 | 2.13 | 2.74 | 2.74 | ok |
| metal-file-tile | metal-tiled-mmap | 64.0 MiB | 16.0 MiB | 2.39 | 2.12 | 2.72 | 2.72 | ok |
| metal-file-tile | metal-tiled-mmap | 64.0 MiB | 32.0 MiB | 3.36 | 2.65 | 3.44 | 3.44 | ok |
| metal-file-tile | metal-tiled-mmap | 64.0 MiB | 64.0 MiB | 3.72 | 3.66 | 3.76 | 3.76 | ok |

| Recommendation | Value | Score GiB/s | Rationale |
| --- | --- | ---: | --- |
| minimum_gpu_bytes | 4.0 MiB | 21.92 | Highest geometric mean resident-auto throughput across autotune sizes. |
| mode | resident-gpu | 19.82 | Highest geometric mean forced-GPU throughput across autotune sizes; compare timing class before publishing. |
| tile_bytes | 32.0 MiB | 3.90 | Highest geometric mean tiled Metal file throughput across autotune sizes. |
autotuneJsonOutput=benchmarks/results/20260418T192002Z-full-suite/autotune/autotune-metal.json
