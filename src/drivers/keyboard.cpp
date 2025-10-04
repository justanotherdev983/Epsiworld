#include "keyboard.h"
#include "terminal.h"

extern "C" unsigned char inb(unsigned short port);

#define KEYBOARD_DATA_PORT 0x60
#define KEYBOARD_STATUS_PORT 0x64

static const char scancode_ascii[] = {
    0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0,
    0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0,
    0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', 0,
    0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
    '*', 0, ' '
};

void process_keyboard() {
    if (inb(KEYBOARD_STATUS_PORT) & 1) {
        unsigned char scancode = inb(KEYBOARD_DATA_PORT);
        
        // Process only key presses (ignore key releases)
        if (scancode < 0x80) {
            if (scancode < sizeof(scancode_ascii) && scancode_ascii[scancode]) {
                terminal_putchar(scancode_ascii[scancode]);
            }
        }
    }
}
