# Symbols

In this assembler, a symbol is marked by preceding a line with a `.`. Some examples of symbol declarations are as follows:

    .MySymbol
    .my_symbol
    .symbol3
    ._hidden_symbol
    .3rd_symbol

A symbol may contain numbers, underscores, and letters. Symbols which begin with underscores will not be exported by name during the linking process.

# Blobs

You may encode a string by beginning a line with a quotation mark. Strings are encoded as Unicode with 32-byte characters. No escapes are supported in strings. Here is an example of a valid string:

    " hey there... This is some text! "

You may encode a raw, unsigned 32-byte value using a number sign followed by a numerical expression using the same format as described in [Constants](#contants-section) below.

Some examples of all this in unison:

	.myJoke
	"And then the wolf says to the rabit, "
	#0x22
	"I didn't order any cabbages!"
	#0x22

# Instructions

All instructions are written as "*instruction* **comma**, **separated**, **operands**". Most of the time, arguments will all be register names. Some examples of calls are:

	jmp r0
	gmem r0, r1
	umul r0, r1, r2

<a name="constants-section"></a>
# Constants

You may assign a numerical value to a register using the `sreg` instruction. For this instruction only, you may specify a constant in hexadecimal, decimal, binary, or octal. Here are the cases:

	sreg r0, 0x1337
	sreg r0, 0b1001100110111
	sreg r0, 4919
	sreg r0, 011467

The prefix `0x` is used for hex, `0b` for binary, and `0` for octal.