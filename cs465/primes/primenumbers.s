   
   .data
 Author:
  .ascii      "\nCS465, Computer Architecture, Fall 2010\n\n"
  .ascii      "spim successive integer counting program\n"
  .ascii      "Author: Jon Morton (implemented prime check)\n"
  .asciiz     "Original Author: Huzefa Rangwala (provided outline)\n"
  
Success1:
  .asciiz     "\nYES, the number is prime.\n"

Success2_start:
  .asciiz     "\nNO, the number is not prime but "

Success2_end:
.asciiz       " is.\n"

Prompt:  
  .asciiz      "\nPlease enter the input number: "

Result:
   .asciiz     "\nThe resulting number is: "

Debug:
    .asciiz    "\nDoing prime\n"

#------------------------------#
#                              #
# Main part of the program     #
#                              #
#------------------------------#

    .globl main
    .text

main:
    
    li $v0, 4 #Print author and program info
    la $a0, Author
    syscall

start:
    
    li  $v0, 4 #Print the prompt
    la  $a0, Prompt
    syscall

    li $v0, 5
    syscall
    add $t0, $v0, $zero #loading number in $t0 


############################################################
#    Call your isprime procedure here.
#    Right now $t0 holds the value from prompt
#    
######################################################    

# Check the first number entered for primeness
check:
    addi $a0, $t0, 0
    jal isprime
    beq $v0, $zero, retry
    la $a0, Success1
    li $v0, 4 # print the message for entered number being prime
    syscall
    j exit

# Try to find the next prime number (if the entered number was not prime)
retry:
    addi $a0, $a0, 1
    jal isprime
    beq $v0, $zero, retry
    move $t0, $a0 # hang onto the number we found

    la $a0, Success2_start
    li $v0, 4 # print the result message
    syscall

    li $v0, 1 # print the found number
    move $a0, $t0
    syscall
    
    la $a0, Success2_end
    li $v0, 4 # print the result message
    syscall

    j exit
    
############################################################
#  Print and Exit
###########################################################
exit:
    li $v0, 10 # Return control to OS
    syscall

############################################################
#  Prime number check:
#  $v0 = 0 when false, 1 when true
###########################################################
#  isprime(x = $a0):
#  if x <= 1
#    return false
#  n = x / 2         # start checking at half of n
#  while (n > 1)     # keep checking while n > 1
#    if x % n == 0   # x divides evenly by n
#      return false  # n is in fact prime
#    n -= 1          # otherwise check again...
#  return true       # eventually we prove x isn't prime
#
# It would be faster to start at sqrt(n) but this didn't
# appear to be the assignment objective.  Besides, there
# are even faster calculations than a trial and error.
#
isprime:
    # store the loop termination check value (1)
    li    $t1, 1
    
    # any number less than or equal to 1 isn't prime
    ble   $a0, $t1, False
        
    # n = x / 2, $t0 will hold n
    li    $t0, 2
    div   $a0, $t0
    mflo  $t0
    
isprimeLoop:
    # if n is less than or equal to 1
    # x hasn't been divided evenly
    # so x is prime
    ble   $t0, $t1, True
    
    # divide x by n and check the remainder,
    # returning false if it divided evenly
    div   $a0, $t0
    mfhi  $t2
    beq   $t2, $zero, False
    
    # reduce n by one and try again
    addi  $t0, $t0, -1
    j     isprimeLoop
    
True:
    li   $v0, 1
    jr   $ra
    
False:
    li   $v0, 0
    jr   $ra
    