#include "kernel.h"

void kernel_init(void* vbe_mode_info_ptr, output_type_t out_type) {
    switch(out_type) {
        case output_type_t::VBE:
            framebuf_init(vbe_mode_info_ptr);
            terminal_writestring("Width: ");
            terminal_writeint(g_framebuffer_info.width);
            terminal_writestring("\nHeight: ");
            terminal_writeint(g_framebuffer_info.height);
            terminal_writestring("\nStride: ");
            terminal_writeint(g_framebuffer_info.stride);
            terminal_writestring("\nBPP: ");
            terminal_writeint(g_framebuffer_info.bytes_per_pixel);
            terminal_writestring("\n");
            terminal_init();
            framebuf_clear(framebuf_make_color(0, 50, 100));
    
            framebuf_draw_rect(100, 100, 200, 150, framebuf_make_color(255, 0, 0));
            break;
            
        case output_type_t::TTY:
            terminal_init();
            break;
            
        case output_type_t::UNKNOWN:
        default:
            terminal_init();
            terminal_writestring("WARNING: Unknown output type, using TTY\n");
            break;
    }
}

extern "C" void kernel_main(void* vbe_mode_info_ptr, uint32_t output_type_value) {
    output_type_t g_out_type;
    
    if (output_type_value == 0) {
        g_out_type = output_type_t::TTY;
    } else if (output_type_value == 1) {
        g_out_type = output_type_t::VBE;
    } else {
        g_out_type = output_type_t::UNKNOWN;
    }
    
    kernel_init(vbe_mode_info_ptr, g_out_type);

    terminal_writestring("EpsiWorld OS Initialized\n");
    terminal_writestring("Keyboard ready...\n");

    while (true) {
        process_keyboard();
        
        // Uncomment to halt between keyboard checks (saves CPU)
        //__asm__ volatile("hlt");
    }
}