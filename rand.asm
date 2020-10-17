section .data
ln db 10
less: db "Less than 50"
more: db "More than 50"

section .text
global start
start:
    call randNum
    cmp    eax, 50 ; compare eax value to the number 80
    jl     Less
    mov rsi, more
    mov rdx, 12
    call print
    jmp    Both
    Less:
    mov rsi, less
    mov rdx, 12
    call print
    Both:
    mov rsi, ln
    mov rdx, 1
    call print
        mov rax, 0x02000001
        mov rdi, 0
        syscall
    
randNum:
    rdtsc
    and eax, 0xFF
    ret

print:
    mov rax, 0x02000004
    mov rdi, 1
    syscall
    ret
