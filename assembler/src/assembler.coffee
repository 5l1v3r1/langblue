class Assembler
  constructor: (@file) ->
    @symbols = {}
    for token in @file.tokens
      if token.type is 'store-symbol'
        name = token.arguments[1]
        if not @symbols[name]?
          @symbols[name] = location: null, relocations: [token.offset]
        else
          @symbols[name].relocations.push token.offset
      else if token.type is 'symbol'
        name = token.arguments[0]
        @symbols[name] ?= location: null, relocations: []
        if @symbols[name].location?
          msg = "duplicate symbol at line #{token.lineNumber}: #{name}"
          throw new Error msg
        @symbols[name].location = token.offset
  
  generateObject: ->
    # generate symbol table
    symbols = []
    for name, info of @symbols
      if name[0] is '_'
        address = info.location
        if not address?
          throw new Error 'unresolved hidden symbol: ' + name
        symbols.push
          name: null
          exists: true
          address: address
          relocations: info.relocations
      else
        symbols.push
          name: name
          exists: info.location?
          address: info.location ? 0
          relocations: info.relocations

    # generate code
    code = []
    for token in @file.tokens
      code.push @_encodeToken(token)...

    return code: code, symbols: symbols
  
  _encodeToken: (token) ->
    switch token.type
      when 'string' then (x.charCodeAt 0 for x in token.arguments[0])
      when 'number' then token.arguments
      when 'symbol' then []
      when 'store-number' then @_encodeStore token
      when 'store-symbol' then @_encodeStore token
      when 'instruction' then Assembler._encodeInstruction token
      else throw new TypeError 'invalid token type: ' + token.type
  
  _encodeStore: (token) ->
    if token.type is 'store-number'
      value = token.arguments[1]
    else
      info = @symbols[token.arguments[1]]
      if not info?
        throw new Error 'invalid symbol at line ' +
          "#{token.lineNumber}: #{token.arguments[1]}"
      value = info.loctation ? 0
    num1 = 2 | (token.arguments[0] << 8) | ((value & 0xffff) << 0x10)
    num2 = 2 | (token.arguments[0] << 8) | ((value & 0xffff0000) >>> 0)
    return [num1, num2]
  
  @_encodeInstruction: (token) ->
    instructions = ['gmem', 'smem', 'sreg', 'cpy', 'jmp', 'pchar', 'gchar',
      'umul', 'udiv', 'uadd', 'usub', 'smul', 'sdiv', 'xor', 'and', 'or',
      'ucmp', 'scmp', 'je', 'jg', 'exit']
    value = instructions.indexOf token.arguments[0]
    for x, i in token.arguments
      continue if i is 0
      value |= x << (8 * i)
    return [value >>> 0]

if module?
  module.exports = Assembler
else if window?
  window.LangBlue ?= {}
  window.LangBlue.Assembler = Assembler
