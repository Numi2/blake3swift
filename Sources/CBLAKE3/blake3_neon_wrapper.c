/*
 * Vendored from BLAKE3-team/BLAKE3 release 1.8.4
 * tag commit b97a24f8754819755ef78d8016c0391c65c943c5.
 * Upstream license: CC0-1.0 OR Apache-2.0 OR Apache-2.0 WITH LLVM-exception.
 * See THIRD_PARTY_NOTICES.md and Sources/CBLAKE3/README.md.
 */

#if defined(__aarch64__) || defined(_M_ARM64) || defined(_M_ARM64EC)
#include "blake3_neon.inc"
#endif
