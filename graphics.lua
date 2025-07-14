-- graphics & drawing functions

-- draws triangle defined by three points on the screen
function draw_polygon(polygon)

  -- saving all of the polygon points into local variables for performance
  local ax, ay, bx, by, cx, cy = polygon[1].x, polygon[1].y, polygon[2].x, polygon[2].y, polygon[3].x, polygon[3].y
  local tax, tay, tbx, tby, tcx, tcy = polygon[4].x / 100,
                                       polygon[4].y / 100,
                                       polygon[5].x / 100,
                                       polygon[5].y / 100,
                                       polygon[6].x / 100,
                                       polygon[6].y / 100

  local abcArea = ((bx - ax) * (cy - ay) - (by - ay) * (cx - ax)) / 100
  
  local minX = round_positive(min(min(ax, bx), cx))
  local minY = round_positive(min(min(ay, by), cy))
  local maxX = round_positive(max(max(ax, bx), cx))
  local maxY = round_positive(max(max(ay, by), cy))

  local aWeight, bWeight, cWeight

  local ypConstAbp = (bx - ax) / abcArea
  local xpConstAbp = (ay - by) / abcArea
  local gnConstAbp = (by * ax - bx * ay) / abcArea

  local ypConstBcp = (cx - bx) / abcArea
  local xpConstBcp = (by - cy) / abcArea
  local gnConstBcp = (cy * bx - cx * by) / abcArea

  local ypConstCap = (ax - cx) / abcArea
  local xpConstCap = (cy - ay) / abcArea
  local gnConstCap = (ay * cx - ax * cy) / abcArea

  for y = minY, maxY, 1 do
    
    for x = minX, maxX, 1 do

      --[[

      abpArea = ((bx - ax) * (y - ay) - (by - ay) * (x - ax))
      if abpArea < 0 then goto xloopfin end

      bcpArea = ((cx - bx) * (y - by) - (cy - by) * (x - bx))
      if bcpArea < 0 then goto xloopfin end

      capArea = ((ax - cx) * (y - cy) - (ay - cy) * (x - cx))
      if capArea < 0 then goto xloopfin end  

      aWeight = bcpArea / abcArea
      bWeight = capArea / abcArea
      cWeight = abpArea / abcArea

      ]]   

      aWeight = y * ypConstAbp + x * xpConstAbp + gnConstAbp
      if aWeight < 0 then goto xloopfin end

      bWeight = y * ypConstBcp + x * xpConstBcp + gnConstBcp
      if bWeight < 0 then goto xloopfin end

      cWeight = y * ypConstCap + x * xpConstCap + gnConstCap
      if cWeight < 0 then goto xloopfin end

      pset(x, y, sget(flr(tax * aWeight + tbx * bWeight + tcx * cWeight + 0.5),
                      flr(tay * aWeight + tby * bWeight + tcy * cWeight + 0.5)))

      ::xloopfin::

    end

  end
  
end


-- assumes points are in counter-clockwise order.
function signedTriArea(a, b, cx, cy)

  return ((b.x - a.x) * (cy - a.y) - (b.y - a.y) * (cx - a.x))

end


-- takes three points and returns a polygon. it is assumed that the order of the polygons is counter-clockwise when looking
-- in the direction opposite the normal vector
function create_3d_polygon(vector1, vector2, vector3, v1texture, v2texture, v3texture)

  return {[1] = vector1,  -- point a
          [2] = vector2,  -- point b
          [3] = vector3,  -- point c
          [4] = v1texture,  -- UV coordinate for point a
          [5] = v2texture,  -- UV coordinate for point b
          [6] = v3texture,  -- UV coordinate for point c
          ["normal"] = calculate_surface_normal(vector1, vector2, vector3)}

end


-- clones a polygon
function clone_3d_polygon(v)

  return {
    create_vector_3d(v[1].x, v[1].y, v[1].z), -- point a
    create_vector_3d(v[2].x, v[2].y, v[2].z), -- point b
    create_vector_3d(v[3].x, v[3].y, v[3].z), -- point c
    create_vector_2d(v[4].x, v[4].y), -- UV coordinate for point a
    create_vector_2d(v[5].x, v[5].y), -- UV vector ab
    create_vector_2d(v[6].x, v[6].y), -- UV vector ac
    ["normal"] = create_vector_3d(v["normal"].x, v["normal"].y, v["normal"].z),
  }

end


-- takes a polygon and changes it to relative screenspace co-ordinates.
-- returns a 2d-polygon
-- NOTE: the normal vector is still in 3d space because it is needed for the shader function
function polygon_to_relative(polygon)

  polygon[1] = _3d_vector_to_screenspace(polygon[1])
  polygon[2] = _3d_vector_to_screenspace(polygon[2])
  polygon[3] = _3d_vector_to_screenspace(polygon[3])

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

function dicepalette()
  pal(14, -8, 1)
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

  -- print(stat(1))

  for i, v in ipairs(newlist) do
    polygon_to_relative(v)
    draw_polygon(v)
    -- print(tostr(v.normal.x) .. ", " .. tostr(v.normal.y) .. ", " .. tostr(v.normal.z))
  end

  -- print(stat(1))

end

-- returns a clone of the target object
-- don't know if I need this
function clone_polylist(polylist)

  local newlist = {}

  for i,v in ipairs(polylist) do
    newlist[i] = {
      clone_3d_polygon(v)
    }
  end

  return newlist
  
end