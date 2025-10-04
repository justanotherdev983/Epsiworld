use16
org 0x7c00

init:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti
    
    mov si, welcome_msg
    call print_str 

load_kernel:
    mov si, loading_msg
    call print_str
    
    ; Load kernel to 0x10000 (64KB mark, safer location)
    mov ah, 0x02        ; BIOS read sector function
    mov al, 32          ; Number of sectors to read
    mov ch, 0           ; Cylinder number
    mov cl, 2           ; Sector number (starting from sector 2)
    mov dh, 0           ; Head number
    mov dl, 0x80        ; Drive number (0x80 = first hard disk)
    
    ; Load to 0x10000 (segment 0x1000, offset 0)
    mov bx, 0x1000
    mov es, bx
    xor bx, bx
    
    int 0x13
    jc disk_error
    
    cmp al, 32
    jne disk_error
    
    mov si, success_msg
    call print_str

enter_protected_mode:
    cli                 ; Disable interrupts
    
    ; Load GDT
    lgdt [gdt_descriptor]
    
    ; Enable protected mode
    mov eax, cr0
    or eax, 1           ; Set PE (Protection Enable) bit
    mov cr0, eax
    
    ; Far jump to flush pipeline and enter 32-bit mode
    jmp 0x08:protected_mode_entry

print_str:
    pusha
    mov ah, 0x0e
.loop:
    lodsb
    or al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

disk_error:
    mov si, error_msg
    call print_str
    jmp $

; GDT - Global Descriptor Table
gdt_start:
    ; Null descriptor (required)
    dq 0x0

gdt_code:
    ; Code segment descriptor
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0x0000       ; Base (bits 0-15)
    db 0x00         ; Base (bits 16-23)
    db 10011010b    ; Access byte: present, ring 0, code, executable, readable
    db 11001111b    ; Flags + Limit (bits 16-19): 4K granularity, 32-bit
    db 0x00         ; Base (bits 24-31)

gdt_data:
    ; Data segment descriptor
    dw 0xFFFF       ; Limit (bits 0-15)
    dw 0x0000       ; Base (bits 0-15)
    db 0x00         ; Base (bits 16-23)
    db 10010010b    ; Access byte: present, ring 0, data, writable
    db 11001111b    ; Flags + Limit (bits 16-19): 4K granularity, 32-bit
    db 0x00         ; Base (bits 24-31)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT
    dd gdt_start                ; Address of GDT

; 32-bit protected mode code
use32
protected_mode_entry:
    ; Set up segment registers
    mov ax, 0x10        ; Data segment selector (offset into GDT)
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Set up stack
    mov esp, 0x90000
    
    ; Jump to kernel (now at 0x10000)
    jmp 0x10000

; Data
use16
welcome_msg db 'EpsiWorld OS Bootloader', 13, 10, 0
loading_msg db 'Loading kernel...', 13, 10, 0
success_msg db 'Kernel loaded, entering protected mode...', 13, 10, 0
error_msg db 'Error loading kernel!', 13, 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55