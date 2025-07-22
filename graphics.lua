-- graphics & drawing functions

-- draws triangle defined by three points on the screen
function draw_polygon(polygon)

  -- saving all of the polygon points into local variables for performance
  local ax, ay, bx, by, cx, cy = polygon[1].x, polygon[1].y, polygon[2].x, polygon[2].y, polygon[3].x, polygon[3].y

  -- these are divided by 100 to offset the triangle area being divided by 100 for the final calculations
  local tax, tay, tbx, tby, tcx, tcy = polygon[4].x / 100,
                                       polygon[4].y / 100,
                                       polygon[5].x / 100,
                                       polygon[5].y / 100,
                                       polygon[6].x / 100,
                                       polygon[6].y / 100

  -- 1/2 shoelace formula for triangle area, divided by 100
  -- this needs to be divided by a large number, or otherwise the precalculated coefficients
  -- become too small, and we start getting weird artifacting from lack of precision
  local abcArea = ((bx - ax) * (cy - ay) - (by - ay) * (cx - ax)) / 100
  
  -- bounding box for the polygon
  local minX = round_positive(min(min(ax, bx), cx))
  local minY = round_positive(min(min(ay, by), cy))
  local maxX = round_positive(max(max(ax, bx), cx))
  local maxY = round_positive(max(max(ay, by), cy))

  -- weights for texture co-ordinates
  local aWeight, bWeight, cWeight

  -- we pre-calculate the coefficients and constants 
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

      aWeight = y * ypConstAbp + x * xpConstAbp + gnConstAbp
      if aWeight < 0 then goto xloopfin end

      bWeight = y * ypConstBcp + x * xpConstBcp + gnConstBcp
      if bWeight < 0 then goto xloopfin end

      cWeight = y * ypConstCap + x * xpConstCap + gnConstCap
      if cWeight < 0 then goto xloopfin end

      -- this could maybe be replaced by directly changing the video memory
      -- don't know if that's even any faster, however
      pset(x, y, sget((tax * aWeight + tbx * bWeight + tcx * cWeight + 0.5) & 0xFF.00,
                      (tay * aWeight + tby * bWeight + tcy * cWeight + 0.5) & 0xFF.00))

      ::xloopfin::

    end

  end
  
end


function draw_polygon_alt(polygon)

  -- saving all of the polygon points into local variables for performance
  local ax, ay, bx, by, cx, cy = polygon[1].x, polygon[1].y, polygon[2].x, polygon[2].y, polygon[3].x, polygon[3].y

  -- these are divided by 100 to offset the triangle area being divided by 100 for the final calculations
  local tax, tay, tbx, tby, tcx, tcy = polygon[4].x / 100,
                                       polygon[4].y / 100,
                                       polygon[5].x / 100,
                                       polygon[5].y / 100,
                                       polygon[6].x / 100,
                                       polygon[6].y / 100


  local ta_memaddress = 0x0000 + tax \ 2 + tay * 64
  local tb_memaddress = 0x0000 + tbx \ 2 + tby * 64
  local tc_memaddress = 0x0000 + tcx \ 2 + tcy * 64


  -- 1/2 shoelace formula for triangle area, divided by 100
  -- this needs to be divided by a large number, or otherwise the precalculated coefficients
  -- become too small, and we start getting weird artifacting from lack of precision
  local abcArea = ((bx - ax) * (cy - ay) - (by - ay) * (cx - ax)) / 100
  
  -- bounding box for the polygon
  local minX = round_positive(min(min(ax, bx), cx))
  local minY = round_positive(min(min(ay, by), cy))
  local maxX = round_positive(max(max(ax, bx), cx))
  local maxY = round_positive(max(max(ay, by), cy))

  -- weights for texture co-ordinates
  local aWeight, bWeight, cWeight

  -- we pre-calculate the coefficients and constants 
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

      aWeight = y * ypConstAbp + x * xpConstAbp + gnConstAbp
      if aWeight < 0 then goto xloopfin end

      bWeight = y * ypConstBcp + x * xpConstBcp + gnConstBcp
      if bWeight < 0 then goto xloopfin end

      cWeight = y * ypConstCap + x * xpConstCap + gnConstCap
      if cWeight < 0 then goto xloopfin end

      -- this could maybe be replaced by directly changing the video memory
      -- don't know if that's even any faster, however
      pset(x, y, sget((tax * aWeight + tbx * bWeight + tcx * cWeight + 0.5) & 0xFF.00,
                      (tay * aWeight + tby * bWeight + tcy * cWeight + 0.5) & 0xFF.00))

      ::xloopfin::

    end

  end
  
end


