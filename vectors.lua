-- vectors and vector functions

-- making sin and cos behave like you expect them to
p8cos = cos function cos(angle) return p8cos(angle/(3.1415*2)) end
p8sin = sin function sin(angle) return -p8sin(angle/(3.1415*2)) end

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
  
  local startY = round_positive(vector1.y)
  local endY   = round_positive(vector2.y)

  local startX = vector1.x
  local endX   = vector2.x

  local xDiff  = endX - startX -- not strictly necessary, you can calculate xStep directly
  local yDiff  = startY - endY -- should always be positive
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

  return create_vector_2d(64 + (vector.x * 64 / vector.z), 64 + (-vector.y * 64 / vector.z))

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

-- returns the dot product of two vectors
function dot_product_3d(vector1, vector2)
  return (vector1.x * vector2.x) + (vector1.y * vector2.y) + (vector1.z * vector2.z)
end


-- takes a polygon and calculates the normalized surface normal vector for it.
-- the cross calculation is done with the vectors ab and ac.
function calculate_surface_normal(vector1, vector2, vector3)

  return  normalize_3d_vector(cross_product_3d(sub_vectors(vector2, vector1), sub_vectors(vector3, vector1)))

end


-- takes a 3d vector and normalizes it
-- this is slow. big PERFORMANCE gains to be found by optimizing this. (maybe use the Quake 3 fast inverse sqrt?) 
function normalize_3d_vector(vector)

  local factor = 1 / sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
  return create_vector_3d(vector.x * factor, vector.y * factor, vector.z * factor)

end


-- multiplies a 3d vector with a matrix
-- modifies the original vector!!!
function multiply_matrix_vector_3d(matrix, vector)

  return create_vector_3d(
    vector.x * matrix[1][1] + vector.y * matrix[1][2] + vector.z * matrix[1][3],
    vector.x * matrix[2][1] + vector.y * matrix[2][2] + vector.z * matrix[2][3],
    vector.x * matrix[3][1] + vector.y * matrix[3][2] + vector.z * matrix[3][3]
  )

end

-- rotation counter-clockwise looking down assuming +y is up
function create_rotation_matrix_y(angle)

  return {{cos(angle), 0, -sin(angle)},
          {0,          1, 0},
          {sin(angle), 0, cos(angle)}}

end


-- rotation counter-clockwise looking down assuming +x is up
function create_rotation_matrix_x(angle)

  return {{1, 0,           0},
          {0, cos(angle),  sin(angle)},
          {0, -sin(angle), cos(angle)}}

end

-- TODO create matrix - matrix multiplication function it will be more efficient.