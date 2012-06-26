node-potter
===========


write point clouds like a 3D Canvas

## overview

  For the moment 3D printers cannot read voxel-with-material formats,
  so you may have to build your own 3D printer.

  that said, you can try an experimental .STL export right now
  (which basically create polygonal 3D cubes for each voxel)

## why

  Because it's funny. If you don't get why, you should probably 
  browse something else on Github.

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

# you can save to a variety of point cloud formats
pot.save "points.pcd"
pot.save "points.pts"
pot.save "points.xyz"

# but also STL for 3D printing!
pot.save "model.stl"

# async syntax supported
pot.save "model.stl", ->
  console.log "done"

```

## Supported output format

### STL

  Yes! it is working! I got inspiration from

  https://github.com/codys/minecraft.print/blob/master/minecraft_print.py


### PCD (Point Cloud Data)

  Specs: 
  http://pointclouds.org/documentation/tutorials/pcd_file_format.php

  Sample:

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
5 3 7 2
```

### PTS

  Spec: 

```

   NB_POINTS
   X Y Z INTENSITY R G B
   X Y Z INTENSITY R G B
   ...

```
  Sample:

```
3
5 5 5 1 0 0 2
4 5 6 1 0 0 2
5 3 7 1 0 0 3
```

### XYZ

  Sample:

```
5 5 5
4 5 6
5 3 7
```


