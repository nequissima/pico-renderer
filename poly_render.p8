pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- main loop
function _init()

  p1 = create_vector_2d(64, 20)
  p2 = create_vector_2d(20, 100)
  p3 = create_vector_2d(80, 80)

end

function _draw()

  cls()
  color(6)
  draw_triangle(p1, p2, p3, 6, nil, nil)
  -- DEBUG
  -- rectfill(20,20, 80,80, 6)

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

  -- safeguard for if the points are the wrong way around
  -- could be removed for performance if needed
  if startY < endY then
    vector1, vector2 = vector2, vector1
  end

  local xDiff = endX - startX -- not strictly necessary, you can calculate xStep directly
  local yDiff = startY - endY
  local xStep = xDiff / yDiff
  
  local returnTable = {}
  returnTable["startY"] = startY
  returnTable["endY"] = endY

  -- PERFORMANCE: rounding the numbers here, hopefully not too big of a perf hit
  -- The numbers should be rounded ONLY ONCE here and nowhere else.

  local step = 0
  for y = startY, endY, -1 do

    returnTable[y] = round_positive(startX + (step * xStep))
    step += 1

  end

  return returnTable
  
end

-->8
-- graphics & drawing functions

-- draws triangle defined by three points on the screen
function draw_triangle(point1, point2, point3, color1, color2, dithering)

  local a = point1
  local b = point2
  local c = point3

  --[[ sort the points into descending height order so that
       a.y > b.y > c.y  ]]

  if (a.y < b.y) then a,b = b,a end
  if (b.y < c.y) then b,c = c,b end
  if (a.y < b.y) then a,b = b,a end

  -- variables for the interpolation tables
  local line1
  local line2
  local line3

  -- test for the possible cases
  if (a.y == b.y) then

    if (b.y == c.y) then
      -- all points are on a horizontal line
      local minX = min(min(a.x, b.x), c.x)
      local maxX = max(max(a.x, b.x), c.x)

      line(minX, a.y, maxX, a.y)
      
    else
      -- a and b are on a horizontal line

      line1 = interpolate_coords(a, c)
      line2 = interpolate_coords(b, c)

      _render_triangle_part(line1, line2, color1)

    end

  else

    if (b.y == c.y) then
      -- b and c are on a horizontal line

      line1 = interpolate_coords(a, b)
      line2 = interpolate_coords(a, c)

      _render_triangle_part(line1, line2, color1)

    else
      -- none of the points have the same height

      -- interpolate the lines between points
      line1 = interpolate_coords(a, c)
      line2 = interpolate_coords(a, b)
      line3 = interpolate_coords(b, c)

      -- one line of overdraw here but it's okay I think
      _render_triangle_part(line2, line1, color1)
      _render_triangle_part(line3, line1, color1)

    end

  end
  
end

-- takes two interpolated lines and fills in the triangle with horizontal lines (the shorter line must be line1)
function _render_triangle_part(line1, line2, color)

  for y = line1.startY, line1.endY, -1 do

    line(line1[y], y, line2[y], y, color)

  end

end

-->8
-- general helper functions

function round_positive(num)
  return flr(num + 0.5)
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
