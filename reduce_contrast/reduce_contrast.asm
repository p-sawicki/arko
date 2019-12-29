section .TEXT
	global reduce_contrast
reduce_contrast:
	push ebp
	mov ebp, esp
	sub esp, 4
	push ebx
	mov eax, [ebp + 8] ; file buffer
	mov cx, [ebp + 12] ; rfactor
	shl cx, 1; rfactor / 128 in 8.8
	mov [ebp - 4], cx
	mov edx, [eax + 18] ; image width
	and edx, 3 ; image width % 4
	add edx, [eax + 18]
	push eax
	mov eax, [eax + 22] ; image height
	mul edx
	mov edx, eax ; image height * image width rounded to account for padding bytes
	pop eax
	lea edx, [edx + edx * 2] ; 3 bytes per pixel	
	add eax, [eax + 10] ; pixel data offset
	vpxor ymm0, ymm0, ymm0
	mov bx, 256
	sub bx, cx
	mov cx, bx
	xor ebx, ebx
	mov [ebp - 2], word 128
	vpbroadcastw ymm5, [ebp - 4] ; rfactor / 128 in every word
	vpbroadcastw ymm4, [ebp - 2] ; 128 in every word
loop:
	vpmovzxbw ymm1, [eax] ; converts 16 bytes to words
	vpcmpgtw ymm2, ymm1, ymm4 ; mask for words greater than 128
	vpand ymm3, ymm1, ymm2 ; >128	
	vpsubw ymm3, ymm3, ymm4
	vpmullw ymm3, ymm3, ymm5
	vpsrlw ymm3, ymm3, 8
	vpaddw ymm3, ymm3, ymm4
	vpsubw ymm1, ymm4, ymm1
	vpmullw ymm1, ymm1, ymm5
	vpsrlw ymm1, ymm1, 8
	vpsubw ymm1, ymm4, ymm1
	vpandn ymm1, ymm2, ymm1
	vpand ymm3, ymm3, ymm2
	vpaddw ymm1, ymm1, ymm3
	vpmovzxbw ymm6, [eax + 16]
	vpcmpgtw ymm2, ymm6, ymm4
	vpand ymm3, ymm6, ymm2
	vpsubw ymm3, ymm3, ymm4
	vpmullw ymm3, ymm3, ymm5
	vpsrlw ymm3, ymm3, 8
	vpaddw ymm3, ymm3, ymm4
	vpsubw ymm6, ymm4, ymm6
	vpmullw ymm6, ymm6, ymm5
	vpsrlw ymm6, ymm6, 8
	vpsubw ymm6, ymm4, ymm6
	vpandn ymm6, ymm2, ymm6
	vpand ymm3, ymm3, ymm2
	vpaddw ymm6, ymm6, ymm3
	vpackuswb ymm1, ymm1, ymm6
	vpermq ymm1, ymm1, 0xD8	
	vmovdqu [eax], ymm1
	add eax, 16 
	add ebx, 16 
	cmp ebx, edx 
	jl loop
fin:
	pop ebx
	mov esp, ebp
	pop ebp
	ret	
