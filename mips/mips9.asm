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
	li $t2, 0 #if last char was capital letter
loop:
	lbu $t3, ($t0) #current char
	bltu $t3, ' ', fin
	bltu $t3, 'A', no_cap
	bgtu $t3, 'Z', no_cap
	beq $t2, 1, no_write
	li $t2, 1
	b next
no_cap:
	li $t2, 0
next:
	sb $t3, ($t1)
	addiu $t1, $t1, 1
no_write:
	addiu $t0, $t0, 1
	b loop
fin:
	sb $zero, ($t1)
	li $v0, 4
	la $a0, buf
	syscall
	li $v0, 10
	syscall