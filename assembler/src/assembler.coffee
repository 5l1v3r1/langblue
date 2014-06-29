if module?
  SymbolTable = require './symbol-table'
else if window?
  SymbolTable = window.LangBlue?.SymbolTable

throw new Error 'missing SymbolTable class' if not SymbolTable?

class Assembler
  constructor: (@file) ->
    @symbols = new SymbolTable()
    @code = []
    for token in @file.tokens
      if token.isSymbol()
        @symbols.handleSymbolToken token
      else if token.isStore() and token.isSymbolicStore()
        @symbols.handleSymbolicStore token
      code.push x for x in token.encode()
  
  encode: -> code: @code, symbols: @symbols.encode()

if module?
  module.exports = Assembler
else if window?
  window.LangBlue ?= {}
  window.LangBlue.Assembler = Assembler
