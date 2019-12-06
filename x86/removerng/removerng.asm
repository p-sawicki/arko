SECTION .TEXT
	global removerng

removerng:
	push ebp
	mov ebp,esp

	mov eax,[ebp+8];source pointer	
	mov ecx,[ebp+8];destination pointer
loop:
	mov dl,[eax];current character
	cmp dl,0
	jz fin
	cmp dl,[ebp+12]
	jl skip
	cmp dl,[ebp+16]
	jg skip
	add eax,1
	jmp loop
skip:
	mov [ecx],dl
	add eax,1
	add ecx,1
	jmp loop
fin:	
	mov [ecx],byte 0
	mov eax,[ebp+8]
	mov esp,ebp
	pop ebp
	ret
