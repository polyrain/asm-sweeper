section .data
border: db "+----------+"
side: db "+"
greeting: db "Welcome to Minesweeper", 10
newln: db 10
evenMsg: db "Even",10
oddMsg: db "Odd",10
num db 0

section .bss
    minex resq 8
    miney resq 8 ; arrays for x and y positions of the mines

section .text
global start
start:
    mov rsi, greeting
    mov rdx, 23
    call print
    call print_board
    call fill_x_arr
    mov rsi, newln
    mov rdx, 1
    call print
    call fill_y_arr
    mov rsi, greeting
    mov rdx, 23
    call print
    mov rax, 0x02000001
    mov rdi, 0
    syscall


print: ; Print function; put your text to print on stack first
    mov rax, 0x02000004
    mov rdi, 1
    syscall
    ret

rand_num: ; Checks # of cycles since you last restarted your computer
    rdtsc ; stores result of this into eax:edx
    and eax, 0x0F ; constrain the number between 0 and 9
    cmp eax, 9
    jg rand_num
    ret ; eax now has our final rand num

check_odd:
    call rand_num
    test rcx, 1
    jnz odd
    add eax, 0
    ret
    odd:
    add eax, 1
    ret
    

fill_y_arr:
    lea rsi, [rel miney] ; needed for 64 bit on mac
    xor rcx, rcx ; make this 0
    array_y:
        
        call check_odd
        mov [rsi+rcx*8], eax ; array element rcx updated with value
        mov rbx, [rsi + rcx*8] ; grab value at index we just filled
            
        add rbx, 48 ; now offset number by 48 to make it ascii'able
        mov [rsi+rcx*8], rbx ; overwritten the value we saw as it's ascii
        mov [rel num], rbx ; update storage var
        ;call printNum ; print
        inc rcx ; we don't need this anymore
        cmp rcx, 10
        jne array_y
    ret

fill_x_arr:
    lea rsi, [rel minex] ; needed for 64 bit on mac
    xor rcx, rcx ; make this 0
    array_x:
        call check_odd
        mov [rsi+rcx*8], eax ; array element rcx updated with value
        mov rbx, [rsi + rcx*8] ; grab value at index we just filled
        
        add rbx, 48 ; now offset number by 48 to make it ascii'able
        mov [rsi+rcx*8], rbx ; overwritten the value we saw as it's ascii
        mov [rel num], rbx ; update storage var
        ;call printNum ; print
        inc rcx ; we don't need this anymore
        cmp rcx, 10
        jne array_x
    ret

printNum:
    mov rsi, num
    mov rdx, 2
    push rcx ; need to push rcx on stack because sys call in print cull
    call print
    pop rcx
    ret

print_board:
    mov cx, 10
    loop_start:
        cmp cx, 0
        jz end
        push cx
    loop:
        mov rsi, border
        mov rdx, 12
        call print
        mov rsi, newln
        mov rdx, 1
        call print

        pop cx
        dec cx
        jmp loop_start
    end:
        ret


