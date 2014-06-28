###############################
# Node-specific code executor #
###############################

Runtime = require './runtime'
Memory = require './memory'
State = require './state'

class Executor
  constructor: (codeBuf) ->
    if not Buffer.isBuffer codeBuf
      throw new TypeError 'invalid code type'
    if codeBuf.length % 4 isnt 0
      throw new RangeError 'invalid code length'
    numbers = []
    for i in [0...codeBuf.length] by 4
      numbers.push codeBuf.readUInt32LE(i) >>> 0
    state = new State new Memory numbers
    @runtime = new Runtime state, Executor.outputCb
    @isWaiting = false
    @dataCallback = (buffer) =>
      if not Buffer.isBuffer buffer
        throw new TypeError 'invalid callback data type'
      @runtime.readBuffer.push x for x in buffer
      if @isWaiting
        @_runNext()
  
  start: ->
    process.stdin.on 'data', @dataCallback
    @_runNext()
  
  stop: ->
    process.stdin.removeListener @dataCallback
  
  _runNext: ->
    result = @runtime.next()
    if result
      setImmediate => @_runNext()
    else
      @isWaiting = true
  
  @outputCb: (num) -> process.stdout.write String.fromCharCode num

module.exports = Executor
