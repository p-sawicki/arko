section .TEXT
	global reduce_contrast
reduce_contrast:
	push ebp
	mov ebp, esp
	push ebx
	mov eax, [ebp + 12] ; rfactor
	shl eax, 1 ; rfactor / 128 in 8.8
	mov ecx, 256
	sub ecx, eax ; 1 - rfactor / 128
	mov ebx, ecx
	shl ecx, 16
	or ecx, ebx ; 2 words of (1 - rfactor / 128)
	mov ebx, [ebp + 8] ; file buffer
	mov edx, [ebx + 18] ; image width
	and edx, 3 ; image width % 4
	add edx, [ebx + 18] ; image width rounded up to mul of 4
	mov eax, [ebx + 22] ; image height
	mul edx ; pixel amount
	lea eax, [eax + eax * 2] ; 3 bytes per pixel
	add ebx, [ebx + 10] ; pixel data offset
	mov edx, 0x00800080 ; 2 words of 128
	movd xmm1, edx
	pshufd xmm1, xmm1, 0 ; 8 words of 128
	movd xmm2, ecx	
	pshufd xmm2, xmm2, 0 ; 8 words of (1 - rfactor / 128)
	pxor xmm0, xmm0
loop:
	cmp eax, 16
	jl too_short
	movdqu xmm3, [ebx] ; get 16 bytes
	movdqu xmm4, xmm3
	punpcklbw xmm4, xmm0 ; low 8 bytes extended into words
	movdqu xmm5, xmm4
	pcmpgtw xmm5, xmm1 ; mask for words > 128
	movdqu xmm6, xmm4 ; words > 128
	psubw xmm6, xmm1 ; pixel - 128
	pmullw xmm6, xmm2 ; (1 - rfactor / 128) * (pixel - 128)
	psrlw xmm6, 8
	paddw xmm6, xmm1 ; (1 - rfactor / 128) * (pixel - 128) + 128
	movdqu xmm7, xmm1 ; words <= 128 in xmm4
	psubw xmm7, xmm4 ; 128 - pixel
	pmullw xmm7, xmm2 ; (1 - rfactor / 128) * (128 - pixel)
	psrlw xmm7, 8
	movdqu xmm4, xmm1
	psubw xmm4, xmm7 ; 128 - (1 - rfactor / 128) * (128 - pixel)
	pand xmm6, xmm5 ; words > 128
	pandn xmm5, xmm4 ; words <= 128
	por xmm5, xmm6 ; all words

	punpckhbw xmm3, xmm0 ; high 8 bytes extended into words
	movdqu xmm4, xmm3
	pcmpgtw xmm4, xmm1 ; mask for words > 128
	movdqu xmm6, xmm3 ; words > 128
	psubw xmm6, xmm1 ; pixel - 128
	pmullw xmm6, xmm2 ; (1 - rfactor / 128) * (pixel - 128)
	psrlw xmm6, 8
	paddw xmm6, xmm1 ; (1 - rfactor / 128) * (pixel - 128) + 128
	movdqu xmm7, xmm1 ; words <= 128 in xmm3
	psubw xmm7, xmm3 ; 128 - pixel
	pmullw xmm7, xmm2 ; (1 - rfactor / 128) * (128 - pixel)
	psrlw xmm7, 8
	movdqu xmm3, xmm1
	psubw xmm3, xmm7 ; 128 - (1 - rfactor / 128) * (128 - pixel)
	pand xmm6, xmm4 ; words > 128
	pandn xmm4, xmm3 ; words <= 128
	por xmm4, xmm6 ; all words

	packuswb xmm5, xmm4 ; convert words back into bytes
	movdqu [ebx], xmm5 ; store 16 bytes
	sub eax, 16
	add ebx, 16
	jmp loop	 
too_short:
	push edi
	mov edi, eax
loop2:
	test edi, edi
	je fin
	movzx ax, [ebx]
	cmp ax, 128
	jle less
	sub ax, 128
	mul cx
	shr ax, 8
	add ax, 128
	jmp next
less:
	mov dx, ax
	mov ax, 128
	sub ax, dx
	mul cx
	shr ax, 8
	mov dx, ax
	mov ax, 128		
	sub ax, dx
next:
	mov [ebx], al
	inc ebx
	dec edi
	jmp loop2
fin:
	pop edi
	pop ebx
	mov esp, ebp
	pop ebp
	ret
