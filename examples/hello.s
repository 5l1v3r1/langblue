.main
  sreg r8, .print
  sreg r9, .gets
  sreg r0, ._readName
  sreg r1, ._prompt
  jmp r8 ; print
._readName
  sreg r0, ._printHello
  sreg r1, ._result
  sreg r2, 0x18
  jmp r9 ; gets
._printHello
  sreg r0, ._printResult
  sreg r1, ._helloText
  jmp r8 ; print
._printResult
  sreg r0, ._printNewline
  sreg r1, ._result
  jmp r8 ; print
._printNewline
  sreg r0, 0xa
  pchar r0
  sreg r0, 0
  exit r0

._prompt
"Name: "
#0

._helloText
"Hello, "
#0

._result
"ABCDEFGHIJKLMNOPQRSTUVWX"
