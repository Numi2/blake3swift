#include "cblake3_bridge.h"

void cblake3_hash(const void *input, size_t input_len, uint8_t out[BLAKE3_OUT_LEN]) {
  blake3_hasher hasher;
  blake3_hasher_init(&hasher);
  blake3_hasher_update(&hasher, input, input_len);
  blake3_hasher_finalize(&hasher, out, BLAKE3_OUT_LEN);
}

const char *cblake3_version(void) {
  return blake3_version();
}
