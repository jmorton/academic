
	.data
MoveFrom:	.asciiz "Move disk from "
To:			.asciiz " to "
A:			.asciiz "A"
B:			.asciiz "B"
C:			.asciiz "C"
LF:			.asciiz "\n"

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
# hanoi(4, "a", "c", "b");
# 

# This hanoi solution doesn't keep track of the individual disks.
# It merely displays the instructions for moving them.

	.globl main
	.text
	
main:
	li $a0, 1 # the number of disks
	la $a1, A # source peg
	la $a2, C # destination peg
	la $a3, B # temporary peg
	jal hanoi
	jal exit
	
# let $a0 be the number of disks
# let $a1, $a2, $a3 be pegs a, b, c

hanoi:
	  bgt $a0, 1, recurse
	  
	  # set parameters for call to puts and invoke
	  move $a0, $a1
	  move $a1, $a2
	  jal puts
	  jr $ra

recurse:
	  # swap b and c for the first recursive call
	  # swap $a2, $a3
	  # jal hanoi

	  # return arguments to the original order
	  # swap $a2, $a3
	  # jal hanoi

	  # swap a and c
	  # swap $a1, $a3
	  # jal hanoi
	  jr $ra


puts:
	# store the arguments since subsequent
	# calls by puts will need to set them
	addi $t0, $a0, 0
	addi $t1, $a1, 0

	# print move from...
	li	$v0, 4
	la	$a0, MoveFrom
	syscall

	# print a
	move $a0, $t0
	syscall

	# print " to "
	la $a0, To
	syscall

	# print b
	move $a0, $t1
	syscall

	# print newline
	la  $a0, LF
	syscall

	jr $ra

exit:
	li $v0, 10 # Return control to OS
	syscall

