fs = require 'fs'

{wait,async} = require "../toolbox"

class module.exports

  constructor: (@path, options) ->
    @outStream = fs.createWriteStream @path, flags: 'w'
    @onEnd = if options.onEnd? then options.onEnd else ->

  close: =>
    #@outStream.close()
    async =>
      @onEnd()

  # http://www.laserscanning.org.uk/forum/viewtopic.php?f=22&t=743
  write: (x, y, z, material) =>
    return if material.id is 0
    @outStream.write "#{x} #{y} #{z}\n" # no material