function draw_polygon_fast(polygon)

  local a, b, c = polygon[1], polygon[2], polygon[3]
  local text_a, text_b, text_c = polygon[4], polygon[5], polygon[6]

  if (a.y < b.y) then
    a, b = b, a
    text_a, text_b = text_b, text_a
  end

  if (b.y < c.y) then
    b, c = c, b
    text_b, text_c = text_c, text_b
  end

  if (a.y < b.y) then
    a, b = b, a
    text_a, text_b = text_b, text_a
  end

  local xa, ya, xb, yb, xc, yc = a.x, a.y, b.x, b.y, c.x, c.y
  local xa_t, ya_t, xb_t, yb_t, xc_t, yc_t = text_a.x, text_a.y, text_b.x, text_b.y, text_c.x, text_c.y

  local xStepAC = (xc - xa) / (ya - yc)
  local xStepAB = (xb - xa) / (ya - yb)
  local xStepBC = (xc - xb) / (yb - yc)

  local startY1 = flr(ya)
  local endY1 = ceil(yb)
  local startY2 = flr(yb)
  local endY2 = ceil(yc)

  local start1YDiff = ya - startY1
  local start2YDiff = yb - startY2
  local start2YDiffLong = ya - startY2

  local triArea = signedTriArea(xa, ya, xb, yb, xc, yc)

  local xStartAC = xa + start1YDiff * xStepAC
  local xStartAB = xa + start1YDiff * xStepAB
  local xStartBC = xb + start2YDiff * xStepBC
  local xStartAC2 = xa + start2YDiffLong * xStepAC

  local drawfunc = function(startY, endY, leftStartX, rightStartX, leftXStep, rightXStep)

    if endY > startY then
      goto drawfuncend
    end

    local cumLeftX = leftStartX
    local cumRightX = rightStartX

    local lx
    local rx

    local txxCoLeft
    local txxCoRight
    local txyCoLeft
    local txyCoRight
    local txStepX
    local txStepY

    local aWeightLx
    local bWeightLx
    local cWeightLx

    local aWeightRx
    local bWeightRx
    local cWeightRx

    local curTextureX
    local curTextureY

    for y = startY, endY, -1 do

      lx = ceil(cumLeftX)
      rx = flr(cumRightX)

      if (lx <= rx) then

      aWeightLx = signedTriArea(xb, yb, xc, yc, lx, y) / triArea
      bWeightLx = signedTriArea(xc, yc, xa, ya, lx, y) / triArea
      cWeightLx = signedTriArea(xa, ya, xb, yb, lx, y) / triArea

      aWeightRx = signedTriArea(xb, yb, xc, yc, rx, y) / triArea
      bWeightRx = signedTriArea(xc, yc, xa, ya, rx, y) / triArea
      cWeightRx = signedTriArea(xa, ya, xb, yb, rx, y) / triArea

      txxCoLeft = xa_t * aWeightLx + xb_t * bWeightLx + xc_t * cWeightLx
      txyCoLeft = ya_t * aWeightLx + yb_t * bWeightLx + yc_t * cWeightLx

      txxCoRight = xa_t * aWeightRx + xb_t * bWeightRx + xc_t * cWeightRx
      txyCoRight = ya_t * aWeightRx + yb_t * bWeightRx + yc_t * cWeightRx

      txStepX = (txxCoRight - txxCoLeft) / (rx - lx)
      txStepY = (txyCoRight - txyCoLeft) / (rx - lx)

      curTextureX = txxCoLeft
      curTextureY = txyCoLeft

        for x = lx, rx, 1 do
          --pset(x, y, sget(flr(txz + x * tx_xs + y * tx_ys + 0.5),
                          --flr(tyz + x * ty_xs + y * ty_ys + 0.5)))

          pset(x, y, sget((curTextureX + 0.5) & 0xFF.00,(curTextureY + 0.5) & 0xFF.00))
          curTextureX += txStepX
          curTextureY += txStepY
        end

      end

      cumLeftX += leftXStep
      cumRightX += rightXStep

    end

    ::drawfuncend::

  end


  if (triArea < 0) then

    drawfunc(startY1, endY1, xStartAC, xStartAB, xStepAC, xStepAB)
    drawfunc(startY2, endY2, xStartAC2, xStartBC, xStepAC, xStepBC)

  else

    drawfunc(startY1, endY1, xStartAB, xStartAC, xStepAB, xStepAC)
    drawfunc(startY2, endY2, xStartBC, xStartAC2, xStepBC, xStepAC)

  end

end


-- assumes points are in counter-clockwise order.
function signedTriArea(xa, ya, xb, yb, xc, yc)

  return ((xb - xa) * (yc - ya) - (yb - ya) * (xc - xa))

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
    draw_polygon_fast(v)
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