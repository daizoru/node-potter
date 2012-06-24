class Exporter

  constructor: ->


  save: ->

    points = []

    # http://www.laserscanning.org.uk/forum/viewtopic.php?f=22&t=743
    For each point cloud, prints the total number of points in the point
    # cloud followed by a stream of XYZ coordinates, the intensity value 
    #(the fraction of incident radiation reflected by a surface) and the
    # colors (RGB) for the points. Vertices and spheres exported to PTS 
    #format are treated as individual point clouds, consisting of one point
    # of zero intensity; the coordinate corresponds to the center of the 
    #vertex or sphere. The point information is transformed into the current 
    #user coordinate system and scaled for the current unit of measure.
    #Number of points X Y Z Intensity value R G B
    buff = ""
    buff += "#{points.length}\n"
    for p in points
      intensityValue = -300
      [r,g,b] = p.material.rgb
      buff += "#{p.x} #{p.y} #{p.z} #{intensityValue} #{r} #{g} #{b}"
