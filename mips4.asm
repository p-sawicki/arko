	.data
buf:	.space 100

	.text
	.globl main
main:	
	la $a0, buf
	li $a1, 100
	li $v0, 8
	syscall
	
	la $t0, buf #string buffer
	la $t1, buf #last beg of digits
	la $t2, buf #beg of longest digit seq
	li $t3, 0 #length of current beg of digits
	li $t4, 0 #length of longest digit seq
scan:
	lbu $t5, ($t0) #current byte
	blt $t5, ' ', fin
	blt $t5, '0', ndg
	bgt $t5, '9', ndg
	addiu $t3, $t3, 1
	beq $t3, 1, nwseq
	blt $t3, $t4, next
	beq $t3, $t4, check
nwlngst:
	move $t2, $t1
	move $t4, $t3
	b next
check:
	move $t5, $t1
	move $t6, $t2
	move $t7, $t3
loop:
	beqz $t7, next
	lbu $t8, ($t5)
	lbu $t9, ($t6)
	bgt $t8, $t9, nwlngst
	blt $t8, $t9, next
	addiu $t5, $t5, 1
	addiu $t6, $t6, 1
	subiu $t7, $t7, 1
	b loop
nwseq:
	move $t1, $t0
	b next
ndg:
	li $t3, 0
next:
	addiu $t0, $t0, 1
	b scan
fin:
	addu $t5, $t2, $t4
	sb $zero, ($t5)
	li $v0, 4
	la $a0, ($t2)
	syscall
	li $v0, 10
	syscall