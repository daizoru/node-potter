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

toInt = Math.round

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
    x = p1[0] + dx * r 
    y = p1[1] + dy * r
    z = p1[2] + dz * r
    points.push [
      toInt x
      toInt y
      toInt z
    ]
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

  constructor: (@id, @params={}) ->
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
    o = if @id is 0 then 0 else 1
    o = 1
    #
    @rgbaDataString = "rgba(#{r},#{g},#{b},#{o})"

    @hexString = rgbToHex r, g, b
    @rgbInt = rgbToInt r, g, b

    @count = 0
    
    #log "#{@}"
  toString: ->
   "mat #{@id} (#{@name}) is #{@color} and #{@type}"

  computeMass: ->
    @mass * count


# online barycenter
class Barycenter
  constructor: (@pot) ->
    @sums = [0,0,0]
    @cache = [0,0,0]
    @revision = -1

  insert: (p,m) =>
    @sums = [
      @sums[0] + p[0]
      @sums[1] + p[1]
      @sums[2] + p[2]
    ]
    #log "#{@} INSERT @sums: #{@sums}"

  delete: (p,m) =>
    @sums = [
      @sums[0] - p[0]
      @sums[1] - p[1]
      @sums[2] - p[2]
    ]
    #log "#{@} DELETE @sums: #{@sums}"

  value: =>
    unless @revision is @pot.revision
      #log "computing new barycenter"
      N = @count
      center = @sums
      center = [center[0] / N, center[1] / N, center[2] / N] if N >= 1
      @cache = center
      @revision = @pot.revision

    @cache


# canvas stream listen to potter, and update a high-res 3D grid made of voxels
# TODO put this in a separate, node-potter-streamflow module
class CanvasStream
  constructor: (@pot) ->
    Canvas = require 'canvas'
    size =
      x: 100
      y: 100
      z: 100

    @layers = []
    for i in [1..size.z]
      canvas = new Canvas size.x, size.y
      ctx = canvas.getContext '2d'
      @layers.push {canvas, ctx}


  insert: (p,m) =>
    layer = @layers[p[2]]
    ct = layer.ctx
    ct.fillStyle = 'rgba(0,0,255,0.5)'
    ct.strokeStyle = 'red'
    ct.lineWidth = 1
    ct.lineTo p[0], p[1]
    ct.stroke()

  delete: (p,m) =>
    layer = @layers[p[2]]
    ct = layer.ctx
    ct.fillStyle = 'rgba(0,0,0,0.0)'
    ct.strokeStyle = 'red'
    ct.lineWidth = 1
    ct.lineTo p[0], p[1]
    ct.stroke()

  update: (p,m) =>
    layer = @layers[p[2]]
    ct = layer.ctx
    ct.fillStyle = 'rgba(0,0,255,0.5)'
    ct.strokeStyle = 'red'
    ct.lineWidth = 1
    ct.lineTo p[0], p[1]
    ct.stroke()

  getLayer: (z) =>
    @layers[z]
    # write to 
    @canvas.toBuffer (err, buf) ->
      throw err if err
      fs.writeFile __dirname + '/slice_#{z}.png', buf

    canvas.toBuffer(function(err, buf){
    var duration = new Date - start;
    console.log('Rendered in %dms', duration);
    res.writeHead(200, { 'Content-Type': 'image/png', 'Content-Length': buf.length });
    res.end(buf);
  });
    

