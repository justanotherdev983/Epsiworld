#include "kernel.h"

void kernel_init(output_type_t out_type) {
    switch(out_type) {
        case output_type_t::VBE:
            framebuf_init();
            terminal_init();    // Initialize terminal to use the framebuffer
            break;
        case output_type_t::TTY:
            terminal_init();    // Initialize terminal for TTY output
            // If TTY output also needs a basic framebuffer (e.g., text mode framebuffer),
            // you might call a different framebuf_init_text_mode() or similar here.
            break;
        case output_type_t::UNKNOWN:
            // TODO: Handle unknown output type, e.g., print error and halt or default to TTY
            terminal_writestring("ERROR: Unknown output type!\n");
            // Fallback to TTY if you want a minimal display
            terminal_init();
            break;
        default:
            // TODO: Handle unexpected enum values, e.g., print error and halt
            terminal_writestring("ERROR: Unexpected output type value!\n");
            terminal_init();
            break;
    }
}

extern "C" void kernel_main() {
    output_type_t g_out_type = output_type_t::VBE;
    kernel_init(g_out_type);

    terminal_writestring("EpsiWorld OS Initialized\n");
    terminal_writestring("Keyboard ready...\n");

    while (true) {
        process_keyboard();
        
        //__asm__ volatile("hlt");

    }
}
