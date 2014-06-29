class Symbol
  constructor: (@relocations, @offset) ->
  
  move: (count) ->
    @offset += count if @offset?
    for i in [0...@relocations.length] by 1
      @relocations[i] += count

class SymbolTable
  constructor: ->
    @symbols = {}
    @hidden = []
  
  handleSymbolToken: (token) ->
    if @symbols[token.name]?.offset?
      throw new Error "duplicate symbol #{token.name} on line #{token.line}"
    @symbols[token.name] ?= new Symbol [], null
    @symbols[token.name].offset = token.offset
  
  handleSymbolicStore: (token) ->
    @symbols[token.value] ?= new Symbol [], null
    @symbols[token.value].relocations.push token.offset
  
  offset: (count) ->
    for name, obj of @symbols
      obj.move count
    for obj in @hidden
      obj.move count
  
  append: (table) ->
    for name, symbol of table.symbols
      if @symbols[name]?
        thisSymbol = @symbols[name]
        if thisSymbol.offset? and symbol.offset?
          throw new Error 'duplicate symbol: ' + name
        thisSymbol.offset ?= symbol.offset
        for x in symbol.relocations
          thisSymbol.relocations.push x
      else
        @symbols[name] = symbol
    for hidden in table.hidden
      @hidden.push hidden
  
  encode: ->
    result = []
    for name, symbol of @symbols
      hidden = name[0] is '_'
      if hidden and not symbol.offset?
        throw new Error 'hidden symbol not defined: ' + name
      result.push
        name: if hidden then null else name
        address: symbol.offset ? 0
        exists: symbol.offset?
        relocations: symbol.relocations
    for symbol in @hidden
      if not symbol.offset?
        throw new Error 'hidden symbol not located'
      result.push
        name: null
        address: symbol.offset ? 0
        exists: symbol.offset?
        relocations: symbol.relocations
    return result
  
  @decode: (symbolArray) ->
    if not (symbolArray instanceof Array)
      throw new TypeError 'invalid symbol array type'
    table = new SymbolTable()
    for info in symbolArray
      address = if info.exists then info.address else null
      if info.name?
        table.symbols[info.name] = new Symbol info.relocations, address
      else
        table.hidden.push new Symbol info.relocations, address
    return table

if module?
  module.exports = SymbolTable
else if window?
  window.LangBlue ?= {}
  window.LangBlue.SymbolTable = SymbolTable
