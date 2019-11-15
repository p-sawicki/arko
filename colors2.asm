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
	li $t0, 650 #wave length [nm]
	sll $s0, $t0, 16 #wave length in 16.16
	li $t1, 270 #spectrum length [nm]
	sll $t1, $t1, 16
	subu $s1, $t6, 1
	divu $t1, $t1, $s1 #nanometers per pixel
	li $t8, 0x10000000 #memory pointer
	li $t9, 0 #loop counter
loop:
	srl $t0, $s0, 16
	bgeu $t9, $t6, fin
	li $t2, 0 #R
	li $t3, 0 #G
	li $t4, 0 #B
	bgeu $t0, 580, Requals1
	bgeu $t0, 510, R
	bgeu $t0, 440, green
	li $t2, 440
	sll $t2, $t2, 16
	subu $t2, $t2, $s0
	divu $t2, $t2, 60
	b green
R:
	li $t2, 510
	sll $t2, $t2, 16
	subu $t2, $s0, $t2
	divu $t2, $t2, 70
	b green
Requals1:
	li $t2, 0x00010000
green:
	bgeu $t0, 645, blue
	bgeu $t0, 580, G1
	bgeu $t0, 490, Gequals1
	bgeu $t0, 440, G0
	b blue
G0:
	li $t3, 440
	sll $t3, $t3, 16
	subu $t3 $s0, $t3
	divu $t3, $t3, 50
	b blue
G1:
	li $t3, 645
	sll $t3, $t3, 16
	subu $t3, $t3, $s0
	divu $t3, $t3, 65
	b blue
Gequals1:
	li $t3, 0x00010000
blue:
	bgeu $t0, 510, store_line
	bgeu $t0, 490, B
	li $t4, 0x00010000
	b store_line
B:
	li $t4, 510
	sll $t4, $t4, 16
	subu $t4, $t4, $s0
	divu $t4, $t4, 20 
store_line:
	mulu $t2, $t2, 255
	mulu $t3, $t3, 255
	mulu $t4, $t4, 255
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
