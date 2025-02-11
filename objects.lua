-- objects

-- returns a cube object of side length 2
function create_cube()

  local polyList = {}
  -- all points of the polygons of the cube
  local newtable = 
  {
    1,1,1, 1,1,-1, 1,-1,1,
    1,-1,-1, 1,-1,1, 1,1,-1,

    1,1,1, -1,1,1, 1,1,-1,
    -1,1,-1, 1,1,-1, -1,1,1,

    -1,-1,1, -1,1,1, 1,-1,1,
    1,1,1, 1,-1,1, -1,1,1,

    -1,-1,1, -1,-1,-1, -1,1,1,
    -1,1,-1, -1,1,1, -1,-1,-1,

    1,1,-1, -1,1,-1, 1,-1,-1,
    -1,-1,-1, 1,-1,-1, -1,1,-1,

    1,-1,1, 1,-1,-1, -1,-1,1,
    -1,-1,-1, -1,-1,1, 1,-1,-1
  }

  local step = 0
  for i=1,12 do
    
    polyList[i] = create_3d_polygon(
      create_vector_3d(newtable[1 + step], newtable[2 + step], newtable[3 + step]),
      create_vector_3d(newtable[4 + step], newtable[5 + step], newtable[6 + step]),
      create_vector_3d(newtable[7 + step], newtable[8 + step], newtable[9 + step])
    )
    step += 9

  end

  return create_object(polyList, create_vector_3d(0,0,0))

end