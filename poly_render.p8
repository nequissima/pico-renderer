pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

#include vectors.lua
#include graphics.lua
#include helper_funcs.lua
#include objects.lua

cameradir = {["x"] = 0, ["y"] = 0, ["z"] = 1}
origin = {["x"] = 0, ["y"] = 0, ["z"] = 0}

-- main loop
function _init()

  -- yes i'm aware horizontal and vertical are not the right terms to use here but
  -- you get what i mean here

  -- horizontal rotation and the update increment
  hrot = 0
  hrotd = 0.025

  -- vertical rotation and the update increment
  vrot = 0
  vrotd = 0.01

  -- translation vector
  translation = create_vector_3d(0,0,15)

  -- horizontal rotation matrix
  hrotmat = create_rotation_matrix_y(hrot)

  -- vertical rotation matrix
  vrotmat = create_rotation_matrix_x(vrot)

  obj = create_icosahedron()

  redpalette()

end

function _draw()

  cls()
  render_object(obj, hrotmat, vrotmat, translation)
  
end

function _update()

  hrotmat = create_rotation_matrix_y(hrot)
  vrotmat = create_rotation_matrix_x(vrot)
  hrot = hrot + hrotd
  vrot = vrot + vrotd

end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
