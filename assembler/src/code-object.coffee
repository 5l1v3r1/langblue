class CodeObject
  constructor: (@info) ->
    throw new TypeError 'invalid info' if not @_isValid()
  
  concat: (codeObject) ->
    result = @copy()
    result.info.code = result.info.code.concat codeObject.getCode()
    for symbol in codeObject.getSymbols()
      result._mergeSymbol @getCode().length, symbol
    result._relocateAll()
    return result
  
  getCode: -> return @info.code
  
  getSymbols: -> return @info.symbols
  
  copy: ->
    resultInfo = symbols: [], code: @getCode().slice 0
    for symbol in @getSymbols()
      symbolCopy =
        name: symbol.name
        address: symbol.address
        exists: symbol.exists
        relocations: symbol.relocations.slice 0
      resultInfo.symbols.push symbolCopy
    return new CodeObject resultInfo
  
  _relocate: (codeAddr, address) ->
    code = @getCode()
    if codeAddr + 2 > code.length
      throw new RangeError 'relocation address out of bounds'
    code[codeAddr] &= 0xffff
    code[codeAddr + 1] &= 0xffff
    code[codeAddr] |= (address & 0xffff) << 0x10
    code[codeAddr + 1] |= (address >>> 0x10) << 0x10
  
  _mergeSymbol: (offset, symbol) ->
    for localSym in @getSymbols()
      continue if not localSym.name?
      continue if symbol.name isnt localSym.name
      if localSym.exists and symbol.exists
        throw new Error 'duplicate symbol "' + symbol.name + '"'
      if symbol.exists
        localSym.address = symbol.address + offset
        localSym.exists = true
      for relocation in symbol.relocations
        localSym.relocations.push relocation + offset
      return
    newSym =
      name: symbol.name
      exists: symbol.exists
      address: symbol.address + offset
    newSym.relocations = (x + offset for x in symbol.relocations)
    @getSymbols().push newSym
  
  _relocateAll: ->
    for symbol in @getSymbols()
      for relocation in symbol.relocations
        @_relocate relocation, symbol.address
  
  _isValid: ->
    return false if not (@info.code instanceof Array)
    return false if not (@info.symbols instanceof Array)
    for number in @info.code
      return false if 'number' isnt typeof number
    for symbol in @info.symbols
      return false if 'object' isnt typeof symbol
      return false if 'number' isnt typeof symbol.address
      return false if 'boolean' isnt typeof symbol.exists
      if symbol.name?
        return false if 'string' isnt typeof symbol.name
        return false if not /^[1-9a-zA-Z_]*$/.exec(symbol.name)?
      return false if not (symbol.relocations instanceof Array)
      for reloc in symbol.relocations
        return false if 'number' isnt typeof reloc
        return false if reloc + 2 > @info.code.length
    return true

if module?
  module.exports = CodeObject
else if window?
  window.LangBlue ?= {}
  window.LangBlue.CodeObject = CodeObject
