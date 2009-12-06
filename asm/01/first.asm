; %include "asm_io.inc"

segment .data
var     db    1
prompt1 db    "Enter a number: ", 0
prompt2 db    "Enter another number: ", 0
outmsg1 db    "You entered ", 0
outmsg2 db    " and ", 0
outmsg3 db    ", the sum of thes is ", 0

segment .bss
input1 resd 1
input2 resd 1

segment .text
        global _asm_main
        global _incrementing
        
_asm_main:
  enter 0,0
  
  nop
  nop
  
  mov rax, 1
  add rax, 6
  
  nop
  nop
  
  leave
  ret
  
_incrementing:
  enter 0,0
  
  movb var, al
  add  rcx, 3
  mov  rax, rcx
  
  leave
  ret
  