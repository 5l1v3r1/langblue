.main
sreg r0, .helloWorld
sreg r1, .endProgram
sreg r2, .print
jmp r2

.endProgram
sreg r0, 0
exit r0

.helloWorld
"Hello, world!"
#0xa
#0
