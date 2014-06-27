.restart

sreg r0, 1
sreg r1, data
sreg r2, 0
sreg r3, start

.start

gmem r1, r4
ucmp r4, r2
je r2

pchar r4
uadd r1, r1, r0
jmp r3

.data
"hey"
#0xa
#0x0
