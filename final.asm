; Welcome to an assembly example of NASM.
; Included is how to print, generate random numbers
; loop over arrays, create arrays
; and if statements! All the blocks you need to be awesome.

; compile this on mac with: nasm -f macho64 final.asm && ld -macosx_version_min 10.7.0 -lSystem -o lottery final.o

section .data ; Constants in memory; think of this like #define in C
 question: db "What's your name?", 10 ; 10 is newline character
 answer: db "Hello, "

 ln db 10 ; new line

 greeting: db "Welcome to the app!", 10
 newln: db 10
 winner: db "Match!"
 unlucky: db "No dice!",10
 random: db "Now for some randomly generated numbers!",10
 prompt_numbers: db "Pick a number I'm thinking of: ",10

 red: db `\u001b[31m`,0 ; ANSI Fore Red code
 green: db `\u001b[32m`,0 ; ANSI Fore Green code
reset: db `\u001b[0m`,0 ; ANSI reset
border: db "+----------+"
num db 0 ; Intermediate storage number for math

 section .bss ; Variables of the program. These are allocated in memory but aren't initalized
    numbers resb 16 ; <var> resb/w/d/q <length> means make an array of length <length>
    ; the resb/w/d/q defines how large each element is in terms of bytes (1,4,8,16)
    
    minex resq 10 
    miney resq 10 ; arrays for x and y positions of the mines
    name resb 16 ; string variable for user input

section .text ; code of main program goes under this
global start ; entry point for compiler; this is like "main" in C
start: ; This is a label: think of it like a function name in C. Use these to define sections of code
    
    ; Welcome user and get their name
    call prompt
    call getName ; We can call subroutines by saying call <label>, where label is their name
    mov rsi, answer ; put the answer register into rsi, which is how mac parses command line args
    mov rdx, 7
    call print ; call the print method; how handy, it's just like printf!
    mov rsi, name
    mov rdx, 10
    call print
    

    ; Introduce them to the app
    mov rsi, greeting 
    mov rdx, 19
    call print

    mov rsi, ln ; Prints a new line; verbose for learning purposes
    mov rdx, 1
    call print

    ; Get a guess off the user, first tell them whats going on
    mov rsi, prompt_numbers
    mov rdx, 32
    call print
    
    ; get their guess

    call getNums

    call check_answer ; check it

    call resetColor ; reset our terminal output
    
    mov rsi, random ; Now we show off the random number generator and arrays
    mov rdx, 41
    call print

    call setGreen

    call fill_x_arr
    call fill_y_arr
    call check_board
    call resetColor


    ; sys call for exiting program with exit status 0; note how this looks like C? :)
    mov rax, 0x02000001
    mov rdi, 0
    syscall

; Resets the terminal color so you aren't stuck with green
resetColor:
    mov rsi, reset
    mov rdx, 4
    call print
    ret

; Makes terminal color red
setRed:
    mov rsi, red
    mov rdx,  5
    call print
    ret

; Makes terminal color green, printing via ANSI
setGreen:
    mov rsi, green
    mov rdx,  5
    call print
    ret

; Constructs a syscall to OS to get print the name question
prompt:
    mov rax, 0x02000004 
    mov rdi, 1
    mov rsi, question
    mov rdx, 18
    syscall

; Print routine. Constructs a syscall, and fires away. Put what you want to print into
; registers rsi and rdx; rsi needs to be a pointer to some data, and rdx is how many bytes to read
print:
    mov rax, 0x02000004
    mov rdi, 1
    syscall
    ret

; Helper method to turn a normal value into ASCII while preserving registers
printNum:
    mov rsi, num
    mov rdx, 1
    push rcx ; need to push rcx on stack because sys call in print cull
    call print
    pop rcx
    ret

; Get the number off the user, constructing a syscall and wiping the old value just in case 
; sys call makes sure user is prompted for input to parse in
getNums:
    mov rdi, 0x0000 
    mov [rel numbers],rdi
    mov rax, 0x02000003 ; read
    mov rdi, 0
    mov rsi, numbers
    mov rdx, 37
    syscall
 ret

; Same as above but for a name variable. Note the sizes!
getName:
    mov rdi, 0x0000 
    mov [rel name],rdi
    mov rax, 0x02000003 ; read
    mov rdi, 0
    mov rsi, name
    mov rdx, 37
    syscall
 ret

; Prints a board to the terminal; unused, showcases a forloop
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

; Generates a random number and truncuates it to a value between 0 and 15.
; If number > 9, rerolls until it gets a number <= 9
rand_num: ; Checks # of cycles since you last restarted your computer
    rdtsc ; stores result of this into eax:edx
    and eax, 0x0F ; constrain the number between 0 and 9
    cmp eax, 9
    jg rand_num
    ret ; eax now has our final rand num

; Compares the lower 8 bits of the eax register against the users answer
; if match, prints a win message. Else, prints no dice.
check_answer:
    call check_odd

    mov ah, [rel numbers]
    
    cmp al, ah
    je win
    call setRed
    mov rsi, unlucky
    mov rdx, 9
    call print
    jmp end_check
    
    win:
        call setGreen
        mov rsi, greeting
        mov rdx, 19
        call print

    end_check:
        ret

; Used in constructing arrays as there was a bug which made the generated numbers
; even; every second number gets a +1 to make some variance
check_odd:
    call rand_num
    test rcx, 1
    jnz odd
    add eax, 0
    ret
    odd:
    add eax, 1
    ret

; Example of initalizing the arrays defined in the .bss section. Note how the pointer
; arithmetic is the same as C essentially; talk about C being low level!
fill_x_arr:
    lea rsi, [rel minex] ; needed for 64 bit on mac
    xor rcx, rcx ; make this 0
    
    mov [rel minex], rcx ; initalize first ele to 0
    array_x:
        call check_odd ; Get a random number
        mov [rsi+rcx*8], eax ; array element rcx updated with value
        mov rbx, [rsi + rcx*8] ; grab value at index we just filled
        
        add rbx, 48 ; now offset number by 48 to make it ascii'able
        mov [rsi+rcx*8], rbx ; overwritten the value we saw as it's ascii
        mov [rel num], rbx ; update storage var
        push rsi ; we need to preserve rsi as the syscall in print will "clobber" it 
        call printNum ; print the number we got
        pop rsi
        inc rcx ; we don't need this anymore
        cmp rcx, 9
        jne array_x
    ret

; same as above
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

; Prints the elements from the arrays to the terminal, one element at a time. Another loop example
check_board:
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
        
        cmp rcx, 9
        jne board_loop
    ret
