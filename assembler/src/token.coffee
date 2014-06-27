class Token
  @instructions: [['jmp', 'pchar', 'gchar', 'je', 'jg'],
    ['gmem', 'smem', 'cpy', 'cmp', 'scmp'],
    ['umul', 'udiv', 'uadd', 'usub', 'smul', 'sdiv', 'xor', 'and', 'or']]
  
  constructor: (rawLine, @number) ->
    @line = rawLine.trim()
    @type = null
    @arguments = []
    return if @_parseString()
    return if @_parseInstruction()
    return if @_parseStore()
    return if @_parseNumber()
    throw new Error "invalid format on line #{@number}: \"#{@line}\""

  _parseString: ->
    match = /^"(.*)"$/.exec @line
    return false if not match?
    @type = 'string'
    @arguments = [match[1]]
    return true
  
  _parseInstruction: ->
    gotResult = (match, idx) ->
      name = match[1].toLowerCase()
      return false if not (name in Token.instructions[idx])
      @type = 'instruction'
      @arguments = [name].concat (parseInt x for x in match[2..idx + 2])
      return true
    
    singleMatch = '([a-zA-Z]+)\\s+[rR]([0-9]+)'
    match = new RegExp("^#{singleMatch}$").exec @line
    return gotResult match, 0 if match?
    
    doubleMatch = "#{singleMatch}\s*,\s*[rR]([0-9]+)"
    match = new RegExp("^#{doubleMatch}$").exec @line
    return gotResult match, 1 if match?
    
    tripleMatch = "#{doubleMatch}\s*,\s*[rR]([0-9]+)"
    match = new RegExp("^#{tripleMatch}$").exec @line
    return gotResult match, 2 if match?
    
    return false
  
  _parseStore: ->
    match = /^(sreg|SREG)\s+[rR]([0-9]+)\s*,\s*([_a-zA-Z0-9\.]*)$/.exec @line
    return false if not match?
    register = parseInt match[2]
    value = match[3]
    if value[0] is '.'
      @type = 'store-symbol'
      @arguments = [register, value]
    else
      parsed = Token._parseNumber value
      if isNaN parsed
        throw new Error "line #{@number}: invalid constant \"#{value}\""
      @type = 'store-number'
      @arguments = [register, parsed]

  _parseNumber: ->
    match = /^#([xXbB0-9]+)$/.exec @line
    return false if not match?
    parsed = Token._parseNumber match[1]
    if isNaN parsed
      throw new Error "line #{@number}: invalid constant \"#{match[1]}\""
    @type = 'number'
    @arguments = [parsed]

  @_parseNumber: (number) ->
    if (match = /^0x[0-9a-fA-F]+$/.exec number)?
      return parseInt match[1], 16
    else if (match = /^0b[01]+$/.exec number)?
      return parseInt match[1], 2
    else if (match = /^0[0-7]+$/.exec number)?
      return parseInt match[1], 8
    else
      return parseInt number

if module?
  module.exports = Token
else if window?
  window.LangBlue ?= {}
  window.LangBlue.Token = Token
