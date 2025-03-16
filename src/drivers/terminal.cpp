#include "terminal.h"
#include "memory.h"

// Terminal state
static size_t term_row;
static size_t term_column;
static uint8_t term_color;
static uint16_t* term_buffer;

// VGA text mode constants
static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;
static uint16_t* const VGA_MEMORY = (uint16_t*)0xB8000;


static inline uint16_t vga_entry(unsigned char c, uint8_t color) {
    return (uint16_t)c | (uint16_t)color << 8;
}

static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) {
    return fg | bg << 4;
}

void terminal_init() {
    term_row = 0;
    term_column = 0;
    term_color = vga_entry_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    term_buffer = VGA_MEMORY;

    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            const size_t index = y * VGA_WIDTH + x;
            term_buffer[index] = vga_entry(' ', VGA_COLOR_BLACK);
        }
    }

}

void terminal_scroll() {
    if (term_row >= VGA_HEIGHT) {
        for (size_t y = 0; y < VGA_HEIGHT - 1; y++) {
            for (size_t x = 0; x < VGA_WIDTH; x++) {
                const size_t src_index = y * VGA_WIDTH + x;
                const size_t dst_index = (y + 1) * VGA_WIDTH + x;
                term_buffer[dst_index] = term_buffer[src_index];
            }
        }
    }

    term_row = VGA_HEIGHT - 1;
}

void terminal_putchar(char c) {
    if (c == '\n') {
        term_column = 0;
        term_row++;

        terminal_scroll();
    } 

    const size_t index = term_row * VGA_WIDTH + term_column;
    term_buffer[index] = vga_entry(c, VGA_COLOR_WHITE);

    term_column++;
    if (term_column >= VGA_WIDTH) {
        term_row++;
        term_column = 0;
        terminal_scroll();
    }

}
void terminal_write(const char* data, size_t size) {
    
    for (size_t i = 0; i < size; i ++) {
        terminal_putchar(data[i]);
    }

}
void terminal_writestring(const char* data) {

}
void terminal_setcolor(uint8_t color) {

}
void terminal_clear() {

}
