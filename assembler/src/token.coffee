class Token
  @instructions: [['jmp', 'pchar', 'gchar', 'je', 'jg', 'exit'],
    ['gmem', 'smem', 'cpy', 'ucmp', 'scmp'],
    ['umul', 'udiv', 'uadd', 'usub', 'smul', 'sdiv', 'xor', 'and', 'or']]
  
  constructor: (rawLine, @lineNumber, @offset) ->
    @line = rawLine.trim()
    @type = null
    @arguments = []
    return if @_parseString()
    return if @_parseInstruction()
    return if @_parseStore()
    return if @_parseNumber()
    return if @_parseSymbol()
    throw new Error "invalid format on line #{@lineNumber}: \"#{@line}\""

  getSize: ->
    switch @type
      when 'string' then return @arguments[0].length
      when 'instruction' then return 1
      when 'store-number' then return 2
      when 'store-symbol' then return 2
      when 'number' then return 1
      when 'symbol' then return 0
      else throw new TypeError 'Unknown type: ' + @type

  _parseString: ->
    match = /^"(.*)"$/.exec @line
    return false if not match?
    @type = 'string'
    @arguments = [match[1]]
    return true
  
  _parseInstruction: ->
    gotResult = (match, idx) =>
      name = match[1].toLowerCase()
      return false if not (name in Token.instructions[idx])
      @type = 'instruction'
      @arguments = [name].concat (parseInt x for x in match[2..idx + 2])
      return true
    
    singleMatch = '([a-zA-Z]+)\\s+[rR]([0-9]+)'
    match = new RegExp("^#{singleMatch}$").exec @line
    return gotResult match, 0 if match?
    
    doubleMatch = "#{singleMatch}\\s*,\\s*[rR]([0-9]+)"
    match = new RegExp("^#{doubleMatch}$").exec @line
    return gotResult match, 1 if match?
    
    tripleMatch = "#{doubleMatch}\\s*,\\s*[rR]([0-9]+)"
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
      @arguments = [register, value[1..]]
    else
      parsed = Token._parseNumber value
      if isNaN parsed
        throw new Error "line #{@lineNumber}: invalid constant \"#{value}\""
      @type = 'store-number'
      @arguments = [register, parsed]
    return true

  _parseNumber: ->
    match = /^#([xXbB0-9]+)$/.exec @line
    return false if not match?
    parsed = Token._parseNumber match[1]
    if isNaN parsed
      throw new Error "line #{@lineNumber}: invalid constant \"#{match[1]}\""
    @type = 'number'
    @arguments = [parsed]

  _parseSymbol: ->
    match = /^\.([a-zA-Z0-9_]+)$/.exec @line
    return false if not match?
    @type = 'symbol'
    @arguments = [match[1]]

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
