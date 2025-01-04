-- vectors and vector functions

-- creates a 2d-vector from 2 co-ordinates
function create_vector_2d(xCoord, yCoord)

  return {["x"] = xCoord,
          ["y"] = yCoord}

end

-- creates a 3d-vector from 3 co-ordinates
function create_vector_3d(xCoord, yCoord, zCoord)

  return {["x"] = xCoord,
          ["y"] = yCoord,
          ["z"] = zCoord}

end

-- takes a 2d-vector and returns a clone
function clone_2d_vector(inputVector)

  return create_vector_2d(inputVector.x, inputVector.y)

end

-- takes a 3d-vector and returns a clone
function clone_3d_vector(inputVector)

  return create_vector_3d(inputVector.x, inputVector.y, inputVector.z)

end

-- takes two points and returns a table with y,x(!!) pairs for each y value between(inclusive) the two points
function interpolate_coords(vector1, vector2)

  -- making sure first point is the higher one
  if vector1.y < vector2.y then
    vector1, vector2 = vector2, vector1
  end
  
  local startY = vector1.y
  local endY   = vector2.y

  local startX = vector1.x
  local endX   = vector2.x

  local xDiff  = endX - startX -- not strictly necessary, you can calculate xStep directly
  local yDiff  = startY - endY
  local xStep  = xDiff / yDiff
  
  local returnTable = {["startY"] = startY,
                       ["endY"] = endY}

  -- PERFORMANCE: rounding the numbers here, hopefully not too big of a perf hit, important for how the triangles look
  -- The numbers should be rounded ONLY ONCE here and nowhere else.
  local step = 0
  for y = startY, endY, -1 do

    returnTable[y] = round_positive(startX + (step * xStep))
    step += 1

  end

  return returnTable
  
end

