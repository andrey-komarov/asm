extern printf

section .data
    format db "%.20f",0

section .text
    global main

_atan:
    mov rdi, 100000 ; количество слагаемых
    mov rax, 1.0 ; коэффициент 
    movq xmm1, rax ; xmm1 -- множитель

    mov rax, 2.0
    movq xmm4, rax; xmm4 = 2

    mov rax, -1.0
    movq xmm2, rax
    mulpd xmm2, xmm0
    mulpd xmm2, xmm0 ; xmm2 = -x^2

    movq xmm3, xmm0 ; xmm3 = текущее слагаемое

    _atan_begin:

    mulpd xmm3, xmm1 ; *= n
    addpd xmm1, xmm4 ; n += 2
    divpd xmm3, xmm1 ; /= n
    mulpd xmm3, xmm2 ; *= -x^2

    addpd xmm0, xmm3 ; прибавить новое слагаемое

    dec rdi
    test rdi, rdi
    jnz _atan_begin

    ret

main:
    push rax  
 
    mov rax, 1.0
    movq xmm0, rax
    call _atan

    mov rdi, format
    mov rax, 1
    call printf

    pop rcx

    mov rax, 0
    ret    
