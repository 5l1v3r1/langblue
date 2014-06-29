parseConstant = (number) ->
  if (match = /^0x[0-9a-fA-F]+$/.exec number)?
    return parseInt match[1], 16
  else if (match = /^0b[01]+$/.exec number)?
    return parseInt match[1], 2
  else if (match = /^0[0-7]+$/.exec number)?
    return parseInt match[1], 8
  else
    return parseInt number

class Token
  constructor: (@line, @raw, @offset) ->
    if 'number' isnt typeof @line
      throw new TypeError 'invalid type for line number'
    if 'string' isnt typeof @raw
      throw new TypeError 'invalid type for raw line'
    if 'number' isnt typeof @offset
      throw new TypeError 'invalid type for offset'
  
  encode: -> []
  
  isSymbol: -> false
  
  isStore: -> false
  
  @parse: (l, r, o) ->
    return val if (val = StringToken.decode l, r, o)?
    return val if (val = InstructionToken.decode l, r, o)?
    return val if (val = StoreToken.decode l, r, o)?
    return val if (val = NumberToken.decode l, r, o)?
    return val if (val = SymbolToken.decode l, r, o)?
    throw new Error "bad syntax on line #{l}: #{r}"

class StringToken extends Token
  constructor: (l, r, o, @string) -> super l, r, o
  
  encode: -> x.charCodeAt 0 for x in @string
  
  @decode: (line, raw, offset) ->
    match = /^"(.*)"$/.exec raw
    return null if not match?
    return new StringToken line, raw, offset, match[1]

class InstructionToken extends Token
  @instructions: [['jmp', 'pchar', 'gchar', 'je', 'jg', 'exit'],
    ['gmem', 'smem', 'cpy', 'ucmp', 'scmp'],
    ['umul', 'udiv', 'uadd', 'usub', 'smul', 'sdiv', 'xor', 'and', 'or']]
  
  constructor: (l, r, o, @op, @regs) -> super l, r, o

  encode: ->
    instructions = ['gmem', 'smem', 'sreg', 'cpy', 'jmp', 'pchar', 'gchar',
      'umul', 'udiv', 'uadd', 'usub', 'smul', 'sdiv', 'xor', 'and', 'or',
      'ucmp', 'scmp', 'je', 'jg', 'exit']
    opcode = instructions.indexOf @op
    if opcode < 0
      throw new Error 'unknown instruction: ' + @op
    for x, i in @regs
      if x > 15
        throw new Error 'invalid register: r' + x
      opcode |= x << (8 + i * 8)
    return [opcode]
  
  @decode: (line, raw, offset) ->
    gotResult = (match, idx) ->
      name = match[1].toLowerCase()
      return null if not (name in InstructionToken.instructions[idx])
      args = (parseInt x for x in match[2..idx + 2])
      return new InstructionToken line, raw, offset, name, args
    
    singleMatch = '([a-zA-Z]+)\\s+[rR]([0-9]+)'
    match = new RegExp("^#{singleMatch}$").exec raw
    return gotResult match, 0 if match?
    
    doubleMatch = "#{singleMatch}\\s*,\\s*[rR]([0-9]+)"
    match = new RegExp("^#{doubleMatch}$").exec raw
    return gotResult match, 1 if match?
    
    tripleMatch = "#{doubleMatch}\\s*,\\s*[rR]([0-9]+)"
    match = new RegExp("^#{tripleMatch}$").exec raw
    return gotResult match, 2 if match?
    
    return null

class StoreToken extends Token
  constructor: (l, r, o, @register, @value) -> super l, r, o
  
  encode: ->
    if @isSymbolicStore()
      return [@_mask(), @_mask()]
    else
      val1 = (@value & 0xffff) << 0x10
      val2 = @value & 0xffff0000
      return [val1 | @_mask(), val2 | @_mask()]
  
  isSymbolicStore: -> 'string' is typeof @value
  
  isStore: -> true
  
  _mask: -> 2 | (@register << 8)
  
  @decode: (line, raw, offset) ->
    match = /^(sreg|SREG)\s+[rR]([0-9]+)\s*,\s*([_a-zA-Z0-9\.]*)$/.exec raw
    return null if not match?
    register = parseInt match[2]
    value = match[3]
    if value[0] is '.'
      return new StoreToken line, raw, offset, register, value[1..]
    else
      parsed = parseConstant value
      if isNaN parsed
        throw new Error "line #{line}: invalid constant \"#{value}\""
      return new StoreToken line, raw, offset, register, parsed

class NumberToken extends Token
  constructor: (l, r, o, @value) -> super l, r, o
  
  encode: -> [@value]
  
  @decode: (line, raw, offset) ->
    match = /^#([xXbB0-9]+)$/.exec raw
    return null if not match?
    parsed = parseConstant match[1]
    if isNaN parsed
      throw new Error "line #{line}: invalid constant \"#{match[1]}\""
    return new NumberToken line, raw, offset, parsed

class SymbolToken extends Token
  constructor: (l, r, o, @name) -> super l, r, o
  
  isSymbol: -> true
  
  @decode: (line, raw, offset) ->
    match = /^\.([a-zA-Z0-9_]+)$/.exec raw
    return null if not match?
    return new SymbolToken line, raw, offset, match[1]

if module?
  module.exports = Token
else if window?
  window.LangBlue ?= {}
  window.LangBlue.Token = Token
