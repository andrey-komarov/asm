extern printf

section .data
	format db "%s",0
	buffer db 0,0,0,0,0,0,0,0,0,0,0,0

section .text
	global main

itoa: 
	mov eax, [esp + 8]
	xor ecx, ecx

	push ebx
	mov ebx, 10

	; запись числа по цифрам в стек
	l1:
	xor edx, edx
	div ebx
	inc ecx ; циферок стало на одну больше
	push edx ; запихать циферку
	test eax, eax
	jnz l1 ; если число закончилось, выйти

	mov edx, [esp + ecx * 4 + 8]
	l2:
	pop dword ebx
	add bl, '0'
	mov [edx], bl
	inc edx
	dec ecx
	test ecx, ecx
	jnz l2

	mov byte [edx], 0

	pop ebx

	ret 8

main:
	nop 
	nop
	nop

	mov eax, buffer

	push -10
	push buffer
	call itoa

	push buffer
	push format
	call printf
	add esp, 8 
    
	mov eax, 0
	ret    
