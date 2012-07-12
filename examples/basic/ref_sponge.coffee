#!/usr/bin/env coffee

{log,error,inspect} = require 'util'
Potter = require 'potter'

name = "ref_sponge"

model = new Potter size: [ 1000, 1000, 1000 ]

sponge = model.material
  name: "sponge" # silica + chitin
  color: "yellow"

center = [ 200, 200, 200 ]

model.use sponge

side = 100
log "growing large sponge"
model.sphere center, 0, side / 2

model.use null

log "drilling small holes"

for x in     [ 0 .. side ]  by 16
  for y in   [ 0 .. side ]  by 16
    for z in [ 0 .. side ]  by 16
      p = [
        center[0] - (side / 2)  + x
        center[1] - (side / 2)  + y
        center[0] - (side / 2)  + z
      ]
      model.sphere p, 0, 4 + Math.random() * 8


log "model has #{model.count} voxels"
model.section center, [+1,0,0]

log "after section: #{model.count} voxels"
model.save "examples/exports/#{name}.stl", ->
  log "file saved"

