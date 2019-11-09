	.data
mes0:	.asciiz "Height [1..512]: "
mes1:	.asciiz "Width [3..512]: "
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
	bleu $t7, 512, skip0
	li $t7, 512
skip0:
	li $v0, 4
	la $a0, mes1
	syscall
	li $v0, 5
	syscall
	move $t6, $v0 #width
	bltu $t6, 1, fin
	bleu $t6, 512, skip1
	li $t6, 512
skip1:
	li $t0, 700 #wave length [nm]
	sll $s0, $t0, 16 #wave length in 16.16
	li $t1, 301 #spectrum length [nm]
	sll $t1, $t1, 16
	divu $t1, $t1, $t7 #nanometers per pixel
	li $t8, 0x10010000 #memory pointer
	li $t9, 0 #loop counter
loop:
	srl $t0, $s0, 16
	bgeu $t0, 400, skip2
	li $t0, 400
skip2:
	bgeu $t9, $t7, fin
	li $t2, 0 #R
	li $t3, 0 #G
	li $t4, 0 #B
	li $t5, 0 #t
	bgeu $t0, 650, R3
	bgeu $t0, 595, R2
	bgeu $t0, 545, R1
	bgeu $t0, 476, green
	bgeu $t0, 410, R0
	li $s1, 400
	sll $s1, $s1, 16
	subu $t5, $s0, $s1
	li $s1, 10
	divu $t5, $t5, $s1
	li $s1, 21627 #approx. 0.33 in 16.16
	mulu $t2, $t5, $s1
	srl $t2, $t2, 16
	li $s1, 13107 #approx. 0.2 in 16.16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	subu $t2, $t2, $s1
	b green
R0:
	li $s1, 410
	sll $s1, $s1, 16
	subu $t5, $s0, $s1
	li $s1, 65
	divu $t5, $t5, $s1
	li $t2, 9175 #approx. 0.14 in 16.16
	li $s1, 8520 #approx. 0.13 in 16.16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	subu $t2, $t2, $s1
	b green
R1:
	li $s1, 545
	sll $s1, $s1, 16
	subu $t5, $s0, $s1
	li $s1, 50
	divu $t5, $t5, $s1
	li $s1, 129761 #approx. 1.98 in 16.16
	mulu $t2, $s1, $t5
	srl $t2, $t2, 16
	mulu $s1, $t5, $t5
	srl $s1, $s1, 16
	subu $t2, $t2, $s1
	b green
R2:
	li $s1, 595
	sll $s1, $s1, 16
	subu $t5, $s0, $s1
	li $s1, 65
	divu $t5, $t5, $s1
	li $t2, 64225 #approx. 0.98 in 16.16
	li $s1, 3932 #approx. 0.06 in 16.16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	addu $t2, $t2, $s1
	li $s1, 26214 #approx 0.4 in 16.16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	subu $t2, $t2, $s1
	b green
R3:
	li $s1, 650
	sll $s1, $s1, 16
	subu $t5, $s0, $s1
	li $s1, 50
	divu $t5, $t5, $s1
	li $t2, 42598 #approx 0.65 in 16.16
	li $s1, 55050 #approx 0.84 in 16.16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	subu $t2, $t2, $s1
	li $s1, 13107 #0.2
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	addu $t2, $t2, $s1
green:
	bgeu $t0, 640, blue
	bgeu $t0, 585, G2
	bgeu $t0, 475, G1
	bgeu $t0, 415, G0
	b blue
G0:
	li $s1, 415
	sll $s1, $s1, 16
	subu $t5, $s0, $s1
	li $s1, 60
	divu $t5, $t5, $s1
	li $s1, 52429 #0.8
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	mulu $t3, $s1, $t5
	srl $t3, $t3, 16
	b blue
G1:
	li $s1, 475
	sll $s1, $s1, 16
	subu $t5, $s0, $s1
	li $s1, 115
	divu $t5, $t5, $s1
	li $t3, 52439 #0.8
	li $s1, 49807 #0.76
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	addu $t3, $t3, $s1
	li $s1, 52439 #0.8
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	subu $t3, $t3, $s1
	b blue
G2:
	li $s1, 585
	sll $s1, $s1, 16
	subu $t5, $s0, $s1
	li $s1, 54
	divu $t5, $t5, $s1
	li $t3, 55050 #0.84
	li $s1, 54050 #0.83
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	subu $t3, $t3, $s1
blue:
	bgeu $t0, 561, store_line
	bgeu $t0, 475, B0
	li $s1, 400
	sll $s1, $s1, 16
	subu $t5, $s0, $s1
	li $s1, 75
	divu $t5, $t5, $s1
	li $s1, 144179 #2.2
	mulu $t4, $s1, $t5
	srl $t4, $t4, 16
	li $s1, 98304 #1.5
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	subu $t4, $t4, $s1
	b store_line
B0:
	li $s1, 475
	sll $s1, $s1, 16
	subu $t5, $s0, $s1
	li $s1, 85
	divu $t5, $t5, $s1
	li $t4, 46875 #0.7
	subu $t4, $t4, $t5
	li $s1, 19661 #0.3
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	mulu $s1, $s1, $t5
	srl $s1, $s1, 16
	addu $t4, $t4, $s1
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
	bgeu $s1, $t6, next
	sw $t2, ($s2)
	addiu $s2, $s2, 4
	addiu $s1, $s1, 1
	b loop2
next:
	addu $t8, $t8, 2048
	addiu $t9, $t9, 1
	subu $s0, $s0, $t1
	b loop
fin:
	li $v0, 10
	syscall
