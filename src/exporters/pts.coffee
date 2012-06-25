fs = require 'fs'

{wait,async} = require "../toolbox"

class module.exports

  constructor: (@path, options) ->
    @outStream = fs.createWriteStream @path, flags: 'w'
    @onEnd = if options.onEnd? then options.onEnd else ->
    @nbPoints = options.nbPoints
    @outStream.write "#{@nbPoints}\n"

  close: =>
    #@outStream.close()
    async =>
      @onEnd()

  # http://www.laserscanning.org.uk/forum/viewtopic.php?f=22&t=743
  write: (x, y, z, material) =>
    return if material.id is 0

    # intensity value 
    #(the fraction of incident radiation reflected by a surface)
    #X Y Z Intensity value R G B
    intensityValue = -300
    [r,g,b] = material.rgb
    @outStream.write "#{x} #{y} #{z} #{1} #{r} #{g} #{b}\n"
