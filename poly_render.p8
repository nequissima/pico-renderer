pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

#include vectors.lua
#include graphics.lua
#include helper_funcs.lua
#include objects.lua

loggingdone = false

origin = {["x"] = 0, ["y"] = 0, ["z"] = 0}

-- main loop
function _init()

  --[[

  p1 = create_vector_3d(0, 1, 3)
  p2 = create_vector_3d(1, -1, 3)
  p3 = create_vector_3d(1, 1, 5)
  
  poly1 = create_3d_polygon(p1, p2, p3)

  p4 = create_vector_3d(0, 1, 3)
  p5 = create_vector_3d(1, -1, 3)
  p6 = create_vector_3d(-1, -1, 3)

  poly2 = create_3d_polygon(p4, p5, p6)

  obj = create_object({poly1, poly2}, cpoint)

  relative = polygon_to_relative(poly1)
  print(tostr(poly1[1]))
  print(tostr(poly1[2]))
  print(tostr(poly1[3]))

  ]]

  rot = 0
  rotd = 0.05

  translation = create_vector_3d(0,0,3)
  rotmat = create_rotation_matrix_y(rot)

  obj = create_cube()
  

end

function _draw()

  cls()
  color(6)
  render_object(obj, rotmat, translation)

end

function _update()

  rotmat = create_rotation_matrix_y(rot)
  rot = rot + rotd

end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
