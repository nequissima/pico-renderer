-- graphics & drawing functions

-- draws triangle defined by three points on the screen
function draw_triangle(point1, point2, point3)

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

      _render_triangle_part(line1, line2)

    end

  else

    if (b.y == c.y) then
      -- b and c are on a horizontal line

      line1 = interpolate_coords(a, b)
      line2 = interpolate_coords(a, c)

      _render_triangle_part(line1, line2)

    else
      -- none of the points have the same height

      -- interpolate the lines between points
      line1 = interpolate_coords(a, c)
      line2 = interpolate_coords(a, b)
      line3 = interpolate_coords(b, c)

      -- one line of overdraw here but it's okay I think
      _render_triangle_part(line2, line1)
      _render_triangle_part(line3, line1)

    end

  end
  
end


-- takes two interpolated lines and fills in the triangle with horizontal lines (the shorter line must be line1)
function _render_triangle_part(line1, line2)

  for y = line1.startY, line1.endY, -1 do

    line(line1[y], y, line2[y], y)

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
function clone_3d_polygon(v)

  return {
    create_vector_3d(v[1].x, v[1].y, v[1].z),
    create_vector_3d(v[2].x, v[2].y, v[2].z),
    create_vector_3d(v[3].x, v[3].y, v[3].z),
    ["normal"] = create_vector_3d(v["normal"].x, v["normal"].y, v["normal"].z),
  }

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


-- creates an object from a polygon list and a 3d vector as a centre point
-- returns an object
function create_object(polygonList, centrePoint)

  return {["polyList"] = polygonList, ["centrePoint"] = centrePoint}

end


-- selects the color based on which component of the normal vector has the greatest magnitude
function shader1(normal)

  local absY = abs(normal.y)
  local absX = abs(normal.x)
  local absZ = abs(normal.z)

  nmax = max(max(absX, absY), absZ)
  if nmax == absX then
    color(8)
  elseif(nmax == absY) then
    color(11)
  else
    color(12)
  end

end

-- top down lighting shader
function shader2(normal)

  local y = normal.y

  if y > 0.66 then
    color(1)
  elseif y > 0.33 then
    color(2)
  elseif y > 0 then
    color(3)
  elseif y > -0.33 then
    color(4)
  elseif y > -0.66 then
    color(5)
  else
    color(6)
  end

end


-- lighting shader with dithering
-- this is such spaghetti but I'm not sure there's an easier way
function shader3(normal)

  local y = normal.y

  if y > 0.82 then
    color(1)
    fillp(0)
  elseif y > 0.64 then
    color(0x12)
    fillp(0b0011001111001100)
  elseif y > 0.45 then
    color(2)
    fillp(0)
  elseif y > 0.27 then
    color(0x23)
    fillp(0b0011001111001100)
  elseif y > 0.09 then
    color(3)
    fillp(0)
  elseif y > -0.09 then
    color(0x34)
    fillp(0b0011001111001100)
  elseif y > -0.27 then
    color(4)
    fillp(0)
  elseif y > -0.45 then
    color(0x45)
    fillp(0b0011001111001100)
  elseif y > -0.64 then
    color(5)
    fillp(0)
  elseif y > -0.82 then
    color(0x56)
    fillp(0b0011001111001100)
  else
    color(6)
    fillp(0)
  end
end


-- initializes the red-blue palette
function redbluepalette()
  pal(1, 8, 1)
  pal(2, 2, 1)
  pal(3, -14, 1)
  pal(4, -15, 1)
  pal(5, -4, 1)
  pal(6, 12, 1)
end


-- initializes the red palette
function redpalette()
  pal(1, 14, 1)
  pal(2, 8, 1)
  pal(3, -8, 1)
  pal(4, 2, 1)
  pal(5, -14, 1)
  pal(6, 0, 1)
end


