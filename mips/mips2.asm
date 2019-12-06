	.data
buf:	.space 100

	.text
	.globl main
	
main:
	la $a0, buf
	li $a1, 100
	li $v0, 8
	syscall
	
	la $t0, buf #pointer to current char
	la $t1, buf #pointer to beg of longest chain
	li $t2, 0 #current chain length
	li $t3, 0 #longest chain length
check:
	lbu $t4, ($t0) #current char
	blt $t4, ' ', fin
	blt $t4, '0', nodig
	bgt $t4, '9', nodig
	addiu $t2, $t2, 1
	bleu $t2, $t3, next
	subu $t1, $t0, $t2
	addiu $t1, $t1, 1
	move $t3, $t2
	b next
nodig:
	move $t2, $zero
next:
	addiu $t0, $t0, 1
	b check
fin:
	addu $t2, $t1, $t3
	sb $zero, ($t2)
	la $a0, ($t1)
	li $v0, 4
	syscall