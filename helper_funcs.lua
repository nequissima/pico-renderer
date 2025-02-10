-- general helper functions

-- rounds a positive number to the nearest integer
function round_positive(num)
  return flr(num + 0.5)
end


-- squares a number
function square(num)
  return num*num
end

-- takes 2 3d points and returns the distance between them
function dist_3d(p1, p2)

  return sqrt(square(p1.x - p2.x) + square(p1.y - p2.y) + square(p1.z - p2.z))

end