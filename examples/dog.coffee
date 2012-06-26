#!/usr/bin/env coffee

{log,error,inspect} = require 'util'
Potter = require 'potter'

name = "dog"

# create a new voxel matrix
dog = new Potter size: [100,100,100]

# create a brown plastic material. let's call it "fur"
fur = dog.createMaterial "plastic", "brown"
dog.use fur

# front
pfr = [10, 10, 10]
pft = [20, 20, 20]
pfl = [10, 30, 10]

# back
pbr = [50, 10, 10]
pbt = [40, 20, 20]
pbl = [50, 30, 10]

log "drawing.."
leg = (p) -> dog.sphere p, 4
body = (p) -> dog.sphere p, 8

# front legs
dog.trace [pfr,pft,pfl], leg

# body
dog.trace [pft,pbt], body

# back legs
dog.trace [pbr,pbt,pbl], leg

# export the dog voxel matrix to STL, for 3D printing
log "saving.."
dog.save "examples/exports/#{name}.stl", ->
  log "file saved"

