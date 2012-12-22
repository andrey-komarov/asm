extern fwrite
extern printf
extern fopen
extern fread
extern fclose

%define BUFSIZE 1048576

section .bss
    fout dd 0
    file dd 0
    outbuffer : times BUFSIZE db 0
    buffer1_used dd 0
    buffer_used dd 0
    preoutbuf : times 256 db 0
    preoutbuf_used dd 0
    freq : times 256 db 0
    buffer : times BUFSIZE db 0
    parent : times 511 dw 0
    letter : times 511 db 0
    queue : times 511 dd 0
    weight : times 511 dd 0
    qsize dd 0
    used dd 0
    len dd 0

section .data
    usage db "need two arguments!!",10,0
    format_int db "%d",10,0
    read_format db "r",0
    write_format db "w",0

section .text
    global push_
    global pop_
    global print_
    global print_encoded_
    global main

push_:
    mov ecx, [esp + 8] ; w
    mov edx, [esp + 4] ; v
    mov [weight + 4 * edx], ecx
    mov ecx, [qsize]
    lea ecx, [queue + 4 * ecx]
    mov [ecx], edx
    inc dword [qsize]
    ret

pop_:
    mov ecx, [qsize]
    xor eax, eax
    pop_loop:
        dec ecx
        mov edx, [queue + 4 * ecx]
        mov edx, [weight + 4 * edx]
        push edx
        mov edx, [queue + 4 * eax]
        mov edx, [weight + 4 * edx]
        cmp [esp], edx
        jge pop_if_fin
            mov eax, ecx
        pop_if_fin:
        pop edx
    test ecx, ecx
    jnz pop_loop

    dec dword [qsize]

    ; eax = best
    lea eax, [queue + 4 * eax]
    mov ecx, [eax]
    mov edx, [qsize]
    mov edx, [queue + 4 * edx]
    mov [eax], edx
    mov eax, ecx
    ret

print_:
    xor eax, eax
    mov ecx, [buffer1_used]
    mov al, [esp + 4]
    shl eax, cl
    ; eax = ch << buffer1_used
    mov edx, [buffer_used]
    lea edx, [outbuffer + edx]
    or [edx], al
    inc dword [buffer1_used]
    mov eax, 8
    cmp dword [buffer1_used], eax
    jne print_fin
        mov dword [buffer1_used], 0
        inc dword [buffer_used]
        mov edx, [buffer_used]
        mov eax, BUFSIZE
        cmp eax, edx
        jne print_fin2
            mov dword [buffer_used], 0
            push dword [fout]
            push dword BUFSIZE
            push dword 1
            push dword outbuffer
            call fwrite
            add esp, 16
        print_fin2:
        mov edx, [buffer_used]
        mov byte [outbuffer + edx], 0
    print_fin:
    ret

print_encoded_:
    xor eax, eax
    mov al, [esp + 4]
    mov dword [preoutbuf_used], 0
    ; eax = p
    print_encoded_loop:
    cmp ax, -1
    je print_encoded_while_fin
        mov edx, [preoutbuf_used]
        mov ecx, [letter + eax]
        mov [preoutbuf + edx], ecx
        inc dword [preoutbuf_used]
        mov ax, [parent + 2 * eax]
    jmp print_encoded_loop
    print_encoded_while_fin:

    mov ecx, [preoutbuf_used]
    print_encoded_loop2:
        dec ecx
        push ecx
        dec esp
        mov al, [preoutbuf + ecx]
        mov [esp], al
        call print_
        inc esp
        pop ecx
    test ecx, ecx
    jnz print_encoded_loop2
    ret

main:
    mov eax, [esp + 4]
    cmp eax, 3
    je good_usage
    good_usage:

    push read_format
    mov ecx, [esp + 12]
    push dword  [ecx + 2 * 4]
    call fopen
    add esp, 8
    mov [file], eax

    mov dword [used], 256

    mov dword [len], 0
    push ebx
    main_read_loop:
        push dword [file]
        push dword BUFSIZE
        push dword 1
        push dword buffer
        call fread
        add esp, 16
        test eax, eax
        jz main_read_loop_fin

        mov ecx, eax
        main_read_loop_freq:
            dec ecx
            xor ebx, ebx
            mov bl, [buffer + ecx]
            inc dword [freq + 4 * ebx]
        test ecx, ecx
        jnz main_read_loop_freq
        
        add [len], eax

    jmp main_read_loop
    main_read_loop_fin:
    pop ebx

    mov ecx, 256
    mov eax, -1
    main_loop_parent_init:
        dec ecx
        mov [parent + 2 * ecx], eax
        push dword [freq + 4 * ecx]
        push ecx
        call push_
        pop ecx
        add esp, 4
    test ecx, ecx
    jnz main_loop_parent_init

    main_loop_build_tree:
        mov eax, [qsize]
        cmp eax, 1
        je main_loop_build_tree_fin
        call pop_
        push eax
        call pop_
        push eax

        mov eax, [used]
        pop ecx
        pop edx
        mov [parent + 2 * ecx], ax
        mov [parent + 2 * edx], ax
        mov byte [letter + ecx], 0
        mov byte [letter + edx], 1

        mov eax, [weight + 4 * ecx]
        mov edx, [weight + 4 * edx]
        add eax, edx
        push eax
        push dword [used]
        call push_
        inc dword [used]
        add esp, 8
    jmp main_loop_build_tree
    main_loop_build_tree_fin:

    call pop_
    mov word [parent + 2 * eax], -1
    
    push dword [file]
    call fclose
    add esp, 4

    push read_format
    mov ecx, [esp + 12]
    push dword [ecx + 2 * 4]
    call fopen
    add esp, 8
    mov [file], eax

    push write_format
    mov ecx, [esp + 12]
    push dword [ecx + 1 * 4]
    call fopen
    add esp, 8
    mov [fout], eax

    push dword [fout]
    push dword 1022 ; sizeof(parent)
    push dword 1
    push parent
    call fwrite
    add esp, 12

    push dword 511 ; sizeof(letter)
    push dword 1
    push letter
    call fwrite
    add esp, 12

    push dword 4 ; sizeof(len)
    push dword 1
    push len
    call fwrite
    add esp, 16

    push ebx
    push esi
    main_read_loop_2:
        push dword [file]
        push dword BUFSIZE
        push dword 1
        push dword buffer
        call fread
        add esp, 16
        test eax, eax
        jz main_read_loop_2_fin
        
        mov esi, eax
        xor ecx, ecx
        main_read_loop_2_iter:
            xor ebx, ebx
            mov bl, [buffer + ecx]
            push ecx
            dec esp
            mov [esp], bl
            call print_encoded_
            inc esp
            pop ecx
        inc ecx
        cmp ecx, esi
        jl main_read_loop_2_iter
        
        add [len], eax

    jmp main_read_loop_2
    main_read_loop_2_fin:
    pop esi
    pop ebx
    
    inc dword [buffer_used]
    push dword [fout]
    push dword [buffer_used]
    push dword 1
    push outbuffer
    call fwrite
    add esp, 16

    push dword [file]
    call fclose
    add esp, 4

    push dword [fout]
    call fclose
    add esp, 4

    xor eax, eax
    ret
