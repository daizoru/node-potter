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

# you can save to a variety of point cloud formats
pot.save "points.pcd"
pot.save "points.pts"

# async syntax supported
pot.save "points.xyz", ->
  console.log "done"

```

## Supported output format

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

## Unsupported formats

  For the moment AMF, STL.. are not supported.

  Exporting voxels to a 3D printer-ready format is a tricky task,
  because one need to convert voxels-filled shapes to polygons.

  problem is most printers require the poly shapes to be without any holes,
  which means automatic voel converters are not enough, and manual operation
  is necessary

  of course if you are coding your own 3D printer with arduino or things like this,
  it should be less of a problem (because then I suppose you have control over slicing,
  and can directly map and match the voxel resolution to your printer's resolution.

  (btw I'm going to add a function to resize the voxels matrix, for this very last purpose)

