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
        rooot dd -1
        current_vertex dd -1
        current_edge dd -1
    ret
        depth dd -1
        last_vertex dd -1
        last_depth dd 0
        last_edge dd 0
        current_letter dd -1
        from dd -1
        too dd -1
        left dd -1
        right dd -1
        tmp dd -1
        INF dd -1
        ans dd 0
        msgEdges db "Edges:",10,0
        msgNewLine db 10,0
        msgIntComma db "%d,",0
        msgSuf db "Suffices:",10,0
        msgLasts db "Curr: V:%d E:%d // Last: V:%d, E:%d, D:%d",10,0
        msgLeft db "Left:",0
        msgRight db "Right:",0
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
        cmp eax, [vertices]
        jl print_stats_in_loop

    push msgSuf
    call printf
    add esp, 4
    mov eax, 0
    print_stats_suf_loop:
        mov edx, [suf]
        push eax
        push dword [edx + 4 * eax]
        push msgIntComma 
        call printf
        add esp, 8
        pop eax
        inc eax
        cmp eax, [vertices]
        jl print_stats_suf_loop

    push dword [last_depth]
    push dword [last_edge]
    push dword [last_vertex]
    push dword [current_edge]
    push dword [current_vertex]
    push msgLasts
    call printf
    add esp, 24

    push msgLeft
    call printf
    add esp, 4
    mov eax, 0
    print_stats_left_loop:
        push eax
        mov edx, [left]
        push dword [edx + 4 * eax]
        push msgIntComma
        call printf
        add esp, 8
        pop eax
        inc eax
        cmp eax, [edges_cnt]
        jl print_stats_left_loop

    push msgRight
    call printf
    add esp, 4
    mov eax, 0
    print_stats_right_loop:
        push eax
        mov edx, [right]
        push dword [edx + 4 * eax]
        push msgIntComma
        call printf
        add esp, 8
        pop eax
        inc eax
        cmp eax, [edges_cnt]
        jl print_stats_right_loop

    push msgNewLine
    call printf
    call printf
    add esp, 4

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
    mov ecx, [esp + 4]
    mov [edx + 4 * eax], ecx
    ; left[eax] = left
    mov edx, [left]
    mov ecx, [esp + 8]
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
    mov ecx, [esp + 4]
    mov [edx + 4 * eax], ecx
    ; to[eax] = to
    mov edx, [too]
    mov ecx, [esp + 8]
    mov [edx + 4 * eax], ecx
    ; left[eax] = left
    mov edx, [left]
    mov ecx, [esp + 12]
    mov [edx + 4 * eax], ecx
    ; right[eax] = right
    mov edx, [right]
    mov ecx, [esp + 16]
    mov [edx + 4 * eax], ecx
    ret

