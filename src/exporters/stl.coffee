fs = require 'fs'
{log} = require 'util'

{wait,async} = require "../toolbox"

# ported from 
# https://github.com/codys/minecraft.print/blob/master/minecraft_print.py

class module.exports

  constructor: (@path, options) ->
    @outStream = fs.createWriteStream @path, flags: 'w'
    @onEnd = if options.onEnd? then options.onEnd else ->
    @nbPoints = options.nbPoints

    @width = options.width
    @height = options.height
    @depth = options.depth

    @matrix = options.matrix

    @str_e = "    endloop\n  endfacet\n"
    @str_s = (x,y,z) -> "  facet normal #{x} #{y} #{y}\n    outer loop\n"
    @str_v = (x,y,z) -> "      vertex #{x} #{y} #{z}\n"    

    #@outStream.write "start\n"
    @outStream.write "solid Pot\n"

  close: =>
    #@outStream.close()
    @outStream.write "endsolid Pot\n"
    async =>
      @onEnd()

  # http://www.laserscanning.org.uk/forum/viewtopic.php?f=22&t=743
  write: (x, y, z, material) =>
    return if material.id is 0
    log "writing!"
    # intensity value 
    #(the fraction of incident radiation reflected by a surface)
    #X Y Z Intensity value R G B
    intensityValue = -300
    [r,g,b] = material.rgb

    if x is 0 or @matrix(x-1,y,z).id <= 0
      @outStream.write [@str_s(-1,0,0),@str_v(x,z+1,y), @str_v(x,z,y+1), @str_v(x,z+1,y+1), @str_e].join('')
      @outStream.write [@str_s(-1,0,0),@str_v(x,z+1,y), @str_v(x,z,y),@str_v(x,z,y+1),@str_e].join('')
    if x is @width-1 or @matrix(x+1,y,z).id <= 0
      @outStream.write [@str_s(1,0,0),@str_v(x+1,z+1,y), @str_v(x+1,z+1,y+1),@str_v(x+1,z,y+1),@str_e].join('')
      @outStream.write [@str_s(1,0,0),@str_v(x+1,z+1,y), @str_v(x+1,z,y+1),@str_v(x+1,z,y),@str_e].join('')
    if (z is 0) or @matrix(x,y,z-1).id <= 0
      @outStream.write [@str_s(0,0,-1),@str_v(x,z,y), @str_v(x+1,z,y+1),@str_v(x,z,y+1),@str_e].join('')
      @outStream.write [@str_s(0,0,-1),@str_v(x,z,y), @str_v(x+1,z,y),@str_v(x+1,z,y+1),@str_e].join('')
    if (z is @depth-1) or @matrix(x,y,z+1).id <= 0
      @outStream.write [@str_s(0,0,1),@str_v(x,z+1,y), @str_v(x,z+1,y+1),@str_v(x+1,z+1,y+1),@str_e].join('')
      @outStream.write [@str_s(0,0,1),@str_v(x,z+1,y), @str_v(x+1,z+1,y+1),@str_v(x+1,z+1,y),@str_e].join('')
    if (y is 0) or @matrix(x,y-1,z).id <= 0
      @outStream.write [@str_s(0,-1,0),@str_v(x+1,z,y), @str_v(x,z+1,y),@str_v(x+1,z+1,y),@str_e].join('')
      @outStream.write [@str_s(0,-1,0),@str_v(x+1,z,y), @str_v(x,z,y),@str_v(x,z+1,y),@str_e].join('')
    if (y is @height-1) or @matrix(x,y+1,z).id <= 0
      @outStream.write [@str_s(0,1,0),@str_v(x+1,z,y+1), @str_v(x+1,z+1,y+1),@str_v(x,z+1,y+1),@str_e].join('')
      @outStream.write [@str_s(0,1,0),@str_v(x+1,z,y+1), @str_v(x,z+1,y+1),@str_v(x,z,y+1),@str_e].join('')

       
