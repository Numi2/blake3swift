BLAKE3 Swift Metal autotune
metalDevice=Apple M4
metalLibrary=runtime-source
sizes=16.0 MiB, 64.0 MiB
iterations=3
gateCandidates=1.0 MiB, 4.0 MiB, 16.0 MiB, 64.0 MiB
modeCandidates=resident,staged,private-staged,e2e,private

| Category | Candidate | Size | Parameter | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| cpu-baseline | context-auto | 16.0 MiB | n/a | 3.13 | 3.12 | 3.16 | 3.16 | ok |
| minimum-gpu-bytes | resident-auto | 16.0 MiB | 1.0 MiB | 11.33 | 9.26 | 12.26 | 12.26 | ok |
| minimum-gpu-bytes | resident-auto | 16.0 MiB | 4.0 MiB | 25.25 | 24.91 | 25.61 | 25.61 | ok |
| minimum-gpu-bytes | resident-auto | 16.0 MiB | 16.0 MiB | 19.81 | 11.62 | 24.99 | 24.99 | ok |
| minimum-gpu-bytes | resident-auto | 16.0 MiB | 64.0 MiB | 3.00 | 2.98 | 3.22 | 3.22 | ok |
| metal-mode | resident-gpu | 16.0 MiB | n/a | 22.81 | 21.49 | 25.07 | 25.07 | ok |
| metal-mode | staged-gpu | 16.0 MiB | n/a | 12.44 | 7.80 | 14.62 | 14.62 | ok |
| metal-mode | private-staged-gpu | 16.0 MiB | n/a | 8.16 | 4.49 | 9.42 | 9.42 | ok |
| metal-mode | e2e-gpu | 16.0 MiB | n/a | 7.58 | 7.48 | 7.61 | 7.61 | ok |
| metal-mode | private-gpu | 16.0 MiB | n/a | 25.97 | 5.35 | 26.31 | 26.31 | ok |
| cpu-baseline | context-auto | 64.0 MiB | n/a | 3.30 | 3.27 | 3.58 | 3.58 | ok |
| minimum-gpu-bytes | resident-auto | 64.0 MiB | 1.0 MiB | 12.56 | 6.98 | 24.08 | 24.08 | ok |
| minimum-gpu-bytes | resident-auto | 64.0 MiB | 4.0 MiB | 23.15 | 8.97 | 26.12 | 26.12 | ok |
| minimum-gpu-bytes | resident-auto | 64.0 MiB | 16.0 MiB | 27.72 | 13.03 | 30.55 | 30.55 | ok |
| minimum-gpu-bytes | resident-auto | 64.0 MiB | 64.0 MiB | 29.25 | 28.08 | 30.34 | 30.34 | ok |
| metal-mode | resident-gpu | 64.0 MiB | n/a | 27.79 | 23.93 | 27.81 | 27.81 | ok |
| metal-mode | staged-gpu | 64.0 MiB | n/a | 10.54 | 9.72 | 13.70 | 13.70 | ok |
| metal-mode | private-staged-gpu | 64.0 MiB | n/a | 7.22 | 7.18 | 8.48 | 8.48 | ok |
| metal-mode | e2e-gpu | 64.0 MiB | n/a | 6.46 | 6.33 | 6.94 | 6.94 | ok |
| metal-mode | private-gpu | 64.0 MiB | n/a | 30.77 | 26.61 | 35.59 | 35.59 | ok |

| Recommendation | Value | Score GiB/s | Rationale |
| --- | --- | ---: | --- |
| minimum_gpu_bytes | 4.0 MiB | 24.18 | Highest geometric mean resident-auto throughput across autotune sizes. |
| mode | private-gpu | 28.27 | Highest geometric mean forced-GPU throughput across autotune sizes; compare timing class before publishing. |
autotuneJsonOutput=benchmarks/results/20260417T155523Z-autotune-default/autotune-metal.json
