#!/usr/bin/env coffee

# ...
{log,error,inspect} = require 'util'
fs = require 'fs'

# third-party libs
Canvas = require 'canvas'
#Color = require 'color'

# module libs
{wait,async} = require './toolbox'

# we use color 0.4.1, but we could also use:
# https://github.com/One-com/one-color

# we use node-canvas for all drawing operation
# because it's faster and mature


toRGBString = (num) -> #num = parseInt color, 16
  [ num >> 16, num >> 8 & 255, num & 255 ]

rgbToInt = (r, g, b) -> (r << 16) + (g << 8) + b

rgbToHex = (r, g, b) ->
  "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)

setPixel = (img, x, y, r, g, b, a) ->
  index = (x + y * img.width) * 4
  img.data[index+0] = r
  img.data[index+1] = g
  img.data[index+2] = b
  img.data[index+3] = a



class Material

  constructor: (@id,@name,@color,@type='continuous') ->

    # used for drawing
    [r, g, b] = @rgb = toRGBString @id
    @rgbaString = "rgba(#{r},#{g},#{b},0)"
    @hexString = rgbToHex r, g, b
    @rgbInt = rgbToInt r, g, b
    
    log "#{@}"
  toString: ->
   "mat #{@id} (#{@name}) is #{@color} and #{@type}"

class Potter

  constructor: (options) ->
    @size =
      x: 32
      y: 32
      z: 32

    if options.size?
      if options.size.length is 3
        @size.x = Math.round((Number) options.size[0])
        @size.y = Math.round((Number) options.size[1])
        @size.z = Math.round((Number) options.size[2])

    # x should be the main, longer axis
    @width = Math.abs @size.x
    
    # y is often the side, maybe shorter axis
    @height = Math.abs @size.y

    # z is always the vertical axis
    @depth = Math.abs @size.z
    
    # initialize N layers
    log "initializing #{@depth} slices"
    @slices = []
    for x in [0...@depth] # @height included
      canvas = new Canvas @width, @height
      ctx = canvas.getContext '2d'
      @slices.push [ canvas, ctx ]
    #log "slices: #{inspect @slices}"

    @nbPoints = 0 # nb non-null points

    @materials = {}
    @lastUsed = no

    # create material #0, which is basically empty space in the model
    @createMaterial "vacuum", "invisible", "vacuum"

  createMaterial: (name, color, type) ->
    id = Object.keys(@materials).length
    material = new Material id, name, color, type
    @materials[id] = material
    material

  use: (material) ->
    if material
      @lastUsed = material
    else
      msg = "Error, no material"
      error msg
      throw msg
      return
    
  draw: (x, y, z, material=no) ->
    [canvas, ctx, imgd] = @slices[z]
    if material
      log "using material #{material.id}"
      @lastUsed = material
    else
      material = @lastUsed

    unless material
      msg = "Error, no material"
      error msg
      throw msg
      return

    # TODO handle cases where we ERASE points
    @nbPoints++

    #log "material: #{inspect material.id}"
    # draw it!
    log "drawing at (#{x}, #{y}) using: #{material.hexString}"
    ctx.fillStyle = material.hexString
    ctx.fillRect x, y, 1, 1
    ctx.stroke()

  
  readVoxel: (x,y,z) =>
    imgd = @slices[z][1].getImageData 0, 0, @width, @height
    i = (x + y * @width) * 4
    [r,g,b,a] = [imgd.data[i],imgd.data[i+1],imgd.data[i+2],imgd.data[i+3]]
    @materials[rgbToInt(r, g, b)]


  save: (path,onComplete=->) => async =>
    # keep file extension. remove any / or \ for security purposes
    ext = path.split(".")[-1..]#.substr("/","").substr("\\","")
    Exporter = require "./exporters/#{ext}"
    unless Exporter
      msg = "could not find exporter for format #{ext}"
      error msg
      throw msg
      onComplete()
      return

    exp = new Exporter path,
      nbPoints: @nbPoints
      width: @width
      height: @height
      depth: @depth
      matrix: (x,y,z) => @readVoxel x, y, z
      onEnd: -> onComplete()

    z = -1
    for slice in @slices
      z++
      [canvas,ctx] = slice
      imgd = ctx.getImageData 0, 0, @width, @height
      for x in [0...@width]
        for y in [0...@height]
          i = (x + y * @width) * 4
          [r,g,b,a] = [imgd.data[i],imgd.data[i+1],imgd.data[i+2],imgd.data[i+3]]
          materialId = rgbToInt r, g, b
          material = @materials[materialId]
          exp.write x, y, z, material

    log "calling exp.close()"
    exp.close()

  savePng: (path=no) =>
    log "saving:"
    i = -1
    path = __dirname+"/" unless path
    for slice in @slices
      i++
      p = "#{path}slice_#{i}.png"
      log " - #{p}"

      #slice[0].toBuffer (err, buf) ->
      #  throw err if err
      #  fs.writeFile p, buf

      out = fs.createWriteStream p
      stream = slice[0].createPNGStream()

      stream.on 'data', (chunk) ->
        out.write chunk

      stream.on 'end', ->
        #log 'saved slice'


  export: (url) ->

# quick & dirty testing
pot = new Potter size: [100,100,100]
clay = pot.createMaterial "clay", "brown"
plastic = pot.createMaterial "plastic", "red"
metal = pot.createMaterial "metal", "grey"

# draw something
pot.draw 5, 5, 5, plastic
pot.draw 4, 5, 6
pot.draw 5, 3, 7, metal

#log "max size: #{pot.computeMaxSize()}"
pot.save "examples/exports/test.stl", ->
  log "file saved"

#pot.save "examples/slices/test_"
#harry.cast()

