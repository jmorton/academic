	.data
 Author:
  .ascii      "\nCS465, Computer Architecture, Fall 2010\n\n"
  .ascii      "towers of hanoi solution\n"
  .asciiz     "Author: Jonathan Morton\n"

HowMany:	.asciiz "Number of disks= "
MoveFrom:	.asciiz "Move disk from "
To:			.asciiz " to "
A:			.asciiz "A"
B:			.asciiz "B"
C:			.asciiz "C"
LF:			.asciiz "\n"
Done:		.asciiz "Finished"

# This hanoi solution doesn't keep track of the individual disks. It merely
# displays the instructions for moving them.  Pseudo (ruby) code...
#
# def hanoi(disks, a, b, c)
#	  if (disks <= 1)
#		  move = "move " + a + " to " + b + "\n"
#		  print move
#	  else
#		  hanoi(disks - 1, a, c, b)
#		  hanoi(1, a, b, c)
#		  hanoi(disks - 1, c, b, a)
#	  end
# end
# 

	.globl main
	.globl recur
	.text
	
main:
	jal prompt
	move $a0, $v0 # set the disk count
	la $a1, A # source peg name
	la $a2, C # destination peg name
	la $a3, B # temporary peg name
	jal hanoi
	jal exit
	
# $a0: number of disks
# $a1, $a2, $a3 : address of a peg name
hanoi:
	# push the return address on the stack
	addi $sp, -20
	sw $ra, 20($sp) # caller return address
	sw $a3, 16($sp) # c
	sw $a2, 12($sp) # b
	sw $a1,  8($sp) # a
	sw $a0,  4($sp) # count

	# if number of disks is greater than one, apply
	# the recursive solution
	bgt $a0, 1, recur

	# otherwise, set parameters for 'puts' call and jump
	move $a0, $a1
	move $a1, $a2
	jal puts

	# restore the return address and return to caller
	addi $sp, $sp, 20
	lw $ra, ($sp)
	jr $ra

recur:
  # initialize parameters for the first recursive call
  # move all but the bottom most disk
  r1: lw   $a0,  4($sp)
	  addi $a0, $a0, -1  # $a0 = disks - 1
	  lw   $a3, 12($sp)  # swap c with b
	  lw   $a2, 16($sp)  # swap b with c
	  jal  hanoi

  # move the bottom most disk
  r2: li  $a0,  1
	  lw  $a1,  8($sp)
	  lw  $a2, 12($sp)
	  lw  $a3, 16($sp)
	  jal hanoi

  # initialize parameters for the last recursive call
  # move the originally moved disks to destination
  r3: lw   $a0,  4($sp)
	  addi $a0, $a0, -1  # $a0 = disks - 1
	  lw   $a1, 16($sp)  # swap a with c
	  lw   $a2, 12($sp)  # use original b for b
	  lw   $a3,  8($sp)  # swap c with a
	  jal hanoi

  # return to caller
	  addi $sp, $sp, 20
	  lw   $ra, 0($sp)
	  jr   $ra

puts:
	# store the arguments since syscalls require overwriting them
	addi $t0, $a0, 0
	addi $t1, $a1, 0

	li	$v0, 4 # print values in an address
	la	$a0, MoveFrom
	syscall # print move from...
	move $a0, $t0
	syscall # print param a
	la $a0, To
	syscall # print " to "
	move $a0, $t1
	syscall # print param b
	la  $a0, LF
	syscall # print newline
	jr $ra
	
prompt:
	li $v0, 4
	la $a0, HowMany
	syscall    # prompt for input
    li $v0, 5  # get input
    syscall    # $v0 is set to entered value
	jr $ra

exit:
	li	$v0, 4
	la	$a0, Done
	li $v0, 10 # Return control to OS
	syscall
