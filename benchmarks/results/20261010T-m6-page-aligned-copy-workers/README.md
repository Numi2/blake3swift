# Page-aligned copy worker sweep

M6 Mac mini, 1 GiB input, two measured iterations per worker count. The benchmark allocated a page-aligned shared `MTLBuffer`, copied Swift input into it, and timed hash completion. Every digest row was correct; thermal snapshots show no warning.

| Copy workers | Observed GiB/s samples |
| ---: | ---: |
| 1 | 26.28, 29.60 |
| 2 | 31.63, 30.91 |
| 4 | 32.35, 32.41 |
| 8 | 32.26, 32.25 |
| 12 | 32.02, 32.31 |

Four workers reached the plateau; 8 and 12 did not improve throughput. The product path later moved to a reusable `MTLBuffer`, so this is a copy-allocation study rather than the accepted final-path result.

Source SHA-256 values are in `environment.txt`: `BLAKE3Metal.swift` `f1e2399d…`, kernel `710b7182…`, and benchmark `e987c971…`. Raw JSON, Markdown reports, and thermal snapshots remain alongside this file.
