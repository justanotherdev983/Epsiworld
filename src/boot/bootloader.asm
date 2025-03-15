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
    
    mov ah, 0x02        ; BIOS read sector function
    mov al, 32          ; Number of sectors to read
    mov ch, 0           ; Cylinder number
    mov cl, 2           ; Sector number (1 is bootloader)
    mov dh, 0           ; Head number
    mov dl, 0x80        ; Drive number (0x80 = first hard disk)
    
    ; Set buffer address (ES:BX)
    mov bx, 0x1000      ; Load kernel at 0x1000
    mov es, bx
    xor bx, bx
    
    int 0x13            ; Call BIOS interrupt
    jc disk_error       ; Jump if carry flag set (error)
    
    ; Check if we read the correct number of sectors
    cmp al, 32
    jne disk_error
    
    mov si, success_msg
    call print_str
    
    ; Jump to kernel
    jmp 0x1000:0x0000


;start:
    ;print hello_bootloader

print_str:
    pusha
    mov ah, 0x0e
.loop:
    lodsb               ; Load byte at SI into AL and increment SI
    or al, al           ; Check if AL is zero (null terminator)
    jz .done            
    int 0x10            
    jmp .loop           
.done:
    popa                
    ret

disk_error:
    mov si, error_msg
    call print_str
    
    ; Display error code
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    mov al, ':'
    int 0x10
    mov al, ' '
    int 0x10
    
    ; Convert AH (error code) to ASCII and print
    mov al, ah
    add al, '0'
    int 0x10
    
    jmp $
    

welcome_msg db 'EpsiWorld OS Bootloader', 13, 10, 0
loading_msg db 'Loading kernel...', 13, 10, 0
success_msg db 'Kernel loaded successfully, jumping to kernel', 13, 10, 0
error_msg db 'Error loading kernel!', 13, 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55
