# Langblue

Langblue is a simple bytecode. There are only 20 32-bit instructions and one 64-bit instruction. Because of this, langblue is very easy to implement compared to other bytecodes.

Along with a bytecode, this project ships with a langblue assembler and linker. The linker supports relocation, so it is easy to write scalable langblue programs.

Theoretically, it would be possible to compile C or C++ down to langblue, although I have not attempted to go about doing so.

# Installing

You can only use the CoffeeScript tools if you have CoffeeScript and Node.js installed. To install Node.js, visit [the Node.js website](http://nodejs.org). To install CoffeeScript once you have Node.js, do this:

	$ npm install -g coffee-script

Now, install the langblue binaries by running this in the root langblue directory:

	$ npm install -g

Now, you have the `langblue` command to interpret langblue binaries, `langblue-as` to assemble langblue assembly, `langblue-join` to join object files, and `langblue-juice` to transform an object file into a binary.

# Usage

Here is an example of how to write a program, assemble it, juice it, and run it. First, let's create a source file called `hi.s`:

    sreg r0, 0x68 ; 'h'
    pchar r0
    sreg r0, 0x69 ; 'i'
    pchar r0
    sreg r0, 0xa ; '\n'
    pchar r0
    sreg r0, 0
    exit r0

To assemble this program, we will use the `langblue-as` command. The command takes the source file as an argument and outputs the object data to `stdout`. We will write the object file to `hi.json`:

	$ langblue-as hi.s >hi.json

At this point, if we had multiple files we would join them using the `langblue-join` command. However, since we only have one file, we will skip right to "juicing" it. The `langblue-juice` command takes the input and output files as arguments, since the raw binary is not suitable to be printed in a console:

	$ langblue-juice hi.json hi.bin

Finally, we can use the `langblue` command to execute the binary:

	$ langblue hi.bin
	hi

## Joining objects

Langblue object files list public symbols, their addresses, and every reference to them. This way, one source file can reference a function or constant from a different file.

The `langblue-join` command takes object files as arguments and outputs the joined object file to `stdout`. The objects are joined in the order they are specified as arguments, so the object with the entry point should go first. Here's an example:

	langblue-join main.json printf.json math.json >program.json

An object file should not be juiced unless it has been completely linked: that is, it has no unresolved references.

# Features

Langblue applications are provided with a pool of memory and 16 registers. They can exit the current program with the `exit` instruction. Additionally, programs may access the "console" through the `pchar` and `gchar` instructions.

At the moment, langblue has no built-in interface for system calls, but the bytecode could easily be expanded to include such a thing in the future.

The assembler allows you to embed strings and constants in the assembled blob. It supports hidden and exported symbols for named internal and external functions and constants.

# Uses

Suppose your Computer Science homework is to write a program in some strange language that you *despise*&ndash;let's call it Flaskell. You *could* write the entire program in Flaskell, but that would be no fun. Instead, you could write a langblue interpreter in Flaskell, write the entire program to compile down to langblue, and then hand in a Flaskell program that contains a large binary blob and a langblue interpreter.

Langblue could also be used for fast platfrom-independent binaries.
