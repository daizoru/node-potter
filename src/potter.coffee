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

len = (p1, p2,round=yes) ->
  dx = p2[0] - p1[0]
  dy = p2[1] - p1[1]
  dz = p2[2] - p1[2]

  sm = dx*dx + dy*dy + dz*dz
  #log "sm: #{sm}"
  if round then Math.round(Math.sqrt(sm)) else Math.sqrt(sm)

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

  constructor: (@id, params={}) ->
    config =
      name: "default"
      type: "continuous"
      color: "grey"
      density:  1.43e6 # grams by cube meter
      scale: 1e-2 # 
      data: {}
    config[k] = v for k,v of params
    @[k] = v for k,v of config

    # used for drawing
    [r, g, b] = @rgb = toRGB @id
    @rgbaString = "rgba(#{r},#{g},#{b},0)"
    @hexString = rgbToHex r, g, b
    @rgbInt = rgbToInt r, g, b

    @count = 0
    
    #log "#{@}"
  toString: ->
   "mat #{@id} (#{@name}) is #{@color} and #{@type}"

  computeMass: ->
    @mass * count


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
    @vacuum = @material name: "vacuum", color: "invisible", type: "vacuum"

  material: (params={}) ->
    id = Object.keys(@materials).length
    material = new Material id, params
    @materials[id] = material
    material

  use: (material) -> 
    @currentMaterial = if material then material else @vacuum


  dot: (p, overwrite) =>
    @set p, @currentMaterial, overwrite

  # set a dot
  set: (p, m, overwrite=no) =>
    id = "#{Math.round(p[0])},#{Math.round(p[1])},#{Math.round(p[2])}"
    if !m or m.id is 0
      if id of @points
        #log "deleting with fire!!"
        delete @points[id]
        @count--
        # do not increment vacuum counter
    else
      if id of @points
        # ifEmpty option allow use to not add stuff in existing matter
        unless overwrite
          return
      else
        @count++
        m.count++ # increment all other counters
      @points[id] = m

  line: (p1, p2, overwrite) ->
    #log "p1: #{p1} p2: #{p2}"
    points = readPath p1, p2
    #log "drawing points"
    #console.dir points
    @dot p, overwrite for p in points

  #face: (p1, p2) ->
  #  width = len 
  
  each: (kernel) =>
    for id,material of @points
      s = id.split ','
      position = [
        parseInt s[0]
        parseInt s[1]
        parseInt s[2]
      ]
      kernel position, material

  map: (kernel) =>
    for id,material of @points
      s = id.split ','
      position = [
        parseInt s[0]
        parseInt s[1]
        parseInt s[2]
      ]
      @set position, kernel(position, material)

  filter: (kernel) =>
    @map (p, state) -> return state if (kernel(p, state))

  reduce: (accumulator, kernel) =>
    acc = accumulator
    @map (p, state) ->
      acc = kernel acc, p, state
    acc
    
  sum: (kernel) =>
    acc = 0
    @map (p, state) ->
      acc += kernel p, state
    acc
    
  reduce: (accumulator, kernel) =>
    acc = accumulator
    @map (p, state) ->
      acc = kernel acc, p, state
    acc

  sphere: (center, inner, outer, overwrite) =>
    i = inner
    o = outer
    c = center
    for x in     [ c[0]-o .. c[0]+o ]
      for y in   [ c[1]-o .. c[1]+o ]
        for z in [ c[2]-o .. c[2]+o ]
          @dot [x,y,z], overwrite if i <= len(c, [x,y,z]) <= o

  # cut a model in half, using a center (c) and a plane (v)
  section: (c, v) =>
    @map (p, m) =>
      return if (v[0] < 0 and p[0] > c[0]) or (v[0] > 0 and p[0] < c[0])
      return if (v[1] < 0 and p[1] > c[1]) or (v[1] > 0 and p[1] < c[1])
      return if (v[2] < 0 and p[2] > c[2]) or (v[2] > 0 and p[2] < c[2])
      m

  get: (p) =>
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

  # helper function, to translate things
  rename: (translations) =>
    for oldName, newName of translations
      @[newName] = @[oldName] if oldName of @
  
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
      matrix: (p) => @get p

    wrote = 0
    progress = 0
    milestone = Math.round(@count * 0.1)

    log "writing voxels:"
    @each (position, material) =>
      exp.write position, material
      wrote++
      unless wrote % milestone
        progress += 10
        log " #{progress}% (#{wrote})" 

    log " 100% (#{wrote}) writing buffer to disk (can take a couple of minutes).."
    async =>
      exp.close onComplete
    return

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
