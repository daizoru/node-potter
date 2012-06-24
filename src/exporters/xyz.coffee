
class Exporter

  constructor: ->


  # http://www.laserscanning.org.uk/forum/viewtopic.php?f=22&t=743
  save: ->

    #XYZ File
    # exports XYZ data for each point cloud, vertex or sphere -
    #this format provides a continuous point listing with no 
    #indication of the start of new point clouds. Coordinates
    # are transformed into the current user coordinate system
    # and scaled for the current unit of measure.
    buff = ""
    for p in points
      buff += "#{x} #{y} #{z}\n" # no material
