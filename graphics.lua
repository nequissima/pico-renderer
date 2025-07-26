-- graphics & drawing functions

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


-- takes an object and renders it on the screen
-- assumes centre point of object is at 0,0,0 and rotates it then translates it
function render_object(object, objectRotMat, objectTransMat)

  local newList = {}
  local tempPoly
  local newListIndex = 1

  for i, v in ipairs(object.polyList) do
    tempPoly = Polygon.duplicate(v)
    Polygon.rotate(tempPoly, objectRotMat)
    Polygon.translate(tempPoly, objectTransMat)
    
    if (Polygon.centre_point(tempPoly) ^ tempPoly.normal < 0) then
      newList[newListIndex] = tempPoly
      newListIndex += 1
    end
    
  end

  newList = Polygon.sort_list(newList)

  for i, v in ipairs(newList) do
    Polygon.to_screenspace(v)
    Polygon.rasterize(v)
  end

end