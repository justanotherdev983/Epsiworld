#include "terminal.h"
#include "keyboard.h"
#include "framebuffer.h"

enum class output_type_t {
    VBE,
    TTY,
    UNKNOWN,
};

void kernel_init(void* vbe_mode_info_ptr, output_type_t out_type);
extern "C" void kernel_main(void* vbe_mode_info_ptr, uint32_t output_type_value);
