SECTION .data
    arraylen dd 10
    num db 0
    result dw 0
    farewell: db "Blah"
SECTION .bss
    array resq 8
    
SECTION .text
    global start

start:
    call fillArr
    mov rax, 0x02000001
    mov rdi, 0
    syscall

printNum:
    mov rsi, num
    mov rdx, 2
    call print
    ret

fillArr:
    lea rsi, [rel array] ; needed for 64 bit on mac
    xor rcx, rcx ; make this 0
    arrayloop:
        mov [rsi+rcx*8], rcx ; array element rcx updated with value
        mov rbx, [rsi + rcx*8] ; grab value at index we just filled
        
        add rbx, 48 ; now offset number by 48 to make it ascii'able
        mov [rsi+rcx*8], rbx ; overwritten the value we saw as it's ascii
        mov [rel num], rbx ; update storage var
        call printNum ; print
        inc rcx ; we don't need this anymore
        cmp rcx, 10
        jne arrayloop

    mov rsi, farewell
    mov rdx, 4
    call print
    ret

print:
    mov rax, 0x02000004
    mov rdi, 1
    push rcx
    syscall
    pop rcx
    ret
