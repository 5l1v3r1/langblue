class Register
  constructor: (number) -> @value = number >>> 0
  
  umul: (register) ->
    high1 = @value >>> 0x10
    high2 = register.value >>> 0x10
    low1 = @value & 0xffff
    low2 = register.value & 0xffff
    # no need for high1 * high2 because it's >= (1 << 32)
    high = (high1 * low2) + (high2 * low1)
    result = ((high << 0x10) >>> 0) + (low1 * low2)
    return new Register result
  
  udiv: (register) -> new Register Math.floor(@value / register.value)
  
  usub: (register) -> new Register @value - register.value
  
  uadd: (register) -> new Register @value + register.value
  
  smul: (register) -> new Register (@value >> 0) * (register.value >> 0)
  
  sdiv: (register) ->
    new Register Math.floor (@value >> 0) / (register.value >> 0)
  
  ucmp: (register) ->
    return 0 if @value is register.value
    return 1 if @value > register.value
    return -1
  
  scmp: (register) ->
    sValue = @value >> 0
    sReg = register.value >> 0
    return 0 if sValue is sReg
    return 1 if sValue > sReg
    return -1

class Runtime
  constructor: (@memory, @ip, @dataCb = null, @maxMem = 0x10000) ->
    @readBuffer = []
    @registers = (new Register 0 for x in [0...16])
    @compareStatus = 0
    if not (@memory instanceof Array)
      throw new TypeError 'invalid code type'
    if 'number' isnt typeof @ip
      throw new TypeError 'invalid instruction pointer type'
    for x in @memory
      if 'number' isnt typeof x
        throw new TypeError 'invalid memory element type'
  
  runNext: ->
    nextOp = @_readMem @ip
    opCode = nextOp & 0xff
    arg1 = (nextOp >>> 8) & 0xff
    arg2 = (nextOp >>> 0x10) & 0xff
    arg3 = (nextOp >>> 0x18) & 0xff
    functions = [
      getMemory, setMemory, setRegister, copy, jump,
      printChar, getChar,
      unsignedMultiply, unsignedDivide, unsignedAdd, unsignedSubtract,
      signedMultiply, signedDivide,
      xorOp, andOp, orOp,
      unsignedCompare, signedCompare,
      jumpEqual, jumpGreater
    ]
    
    if opCode > 0x13
      throw new Error 'invalid opcode: ' + opcode
    if opCode is 6 and @readBuffer.length is 0
      return false
    
    functions[opCode] arg1, arg2, arg3
    
    if opCode is 2
      @ip += 2
    else if opCode isnt 4
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
    @_writeReg arg2, @_readMem @_readReg arg1
  
  setMemory: (arg1, arg2, arg3) ->
    @_writeMem @_readReg(arg1), @_readReg arg2
    
  setRegister: (arg1, arg2, arg3) ->
    # make sure there's room for the next instruction
    nextCall = @_readMem @ip + 1
    if (nextCall & 0xffff) isnt (2 & (arg1 << 8))
      throw new Error 'invalid instruction following sreg: ' + nextCall
    fullValue = arg2 | (arg3 << 8) | (nextCall >>> 0x10)
    @_writeReg arg1, fullValue
  
  copy: (arg1, arg2, arg3) ->
    @_writeReg arg1, @_readReg arg2
  
  jump: (arg1, arg2, arg3) ->
    @ip = @_readReg arg1
  
  printChar: (arg1, arg2, arg3) ->
    @dataCb? @_readReg arg1
  
  getChar: (arg1, arg2, arg3) ->
    return false if @readBuffer.length is 0
    value = @readBuffer[0]
    @readBuffer.splice 0, 1
    @_writeReg arg1, value
  
  unsignedMultiply: (arg1, arg2, arg3) ->
    [val1, val2] = @_readRegs arg2, arg3
    
  
  unsignedDivide: (arg1, arg2, arg3) ->
    [val1, val2] = @_readReg arg2, arg3
    if val2 is 0
      throw new Error 'divide by zero'
    divided = Math.floor((val1 >>> 0) / (val2 >>> 0)) & 0xffffffff
    @_writeReg arg1, divided >>> 0
  
  unsignedAdd: (arg1, arg2, arg3) ->
    result = (@_readReg(arg2) + @_readReg arg3) >>> 0
    @_writeReg arg1, result
  
  unsignedSubtract: (arg1, arg2, arg3) ->
    result = (@_readReg(arg2) - @_readReg arg3) >>> 0
    @_writeReg arg1, result
  
  signedMultiply: (arg1, arg2, arg3) ->
    result = (@_readReg(arg2) * @_readReg arg3) >>> 0
  
  signedDivide: (arg1, arg2, arg3) ->
  
  xorOp: (arg1, arg2, arg3) ->
  
  andOp: (arg1, arg2, arg3) ->
  
  orOp: (arg1, arg2, arg3) ->
  
  unsignedCompare: (arg1, arg2, arg3) ->
  
  signedCompare: (arg1, arg2, arg3) ->
  
  jumpEqual: (arg1, arg2, arg3) ->
  
  jumpGreater: (arg1, arg2, arg3) ->
    
  _readReg: (idx) ->
    if idx > 0xf or idx < 0
      throw new RangeError 'invalid register: r' + idx
    return @registers[idx]
  
  _readRegs: (args...) -> @_readReg x for x in args...
  
  _writeReg: (idx, value) ->
    if idx > 0xf or idx < 0
      throw new RangeError 'invalid register: r' + idx
    @registers[idx] = value

  _readMem: (idx) ->
    if idx >= @maxMem or idx < 0
      throw new RangeError 'memory limit exceeded: ' + idx
    return @memory[idx] ? 0
  
  _writeMem: (idx, value) ->
    if idx >= @maxMem or idx < 0
      throw new RangeError 'memory limit exceeded: ' + idx
    @memory[idx] = value
