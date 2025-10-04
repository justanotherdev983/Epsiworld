#include "terminal.h"
#include "keyboard.h"

void kernel_init() {
    terminal_init();
}

extern "C" void kernel_main() {
    kernel_init();
    terminal_writestring("EpsiWorld OS Initialized\n");
    terminal_writestring("Keyboard ready...\n");

    while (true) {
        process_keyboard();
        
        //__asm__ volatile("hlt");

    }
}
