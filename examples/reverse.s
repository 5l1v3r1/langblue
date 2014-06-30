; Reverse a NULL-terminated string
;
; input:
; r0 - return address
; r1 - buffer
;
; modifies: r1, r2, r3, r4, r5, r6, r7
;
.reverse
  ; backup return address and buffer
  cpy r6, r0
  cpy r7, r1
  
  ; call strlen on the input buffer
  sreg r0, ._gotLength
  sreg r2, .strlen
  jmp r2

._gotLength
  ; r3 = strlen(buff), r6 = return addr, r7 = buff
  cpy r0, r6
  cpy r1, r7
  
  ; if the string is of length < 2, we're done
  sreg r4, 2
  ucmp r4, r3
  jg r0

  ; perform some arithmetic
  sreg r4, 2
  udiv r2, r3, r4
  sreg r4, 1
  usub r3, r3, r4
  usub r2, r2, r4
  ; r3 = strlen(buff) - 1
  ; r2 = strlen(buff) / 2 - 1

._loop
  uadd r4, r1, r2
  uadd r5, r1, r3
  usub r5, r5, r2
  ; r4 = buff + r2
  ; r5 = buff + strlen(buff) - 1 - r2
  
  ; actually flip the values
  gmem r4, r6
  gmem r5, r7
  smem r4, r7
  smem r5, r6
  
  ; check if we are done
  sreg r4, 0
  ucmp r2, r4
  je r0
  
  ; subtract one from r2
  sreg r4, 1
  usub r2, r2, r4
  sreg r4, ._loop
  jmp r4
