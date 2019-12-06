	.data
buf:	.space 100
	.text
	.globl main
main:
	la $a0, buf
	li $a1, 100
	li $v0, 8
	syscall
	
	la $t0, buf #current char pointer
	li $t1, 0 #flag if prev char is digit
	li $t2, 0 #amount of numbers
read:
	lbu $t3, ($t0) #current char
	bltu $t3, ' ', fin
	bltu $t3, '0', notdigit
	bgtu $t3, '9', notdigit
	beq $t1, 1, flag
	addiu $t2, $t2, 1
flag:
	li $t1, 1
	b next
notdigit:
	li $t1, 0
next:
	addiu $t0, $t0, 1
	b read
fin:
	li $v0, 1
	move $a0, $t2
	syscall
	li $v0, 10
	syscall