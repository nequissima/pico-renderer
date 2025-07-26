-- Polygons, objects, and functions related to both

Polygon = {}
Polygon.mt = {}


function Polygon.new(vecA, vecB, vecC, txtrVecA, txtrVecB, txtrVecC)

  local polygon = {["a"] = vecA,
                   ["b"] = vecB,
                   ["c"] = vecC,
                   ["ta"] = txtrVecA,
                   ["tb"] = txtrVecB,
                   ["tc"] = txtrVecC,
                   ["normal"] = Vector3.calculate_surface_normal(vecA, vecB, vecC)}

  setmetatable(polygon, Polygon.mt)
  return polygon

end


function Polygon.duplicate(a)

  local polygon = {["a"] = Vector3.duplicate(a.a),
                   ["b"] = Vector3.duplicate(a.b),
                   ["c"] = Vector3.duplicate(a.c),
                   ["ta"] = Vector3.duplicate(a.ta),
                   ["tb"] = Vector3.duplicate(a.tb),
                   ["tc"] = Vector3.duplicate(a.tc),
                   ["normal"] = Vector3.duplicate(a.normal)}

  setmetatable(polygon, Polygon.mt)
  return polygon

end


-- DESTRUCTIVE
function Polygon.to_screenspace(a)

  a.a = Vector3.to_screenspace(a.a)
  a.b = Vector3.to_screenspace(a.b)
  a.c = Vector3.to_screenspace(a.c)

end


function Polygon.centre_point(a)

  return Vector3.new((a.a.x + a.b.x + a.c.x) / 3,
                     (a.a.y + a.b.y + a.c.y) / 3,
                     (a.a.z + a.b.z + a.c.z) / 3)

end

function Polygon.sort_list(list)

  local tablelength = #list
  local biggest = 0
  local biggestindex = 0
  local dist = 0
  local newtable = {}
  local newtableindex = 1

  for j=1,tablelength do

    for i=1,tablelength do

      if list[i] != nil do

        dist = Vector3.distance(origin, Polygon.centre_point(list[i]))
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


-- DESTRUCTIVE
function Polygon.rotate(polygon, rotMat)

  polygon.a = (rotMat * polygon.a)
  polygon.b = (rotMat * polygon.b)
  polygon.c = (rotMat * polygon.c)
  polygon.normal = (rotMat * polygon.normal)

end


-- DESTRUCTIVE
function Polygon.translate(polygon, vector)

  polygon.a = polygon.a + vector
  polygon.b = polygon.b + vector
  polygon.c = polygon.c + vector

end


function Polygon.duplicate_list(list)

  local newlist = {}

  for i,v in ipairs(list) do
    newlist[i] = {
      Polygon.duplicate(v)
    }
  end

  return newlist
  
end


-- creates an object from a polygon list and a 3d vector as a centre point
-- returns an object
function Polygon.create_object(polygonList, centrePoint)

  return {["polyList"] = polygonList, ["centrePoint"] = centrePoint}

end


