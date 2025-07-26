-- objects

-- returns a cube object of side length 2
function create_cube()

  local polyList = {}
  -- all points of the polygons of the cube
  local newtable = 
  {
    1,1,-1, 1,1,1, 1,-1,-1,
    1,-1,1, 1,-1,-1, 1,1,1,

    1,1,-1, -1,1,-1, 1,1,1,
    -1,1,1, 1,1,1, -1,1,-1,

    -1,-1,-1, -1,1,-1, 1,-1,-1,
    1,1,-1, 1,-1,-1, -1,1,-1,

    -1,-1,-1, -1,-1,1, -1,1,-1,
    -1,1,1, -1,1,-1, -1,-1,1,

    1,1,1, -1,1,1, 1,-1,1,
    -1,-1,1, 1,-1,1, -1,1,1,

    1,-1,-1, 1,-1,1, -1,-1,-1,
    -1,-1,1, -1,-1,-1, 1,-1,1
  }

  local step = 0
  for i=1,12 do
    
    if i % 2 == 0 then
      polyList[i] = Polygon.new(
        Vector3.new(newtable[1 + step], newtable[2 + step], newtable[3 + step]),
        Vector3.new(newtable[4 + step], newtable[5 + step], newtable[6 + step]),
        Vector3.new(newtable[7 + step], newtable[8 + step], newtable[9 + step]),
        Vector2.new(0,32), --DEBUG
        Vector2.new(31,32),
        Vector2.new(0,63) --DEBUG
        
      )
      step += 9
    else

      polyList[i] = Polygon.new(
      Vector3.new(newtable[1 + step], newtable[2 + step], newtable[3 + step]),
      Vector3.new(newtable[4 + step], newtable[5 + step], newtable[6 + step]),
      Vector3.new(newtable[7 + step], newtable[8 + step], newtable[9 + step]),
      Vector2.new(31,63), --DEBUG
      Vector2.new(0,63),
      Vector2.new(31,32) --DEBUG
      
    )
    step += 9


    end

  end

  return Polygon.create_object(polyList, Vector3.new(0,0,0))

end


-- returns an icosahedron object
function create_icosahedron()

  local polylist = {}
  local vectorlist = {}
  local vertexlist = {
    0.19649, 8.40808, 4.48559,
    8.28664, 5.31788, -0.51401,
    0.19649, 8.40809, -5.51401,
    -4.80351, 0.31790, 7.57579,
    0.19649, -7.77226, 4.48559,
    8.28664, -4.68209, -0.51401,
    -7.89368, 5.31788, -0.51401,
    -4.80351, 0.31791, -8.60501,
    0.19649, -7.77226, -5.51401,
    -7.89368, -4.68209, -0.51401,
    5.19654, 0.31790, 7.57579,
    5.19654, 0.31791, -8.60501
  }

  local facelist = {
    1,2,3,
    5,4,10,
    4,5,11,
    11,5,6,
    6,5,9,
    5,10,9,
    8,9,10,
    12,9,8,
    6,9,12,
    6,12,2,
    12,3,2,
    8,3,12,
    8,7,3,
    8,10,7,
    10,4,7,
    4,1,7,
    1,4,11,
    11,2,1,
    11,6,2,
    3,7,1
  }

  local step = 0
  for i=1,12 do

    vectorlist[i] = Vector3.new(vertexlist[1+step], vertexlist[2+step], vertexlist[3+step])
    step += 3

  end

  local cpoint = vectorlist[1]

  for i = 2, 12, 1 do
    cpoint = cpoint + vectorlist[i]
  end

  cpoint = cpoint * (1/12)

  for i = 1, 12, 1 do
    vectorlist[i] = vectorlist[i] - cpoint
  end

  step = 0
  for i=1,20 do

    polylist[i] = Polygon.new(
      vectorlist[facelist[1+step]],
      vectorlist[facelist[2+step]],
      vectorlist[facelist[3+step]],
      Vector2.new(96,0), --DEBUG
      Vector2.new(111,31),
      Vector2.new(80,31)
    )
    step += 3

  end

  return Polygon.create_object(polylist, Vector3.new(0,0,0))

end