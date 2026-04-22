#ifndef CBLAKE3_BRIDGE_H
#define CBLAKE3_BRIDGE_H

#include <stddef.h>
#include <stdint.h>

#include "blake3.h"

void cblake3_hash(const void *input, size_t input_len, uint8_t out[BLAKE3_OUT_LEN]);
void cblake3_hash_xof(const void *input, size_t input_len, uint64_t seek, uint8_t *out, size_t out_len);
void cblake3_keyed_hash(const uint8_t key[BLAKE3_KEY_LEN], const void *input, size_t input_len,
                        uint8_t out[BLAKE3_OUT_LEN]);
void cblake3_keyed_hash_xof(const uint8_t key[BLAKE3_KEY_LEN], const void *input, size_t input_len,
                            uint64_t seek, uint8_t *out, size_t out_len);
void cblake3_derive_key_raw(const void *context, size_t context_len, const void *input, size_t input_len,
                            uint64_t seek, uint8_t *out, size_t out_len);
const char *cblake3_version(void);

#endif
