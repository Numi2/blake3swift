# Page-aligned copy by input size

M6 Mac mini; two measured iterations per worker/cache configuration at 16, 64, and 256 MiB. All digest rows were correct and thermal snapshots show no warning.

| Input | 1 worker, default | 4 workers, default | 4 workers, write-combined |
| --- | ---: | ---: | ---: |
| 16 MiB | 16.51, 17.10 | 17.49, 17.83 | 17.87, 17.68 |
| 64 MiB | 19.14, 19.93 | 19.97, 20.81 | 21.43, 20.28 |
| 256 MiB | 23.16, 25.13 | 25.08, 25.48 | 25.18, 24.71 |

Four-way copy helped modestly, with no consistent write-combined win. These runs measured an allocation-and-copy helper, not the final reusable public path; final results are in [the safe-input-path report](../20261010T-m6-safe-input-paths/README.md).

Source SHA-256 values are in `environment.txt`: `BLAKE3Metal.swift` `f1e2399d…`, kernel `710b7182…`, and benchmark `709b693e…`. Raw JSON, Markdown reports, and thermal snapshots remain alongside this file.
