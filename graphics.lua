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


-- takes three points and returns a polygon. it is assumed that the order of the polygons is counter-clockwise when looking
-- in the direction opposite the normal vector
function create_3d_polygon(vector1, vector2, vector3)

  return {[1] = vector1,
          [2] = vector2,
          [3] = vector3,
          ["normal"] = calculate_surface_normal(vector1, vector2, vector3)}

end


-- clones a polygon
function clone_3d_polygon(polygon)

  return {[1] = polygon[1],
          [2] = polygon[2],
          [3] = polygon[3],
          ["normal"] = polygon.normal}

end


-- takes a polygon and changes it to relative screenspace co-ordinates.
-- returns a 2d-polygon
-- NOTE: the normal vector is still in 3d space because it is needed for the shader function
function polygon_to_relative(polygon)

  return {[1] = _3d_vector_to_screenspace(polygon[1]),
          [2] = _3d_vector_to_screenspace(polygon[2]),
          [3] = _3d_vector_to_screenspace(polygon[3]),
          ["normal"] = polygon.normal}

end


function create_an_object(polygonList, centrePoint)

  return {["polyList"] = polygonList, ["centrePoint"] = centrePoint}

end


function clone_object(object)


  
end