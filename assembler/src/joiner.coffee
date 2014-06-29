if module?
  SymbolTable = require './symbol-table'
else if window?
  SymbolTable = window?.LangBlue?.SymbolTable

if not SymbolTable?
  throw new Error 'missing SymbolTable class'

class Joiner
  constructor: (@code, @symbols) ->
    if not (@code instanceof Array)
      throw new TypeError 'code must be Array of numbers'
    if not (@symbols instanceof SymbolTable)
      throw new TypeError 'symbols must be SymbolTable instance'
  
  append: (code, symbols) ->
    if not (code instanceof Array)
      throw new TypeError 'code must be Array of numbers'
    if not (symbols instanceof SymbolTable)
      throw new TypeError 'symbols must be SymbolTable instance'
    symbols.offset @code.length
    @code = @code.concat code
    @symbols.append symbols
    @_relocateAll()
  
  encode: -> code: @code, symbols: @symbols.encode()
  
  _relocateAll: ->
    for name, symbol of @symbols.symbols
      @_relocateSymbol symbol
    for symbol in @symbols.hidden
      @_relocateSymbol symbol
  
  _relocateSymbol: (symbol) ->
    return if not symbol.offset?
    for relocation in symbol.relocations
      @code[relocation] &= 0xffff
      @code[relocation] |= (symbol.offset & 0xffff) << 0x10
      @code[relocation + 1] &= 0xffff
      @code[relocation + 1] |= (symbol.offset & 0xffff0000)
      @code[relocation] >>>= 0
      @code[relocation + 1] >>>= 0

if module?
  module.exports = Joiner
else if window?
  window.LangBlue ?= {}
  window.LangBlue.Joiner = Joiner
