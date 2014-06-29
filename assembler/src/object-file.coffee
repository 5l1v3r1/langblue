if module?
  SymbolTable = require './symbol-table'
else if window?
  SymbolTable = window?.LangBlue?.SymbolTable

throw new Error 'missing SymbolTable class' if not SymbolTable?

class ObjectFile
  constructor: (@code = [], @symbols = new SymbolTable()) ->
    if not (@code instanceof Array)
      throw new TypeError 'code must be Array of numbers'
    if not (@symbols instanceof SymbolTable)
      throw new TypeError 'symbols must be SymbolTable instance'
  
  decodeJSON: (jsObject) ->
    if 'object' isnt typeof jsObject
      throw new TypeError 'invalid JSON root type'
    if not (jsObject.code instanceof Array)
      throw new TypeError 'code must be Array'
    if not (jsObject.symbols instanceof Array)
      throw new TypeError 'symbols must be Array'
    @code = jsObject.code
    @symbols = SymbolTable.decode jsObject.symbols
  
  encode: -> code: @code, symbols: @symbols.encode()
  
  @fromJSON: (js) ->
    obj = new ObjectFile()
    obj.decodeJSON js
    return obj

if module?
  module.exports = ObjectFile
else if window?
  window.LangBlue ?= {}
  window.LangBlue.ObjectFile = ObjectFile
