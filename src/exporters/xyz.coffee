fs = require 'fs'

{wait,async} = require "../toolbox"

class module.exports

  constructor: (@path, options) ->
    @outStream = fs.createWriteStream @path, flags: 'w'

  close: (cb) =>
    @outStream.end()
    @outStream.destroySoon()
    async cb

  # http://www.laserscanning.org.uk/forum/viewtopic.php?f=22&t=743
  write: (position, material) =>
    return if material.id is 0
    [x, y, z] = position
    @outStream.write "#{x} #{y} #{z}\n" # no material