
	.data
str:	.asciiz "\n"
str1:	.asciiz "Original Array\n"
str2:	.asciiz "Sorted Array\n"

	.text
main:	subu	$sp,$sp,32
	sw	$ra,20($sp)
	
	
	la	$t0,A 
	li	$t1,20
	mulou	$t3,$t1,4
	add	$t3,$t3,$t0
	move	$t2,$0
loop1:	sw	$t1,0($t0)
	addi	$t1,$t1,-1
	addi	$t0,$t0,4
	slt	$t4,$t0,$t3
	bne	$t4,$0,loop1
	
	li	$v0,4
	la	$a0,str1
	syscall
	li	$s1,80
	move	$s0,$0
loop2:	li	$v0,1
	lw	$a0,A($s0)
	syscall
	li	$v0,4
	la	$a0,str
	syscall
	addi	$s0,$s0,4
	slt	$t4,$s0,$s1
	bne	$t4,$0,loop2
	li	$v0,4
	la	$a0,str
	syscall
	
	la	$a0,A
	li	$a1,20
	jal     sort
	li	$v0,4
	la	$a0,str2
	syscall
	
	li	$s1,80
	move	$s0,$0
loop3:	li	$v0,1
	lw	$a0,A($s0)
	syscall
	li	$v0,4
	la	$a0,str
	syscall
	addi	$s0,$s0,4
	slt	$t4,$s0,$s1
	bne	$t4,$0,loop3
	
	lw	$ra,20($sp)
	addu	$sp,$sp,32
	jr	$ra

sort:	addi	$29,$29,-36
	sw	$15,0($29)
	sw	$16,4($29)
	sw	$17,8($29)
	sw	$18,12($29)
	sw	$19,16($29)
	sw	$20,20($29)
	sw	$24,24($29)
	sw	$25,28($29)
	sw	$31,32($29)
	move	$18,$4
	move	$20,$5


	add	$19,$0,$0
ftst:	slt	$8,$19,$20
	beq	$8,$0,exit1
	addi	$17,$19,-1
f2tst:	slti	$8,$17,0
	bne	$8,$0,exit2
	mulou	$15,$17,4
	add	$16,$18,$15
	lw	$24,0($16)
	lw	$25,4($16)
	slt	$8,$25,$24
	beq	$8,$0,exit2

	move	$4,$18
	move	$5,$17
	jal	swap

	addi	$17,$17,-1
	j	f2tst
exit2:	addi	$19,$19,1
	j	ftst

exit1:	lw	$15,0($29)
	lw	$16,4($29)
	lw	$17,8($29)
	lw	$18,12($29)
	lw	$19,16($29)
	lw	$20,20($29)
	lw	$24,24($29)
	lw	$25,28($29)
	lw	$31,32($29)
	addi	$29,$29,36
	jr	$31

swap:	addi	$29,$29,-12
	sw	$2,0($29)
	sw	$15,4($29)
	sw	$16,8($29)
	mulou	$2,$5,4
	add	$2,$4,$2
	lw	$15,0($2)
	lw	$16,4($2)
	sw	$16,0($2)
	sw	$15,4($2)
	lw	$2,0($29)
	lw	$15,4($29)
	lw	$16,8($29)
	addi	$29,$29,12
	jr	$31

	
	.data
	.align 2
A:	.space 80
