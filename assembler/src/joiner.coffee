if module?
  Relocator = require './relocator'
else if window?
  Relocator = window?.LangBlue?.Relocator

if not Relocator?
  throw new Error 'missing Relocator class'

class Joiner extends Relocator
  append: (object) ->
    object.symbols.offset @code.length
    @code = @code.concat object.code
    @symbols.append object.symbols
    @relocateAll()

if module?
  module.exports = Joiner
else if window?
  window.LangBlue ?= {}
  window.LangBlue.Joiner = Joiner
