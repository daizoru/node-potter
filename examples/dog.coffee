#!/usr/bin/env coffee

{log,error,inspect} = require 'util'
Potter = require 'potter'

name = "dog"

# create a new voxel matrix
dog = new Potter size: [1000,1000,1000]

# create a brown plastic material. let's call it "fur"
fur = dog.createMaterial "plastic", "brown"
dog.use fur

# front
pfr = [100, 100, 100]
pft = [200, 200, 200]
pfl = [100, 300, 100]

# back
pbr = [500, 100, 100]
pbt = [400, 200, 200]
pbl = [500, 300, 100]

leg = (p) -> dog.sphere p, 10
body = (p) -> dog.sphere p, 30

# front legs
log "drawing front legs.."
dog.trace [pfr,pft,pfl], leg

# body
log "drawing body.."
dog.trace [pft,pbt], body

# back legs
log "drawing back legs.."
dog.trace [pbr,pbt,pbl], leg

# export the dog voxel matrix to STL, for 3D printing
log "saving #{dog.count} voxels.."
dog.save "examples/exports/#{name}.stl", ->
  log "file saved"

