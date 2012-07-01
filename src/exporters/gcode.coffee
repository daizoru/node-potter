

# todo: add ourselve to this list: http://replicat.org/generators

# the gcode will be read by ReplicatorG
# ReplicatorG is a GCode controller for RepRap compatible machines.
# http://code.google.com/p/replicatorg/source/browse/trunk/src/replicatorg/app/GCodeParser.java


fs = require 'fs'

{wait,async} = require "../toolbox"

class Program

  constructor: (name="") ->
    @b = "0#{name}\n"

  absolutePositionning: => @b += "G90\n"
  coolingFan: (enable=yes) => @b += if enable then "M106\n" else "M107\n"

  changeTool: (id=0) => @b += "M06 #{id}\n"


  toString: => @b

class module.exports

  constructor: (@path, options) ->
    @outStream = fs.createWriteStream @path, flags: 'w'
    @onEnd = if options.onEnd? then options.onEnd else ->
    @headerWritten = no

    @nbPoints = options.nbPoints

    @program = new Program "1234"



  close: =>
    #@outStream.close()
    async =>
      @onEnd()



  # http://pointclouds.org/documentation/tutorials/pcd_file_format.php
  write: (x, y, z, material) =>
    return if material.id is 0
    # @writeHeader() unless @headerWritten
    @outStream.write "#{x} #{y} #{z} #{material.rgbInt}\n" # no material
