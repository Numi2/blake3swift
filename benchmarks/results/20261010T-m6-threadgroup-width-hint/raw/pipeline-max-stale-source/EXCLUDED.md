# Excluded pipeline maximum sweep

These runs were intended to compare `MTLComputePipelineDescriptor.maxTotalThreadsPerThreadgroup`, but the M6 checkout still had the old source hashes (`710b7182...` for `BLAKE3MetalKernel.swift` and `d06ffdc2...` for the benchmark). The local experiment source had different hashes (`39cded7a...` and `012ea9da...`). The M6 build therefore never read the environment variable or applied the thread limit.

All captured JSON rows were correct, but the run files represent default-pipeline repeat measurements only. They are preserved for traceability and excluded from the maximum-threads comparison. The verified rerun is in `../pipeline-max/`.
