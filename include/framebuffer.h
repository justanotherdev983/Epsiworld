#pragma once

#include <stdint.h>

enum class framebuffer_t {
    FRAMEBUF_TYPE_RGB,
    FRAMEBUF_TYPE_UNKNOWN,
};

struct framebuffer_info_t {
    uintptr_t phys_start_addr;

    uint32_t width;
    uint32_t height;
    uint32_t stride; // bytes per scanline (may not equal width * bpp)
    uint8_t bytes_per_pixel;

    uint8_t   red_mask_size;
    uint8_t   red_mask_shift;
    uint8_t   green_mask_size;
    uint8_t   green_mask_shift;
    uint8_t   blue_mask_size;
    uint8_t   blue_mask_shift;
    uint8_t   reserved_mask_size;
    uint8_t   reserved_mask_shift;
    
    framebuffer_t type;
};

extern framebuffer_info_t g_framebuffer_info;

// Initialize framebuffer from VBE mode info
void framebuf_init(void* vbe_mode_info_ptr);

// Drawing functions
void framebuf_put_pixel(uint32_t x, uint32_t y, uint32_t color);
uint32_t framebuf_make_color(uint8_t r, uint8_t g, uint8_t b);
void framebuf_clear(uint32_t color);
void framebuf_draw_rect(uint32_t x, uint32_t y, uint32_t width, uint32_t height, uint32_t color);