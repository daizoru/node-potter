#!/usr/bin/env coffee

{log,error,inspect} = require 'util'
Potter = require 'potter'

name = "dog"

# create a new voxel matrix
dog = new Potter size: [1000,1000,1000]

# create a brown plastic material. let's call it "fur"
fur = dog.material name: "plastic", color: "brown"
dog.use fur


# nose
nse = [130, 200, 160]

# front
pfr = [100, 130,  50]
pft = [150, 200, 130]
pfl = [100, 270,  50]

# back
pbr = [300, 130,  50]
pbt = [250, 200, 130]
pbl = [300, 270,  50]

# tail
tab = [250, 200, 130]
tat = [280, 200, 170]

nose = (p) -> dog.sphere p, 6, 8
leg =  (p) -> dog.sphere p, 8, 10
body = (p) -> dog.sphere p, 20, 22
tail = (p) -> dog.sphere p, 6, 8
# nose, 

log "drawing nose.."
dog.trace [nse], (p) ->
  dog.sphere p, 5, 6

# front legs
log "drawing front legs.."
dog.trace [pfr,pft,pfl], leg

# body
log "drawing body.."
dog.trace [pft,pbt], body

# back legs
log "drawing back legs.."
dog.trace [pbr,pbt,pbl], leg

# tail
log "drawing tail.."
dog.trace [tab,tat], tail

# export the dog voxel matrix to STL, for 3D printing
log "saving #{dog.count} voxels.."
dog.save "examples/exports/#{name}.stl", ->
  log "file saved"

