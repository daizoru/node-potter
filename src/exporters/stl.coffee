fs = require 'fs'
{log} = require 'util'

{wait,async} = require "../toolbox"

# external dependencies
Put = require 'put'

# ported from 
# https://github.com/codys/minecraft.print/blob/master/minecraft_print.py

class module.exports

  constructor: (@path, options) ->
    @outStream = fs.createWriteStream @path, flags: 'w'
    @nbPoints = options.nbPoints

    @width = options.width
    @height = options.height
    @depth = options.depth

    @matrix = options.matrix

    @bin = yes

    buff = "solid Pot\n"
    @outStream.write buff


  close: (cb) =>
    buff = "endsolid Pot\n"
    @outStream.write buff

    #@outStream.end()
    @outStream.destroySoon()
    async cb
    #fs.writeFile @path, @buff, (err) =>
    #  throw err if err
    #  async => @onEnd()

  write: (position, material) =>
    return 0 if material.id is 0

    [x, y, z] = position
    #console.log "position: #{position}"

    end = "    endloop\n  endfacet\n"

    n = (x,y,z) -> "  facet normal #{x} #{y} #{z}\n    outer loop\n"
    v = (x,y,z) -> "      vertex #{x} #{y} #{z}\n"    

    #log "writing #{x}#{y}#{z}"
    # intensity value 
    #(the fraction of incident radiation reflected by a surface)
    #X Y Z Intensity value R G B
    intensityValue = -300
    [r,g,b] = material.rgb

    buff = ""
    if (x is 0)         or @isEmpty [x-1,y,z]
      buff += "#{n -1,0,0  }#{v x,z+1,y   }#{v x,   z,  y+1}#{v x,  z+1,y+1}"+end
      buff += "#{n -1,0,0  }#{v x,z+1,y   }#{v x,   z,  y  }#{v x,  z,  y+1}"+end
    if x is @width-1    or @isEmpty [x+1,y,z]
      buff += "#{n  1,0,0  }#{v x+1,z+1,y }#{v x+1, z+1,y+1}#{v x+1,z,  y+1}"+end
      buff += "#{n  1,0,0  }#{v x+1,z+1,y }#{v x+1, z,  y+1}#{v x+1,z,  y  }"+end
    if (z is 0)         or @isEmpty [x,y,z-1]
      buff += "#{n  0,0,-1 }#{v x,  z,  y }#{v x+1, z,  y+1}#{v x,  z,  y+1}"+end
      buff += "#{n  0,0,-1 }#{v x,  z,  y }#{v x+1, z,  y  }#{v x+1,z,  y+1}"+end
    if (z is @depth-1)  or @isEmpty [x,y,z+1]
      buff += "#{n  0,0,1  }#{v x,  z+1,y }#{v x,   z+1,y+1}#{v x+1,z+1,y+1}"+end
      buff += "#{n  0,0,1  }#{v x,  z+1,y }#{v x+1, z+1,y+1}#{v x+1,z+1,y  }"+end
    if (y is 0)         or @isEmpty [x,y-1,z]
      buff += "#{n  0,-1,0 }#{v x+1,z,  y }#{v x,  z+1, y  }#{v x+1,z+1,y  }"+end
      buff += "#{n  0,-1,0 }#{v x+1,z,  y }#{v x,  z,   y  }#{v x,  z+1,y  }"+end
    if (y is @height-1) or @isEmpty [x,y+1,z]
      buff += "#{n  0,1,0  }#{v x+1,z,y+1}#{v x+1,z+1, y+1 }#{v x,  z+1,y+1}"+end
      buff += "#{n  0,1,0  }#{v x+1,z,y+1}#{v x,  z+1, y+1 }#{v x,  z,  y+1}"+end

    @outStream.write buff

    1

  writeBinary: () ->
    put = Put()
    put = put.word16be 24930
    put = put.word32le 1717920867
    put = put.word8 103
    put = put.write @outStream

       