; stdcall can_go(ch)
can_go:
    cmp dword [current_vertex], -1
    je can_go_next
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
    cmp dword [current_edge], -1
    je can_go_error
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
    cmp dword [current_vertex], -1
    je newleaf_if1_elif
        ; edges[current_vertex][ch] = newEdge(current_vertex, current_letter)
        push dword [current_letter]
        push dword [current_vertex]
        call new_edge
        add esp, 8
        mov edx, [edges]
        mov ecx, [current_vertex]
        mov edx, [edx + 4 * ecx]
        mov ecx, [esp + 4]
        lea edx, [edx + 4 * ecx]
        mov [edx], eax
    newleaf_if1_elif:
    cmp dword [current_edge], -1
    je newleaf_fin
        ; vdepth[from[current_edge]] + depth
        mov ecx, [current_edge]
        mov edx, [from]
        mov ecx, [edx + 4 * ecx]
        mov edx, [vdepth]
        mov edx, [edx + 4 * ecx]
        add edx, [depth]
        push edx
        call new_vertex
        add esp, 4
        push eax ; ======= СТЕК +4 new_vertex

        cmp dword [last_vertex], -1
        je newleaf_if2_fin
            ; suf[last_vertex] = new_vertex
            mov edx, [suf]
            mov ecx, [last_vertex]
            lea edx, [edx + 4 * ecx]
            mov ecx, [new_vertex]
            mov [edx], ecx
        newleaf_if2_fin:

        mov ecx, [current_edge]
        mov edx, [right]
        push dword [edx + 4 * ecx]
        mov edx, [left]
        mov edx, [edx + 4 * ecx]
        add edx, [depth]
        push edx
        mov edx, [too]
        push dword [edx + 4 * ecx]
        push eax ; new_vertex
        call new_edge2
        add esp, 16

        push ebx ; save
        ; s[left[new_edge]]
        mov edx, [left]
        mov ecx, eax
        mov ecx, [edx + 4 * ecx]
        mov edx, [s]
        xor ebx, ebx
        mov bl, [edx + ecx]
        ; edges[new_vertex][ebx] = new_edge
        mov edx, [edges]
        mov ecx, [esp + 4] ; new_vertex
        mov edx, [edx + 4 * ecx]
        mov [edx + 4 * ebx], eax
        pop ebx ; restore
        ; edges[new_vertex][ch] = new_edge(new_vertex, current_letter)
        push dword [current_letter]
        push dword [esp] ; new_vertex
        call new_edge
        add esp, 8
        mov edx, [edges]
        mov ecx, [esp] ; new_vertex
        mov edx, [edx + 4 * ecx]
        mov ecx, [esp + 8] ; ch ??????
        lea edx, [edx + 4 * ecx]
        mov [edx], eax
        
        mov edx, [too]
        mov ecx, [current_edge]
        lea edx, [edx + 4 * ecx]
        mov ecx, [esp] ; new_vertex
        mov [edx], ecx
        
        mov eax, [left]
        mov ecx, [current_edge]
        mov eax, [eax + 4 * ecx]
        add eax, [depth]
        mov edx, [right]
        mov [edx + 4 * ecx], eax
        
        mov edx, [esp]
        mov [current_vertex], edx

        mov edx, [current_edge]
        mov [last_edge], edx

        mov edx, [depth]
        mov [last_depth], edx

        mov dword [current_edge], -1
        mov dword [depth], 0
        
        mov edx, [esp]
        mov [last_vertex], edx

        add esp, 4; вернуть new_vertex
    newleaf_fin:
    ret

; cdecl length(e)
length:
    ; r[e]-l[e]
    mov edx, [right]
    mov ecx, [esp + 4]
    mov eax, [edx + 4 * ecx]
    mov edx, [left]
    mov edx, [edx + 4 * ecx]
    sub eax, edx 
    ret

