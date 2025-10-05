#pragma once

#include <stdint.h>

enum class framebuffer_t {
    FRAMEBUF_TYPE_RGB,
    FRAMEBUF_TYPE_UNKNOWN,

    // We can add other later.
};

struct framebuffer_info_t {
    uintptr_t phys_start_addr;

    uint32_t width;
    uint32_t height;
    uint32_t stride; // will prob be width * bytes_per_pixel
    uint8_t bytes_per_pixel;

    uint8_t   red_mask_size;
    uint8_t   red_mask_shift;
    uint8_t   green_mask_size;
    uint8_t   green_mask_shift;
    uint8_t   blue_mask_size;
    uint8_t   blue_mask_shift;
    uint8_t   reserved_mask_size;   // Often used for alpha channel
    uint8_t   reserved_mask_shift;
    
    framebuffer_t type;
};

extern framebuffer_info_t g_framebuffer_info;

void framebuf_init();
