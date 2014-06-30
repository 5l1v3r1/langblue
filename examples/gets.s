; Get a line from the console
;
; Input:
; r0 - return address
; r1 - output buffer
; r2 - maximum length (1 or higher) including NULL terminator
;
; modifies: r1, r2, r3, r4, r5, r6, r7
;
.gets
  sreg r3, 0
  sreg r4, 1
  sreg r6, 0xa
  sreg r7, ._terminate
._loop
  gchar r5
  ucmp r5, r6 ; compare with '\n'
  je r7 ; ._terminate
  smem r1, r5
  
  ; subract from the maximum length and see if it's 0
  usub r2, r2, r4 ; subtract 1
  ucmp r2, r3 ; compare with 0
  je r7 ; ._terminate
  
  ; increment the buffer and loop
  uadd r1, r1, r4 ; add 1
  sreg r5, ._loop
  jmp r5
  
._terminate
  sreg r5, 0
  smem r1, r5
  jmp r0
