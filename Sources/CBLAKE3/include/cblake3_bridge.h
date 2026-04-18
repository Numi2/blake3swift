#ifndef CBLAKE3_BRIDGE_H
#define CBLAKE3_BRIDGE_H

#include <stddef.h>
#include <stdint.h>

#include "blake3.h"

void cblake3_hash(const void *input, size_t input_len, uint8_t out[BLAKE3_OUT_LEN]);
const char *cblake3_version(void);

#endif
