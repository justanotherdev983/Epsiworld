void kernel_init() {

}

void kernel_main() {
    kernel_init();

    while (true) {
        __asm__ volatile("hlt");
    }
}
