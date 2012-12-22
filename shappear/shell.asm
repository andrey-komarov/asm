section .bss
    ololo db "1234567890",0

section .data
    format db "/bin/ps",0

global _start

_start:
    mov ebx, format
    xor ecx, ecx
    xor edx, edx
    mov eax, 11
    int 80h
