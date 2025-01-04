-- graphics & drawing functions

-- draws triangle defined by three points on the screen
function draw_triangle(point1, point2, point3, color1, color2, dithering)

  -- PERFORMANCE: to save tokens you can remove this and rename the abc to the points
  local a, b, c = point1, point2, point3


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
