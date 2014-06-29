if module?
  ObjectFile = require './object-file'
else if window?
  ObjectFile = window?.LangBlue?.ObjectFile

throw new Error 'missing ObjectFile class' if not ObjectFile?

class Relocator extends ObjectFile
  relocateAll: ->
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
  module.exports = Relocator
else if window?
  window.LangBlue ?= {}
  window.LangBlue.Relocator = Relocator
