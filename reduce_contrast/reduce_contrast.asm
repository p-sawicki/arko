section .TEXT
	global reduce_contrast
reduce_contrast:
	push ebp
	mov ebp, esp

	mov eax, [ebp + 12] ; rfactor
	mov ecx, 128 
	sub ecx, eax ; 1 - rfactor / 128
	mov edx, ecx
	shl ecx, 16
	or ecx, edx ; 2 words of (1 - rfactor / 128)

	mov edx, 0x00800080 ; 2 words of 128
	movd xmm1, edx
	pshufd xmm1, xmm1, 0 ; 8 words of 128

	movd xmm2, ecx	
	pshufd xmm2, xmm2, 0 ; 8 words of (1 - rfactor / 128)

	pxor xmm0, xmm0

	mov edx, [ebp + 8] ; file buffer
	mov eax, [edx + 34] ; pixel data size
	add edx, [edx + 10] ; pixel data offset
loop:
	cmp eax, 4
	jl fin

	movd xmm3, [edx] ; get 4 bytes
	cmp eax, 16
	jl too_short

	movdqu xmm3, [edx] ; get 16 bytes if possible
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
	movd [edx], xmm4
	add edx, 4
	sub eax, 4
	jmp loop
next_eight_bytes:
	punpckhbw xmm3, xmm0 ; high 8 bytes extended into words

	psubw xmm3, xmm1 ; pixel - 128
	pmullw xmm3, xmm2 ; (1 - rfactor / 128) * (pixel - 128)
	psraw xmm3, 7
	paddw xmm3, xmm1 ; (1 - rfactor / 128) * (pixel - 128) + 128

	packuswb xmm4, xmm3 ; convert words back into bytes
	movdqu [edx], xmm4 ; store 16 bytes
	sub eax, 16
	add edx, 16
	jmp loop	 
fin:
	mov esp, ebp
	pop ebp
	ret
