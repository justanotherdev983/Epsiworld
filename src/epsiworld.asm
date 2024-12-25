use16
org 0x7c00

macro print msg {
    mov si, msg

print_char:
    mov ah, 0x0e              ; BIOS teletype output
    mov al, [si]
    int 0x10                  ; BIOS video interrupt
    inc si
    cmp byte [si], 0          ; Check if we've reached null terminator
    jne print_char
}

start:
    print hello_bootloader


hello_bootloader db 'Hello EpsiWorld!', 0


times 510 - ($ - $$) db 0
dw 0xAA55