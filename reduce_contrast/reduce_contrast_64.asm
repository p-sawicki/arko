section .TEXT
	global reduce_contrast
reduce_contrast:
	push rbp
	mov rbp, rsp
	shl esi, 1 ; rfactor / 128 in 8.8
	mov ecx, 256
	sub ecx, esi; 1 - rfactor / 128
	mov eax, ecx
	shl ecx, 16
	or ecx, eax; 2 words of (1 - rfactor / 128)
	mov edx, [rdi + 18] ; image width
	add edx, 3 
	and edx, 0xFFFFFFFC; image width rounded to mul of 4
	mov eax, [rdi + 22] ; image height
	mul edx ; pixel amount
	lea eax, [eax + eax * 2] ; 3 bytes per pixel
	xor rdx, rdx
	mov edx, [rdi + 10]
	add rdi, rdx ; pixel data offset
	mov edx, 0x00800080 ; 2 words of 128
	movd xmm1, edx
	pshufd xmm1, xmm1, 0 ; 8 words of 128
	movd xmm2, ecx	
	pshufd xmm2, xmm2, 0 ; 8 words of (1 - rfactor / 128)
	pxor xmm0, xmm0
loop:
	test eax, eax
	je fin
	movd xmm3, [rdi] ; get 4 bytes
	cmp eax, 16
	jl too_short
	movdqu xmm3, [rdi] ; get 16 bytes if possible
too_short:
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
	cmp eax, 16
	jge next_eight_bytes
	packuswb xmm5, xmm0 ; convert words to bytes
	movd [rdi], xmm5
	add rdi, 4
	sub eax, 4
	jmp loop
next_eight_bytes:
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
	movdqu [rdi], xmm5 ; store 16 bytes
	sub eax, 16
	add rdi, 16
	jmp loop	 
fin:
	mov rsp, rbp
	pop rbp
	ret
