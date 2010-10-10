   
   .data
 Author:
  .ascii      "\nCS465, Computer Architecture, Fall 2010\n\n"
  .ascii      "spim successive integer counting program\n"
  .asciiz     "Author: Huzefa Rangwala\n"


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
   addi $a0, $t0, 0
   jal isprime
   move $t0, $v0

############################################################
#  Print and Exit
###########################################################
    li $v0, 4 #Print the result prompt
    la $a0, Result
    syscall

    li $v0, 1 #Print the decimal values
    move $a0, $t0
    syscall

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
    
    # any number less than or equal to 1 aren't prime
    ble   $a0, $t1, False
        
    # n = x / 2, $t0 will hold n
    li    $t0, 2
    div   $a0, $t0
    mflo  $t0
    
isprimeLoop:
    # if n is less than or equal to 1
    # x hasn't been divided evenly
    # so n is prime
    ble   $t0, $t1, True
    
    # divide x by n and get the remainder
    div   $a0, $t0
    mfhi  $t2
    
    # if the remainder is zero the number divided
    # evenly and isn't prime
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
    