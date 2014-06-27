class Runtime
  constructor: (@memory, @ip, @dataCb = null, @maxMem = 0x10000) ->
    @readBuffer = []
    @registers = (0 for x in [0...16])
    @compareStatus = 0
    if not (@memory instanceof Array)
      throw new TypeError 'invalid code type'
    if 'number' isnt typeof @ip
      throw new TypeError 'invalid instruction pointer type'
    for x in @memory
      if 'number' isnt typeof x
        throw new TypeError 'invalid memory element type'
  
  runNext: ->
    nextOp = @readMem @ip
    opCode = nextOp & 0xff
    arg1 = (nextOp >>> 8) & 0xff
    arg2 = (nextOp >>> 0x10) & 0xff
    arg3 = (nextOp >>> 0x18) & 0xff
    functions = [
      @getMemory, @setMemory, @setRegister, @copy, @jump,
      @printChar, @getChar,
      @unsignedMultiply, @unsignedDivide, @unsignedAdd, @unsignedSubtract,
      @signedMultiply, @signedDivide,
      @xorOp, @andOp, @orOp,
      @unsignedCompare, @signedCompare,
      @jumpEqual, @jumpGreater
    ]
    
    if opCode > 0x13
      throw new Error 'invalid opcode: ' + opCode
    if opCode is 6 and @readBuffer.length is 0
      return false
    
    functions[opCode].call this, arg1, arg2, arg3
    
    if not (opCode in [4, 0x12, 0x13])
      ++@ip
    
    return true
  
  input: (chars) ->
    if not (chars instanceof Array)
      throw new TypeError 'invalid input chars type'
    for x in chars
      if 'number' isnt typeof x
        throw new TypeError 'invalid char type'
      @readBuffer.push x

  getMemory: (arg1, arg2, arg3) ->
    @writeReg arg2, @readMem @readReg arg1
  
  setMemory: (arg1, arg2, arg3) ->
    @writeMem @readReg(arg1), @readReg arg2
    
  setRegister: (arg1, arg2, arg3) ->
    # make sure there's room for the next instruction
    nextCall = @readMem @ip + 1
    if (nextCall & 0xffff) isnt (2 | (arg1 << 8))
      throw new Error 'invalid instruction following sreg: ' + nextCall
    fullValue = arg2 | (arg3 << 8) | ((nextCall & 0xffff0000) >>> 0)
    @writeReg arg1, fullValue
    ++@ip
  
  copy: (arg1, arg2, arg3) ->
    @writeReg arg1, @readReg arg2
  
  jump: (arg1, arg2, arg3) ->
    @ip = @readReg arg1
  
  printChar: (arg1, arg2, arg3) ->
    @dataCb? @readReg arg1
  
  getChar: (arg1, arg2, arg3) ->
    throw new Error 'empty read buffer' if @readBuffer.length is 0
    value = @readBuffer[0]
    @readBuffer.splice 0, 1
    @writeReg arg1, value
  
  unsignedMultiply: (arg1, arg2, arg3) ->
    [val1, val2] = @readRegs arg2, arg3
    high1 = val1 >>> 0x10
    high2 = val2 >>> 0x10
    low1 = val1 & 0xffff
    low2 = val2 & 0xffff
    # no need for high1 * high2 because it's >= (1 << 32)
    high = (high1 * low2) + (high2 * low1)
    result = ((high << 0x10) >>> 0) + (low1 * low2)
    @writeReg arg1, result
  
  unsignedDivide: (arg1, arg2, arg3) ->
    [val1, val2] = @readRegs arg2, arg3
    throw new Error 'divide by zero' if val2 is 0
    @writeReg arg1, Math.floor val1 / val2
  
  unsignedAdd: (arg1, arg2, arg3) ->
    @writeReg arg1, @readReg(arg2) + @readReg(arg3)
  
  unsignedSubtract: (arg1, arg2, arg3) ->
    @writeReg arg1, @readReg(arg2) - @readReg(arg3)
  
  signedMultiply: (arg1, arg2, arg3) ->
    [val1, val2] = @readRegs arg2, arg3
    @writeReg arg1, (val1 >> 0) * (val2 >> 0)
  
  signedDivide: (arg1, arg2, arg3) ->
    [val1, val2] = @readRegs arg2, arg3
    throw new Error 'divide by zero' if val2 is 0
    @writeReg arg1, Math.floor (val1 >> 0) / (val2 >> 0)
  
  xorOp: (arg1, arg2, arg3) ->
    @writeReg arg1, @readReg(arg2) ^ @readReg(arg3)
  
  andOp: (arg1, arg2, arg3) ->
    @writeReg arg1, @readReg(arg2) & @readReg(arg3)
  
  orOp: (arg1, arg2, arg3) ->
    @writeReg arg1, @readReg(arg2) | @readReg(arg3)
  
  unsignedCompare: (arg1, arg2, arg3) ->
    [val1, val2] = @readRegs arg1, arg2
    if val1 > val2
      @compareStatus = 1
    else if val1 is val2
      @compareStatus = 0
    else
      @compareStatus = -1
  
  signedCompare: (arg1, arg2, arg3) ->
    val1 = @readReg(arg1) >> 0
    val2 = @readReg(arg2) >> 0
    if val1 > val2
      @compareStatus = 1
    else if val1 is val2
      @compareStatus = 0
    else
      @compareStatus = -1
  
  jumpEqual: (arg1, arg2, arg3) ->
    if @compareStatus is 0
      @ip = @readReg arg1
    else
      ++@ip
  
  jumpGreater: (arg1, arg2, arg3) ->
    if @compareStatus is 1
      @ip = @readReg arg1
    else
      ++@ip
  
  readReg: (idx) ->
    if idx > 0xf or idx < 0
      throw new RangeError 'invalid register: r' + idx
    return @registers[idx]
  
  readRegs: (args...) -> @readReg x for x in args
  
  writeReg: (idx, value) ->
    if idx > 0xf or idx < 0
      throw new RangeError 'invalid register: r' + idx
    @registers[idx] = value >>> 0

  readMem: (idx) ->
    if idx >= @maxMem or idx < 0
      throw new RangeError 'memory limit exceeded: ' + idx
    return @memory[idx] ? 0
  
  writeMem: (idx, value) ->
    if idx >= @maxMem or idx < 0
      throw new RangeError 'memory limit exceeded: ' + idx
    @memory[idx] = value

if module?
  module.exports = Runtime
else if window?
  window.LangBlue ?= {}
  window.LangBlue.Runtime = Runtime
