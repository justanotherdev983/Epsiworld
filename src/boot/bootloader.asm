use16
org 0x7c00

; VBE data will be stored at these memory locations
VBE_INFO_BLOCK equ 0x7E00
VBE_MODE_INFO equ 0x8000

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

setup_vbe:
    mov si, vbe_msg
    call print_str
    
    ; Get VBE controller info
    mov ax, 0x4F00
    mov di, VBE_INFO_BLOCK
    int 0x10
    cmp ax, 0x004F
    jne vbe_failed
    
    ; Get mode info for 1024x768x24
    mov ax, 0x4F01
    mov cx, 0x118
    mov di, VBE_MODE_INFO
    int 0x10
    cmp ax, 0x004F
    jne try_lower_res
    
    ; Set VBE mode with linear framebuffer
    mov bx, 0x4118      ; 0x118 | 0x4000
    jmp set_vbe

try_lower_res:
    mov si, fallback_msg
    call print_str
    
    mov ax, 0x4F01
    mov cx, 0x115
    mov di, VBE_MODE_INFO
    int 0x10
    cmp ax, 0x004F
    jne vbe_failed
    
    mov bx, 0x4115      ; 0x115 | 0x4000

set_vbe:
    mov ax, 0x4F02
    int 0x10
    cmp ax, 0x004F
    jne vbe_failed

vbe_success:
    mov si, success_vbe_msg
    call print_str
    mov byte [0x7000], 1
    jmp load_kernel

vbe_failed:
    mov si, error_vbe_msg
    call print_str
    mov byte [0x7000], 0
    mov ax, 0x0003
    int 0x10

load_kernel:
    mov si, loading_msg
    call print_str
    
    ; Reset disk system first - try floppy (0x00)
    xor ax, ax
    xor dl, dl          ; Drive 0 (floppy)
    int 0x13
    jc disk_error
    
    mov si, reset_ok_msg
    call print_str
    
    ; Load kernel to 0x10000 - smaller read first (15 sectors)
    mov ax, 0x020F      ; ah=0x02, al=15 sectors
    mov cx, 0x0002      ; ch=0 cylinder, cl=2 sector
    xor dh, dh          ; head 0
    xor dl, dl          ; floppy drive 0
    
    mov bx, 0x1000
    mov es, bx
    xor bx, bx
    
    int 0x13
    jc disk_error
    
    ; Print actual sectors read
    push ax
    mov si, read_ok_msg
    call print_str
    pop ax
    
    ; Check if we read expected sectors
    cmp al, 15
    jl sector_error
    
    mov si, ok_msg
    call print_str

enter_protected_mode:
    cli
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp 0x08:protected_mode_entry

print_str:
    pusha
    mov ah, 0x0e
.loop:
    lodsb
    test al, al
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

sector_error:
    mov si, sector_err_msg
    call print_str
    jmp $

; GDT
gdt_start:
    dq 0

gdt_code:
    dw 0xFFFF, 0
    db 0, 10011010b, 11001111b, 0

gdt_data:
    dw 0xFFFF, 0
    db 0, 10010010b, 11001111b, 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; 32-bit protected mode
use32
protected_mode_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000
    jmp 0x10000

; Data
use16
welcome_msg db 'EpsiWorld Bootloader', 13, 10, 0
vbe_msg db 'VBE init...', 13, 10, 0
fallback_msg db 'Trying 800x600...', 13, 10, 0
success_vbe_msg db 'VBE OK!', 13, 10, 0
error_vbe_msg db 'VBE failed, TTY', 13, 10, 0
loading_msg db 'Loading...', 13, 10, 0
reset_ok_msg db 'Reset OK', 13, 10, 0
read_ok_msg db 'Read OK', 13, 10, 0
ok_msg db 'Entering PM...', 13, 10, 0
error_msg db 'Disk error!', 13, 10, 0
sector_err_msg db 'Sector count!', 13, 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55