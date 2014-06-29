if module?
  SymbolTable = require './symbol-table'
  Relocator = require './relocator'
  Token = require './token'
else if window?
  SymbolTable = window.LangBlue?.SymbolTable
  Relocator = window.LangBlue?.Relocator
  Token = window.LagBlue?.Token

throw new Error 'missing SymbolTable class' if not SymbolTable?
throw new Error 'missing Relocator class' if not Relocator?
throw new Error 'missing Token class' if not Token?

class Assembler extends Relocator
  constructor: (script) ->
    super()
    lines = script.split '\n'
    for line, i in lines
      uncommented = line.replace(/;.*$/, '').trim()
      continue if uncommented.length is 0
      token = Token.parse i, uncommented, @code.length
      @code.push x for x in token.encode()
      if token.isSymbol()
        @symbols.handleSymbolToken token
      else if token.isStore() and token.isSymbolicStore()
        @symbols.handleSymbolicStore token
    @relocateAll()

if module?
  module.exports = Assembler
else if window?
  window.LangBlue ?= {}
  window.LangBlue.Assembler = Assembler
