fs = require 'fs'
{log} = require 'util'

{wait,async} = require "../toolbox"

# ported from 
# https://github.com/codys/minecraft.print/blob/master/minecraft_print.py

class module.exports

  constructor: (@path, options) ->
    #@outStream = fs.createWriteStream @path, flags: 'w'
    @onEnd = if options.onEnd? then options.onEnd else ->
    @nbPoints = options.nbPoints

    @width = options.width
    @height = options.height
    @depth = options.depth

    @matrix = options.matrix

    #@buff += "start\n"
    @buff = "solid Pot\n"


  close: =>
    #@outStream.close()
    @buff += "endsolid Pot\n"
    fs.writeFile @path, @buff, (err) =>
      throw err if err
      async => @onEnd()

  write: (x, y, z, material) =>
    return 0 if material.id is 0

    end = "    endloop\n  endfacet\n"

    n = (x,y,z) -> "  facet normal #{x} #{y} #{z}\n    outer loop\n"
    v = (x,y,z) -> "      vertex #{x} #{y} #{z}\n"    

    #log "writing #{x}#{y}#{z}"
    # intensity value 
    #(the fraction of incident radiation reflected by a surface)
    #X Y Z Intensity value R G B
    intensityValue = -300
    [r,g,b] = material.rgb

    if (x is 0) or @matrix([x-1,y,z]).id <= 0
      @buff += "#{n -1,0,0  }#{v x,z+1,y   }#{v x,   z,  y+1}#{v x,  z+1,y+1}"+end
      @buff += "#{n -1,0,0  }#{v x,z+1,y   }#{v x,   z,  y  }#{v x,  z,  y+1}"+end
    if x is @width-1 or @matrix([x+1,y,z]).id <= 0
      @buff += "#{n  1,0,0  }#{v x+1,z+1,y }#{v x+1, z+1,y+1}#{v x+1,z,  y+1}"+end
      @buff += "#{n  1,0,0  }#{v x+1,z+1,y }#{v x+1, z,  y+1}#{v x+1,z,  y  }"+end
    if (z is 0) or @matrix([x,y,z-1]).id <= 0
      @buff += "#{n  0,0,-1 }#{v x,  z,  y }#{v x+1, z,  y+1}#{v x,  z,  y+1}"+end
      @buff += "#{n  0,0,-1 }#{v x,  z,  y }#{v x+1, z,  y  }#{v x+1,z,  y+1}"+end
    if (z is @depth-1) or @matrix([x,y,z+1]).id <= 0
      @buff += "#{n  0,0,1  }#{v x,  z+1,y }#{v x,   z+1,y+1}#{v x+1,z+1,y+1}"+end
      @buff += "#{n  0,0,1  }#{v x,  z+1,y }#{v x+1, z+1,y+1}#{v x+1,z+1,y  }"+end
    if (y is 0) or @matrix([x,y-1,z]).id <= 0
      @buff += "#{n  0,-1,0 }#{v x+1,z,  y }#{v x,  z+1, y  }#{v x+1,z+1,y  }"+end
      @buff += "#{n  0,-1,0 }#{v x+1,z,  y }#{v x,  z,   y  }#{v x,  z+1,y  }"+end
    if (y is @height-1) or @matrix([x,y+1,z]).id <= 0
      @buff += "#{n  0,1,0  }#{v x+1,z,y+1}#{v x+1,z+1, y+1 }#{v x,  z+1,y+1}"+end
      @buff += "#{n  0,1,0  }#{v x+1,z,y+1}#{v x,  z+1, y+1 }#{v x,  z,  y+1}"+end
    1

       
