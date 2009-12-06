section .text
GLOBAL _main

%macro clib_prolog 1
;  mov rbx, rsp        ; remember current esp
;  and rsp, 0xFFFFFFFFFFFFFFF0 ; align to next 16 byte boundary (could be zero offset!)
;  sub rsp, 12         ; skip ahead 12 so we can store original esp
;  push rbx            ; store esp (16 bytes aligned again)
;  add rsp, 16         ; pad for arguments (make conditional?)
%endmacro

; arg must match most recent call to clib_prolog
%macro clib_epilog 1
;    sub rsp, %1         ; remove arg padding
;    pop rbx             ; get original esp
;    mov rsp, rbx        ; restore
%endmacro
  
  _main:
    push rbp
    mov rbp, rsp
    push rbx
    
    clib_prolog 16
    ; xor eax,eax       ; place 0x0 in EAX for getting the name of the processor 
    ; cpuid
    ; shl  rdx,0x20     ; shifting lower 32-bits into upper 32-bit of RDX
    ; xor  rdx,rbx      ; moving EBX into EDX
    ; push rcx          ; push the string on the stack
    ; push rdx
    ; mov  rdx, 0x10    ; since we are pushing 2 registers, the length is not more than 16 bytes.
    ; mov  rsi, rsp     ; The address of the string is RSP because the string is on the stack
    ; push 0x1          ; The system call write() has the value 0x1 in the sytem call table
    ; pop  rax
    ; mov  rdi, rax     ; Since we are printing to stdout, the value of the file descriptor is also 0x1
    ; syscall           ; make the system call
    ; mov  rax, 0x3c    ; We now make the exit() system call here.
    ; xor  rdi, rdi     ; the argument is 0x0
    ; syscall           ; this exits the application and gives control back to the shell or the Operating system
    clib_epilog 16
    
    pop rbx
    mov rsp, rbp
    pop rbp
    mov eax, 0
    ret