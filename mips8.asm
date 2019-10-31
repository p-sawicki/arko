	.data
buf:	.space 100
	.text
	.globl main
main:
	li $v0, 8
	la $a0, buf
	li $a1, 100
	syscall
	
	la $t0, buf #string pointer
	li $t1, 0 #counter
loop:
	lbu $t2, ($t0) #current char
	bltu $t2, ' ', fin
	bltu $t2, 'a', next
	bgtu $t2, 'z', next
	beqz $t1, capitalize
	subiu $t1, $t1, 1
	b next
capitalize:
	subiu $t2, $t2, 0x20
	sb $t2, ($t0)
	li $t1, 2
next:
	addiu $t0, $t0, 1
	b loop
fin:
	li $v0, 4
	la $a0, buf
	syscall
	li $v0, 10
	syscall