	.data
buf:	.space 100
	.text
	.globl main
main:
	li $v0, 8
	la $a0, buf
	li $a1, 100
	syscall
	
	la $t0, buf #read pointer
	la $t1, buf #write pointer
work:
	lbu $t2, ($t0)
	bltu $t2, ' ', fin
	bltu $t2, '0', notdigit
	bgtu $t2, '9', notdigit
next:
	addiu $t0, $t0, 1
	b work
notdigit:
	sb $t2, ($t1)
	addiu $t1, $t1, 1
	b next
fin:
	sb $zero, ($t1)
	li $v0, 4
	la $a0, buf
	syscall
	li $v0, 10
	syscall