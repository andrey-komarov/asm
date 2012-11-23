extern printf
extern fread
extern fopen
extern fwrite
extern fscanf
extern fclose
extern malloc
extern scanf

section .data
        w db "w",0
        r db "r",0
        namein db "count.in",0
        formatInt db "%d",10,0
        formatString db "%s",0
        infile dd -1
        n dd -1
        s dd -1
        edges dd -1
        suf dd -1
        vdepth dd -1
        vertices dd 0
        edges_cnt dd 0
        hell dd -1
        root dd -1
        current_vertex dd -1
        current_edge dd -1
    ret
        depth dd -1
        last_vertex dd -1
        last_depth dd -1
        last_edge dd -1
        current_letter dd -1
        from dd -1
        too dd -1
        left dd -1
        right dd -1
        tmp dd -1
        INF dd -1
        
        msgEdges db "Edges:",10,0
        msgNewLine db 10,0
        msgIntComma db "%d,",0
section .text
    global main

; cdecl print_stats()
print_stats:
    push msgEdges
    call printf
    add esp, 4

    mov eax, 0
    print_stats_in_loop:
        mov ecx, 0
        print_stats_out_loop:
            mov edx, [edges]
            mov edx, [edx + 4 * eax]
            mov edx, [edx + 4 * ecx]
            push eax ; save
            push ecx ; save
            push edx ; arg
            push msgIntComma
            call printf
            add esp, 8
            pop ecx
            pop eax
            inc ecx
            cmp ecx, 25
            jle print_stats_out_loop
        push eax ; save
        push msgNewLine
        call printf
        add esp, 4
        pop eax
        inc eax
        cmp eax, [n]
        jl print_stats_in_loop

    ret

; cdecl newVertex(d)
new_vertex:
    mov eax, [vertices]
    inc dword [vertices]
    ; vdepth[eax] = d
    mov ecx, [esp + 4]
    mov edx, [vdepth]
    mov [edx + 4 * eax], ecx
    ; suf[eax] = -1
    mov edx, [suf]
    mov dword [edx + 4 * eax], -1
    ; все выходящие рёбра заполнить -1
    xor ecx, ecx
    mov edx, [edges]
    mov edx, [edx + 4 * eax]
    ;mov edx, [edx]
    new_vertex_edges_init_loop:
        mov dword [edx], -1 ; edges[eax][ecx] = -1
        add edx, 4
        inc ecx
        cmp ecx, 25
        jle new_vertex_edges_init_loop
    ret

; cdecl new_edge(from, left)
new_edge:
    mov eax, [edges_cnt]
    inc dword [edges_cnt]
    ; from[eax] = from
    mov edx, [from]
    mov ecx, [esp + 8]
    mov [edx + 4 * eax], ecx
    ; left[eax] = left
    mov edx, [left]
    mov ecx, [esp + 4]
    mov [edx + 4 * eax], ecx
    ; right[eax] = INF
    mov edx, [right]
    mov ecx, [INF]
    mov [edx + 4 * eax], ecx
    ; to[eax] = newVertex(INF)
    push eax
    push dword [INF]
    call new_vertex
    add esp, 4
    mov edx, [too]
    mov ecx, eax
    pop eax
    mov [edx + 4 * eax], ecx
    ret

; cdecl new_edge2(from, to, left, right)
new_edge2:
    mov eax, [edges_cnt]
    inc dword [edges_cnt]
    ; from[eax] = from
    mov edx, [from]
    mov ecx, [esp + 16]
    mov [edx + 4 * eax], ecx
    ; to[eax] = to
    mov edx, [too]
    mov ecx, [esp + 12]
    mov [edx + 4 * eax], ecx
    ; left[eax] = left
    mov edx, [left]
    mov ecx, [esp + 8]
    mov [edx + 4 * eax], ecx
    ; right[eax] = right
    mov edx, [right]
    mov ecx, [esp + 4]
    mov [edx + 4 * eax], ecx
    ret

; stdcall can_go(ch)
can_go:
    test dword [current_vertex], -1
    jz can_go_next
    ; eax = edges[current_vertex][ch] - (-1)
    mov edx, [edges]
    mov eax, [current_vertex]
    mov edx, [edx + 4 * eax]
    mov eax, [esp + 4]
    mov edx, [edx + 4 * eax]
    sub edx, -1
    mov eax, edx
    jmp can_go_finish

    can_go_next:
    test dword [current_edge], -1
    jz can_go_error
    ; eax = s[left[current_edge] + depth] - ch
    mov edx, [left]
    mov eax, [current_edge]
    mov edx, [edx + 4 * eax]
    add edx, [depth]
    mov eax, [s]
    xor edx, edx
    mov dl, [edx + eax]
    mov eax, edx
    mov edx, [esp + 4]
    sub eax, edx

    can_go_finish:
    ret 4
    can_go_error:
    xor esp, esp ; ломаааать!
    ret

; cdecl create_new_leaf_here(ch)
create_new_leaf_here:
    ; TODO TODO
    ret

; jump_suffix_link()
jump_suffix_link:
    ; TODO TODO
    ret