class Bounding
  constructor: (@pot) ->
    m = 999999999 
    @min = [+m,+m,+m]
    @max = [-m,-m,-m]

    @cache =
      max: [0,0,0]
      min: [0,0,0]
    @revision = -1

  insert: (p,m) =>
    @values = [
      @sums[0] + p[0]
      @sums[1] + p[1]
      @sums[2] + p[2]
    ]
    #log "#{@} INSERT @sums: #{@sums}"

  delete: (p,m) =>
    @sums = [
      @sums[0] - p[0]
      @sums[1] - p[1]
      @sums[2] - p[2]
    ]
    #log "#{@} DELETE @sums: #{@sums}"

  value: =>
    unless @revision is @pot.revision
      #log "computing new barycenter"
      N = @count
      center = @sums
      center = [center[0] / N, center[1] / N, center[2] / N] if N >= 1
      @cache = center
      @revision = @pot.revision

    @cache

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

    @points = {}

    @count = 0
    @materials = {}
    @currentMaterial = no

    @revision = -1

    # create material #0, which is basically empty space in the model
    @vacuum = @material name: "vacuum", color: "invisible", type: "vacuum"

    # default outputs - renderer goes here!
    @outputs =
      barycenter: new Barycenter @
      bounding: new Bounding @


  material: (params={}) ->
    id = Object.keys(@materials).length
    material = new Material id, params
    @materials[id] = material
    material

  use: (material) -> 
    @currentMaterial = if material then material else @vacuum

  dot: (p, overwrite) =>
    @put p, @currentMaterial, overwrite

  # PUT a voxel using an array of size 3, a Material, and optional 'overwrite' boolean
  put: (p, m, overwrite=no) =>

    # Compress the Vector into a hashmap key
    # This give us overhead, but greatly improve memory usage
    id = p.join ','
    ############
    ## DELETE ##
    ############
    if !m? or !m or m.id is 0
      if id of @points

        delete @points[id] # actual delete!
        @count--           # DECREMENT the Voxel counter
        @revision++        # INCREMENT the revision since structure has changed

        # fire DELETE event
        async =>
          for k,output of @outputs
            if output.delete?
              output.delete p, m

      # else we want to delete an already delete voxel - skipping

    ##############################
    ## INSERT or UPDATE or SKIP ##
    ##############################
    else
      # id already exists - check if we should overwrite
      if id of @points

        ##########
        ## SKIP ##
        ##########
        unless overwrite
          return


        ############
        ## UPDATE ##
        ############

        # fire UPDATE event
        async =>
          for k,output of @outputs
            if output.update?
              output.update p, m

      ############
      ## INSERT ##
      ############
      else
        @count++ # INCREMENT Voxel counter
        m.count++ # INCREMENT Material counter (for statistics)

        # fire INSERT event
        async =>
          for k,output of @outputs
            if output.insert?
              output.insert p, m

      ######################
      ## INSERT or UPDATE ##
      ######################
      @revision++       # INCREMENT the revision since structure has changed
      @points[id] = m   # actual writing of new value to the memory


  line: (p1, p2, overwrite) ->
    #log "p1: #{p1} p2: #{p2}"
    points = readPath p1, p2
    #log "drawing points"
    #console.dir points
    @dot p, overwrite for p in points

  #face: (p1, p2) ->
  #  width = len 
  
  # each kernel_function ->
  each: (kernel) =>
    for id,material of @points
      s = id.split ','
      position = [
        parseInt s[0]
        parseInt s[1]
        parseInt s[2]
      ]
      kernel position, material

  # map kernel_function ->
  map: (kernel) =>
    for id, m of @points
      s = id.split ','
      p = [
        parseInt s[0]
        parseInt s[1]
        parseInt s[2]
      ]
      @put p, kernel(p, m)

  filter: (kernel) =>

    for id, m of @points
      s = id.split ','
      p = [
        parseInt s[0]
        parseInt s[1]
        parseInt s[2]
      ]
      @put p, m if kernel p, m

  reduce: (accumulator, kernel) =>
    acc = accumulator
    @each (p, state) ->
      acc = kernel acc, p, state
    acc
    
  sum: (kernel) =>
    acc = 0
    @each (p, state) ->
      acc += kernel p, state
    acc
    
  reduce: (accumulator, kernel) =>
    acc = accumulator
    @each (p, state) ->
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

  get: (p) => @points[p.join(',')]

  isEmpty: (p) => !@points[p.join(',')]?

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
      isEmpty: (p) => @isEmpty p

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

module.exports = Potter
