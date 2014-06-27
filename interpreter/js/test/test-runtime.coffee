Runtime = require '../runtime'

content = require('fs').readFileSync __dirname + '/compiled.bin'
theMemory = []
i = 0
while i < content.length - 3
  theMemory.push content.readUInt32LE(i) >>> 0
  i += 4

rt = new Runtime theMemory, 0, (char) ->
  process.stdout.write new Buffer [char]
loop
  rt.runNext()
