#!/usr/bin/env coffee

{log,error,inspect} = require 'util'
Potter = require 'potter'

# create a new voxel matrix
pot = new Potter size: [100,100,100]

# create a red plastic material
plastic = pot.createMaterial "plastic", "red"
pot.use plastic

p1 = [10, 10, 10]
p2 = [20, 20, 20]
p3 = [50, 10, 10]

log "drawing.."
pot.dot p1
pot.line p1, p2


# I think node-potter would work nicely with 
# https://github.com/osuushi/Smooth.js
# this is something I should try in the future

# export the dog voxel matrix to STL, for 3D printing
log "saving.."
pot.save "examples/exports/simple.stl", ->
  log "file saved"

