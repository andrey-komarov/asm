extern printf

section .data
	format db "%d",0

section .text
	global main

main:
	xor eax, eax

	l:
	inc eax
	
	push eax
	push format
	call printf
	add esp, 8
	
;	cmp eax, 0
;	jz end
	
	jmp l

	end:
	ret
