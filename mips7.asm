	.data
buf:	.space 100
err:	.asciiz "Incorrect input, try again."
	.text
	.globl main
main:
	li $v0, 8
	la $a0, buf
	li $a1, 100
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0 #start to delete
	
	li $v0, 5
	syscall
	move $t1, $v0 #amount of chars to del
	
	bltz $t0, excpt
	bgt $t0, 99, excpt
	bltz $t1, excpt
	
	la $t2, buf #write pointer
position_write:
	beqz $t0, delete
	lbu $t3, ($t2)
	bltu $t3, ' ', fin
	addiu $t2, $t2, 1
	subiu $t0, $t0, 1
	b position_write
delete:
	move $t4, $t2 #read pointer
pos:
	beqz $t1, write
	lbu $t3, ($t4)
	bltu $t3, ' ', fin
	addiu $t4, $t4, 1
	subiu $t1, $t1, 1
	b pos
write:
	lbu $t3, ($t4)
	bltu $t3, ' ', fin
	sb $t3, ($t2)
	addiu $t2, $t2, 1
	addiu $t4, $t4, 1
	b write
excpt:
	li $v0, 4
	la $a0, err
	syscall
	b end
fin:
	sb $zero, ($t2)
	li $v0, 4
	la $a0, buf
	syscall
end:
	li $v0, 10
	syscall