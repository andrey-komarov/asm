extern printf

section .data
    format db "%d",0

section .text
    global main



fact: ; стек очищает сама функция
    mov ecx, [esp + 4] ; аргумент во врем. переменную
    
    test ecx, ecx ; если 0, то возвращаем 1
    jnz notzero 

    mov eax, 1 ; база рекурсии
    ret 4

    notzero:
    mov eax, ecx ; вычитаем 1
    sub eax, 1
    push eax ; пихаем аргумент - 1 нa стек   
    
    call fact ; вызывает рекурсивно
   
    mov ecx, [esp + 4] 
    mul ecx ; умножает на текущий аргумент
    
    ret 4 

main:
	push 10
	call fact

    push eax
    push format
    call printf
    add esp, 8 
    
    mov eax, 0
    ret    
