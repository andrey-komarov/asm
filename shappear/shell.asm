section .data
    format db "/bin/bash",0

global _start

_start:
    mov ebx, format
    xor ecx, ecx
    xor edx, edx
    mov eax, 11
    int 80h
