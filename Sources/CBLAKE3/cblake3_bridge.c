#include "cblake3_bridge.h"

void cblake3_hash(const void *input, size_t input_len, uint8_t out[BLAKE3_OUT_LEN]) {
  blake3_hasher hasher;
  blake3_hasher_init(&hasher);
  blake3_hasher_update(&hasher, input, input_len);
  blake3_hasher_finalize(&hasher, out, BLAKE3_OUT_LEN);
}

void cblake3_hash_xof(const void *input, size_t input_len, uint64_t seek, uint8_t *out, size_t out_len) {
  blake3_hasher hasher;
  blake3_hasher_init(&hasher);
  blake3_hasher_update(&hasher, input, input_len);
  blake3_hasher_finalize_seek(&hasher, seek, out, out_len);
}

void cblake3_keyed_hash(const uint8_t key[BLAKE3_KEY_LEN], const void *input, size_t input_len,
                        uint8_t out[BLAKE3_OUT_LEN]) {
  blake3_hasher hasher;
  blake3_hasher_init_keyed(&hasher, key);
  blake3_hasher_update(&hasher, input, input_len);
  blake3_hasher_finalize(&hasher, out, BLAKE3_OUT_LEN);
}

void cblake3_keyed_hash_xof(const uint8_t key[BLAKE3_KEY_LEN], const void *input, size_t input_len,
                            uint64_t seek, uint8_t *out, size_t out_len) {
  blake3_hasher hasher;
  blake3_hasher_init_keyed(&hasher, key);
  blake3_hasher_update(&hasher, input, input_len);
  blake3_hasher_finalize_seek(&hasher, seek, out, out_len);
}

void cblake3_derive_key_raw(const void *context, size_t context_len, const void *input, size_t input_len,
                            uint64_t seek, uint8_t *out, size_t out_len) {
  blake3_hasher hasher;
  blake3_hasher_init_derive_key_raw(&hasher, context, context_len);
  blake3_hasher_update(&hasher, input, input_len);
  blake3_hasher_finalize_seek(&hasher, seek, out, out_len);
}

const char *cblake3_version(void) {
  return blake3_version();
}
