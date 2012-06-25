class Exporter

  constructor: ->

  save: ->

    # TODO
    # TO SUPPORT STL WE FIRST NEED TO CONVERT THE CLOUD POINT TO
    # POLYGONS, BUT I'M AFRAID WE CAN'T DO IT AUTOMATICALLY :/
    # 

    name = "foo"

    buff = ""
    buff += "solid #{name}\n"
    """facet normal ni nj nk
    outer loop
    vertex v1x v1y v1z
    vertex v2x v2y v2z
    vertex v3x v3y v3z
    endloop
    endfacet"""
    buff += "endsolid #{name}\n"