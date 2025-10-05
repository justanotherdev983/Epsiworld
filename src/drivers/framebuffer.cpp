#include "framebuffer.h"

// VBE Mode Info Block structure (matches BIOS layout)
struct __attribute__((packed)) vbe_mode_info_t {
    uint16_t attributes;
    uint8_t  window_a;
    uint8_t  window_b;
    uint16_t granularity;
    uint16_t window_size;
    uint16_t segment_a;
    uint16_t segment_b;
    uint32_t win_func_ptr;
    uint16_t pitch;             // bytes per scanline
    uint16_t width;
    uint16_t height;
    uint8_t  w_char;
    uint8_t  y_char;
    uint8_t  planes;
    uint8_t  bpp;               // bits per pixel
    uint8_t  banks;
    uint8_t  memory_model;
    uint8_t  bank_size;
    uint8_t  image_pages;
    uint8_t  reserved0;
    
    // Direct color fields
    uint8_t  red_mask;
    uint8_t  red_position;
    uint8_t  green_mask;
    uint8_t  green_position;
    uint8_t  blue_mask;
    uint8_t  blue_position;
    uint8_t  reserved_mask;
    uint8_t  reserved_position;
    uint8_t  direct_color_attributes;
    
    uint32_t framebuffer;       // Physical address of linear framebuffer
    uint32_t off_screen_mem_off;
    uint16_t off_screen_mem_size;
    uint8_t  reserved1[206];
};

framebuffer_info_t g_framebuffer_info;

void framebuf_init(void* vbe_mode_info_ptr) {
    // Cast the pointer to our VBE structure
    vbe_mode_info_t* vbe_info = (vbe_mode_info_t*)vbe_mode_info_ptr;
    
    // Fill in our framebuffer info structure from VBE data
    g_framebuffer_info.phys_start_addr = vbe_info->framebuffer;
    g_framebuffer_info.width = vbe_info->width;
    g_framebuffer_info.height = vbe_info->height;
    g_framebuffer_info.stride = vbe_info->pitch;  // Use pitch from VBE
    g_framebuffer_info.bytes_per_pixel = vbe_info->bpp / 8;
    
    // Color channel info
    g_framebuffer_info.red_mask_size = vbe_info->red_mask;
    g_framebuffer_info.red_mask_shift = vbe_info->red_position;
    g_framebuffer_info.green_mask_size = vbe_info->green_mask;
    g_framebuffer_info.green_mask_shift = vbe_info->green_position;
    g_framebuffer_info.blue_mask_size = vbe_info->blue_mask;
    g_framebuffer_info.blue_mask_shift = vbe_info->blue_position;
    g_framebuffer_info.reserved_mask_size = vbe_info->reserved_mask;
    g_framebuffer_info.reserved_mask_shift = vbe_info->reserved_position;
    
    g_framebuffer_info.type = framebuffer_t::FRAMEBUF_TYPE_RGB;
}


void framebuf_put_pixel(uint32_t x, uint32_t y, uint32_t color) {
    if (x >= g_framebuffer_info.width || y >= g_framebuffer_info.height) {
        return;
    }
    
    // Calculate byte offset: y * stride (bytes per line) + x * bytes_per_pixel
    uint8_t* fb = (uint8_t*)g_framebuffer_info.phys_start_addr;
    uint32_t offset = y * g_framebuffer_info.stride + x * g_framebuffer_info.bytes_per_pixel;
    
    // Write the pixel
    uint32_t* pixel = (uint32_t*)(fb + offset);
    *pixel = color;
}

uint32_t framebuf_make_color(uint8_t r, uint8_t g, uint8_t b) {
    return ((uint32_t)r << g_framebuffer_info.red_mask_shift) |
           ((uint32_t)g << g_framebuffer_info.green_mask_shift) |
           ((uint32_t)b << g_framebuffer_info.blue_mask_shift);
}

void framebuf_clear(uint32_t color) {
    uint8_t* fb = (uint8_t*)g_framebuffer_info.phys_start_addr;
    
    for (uint32_t y = 0; y < g_framebuffer_info.height; y++) {
        uint8_t* line_start = fb + (y * g_framebuffer_info.stride);
        
        for (uint32_t x = 0; x < g_framebuffer_info.width; x++) {
            uint32_t* pixel = (uint32_t*)(line_start + (x * g_framebuffer_info.bytes_per_pixel));
            *pixel = color;
        }
    }
}

void framebuf_draw_rect(uint32_t x, uint32_t y, uint32_t width, uint32_t height, uint32_t color) {
    for (uint32_t dy = 0; dy < height; dy++) {
        for (uint32_t dx = 0; dx < width; dx++) {
            framebuf_put_pixel(x + dx, y + dy, color);
        }
    }
}