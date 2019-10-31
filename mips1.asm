	.data
buf:	.space 100

	.text
	.globl main
main:
	la $a0, buf
	li $a1, 100
	li $v0, 8
	syscall
	
	la $t0, buf
	li $t1, '9'
swap:
	lbu $t2, ($t0)
	blt $t2, ' ', fin
	blt $t2, '0', next
	bgt $t2, '9', next
	subu $t2, $t1, $t2
	addiu $t2, $t2, '0'
	sb $t2, ($t0)
next:
	addiu $t0, $t0, 1
	b swap
fin:
	la $a0, buf
	li $v0, 4
	syscall