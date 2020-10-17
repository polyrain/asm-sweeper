section .data
 question: db "What's your name?", 10
 answer: db "Hello, "
 ln db 10

 

section .bss
 name resb 16

section .text
global start 
start:
    call prompt
    call getName
    mov rsi, answer
    mov rdx, 7
    call print
    mov rsi, name
    mov rdx, 10
    call print
    mov rsi, ln
    mov rdx, 1
    call print
    call loop_name
    
    mov rax, 0x02000001
    mov rdi, 0
    syscall

reset_name:
    
loop_name:
    mov cx, 3
    startloop:
        cmp cx, 0
        jz endofloop
        push cx
    loopy:
        call getName
        mov rsi, answer
        mov rdx, 7
        call print
        mov rsi, name
        mov rdx, 10
        call print
        
        pop cx
        dec cx
        jmp startloop
    endofloop:
   ; Loop ended
   ; Do what ever you have to do here
        ret

prompt:
    mov rax, 0x02000004 
    mov rdi, 1
    mov rsi, question
    mov rdx, 18
    syscall

print:
    mov rax, 0x02000004
    mov rdi, 1
    syscall
    ret

getName:
    mov rdi, 0x0000 
    mov [rel name],rdi
    mov rax, 0x02000003 ; read
    mov rdi, 0
    mov rsi, name
    mov rdx, 37
    syscall
 ret
