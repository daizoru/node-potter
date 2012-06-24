#!/usr/bin/env coffee

# ...
{log,error,inspect} = require 'util'
fs = require 'fs'

# third-party libs
Canvas = require 'canvas'
#Color = require 'color'

# we use color 0.4.1, but we could also use:
# https://github.com/One-com/one-color

# we use node-canvas for all drawing operation
# because it's faster and mature


toRGB = (num) -> #num = parseInt color, 16
  [ num >> 16, num >> 8 & 255, num & 255 ]

setPixel = (img, x, y, r, g, b, a) ->
  index = (x + y * img.width) * 4
  img.data[index+0] = r
  img.data[index+1] = g
  img.data[index+2] = b
  img.data[index+3] = a



class Material

  constructor: (@id,@name,@color,@type='continuous') ->

    # used for drawing
    [r,g,b] = toRGB @id
    @rgba = "rgba(#{r},#{g},#{b},0)"
    
    log "#{@}"
  toString: ->
   "Material(id: #{@id}, name: #{@name}, color: #{@color}, type: #{@type}, rgba: #{@rgba})"

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
    for x in [0..@depth] # @height included
      canvas = new Canvas @width, @height
      ctx = canvas.getContext '2d'
      @slices.push [ canvas, ctx ]
    #log "slices: #{inspect @slices}"

    @materials = []
    @lastUsed = no

    # create material #0, which is basically empty space in the model
    @createMaterial "vacuum", "invisible", "vacuum"

  createMaterial: (name, color, type) ->
    id = @materials.length
    material = new Material id, name, color, type
    @materials.push material
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
    [canvas, ctx] = @slices[z-1]
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

    #log "material: #{inspect material.id}"
    # draw it!
    #log "drawing using: #{material.rgba}"
    ctx.fillStyle = material.rgba
    ctx.fillRect x, y, 1, 1
    ctx.stroke()

  save: (path=no) =>
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

pot.save "examples/slices/test_"
#harry.cast()

