format ELF

section '.text' executable

public inb
public outb

; unsigned char inb(unsigned short port)
inb:
    push ebp
    mov ebp, esp
    
    mov dx, [ebp + 8]   ; port parameter
    xor eax, eax
    in al, dx           ; Read byte from port
    
    pop ebp
    ret

; void outb(unsigned short port, unsigned char value)
outb:
    push ebp
    mov ebp, esp
    
    mov dx, [ebp + 8]   ; port parameter
    mov al, [ebp + 12]  ; value parameter
    out dx, al          ; Write byte to port
    
    pop ebp
    ret