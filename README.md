
node-potter
===========

Draw Something in 3D Space

## overview

  A library to draw in a 3D canvas, and create things to be printed in 3D, like this beautiful dog:
  
  ![doogy](http://img528.imageshack.us/img528/518/doggy.png)
   
  I know, I know, it looks very realistic. You can do it, too! If you install this library.

  For the moment 3D printers cannot read voxel-with-material formats,
  so you may have to build your own 3D printer (which I started to do myself)

  That said, you can try an experimental .STL export right now
  (which basically create polygonal 3D cubes for each voxel)


## why

  Because it's funny. If you don't get why, you should probably 
  browse something else on Github.

## TODO
  * better file stream support (currently buffer saturate)
  * support binary STL (and colors)
  * implement more materials: http://www.matbase.com/matbase_material_properties_database.html

## install

  globally:

    $ npm install potter -g

  as a dependency of your Node project:

    $ npm install potter


## usage

``` javascript

  var Potter = require('potter');

  // initialize a voxel matrix
  var pot = new Potter({
    size: [100, 100, 100]
  });

  // define a new material
  var plastic = pot.material("plastic", "red");

  // and use it
  pot.use(plastic);
  
  // draw voxels using plastic
  pot.dot([ 5, 5, 5 ]);
  pot.dot([ 4, 5, 6 ]);

  // it's easier if you use it this way
  var p1 = [20, 20, 15];
  var p2 = [15, 40, 15];
  var p3 = [30, 20, 30];

  // you can draw lines as well
  pot.line(p1, p3);

  // you can also draw over a "3D path"
  pot.trace([ p1, p2, p3 ], function(p) {
    var radius = 3;
    pot.sphere(p, radius, radius + 2);
  });

  // you can save to a variety of point cloud formats
  pot.save("model.pcd"); 

  // experimental export to STL
  pot.save("model.stl");

  // async syntax is supported
  pot.save("model.xyz", function() {
    console.log("file saved");
  });

```

## Demo

### In CoffeeScript - please fasten your seatbelt

``` coffeescript
#!/usr/bin/env coffee

{log,error,inspect} = require 'util'
Potter = require 'potter'

name = "dog"

# create a new voxel matrix
dog = new Potter size: [1000,1000,1000]

# create a brown plastic material. let's call it "fur"
fur = dog.material "plastic", "brown"
dog.use fur

# front
pfr = [100, 100, 100]
pft = [200, 200, 200]
pfl = [100, 300, 100]

# back
pbr = [500, 100, 100]
pbt = [400, 200, 200]
pbl = [500, 300, 100]

leg  = (p) -> dog.sphere p, 10, 12
body = (p) -> dog.sphere p, 30, 32

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

```

  Then if you run it: 


    $ coffee examples/basic/test_dog.coffee 

  It should give you this:

![doggy](http://img641.imageshack.us/img641/3148/doggy2.png)

  With a lot of voxels. Really. A lot.

  WARNING: it make take a couple of MINUTES for Node.js
  to write all the buffer to disk (this happens AFTER the "file saved" msg,
  and freeze the app for some time)

## Running the other examples

### Sponge

    $ coffee examples/basic/ref_sponge.coffee 

### Egg

    $ coffee examples/basic/ref_egg.coffee 

## List of functions

###

  Documentation legend

```scala
  foo ({ x:Number });
```
  means function foo takes an object as argument, this object should have an entry with key 'x' and value of type Number


```scala
  foo ( x=Number ); 
```
  means function foo takes one argument, x, which should be a Number



### pot = new Potter({size:[x,y,z]})

### Material m = pot.material({ })

  Create a material
 
### pot.use(material=Material)

  Use a material for all next drawing operations

### pot.dot(position=[x,y,z])

  Draw a voxel at a give coordinate

### pot.line(from=[x1,y1,z1], to=[x2,y2,z2])

  Draw a line in 3D

### pot.sphere(position=[x,y,z], inner=Number, outer=Number)

  Draw a sphere, using a center, inner radius (radius of the inside hole), and outer radius (the 'real' radius)

### pot.section(position=[x,y,z],plane=[u,v,w])

Cut the model - do a section (nice for autopsy or medical research)

Where x,y,z are the center of the section plane,
and u,v,w is the plane axis. example:

```javascript
pot.section([x,y,z], [1,0,0]);
```

will cut the model in half, on the X axis,

```javascript
pot.section([x,y,z], [-1,0,0]);
```

will cut the model in half, on the X axis, but in the other direction, and:

```javascript
pot.section([x,y,z], [0,1,1]);
```

will cut the model in a quarter, on the Y/Z axis.



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


## Changelog

### 0.0.2
 
  * better Potter::sphere() algorithm, with optional thickness (useful for fillings!)
  * added Potter::section(), you can use it to cut a model for autopsy
  * added Potter.vacuum, which is a shortcut to material 0 (vacuum)
  * various minor bugfixes

### 0.0.1

  * second, less crappy version 
  * fucking much faster (except if you do export STL files)

### 0.0.0

  * initial crappy version