function Polygon.rasterize(polygon)

  -- moving data into local variables for faster access
  local a, b, c = polygon.a, polygon.b, polygon.c
  local text_a, text_b, text_c = polygon.ta, polygon.tb, polygon.tc

  -- making sure the points are in order from highest to smallest y-value
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

  -- moving data into local variables for faster access
  local xa, ya, xb, yb, xc, yc = a.x, a.y, b.x, b.y, c.x, c.y
  local xa_t, ya_t, xb_t, yb_t, xc_t, yc_t = text_a.x, text_a.y, text_b.x, text_b.y, text_c.x, text_c.y

  -- the slope of the lines
  local xStepAC = (xc - xa) / (ya - yc)
  local xStepAB = (xb - xa) / (ya - yb)
  local xStepBC = (xc - xb) / (yb - yc)

  -- start and end y-values for the two triangle parts
  local startY1 = flr(ya)
  local endY1 = ceil(yb)
  local startY2 = flr(yb)
  local endY2 = ceil(yc)

  -- difference from the points' y-values and the integer rounded values
  local start1YDiff = ya - startY1
  local start2YDiff = yb - startY2
  local start2YDiffLong = ya - startY2

  -- signed area of the whole triangle (times two, technically)
  local triArea = signedTriArea(xa, ya, xb, yb, xc, yc)

  -- initial X-values for the starting y-values
  local xStartAC = xa + start1YDiff * xStepAC
  local xStartAB = xa + start1YDiff * xStepAB
  local xStartBC = xb + start2YDiff * xStepBC
  local xStartAC2 = xa + start2YDiffLong * xStepAC

  local startY = startY1
  local endY = endY1

  local leftStartX = xStartAB
  local rightStartX = xStartAC
  local leftXStep = xStepAB
  local rightXStep = xStepAC

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

  local cumLeftX
  local cumRightX

  local ypConstAbp = (xb - xa) / triArea
  local xpConstAbp = (ya - yb) / triArea
  local gnConstAbp = (yb * xa - xb * ya) / triArea

  local ypConstBcp = (xc - xb) / triArea
  local xpConstBcp = (yb - yc) / triArea
  local gnConstBcp = (yc * xb - xc * yb) / triArea

  local ypConstCap = (xa - xc) / triArea
  local xpConstCap = (yc - ya) / triArea
  local gnConstCap = (ya * xc - xa * yc) / triArea

  -- TODO: use goto jumps to avoid a function call; it'll make the code a lot cleaner
  -- also instead of calling the func with different args based on whether b is left or right of AC,
  -- just swap the cumulative xy vars and the xstep vars with each other. that way it's the same call.

  local loop = 1

  ::drawfuncstart::

    if endY > startY then
      goto drawfuncend
    end

    if (triArea < 0) then
      leftStartX, leftXStep, rightStartX, rightXStep = rightStartX, rightXStep, leftStartX, leftXStep
    end

    cumLeftX = leftStartX
    cumRightX = rightStartX

    for y = startY, endY, -1 do

      lx = ceil(cumLeftX)
      rx = flr(cumRightX)

      if (lx <= rx) then

        aWeightLx = lx * xpConstBcp + y * ypConstBcp + gnConstBcp
        bWeightLx = lx * xpConstCap + y * ypConstCap + gnConstCap
        cWeightLx = lx * xpConstAbp + y * ypConstAbp + gnConstAbp

        aWeightRx = rx * xpConstBcp + y * ypConstBcp + gnConstBcp
        bWeightRx = rx * xpConstCap + y * ypConstCap + gnConstCap
        cWeightRx = rx * xpConstAbp + y * ypConstAbp + gnConstAbp

        txxCoLeft = xa_t * aWeightLx + xb_t * bWeightLx + xc_t * cWeightLx
        txyCoLeft = ya_t * aWeightLx + yb_t * bWeightLx + yc_t * cWeightLx

        txxCoRight = xa_t * aWeightRx + xb_t * bWeightRx + xc_t * cWeightRx
        txyCoRight = ya_t * aWeightRx + yb_t * bWeightRx + yc_t * cWeightRx

        txStepX = (txxCoRight - txxCoLeft) / (rx - lx)
        txStepY = (txyCoRight - txyCoLeft) / (rx - lx)

        curTextureX = txxCoLeft
        curTextureY = txyCoLeft

          for x = lx, rx, 1 do

            pset(x, y, sget((curTextureX + 0.5) & 0xFF.00,(curTextureY + 0.5) & 0xFF.00))
            curTextureX += txStepX
            curTextureY += txStepY

          end

      end

      cumLeftX += leftXStep
      cumRightX += rightXStep

    end

  ::drawfuncend::

  if (loop == 1) then
    
    leftStartX = xStartBC
    rightStartX = xStartAC2
    leftXStep = xStepBC
    rightXStep = xStepAC
    startY = startY2
    endY = endY2

    loop = 2

    goto drawfuncstart

  end

end