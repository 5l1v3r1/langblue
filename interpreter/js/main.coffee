Runtime = require './runtime'
fs = require 'fs'

if process.argv.length isnt 3
  console.log 'Usage: coffee main.coffee <raw file>'
  process.exit 1

dataCb = (data) -> process.stdout.write new Buffer data

runCode = (code) ->
  loop
    if not code.runNext()
      console.error 'input not supported yet!'
      process.exit 1

fs.readFile process.argv[2], (err, data) ->
  if err?
    console.error err
    process.exit 1
  if data.length % 4 isnt 0
    throw new RangeError 'all machine code files are multiples of 4 in length'
  codeTokens = []
  i = 0
  while i < data.length
    codeTokens.push data.readUInt32LE(i) >>> 0
    i += 4
  rt = new Runtime codeTokens, 0, dataCb
  runCode rt
