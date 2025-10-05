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
    
    ; Read output type flag from 0x7000 (set by bootloader)
    xor eax, eax
    mov al, [0x7000]    ; 0 = TTY, 1 = VBE
    push eax            ; Push output type as second parameter
    
    ; Pass VBE info address to kernel_main
    ; The bootloader stored VBE mode info at 0x8000
    push 0x8000         ; Push VBE mode info address as first parameter
    
    ; Call the C++ kernel main function
    ; Parameters: kernel_main(void* vbe_mode_info_ptr, uint32_t output_type)
    call kernel_main
    
    ; Clean up stack
    add esp, 8

    ; Halt the system
    cli
.hang:
    hlt
    jmp .hang