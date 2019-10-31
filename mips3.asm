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
	la $t1, buf
check:
	lbu $t2, ($t1)
	blt $t2, ' ', decr
	addiu $t1, $t1, 1
	b check
decr:
	subiu $t1, $t1, 1
movee:
	ble $t1, $t0, fin
	lbu $t2, ($t0)
	lbu $t3, ($t1)
	blt $t2, '0', nodigb
	bgt $t2, '9', nodigb
	blt $t3, '0', nodige
	bgt $t3, '9', nodige
	sb $t2, ($t1)
	sb $t3, ($t0)
	addiu $t0, $t0, 1
	subiu $t1, $t1, 1
	b movee
nodigb:
	addiu $t0, $t0, 1
	b movee
nodige:
	subiu $t1, $t1, 1
	b movee
fin:
	la $a0, buf
	li $v0, 4
	syscall
	li $v0, 10
	syscall
