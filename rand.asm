section .data
ln db 10
less: db `\033[5;7H`, "Less than 50"
more: db "More than 50"
red: db `\u001b[31m`,0 ; ANSI Fore Red code
reset: db `\u001b[0m`,0 ; ANSI reset

section .text
global start
start:
    call setColor
    call randNum

    cmp    eax, 50 ; compare eax value to the number 80
    jl     Less
    mov rsi, more
    mov rdx, 18
    call print
    jmp    Both
    Less:
    mov rsi, less
    mov rdx, 18
    call print
    Both:
    mov rsi, ln
    mov rdx, 1
    call print
        mov rsi, reset
        mov rdx, 4
        call print
        mov rax, 0x02000001
        mov rdi, 0
        syscall

setColor:
    mov rsi, red
    mov rdx,  5
    call print
    ret

randNum:
    rdtsc
    and eax, 0xFF
    ret

print:
    mov rax, 0x02000004
    mov rdi, 1
    syscall
    ret
