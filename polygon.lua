-- Polygons, objects, and functions related to both

#include math.lua

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