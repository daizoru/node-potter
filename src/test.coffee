#!/usr/bin/env coffee

# ...
{log,error,inspect} = require 'util'

# module libs
{wait,async} = require './toolbox'

Potter = require './potter'

sphere = (x,y,r) ->


# quick & dirty testing
pot = new Potter size: [100,100,100]
clay = pot.createMaterial "clay", "brown"
plastic = pot.createMaterial "plastic", "red"
metal = pot.createMaterial "metal", "grey"

# draw something
pot.use plastic
pot.dot [5, 5, 5]
pot.dot [4, 5, 6]
pot.dot [5, 3, 7]

pot.use clay

p1 = [20, 20, 15]
p2 = [15, 40, 15]
p3 = [30, 20, 30]
p4 = [40, 30, 40]
#pot.line p1, p2
#pot.line p3, p2
#pot.line p1, p3

# potter can walk voxel paths
path = [p1,p2,p3,p4]
log "starting walk.."
rad = 15

pot.walk path, (p) -> 
  log "@#{p}"
  rad -= Math.random() * 0.3

  rad = 1 if rad < 2
  pot.sphere p, rad

#pot.use metal
#pot.sphere [50, 50, 50], 20


#log "max size: #{pot.computeMaxSize()}"
pot.save "examples/exports/test.stl", ->
  log "file saved"

#pot.save "examples/slices/test_"
#harry.cast()

