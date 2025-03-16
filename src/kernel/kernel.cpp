#include "terminal.h"
#include "keyboard.h"

void kernel_init() {
    terminal_init();
}

void kernel_main() {
    kernel_init();

    while (true) {
        __asm__ volatile("hlt");


    }
}
