; Print a string to the console
;
; input:
; r0 - string pointer
; r1 - return address
;
; modifies registers:
; r0, r2, r3, r4
;

.print
; setup initial registers
sreg r2, 0
sreg r3, 1
; print out the next character
._nextChar
gmem r0, r4
; return if NULL char has been reached
ucmp r4, r2
je r1
; print this character and increment the buffer pointer
pchar r4
uadd r0, r0, r3
; jump to print loop start
sreg r4, ._nextChar
jmp r4
