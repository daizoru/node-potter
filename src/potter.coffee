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
   "Material(id: #{@id}, name: #{@name}, color: #{@color}, type: #{@type}, rgb: (#{@rgb.r},#{@rgb.g},#{@rgb.b})})"

class Potter

  constructor: (url) ->
    @size =
      x: 12
      y: 12
      z: 12

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
      onEnd: -> onComplete()

    z = -1
    for slice in @slices
      z++
      [canvas,ctx] = slice
      imgd = ctx.getImageData 0, 0, @width, @height
      for x in [0...@width]
        for y in [0...@height]
          i = (x + y * @width) * 4
          #log "i: #{i}"
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
pot = new Potter()
clay = pot.createMaterial "clay", "brown"

# draw something
pot.draw 5, 5, 5, clay
pot.draw 4, 5, 6
pot.draw 5, 3, 7


pot.save "examples/exports/test.pcd", ->
  log "file saved"

#pot.save "examples/slices/test_"
#harry.cast()

