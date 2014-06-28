# Basic encoding

Instructions are all 4 bytes (with the minor exception of the `sreg` instruction). The first byte is always the instruction opcode. The next three bytes depend on the opcode, but will generally contain one or zero register indexes each. Since register indexes are only 4 bits, the other 4 bits in each byte are reserved. 

As an example, this code would be compiled as such:

    smul r0, r1, r2
    cmp r2, r1
    je r3

Would come out as:

    0B 00 01 02
    10 02 01 00
    12 03 00 00

# The `sreg` instruction

How could you possibly encode an `sreg` instruction into 4 bytes when in *includes* a 4 byte numerical operand? Such a thing is not possible. 

Instead, the `sreg` instruction is used twice. The first time, it stores the lower half of the numerical operand; the second time, it stores the upper half. It is invalid to split up these two instructions: an `sreg` instruction that is not followed by another `sreg` instruction *that acts on the same register* is invalid.

Here is an example of how an `sreg` might be encoded:

    sreg r0, 0x12345678

Would become

	02 00 78 56
	02 00 34 12

As you can see, the first byte is the opcode, the next is the register, and the next two are the 16-byte numerical operand (stored in little endian). The following are examples of **invalid** `sreg` encodings. The `...` indicates an opcode that is not an `sreg` instruction.

	...
	02 07 12 34
	...

The above example is invalid because there is no second `sreg` instruction.

	...
	02 07 12 34
	02 08 12 34
	...

The above example is invalid because there are two successive `sreg` calls which store to different registers.

# Opcode assignments

Here are the raw numerical values associated with each instruction.

| Name  | Opcode | 
|------:|--------|
|`gmem` |`00`    |
|`smem` |`01`    |
|`sreg` |`02`    |
|`cpy`  |`03`    |
|`jmp`  |`04`    |
|`pchar`|`05`    |
|`gchar`|`06`    |
|`umul` |`07`    |
|`udiv` |`08`    |
|`uadd` |`09`    |
|`usub` |`0a`    |
|`smul` |`0b`    |
|`sdiv` |`0c`    |
|`xor`  |`0d`    |
|`and`  |`0e`    |
|`or`   |`0f`    |
|`ucmp` |`10`    |
|`scmp` |`11`    |
|`je`   |`12`    |
|`jg`   |`13`    |
|`exit` |`14`    |