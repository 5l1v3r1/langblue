.main
sreg r0, .helloWorld
sreg r1, .endProgram
sreg r2, .print
jmp r2

.endProgram
sreg r0, .done
sreg r1, .spin
sreg r2, .print
jmp r2
sreg r2, .spin
.spin
jmp r2

.helloWorld
"Hello, world!"
#0xa
#0

.done
"Done execution. TODO: make an exit call"
#0xa
#0
