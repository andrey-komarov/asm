extern printf
extern fread
extern fopen
extern fwrite

section .data
	buffer db 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0  
        r db "r",0
        w db "w",0
        namein db "test.bmp",0
        nameout db "ololo.bmp",0
        format db "%d",0

section .text
	global main



main:
    push w
    push nameout
    call fopen
    add esp, 8

    push eax ; outfile

    push r
    push namein
    call fopen
    add esp, 8

    push eax ; [esp] 

    push 54
    push 1
    push buffer
    call fread
    add esp, 12

    push dword [esp + 4]
    push 54
    push 1
    push buffer
    call fwrite
    add esp, 16

    ll:
        push 64
        push 1
        push buffer
        call fread
        add esp, 12
        
        test eax, eax
        jz fin

        xor ebx, ebx 
        
        ll2:
        movq mm0, [ebx + buffer]
        paddusb mm0, mm0
        movq [ebx + buffer], mm0
        add ebx, 8
        cmp ebx, eax
        jna ll2

        push dword [esp + 4] 
        push eax
        push 1
        push buffer
        call fwrite
        add esp, 16

    jmp ll
    fin:

    add esp, 8
    ret
