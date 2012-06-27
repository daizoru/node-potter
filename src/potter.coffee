#!/usr/bin/env coffee

# ...
{log,error,inspect} = require 'util'
fs = require 'fs'

# third-party libs
#Canvas = require 'canvas'
#Color = require 'color'
#  "snappy"            : "1.2.0",
# "libyaml"           : "0.1.1",

# module libs
{wait,async} = require './toolbox'

# we use color 0.4.1, but we could also use:
# https://github.com/One-com/one-color

# we use node-canvas for all drawing operation
# because it's faster and mature

len = (p1, p2) ->
  dx = p2[0] - p1[0]
  dy = p2[1] - p1[1]
  dz = p2[2] - p1[2]

  sm = dx*dx + dy*dy + dz*dz
  #log "sm: #{sm}"
  Math.round(Math.sqrt sm)

readPath = (p1, p2) ->
  dx = p2[0] - p1[0]
  dy = p2[1] - p1[1]
  dz = p2[2] - p1[2]

  sm = dx*dx + dy*dy + dz*dz
  #log "sm: #{sm}"
  resolution = Math.round(Math.sqrt sm)

  if resolution < 1
    #log "resolution 0 not handled yet"
    return []

  points = []
    #log "res: #{resolution}"
  # now we search the position of every point
  for i in [0..resolution]
    #log "ok: #{i}"
    r = i / resolution # ratio
    x = Math.round( p1[0] + dx * r )
    y = Math.round( p1[1] + dy * r )
    z = Math.round( p1[2] + dz * r )
    points.push [x,y,z]
  points


toRGB = (num) -> #num = parseInt color, 16
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
    [r, g, b] = @rgb = toRGB @id
    @rgbaString = "rgba(#{r},#{g},#{b},0)"
    @hexString = rgbToHex r, g, b
    @rgbInt = rgbToInt r, g, b
    
    #log "#{@}"
  toString: ->
   "mat #{@id} (#{@name}) is #{@color} and #{@type}"

class module.exports

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

    @points = {}
    @count = 0
    @materials = {}
    @currentMaterial = no

    # create material #0, which is basically empty space in the model
    @createMaterial "vacuum", "invisible", "vacuum"

  createMaterial: (name, color, type) ->
    id = Object.keys(@materials).length
    material = new Material id, name, color, type
    @materials[id] = material
    material

  use: (material) ->
    if material
      @currentMaterial = material
    else
      msg = "Error, no material"
      error msg
      throw msg
      return

  dot: (p) =>
    id = "#{Math.round(p[0])},#{Math.round(p[1])},#{Math.round(p[2])}"
    @count++ unless id of @points
    @points[id] = @currentMaterial

  line: (p1, p2, material=no) ->
    #log "p1: #{p1} p2: #{p2}"
    points = readPath p1, p2
    #log "drawing points"
    #console.dir points
    @dot p for p in points

  #face: (p1, p2) ->
  #  width = len 
    
  sphere: (p, radius) =>

    res = radius
    M = res * 3
    N = res * 6
    f = (m,n) -> [
      Math.sin(Math.PI * m/M) * Math.cos(Math.PI*2 * n/N)
      Math.sin(Math.PI * m/M) * Math.sin(Math.PI*2 * n/N)
      Math.cos(Math.PI * m/M)
    ]

    for m in [0..M]
      for n in [0...N]
        s = f m,n

        [x,y,z] = [
          Math.round(p[0] + s[0]*radius)
          Math.round(p[1] + s[1]*radius)
          Math.round(p[2] + s[2]*radius)
        ]
        #console.log "#{[x,y,z]}"
        @dot [x,y,z]
        #@dot [x1,y1,z1]

  readVoxel: (p) =>
    id = "#{Math.round(p[0])},#{Math.round(p[1])},#{Math.round(p[2])}" 
    m = @points[id]
    #log "id: #{id} -> #{m} -> #{@materials[0]}"
    if m? then m else @materials[0]

  trace: (keypoints,fn) =>
    for i in [0...keypoints.length-1]
      #log " #{keypoints[0]} -> #{keypoints[i+1]}"
      points = readPath keypoints[i], keypoints[i+1]
      for point in points
        fn point

  
  dig: =>


  # save the voxels to a file
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
      nbPoints: @count
      width: @width
      height: @height
      depth: @depth
      matrix: (p) => @readVoxel p
      onEnd: -> onComplete()

    wrote = 0
    progress = 0
    milestone = Math.round(@count * 0.1)

    log "writing voxels:"
    for id,material of @points
      s = id.split ','
      [x,y,z] = [
        parseInt s[0]
        parseInt s[1]
        parseInt s[2]
      ]
      exp.write x, y, z, material
      wrote++
      unless wrote % milestone
        progress += 10
        log " #{progress}% (#{wrote})" 

    log " generated 100% (#{wrote}}) of geometries, writing to disk.."
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
