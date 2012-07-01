#!/usr/bin/env coffee

{log,error,inspect} = require 'util'
Potter = require 'potter'

name = "axon"

# create a new voxel matrix
model = new Potter name: name, size: [1000,1000,1000]

# create a brown plastic material. let's call it "fur"
isolant = model.createMaterial "polymer_nonconductive", "grey"
conductor = model.createMaterial "conductor", "blue"

# key points
keypoints = [
  [130, 200, 160]
  [100, 130,  50]
  [150, 200, 130]
  [100, 270,  50 
]
path = keypoints
model.use isolant
model.trace keypoints, (p) -> model.sphere p, 5

model.use conductor
model.trace keypoints, (p) -> model.sphere p, 2

# export the voxel matrix to STL, for 3D printing
log "saving #{model.count} voxels.."
model.save "examples/exports/#{name}.stl", ->
  log "file saved"

