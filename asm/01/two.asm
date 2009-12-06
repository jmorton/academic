.data
var: .byte 0

.text
  .globl _asm_main
  .globl _incrementing
        
_asm_main:
  enter $0, $0

  movq $64, var(%rdi)

  leave
  ret

_incrementing:
  nop
  