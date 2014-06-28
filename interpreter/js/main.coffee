fs = require 'fs'
Executor = require './executor'

if process.argv.length isnt 3
  console.log 'Usage: coffee main.coffee <raw file>'
  process.exit 1

fs.readFile process.argv[2], (err, data) ->
  if err?
    console.error err
    process.exit 1
  new Executor(data).start()
