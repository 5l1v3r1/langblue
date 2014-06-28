# State

Programs have access to a 32-bit address-space of 32-bit memory cells. Thus, there is a hard limit of 16GiB of memory.

A program has quick access to 16 32-bit registers r0 through r15. These registers are used as operands to pretty much every instruction.

The `gchar` and `pchar` instructions provide a virtual interface for a console. The console allows for Unicode input and output.

# Operations

## Registers and Memory

For `gmem` and `smem`, the first register operand stores the memory address. For `cpy`, the first register operand is set to the second register operand.

 * `gmem` - Get memory (reg, reg)
 * `smem` - Set memory (reg, reg)
 * `sreg` - Set register (reg, imm)
 * `cpy` - Copy register (reg, reg)

## Code execution

 * `jmp` - Jump (reg)

## I/O

 * `pchar` - Print char (reg)
 * `gchar` - Get char (reg) 

## Integer Arithmetic

For arguments `(a, b, c)` and operator `x`, read this as `a = b x c`

#### Unsigned math

 * `umul` - Unsigned multiply (reg, reg, reg)
 * `udiv` - Unsigned divide (reg, reg, reg)
 * `uadd` - Unsigned add (reg, reg, reg)
 * `usub` - Unsigned subtract (reg, reg, reg)

#### Signed math

 * `smul` - Signed multiply (reg, reg, reg)
 * `sdiv` - Signed divide (reg, reg, reg)

#### Bit manipulation

 * `xor` - Bitwise xor (reg, reg, reg)
 * `and` - Bitwise and (reg, reg, reg) 
 * `or` - Bitwise or (reg, reg, reg)

## Comparisons

 * `ucmp` - Unsigned compare (reg, reg)
 * `scmp` - Signed compare (reg, reg)
 * `je` - Jump if equal (reg)
 * `jg` - Jump if first operand is greater than second operand (reg)

## OS

 * `exit` - Exit with a status code (reg)