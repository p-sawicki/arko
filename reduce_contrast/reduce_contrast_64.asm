section .TEXT
	global reduce_contrast
reduce_contrast:
	push rbp
	mov rbp, rsp

	mov ecx, 128
	sub ecx, esi; 1 - rfactor / 128
	mov eax, ecx
	shl ecx, 16
	or ecx, eax; 2 words of (1 - rfactor / 128)

	mov edx, 0x00800080 ; 2 words of 128
	movd xmm1, edx
	pshufd xmm1, xmm1, 0 ; 8 words of 128

	movd xmm2, ecx	
	pshufd xmm2, xmm2, 0 ; 8 words of (1 - rfactor / 128)

	pxor xmm0, xmm0

	mov eax, [rdi + 34] ; pixel data size
	xor rdx, rdx
	mov edx, [rdi + 10]
	add rdi, rdx ; pixel data offset
loop:
	cmp eax, 4
	jl fin

	movd xmm3, [rdi] ; get 4 bytes
	cmp eax, 16
	jl too_short

	movdqu xmm3, [rdi] ; get 16 bytes if possible
too_short:
	movdqu xmm4, xmm3
	punpcklbw xmm4, xmm0 ; low 8 bytes extended into words

	psubw xmm4, xmm1 ; pixel - 128
	pmullw xmm4, xmm2 ; (1 - rfactor / 128) * (pixel - 128)
	psraw xmm4, 7
	paddw xmm4, xmm1 ; (1 - rfactor / 128) * (pixel - 128) + 128

	cmp eax, 16
	jge next_eight_bytes

	packuswb xmm4, xmm0 ; convert words to bytes
	movd [rdi], xmm4
	add rdi, 4
	sub eax, 4
	jmp loop
next_eight_bytes:
	punpckhbw xmm3, xmm0 ; high 8 bytes extended into words

	psubw xmm3, xmm1 ; pixel - 128
	pmullw xmm3, xmm2 ; (1 - rfactor / 128) * (pixel - 128)
	psraw xmm3, 7
	paddw xmm3, xmm1 ; (1 - rfactor / 128) * (pixel - 128) + 128

	packuswb xmm4, xmm3 ; convert words back into bytes
	movdqu [rdi], xmm4 ; store 16 bytes
	sub eax, 16
	add rdi, 16
	jmp loop	 
fin:
	mov rsp, rbp
	pop rbp
	ret
