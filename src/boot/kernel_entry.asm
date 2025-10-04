format ELF

section '.text' executable

public kernel_entry
extrn kernel_main

kernel_entry:
    cli 
    
    ; We're already in protected mode (bootloader did this)
    ; Set up segment registers
    mov ax, 0x10        ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Set up stack
    mov esp, 0x90000    ; Set stack pointer
    mov ebp, esp
    
    ; Clear screen
    mov ecx, 80*25      ; Screen size
    mov edi, 0xB8000    ; Video memory address
    mov eax, 0x07200720 ; Space with light gray on black (two spaces)
    rep stosd           ; Repeat store string dword
    
    ; Display a message
    mov edi, 0xB8000    ; Video memory
    mov esi, kernel_msg
    call print_string

    ; Call the C++ kernel main function
    call kernel_main

    ; Halt the system
    cli
    hlt
    jmp $               ; Infinite loop
    
; Print null-terminated string in protected mode
print_string:
    push eax
    push edi
    
.loop:
    lodsb               ; Load byte at ESI into AL and increment ESI
    or al, al           ; Check if AL is zero (null terminator)
    jz .done
    
    mov ah, 0x07        ; Light gray on black attribute
    mov [edi], ax       ; Store character and attribute
    add edi, 2          ; Move to next character position
    jmp .loop
    
.done:
    pop edi
    pop eax
    ret

kernel_msg db 'EpsiWorld OS Kernel loaded successfully!', 0