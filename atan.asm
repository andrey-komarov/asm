extern printf

section .data
    format db "%.20f",0

section .text
    global main



_atan:
    mov ecx, 1

    fld st0
    fmul st1, st0
    fld st0 

    push dword 1

    _atan_l1:
    cmp ecx, [esp + 8] 
    je _atan_finish
    
    fmul st0, st2 ; cur *= x^2

    fild dword [esp]
    fmulp st1, st0 ; cur *= 2n + 1

    add dword [esp], 2
    fild dword [esp]
    fdivp st1, st0 ; cur /= 2n + 3

    fchs ; cur = -cur

    fadd st1, st0

    inc ecx
    jmp _atan_l1
    
    _atan_finish:

    ffree st0
    fincstp
    fxch st1
    ffree st0
    fincstp

    add esp, 4

    ret 4

main:
    fld1
    push dword 10000
    call _atan

    sub esp, 8
    fstp qword [esp]

    push format
    call printf
    add esp, 12 

    mov eax, 0
    ret    
