#include "terminal.h"
#include "keyboard.h"
#include "framebuffer.h"

enum class output_type_t {
    VBE,
    TTY,
    UNKNOWN,
};

void kernel_init(output_type_t out_type);
extern "C" void kernel_main();
