   
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
#    addi $a0, $t0, 0
#    jal isprime


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


#  isprime(x):
#  n = x / 2         # start checking at half of n
#  while (n > 1)     # keep checking while n > 1
#    if x % n == 0   # x divides evenly by n
#      return true   # n is in fact prime
#    n -= 1          # otherwise check again...
#  return false      # eventually we prove x isn't prime
# isprime:
#     # n = x / 2
#     li    $t2, 2
#     div   $a0, $t2
#     mflo  $v0
#     jr    $ra
#     # li    $t0, 42
# 
#  while (n > 1)     # keep checking while n > 1
#    if x % n == 0   # x divides evenly by n
#      return true   # n is in fact prime
#    n -= 1          # otherwise check again...
#  return false      # eventually we prove x isn't prime


