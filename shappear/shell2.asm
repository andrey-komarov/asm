global _start

_start:
    push dword 0x00000068
    push dword 0x7361622f
    push dword 0x6e69622f
    mov ebx, esp
    xor ecx, ecx
    xor edx, edx
    mov eax, 11
    int 80h
