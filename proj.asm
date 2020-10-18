section .data
border: db "+----------+"
side: db "+"
mine: db " X "
unknown: db " ? "
safe: db " O "
doneMsg: db "Finished"

greeting: db "Welcome to Minesweeper", 10
stage: db "progressing",10
newln: db 10
evenMsg: db "Even",10
oddMsg: db "Odd",10
num db 0
char db 65

section .bss
    minex resq 10
    miney resq 10 ; arrays for x and y positions of the mines

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
    mov rsi, newln
    mov rdx, 1
    call print
    mov rsi, stage
    mov rdx, 12
    call print
    call check_bombs
    call check_board
    mov rax, 0x02000001
    mov rdi, 0
    syscall


printBomb:
    mov rsi, mine
    mov rdx, 3
    push rcx
    push rax
    call print
    pop rax
    pop rcx
    ret

printSafe:
    mov rsi, safe
    mov rdx, 3
    push rcx
    push rax
    call print
    pop rax
    pop rcx
    ret

printQ:
    mov rsi, unknown
    mov rdx, 3
    push rcx
    push rax
    call print
    pop rax
    pop rcx
    ret

check_board:

    xor rcx, rcx
    xor rbx, rbx
    lea r12, [rel miney]
    lea r13, [rel minex]

    outerLoop:

        cmp rcx, 9
        je done
        xor rbx, rbx ; reset inner
        mov rax, [r12+rcx*8] ; rax now has x[i]
        mov [rel num], rax
        push rax
        call printNum
        pop rax
        sub rax, 48


    innerLoop:
        mov r14, [r13+rbx*8] ; rax now has y[j]
        mov [rel num], r14
        ;push r14
        push rax

        call printNum
        pop rax
        ;pop r14
    
        sub r14, 48
        ;push r14
        ;mov r14, 2

        cmp r14, rbx
        ;pop r14
        je bomb
        call printQ
        jmp innerEnd
        
        bomb:
            ;push r14
            ;mov r14, 2
            ;cmp r14, rcx
            ;pop r14
            cmp rax, rcx
            je certBomb
            call printQ
            jmp innerEnd

        certBomb: ; both registers equal our indices; its a bomb
            call printBomb
        
        innerEnd:
            cmp rbx, 9
            je innerLoopDone
            inc rbx
            jmp innerLoop

    innerLoopDone:

        inc rcx
        push rsi
        push rax
        push r14

        mov rsi, newln
        mov rdx, 1
        push rcx
        call print
        pop rcx

        pop r14
        pop rax
        pop rsi
        jmp outerLoop
    done:
        mov rsi, doneMsg
        mov rdx, 8
        call print
        ret



check_bombs:
    lea r13, [rel miney]
    lea r14, [rel minex]
    xor rcx, rcx

    board_loop:
        mov rbx, [r14+rcx*8]
        mov [rel num], rbx
        call printNum
        
        mov rbx, [r13+rcx*8]
        mov [rel num], rbx
        call printNum
        
        push rcx
        mov rsi, newln
        mov rdx, 1
        call print
        pop rcx
        
        inc rcx
        
        push rcx
        mov rsi, stage
        mov rdx, 12
        call print
        pop rcx
        cmp rcx, 9
        jne board_loop
    ret

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
        push rsi
        call printNum ; print
        pop rsi
        inc rcx ; we don't need this anymore
        cmp rcx, 9
        jne array_y
    ret

fill_x_arr:
    lea rsi, [rel minex] ; needed for 64 bit on mac
    xor rcx, rcx ; make this 0
    
    mov [rel minex], rcx
    array_x:
        call check_odd
        mov [rsi+rcx*8], eax ; array element rcx updated with value
        mov rbx, [rsi + rcx*8] ; grab value at index we just filled
        
        add rbx, 48 ; now offset number by 48 to make it ascii'able
        mov [rsi+rcx*8], rbx ; overwritten the value we saw as it's ascii
        mov [rel num], rbx ; update storage var
        push rsi
        call printNum ; print
        pop rsi
        inc rcx ; we don't need this anymore
        cmp rcx, 9
        jne array_x
    ret


printNum:
    mov rsi, num
    mov rdx, 1
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


