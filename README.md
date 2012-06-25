node-potter
===========


write point clouds like a 3D Canvas

## overview

  For the moment 3D printers cannot read voxel formats,
  so you may have to build your own 3D printer

## usage

```coffeescript

# initialise the potter
pot = new Potter()

# create materials
plastic = pot.createMaterial "plastic", "red"
metal =   pot.createMaterial "metal",   "grey"

# draw something
pot.draw 5, 5, 5, plastic
pot.draw 4, 5, 6
pot.draw 5, 3, 7, metal

pot.save "points.xyz"
pot.save "points.pcd"

# async syntax supported
pot.save "points.pcd", ->
  console.log "done"

```

## example outputs

### PCD (Point Cloud Data)

 Specs: http://pointclouds.org/documentation/tutorials/pcd_file_format.php

 sample (from node-potter):

```
VERSION .7
FIELDS x y z rgb
SIZE 4 4 4 4
TYPE I I I I
COUNT 1 1 1 1
WIDTH 3
HEIGHT 1
VIEWPOINT 0 0 0 1 0 0 0
POINTS 3
DATA ascii
5 5 5 1
4 5 6 1
5 3 7 1
```

### XYZ

 Specs: ?

 sample (from node-potter):

```
5 5 5
4 5 6
5 3 7
```

