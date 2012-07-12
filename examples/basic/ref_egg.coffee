#!/usr/bin/env coffee

{log,error,inspect} = require 'util'
Potter = require 'potter'

name = "ref_egg"

model = new Potter size: [ 1000, 1000, 1000 ]

yolk = model.material
  name: "yolk"
  color: "yellow"

albumen = model.material
  name: "albumen"
  color: "transparent"

membrane = model.material
  name: "membrane"
  color: "white"

shell = model.material
  name: "shell"
  color: "orange"

center = [ 200, 200, 200 ]

model.use yolk
model.sphere center, 0, 10

model.use albumen
model.sphere center, 12, 30

model.use membrane
model.sphere center, 32, 33

model.use shell
model.sphere center, 34, 36

log "model has #{model.count} voxels"
model.section center, [+1,0,0]

log "after section: #{model.count} voxels"
model.save "examples/exports/#{name}.stl", ->
  log "file saved"

