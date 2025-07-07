#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

const uint8_t *ak_apdu_received(const uint8_t *apdu,
                                uintptr_t apdu_len,
                                uintptr_t *out_len,
                                uintptr_t *out_status);

void ak_apdu_deactivated(void);

void free_rust_buffer(uint8_t *ptr, uintptr_t len);
