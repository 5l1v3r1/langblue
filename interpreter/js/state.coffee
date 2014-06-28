class Registers
  constructor: ->
    @list = (0 for x in [0...16])
  
  read: (idx) ->
    if isNaN(idx) or 'number' isnt typeof idx
      throw new TypeError 'invalid register index: ' + idx
    if idx < 0 or idx > 0xf
      throw new RangeError 'invalid register index: ' + idx
    return @list[idx]
  
  write: (idx, value) ->
    if isNaN(idx) or 'number' isnt typeof idx
      throw new TypeError 'invalid register index: ' + idx
    if idx < 0 or idx > 0xf
      throw new RangeError 'invalid register index: ' + idx
    @list[idx] = value >>> 0
  
  readAll: (idxs...) -> @read x for x in idxs

class State
  constructor: (@memory, @ip = 0) ->
    @registers = new Registers()
    @compareStatus = 0
    if 'number' isnt typeof @ip
      throw new TypeError 'invalid instruction-pointer type'
  
  getEqualFlag: -> @compareStatus is 0
  
  getGreaterFlag: -> @compareStatus is 1
  
  jump: (register) -> @ip = @registers.read register
  
  step: -> ++@ip
  
  readInstruction: -> @memory.read @ip

if module?
  module.exports = State
else if window?
  window.LangBlue ?= {}
  window.LangBlue.State = State
