use16
org 0x0000        ; Loaded at 0x1000:0x0000

kernel_entry:
    ; Store multiboot info pointer if needed
    ; Set up initial C environment
    ; Prepare for protected mode
    cli                 ; Disable interrupts
    lgdt [gdt_descriptor] ; Load GDT
    
    ; Enable protected mode
    mov eax, cr0
    or eax, 0x1         ; Set PE bit
    mov cr0, eax
    
    ; Far jump to 32-bit code
    jmp 0x08:protected_mode

use32              ; Switch to 32-bit mode
protected_mode:
    ; Set up segment registers for protected mode
    mov ax, 0x10        ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Set up stack
    mov esp, 0x90000    ; Set stack pointer
    
    ; Clear screen
    mov ecx, 80*25     ; Screen size
    mov edi, 0xB8000   ; Video memory address
    mov eax, 0x07200720 ; Space with light gray on black (two spaces)
    rep stosd          ; Repeat store string dword
    
    ; Display a message
    mov edi, 0xB8000   ; Video memory
    mov esi, kernel_msg
    call print_string
    
    ; Halt the system
    cli
    hlt
    
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
    
; GDT (Global Descriptor Table)
gdt_start:
    ; Null descriptor
    dd 0x0
    dd 0x0
    
    ; Code segment descriptor
    dw 0xFFFF           ; Limit (bits 0-15)
    dw 0x0              ; Base (bits 0-15)
    db 0x0              ; Base (bits 16-23)
    db 10011010b        ; Access byte
    db 11001111b        ; Flags + Limit (bits 16-19)
    db 0x0              ; Base (bits 24-31)
    
    ; Data segment descriptor
    dw 0xFFFF           ; Limit (bits 0-15)
    dw 0x0              ; Base (bits 0-15)
    db 0x0              ; Base (bits 16-23)
    db 10010010b        ; Access byte
    db 11001111b        ; Flags + Limit (bits 16-19)
    db 0x0              ; Base (bits 24-31)
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; GDT size
    dd gdt_start               ; GDT address

kernel_msg db 'EpsiWorld OS Kernel loaded successfully!', 0

; Pad the kernel to ensure it's large enough
times 16384 db 0