-- renders a polygon on the screen
-- assumes that the polygon has been converted to 2d
function render_polygon(polygon, shader)

  shader3(polygon.normal)
  -- placeholder, the render func should change the color settings
  draw_triangle(polygon[1], polygon[2], polygon[3])

end


-- takes a polygon and returns an approximate center point for it
function cpoint_approx(polygon)

  return create_vector_3d((polygon[1].x + polygon[2].x + polygon[3].x) / 3,
                          (polygon[1].y + polygon[2].y + polygon[3].y) / 3,
                          (polygon[1].z + polygon[2].z + polygon[3].z) / 3)

end

-- assumes that no polygons centrepoints lie exactly on the origin, otherwise this will crash
-- takes a list of polygons and returns a sorted list
-- assumes camera is at origin
function sort_polygons(list)

  local tablelength = #list
  local biggest = 0
  local biggestindex = 0
  local dist = 0
  local newtable = {}
  local newtableindex = 1

  for j=1,tablelength do

    for i=1,tablelength do

      if list[i] != nil do

        dist = dist_3d(origin, cpoint_approx(list[i]))
        if dist > biggest do

          biggest = dist
          biggestindex = i

        end

      end

    end

    newtable[newtableindex] = list[biggestindex]
    list[biggestindex] = nil
    biggest = 0
    newtableindex += 1

  end

  return newtable

end


-- takes a polygon and applies a rotation matrix
-- DOES NOT RETURN A NEW POLYGON
-- TRANSFORMS THE GIVEN POLY
function rotate_polygon(polygon, rotMat)

  polygon[1] = multiply_matrix_vector_3d(rotMat, polygon[1])
  polygon[2] = multiply_matrix_vector_3d(rotMat, polygon[2])
  polygon[3] = multiply_matrix_vector_3d(rotMat, polygon[3])
  polygon["normal"] = multiply_matrix_vector_3d(rotMat, polygon["normal"])

end


-- takes a polygon and translates it according to the translation vector
-- DOES NOT RETURN A NEW POLYGON
-- TRANSFORMS THE GIVEN POLY
function translate_polygon(polygon, vector)

  polygon[1] = add_vectors(polygon[1], vector)
  polygon[2] = add_vectors(polygon[2], vector)
  polygon[3] = add_vectors(polygon[3], vector)

end


-- takes an object and renders it on the screen
-- assumes centre point of object is at 0,0,0 and rotates it then translates it
function render_object(object, objectRotH, objectRotV, objectTrans)

  local newlist = {}
  local temppoly
  local newlistindex = 1

  for i, v in ipairs(object.polyList) do
    temppoly = clone_3d_polygon(v)
    rotate_polygon(temppoly, objectRotV)
    rotate_polygon(temppoly, objectRotH)
    translate_polygon(temppoly, objectTrans)
    -- realistically we should caluclate the cpoint approx when we create a poly and then rotate it
    -- i'd have to refactor a lot of shit for that though :(
    if (dot_product_3d(cpoint_approx(temppoly), temppoly.normal) < 0) then
      newlist[newlistindex] = temppoly
      newlistindex += 1
    end
    
  end

  newlist = sort_polygons(newlist)

  for i, v in ipairs(newlist) do
    render_polygon(polygon_to_relative(v), nil)
    -- print(tostr(v.normal.x) .. ", " .. tostr(v.normal.y) .. ", " .. tostr(v.normal.z))
  end

end

-- returns a clone of the target object
-- don't know if I need this
function clone_polylist(polylist)

  local newlist = {}

  for i,v in ipairs(polylist) do
    newlist[i] = {
      create_vector_3d(v[1].x, v[1].y, v[1].z),
      create_vector_3d(v[2].x, v[2].y, v[2].z),
      create_vector_3d(v[3].x, v[3].y, v[3].z),
      ["normal"] = create_vector_3d(v["normal"].x, v["normal"].y, v["normal"].z),
    }
  end

  return newlist
  
end