; cdecl go(ch)
go:
    test dword [current_vertex], -1
    jz go_next
        ; current_edge = edges[current_vertex][ch]
        mov edx, [edges]
        mov eax, [current_vertex]
        mov edx, [edx + 4 * eax]
        mov eax, [esp + 4]
        mov edx, [edx + 4 * eax]
        mov [current_edge], edx
        
        mov dword [depth], 1
        mov dword [current_vertex], -1
        
    jmp go_if1_fin 
    go_next:
    test dword [current_edge], -1
    jz go_if1_fin
        inc dword [depth]
    go_if1_fin:

    ; if (current_edge != -1) && left[current_edge] + depth == right[current_edge]
    test dword [current_edge], -1
    jz go_fin
    ; left[current_edge] + depth
    mov edx, [left]
    mov eax, [current_edge]
    mov edx, [edx + 4 * eax]
    add edx, [depth]
    ; right[current_edge]
    mov ecx, [right]
    mov ecx, [ecx + 4 * eax]
    test ecx, edx
    jnz go_fin
        ; current_vertex = to[current_edge]
        mov edx, [too]
        mov eax, [current_edge]
        mov edx, [edx + 4 * eax]
        mov [current_vertex], edx
        
        mov dword [current_edge], -1
        mov dword [depth], 0

    go_fin:
    ret

; cdecl append(ch)
append:
    ; while (!can_go(ch))
        push dword [esp + 4]
        call can_go
        test eax, eax
        jnz append_loop_finish

        push dword [esp + 4]
        call create_new_leaf_here
        add esp, 4
        call jump_suffix_link
        
        jmp append
    append_loop_finish:

    push dword [esp + 4]
    call go
    add esp, 4
    ret

; cdecl suffix_tree()
suffix_tree:
    ; hell = new_vertex(-1)
    push dword -1
    call new_vertex
    add esp, 4
    mov [hell], eax
    ; root = new_vertex(0)
    push dword 0
    call new_vertex
    add esp, 4
    mov [root], eax
    
    mov [current_vertex], eax
    mov dword [current_edge], -1
    mov dword [last_vertex], -1
    mov ecx, [n]
    mov [INF], ecx

    ; s[i] -= 'a'
    mov ecx, [n]
    mov edx, [s]
    suftree_str_sub_loop:
        dec ecx
        sub dword [edx], 97 ; 'a'
        inc edx
        test ecx, ecx
        jnz suftree_str_sub_loop

    ; new_edge2(hell, root, -1, 0)
    push dword 0
    push dword -1
    push dword [root]
    push dword [hell]
    call new_edge2
    add esp, 16
    ; edges[hell][i] = eax
    mov ecx, [hell]
    mov edx, [edges]
    mov edx, [edx + 4 * ecx]
    mov ecx, 26
    suftree_edges_init_loop:
        dec ecx
        mov [edx], eax
        add edx, 4
        test ecx, ecx
        jnz suftree_edges_init_loop
    ; suf[hell] = hell
    mov ecx, [hell]
    mov edx, [suf]
    mov [edx + 4 * ecx], ecx
    ; suf[root] = hell
    push ecx
    mov ecx, [root]
    pop dword [edx + 4 * ecx]
    ; append(s[i])
    mov dword [current_letter], 0
    push ebx
    mov ebx, [s]
    suftree_add_loop:
        xor eax, eax
        mov al, [ebx]
        push eax
        call append
        add esp, 4
        inc dword [current_letter]
        mov eax, [current_letter]
        cmp eax, [n]
        jl suftree_add_loop
    pop ebx

    ret

main:
    ; открыть count.in
    push r 
    push namein
    call fopen
    add esp, 8
    mov [infile], eax

    ; считать оттуда число
    push n
    push formatInt
    push dword [infile]
    call fscanf
    add esp, 12

    ; вывести это число
    push dword [n]
    push formatInt
    call printf
    add esp, 8

    push ebx
    mov ebx, [n]
    lea ebx, [8*ebx]
    
    ; выделить память подо всёёё!
    push ebx
    call malloc
    mov [suf], eax
    call malloc
    mov [from], eax
    call malloc
    mov [too], eax
    call malloc
    mov [left], eax
    call malloc
    mov [right], eax
    call malloc
    mov [vdepth], eax
    call malloc
    mov [edges], eax
    pop ebx
    mov ebx, [n]
    lea ebx, [ebx+4]
    push ebx
    call malloc
    mov [s], eax
    add esp, 4
    ; осталось под рёбра
    mov eax, [n]
    mov ecx, 208
    mul ecx; 26 * 8
    push eax
    call malloc
    mov [tmp], eax
    add esp, 4
    xor ecx, ecx
    mov ebx, 208
    mov eax, [tmp]
    mov edx, [edges]
    edge_init_loop:
        mov [edx], eax
        add eax, ebx; eax = tmp, 8 * n * ecx 
        add edx, 4
        inc ecx
        cmp ecx, 25
        jle edge_init_loop

    pop ebx

    ; считать строку s
    push dword [s]
    push formatString
    push dword [infile]
    call fscanf
    add esp, 12

    ; строим дерево
    call suffix_tree

    xor eax, eax
    ret
