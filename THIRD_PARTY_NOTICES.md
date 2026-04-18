# Third-Party Notices

This repository contains a small amount of upstream BLAKE3 material for correctness checks and benchmark comparison. These materials are not covered by the proprietary BLAKE3Swift license in `LICENSE.md`; they remain under the upstream BLAKE3 license terms.

## Official BLAKE3 C Implementation

- Upstream project: `BLAKE3-team/BLAKE3`
- Upstream URL: https://github.com/BLAKE3-team/BLAKE3
- Upstream release: `1.8.4`
- Upstream tag commit: `b97a24f8754819755ef78d8016c0391c65c943c5`
- Upstream license options: `CC0-1.0 OR Apache-2.0 OR Apache-2.0 WITH LLVM-exception`
- Upstream license text links:
  - https://github.com/BLAKE3-team/BLAKE3/blob/1.8.4/LICENSE_CC0
  - https://github.com/BLAKE3-team/BLAKE3/blob/1.8.4/LICENSE_A2
  - https://github.com/BLAKE3-team/BLAKE3/blob/1.8.4/LICENSE_A2LLVM

Vendored upstream files:

- `Sources/CBLAKE3/blake3.c`
- `Sources/CBLAKE3/blake3_dispatch.c`
- `Sources/CBLAKE3/blake3_impl.h`
- `Sources/CBLAKE3/blake3_neon.inc`
- `Sources/CBLAKE3/blake3_neon_wrapper.c`
- `Sources/CBLAKE3/blake3_portable.c`
- `Sources/CBLAKE3/include/blake3.h`

Local bridge files:

- `Sources/CBLAKE3/cblake3_bridge.c`
- `Sources/CBLAKE3/include/cblake3_bridge.h`

The `CBLAKE3` target is used by `Blake3BenchmarkSupport` and the `blake3-bench` executable to compare against the official C implementation. The public `Blake3` library product does not depend on `CBLAKE3`.

## Official BLAKE3 Test Vectors

- Upstream project: `BLAKE3-team/BLAKE3`
- Upstream path: `test_vectors/test_vectors.json`
- Upstream release: `1.8.4`
- Upstream tag commit: `b97a24f8754819755ef78d8016c0391c65c943c5`
- Upstream license options: `CC0-1.0 OR Apache-2.0 OR Apache-2.0 WITH LLVM-exception`

Vendored file:

- `Tests/Blake3Tests/Resources/test_vectors.json`

The test vectors are used only by the test target to verify BLAKE3Swift correctness against official expected output.
