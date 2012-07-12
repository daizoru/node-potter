fs = require 'fs'
{log} = require 'util'

{wait,async} = require "../toolbox"

# http://local.wasp.uwa.edu.au/~pbourke/dataformats/ply/
# http://en.wikipedia.org/wiki/PLY_(file_format)

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
    @outStream.write "ply\n"
    @outStream.write "format ascii 1.0\n"
    @outStream.write "element vertex #{@nbPoints * 8}\n"
    @outStream.write "property float x\n"
    @outStream.write "property float y\n"
    @outStream.write "property float z\n"

    # how many cubes * 6 faces
    @outStream.write "element face #{@nbPoints * 6}\n"

    # This means that the property "vertex_index" contains first an unsigned char 
    # telling how many indices the property contains, followed by a list containing
    # that many integers. Each integer in this variable-length list is an index to a vertex.
    @outStream.write "property list uchar int vertex_index\n"

    @outStream.write "end_header\n"


  close: =>
    #@outStream.close()
    #@outStream.write "endsolid Pot\n"
    async =>
      @onEnd()

  # http://www.laserscanning.org.uk/forum/viewtopic.php?f=22&t=743
  write: (position, material) =>
    return if material.id is 0
    log "writing!"
    [x, y, z] = position
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

       
