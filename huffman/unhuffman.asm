extern printf
extern fwrite
extern fread
extern fopen
extern fclose

%define BUFSIZE 1048576

section .bss
    parent : times 511 dw 0
    letter : times 511 db 0
    to_ : times 524288 dd 0
    trie_letter : times 524288 db 0
    trie_used dd 0
    tmpbuf : times 256 db 0
    tmpbuf_used dd 0
    in_ dd 0
    out_ dd 0
    buffer : times BUFSIZE db 0
    buffer_pos dd 0
    buffer_pos_2 dd 0
    outbuffer : times BUFSIZE db 0
    outbuffer_pos dd 0
    len dd 0


section .data
    read_format db "r",0
    write_format db "w",0
    int_format db "%d",10,0
    format db "%.20f",0
    usage db "need two arguments",10,0

section .text
    global print_letter_
    global next_bit_
    global main

print_letter_:
    cmp dword [outbuffer_pos], BUFSIZE
    jne print_letter_if_fin
        push dword [out_]
        push dword BUFSIZE
        push dword 1
        push outbuffer
        call fwrite
        add esp, 16
        mov dword [outbuffer_pos], 0
    print_letter_if_fin:
    mov eax, [outbuffer_pos]
    xor edx, edx 
    mov dl, [esp + 4]
    lea ecx, [outbuffer + eax]
    mov [ecx], dl
    inc dword [outbuffer_pos]
    ret

next_bit_:
    cmp dword [buffer_pos_2], 8
    jne next_bit_else
        mov dword [buffer_pos_2], 0
        cmp dword [buffer_pos], BUFSIZE - 1
        jne next_bit_else2
            mov dword [buffer_pos], 0
            push dword [in_]
            push dword BUFSIZE
            push dword 1
            push buffer
            call fread
            add esp, 16
        jmp next_bit_fi
        next_bit_else2:
            inc dword [buffer_pos]
        next_bit_fi:
    next_bit_else:

    mov ecx, [buffer_pos_2]
    mov edx, [buffer_pos]
    mov dl, [buffer + edx]
    shr dl, cl
    and dl, 1
    xor eax, eax
    mov al, dl
    inc dword [buffer_pos_2]
    ret
    

main:
    mov eax, [esp + 4]
    cmp eax, 3
    je good_usage
        push usage
        call printf
        add esp, 4
        mov eax, -1
        ret
    good_usage:

    mov dword [buffer_pos_2], 8
    mov dword [buffer_pos], BUFSIZE - 1
    mov dword [trie_used], 1

    push read_format
    mov ecx, [esp + 12]
    push dword  [ecx + 2 * 4]
    call fopen
    add esp, 8
    mov [in_], eax

    push dword [in_]
    push dword 1022 ; sizeof(parent)
    push dword 1
    push parent 
    call fread
    add esp, 12

    push dword 511 ; sizeof(letter)
    push dword 1
    push letter
    call fread
    add esp, 12

    push dword 4 ; sizeof(len)
    push dword 1
    push len
    call fread
    add esp, 16

    xor ecx, ecx
    push ebx
    push esi
    main_loop_build_trie:
        push ecx

        mov eax, ecx
        mov dword [tmpbuf_used], 0

        main_loop_build_trie_2:
        cmp ax, -1
        je main_loop_build_trie_2_fin
            mov dl, [letter + eax]
            mov ecx, [tmpbuf_used]
            lea ecx, [tmpbuf + ecx]
            mov [ecx], dl
            
            inc dword [tmpbuf_used]
            mov ax, [parent + 2 * eax]
        jmp main_loop_build_trie_2
        main_loop_build_trie_2_fin:

        xor eax, eax
        mov ecx, [tmpbuf_used]
        main_loop_build_trie_3:
            dec ecx
            xor edx, edx
            mov dl, [tmpbuf + ecx]
            shl edx, 18; sizeof(to_[0])
            lea edx, [to_ + edx]
            lea edx, [edx + 4 * eax]
            mov ebx, [edx]
            test ebx, ebx
            jnz main_loop_build_trie_3_else
                mov esi, [trie_used]
                mov [edx], esi
                inc dword [trie_used]
            main_loop_build_trie_3_else:
            mov eax, [edx]
        test ecx, ecx
        jnz main_loop_build_trie_3
        pop ecx
        mov [trie_letter + eax], cl
    inc ecx
    cmp ecx, 256
    jne main_loop_build_trie
    pop esi
    pop ebx

    push write_format
    mov ecx, [esp + 12]
    push dword [ecx + 1 * 4]
    call fopen
    add esp, 8
    mov [out_], eax

    xor eax, eax
    xor ecx, ecx
    main_main_loop:
        mov edx, [to_ + eax * 4]
        test edx, edx
        jnz main_main_loop_cont
        mov edx, [to_ + eax * 4 + 262144] ; sizeof(to[0])
        test edx, edx
        jnz main_main_loop_cont
            mov dl, [trie_letter + eax]
            push eax
            push ecx
            dec esp
            mov [esp], dl
            call print_letter_
            inc esp
            pop ecx
            pop eax 
            
            xor eax, eax
            inc ecx
        main_main_loop_cont:
            push eax
            push ecx
            call next_bit_
            mov edx, eax
            pop ecx
            pop eax
            shl edx, 18 ; sizeof(to[0])
            mov eax, [to_ + 4 * eax + edx]

    cmp ecx, [len]
    jne main_main_loop

    push dword [out_]
    push dword [outbuffer_pos]
    push dword 1
    push outbuffer
    call fwrite
    add esp, 16

    push dword [in_]
    call fclose
    add esp, 4

    push dword [out_]
    call fclose
    add esp, 4
    
    ret
    
