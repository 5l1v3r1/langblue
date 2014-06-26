class Object
  constructor: (@info) ->
    throw new TypeError 'invalid info' if @_isValid()
  
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
      return false if not (symbol.relocations instanceof Array)
      for reloc in symbol.relocations
        return false if 'number' isnt typeof reloc
    return true
  