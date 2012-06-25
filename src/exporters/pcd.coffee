fs = require 'fs'

{wait,async} = require "../toolbox"

class module.exports

  constructor: (@path, options) ->
    @outStream = fs.createWriteStream @path, flags: 'w'
    @onEnd = if options.onEnd? then options.onEnd else ->
    @headerWritten = no

    @nbPoints = options.nbPoints

    @writeHeader()

  close: =>
    #@outStream.close()
    async =>
      @onEnd()

  writeHeader: () =>

    header =
      version: '.7'

      # specifies the name of each dimension/field that a point can have
      fields: "x y z rgb"


      # specifies the size of each dimension in bytes. Examples:
      # unsigned char/char has 1 byte
      # unsigned short/short has 2 bytes
      # unsigned int/int/float has 4 bytes
      # double has 8 bytes
      size: "4 4 4 4"

      # type of each dimension
      # I - represents signed types int8 (char), int16 (short), and int32 (int)
      # U - represents unsigned types uint8 (unsigned char), uint16 (unsigned short), uint32 (unsigned int)
      # F - represents float types
      type: "I I I I"


      # specifies how many elements does each dimension have
      count: "1 1 1 1"

      # the width of the point cloud dataset in the number of points. 
      # - it can specify the total number of points in the cloud 
      #(equal with POINTS see below) for unorganized datasets;
      # - it can specify the width (total number of points in a row)
      # of an organized point cloud dataset.
      width: @nbPoints

      # specifies the height of the point cloud dataset in the number of points. 
      # HEIGHT has two meanings:
      # - it can specify the height (total number of rows) of an organized point 
      # cloud dataset;
      # - it is set to 1 for unorganized datasets (thus used to check whether a 
      # dataset is organized or not).
      height: 1

      # pecifies an acquisition viewpoint for the points in the dataset.
      # This could potentially be later on used for building transforms 
      # between different coordinate systems, or for aiding with features 
      # such as surface normals, that need a consistent orientation.
      viewpoint: "0 0 0 1 0 0 0"

      # specifies the total number of points in the cloud. As of version 0.7,
      # its purpose is a bit redundant, so we’re expecting this to be removed 
      # in future versions.
      points: @nbPoints

      # specifies the data type that the point cloud data is stored in. As of 
      # version 0.7, two data types are supported: ascii and binary. See the 
      # next section for more details.
      data: 'ascii'

    headerOrder = [ 
      'version'
      'fields'
      'size'
      'type'
      'count'
      'width'
      'height'
      'viewpoint'
      'points'
      'data'
    ]

    for key in headerOrder
      value = header[key]
      @outStream.write "#{key.toUpperCase()} #{value}\n"

    @headerWritten = yes


  # http://pointclouds.org/documentation/tutorials/pcd_file_format.php
  write: (x, y, z, material) =>
    return if material.id is 0
    # @writeHeader() unless @headerWritten
    @outStream.write "#{x} #{y} #{z} #{material.rgbInt}\n" # no material
