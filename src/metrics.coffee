{log,error,inspect} = require 'util'

# potter is used because we need to create on-the-fly
# clones
Potter = require './potter'

# compare the difference between two amounts
# eg. if 
# a=0 and b=400 -> 0.0 similarity (also 0.0 if a is negative)
# a=245 and b=300 -> 0.8166667 similarity
# a=500 and b=30 -> 0.06 similarity
diff = (a, b) ->
  _diff = (a,b) ->
    r = if a < b then (if b >= 1 then a/b else a) else (if a >= 1 then  b/a else b)
    r = 0.0 if r < 0.0
    r
  if a.length? and b.length?
    (_diff(a[i],b[i]) for i in [0...a.length])
  else
    _diff( a, b )


difference = exports.difference = (pot1, pot2) ->
  adds = 0
  dels = 0
  pot1.each (p,m) -> adds += 1 unless pot2.get p
  pot2.each (p,m) -> dels += 1 unless pot1.get p

  adds: adds
  dels: dels
  total: adds + dels

rotateModel = exports.rotateModel = (pot1,rotation) ->

  log "doing rotation: #{rotation}"
  pot2 = new Potter size: pot1.size

  # phi [0,Math.PI] -> trigo orger
  # phi [-Math.PI,0] -> anti-trigo order
  # so we can simply map Math.PI to -1, and MAth.PI to 1


  # rotation of a point around zero, using an amount betweent -1 and +1
  rotatePoint = (x, y, amount) ->
    return [x,y] if amount is 0
    phi = amount * Math.PI # now we have an angle between -PI and +PI
    cosPhi = Math.cos phi
    sinPhi = Math.sin phi
    [
      x * cosPhi - y * sinPhi
      x * sinPhi + y * cosPhi
    ]

  # we use .map() so we can erase voxels just after copying them
  pot1.map (p,m) ->

    #log "reading point: #{p}"
    # Compute the rotation in 3 steps
    # TODO this part should be optimized
    yz = rotatePoint p[1], p[2], rotation[0] # X-Axis
    #log "yz: #{yz}"
    p = [p[0], yz[0], yz[1]]
    #log: "p: #{p}"
    xz = rotatePoint p[0], p[2], rotation[1] # Y-Axis
    #log "xz: #{xz}"
    p = [xz[0], p[1], xz[1]] 
    #log "p: #{p}"  
    xy = rotatePoint p[0], p[1], rotation[2] # Z-Axis
    #log "xy: #{xy}"
    p = [xy[0], xy[1], p[2]]

    p = [
      Math.round p[0]
      Math.round p[1]
      Math.round p[2]
    ]

    #log "writing point: #{p}"
    m2 = pot2.material m.params # recreate a brand new material in the target model
    pot2.use m2 # use it
    pot2.dot p
    #log ""
  pot2


exports.computeRotation = computeRotation = (pot1, pot2) ->
  ###
  basically, this is a 3D binary search
  we try 4 * 4 * 4 differents rotations
  then, we get the best combination
  starting from here, we refinate the model a bit more by
  creating a range, then subdividing it again and again
  
  we start the search with these angles:
  x: [0°, 90°, 180°, 270°]
  y: [0°, 90°, 180°, 270°]
  z: [0°, 90°, 180°, 270°]

  eg if the best angle so far is:
  x: 270°
  y: 180°
  z: 0°
  then we can search from:
  x: [0°,   180°] / 4  -> [0°,   45°,  90°, 135°, 180°]
  y: [270°,  90°] / 4  -> [270°, 0°,   45°, 90°]
  z: [90°,  270°] / 4  -> [90°,  135°, 180°, 270°]

  # then again, if we run the search we might find:
  x: 45°
  y: 135°
  z: 45°
  ###  

# compare two models, returning some features
compare = exports.compare = (pot1,pot2) ->

  features =
    count: 0
    transform:
      translate: [0,0,0]
      rotate: [0,0,0]

  features.count = diff pot1.count, pot2.count


  log "POT1:"
  center1 = pot1.outputs.barycenter.value() # should be quite fast (cached)
  log "POT2:"
  center2 = pot2.outputs.barycenter.value()
  features.transform.translate = diff center1, center2

  
  nbAlive = (pot) -> pot.sum (p, state) -> state.values[0]
  
  features.alive = diff nbAlive(pot1), nbAlive(pot2)


  log "pot1 count: #{pot1.count}, center: #{center1}"
  log "pot2 count: #{pot2.count}, center: #{center2}"
  log "diff count: #{features.count},  alive: #{features.alive},  translate: #{features.transform.translate}"
  #pot3 = translat

  df = difference pot1, pot2
  log "differential: #{inspect df}"

  # rotate the model around 0 of X axis (-1 means -PI, +1 means +PI)
  model2 = rotateModel pot1, [0.5,0,0]

  df = difference pot1, pot2
  log "differential: #{inspect df}"

