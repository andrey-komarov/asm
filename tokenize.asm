extern printf

section .data
	format db "%d",10,0
	args db '  ""  A" "B   " A B "C   A"B"C" "D"" A""""B         ',0

section .text
	global main
	
skip_spaces:
	mov eax, [esp + 4]
	
	skip_spaces_loop:
	cmp byte [eax], ' '
	jne skip_spaces_finish
	inc eax
	jmp skip_spaces_loop

	skip_spaces_finish:
	ret 4

skip_token: 
	mov eax, [esp + 4]

	mov bl, ' '
	skip_token_loop:
	cmp byte [eax], 0
	je skip_token_finish
		cmp byte [eax], '"'
		jne skip_token_l1
		xor bl, 2 ; 2 = '"' ^ ' '
		inc eax
		jmp skip_token_loop
		skip_token_l1:
		inc eax
	cmp [eax - 1], bl
	je skip_token_finish
	jmp skip_token_loop

	skip_token_finish:
	ret 4


parse: ; char*
	xor eax, eax ; eax --- ответ
	xor ecx, ecx
	mov edx, [esp + 4] ; edx --- указатель на текущий символ в строке

	parse_loop:
	push eax
	
	push edx
	call skip_spaces
	
	mov edx, eax
	mov cl, [edx]

	test cl, cl
	jz _out

	push edx
	call skip_token

	mov edx, eax

	pop eax
	inc eax
	jmp parse_loop
	_out:

	pop eax

	ret 4


main:
	nop
	nop
	nop

	push args
	call parse

	push eax
	push format 
	call printf
	add esp, 8
    
	mov eax, 0
	ret    
