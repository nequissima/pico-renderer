pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main loop

function _init()

end

function _draw()

end

function _update()

end

-->8
-- vectors and vector functions

-- creates a 2d-vector from 2 co-ordinates
function create_vector_2d(xCoord, yCoord)

  local v = {}

  v["x"] = xCoord
  v["y"] = yCoord

  return v

end

-- creates a 3d-vector from 3 co-ordinates
function create_vector_3d(xCoord, yCoord, zCoord)

  local v = {}

  v["x"] = xCoord
  v["y"] = yCoord
  v["z"] = zCoord

  return v

end

-- takes a 2d-vector and returns a clone
function clone_2d_vector(inputVector)

  local v = {}
  
  v["x"] = inputVector.x
  v["y"] = inputVector.y

  return v

end

-- takes a 3d-vector and returns a clone
function clone_3d_vector(inputVector)

  local v = {}
  
  v["x"] = inputVector.x
  v["y"] = inputVector.y
  v["z"] = inputVector.z

  return v

end

-- takes two points and returns a table with y,x(!!) pairs for each y value between(inclusive) the two points
-- assumes that the first point has a greater y-value than the second point
function interpolate_coords(vector1, vector2)

  local startY = vector1.y
  local endY = vector2.y
  local startX = vector1.x
  local endX = vector2.x

  local xDiff = startX - endX
  local yDiff = startY - endY
  local xStep = xDiff / yDiff
  
  local returnTable = {}
  returnTable["startY"] = startY
  returnTable["endY"] = endY

  -- I might need to round these values to integers if this doesn't work

  local step = 0
  for y = startY, endY, -1 do

    returnTable[y] = startX + (step * xStep)

  end

  return returnTable
  
end

-->8
-- graphics & drawing functions

-- draws triangle defined by three points on the screen
function draw_triangle(point1, point2, point3)

  local a = point1
  local b = point2
  local c = point3

  --[[ sort the points into descending height order so that
       a.y > b.y > c.y  ]]

  if (a.y < b.y) then a,b = b,a end
  if (b.y < c.y) then b,c = c,b end
  if (a.y < b.y) then a,b = b,a end

  -- test for the possible cases

  if (a.y == b.y) then

    if (b.y == c.y) then
      -- all points are on a horizontal line

    else
      -- a and b are on a horizontal line

    end

  else

    if (b.y == c.y) then
      -- b and y are on a horizontal line

    else
      -- none of the points have the same height

    end


  end
  
end

-->8
-- general helper functions



__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
