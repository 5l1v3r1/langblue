# Purpose

It is sometimes useful to join multiple separate object files together. As an example, a library may come pre-compiled in an object file. Object files include information for symbolic relocation.

Object files may be executed only if every symbol they contain is resolved. Object files may be linked together only if no symbols in each file overlap.

# Format

An object file is stored as a JSON object. This json object follows this structure:

    {
      code: [some, numbers, here, ...],
      symbols: [
        {
          name: "some name or null",
          address: some_number,
          exists: true or false
          relocations: [
            some_offset,
            some_other_offset,
            some_third_offset,
            ...
          ]
        }
      ]
    }

The code is an array of 4-byte integers. An "address" in the code is simply an index in the code array (starting at 0).

The symbols array contains a list of objects. Each object has a `name` attribute which may be `null` if the symbol was marked private. The symbol begins at `address`, which is simply an index into the `code` array. If the `exists` flag is `false`, the address of the symbol is ignored. Symbols that do not exist are considered "external."

# Relocations

Note that each instruction is encoded as a 4-byte integer **except** for the `sreg` instruction, which is actually two "instructions." This is important to note because of the nature of relocations. A relocation points to the instruction which is the first "half" of an `sreg`. When code is relocated, the constant value in the `sreg` instruction is replaced with the relocated address.

# Execution

If any symbols in an object file do not exist (i.e. they have a `false` `exists` flag), the file is not executable. Otherwise, a symbol in the file may be run by loading the program into memory and starting execution at the symbol's address.
