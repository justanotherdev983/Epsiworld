#include "framebuffer.h"

void framebuf_init() {
    g_framebuffer_info = { 
        .width = 1920,
        .height = 1080,
        .bytes_per_pixel = 32, // 8 for each channel, 8 * 4 = 32
        .stride = g_framebuffer_info.width * g_framebuffer_info.bytes_per_pixel,
        .red_mask_size = 8,

    };
}