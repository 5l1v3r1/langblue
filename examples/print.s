; Print a string to the console
;
; input:
; r0 - return address
; r1 - string pointer
;
; modifies: r1, r2, r3, r4
;
.print
  ; setup initial registers
  sreg r2, 0
  sreg r3, 1
  
._nextChar
  gmem r1, r4
  
  ; return if NULL char has been reached
  ucmp r4, r2
  je r0

  ; print this character and increment the buffer pointer
  pchar r4
  uadd r1, r1, r3
  
  ; jump to print loop start
  sreg r4, ._nextChar
  jmp r4
