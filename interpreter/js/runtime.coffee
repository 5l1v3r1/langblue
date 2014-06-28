class Runtime
  constructor: (@state, @outputCallback) ->
    @readBuffer = []
  
  getMemory: -> @state.memory
  
  getRegisters: -> @state.registers
  
  next: ->
    instruction = @state.readInstruction()
    opcode = instruction & 0xff
    args = ((instruction >>> (i * 8)) & 0xff for i in [1..3])
    
    if opcode > 0x13
      throw new Error 'invalid opcode: ' + opCode
    if opcode is 6 and @readBuffer.length is 0
      return false
    
    @operationFunctions()[opcode].call this, args...
    
    # increment IP if opcode wasn't a jump instruction
    @state.step() if not (opcode in [4, 0x12, 0x13])
    
    return true
  
  input: (chars) ->
    if not (chars instanceof Array)
      throw new TypeError 'invalid input chars type'
    for x in chars
      if 'number' isnt typeof x
        throw new TypeError 'invalid char type'
      @readBuffer.push x

  operationFunctions: ->
    [
      @gmem, @smem, @sreg, @cpy, @jmp,
      @pchar, @gchar,
      @umul, @udiv, @uadd, @usub,
      @smul, @sdiv,
      @xorOp, @andOp, @orOp,
      @ucmp, @scmp,
      @je, @jg,
      @exit
    ]

  gmem: (arg1, arg2, arg3) ->
    value = @getMemory().read @getRegisters().read arg1
    @getRegisters().write arg2, value
  
  smem: (arg1, arg2, arg3) ->
    address = @getRegisters().read arg1
    value = @getRegisters().read arg2
    @getMemory().write address, value
    
  sreg: (arg1, arg2, arg3) ->
    # read the next instruction to make sure it's a valid sreg continuation
    @state.step()
    nextCall = @state.readInstruction()
    if (nextCall & 0xffff) isnt (2 | (arg1 << 8))
      throw new Error 'invalid instruction following sreg: ' + nextCall
    # combine the lower and higher halves
    value = arg2 | (arg3 << 8) | ((nextCall & 0xffff0000) >>> 0)
    @getRegisters().write arg1, value
  
  cpy: (arg1, arg2, arg3) ->
    @getRegisters().write arg1, @getRegisters().read arg2
  
  jmp: (arg1, arg2, arg3) ->
    @state.jump arg1
  
  pchar: (arg1, arg2, arg3) ->
    @outputCallback? @getRegisters().read arg1
  
  gchar: (arg1, arg2, arg3) ->
    throw new Error 'empty read buffer' if @readBuffer.length is 0
    value = @readBuffer[0]
    @readBuffer.splice 0, 1
    @getRegisters().write arg1, value
  
  umul: (arg1, arg2, arg3) ->
    [val1, val2] = @getRegisters().readAll arg2, arg3
    high1 = val1 >>> 0x10
    high2 = val2 >>> 0x10
    low1 = val1 & 0xffff
    low2 = val2 & 0xffff
    # no need for high1 * high2 because it's >= (1 << 32)
    high = (high1 * low2) + (high2 * low1)
    result = ((high << 0x10) >>> 0) + (low1 * low2)
    @getRegisters().write arg1, result
  
  udiv: (arg1, arg2, arg3) ->
    [val1, val2] = @getRegisters().readAll arg2, arg3
    throw new Error 'divide by zero' if val2 is 0
    @getRegisters().write arg1, Math.floor val1 / val2
  
  uadd: (arg1, arg2, arg3) ->
    [val1, val2] = @getRegisters().readAll arg2, arg3
    @getRegisters().write arg1, val1 + val2
  
  usub: (arg1, arg2, arg3) ->
    [val1, val2] = @getRegisters().readAll arg2, arg3
    @getRegisters().write arg1, val1 - val2
  
  smul: (arg1, arg2, arg3) ->
    [val1, val2] = @getRegisters().readAll arg2, arg3
    @getRegisters().write arg1, (val1 >> 0) * (val2 >> 0)
  
  sdiv: (arg1, arg2, arg3) ->
    [val1, val2] = @getRegisters().readAll arg2, arg3
    throw new Error 'divide by zero' if val2 is 0
    # TODO: maybe here always round "close", not "floor" for negative values
    @getRegisters().write arg1, Math.floor (val1 >> 0) / (val2 >> 0)
  
  xorOp: (arg1, arg2, arg3) ->
    [val1, val2] = @getRegisters().readAll arg2, arg3
    @getRegisters().write arg1, val1 ^ val2
  
  andOp: (arg1, arg2, arg3) ->
    [val1, val2] = @getRegisters().readAll arg2, arg3
    @getRegisters().write arg1, val1 & val2
  
  orOp: (arg1, arg2, arg3) ->
    [val1, val2] = @getRegisters().readAll arg2, arg3
    @getRegisters().write arg1, val1 | val2
  
  ucmp: (arg1, arg2, arg3) ->
    [val1, val2] = @getRegisters().readAll arg1, arg2
    if val1 > val2
      @state.compareStatus = 1
    else if val1 is val2
      @state.compareStatus = 0
    else
      @state.compareStatus = -1
  
  scmp: (arg1, arg2, arg3) ->
    val1 = @getRegisters().read(arg1) >> 0
    val2 = @getRegisters().read(arg2) >> 0
    if val1 > val2
      @state.compareStatus = 1
    else if val1 is val2
      @state.compareStatus = 0
    else
      @state.compareStatus = -1
  
  je: (arg1, arg2, arg3) ->
    if @state.getEqualFlag()
      @state.jump arg1
    else
      @state.step()
  
  jg: (arg1, arg2, arg3) ->
    if @state.getGreaterFlag()
      @state.jump arg1
    else
      @state.step()
  
  exit: (arg1, arg2, arg3) ->
    process.exit @getRegisters().read arg1

if module?
  module.exports = Runtime
else if window?
  window.LangBlue ?= {}
  window.LangBlue.Runtime = Runtime
