.main
  sreg r0, ._readInput
  sreg r1, ._prompt
  sreg r2, .print
  jmp r2
._readInput
  sreg r0, ._doneInput
  sreg r1, ._stringOutput
  sreg r2, 24
  sreg r3, .gets
  jmp r3
._doneInput
  sreg r0, ._printFlipped
  sreg r1, ._stringOutput
  sreg r2, .reverse
  jmp r2
._printFlipped
  sreg r0, ._exit
  sreg r1, ._stringOutput
  sreg r2, .print
  jmp r2
._exit
  sreg r0, 0xa
  pchar r0
  sreg r0, 0
  exit r0

._prompt
"Enter a string: "
#0

._stringOutput
"ABCDEFGHIJKLMNOPQRSTUVWX"
