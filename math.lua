-- Vectors, matrices, and functions related to both


-- making sin and cos behave like you expect them to
p8cos = cos function cos(angle) return p8cos(angle/(3.1415*2)) end
p8sin = sin function sin(angle) return -p8sin(angle/(3.1415*2)) end

-- Singleton constructor objects

Vector3 = {}
Vector3.mt = {}
Vector3.mt.__add = Vector3.add
Vector3.mt.__sub = Vector3.subtract
Vector3.mt.__mul = Vector3.multiply_constant
Vector3.mt.__div = Vector3.divide_constant
Vector3.mt.__pow = Vector3.dot_product
Vector3.mt.__mod = Vector3.cross_product
Vector3.mt.__len = Vector3.length


Vector2 = {}
Vector2.mt = {}
Vector2.mt.__add = Vector2.add
Vector2.mt.__sub = Vector2.subtract
Vector2.mt.__mul = Vector2.multiply_constant
Vector2.mt.__div = Vector2.divide_constant
Vector2.mt.__pow = Vector2.dot_product


Matrix3x3 = {}
Matrix3x3.mt = {}
Matrix3x3.mt.__pow = Matrix3x3.multiply_matrix_matrix
Matrix3x3.mt.__mul = Matrix3x3.multiply_matrix_vector


-- 3D Vector functions

function Vector3.new(x, y, z)

  local vector3 = {["x"] = x,
                   ["y"] = y,
                   ["z"] = z}
                
  setmetatable(vector3, Vector3.mt)
  return vector3

end


function Vector3.duplicate(a)

  return Vector3.new(a.x, a.y, a.z)

end


function Vector3.add(a, b)

  return Vector3.new(a.x + b.x,
                     a.y + b.y,
                     a.z + b.z)

end


function Vector3.subtract(a, b)

  return Vector3.new(a.x - b.x,
                     a.y - b.y,
                     a.z - b.z)

end


function Vector3.dot_product(a, b)

  return a.x * b.x + a.y * b.y + a.z * b.z

end


function Vector3.cross_product(a, b)

  return Vector3.new(a.y * b.z - a.z * b.y,
                     a.z * b.x - a.x * b.z,
                     a.x * b.y - a.y * b.x)

end


function Vector3.multiply_constant(a, b)

  return Vector3.new(a.x * b,
                     a.y * b,
                     a.z * b)

end


function Vector3.divide_constant(a, b)

  return Vector3.new(a.x / b,
                     a.y / b,
                     a.z / b)

end


function Vector3.length(a)

  return sqrt(a.x * a.x + a.y * a.y + a.z * a.z)

end


function Vector3.normalize(a)

  local vectorLength = 1 / #a

  return Vector3.new(a.x * vectorLength,
                     a.y * vectorLength,
                     a.z * vectorLength)


end


function Vector3.to_screenspace(a)

  return Vector2.new(63.5 + (a.x * 64 / a.z), 63.5 + (-a.y * 64 / a.z))

end


function Vector3.calculate_surface_normal(a, b, c)

  return Vector3.normalize((b - a) % (c - a))

end


function Vector3.distance(a, b)

  return #(b - a)

end


-- 2D Vector functions

function Vector2.new(x, y, z)

  local vector2 = {["x"] = x,
                   ["y"] = y}
                
  setmetatable(vector2, Vector2.mt)
  return vector2

end


function Vector2.duplicate(a)

  return Vector2.new(a.x, a.y)

end


function Vector2.add(a, b)

  return Vector2.new(a.x + b.x,
                     a.y + b.y)

end


function Vector2.subtract(a, b)

  return Vector2.new(a.x - b.x,
                     a.y - b.y)

end


function Vector2.dot_product(a, b)

  return a.x * b.x + a.y * b.y

end


function Vector2.multiply_constant(a, b)

  return Vector2.new(a.x * b,
                     a.y * b)

end


function Vector2.divide_constant(a, b)

  return Vector2.new(a.x / b,
                     a.y / b)

end


-- 3x3 Matrix functions

function Matrix3x3.new(m11, m21, m31,
                       m12, m22, m32,
                       m13, m23, m33)

  local matrix3x3 = {["m11"] = m11, ["m21"] = m21, ["m31"] = m31,
                     ["m12"] = m12, ["m22"] = m22, ["m32"] = m32,
                     ["m13"] = m13, ["m23"] = m23, ["m33"] = m33}

  setmetatable(matrix3x3, Matrix3x3.mt)
  return matrix3x3


end


function Matrix3x3.generate_y_rotation_matrix(angle)

  return Matrix3x3.new(cos(angle), 0, -sin(angle),
                       0,          1, 0,
                       sin(angle), 0, cos(angle))

end


function Matrix3x3.generate_x_rotation_matrix(angle)

  return Matrix3x3.new(1, 0,           0,
                       0, cos(angle),  sin(angle),
                       0, -sin(angle), cos(angle))

end


function Matrix3x3.multiply_matrix_vector(matrix, vector)

  return Vector3.new(
    vector.x * matrix.m11 + vector.y * matrix.m21 + vector.z * matrix.m31,
    vector.x * matrix.m12 + vector.y * matrix.m22 + vector.z * matrix.m32,
    vector.x * matrix.m13 + vector.y * matrix.m23 + vector.z * matrix.m33
  )

end


function Matrix3x3.multiply_matrix_matrix(leftMatrix, rightMatrix)

  local lmRow1 = Vector3.new(leftMatrix.m11, leftMatrix.m21, leftMatrix.m31)
  local lmRow2 = Vector3.new(leftMatrix.m12, leftMatrix.m22, leftMatrix.m32)
  local lmRow3 = Vector3.new(leftMatrix.m13, leftMatrix.m23, leftMatrix.m33)

  local rmColumn1 = Vector3.new(rightMatrix.m11, rightMatrix.m12, rightMatrix.m13)
  local rmColumn2 = Vector3.new(rightMatrix.m21, rightMatrix.m22, rightMatrix.m23)
  local rmColumn3 = Vector3.new(rightMatrix.m31, rightMatrix.m32, rightMatrix.m33)

  return Matrix3x3.new(lmRow1 ^ rmColumn1, lmRow1 ^ rmColumn2, lmRow1 ^ rmColumn3,
                       lmRow2 ^ rmColumn1, lmRow2 ^ rmColumn2, lmRow2 ^ rmColumn3,
                       lmRow3 ^ rmColumn1, lmRow3 ^ rmColumn2, lmRow3 ^ rmColumn3)

end


-- General math functions

-- result is positive if points are in counter-clockwise order, negative otherwise.
function signedTriArea(xa, ya, xb, yb, xc, yc)

  return ((xb - xa) * (yc - ya) - (yb - ya) * (xc - xa))

end


function round_positive(num)

  return (num + 0.5) & 0xFF.00

end