# Page-aligned shared-buffer cache-mode sweep

M6 Mac mini, 1 GiB input, two measured iterations per configuration. All digest rows were correct and thermal snapshots show no warning.

| Copy workers | CPU cache mode | Observed GiB/s samples |
| ---: | --- | ---: |
| 1 | default | 27.32, 28.70 |
| 4 | default | 31.69, 32.17 |
| 8 | default | 32.09, 32.06 |
| 4 | write-combined | 32.25, 32.44 |
| 8 | write-combined | 32.28, 31.54 |

Four workers were near the plateau. Write-combined storage did not show a repeatable advantage over the default CPU cache mode, so production code uses default shared storage. This is an isolated helper benchmark; see [the final safe-input-path report](../20261010T-m6-safe-input-paths/README.md) for the accepted public API result.

Source SHA-256 values are in `environment.txt`: `BLAKE3Metal.swift` `f1e2399d…`, kernel `710b7182…`, and benchmark `709b693e…`. Raw JSON, Markdown reports, and thermal snapshots remain alongside this file.
