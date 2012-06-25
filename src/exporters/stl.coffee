fs = require 'fs'

{wait,async} = require "../toolbox"

# ported from 
# https://github.com/codys/minecraft.print/blob/master/minecraft_print.py

class module.exports

  constructor: (@path, options) ->
    @outStream = fs.createWriteStream @path, flags: 'w'
    @onEnd = if options.onEnd? then options.onEnd else ->
    @nbPoints = options.nbPoints

    @str_e = "    endloop\n  endfacet\n"
    @str_s = (x,y,z) -> "  facet normal #{x} #{y} #{y}\n    outer loop\n"
    @str_v = (x,y,z) -> "      vertex #{x} #{y} #{z}\n"    

    @outStream.write "start\n"
    @outStream.write "solid Pot\n"

  close: =>
    #@outStream.close()
    @outStream.write "endsolid Pot\n"
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

    # TODO we need to access the matrix for conversion. well, okay. I'll do it later..

    # TODO
    return

    if x is 0 or self.object_array[x-1][y][z] <= 0
      @outStream.write("".join([str_s(-1,0,0),str_v(x,z+1,y), str_v(x,z,y+1),str_v(x,z+1,y+1),str_e]))
      @outStream.write("".join([str_s(-1,0,0),str_v(x,z+1,y), str_v(x,z,y),str_v(x,z,y+1),str_e]))
    if x is width-1 or self.object_array[x+1][y][z] <= 0
      @outStream.write("".join([str_s(1,0,0),str_v(x+1,z+1,y), str_v(x+1,z+1,y+1),str_v(x+1,z,y+1),str_e]))
      @outStream.write("".join([str_s(1,0,0),str_v(x+1,z+1,y), str_v(x+1,z,y+1),str_v(x+1,z,y),str_e]))
    if (z is 0) or self.object_array[x][y][z-1] <= 0
      @outStream.write("".join([str_s(0,0,-1),str_v(x,z,y), str_v(x+1,z,y+1),str_v(x,z,y+1),str_e]))
      @outStream.write("".join([str_s(0,0,-1),str_v(x,z,y), str_v(x+1,z,y),str_v(x+1,z,y+1),str_e]))
    if (z is depth-1) or self.object_array[x][y][z+1] <= 0
      @outStream.write("".join([str_s(0,0,1),str_v(x,z+1,y), str_v(x,z+1,y+1),str_v(x+1,z+1,y+1),str_e]))
      @outStream.write("".join([str_s(0,0,1),str_v(x,z+1,y), str_v(x+1,z+1,y+1),str_v(x+1,z+1,y),str_e]))
    if (y is 0) or self.object_array[x][y-1][z] <= 0
      @outStream.write("".join([str_s(0,-1,0),str_v(x+1,z,y), str_v(x,z+1,y),str_v(x+1,z+1,y),str_e]))
      @outStream.write("".join([str_s(0,-1,0),str_v(x+1,z,y), str_v(x,z,y),str_v(x,z+1,y),str_e]))
    if (y is height-1) or self.object_array[x][y+1][z] <= 0
      @outStream.write("".join([str_s(0,1,0),str_v(x+1,z,y+1), str_v(x+1,z+1,y+1),str_v(x,z+1,y+1),str_e]))
      @outStream.write("".join([str_s(0,1,0),str_v(x+1,z,y+1), str_v(x,z+1,y+1),str_v(x,z,y+1),str_e]))

       