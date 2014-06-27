if module?
  Token = require './token'
else if window?
  Token = window.LangBlue?.Token

throw new Error 'missing Token class' if not Token?

class File
  constructor: (contents) ->
    @tokens = []
    lines = contents.split '\n'
    offset = 0
    for line, i in lines
      uncommented = line.replace(/#.*$/, '').trim()
      continue if uncommented.length is 0
      token = new Token uncommented, i, offset
      @tokens.push token
      offset += token.getSize()

if module?
  module.exports = File
else if window?
  window.LangBlue ?= {}
  window.LangBlue.File = File
