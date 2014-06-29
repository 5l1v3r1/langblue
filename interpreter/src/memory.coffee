class Memory
  constructor: (@array = [], @maximum = 0x10000) ->
    if not (@array instanceof Array)
      throw new TypeError 'invalid memory type'
  
  read: (address) ->
    if isNaN(address) or 'number' isnt typeof address
      throw new TypeError 'invalid address: ' + address
    if address < 0 or address >= @maximum
      throw new RangeError 'memory address out of bounds: ' + address
    return @array[address]
  
  write: (address, value) ->
    if isNaN(address) or 'number' isnt typeof address
      throw new TypeError 'invalid address: ' + address
    if address < 0 or address >= @maximum
      throw new RangeError 'memory address out of bounds: ' + address
    @array[address] = value >>> 0

if module?
  module.exports = Memory
else if window?
  window.LangBlue ?= {}
  window.LangBlue.Memory = Memory
