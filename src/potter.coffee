#!/usr/bin/env coffee

# ...
{log,error} = require 'util'
fs = require 'fs'

class Material

  constructor: (@id,@name,@color,@type='continuous') ->


class Potter

  constructor: (url) ->
    @size =
      x: [-20,20]
      y: [-20,20]
      z: [-20,20]

    # x should be the main, longer axis
    @length = Math.abs(@size.x[0]) + Math.abs(@size.x[1])
    
    # y is often the side, maybe shorter axis
    @width = Math.abs(@size.y[0]) + Math.abs(@size.y[1])

    # z is always the vertical axis
    @height = Math.abs(@size.z[0]) + Math.abs(@size.z[1])
    
    # initialize N layers
    log "initializing #{@height} slices"
    @slices = no for x in [0..@height] # @height included

    @materials = []
    @lastUsed = no

  createMaterial: (name, color, type) ->
    material = new Material @materials.length, name, color, type
    @materials.push material

  map: (x, y, z) ->
    [
      Math.abs(@size.x[0]) + x
      Math.abs(@size.y[0]) + y
      Math.abs(@size.z[0]) + z
    ]

  emptySlice: =>
    slice = []
    for i in [0..@length]
      row = 0 for j in [0..@width]
      slice.push row

  use: (material) ->
    if material
      @lastUsed = material
    else
      msg = "Error, no material"
      error msg
      throw msg
      return
    
  draw: (x, y, z, material=no) ->
    [i,j,sliceId] = @map x, y, z
    slice = @slices[sliceId]

    # make it on demand (so we can save memory when possible)
    slice = @emptySlice() unless slice

    if material
      @lastUsed = material
    else
      material = @lastUsed

    unless material
      msg = "Error, no material"
      error msg
      throw msg
      return

    slice[i][j] = material.id

  save: ->

  export: (url) ->

# quick & dirty testing
pot = new Potter()
clay = pot.createMaterial "clay", "brown"

# draw something
pot.draw 5, 5, 5, clay
pot.draw 5, 5, 6
pot.draw 5, 5, 7

#harry.cast()

