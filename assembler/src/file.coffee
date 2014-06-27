if module?
  Token = require './token'
else if window?
  Token = window.LangBlue?.Token

throw new Error 'missing Token class' if not Token?

class File
  constructor: (contents) ->
    lines = contents.split '\n'
    @tokens = []
    for line, i in lines
      uncommented = line.replace(/#.*$/, '').trim()
      continue if uncommented.length is 0
      @tokens.push new Token uncommented, i

if module?
  module.exports = File
else if window?
  window.LangBlue ?= {}
  window.LangBlue.File = File
