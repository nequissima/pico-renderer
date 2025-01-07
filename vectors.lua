-- vectors and vector functions

-- creates a 2d-vector from 2 coordinates
function create_vector_2d(xCoord, yCoord)

  return {["x"] = xCoord,
          ["y"] = yCoord}

end


-- creates a 3d-vector from 3 coordinates
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


-- takes a 3d vector and returns its position in relative screenspace coordinates (-1 to 1)
function _3d_vector_to_screenspace(vector)

  -- this function assumes a horizontal and vertical FOV of 90.
  -- for other values you have to squish the values, which is probably more efficient to do all at once earlier than this func.

  -- the function assumes that the camera is at 0,0,0 and it is pointing in the direction of the positive z-axis
  -- local and global rotation must be done before calling this function

  -- this vector returns screenspace coordinates that are off the screen, offscreen polys have to be culled later.

  return create_vector_2d(vector.x / vector.z, vector.y / vector.z)

end


-- takes two 3d vectors and adds them together
function add_vectors(vector1, vector2)

  return create_vector_3d(vector1.x + vector2.x,
                          vector1.y + vector2.y,
                          vector1.z + vector2.z)

end


-- takes two 3d vectors and subtracts the second from the first
function sub_vectors(vector1, vector2)

  return create_vector_3d(vector1.x - vector2.x,
                          vector1.y - vector2.y,
                          vector1.z - vector2.z)

end


-- calculates the cross product between two vectors
function cross_product_3d(vector1, vector2)

  return create_vector_3d(vector1.y * vector2.z - vector1.z * vector2.y,
                          vector1.z * vector2.x - vector1.x * vector2.z,
                          vector1.x * vector2.y - vector1.y * vector2.x)

end


-- takes a polygon and calculates the normalized surface normal vector for it.
-- the cross calculation is done with the vectors ab and ac.
function calculate_surface_normal(vector1, vector2, vector3)

  return  normalize_3d_vector(sub_vectors(vector2, vector1), sub_vectors(vector3, vector1))

end


-- takes a 3d vector and normalizes it
-- this is slow. big PERFORMANCE gains to be found by optimizing this. (maybe use the Quake 3 fast inverse sqrt?) 
function normalize_3d_vector(vector)

  local factor = 1 / sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
  return create_vector_3d(vector.x / factor, vector.y / factor, vector.z / factor)

end


function polygon_to_relative()

end