; jump_suffix_link()
jump_suffix_link:
    pusha
    mov edx, [suf]
    mov ecx, [current_vertex]
    cmp dword [edx + 4 * ecx], -1
    jz jump_suflink_main_else
        mov edx, [suf]
        mov ecx, [current_vertex]
        mov edx, [edx + 4 * ecx]
        mov [current_vertex], edx
    jmp jump_suflink_fin
    jump_suflink_main_else:
        mov edx, [left]
        mov ecx, [last_edge]
        mov edx, [edx + 4 * ecx]
        mov esi, edx ; need_left
        add edx, [last_depth]
        mov edi, edx ; need_right
        ; suf[from[last_edge]]
        mov edx, [from]
        mov ecx, [last_edge]
        mov ecx, [edx + 4 * ecx]
        mov edx, [suf]
        mov eax, [edx + 4 * ecx] ; now
        ; current_edge = edges[now][s[need_left]]
        mov edx, [s]
        mov ecx, esi
        xor ebx, ebx
        mov bl, [edx + ecx]
        mov edx, [edges]
        mov edx, [edx + 4 * eax]
        mov edx, [edx + 4 * ebx]
        mov [current_edge], edx;
        jump_suflink_while:
            ; need_right - need_left > length(current_edge)
            mov ebx, edi
            sub ebx, esi
            push dword [current_edge]
            call length
            add esp, 4
            cmp ebx, eax
            jle jump_suflink_while_end
            add [esi], eax
            ; current_edge = edges[to[current_edge]][s[need_left]]
            mov edx, [too]
            mov ecx, [current_edge]
            mov ecx, [edx + 4 * ecx]
            mov edx, [edges]
            mov edx, [edx + 4 * ecx]
            mov eax, [s]
            xor ebx, ebx
            mov ecx, [esi]
            mov bl, [eax + ecx]
            mov edx, [edx + 4 * ebx]
            mov [current_edge], edx
        jmp jump_suflink_while
        jump_suflink_while_end:

        push dword [current_edge]
        call length
        add esp, 4
        mov ebx, edi
        sub ebx, esi
        cmp ebx, eax ; need_left-need_left ==len(current_edge)
        jne jump_suflink_if2_else
            mov edx, [too]
            mov ecx, [current_edge]
            mov edx, [edx + 4 * ecx]
            mov [current_vertex], edx
            
            mov dword [current_edge], -1
            cmp dword [last_vertex], -1
            je jump_suflink_if3_fin
                ; suf[last_vertex] = current_vertex
                mov edx, [suf]
                mov ecx, [last_vertex]
                lea edx, [edx + 4 * ecx]
                mov ecx, [current_vertex]
                mov [edx], ecx
                
                mov dword [last_vertex], -1
            jump_suflink_if3_fin:
            jmp jump_suflink_if2_fin
        jump_suflink_if2_else:
            mov dword [current_vertex], -1
            mov eax, edi
            sub eax, esi
            mov [depth], eax
        jump_suflink_if2_fin:
    jump_suflink_fin:
    popa
    ret

; cdecl go(ch)
go:
    cmp dword [current_vertex], -1
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
    cmp dword [current_edge], -1
    jz go_if1_fin
        inc dword [depth]
    go_if1_fin:

    ; if (current_edge != -1) && left[current_edge] + depth == right[current_edge]
    cmp dword [current_edge], -1
    jz go_fin
    ; left[current_edge] + depth
    mov edx, [left]
    mov eax, [current_edge]
    mov edx, [edx + 4 * eax]
    add edx, [depth]
    ; right[current_edge]
    mov ecx, [right]
    mov ecx, [ecx + 4 * eax]
    cmp ecx, edx
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
    call print_stats
    ret

; cdecl suffix_tree()
suffix_tree:
    ; hell = new_vertex(-1)
    push dword -1
    call new_vertex
    add esp, 4
    mov [hell], eax
    ; rooot = new_vertex(0)
    push dword 0
    call new_vertex
    add esp, 4
    mov [rooot], eax
    
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

    ; new_edge2(hell, rooot, -1, 0)
    push dword 0
    push dword -1
    push dword [rooot]
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
    ; suf[rooot] = hell
    push ecx
    mov ecx, [rooot]
    pop dword [edx + 4 * ecx]
    call print_stats
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

; cdecl traverse2(v)
traverse2:
    push ebx
    mov ebx, 26
    traverse2_loop:
        dec ebx
        mov edx, [edges]
        mov ecx, [esp + 8]
        mov edx, [edx + 4 * ecx]
        mov edx, [edx + 4 * ebx]
        cmp edx, -1
        je traverse_if_fin
            push edx
            push edx
            call length
            add esp, 4
            add [ans], eax
            dec dword [ans]
            pop edx
            mov ecx, [too]
            mov edx, [ecx + 4 * edx]
            push edx
            call traverse2
            add esp, 4
        traverse_if_fin: 
        test ebx, ebx
        jz traverse2_loop_fin
    jmp traverse2_loop        
    traverse2_loop_fin:
    pop ebx
    ret

; cdecl traverse()
traverse:
    push dword [rooot]
    call traverse2
    add esp, 4
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
    
    call traverse
    
    push dword [ans]
    push formatInt
    call printf
    add esp, 8

    xor eax, eax
    ret
