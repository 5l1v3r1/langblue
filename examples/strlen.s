; Get the length of a NULL-terminated string
;
; input:
; r0 - return address
; r1 - string
;
; modifies: r1, r2, r3, r4, r5
;
; return value: r3
;
.strlen
  sreg r3, 0
._loop
  gmem r1, r5
  sreg r4, 0
  ucmp r5, r4
  je r0
  sreg r4, 1
  uadd r3, r3, r4
  uadd r1, r1, r4
  sreg r4, ._loop
  jmp r4
