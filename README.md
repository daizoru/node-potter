node-potter
===========


write point clouds like a 3D Canvas


usage:


```coffeescript

# initialise the potter
pot = new Potter()

# create materials
plastic = pot.createMaterial "plastic", "red"
metal =   pot.createMaterial "metal",   "grey"

# draw something
pot.draw 5, 5, 5, clay
pot.draw 4, 5, 6
pot.draw 5, 3, 7, metal

pot.save "points.xyz"
pot.save "points.pcd"

# async syntax supported
pot.save "points.pcd", ->
  console.log "done"

```

