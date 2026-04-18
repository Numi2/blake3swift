# CBLAKE3 Provenance

This target vendors files from the official BLAKE3 C implementation for benchmark comparison and differential correctness checks.

- Upstream project: `BLAKE3-team/BLAKE3`
- Upstream URL: https://github.com/BLAKE3-team/BLAKE3
- Upstream release: `1.8.4`
- Upstream tag commit: `b97a24f8754819755ef78d8016c0391c65c943c5`
- Upstream license options: `CC0-1.0 OR Apache-2.0 OR Apache-2.0 WITH LLVM-exception`
- Upstream license text links:
  - https://github.com/BLAKE3-team/BLAKE3/blob/1.8.4/LICENSE_CC0
  - https://github.com/BLAKE3-team/BLAKE3/blob/1.8.4/LICENSE_A2
  - https://github.com/BLAKE3-team/BLAKE3/blob/1.8.4/LICENSE_A2LLVM

The local `cblake3_bridge.c` and `include/cblake3_bridge.h` files expose a narrow one-shot bridge for benchmark support. The public `Blake3` library product does not depend on this target.
