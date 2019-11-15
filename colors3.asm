	#based on algorithm from https://stackoverflow.com/questions/3407942/rgb-values-of-visible-spectrum/22681410 by Andrey
	#assuming 1024 max width and 1024 max height
	.data
mes0:	.asciiz "Height [1..1024]: "
mes1:	.asciiz "Width [3..1024]: "
	.text
	.globl main
main:
	li $v0, 4
	la $a0, mes0
	syscall
	li $v0, 5
	syscall
	move $t7, $v0 #height
	bltu $t7, 1, fin
	bleu $t7, 1024, skip0
	li $t7, 1024
skip0:
	li $v0, 4
	la $a0, mes1
	syscall
	li $v0, 5
	syscall
	move $t6, $v0 #width
	bltu $t6, 3, fin
	bleu $t6, 1024, skip1
	li $t6, 1024
skip1:
	li $s0, 255 #wave length [nm]
	sll $s0, $t0, 16 #wave length in 16.16
	divu $t1, $s0, $t6 #nanometers per pixel
	srl $s1, $t1, 1 #2x change
	li $t8, 0x10000000 #memory pointer
	li $t9, 0 #loop counter
loop:
	srl $t0, $s0, 16
	bgeu $t9, $t6, fin
	li $t2, 0 #R
	bltu $t2, 128, green
	mulu $s2, $t9, $s1
	subu $t2, $s0, $s2
green:
	mulu $t3, $t9, $s1
	
	li $t4, 256 #B
	sll $t4, $t4, 16
	subu $t4, $t4, $s0
	bltu $t0, 128, blue
	li $s1, 512
	sll $s1, $s1, 16
	subu $t3, $s1, $t3
blue:
	
store_line:
	andi $t2, $t2, 0x00FF0000
	srl $t3, $t3, 8
	andi $t3, $t3, 0x0000FF00
	srl $t4, $t4, 16
	addu $t2, $t2, $t3
	addu $t2, $t2, $t4
	li $s1, 0 #loop2 counter
	move $s2, $t8 #temp memory pointer
loop2:
	bgeu $s1, $t7, next
	sw $t2, ($s2)
	addiu $s2, $s2, 4096
	addiu $s1, $s1, 1
	b loop2
next:
	addu $t8, $t8, 4
	addiu $t9, $t9, 1
	subu $s0, $s0, $t1
	b loop
fin:
	li $v0, 10
	syscall
